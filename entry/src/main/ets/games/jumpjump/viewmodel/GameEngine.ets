import { Player, Point } from '../model/Player';
import { Platform } from '../model/Platform';
import { GameState, JumpDirection } from '../model/GameState';
import { GameConstants } from '../model/GameConstants';
import { MathUtils } from '../model/MathUtils';

/**
 * 游戏引擎 - 跳一跳核心逻辑
 */
export class GameEngine {
  private player: Player;
  private platforms: Platform[] = [];
  private currentPlatformIndex: number = 0;
  private gameState: GameState;
  private score: number;
  private chargeStartTime: number = 0;
  private jumpDirection: JumpDirection = JumpDirection.RIGHT;
  private cameraOffsetX: number = 0;
  private targetCameraOffsetX: number = 0;

  constructor() {
    this.player = new Player();
    this.gameState = GameState.IDLE;
    this.score = 0;
    this.initPlatforms();
  }

  private initPlatforms(): void {
    this.platforms = [];
    // 创建初始方块
    const firstPlatform = new Platform(GameConstants.CANVAS_WIDTH / 2, GameConstants.PLATFORM_Y, 80);
    this.platforms.push(firstPlatform);

    // 预生成几个方块
    for (let i = 0; i < 5; i++) {
      const lastPlatform = this.platforms[this.platforms.length - 1];
      this.platforms.push(Platform.generateNext(lastPlatform.x));
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

  getCameraOffsetX(): number {
    return this.cameraOffsetX;
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
    this.cameraOffsetX = 0;
    this.targetCameraOffsetX = 0;
    this.initPlatforms();

    const firstPlatform = this.platforms[0];
    this.player.reset(firstPlatform.x, GameConstants.PLATFORM_Y);
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
    const jumpDistance = chargeTime; // 蓄力时间直接作为跳跃距离参考

    this.player.jump(jumpDistance, 1); // 向右跳
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
    // 平滑相机移动
    const diff = this.targetCameraOffsetX - this.cameraOffsetX;
    this.cameraOffsetX += diff * Math.min(deltaTime * 5, 1);
  }

  private checkLanding(): void {
    const bottomCenter = this.player.getBottomCenter();

    // 检查是否开始下落
    if (this.player.velocityY < 0) {
      return; // 还在上升
    }

    // 检查是否落在下一个方块上
    const nextPlatform = this.getNextPlatform();
    if (nextPlatform && nextPlatform.containsPoint(bottomCenter.x, bottomCenter.y)) {
      // 成功落地
      this.handleSuccessfulLanding(nextPlatform);
    }
    // 检查是否落在当前方块上（跳跃距离不够）
    else if (this.getCurrentPlatform()?.containsPoint(bottomCenter.x, bottomCenter.y)) {
      this.handleSuccessfulLanding(this.getCurrentPlatform()!);
    }
    // 检查是否掉落
    else if (bottomCenter.y > GameConstants.PLATFORM_Y + 50) {
      this.gameOver();
    }
  }

  private handleSuccessfulLanding(platform: Platform): void {
    this.player.land(GameConstants.PLATFORM_Y);

    // 判断是否跳到了新方块
    const platformIndex = this.platforms.indexOf(platform);
    if (platformIndex > this.currentPlatformIndex) {
      this.currentPlatformIndex = platformIndex;
      this.score += GameConstants.SCORE_PER_LAND;

      // 检查是否完美落地
      const distance = platform.distanceToCenter(this.player.x);
      if (distance < GameConstants.PERFECT_THRESHOLD) {
        this.score += GameConstants.SCORE_PERFECT_BONUS;
      }

      // 更新相机目标位置
      this.targetCameraOffsetX = platform.x - GameConstants.CANVAS_WIDTH / 2;

      // 生成新方块
      this.generateNewPlatform();
    }

    this.gameState = GameState.PLAYING;
  }

  private generateNewPlatform(): void {
    const lastPlatform = this.platforms[this.platforms.length - 1];
    this.platforms.push(Platform.generateNext(lastPlatform.x));

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
    this.player.reset(GameConstants.CANVAS_WIDTH / 2, GameConstants.PLATFORM_Y);
    this.score = 0;
    this.gameState = GameState.IDLE;
    this.currentPlatformIndex = 0;
    this.cameraOffsetX = 0;
    this.targetCameraOffsetX = 0;
    this.initPlatforms();
  }
}
