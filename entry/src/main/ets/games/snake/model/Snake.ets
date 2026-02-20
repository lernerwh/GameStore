import { SnakePoint } from './Point';
import { SnakeConstants } from './SnakeConstants';

/**
 * 蛇实体
 */
export class Snake {
  body: SnakePoint[] = [];
  direction: number = SnakeConstants.DIRECTION_RIGHT;
  nextDirection: number = SnakeConstants.DIRECTION_RIGHT;
  growPending: boolean = false;

  constructor() {
    this.reset();
  }

  reset(): void {
    // 初始位置在中间
    const startX = Math.floor(SnakeConstants.GRID_WIDTH / 2);
    const startY = Math.floor(SnakeConstants.GRID_HEIGHT / 2);

    this.body = [
      { x: startX, y: startY },
      { x: startX - 1, y: startY },
      { x: startX - 2, y: startY }
    ];
    this.direction = SnakeConstants.DIRECTION_RIGHT;
    this.nextDirection = SnakeConstants.DIRECTION_RIGHT;
    this.growPending = false;
  }

  getHead(): SnakePoint {
    return this.body[0];
  }

  setDirection(newDirection: number): void {
    // 防止反向移动
    const opposite: number = (this.direction + 2) % 4;
    if (newDirection !== opposite) {
      this.nextDirection = newDirection;
    }
  }

  move(): void {
    this.direction = this.nextDirection;
    const head: SnakePoint = this.getHead();
    let newHead: SnakePoint = { x: head.x, y: head.y };

    switch (this.direction) {
      case SnakeConstants.DIRECTION_UP:
        newHead.y -= 1;
        break;
      case SnakeConstants.DIRECTION_RIGHT:
        newHead.x += 1;
        break;
      case SnakeConstants.DIRECTION_DOWN:
        newHead.y += 1;
        break;
      case SnakeConstants.DIRECTION_LEFT:
        newHead.x -= 1;
        break;
    }

    this.body.unshift(newHead);

    if (!this.growPending) {
      this.body.pop();
    } else {
      this.growPending = false;
    }
  }

  grow(): void {
    this.growPending = true;
  }

  checkSelfCollision(): boolean {
    const head: SnakePoint = this.getHead();
    for (let i = 1; i < this.body.length; i++) {
      if (this.body[i].x === head.x && this.body[i].y === head.y) {
        return true;
      }
    }
    return false;
  }

  checkWallCollision(): boolean {
    const head: SnakePoint = this.getHead();
    return head.x < 0 || head.x >= SnakeConstants.GRID_WIDTH ||
           head.y < 0 || head.y >= SnakeConstants.GRID_HEIGHT;
  }
}
