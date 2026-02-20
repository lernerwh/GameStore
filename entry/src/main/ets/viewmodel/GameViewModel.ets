import { GameEngine } from './GameEngine';
import { Player } from '../model/entities/Player';
import { GameState } from '../model/entities/GameState';

@Observed
export class GameViewModel {
  private engine: GameEngine;
  @Track gameState: GameState;
  @Track score: number;
  @Track highScore: number;
  @Track player: Player;

  private intervalId: number | null = null;
  private lastFrameTime: number = 0;
  private readonly FRAME_TIME: number = 1000 / 60;

  constructor() {
    this.engine = new GameEngine();
    this.gameState = GameState.IDLE;
    this.score = 0;
    this.highScore = 0;
    this.player = this.engine.getPlayer();
  }

  startGame(): void {
    this.engine.startGame();
    this.gameState = this.engine.getGameState();
    this.startGameLoop();
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
  }
}
