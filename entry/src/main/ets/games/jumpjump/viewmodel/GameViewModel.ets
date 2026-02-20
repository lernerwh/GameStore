import { GameEngine } from './GameEngine';
import { Player } from '../model/Player';
import { Platform } from '../model/Platform';
import { GameState } from '../model/GameState';
import { GameConstants } from '../model/GameConstants';

@Observed
export class GameViewModel {
  private engine: GameEngine;
  @Track gameState: GameState;
  @Track score: number;
  @Track highScore: number;
  @Track player: Player;
  @Track platforms: Platform[];
  @Track cameraOffsetX: number;
  @Track chargeProgress: number;

  private intervalId: number | null = null;
  private lastFrameTime: number = 0;
  private readonly FRAME_TIME: number = 1000 / 60;

  constructor() {
    this.engine = new GameEngine();
    this.gameState = GameState.IDLE;
    this.score = 0;
    this.highScore = 0;
    this.player = this.engine.getPlayer();
    this.platforms = this.engine.getPlatforms();
    this.cameraOffsetX = 0;
    this.chargeProgress = 0;
  }

  /**
   * 开始游戏
   */
  startGame(): void {
    this.engine.startGame();
    this.syncState();
    this.startGameLoop();
  }

  /**
   * 开始蓄力（按下屏幕）
   */
  startCharge(): void {
    this.engine.startCharge();
    this.syncState();
  }

  /**
   * 释放跳跃（松开屏幕）
   */
  releaseJump(): void {
    this.engine.releaseJump();
    this.syncState();
  }

  private startGameLoop(): void {
    this.lastFrameTime = Date.now();
    this.intervalId = setInterval(() => {
      this.gameLoop();
    }, this.FRAME_TIME);
  }

  private gameLoop(): void {
    const now = Date.now();
    const deltaTime = Math.min((now - this.lastFrameTime) / 1000, 0.1);
    this.lastFrameTime = now;

    this.engine.update(deltaTime);
    this.syncState();

    if (this.gameState === GameState.GAME_OVER) {
      this.stopGameLoop();
    }
  }

  private syncState(): void {
    this.gameState = this.engine.getGameState();
    this.score = this.engine.getScore();
    this.player = this.engine.getPlayer();
    this.platforms = [...this.engine.getPlatforms()];
    this.cameraOffsetX = this.engine.getCameraOffsetX();
    this.chargeProgress = this.engine.getChargeProgress();
  }

  private stopGameLoop(): void {
    if (this.intervalId !== null) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  destroy(): void {
    this.stopGameLoop();
    this.engine.reset();
  }
}
