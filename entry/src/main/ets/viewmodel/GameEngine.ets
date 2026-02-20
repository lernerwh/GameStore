import { Player } from '../model/entities/Player';
import { GameState } from '../model/entities/GameState';
import { GameConstants } from '../common/constants/GameConstants';

/**
 * 游戏引擎 - 核心游戏逻辑
 */
export class GameEngine {
  private player: Player;
  private gameState: GameState;
  private score: number;

  constructor() {
    this.player = new Player();
    this.gameState = GameState.IDLE;
    this.score = 0;
  }

  getPlayer(): Player {
    return this.player;
  }

  getGameState(): GameState {
    return this.gameState;
  }

  getScore(): number {
    return this.score;
  }

  startGame(): void {
    this.gameState = GameState.PLAYING;
    this.player.reset();
    this.score = 0;
  }

  update(deltaTime: number): void {
    if (this.gameState !== GameState.PLAYING) {
      return;
    }
    this.player.update(deltaTime);
    this.checkCollision();
  }

  private checkCollision(): void {
    // TODO: 根据游戏类型实现碰撞检测
  }

  private gameOver(): void {
    this.gameState = GameState.GAME_OVER;
  }

  reset(): void {
    this.player.reset();
    this.score = 0;
    this.gameState = GameState.IDLE;
  }
}
