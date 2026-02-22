import { Player } from '../model/Player';
import { Platform } from '../model/Platform';
import { GameState } from '../model/GameState';
import { GameConstants } from '../model/GameConstants';
import { MathUtils } from '../model/MathUtils';

/**
 * 游戏引擎 - 跳一跳核心逻辑（2.5D版本）
 */
export class GameEngine {
  private player: Player;
  private platforms: Platform[] = [];
  private currentPlatformIndex: number = 0;
  private gameState: GameState;
  private score: number;
  private chargeStartTime: number = 0;

  // 相机位置（世界坐标）
  private cameraWorldX: number = 0;
  private cameraWorldY: number = 0;
  private targetCameraWorldX: number = 0;
  private targetCameraWorldY: number = 0;

  constructor() {
    this.player = new Player();
    this.gameState = GameState.IDLE;
    this.score = 0;
    this.initPlatforms();
  }

  private initPlatforms(): void {
    this.platforms = [];
    // 创建初始方块（世界坐标 0, 0）
    const firstPlatform = new Platform(0, 0, 80, 0); // 固定第一个平台颜色
    this.platforms.push(firstPlatform);

    // 预生成几个方块（沿45度斜向）
    for (let i = 0; i < 5; i++) {
      const lastPlatform = this.platforms[this.platforms.length - 1];
      this.platforms.push(Platform.generateNext(lastPlatform.worldX, lastPlatform.worldY));
    }
  }

  getPlayer(): Player {
    return this.player;
  }

  getPlatforms(): Platform[] {
    return this.platforms;
  }

  getCurrentPlatform(): Platform | null {
    if (this.currentPlatformIndex < this.platforms.length) {
      return this.platforms[this.currentPlatformIndex];
    }
    return null;
  }

  getNextPlatform(): Platform | null {
    if (this.currentPlatformIndex + 1 < this.platforms.length) {
      return this.platforms[this.currentPlatformIndex + 1];
    }
    return null;
  }

  getGameState(): GameState {
    return this.gameState;
  }

  getScore(): number {
    return this.score;
  }

  getCameraWorldX(): number {
    return this.cameraWorldX;
  }

  getCameraWorldY(): number {
    return this.cameraWorldY;
  }

  getChargeProgress(): number {
    if (this.gameState !== GameState.CHARGING) {
      return 0;
    }
    const chargeTime = Date.now() - this.chargeStartTime;
    return Math.min(chargeTime / GameConstants.MAX_CHARGE_TIME, 1);
  }

  /**
   * 开始游戏
   */
  startGame(): void {
    this.gameState = GameState.PLAYING;
    this.score = 0;
    this.currentPlatformIndex = 0;
    this.cameraWorldX = 0;
    this.cameraWorldY = 0;
    this.targetCameraWorldX = 0;
    this.targetCameraWorldY = 0;
    this.initPlatforms();

    const firstPlatform = this.platforms[0];
    this.player.reset(firstPlatform.worldX, firstPlatform.worldY);
  }

  /**
   * 开始蓄力
   */
  startCharge(): void {
    if (this.gameState !== GameState.PLAYING) {
      return;
    }
    this.gameState = GameState.CHARGING;
    this.chargeStartTime = Date.now();
  }

  /**
   * 释放跳跃
   */
  releaseJump(): void {
    if (this.gameState !== GameState.CHARGING) {
      return;
    }

    const chargeTime = Date.now() - this.chargeStartTime;
    const jumpDistance = chargeTime;

    this.player.jump(jumpDistance);
    this.gameState = GameState.JUMPING;
  }

  /**
   * 更新游戏状态
   */
  update(deltaTime: number): void {
    // 更新相机位置（平滑跟随）
    this.updateCamera(deltaTime);

    if (this.gameState === GameState.CHARGING) {
      // 更新蓄力压缩效果
      const chargeTime = Date.now() - this.chargeStartTime;
      this.player.compress(chargeTime);
    } else if (this.gameState === GameState.JUMPING) {
      this.player.update(deltaTime);
      this.checkLanding();
    }
  }

  private updateCamera(deltaTime: number): void {
    // 平滑相机移动（世界坐标）
    const diffX = this.targetCameraWorldX - this.cameraWorldX;
    const diffY = this.targetCameraWorldY - this.cameraWorldY;
    const smoothing = Math.min(deltaTime * 5, 1);
    this.cameraWorldX += diffX * smoothing;
    this.cameraWorldY += diffY * smoothing;
  }

  private checkLanding(): void {
    const bottomCenter = this.player.getBottomCenter();

    // 检查是否开始下落
    if (!this.player.isFalling()) {
      return; // 还在上升
    }

    // 当玩家下落到平台高度时，检查是否在平台上
    if (this.player.worldZ >= 0) {
      const nextPlatform = this.getNextPlatform();
      const currentPlatform = this.getCurrentPlatform();

      // 检查是否落在下一个方块上
      if (nextPlatform && nextPlatform.containsPoint(bottomCenter.worldX, bottomCenter.worldY)) {
        this.handleSuccessfulLanding(nextPlatform);
      }
      // 检查是否落在当前方块上（跳跃距离不够）
      else if (currentPlatform && currentPlatform.containsPoint(bottomCenter.worldX, bottomCenter.worldY)) {
        this.handleSuccessfulLanding(currentPlatform);
      }
      // 棋子中心点不在任何台阶上，立即触发掉落
      else {
        this.gameOver();
      }
    }
  }

  private handleSuccessfulLanding(platform: Platform): void {
    this.player.land();

    // 判断是否跳到了新方块
    const platformIndex = this.platforms.indexOf(platform);
    if (platformIndex > this.currentPlatformIndex) {
      this.currentPlatformIndex = platformIndex;
      this.score += GameConstants.SCORE_PER_LAND;

      // 检查是否完美落地
      const distance = platform.distanceToCenter(this.player.worldX, this.player.worldY);
      if (distance < GameConstants.PERFECT_THRESHOLD) {
        this.score += GameConstants.SCORE_PERFECT_BONUS;
      }

      // 更新相机目标位置（跟随玩家到新平台）
      this.targetCameraWorldX = platform.worldX;
      this.targetCameraWorldY = platform.worldY;

      // 生成新方块
      this.generateNewPlatform();
    }

    this.gameState = GameState.PLAYING;
  }

  private generateNewPlatform(): void {
    const lastPlatform = this.platforms[this.platforms.length - 1];
    this.platforms.push(Platform.generateNext(lastPlatform.worldX, lastPlatform.worldY));

    // 移除已经过的旧方块（保留当前方块之前的2个）
    while (this.currentPlatformIndex > 2) {
      this.platforms.shift();
      this.currentPlatformIndex--;
    }
  }

  private gameOver(): void {
    this.gameState = GameState.GAME_OVER;
  }

  reset(): void {
    this.player.reset(0, 0);
    this.score = 0;
    this.gameState = GameState.IDLE;
    this.currentPlatformIndex = 0;
    this.cameraWorldX = 0;
    this.cameraWorldY = 0;
    this.targetCameraWorldX = 0;
    this.targetCameraWorldY = 0;
    this.initPlatforms();
  }
}
