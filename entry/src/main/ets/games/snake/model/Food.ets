import { SnakePoint } from './Point';
import { SnakeConstants } from './SnakeConstants';
import { Snake } from './Snake';

/**
 * 食物实体
 */
export class Food {
  position: SnakePoint = { x: 0, y: 0 };

  spawn(snake: Snake): void {
    let validPosition: boolean = false;

    while (!validPosition) {
      this.position = {
        x: Math.floor(Math.random() * SnakeConstants.GRID_WIDTH),
        y: Math.floor(Math.random() * SnakeConstants.GRID_HEIGHT)
      };

      // 确保食物不在蛇身上
      validPosition = !snake.body.some((segment: SnakePoint) =>
        segment.x === this.position.x && segment.y === this.position.y
      );
    }
  }
}
