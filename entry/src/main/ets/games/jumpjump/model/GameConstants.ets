/**
 * 跳一跳游戏常量定义
 */
export class GameConstants {
  // 画布尺寸
  static readonly CANVAS_WIDTH: number = 360;
  static readonly CANVAS_HEIGHT: number = 640;

  // 玩家属性
  static readonly PLAYER_SIZE: number = 35;
  static readonly PLAYER_MAX_COMPRESS: number = 0.4; // 最大压缩比例

  // 跳跃参数
  static readonly JUMP_POWER_FACTOR: number = 0.35; // 蓄力转跳跃距离系数
  static readonly MAX_CHARGE_TIME: number = 1500; // 最大蓄力时间(ms)
  static readonly GRAVITY: number = 1500; // 重力加速度
  static readonly JUMP_INITIAL_VELOCITY_Y: number = -600; // 跳跃初始垂直速度

  // 方块参数
  static readonly PLATFORM_MIN_SIZE: number = 50;
  static readonly PLATFORM_MAX_SIZE: number = 90;
  static readonly PLATFORM_HEIGHT: number = 25;
  static readonly PLATFORM_GAP_MIN: number = 60;
  static readonly PLATFORM_GAP_MAX: number = 160;
  static readonly PLATFORM_Y: number = 480; // 方块基础Y位置

  // 游戏规则
  static readonly SCORE_PER_LAND: number = 1;
  static readonly SCORE_PERFECT_BONUS: number = 2; // 完美落地额外加分
  static readonly PERFECT_THRESHOLD: number = 10; // 完美落地阈值(像素)

  // 颜色定义
  static readonly COLOR_BACKGROUND: string = '#DEB887';
  static readonly COLOR_PLAYER: string = '#2C2C2C';
  static readonly COLOR_PLAYER_TOP: string = '#4A4A4A';
  static readonly COLOR_PLAYER_HIGHLIGHT: string = '#666666';
  static readonly COLOR_PLATFORM_SHADOW: string = '#8B7355';
  static readonly COLOR_PLATFORM_TOP: string = '#C4A574';
  static readonly COLOR_PLATFORM_SIDE: string = '#A08050';
  static readonly COLOR_CHARGE_BAR_BG: string = 'rgba(0,0,0,0.3)';
  static readonly COLOR_CHARGE_BAR_FILL: string = '#FF6347';
  static readonly COLOR_TEXT: string = '#4A4A4A';
  static readonly COLOR_SCORE_SHADOW: string = '#000000';
}
