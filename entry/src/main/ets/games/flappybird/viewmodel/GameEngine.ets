import { Bird } from '../model/Bird';
import { Pipe } from '../model/Pipe';
import { GameState } from '../model/GameState';
import { GameConstants } from '../model/GameConstants';
import { MathUtils } from '../model/MathUtils';

/**
 * 游戏引擎 - 核心游戏逻辑
 */
export class GameEngine {
  private bird: Bird;
  private pipes: Pipe[];
  private gameState: GameState;
  private score: number;
  private lastPipeSpawnTime: number;
  private groundY: number;

  constructor() {
    this.bird = new Bird();
    this.pipes = [];
    this.gameState = GameState.IDLE;
    this.score = 0;
    this.lastPipeSpawnTime = 0;
    this.groundY = GameConstants.CANVAS_HEIGHT - 50; // 地面高度
  }

  /**
   * 获取小鸟
   */
  getBird(): Bird {
    return this.bird;
  }

  /**
   * 获取管道列表
   */
  getPipes(): Pipe[] {
    return this.pipes;
  }

  /**
   * 获取游戏状态
   */
  getGameState(): GameState {
    return this.gameState;
  }

  /**
   * 获取分数
   */
  getScore(): number {
    return this.score;
  }

  /**
   * 获取地面Y坐标
   */
  getGroundY(): number {
    return this.groundY;
  }

  /**
   * 开始游戏
   */
  startGame(): void {
    this.gameState = GameState.PLAYING;
    this.bird.reset();
    this.pipes = [];
    this.score = 0;
    this.lastPipeSpawnTime = Date.now();
  }

  /**
   * 小鸟跳跃
   */
  jump(): void {
    if (this.gameState === GameState.PLAYING) {
      this.bird.jump();
    }
  }

  /**
   * 游戏主循环更新
   * @param deltaTime 时间增量 (秒)
   */
  update(deltaTime: number): void {
    if (this.gameState !== GameState.PLAYING) {
      return;
    }

    // 更新小鸟
    this.bird.update(deltaTime);

    // 生成新管道
    this.spawnPipes();

    // 更新管道
    this.updatePipes(deltaTime);

    // 检查得分
    this.checkScore();

    // 检查碰撞
    this.checkCollision();
  }

  /**
   * 生成新管道
   */
  private spawnPipes(): void {
    const now = Date.now();
    if (now - this.lastPipeSpawnTime >= GameConstants.PIPE_SPAWN_INTERVAL) {
      const topHeight = MathUtils.randomInt(
        GameConstants.PIPE_MIN_HEIGHT,
        GameConstants.PIPE_MAX_HEIGHT
      );
      this.pipes.push(new Pipe(GameConstants.CANVAS_WIDTH, topHeight));
      this.lastPipeSpawnTime = now;
    }
  }

  /**
   * 更新管道位置
   */
  private updatePipes(deltaTime: number): void {
    // 更新所有管道
    for (const pipe of this.pipes) {
      pipe.update(deltaTime);
    }

    // 移除离开屏幕的管道
    this.pipes = this.pipes.filter(pipe => !pipe.isOffScreen());
  }

  /**
   * 检查得分
   */
  private checkScore(): void {
    for (const pipe of this.pipes) {
      if (pipe.checkPassed(this.bird.x)) {
        this.score += GameConstants.SCORE_PER_PIPE;
      }
    }
  }

  /**
   * 检查碰撞
   */
  private checkCollision(): void {
    // 检查是否撞地或飞出顶部
    if (this.bird.y < 0 || this.bird.y + this.bird.height > this.groundY) {
      this.gameOver();
      return;
    }

    // 检查与管道的碰撞
    const birdRect = this.bird.getCollisionRect();

    for (const pipe of this.pipes) {
      // 检查与上管道碰撞
      const topPipeRect = pipe.getTopCollisionRect();
      if (MathUtils.checkRectCollision(birdRect, topPipeRect)) {
        this.gameOver();
        return;
      }

      // 检查与下管道碰撞
      const bottomPipeRect = pipe.getBottomCollisionRect();
      if (MathUtils.checkRectCollision(birdRect, bottomPipeRect)) {
        this.gameOver();
        return;
      }
    }
  }

  /**
   * 游戏结束
   */
  private gameOver(): void {
    this.gameState = GameState.GAME_OVER;
  }

  /**
   * 重置游戏
   */
  reset(): void {
    this.bird.reset();
    this.pipes = [];
    this.score = 0;
    this.lastPipeSpawnTime = 0;
    this.gameState = GameState.IDLE;
  }
}
