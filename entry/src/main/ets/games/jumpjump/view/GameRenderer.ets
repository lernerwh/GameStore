import { Player } from '../model/Player';
import { Platform } from '../model/Platform';
import { GameState } from '../model/GameState';
import { GameConstants } from '../model/GameConstants';

/**
 * 屏幕坐标接口
 */
interface ScreenPosition {
  x: number;
  y: number;
}

/**
 * 2.5D等距视角渲染器
 */
export class GameRenderer {
  private canvasWidth: number = GameConstants.CANVAS_WIDTH;
  private canvasHeight: number = GameConstants.CANVAS_HEIGHT;

  // 相机偏移（世界坐标）
  private cameraWorldX: number = 0;
  private cameraWorldY: number = 0;

  render(
    canvas: CanvasRenderingContext2D,
    player: Player,
    platforms: Platform[],
    score: number,
    gameState: GameState,
    cameraWorldX: number,
    cameraWorldY: number,
    chargeProgress: number
  ): void {
    this.cameraWorldX = cameraWorldX;
    this.cameraWorldY = cameraWorldY;

    this.clearCanvas(canvas);
    this.drawBackground(canvas);

    // 按深度排序平台（Y-sorting：世界坐标Y+X）
    const sortedPlatforms = [...platforms].sort((a, b) => {
      const depthA = a.worldX + a.worldY;
      const depthB = b.worldX + b.worldY;
      return depthA - depthB;
    });

    // 先渲染所有平台
    for (const platform of sortedPlatforms) {
      this.drawPlatform(canvas, platform);
    }

    // 最后渲染玩家（确保玩家始终在最上层，不会被平台盖住）
    this.drawPlayer(canvas, player);

    // 绘制蓄力条
    if (gameState === GameState.CHARGING) {
      this.drawChargeBar(canvas, chargeProgress);
    }

    // 绘制分数
    this.drawScore(canvas, score);

    // 绘制提示
    if (gameState === GameState.IDLE) {
      this.drawStartPrompt(canvas);
    } else if (gameState === GameState.GAME_OVER) {
      this.drawGameOver(canvas, score);
    }
  }

  /**
   * 世界坐标转屏幕坐标（等距投影）
   * 平台沿45度对角线排列，从屏幕左下到右上
   */
  private worldToScreen(worldX: number, worldY: number, worldZ: number = 0): ScreenPosition {
    // 相机偏移 - 使用平均位置作为相机中心
    const cameraProgress = (this.cameraWorldX + this.cameraWorldY) / 2;
    const progress = (worldX + worldY) / 2 - cameraProgress;

    // 等距投影转换
    // progress增加时：screenX增加（向右），screenY减少（向上）
    // worldZ在当前物理系统中：负值=跳起（屏幕向上），正值=下落
    const screenX = progress * GameConstants.ISO_SCALE_X * 2 + this.canvasWidth / 2;
    const screenY = this.canvasHeight * 0.6 - progress * GameConstants.ISO_SCALE_Y * 2 + worldZ * GameConstants.HEIGHT_SCALE;

    const pos: ScreenPosition = { x: screenX, y: screenY };
    return pos;
  }

  private clearCanvas(canvas: CanvasRenderingContext2D): void {
    canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private drawBackground(canvas: CanvasRenderingContext2D): void {
    // 渐变背景
    const gradient = canvas.createLinearGradient(0, 0, 0, this.canvasHeight);
    gradient.addColorStop(0, GameConstants.COLOR_BACKGROUND_TOP);
    gradient.addColorStop(1, GameConstants.COLOR_BACKGROUND_BOTTOM);
    canvas.fillStyle = gradient;
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  /**
   * 绘制2.5D立体平台（等距视角方块）
   */
  private drawPlatform(canvas: CanvasRenderingContext2D, platform: Platform): void {
    // 获取平台中心的屏幕坐标
    const center = this.worldToScreen(platform.worldX, platform.worldY, platform.worldZ);

    const size = platform.size;
    const halfW = size * 0.6;  // 等距视角的宽度
    const halfH = size * 0.35; // 等距视角的高度
    const depth = GameConstants.PLATFORM_DEPTH;

    // 顶面四个顶点（平行四边形）
    // 上、右、下、左
    const top: ScreenPosition = { x: center.x, y: center.y - halfH };
    const right: ScreenPosition = { x: center.x + halfW, y: center.y };
    const bottom: ScreenPosition = { x: center.x, y: center.y + halfH };
    const left: ScreenPosition = { x: center.x - halfW, y: center.y };

    // 底部顶点（用于画侧面）
    const rightBottom: ScreenPosition = { x: right.x, y: right.y + depth };
    const bottomBottom: ScreenPosition = { x: bottom.x, y: bottom.y + depth };
    const leftBottom: ScreenPosition = { x: left.x, y: left.y + depth };

    // 绘制右侧面（较暗色调）
    canvas.fillStyle = platform.getDarkColor();
    canvas.beginPath();
    canvas.moveTo(right.x, right.y);
    canvas.lineTo(bottom.x, bottom.y);
    canvas.lineTo(bottomBottom.x, bottomBottom.y);
    canvas.lineTo(rightBottom.x, rightBottom.y);
    canvas.closePath();
    canvas.fill();

    // 绘制左侧面（中等色调）
    canvas.fillStyle = platform.getMediumColor();
    canvas.beginPath();
    canvas.moveTo(bottom.x, bottom.y);
    canvas.lineTo(left.x, left.y);
    canvas.lineTo(leftBottom.x, leftBottom.y);
    canvas.lineTo(bottomBottom.x, bottomBottom.y);
    canvas.closePath();
    canvas.fill();

    // 绘制顶面（平行四边形，亮色）
    canvas.fillStyle = platform.getColor();
    canvas.beginPath();
    canvas.moveTo(top.x, top.y);
    canvas.lineTo(right.x, right.y);
    canvas.lineTo(bottom.x, bottom.y);
    canvas.lineTo(left.x, left.y);
    canvas.closePath();
    canvas.fill();

    // 顶面高光（上半部分）
    canvas.fillStyle = 'rgba(255, 255, 255, 0.3)';
    canvas.beginPath();
    canvas.moveTo(top.x, top.y);
    canvas.lineTo(right.x, right.y);
    canvas.lineTo(center.x, center.y);
    canvas.lineTo(left.x, left.y);
    canvas.closePath();
    canvas.fill();
  }

  /**
   * 绘制2.5D立体玩家
   */
  private drawPlayer(canvas: CanvasRenderingContext2D, player: Player): void {
    // 玩家底部位置（世界坐标）
    const bottomPos = this.worldToScreen(player.worldX, player.worldY, player.worldZ);

    // 玩家高度对应的屏幕偏移
    const heightOffset = player.height * GameConstants.HEIGHT_SCALE * 0.8;

    // 绘制阴影（椭圆形，在地面上）
    canvas.fillStyle = GameConstants.COLOR_PLAYER_SHADOW;
    canvas.beginPath();
    canvas.ellipse(bottomPos.x, bottomPos.y + 3, player.width / 2 * 0.7, player.width / 4 * 0.7, 0, 0, Math.PI * 2);
    canvas.fill();

    // 玩家身体顶部位置
    const topY = bottomPos.y - heightOffset;

    // 绘制圆柱体身体（用渐变模拟光照）
    const bodyGradient = canvas.createLinearGradient(
      bottomPos.x - player.width / 2, bottomPos.y,
      bottomPos.x + player.width / 2, bottomPos.y
    );
    bodyGradient.addColorStop(0, '#1A1A1A');
    bodyGradient.addColorStop(0.3, GameConstants.COLOR_PLAYER);
    bodyGradient.addColorStop(0.5, GameConstants.COLOR_PLAYER_TOP);
    bodyGradient.addColorStop(0.7, GameConstants.COLOR_PLAYER);
    bodyGradient.addColorStop(1, '#1A1A1A');

    // 底部椭圆
    canvas.fillStyle = GameConstants.COLOR_PLAYER;
    canvas.beginPath();
    canvas.ellipse(bottomPos.x, bottomPos.y, player.width / 2, player.width / 4, 0, 0, Math.PI * 2);
    canvas.fill();

    // 身体侧面
    canvas.fillStyle = bodyGradient;
    canvas.beginPath();
    canvas.moveTo(bottomPos.x - player.width / 2, bottomPos.y);
    canvas.lineTo(bottomPos.x - player.width / 2, topY + player.width / 4);
    canvas.ellipse(bottomPos.x, topY + player.width / 4, player.width / 2, player.width / 4, 0, Math.PI, 0, true);
    canvas.lineTo(bottomPos.x + player.width / 2, bottomPos.y);
    canvas.ellipse(bottomPos.x, bottomPos.y, player.width / 2, player.width / 4, 0, 0, Math.PI, true);
    canvas.closePath();
    canvas.fill();

    // 顶部椭圆
    canvas.fillStyle = GameConstants.COLOR_PLAYER_TOP;
    canvas.beginPath();
    canvas.ellipse(bottomPos.x, topY + player.width / 4, player.width / 2, player.width / 4, 0, 0, Math.PI * 2);
    canvas.fill();

    // 顶部高光
    canvas.fillStyle = GameConstants.COLOR_PLAYER_HIGHLIGHT;
    canvas.beginPath();
    canvas.ellipse(
      bottomPos.x - player.width / 6,
      topY + player.width / 4 - 3,
      player.width / 4,
      player.width / 6,
      -0.3, 0, Math.PI * 2
    );
    canvas.fill();

    // 眼睛（两个小圆点）- 在身体上部
    const eyeY = topY + player.width / 3;
    const eyeSpacing = 5;

    // 眼白
    canvas.fillStyle = '#FFFFFF';
    canvas.beginPath();
    canvas.arc(bottomPos.x - eyeSpacing, eyeY, 3, 0, Math.PI * 2);
    canvas.arc(bottomPos.x + eyeSpacing, eyeY, 3, 0, Math.PI * 2);
    canvas.fill();

    // 瞳孔
    canvas.fillStyle = '#000000';
    canvas.beginPath();
    canvas.arc(bottomPos.x - eyeSpacing, eyeY, 1.5, 0, Math.PI * 2);
    canvas.arc(bottomPos.x + eyeSpacing, eyeY, 1.5, 0, Math.PI * 2);
    canvas.fill();
  }

  private drawChargeBar(canvas: CanvasRenderingContext2D, progress: number): void {
    const barWidth = 100;
    const barHeight = 10;
    const x = (this.canvasWidth - barWidth) / 2;
    const y = this.canvasHeight - 80;

    // 背景
    canvas.fillStyle = GameConstants.COLOR_CHARGE_BAR_BG;
    canvas.fillRect(x, y, barWidth, barHeight);

    // 填充
    canvas.fillStyle = GameConstants.COLOR_CHARGE_BAR_FILL;
    canvas.fillRect(x, y, barWidth * progress, barHeight);

    // 边框
    canvas.strokeStyle = '#FFFFFF';
    canvas.lineWidth = 2;
    canvas.strokeRect(x, y, barWidth, barHeight);
  }

  private drawScore(canvas: CanvasRenderingContext2D, score: number): void {
    canvas.fillStyle = GameConstants.COLOR_SCORE_SHADOW;
    canvas.font = 'bold 56px sans-serif';
    canvas.textAlign = 'center';
    canvas.fillText(score.toString(), this.canvasWidth / 2 + 2, 62);

    canvas.fillStyle = '#FFFFFF';
    canvas.fillText(score.toString(), this.canvasWidth / 2, 60);
  }

  private drawStartPrompt(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.4)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 56px sans-serif';
    canvas.textAlign = 'center';
    canvas.fillText('跳一跳', this.canvasWidth / 2, this.canvasHeight / 2 - 60);

    canvas.font = '36px sans-serif';
    canvas.fillText('按住蓄力，松开跳跃', this.canvasWidth / 2, this.canvasHeight / 2 + 10);
    canvas.fillText('点击屏幕开始', this.canvasWidth / 2, this.canvasHeight / 2 + 60);
  }

  private drawGameOver(canvas: CanvasRenderingContext2D, score: number): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.6)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 56px sans-serif';
    canvas.textAlign = 'center';
    canvas.fillText('游戏结束', this.canvasWidth / 2, this.canvasHeight / 2 - 70);

    canvas.font = '42px sans-serif';
    canvas.fillText('得分: ' + score, this.canvasWidth / 2, this.canvasHeight / 2 + 10);

    canvas.font = '36px sans-serif';
    canvas.fillText('点击重新开始', this.canvasWidth / 2, this.canvasHeight / 2 + 80);
  }
}
