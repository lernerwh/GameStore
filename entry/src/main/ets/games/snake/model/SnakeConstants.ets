/**
 * 贪吃蛇游戏常量
 */
export class SnakeConstants {
  // 游戏区域
  static readonly GRID_SIZE: number = 20;
  static readonly GRID_WIDTH: number = 18;
  static readonly GRID_HEIGHT: number = 30;

  // 像素尺寸
  static readonly CANVAS_WIDTH: number = SnakeConstants.GRID_SIZE * SnakeConstants.GRID_WIDTH;
  static readonly CANVAS_HEIGHT: number = SnakeConstants.GRID_SIZE * SnakeConstants.GRID_HEIGHT;

  // 颜色
  static readonly COLOR_BACKGROUND: string = '#1a1a2e';
  static readonly COLOR_GRID: string = '#16213e';
  static readonly COLOR_SNAKE_HEAD: string = '#4ade80';
  static readonly COLOR_SNAKE_BODY: string = '#22c55e';
  static readonly COLOR_FOOD: string = '#ef4444';
  static readonly COLOR_TEXT: string = '#ffffff';

  // 游戏速度 (毫秒/帧)
  static readonly GAME_SPEED: number = 150;

  // 方向
  static readonly DIRECTION_UP: number = 0;
  static readonly DIRECTION_RIGHT: number = 1;
  static readonly DIRECTION_DOWN: number = 2;
  static readonly DIRECTION_LEFT: number = 3;
}
