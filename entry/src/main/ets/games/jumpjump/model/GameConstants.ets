/**
 * 跳一跳游戏常量定义
 */
export class GameConstants {
  // 画布尺寸
  static readonly CANVAS_WIDTH: number = 360;
  static readonly CANVAS_HEIGHT: number = 760;

  // 2.5D 等距投影参数
  static readonly ISO_SCALE_X: number = 0.5;      // 等距 X 缩放
  static readonly ISO_SCALE_Y: number = 0.35;     // 等距 Y 缩放
  static readonly PLATFORM_DEPTH: number = 18;    // 平台深度（侧面高度）
  static readonly HEIGHT_SCALE: number = 1.45;    // 高度缩放

  // 玩家属性
  static readonly PLAYER_SIZE: number = 35;
  static readonly PLAYER_MAX_COMPRESS: number = 0.4; // 最大压缩比例

  // 跳跃参数
  static readonly JUMP_POWER_FACTOR: number = 0.3; // 蓄力转跳跃距离系数
  static readonly MAX_CHARGE_TIME: number = 1650; // 最大蓄力时间(ms)
  static readonly GRAVITY: number = 1500; // 重力加速度
  static readonly JUMP_INITIAL_VELOCITY_Y: number = -600; // 跳跃初始垂直速度

  // 方块参数
  static readonly PLATFORM_MIN_SIZE: number = 60;
  static readonly PLATFORM_MAX_SIZE: number = 100;
  static readonly PLATFORM_HEIGHT: number = 25;
  static readonly PLATFORM_GAP_MIN: number = 122;
  static readonly PLATFORM_GAP_MAX: number = 168;
  static readonly PLATFORM_Y: number = 480; // 方块基础Y位置（世界坐标基准）

  // 游戏规则
  static readonly SCORE_PER_LAND: number = 1;
  static readonly SCORE_PERFECT_BONUS: number = 2; // 完美落地额外加分
  static readonly PERFECT_THRESHOLD: number = 10; // 完美落地阈值(像素)

  // 背景颜色（暖色渐变）
  static readonly COLOR_BACKGROUND_TOP: string = '#D6D8E0';
  static readonly COLOR_BACKGROUND_BOTTOM: string = '#CDD0D9';

  // 玩家颜色
  static readonly COLOR_PLAYER: string = '#2C2A49';
  static readonly COLOR_PLAYER_TOP: string = '#4C4A7A';
  static readonly COLOR_PLAYER_HIGHLIGHT: string = '#7F7CB5';
  static readonly COLOR_PLAYER_SHADOW: string = 'rgba(0, 0, 0, 0.28)';

  // 平台颜色数组（多种柔和色彩）
  static readonly PLATFORM_COLORS: string[] = [
    '#ECECEC',
    '#DDDDDD',
    '#6A6A6A',
    '#76A378',
    '#E4E4E4',
    '#B9B9B9',
    '#F1F1F1',
    '#C7C7C7',
  ];

  // 蓄力条颜色
  static readonly COLOR_CHARGE_BAR_BG: string = 'rgba(0,0,0,0.22)';
  static readonly COLOR_CHARGE_BAR_FILL: string = '#6FC58B';

  // 文字颜色
  static readonly COLOR_TEXT: string = '#4A4A4A';
  static readonly COLOR_SCORE_SHADOW: string = '#000000';
}
