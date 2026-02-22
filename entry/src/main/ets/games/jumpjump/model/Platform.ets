import { GameConstants } from './GameConstants';
import { Rect, MathUtils } from './MathUtils';

/**
 * 平台/方块实体类 - 支持2.5D世界坐标
 */
export class Platform {
  worldX: number;      // 世界坐标X
  worldY: number;      // 世界坐标Y
  worldZ: number;      // 世界坐标Z（高度，用于渲染）
  size: number;        // 方块尺寸
  colorIndex: number;  // 颜色索引

  constructor(worldX: number, worldY: number, size?: number, colorIndex?: number) {
    this.worldX = worldX;
    this.worldY = worldY;
    this.worldZ = 0;
    this.size = size ?? MathUtils.randomInt(GameConstants.PLATFORM_MIN_SIZE, GameConstants.PLATFORM_MAX_SIZE);
    this.colorIndex = colorIndex ?? MathUtils.randomInt(0, GameConstants.PLATFORM_COLORS.length - 1);
  }

  /**
   * 获取平台颜色
   */
  getColor(): string {
    return GameConstants.PLATFORM_COLORS[this.colorIndex];
  }

  /**
   * 获取平台较暗颜色（用于右侧面）
   */
  getDarkColor(): string {
    return this.darkenColor(this.getColor(), 0.3);
  }

  /**
   * 获取平台中等颜色（用于左侧面）
   */
  getMediumColor(): string {
    return this.darkenColor(this.getColor(), 0.15);
  }

  /**
   * 使颜色变暗
   */
  private darkenColor(hex: string, factor: number): string {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);

    const newR = Math.floor(r * (1 - factor));
    const newG = Math.floor(g * (1 - factor));
    const newB = Math.floor(b * (1 - factor));

    return `#${newR.toString(16).padStart(2, '0')}${newG.toString(16).padStart(2, '0')}${newB.toString(16).padStart(2, '0')}`;
  }

  /**
   * 检测点是否在平台顶部（使用世界坐标距离检测）
   * @param pointWorldX 点的世界X坐标
   * @param pointWorldY 点的世界Y坐标
   */
  containsPoint(pointWorldX: number, pointWorldY: number): boolean {
    // 在2.5D视角中，平台是一个正方形区域
    // 检测点到平台中心的距离是否在尺寸的一半范围内
    const dx = pointWorldX - this.worldX;
    const dy = pointWorldY - this.worldY;
    const distance = Math.sqrt(dx * dx + dy * dy);
    const halfSize = this.size / 2;

    // 精确检测：只在平台范围内才算
    return distance < halfSize;
  }

  /**
   * 计算点到平台中心的距离（世界坐标）
   */
  distanceToCenter(pointWorldX: number, pointWorldY: number): number {
    const dx = pointWorldX - this.worldX;
    const dy = pointWorldY - this.worldY;
    return Math.sqrt(dx * dx + dy * dy);
  }

  /**
   * 生成下一个方块（沿45度斜向）
   * @param currentWorldX 当前方块世界X坐标
   * @param currentWorldY 当前方块世界Y坐标
   */
  static generateNext(currentWorldX: number, currentWorldY: number): Platform {
    const gap = MathUtils.randomInt(GameConstants.PLATFORM_GAP_MIN, GameConstants.PLATFORM_GAP_MAX);

    // 沿45度角方向生成（x和y同时增加）
    const newWorldX = currentWorldX + gap;
    const newWorldY = currentWorldY + gap;

    return new Platform(newWorldX, newWorldY);
  }
}
