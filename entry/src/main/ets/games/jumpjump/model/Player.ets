import { GameConstants } from './GameConstants';
import { Rect } from './MathUtils';

/**
 * 点坐标接口
 */
export interface Point {
  x: number;
  y: number;
}

/**
 * 玩家实体类 - 跳一跳中的棋子
 */
export class Player {
  x: number;           // 玩家中心X坐标
  y: number;           // 玩家底部Y坐标
  width: number;       // 玩家宽度
  height: number;      // 玩家当前高度（可压缩）
  baseHeight: number;  // 玩家基础高度
  velocityX: number;   // X方向速度
  velocityY: number;   // Y方向速度
  isOnGround: boolean; // 是否在地面上
  compressRatio: number; // 压缩比例 0-1

  constructor() {
    this.width = GameConstants.PLAYER_SIZE;
    this.baseHeight = GameConstants.PLAYER_SIZE * 1.2;
    this.height = this.baseHeight;
    this.x = GameConstants.CANVAS_WIDTH / 2;
    this.y = GameConstants.PLATFORM_Y;
    this.velocityX = 0;
    this.velocityY = 0;
    this.isOnGround = true;
    this.compressRatio = 0;
  }

  reset(startX: number, startY: number): void {
    this.x = startX;
    this.y = startY;
    this.height = this.baseHeight;
    this.velocityX = 0;
    this.velocityY = 0;
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
   * 开始跳跃
   * @param distance 跳跃距离
   * @param direction 跳跃方向
   */
  jump(distance: number, direction: number): void {
    this.velocityX = direction * distance * GameConstants.JUMP_POWER_FACTOR;
    this.velocityY = GameConstants.JUMP_INITIAL_VELOCITY_Y;
    this.isOnGround = false;
    this.height = this.baseHeight; // 恢复高度
    this.compressRatio = 0;
  }

  /**
   * 更新玩家状态
   * @param deltaTime 时间增量(秒)
   */
  update(deltaTime: number): void {
    if (!this.isOnGround) {
      // 应用重力
      this.velocityY += GameConstants.GRAVITY * deltaTime;

      // 更新位置
      this.x += this.velocityX * deltaTime;
      this.y += this.velocityY * deltaTime;
    }
  }

  /**
   * 落地
   * @param groundY 地面Y坐标
   */
  land(groundY: number): void {
    this.y = groundY;
    this.velocityX = 0;
    this.velocityY = 0;
    this.isOnGround = true;
  }

  /**
   * 获取碰撞矩形（用于检测是否落在方块上）
   */
  getCollisionRect(): Rect {
    return {
      x: this.x - this.width / 2,
      y: this.y - this.height,
      width: this.width,
      height: this.height
    };
  }

  /**
   * 获取底部中心点（用于精确落地检测）
   */
  getBottomCenter(): Point {
    const point: Point = {
      x: this.x,
      y: this.y
    };
    return point;
  }
}
