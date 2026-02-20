/**
 * 数独游戏常量
 */
export class SudokuConstants {
  // 画布尺寸
  static readonly CANVAS_WIDTH: number = 360;
  static readonly CANVAS_HEIGHT: number = 640;

  // 数独网格
  static readonly GRID_SIZE: number = 9;
  static readonly CELL_SIZE: number = 38;
  static readonly GRID_PADDING: number = 10;
  static readonly GRID_START_X: number = (360 - 9 * 38) / 2;
  static readonly GRID_START_Y: number = 100;

  // 数字选择面板
  static readonly NUMBER_PANEL_Y: number = 480;
  static readonly NUMBER_SIZE: number = 36;

  // 难度级别
  static readonly DIFFICULTY_EASY: number = 40;    // 简单：去掉40个数字
  static readonly DIFFICULTY_MEDIUM: number = 50;  // 中等：去掉50个数字
  static readonly DIFFICULTY_HARD: number = 60;    // 困难：去掉60个数字

  // 颜色
  static readonly COLOR_BACKGROUND: string = '#F5F5F5';
  static readonly COLOR_GRID: string = '#333333';
  static readonly COLOR_BOX: string = '#666666';
  static readonly COLOR_CELL_BG: string = '#FFFFFF';
  static readonly COLOR_CELL_SELECTED: string = '#BBDEFB';
  static readonly COLOR_CELL_SAME_NUM: string = '#E3F2FD';
  static readonly COLOR_CELL_SAME_ROW_COL: string = '#F0F0F0';
  static readonly COLOR_CELL_ERROR: string = '#FFCDD2';
  static readonly COLOR_FIXED: string = '#000000';
  static readonly COLOR_USER: string = '#1976D2';
  static readonly COLOR_NUMBER_BTN: string = '#2196F3';
  static readonly COLOR_NUMBER_BTN_SELECTED: string = '#1976D2';
}

/**
 * 游戏状态
 */
export enum SudokuState {
  IDLE = 'IDLE',
  PLAYING = 'PLAYING',
  COMPLETED = 'COMPLETED'
}

/**
 * 难度级别
 */
export enum Difficulty {
  EASY = 'EASY',
  MEDIUM = 'MEDIUM',
  HARD = 'HARD'
}
