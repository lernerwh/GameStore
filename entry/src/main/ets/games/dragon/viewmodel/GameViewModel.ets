import { GameEngine, Camera } from './GameEngine';
import { Player } from '../../../model/Player';
import { Creature } from '../../../model/Creature';
import { Pellet } from '../../../model/Pellet';
import { GameState } from '../../../model/GameState';

@Observed
export class GameViewModel {
  private engine: GameEngine;
  @Track gameState: GameState;
  @Track score: number;
  @Track highScore: number;
  @Track player: Player;
  @Track hasWon: boolean;
  @Track playTime: number;

  private intervalId: number | null = null;
  private lastFrameTime: number = 0;
  private readonly FRAME_TIME: number = 1000 / 60;

  constructor() {
    this.engine = new GameEngine();
    this.gameState = GameState.IDLE;
    this.score = 0;
    this.highScore = 0;
    this.hasWon = false;
    this.playTime = 0;
    this.player = this.engine.getPlayer();
  }

  get creatures(): Creature[] {
    return this.engine.getCreatures();
  }

  get pellets(): Pellet[] {
    return this.engine.getPellets();
  }

  getCamera(): Camera {
    return this.engine.getCamera();
  }

  startGame(): void {
    this.engine.startGame();
    this.gameState = this.engine.getGameState();
    this.startGameLoop();
  }

  setPlayerTarget(screenX: number, screenY: number): void {
    const camera = this.getCamera();
    const worldPoint = camera.screenToWorld(screenX, screenY);
    const worldX = worldPoint.x;
    const worldY = worldPoint.y;
    this.engine.setPlayerTarget(worldX, worldY);
  }

  /**
   * 根据虚拟手柄拖拽向量设置角色移动方向。
   * deltaX/deltaY 为屏幕坐标系下，相对于摇杆中心的偏移。
   * strength 取值建议为 [0, 1]，用于控制目标点距离。
   */
  setPlayerDirectionInput(deltaX: number, deltaY: number, strength: number): void {
    const len = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
    if (len < 1) {
      return;
    }

    const normalizedX = deltaX / len;
    const normalizedY = deltaY / len;
    const clampedStrength = Math.max(0, Math.min(1, strength));
    const targetOffset = 120 + clampedStrength * 420;
    const player = this.engine.getPlayer();

    this.engine.setPlayerTarget(
      player.x + normalizedX * targetOffset,
      player.y + normalizedY * targetOffset
    );
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
  }

  private syncState(): void {
    this.gameState = this.engine.getGameState();
    this.score = this.engine.getScore();
    this.playTime = this.engine.getPlayTime();
    this.hasWon = this.engine.hasPlayerWon();

    if (this.score > this.highScore) {
      this.highScore = this.score;
    }

    if (this.gameState === GameState.GAME_OVER) {
      this.stopGameLoop();
    }
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
