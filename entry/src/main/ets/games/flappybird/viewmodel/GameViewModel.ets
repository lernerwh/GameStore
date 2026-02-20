import { GameEngine } from './GameEngine';
import { Bird } from '../model/Bird';
import { Pipe } from '../model/Pipe';
import { GameState } from '../model/GameState';

/**
 * 游戏视图模型 - 状态管理
 * 使用 @Observed 和 @Track 实现响应式状态
 */
@Observed
export class GameViewModel {
  /** 游戏引擎 */
  private engine: GameEngine;

  /** 游戏状态 */
  @Track gameState: GameState;

  /** 分数 */
  @Track score: number;

  /** 最高分 */
  @Track highScore: number;

  /** 小鸟引用 */
  @Track bird: Bird;

  /** 管道列表引用 */
  @Track pipes: Pipe[];

  /** 地面Y坐标 */
  @Track groundY: number;

  /** 游戏循环定时器ID */
  private intervalId: number | null;

  /** 上一帧时间戳 */
  private lastFrameTime: number;

  /** 帧率 (FPS) */
  private readonly TARGET_FPS: number = 60;
  private readonly FRAME_TIME: number = 1000 / 60;

  constructor() {
    this.engine = new GameEngine();
    this.gameState = GameState.IDLE;
    this.score = 0;
    this.highScore = 0;
    this.bird = this.engine.getBird();
    this.pipes = [];
    this.groundY = this.engine.getGroundY();
    this.intervalId = null;
    this.lastFrameTime = 0;
  }

  /**
   * 开始游戏
   */
  startGame(): void {
    this.engine.startGame();
    this.gameState = this.engine.getGameState();
    this.startGameLoop();
  }

  /**
   * 小鸟跳跃
   */
  jump(): void {
    this.engine.jump();
  }

  /**
   * 获取当前游戏状态
   */
  getGameState(): GameState {
    return this.gameState;
  }

  /**
   * 获取当前分数
   */
  getScore(): number {
    return this.score;
  }

  /**
   * 获取最高分
   */
  getHighScore(): number {
    return this.highScore;
  }

  /**
   * 设置最高分
   */
  setHighScore(score: number): void {
    this.highScore = score;
  }

  /**
   * 启动游戏循环
   */
  private startGameLoop(): void {
    this.lastFrameTime = Date.now();

    this.intervalId = setInterval(() => {
      this.gameLoop();
    }, this.FRAME_TIME);
  }

  /**
   * 游戏循环
   */
  private gameLoop(): void {
    const now = Date.now();
    const deltaTime = (now - this.lastFrameTime) / 1000; // 转换为秒
    this.lastFrameTime = now;

    // 限制deltaTime防止卡顿时物理异常
    const clampedDelta = Math.min(deltaTime, 0.1);

    // 更新引擎
    this.engine.update(clampedDelta);

    // 同步状态
    this.syncState();
  }

  /**
   * 同步引擎状态到视图模型
   */
  private syncState(): void {
    this.gameState = this.engine.getGameState();
    this.score = this.engine.getScore();
    this.pipes = [...this.engine.getPipes()]; // 创建新数组触发响应式更新

    // 如果游戏结束，停止循环
    if (this.gameState === GameState.GAME_OVER) {
      this.stopGameLoop();
    }
  }

  /**
   * 停止游戏循环
   */
  private stopGameLoop(): void {
    if (this.intervalId !== null) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  /**
   * 重新开始游戏
   */
  restartGame(): void {
    this.stopGameLoop();
    this.engine.reset();
    this.gameState = GameState.IDLE;
    this.score = 0;
    this.pipes = [];
  }

  /**
   * 清理资源
   */
  destroy(): void {
    this.stopGameLoop();
  }
}
