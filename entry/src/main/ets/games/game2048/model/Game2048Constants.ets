export enum MoveDirection {
  UP = 'up',
  DOWN = 'down',
  LEFT = 'left',
  RIGHT = 'right'
}

export enum Game2048State {
  READY = 'ready',
  PLAYING = 'playing',
  WON = 'won',
  OVER = 'over'
}

export const BOARD_SIZE = 4;
export const WIN_VALUE = 2048;
