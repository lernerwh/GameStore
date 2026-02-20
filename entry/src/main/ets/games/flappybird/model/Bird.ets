import { GameConstants } from './GameConstants';
import { Rect } from './MathUtils';

/**
 * 小鸟实体类
 */
export class Bird {
  /** X坐标 */
  x: number;
  /** Y坐标 */
  y: number;
  /** 宽度 */
  width: number;
  /** 高度 */
  height: number;
  /** Y方向速度 (像素/秒) */
  velocityY: number;
  /** 旋转角度 (弧度) */
  rotation: number;

  constructor() {
    this.x = GameConstants.BIRD_X;
    this.y = GameConstants.BIRD_INIT_Y;
    this.width = GameConstants.BIRD_WIDTH;
    this.height = GameConstants.BIRD_HEIGHT;
    this.velocityY = 0;
    this.rotation = 0;
  }

  /**
   * 重置小鸟状态
   */
  reset(): void {
    this.x = GameConstants.BIRD_X;
    this.y = GameConstants.BIRD_INIT_Y;
    this.velocityY = 0;
    this.rotation = 0;
  }

  /**
   * 执行跳跃
   */
  jump(): void {
    this.velocityY = GameConstants.JUMP_VELOCITY;
  }

  /**
   * 更新小鸟位置
   * @param deltaTime 时间增量 (秒)
   */
  update(deltaTime: number): void {
    // 应用重力
    this.velocityY += GameConstants.GRAVITY * deltaTime;

    // 限制最大下落速度
    if (this.velocityY > GameConstants.MAX_FALL_VELOCITY) {
      this.velocityY = GameConstants.MAX_FALL_VELOCITY;
    }

    // 更新Y坐标
    this.y += this.velocityY * deltaTime;

    // 更新旋转角度 (根据速度)
    if (this.velocityY < 0) {
      // 上升时向上旋转
      this.rotation = Math.max(-0.5, this.velocityY / 1000);
    } else {
      // 下落时向下旋转
      this.rotation = Math.min(Math.PI / 4, this.velocityY / 800);
    }
  }

  /**
   * 获取碰撞矩形
   */
  getCollisionRect(): Rect {
    // 稍微缩小碰撞盒以提高游戏体验
    const padding = 4;
    const rect: Rect = {
      x: this.x + padding,
      y: this.y + padding,
      width: this.width - padding * 2,
      height: this.height - padding * 2
    };
    return rect;
  }
}
