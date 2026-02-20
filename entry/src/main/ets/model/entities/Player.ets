import { GameConstants } from '../../common/constants/GameConstants';
import { Rect } from '../../common/utils/MathUtils';

/**
 * 玩家实体类
 */
export class Player {
  x: number;
  y: number;
  width: number;
  height: number;
  velocityX: number;
  velocityY: number;

  constructor() {
    this.x = GameConstants.CANVAS_WIDTH / 2 - GameConstants.PLAYER_SIZE / 2;
    this.y = GameConstants.CANVAS_HEIGHT / 2;
    this.width = GameConstants.PLAYER_SIZE;
    this.height = GameConstants.PLAYER_SIZE;
    this.velocityX = 0;
    this.velocityY = 0;
  }

  reset(): void {
    this.x = GameConstants.CANVAS_WIDTH / 2 - GameConstants.PLAYER_SIZE / 2;
    this.y = GameConstants.CANVAS_HEIGHT / 2;
    this.velocityX = 0;
    this.velocityY = 0;
  }

  update(deltaTime: number): void {
    this.x += this.velocityX * deltaTime;
    this.y += this.velocityY * deltaTime;

    // 边界限制
    this.x = Math.max(0, Math.min(GameConstants.CANVAS_WIDTH - this.width, this.x));
    this.y = Math.max(0, Math.min(GameConstants.CANVAS_HEIGHT - this.height, this.y));
  }

  getCollisionRect(): Rect {
    const rect: Rect = {
      x: this.x,
      y: this.y,
      width: this.width,
      height: this.height
    };
    return rect;
  }
}
