/**
 * 游戏状态枚举
 */
export enum GameState {
  IDLE = 'IDLE',           // 等待开始
  PLAYING = 'PLAYING',     // 游戏中，等待操作
  CHARGING = 'CHARGING',   // 蓄力中
  JUMPING = 'JUMPING',     // 跳跃中
  GAME_OVER = 'GAME_OVER'  // 游戏结束
}

/**
 * 跳跃方向
 */
export enum JumpDirection {
  RIGHT = 'RIGHT',  // 向右跳（默认方向）
  LEFT = 'LEFT'     // 向左跳
}
