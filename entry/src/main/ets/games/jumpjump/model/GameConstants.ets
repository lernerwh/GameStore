/**
 * 跳一跳游戏常量定义
 */
export class GameConstants {
  // 画布尺寸
  static readonly CANVAS_WIDTH: number = 360;
  static readonly CANVAS_HEIGHT: number = 640;

  // 2.5D 等距投影参数
  static readonly ISO_SCALE_X: number = 0.5;      // 等距 X 缩放
  static readonly ISO_SCALE_Y: number = 0.35;     // 等距 Y 缩放
  static readonly PLATFORM_DEPTH: number = 15;    // 平台深度（侧面高度）
  static readonly HEIGHT_SCALE: number = 1.5;     // 高度缩放（增大让跳跃/下落更明显）

  // 玩家属性
  static readonly PLAYER_SIZE: number = 35;
  static readonly PLAYER_MAX_COMPRESS: number = 0.4; // 最大压缩比例

  // 跳跃参数
  static readonly JUMP_POWER_FACTOR: number = 0.35; // 蓄力转跳跃距离系数
  static readonly MAX_CHARGE_TIME: number = 1500; // 最大蓄力时间(ms)
  static readonly GRAVITY: number = 1500; // 重力加速度
  static readonly JUMP_INITIAL_VELOCITY_Y: number = -600; // 跳跃初始垂直速度

  // 方块参数
  static readonly PLATFORM_MIN_SIZE: number = 60;
  static readonly PLATFORM_MAX_SIZE: number = 100;
  static readonly PLATFORM_HEIGHT: number = 25;
  static readonly PLATFORM_GAP_MIN: number = 80;
  static readonly PLATFORM_GAP_MAX: number = 180;
  static readonly PLATFORM_Y: number = 480; // 方块基础Y位置（世界坐标基准）

  // 游戏规则
  static readonly SCORE_PER_LAND: number = 1;
  static readonly SCORE_PERFECT_BONUS: number = 2; // 完美落地额外加分
  static readonly PERFECT_THRESHOLD: number = 10; // 完美落地阈值(像素)

  // 背景颜色（暖色渐变）
  static readonly COLOR_BACKGROUND_TOP: string = '#F5E6D3';
  static readonly COLOR_BACKGROUND_BOTTOM: string = '#E8D4B8';

  // 玩家颜色
  static readonly COLOR_PLAYER: string = '#2C2C2C';
  static readonly COLOR_PLAYER_TOP: string = '#4A4A4A';
  static readonly COLOR_PLAYER_HIGHLIGHT: string = '#666666';
  static readonly COLOR_PLAYER_SHADOW: string = 'rgba(0, 0, 0, 0.3)';

  // 平台颜色数组（多种柔和色彩）
  static readonly PLATFORM_COLORS: string[] = [
    '#7EC8E3',  // 浅蓝
    '#98D8AA',  // 浅绿
    '#F5A9B8',  // 浅粉
    '#F5E6A3',  // 米黄
    '#C9B1FF',  // 浅紫
    '#FFB347',  // 浅橙
    '#87CEEB',  // 天蓝
    '#98FB98',  // 浅草绿
  ];

  // 蓄力条颜色
  static readonly COLOR_CHARGE_BAR_BG: string = 'rgba(0,0,0,0.3)';
  static readonly COLOR_CHARGE_BAR_FILL: string = '#FF6347';

  // 文字颜色
  static readonly COLOR_TEXT: string = '#4A4A4A';
  static readonly COLOR_SCORE_SHADOW: string = '#000000';
}
