import { GameConstants } from './GameConstants';

/**
 * 玩家位置接口
 */
export interface PlayerPosition {
  worldX: number;
  worldY: number;
  worldZ: number;
}

/**
 * 玩家实体类 - 跳一跳中的棋子（支持2.5D世界坐标）
 */
export class Player {
  worldX: number;        // 世界坐标X
  worldY: number;        // 世界坐标Y
  worldZ: number;        // 世界坐标Z（跳跃高度）

  velocityX: number;     // X方向速度（世界坐标）
  velocityY: number;     // Y方向速度（世界坐标）
  velocityZ: number;     // Z方向速度（跳跃）

  width: number;         // 玩家宽度
  height: number;        // 玩家当前高度（可压缩）
  baseHeight: number;    // 玩家基础高度

  isOnGround: boolean;   // 是否在地面上
  compressRatio: number; // 压缩比例 0-1

  constructor() {
    this.width = GameConstants.PLAYER_SIZE;
    this.baseHeight = GameConstants.PLAYER_SIZE * 1.2;
    this.height = this.baseHeight;
    this.worldX = 0;
    this.worldY = 0;
    this.worldZ = 0;
    this.velocityX = 0;
    this.velocityY = 0;
    this.velocityZ = 0;
    this.isOnGround = true;
    this.compressRatio = 0;
  }

  reset(startWorldX: number, startWorldY: number): void {
    this.worldX = startWorldX;
    this.worldY = startWorldY;
    this.worldZ = 0;
    this.height = this.baseHeight;
    this.velocityX = 0;
    this.velocityY = 0;
    this.velocityZ = 0;
    this.isOnGround = true;
    this.compressRatio = 0;
  }

  /**
   * 蓄力压缩
   * @param chargeTime 蓄力时间(ms)
   */
  compress(chargeTime: number): void {
    const maxCharge = GameConstants.MAX_CHARGE_TIME;
    this.compressRatio = Math.min(chargeTime / maxCharge, 1);
    this.height = this.baseHeight * (1 - GameConstants.PLAYER_MAX_COMPRESS * this.compressRatio);
  }

  /**
   * 开始跳跃（沿45度斜向）
   * @param distance 跳跃距离（世界坐标距离）
   */
  jump(distance: number): void {
    // 计算XY方向的速度分量（45度角）
    const speed = distance * GameConstants.JUMP_POWER_FACTOR;
    // 归一化45度方向向量 (1/√2, 1/√2) ≈ (0.707, 0.707)
    this.velocityX = speed * 0.707;
    this.velocityY = speed * 0.707;

    // Z方向跳跃速度
    this.velocityZ = GameConstants.JUMP_INITIAL_VELOCITY_Y;
    this.isOnGround = false;
    this.height = this.baseHeight;
    this.compressRatio = 0;
  }

  /**
   * 更新玩家状态
   * @param deltaTime 时间增量(秒)
   */
  update(deltaTime: number): void {
    if (!this.isOnGround) {
      // 应用重力到Z轴
      this.velocityZ += GameConstants.GRAVITY * deltaTime;

      // 更新位置
      this.worldX += this.velocityX * deltaTime;
      this.worldY += this.velocityY * deltaTime;
      this.worldZ += this.velocityZ * deltaTime;

      // 注意：不限制 worldZ，让它在掉落时继续增加
      // 游戏结束检测在 GameEngine 中处理
    }
  }

  /**
   * 落地
   */
  land(): void {
    this.worldZ = 0;
    this.velocityX = 0;
    this.velocityY = 0;
    this.velocityZ = 0;
    this.isOnGround = true;
  }

  /**
   * 获取底部中心点（世界坐标）
   */
  getBottomCenter(): PlayerPosition {
    const pos: PlayerPosition = {
      worldX: this.worldX,
      worldY: this.worldY,
      worldZ: this.worldZ
    };
    return pos;
  }

  /**
   * 检查是否正在下落
   */
  isFalling(): boolean {
    return this.velocityZ > 0;
  }
}
