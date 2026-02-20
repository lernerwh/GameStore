import { Snake } from '../model/Snake';
import { Food } from '../model/Food';
import { SnakeState } from '../model/SnakeState';
import { SnakeConstants } from '../model/SnakeConstants';

/**
 * 贪吃蛇游戏引擎
 */
export class SnakeEngine {
  snake: Snake = new Snake();
  food: Food = new Food();
  gameState: SnakeState = SnakeState.IDLE;
  score: number = 0;
  highScore: number = 0;
  private gameInterval: number | null = null;

  constructor() {
    this.food.spawn(this.snake);
  }

  startGame(): void {
    this.snake.reset();
    this.food.spawn(this.snake);
    this.score = 0;
    this.gameState = SnakeState.PLAYING;
  }

  update(): void {
    if (this.gameState !== SnakeState.PLAYING) {
      return;
    }

    this.snake.move();

    // 检查碰撞
    if (this.snake.checkWallCollision() || this.snake.checkSelfCollision()) {
      this.gameOver();
      return;
    }

    // 检查吃到食物
    const head = this.snake.getHead();
    if (head.x === this.food.position.x && head.y === this.food.position.y) {
      this.snake.grow();
      this.score += 10;
      this.food.spawn(this.snake);

      if (this.score > this.highScore) {
        this.highScore = this.score;
      }
    }
  }

  setDirection(direction: number): void {
    if (this.gameState === SnakeState.PLAYING) {
      this.snake.setDirection(direction);
    }
  }

  pauseGame(): void {
    if (this.gameState === SnakeState.PLAYING) {
      this.gameState = SnakeState.PAUSED;
    }
  }

  resumeGame(): void {
    if (this.gameState === SnakeState.PAUSED) {
      this.gameState = SnakeState.PLAYING;
    }
  }

  private gameOver(): void {
    this.gameState = SnakeState.GAME_OVER;
  }

  destroy(): void {
    if (this.gameInterval !== null) {
      clearInterval(this.gameInterval);
      this.gameInterval = null;
    }
  }
}
