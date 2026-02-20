import { GameConstants } from './GameConstants';
import { Rect, MathUtils } from './MathUtils';

/**
 * 平台/方块实体类
 */
export class Platform {
  x: number;           // 方块中心X坐标
  y: number;           // 方块顶部Y坐标
  width: number;       // 方块宽度
  height: number;      // 方块高度

  constructor(x: number, y: number, width?: number) {
    this.x = x;
    this.y = y;
    this.width = width ?? MathUtils.randomInt(GameConstants.PLATFORM_MIN_SIZE, GameConstants.PLATFORM_MAX_SIZE);
    this.height = GameConstants.PLATFORM_HEIGHT;
  }

  /**
   * 获取方块边界
   */
  getBounds(): Rect {
    return {
      x: this.x - this.width / 2,
      y: this.y,
      width: this.width,
      height: this.height
    };
  }

  /**
   * 检测点是否在方块顶部
   * @param pointX 点的X坐标
   * @param pointY 点的Y坐标
   * @param threshold 允许的Y偏移阈值
   */
  containsPoint(pointX: number, pointY: number, threshold: number = 20): boolean {
    const bounds = this.getBounds();
    const inX = pointX >= bounds.x && pointX <= bounds.x + bounds.width;
    const inY = pointY >= bounds.y - threshold && pointY <= bounds.y + threshold;
    return inX && inY;
  }

  /**
   * 计算点到方块中心的距离
   */
  distanceToCenter(pointX: number): number {
    return Math.abs(pointX - this.x);
  }

  /**
   * 生成下一个方块
   * @param currentX 当前方块X坐标
   */
  static generateNext(currentX: number): Platform {
    const gap = MathUtils.randomInt(GameConstants.PLATFORM_GAP_MIN, GameConstants.PLATFORM_GAP_MAX);
    const newX = currentX + gap;
    return new Platform(newX, GameConstants.PLATFORM_Y);
  }
}
