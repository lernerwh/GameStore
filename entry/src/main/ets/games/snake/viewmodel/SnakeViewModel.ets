import { SnakeEngine } from './SnakeEngine';
import { SnakeState } from '../model/SnakeState';
import { SnakeConstants } from '../model/SnakeConstants';

/**
 * 贪吃蛇游戏视图模型
 */
export class SnakeViewModel {
  private engine: SnakeEngine = new SnakeEngine();

  get snake() {
    return this.engine.snake;
  }

  get food() {
    return this.engine.food;
  }

  get gameState() {
    return this.engine.gameState;
  }

  get score() {
    return this.engine.score;
  }

  get highScore() {
    return this.engine.highScore;
  }

  startGame(): void {
    this.engine.startGame();
  }

  update(): void {
    this.engine.update();
  }

  setDirection(direction: number): void {
    this.engine.setDirection(direction);
  }

  handleSwipe(startX: number, startY: number, endX: number, endY: number): void {
    const deltaX = endX - startX;
    const deltaY = endY - startY;

    if (Math.abs(deltaX) > Math.abs(deltaY)) {
      // 水平滑动
      if (deltaX > 30) {
        this.setDirection(SnakeConstants.DIRECTION_RIGHT);
      } else if (deltaX < -30) {
        this.setDirection(SnakeConstants.DIRECTION_LEFT);
      }
    } else {
      // 垂直滑动
      if (deltaY > 30) {
        this.setDirection(SnakeConstants.DIRECTION_DOWN);
      } else if (deltaY < -30) {
        this.setDirection(SnakeConstants.DIRECTION_UP);
      }
    }
  }

  destroy(): void {
    this.engine.destroy();
  }
}
