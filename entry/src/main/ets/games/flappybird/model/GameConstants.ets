/**
 * 游戏常量定义
 */
export class GameConstants {
  // 画布尺寸
  static readonly CANVAS_WIDTH: number = 360;
  static readonly CANVAS_HEIGHT: number = 640;

  // 小鸟属性
  static readonly BIRD_WIDTH: number = 40;
  static readonly BIRD_HEIGHT: number = 30;
  static readonly BIRD_X: number = 80; // 小鸟固定X坐标
  static readonly BIRD_INIT_Y: number = 300; // 小鸟初始Y坐标
  static readonly GRAVITY: number = 800; // 重力加速度 (像素/秒²)
  static readonly JUMP_VELOCITY: number = -300; // 跳跃初速度
  static readonly MAX_FALL_VELOCITY: number = 600; // 最大下落速度

  // 管道属性
  static readonly PIPE_WIDTH: number = 60;
  static readonly PIPE_GAP: number = 180; // 上下管道间隙
  static readonly PIPE_SPEED: number = 150; // 管道移动速度 (像素/秒)
  static readonly PIPE_SPAWN_INTERVAL: number = 2000; // 管道生成间隔 (毫秒)
  static readonly PIPE_MIN_HEIGHT: number = 80; // 管道最小高度
  static readonly PIPE_MAX_HEIGHT: number = 380; // 管道最大高度

  // 游戏规则
  static readonly SCORE_PER_PIPE: number = 1; // 通过每个管道得分
  static readonly GAME_OVER_DELAY: number = 1000; // 游戏结束延迟 (毫秒)

  // 颜色定义
  static readonly COLOR_SKY: string = '#87CEEB';
  static readonly COLOR_BIRD: string = '#FFD700';
  static readonly COLOR_PIPE: string = '#228B22';
  static readonly COLOR_PIPE_BORDER: string = '#006400';
  static readonly COLOR_GROUND: string = '#8B4513';
  static readonly COLOR_TEXT: string = '#FFFFFF';
  static readonly COLOR_SCORE: string = '#000000';
}
