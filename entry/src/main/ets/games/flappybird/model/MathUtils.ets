/**
 * 矩形接口
 */
export interface Rect {
  x: number;
  y: number;
  width: number;
  height: number;
}

/**
 * 数学工具类
 */
export class MathUtils {
  /**
   * 生成指定范围内的随机整数 [min, max]
   */
  static randomInt(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  /**
   * 生成指定范围内的随机浮点数 [min, max)
   */
  static randomFloat(min: number, max: number): number {
    return Math.random() * (max - min) + min;
  }

  /**
   * 矩形碰撞检测
   * @param rect1 第一个矩形
   * @param rect2 第二个矩形
   * @returns 是否碰撞
   */
  static checkRectCollision(rect1: Rect, rect2: Rect): boolean {
    return (
      rect1.x < rect2.x + rect2.width &&
      rect1.x + rect1.width > rect2.x &&
      rect1.y < rect2.y + rect2.height &&
      rect1.y + rect1.height > rect2.y
    );
  }

  /**
   * 创建矩形
   */
  static createRect(x: number, y: number, width: number, height: number): Rect {
    const rect: Rect = { x, y, width, height };
    return rect;
  }

  /**
   * 限制数值在指定范围内
   */
  static clamp(value: number, min: number, max: number): number {
    return Math.max(min, Math.min(max, value));
  }

  /**
   * 线性插值
   */
  static lerp(start: number, end: number, t: number): number {
    return start + (end - start) * t;
  }

  /**
   * 计算两点之间的距离
   */
  static distance(x1: number, y1: number, x2: number, y2: number): number {
    const dx = x2 - x1;
    const dy = y2 - y1;
    return Math.sqrt(dx * dx + dy * dy);
  }
}
