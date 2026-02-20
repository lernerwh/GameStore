import { Player } from '../model/Player';
import { Platform } from '../model/Platform';
import { GameState } from '../model/GameState';
import { GameConstants } from '../model/GameConstants';

export class GameRenderer {
  private canvasWidth: number = GameConstants.CANVAS_WIDTH;
  private canvasHeight: number = GameConstants.CANVAS_HEIGHT;

  render(
    canvas: CanvasRenderingContext2D,
    player: Player,
    platforms: Platform[],
    score: number,
    gameState: GameState,
    cameraOffsetX: number,
    chargeProgress: number
  ): void {
    this.clearCanvas(canvas);
    this.drawBackground(canvas);

    // 绘制所有方块（应用相机偏移）
    for (const platform of platforms) {
      this.drawPlatform(canvas, platform, cameraOffsetX);
    }

    // 绘制玩家（应用相机偏移）
    this.drawPlayer(canvas, player, cameraOffsetX);

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

  private clearCanvas(canvas: CanvasRenderingContext2D): void {
    canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private drawBackground(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = GameConstants.COLOR_BACKGROUND;
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private drawPlatform(canvas: CanvasRenderingContext2D, platform: Platform, offsetX: number): void {
    const bounds = platform.getBounds();
    const x = bounds.x - offsetX;
    const y = bounds.y;
    const w = bounds.width;
    const h = bounds.height;

    // 绘制阴影
    canvas.fillStyle = GameConstants.COLOR_PLATFORM_SHADOW;
    canvas.fillRect(x + 3, y + 3, w, h);

    // 绘制侧面（深度感）
    canvas.fillStyle = GameConstants.COLOR_PLATFORM_SIDE;
    canvas.fillRect(x, y + h * 0.3, w, h * 0.7);

    // 绘制顶面
    canvas.fillStyle = GameConstants.COLOR_PLATFORM_TOP;
    canvas.fillRect(x, y, w, h * 0.4);

    // 绘制高光
    canvas.fillStyle = 'rgba(255, 255, 255, 0.2)';
    canvas.fillRect(x + 2, y + 2, w - 4, 4);
  }

  private drawPlayer(canvas: CanvasRenderingContext2D, player: Player, offsetX: number): void {
    const x = player.x - player.width / 2 - offsetX;
    const y = player.y - player.height;
    const w = player.width;
    const h = player.height;

    // 绘制阴影
    canvas.fillStyle = 'rgba(0, 0, 0, 0.3)';
    canvas.beginPath();
    canvas.ellipse(player.x - offsetX, player.y + 2, w / 2 * 0.8, 5, 0, 0, Math.PI * 2);
    canvas.fill();

    // 绘制身体（类似圆柱体）
    // 底部
    canvas.fillStyle = GameConstants.COLOR_PLAYER;
    canvas.beginPath();
    canvas.ellipse(x + w / 2, y + h, w / 2, w / 4, 0, 0, Math.PI * 2);
    canvas.fill();

    // 身体
    canvas.fillStyle = GameConstants.COLOR_PLAYER;
    canvas.fillRect(x, y + w / 4, w, h - w / 4);

    // 顶部
    canvas.fillStyle = GameConstants.COLOR_PLAYER_TOP;
    canvas.beginPath();
    canvas.ellipse(x + w / 2, y + w / 4, w / 2, w / 4, 0, 0, Math.PI * 2);
    canvas.fill();

    // 高光
    canvas.fillStyle = GameConstants.COLOR_PLAYER_HIGHLIGHT;
    canvas.beginPath();
    canvas.ellipse(x + w / 2 - 3, y + w / 4 - 2, w / 4, w / 6, -0.3, 0, Math.PI * 2);
    canvas.fill();

    // 眼睛（两个小圆点）
    canvas.fillStyle = '#FFFFFF';
    canvas.beginPath();
    canvas.arc(x + w / 2 - 5, y + h / 2, 3, 0, Math.PI * 2);
    canvas.arc(x + w / 2 + 5, y + h / 2, 3, 0, Math.PI * 2);
    canvas.fill();

    // 瞳孔
    canvas.fillStyle = '#000000';
    canvas.beginPath();
    canvas.arc(x + w / 2 - 5, y + h / 2, 1.5, 0, Math.PI * 2);
    canvas.arc(x + w / 2 + 5, y + h / 2, 1.5, 0, Math.PI * 2);
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
    canvas.font = 'bold 42px sans-serif';
    canvas.textAlign = 'center';
    canvas.fillText(score.toString(), this.canvasWidth / 2 + 2, 52);

    canvas.fillStyle = '#FFFFFF';
    canvas.fillText(score.toString(), this.canvasWidth / 2, 50);
  }

  private drawStartPrompt(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.4)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 32px sans-serif';
    canvas.textAlign = 'center';
    canvas.fillText('跳一跳', this.canvasWidth / 2, this.canvasHeight / 2 - 40);

    canvas.font = '20px sans-serif';
    canvas.fillText('按住蓄力，松开跳跃', this.canvasWidth / 2, this.canvasHeight / 2 + 10);
    canvas.fillText('点击屏幕开始', this.canvasWidth / 2, this.canvasHeight / 2 + 50);
  }

  private drawGameOver(canvas: CanvasRenderingContext2D, score: number): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.6)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 36px sans-serif';
    canvas.textAlign = 'center';
    canvas.fillText('游戏结束', this.canvasWidth / 2, this.canvasHeight / 2 - 50);

    canvas.font = '28px sans-serif';
    canvas.fillText('得分: ' + score, this.canvasWidth / 2, this.canvasHeight / 2);

    canvas.font = '20px sans-serif';
    canvas.fillText('点击重新开始', this.canvasWidth / 2, this.canvasHeight / 2 + 50);
  }
}
