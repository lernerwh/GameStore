import { GameConstants } from './GameConstants';
import { Rect } from './MathUtils';

/**
 * 管道类型
 */
export enum PipeType {
  /** 上管道 */
  TOP,
  /** 下管道 */
  BOTTOM
}

/**
 * 管道实体类
 */
export class Pipe {
  /** X坐标 */
  x: number;
  /** 管道宽度 */
  width: number;
  /** 上管道高度 */
  topHeight: number;
  /** 下管道Y坐标 */
  bottomY: number;
  /** 是否已被计分 */
  isScored: boolean;

  constructor(x: number, topHeight: number) {
    this.x = x;
    this.width = GameConstants.PIPE_WIDTH;
    this.topHeight = topHeight;
    this.bottomY = topHeight + GameConstants.PIPE_GAP;
    this.isScored = false;
  }

  /**
   * 更新管道位置
   * @param deltaTime 时间增量 (秒)
   */
  update(deltaTime: number): void {
    this.x -= GameConstants.PIPE_SPEED * deltaTime;
  }

  /**
   * 检查管道是否已离开屏幕
   */
  isOffScreen(): boolean {
    return this.x + this.width < 0;
  }

  /**
   * 检查小鸟是否通过管道
   * @param birdX 小鸟X坐标
   */
  checkPassed(birdX: number): boolean {
    if (!this.isScored && birdX > this.x + this.width) {
      this.isScored = true;
      return true;
    }
    return false;
  }

  /**
   * 获取上管道碰撞矩形
   */
  getTopCollisionRect(): Rect {
    const rect: Rect = {
      x: this.x,
      y: 0,
      width: this.width,
      height: this.topHeight
    };
    return rect;
  }

  /**
   * 获取下管道碰撞矩形
   */
  getBottomCollisionRect(): Rect {
    const rect: Rect = {
      x: this.x,
      y: this.bottomY,
      width: this.width,
      height: GameConstants.CANVAS_HEIGHT - this.bottomY
    };
    return rect;
  }
}
