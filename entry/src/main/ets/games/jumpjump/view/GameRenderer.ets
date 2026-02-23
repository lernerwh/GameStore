import { Player } from '../model/Player';
import { Platform } from '../model/Platform';
import { GameState } from '../model/GameState';
import { GameConstants } from '../model/GameConstants';

interface ScreenPosition {
  x: number;
  y: number;
}

export class GameRenderer {
  private canvasWidth: number = GameConstants.CANVAS_WIDTH;
  private canvasHeight: number = GameConstants.CANVAS_HEIGHT;
  private cameraWorldX: number = 0;
  private cameraWorldY: number = 0;
  private animTime: number = 0;

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
    this.animTime = Date.now();
    this.cameraWorldX = cameraWorldX;
    this.cameraWorldY = cameraWorldY;

    this.clearCanvas(canvas);
    this.drawBackground(canvas);

    const sortedPlatforms = [...platforms].sort((a, b) => {
      const depthA = a.worldX + a.worldY;
      const depthB = b.worldX + b.worldY;
      return depthA - depthB;
    });

    for (const platform of sortedPlatforms) {
      this.drawPlatformShadow(canvas, platform);
      this.drawPlatform(canvas, platform);
    }

    this.drawPlayer(canvas, player, chargeProgress, gameState);

    if (gameState === GameState.CHARGING) {
      this.drawChargeHint(canvas, chargeProgress);
    }

    this.drawScore(canvas, score);

    if (gameState === GameState.IDLE) {
      this.drawStartPrompt(canvas);
    } else if (gameState === GameState.GAME_OVER) {
      this.drawGameOver(canvas, score);
    }
  }

  private worldToScreen(worldX: number, worldY: number, worldZ: number = 0): ScreenPosition {
    const cameraProgress = (this.cameraWorldX + this.cameraWorldY) / 2;
    const progress = (worldX + worldY) / 2 - cameraProgress;
    const screenX = progress * GameConstants.ISO_SCALE_X * 2 + this.canvasWidth / 2;
    const screenY = this.canvasHeight * 0.62 - progress * GameConstants.ISO_SCALE_Y * 2 + worldZ * GameConstants.HEIGHT_SCALE;
    return { x: screenX, y: screenY };
  }

  private clearCanvas(canvas: CanvasRenderingContext2D): void {
    canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private drawBackground(canvas: CanvasRenderingContext2D): void {
    const gradient = canvas.createLinearGradient(0, 0, 0, this.canvasHeight);
    gradient.addColorStop(0, GameConstants.COLOR_BACKGROUND_TOP);
    gradient.addColorStop(1, GameConstants.COLOR_BACKGROUND_BOTTOM);
    canvas.fillStyle = gradient;
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 轻微氛围层，避免背景过于死板
    const t = this.animTime / 1000;
    for (let i = 0; i < 5; i++) {
      const x = (i * 87 + 35) % this.canvasWidth + Math.sin(t * 0.2 + i) * 10;
      const y = 120 + i * 120 + Math.cos(t * 0.18 + i * 0.7) * 7;
      const g = canvas.createRadialGradient(x, y, 10, x, y, 56);
      g.addColorStop(0, 'rgba(255,255,255,0.08)');
      g.addColorStop(1, 'rgba(255,255,255,0)');
      canvas.fillStyle = g;
      canvas.beginPath();
      canvas.arc(x, y, 56, 0, Math.PI * 2);
      canvas.fill();
    }
  }

  private drawPlatformShadow(canvas: CanvasRenderingContext2D, platform: Platform): void {
    const center = this.worldToScreen(platform.worldX, platform.worldY, platform.worldZ);
    const size = platform.size;
    const shadowW = size * 0.62;
    const shadowH = size * 0.2;

    canvas.fillStyle = 'rgba(0,0,0,0.18)';
    canvas.beginPath();
    canvas.ellipse(center.x - shadowW * 0.35, center.y + GameConstants.PLATFORM_DEPTH + 8, shadowW, shadowH, -0.18, 0, Math.PI * 2);
    canvas.fill();
  }

  private drawPlatform(canvas: CanvasRenderingContext2D, platform: Platform): void {
    const center = this.worldToScreen(platform.worldX, platform.worldY, platform.worldZ);
    const size = platform.size;
    const halfW = size * 0.6;
    const halfH = size * 0.34;
    const depth = GameConstants.PLATFORM_DEPTH;

    const top: ScreenPosition = { x: center.x, y: center.y - halfH };
    const right: ScreenPosition = { x: center.x + halfW, y: center.y };
    const bottom: ScreenPosition = { x: center.x, y: center.y + halfH };
    const left: ScreenPosition = { x: center.x - halfW, y: center.y };

    const rightBottom: ScreenPosition = { x: right.x, y: right.y + depth };
    const bottomBottom: ScreenPosition = { x: bottom.x, y: bottom.y + depth };
    const leftBottom: ScreenPosition = { x: left.x, y: left.y + depth };

    canvas.fillStyle = platform.getDarkColor();
    canvas.beginPath();
    canvas.moveTo(right.x, right.y);
    canvas.lineTo(bottom.x, bottom.y);
    canvas.lineTo(bottomBottom.x, bottomBottom.y);
    canvas.lineTo(rightBottom.x, rightBottom.y);
    canvas.closePath();
    canvas.fill();

    canvas.fillStyle = platform.getMediumColor();
    canvas.beginPath();
    canvas.moveTo(bottom.x, bottom.y);
    canvas.lineTo(left.x, left.y);
    canvas.lineTo(leftBottom.x, leftBottom.y);
    canvas.lineTo(bottomBottom.x, bottomBottom.y);
    canvas.closePath();
    canvas.fill();

    canvas.fillStyle = platform.getColor();
    canvas.beginPath();
    canvas.moveTo(top.x, top.y);
    canvas.lineTo(right.x, right.y);
    canvas.lineTo(bottom.x, bottom.y);
    canvas.lineTo(left.x, left.y);
    canvas.closePath();
    canvas.fill();

    canvas.strokeStyle = 'rgba(255,255,255,0.3)';
    canvas.lineWidth = 1;
    canvas.beginPath();
    canvas.moveTo(top.x, top.y);
    canvas.lineTo(right.x, right.y);
    canvas.lineTo(bottom.x, bottom.y);
    canvas.lineTo(left.x, left.y);
    canvas.closePath();
    canvas.stroke();

    // 顶面细节块（贴图感）
    canvas.fillStyle = 'rgba(255,255,255,0.16)';
    canvas.beginPath();
    canvas.moveTo(center.x, center.y - halfH * 0.45);
    canvas.lineTo(center.x + halfW * 0.35, center.y - halfH * 0.02);
    canvas.lineTo(center.x, center.y + halfH * 0.3);
    canvas.lineTo(center.x - halfW * 0.35, center.y - halfH * 0.02);
    canvas.closePath();
    canvas.fill();
  }

  private drawPlayer(canvas: CanvasRenderingContext2D, player: Player, chargeProgress: number, gameState: GameState): void {
    const bottomPos = this.worldToScreen(player.worldX, player.worldY, player.worldZ);
    const heightOffset = player.height * GameConstants.HEIGHT_SCALE * 0.8;
    const squeeze = gameState === GameState.CHARGING ? chargeProgress * 0.22 : 0;

    const bodyWidth = player.width * (1 + squeeze * 0.45);
    const bodyHeight = heightOffset * (1 - squeeze * 0.3);
    const topY = bottomPos.y - bodyHeight;

    const shadowScale = player.worldZ > 0 ? 0.48 : 0.78;
    canvas.fillStyle = GameConstants.COLOR_PLAYER_SHADOW;
    canvas.beginPath();
    canvas.ellipse(bottomPos.x - 10, bottomPos.y + 5, player.width * shadowScale, player.width * 0.35 * shadowScale, -0.2, 0, Math.PI * 2);
    canvas.fill();

    // 棋子主体（紫色）
    const bodyGradient = canvas.createLinearGradient(bottomPos.x - bodyWidth / 2, bottomPos.y, bottomPos.x + bodyWidth / 2, bottomPos.y);
    bodyGradient.addColorStop(0, '#1A1730');
    bodyGradient.addColorStop(0.4, GameConstants.COLOR_PLAYER);
    bodyGradient.addColorStop(0.75, GameConstants.COLOR_PLAYER_TOP);
    bodyGradient.addColorStop(1, '#16142A');

    canvas.fillStyle = bodyGradient;
    canvas.beginPath();
    canvas.moveTo(bottomPos.x - bodyWidth * 0.33, bottomPos.y);
    canvas.quadraticCurveTo(bottomPos.x - bodyWidth * 0.44, bottomPos.y - bodyHeight * 0.25, bottomPos.x - bodyWidth * 0.2, topY + bodyWidth * 0.22);
    canvas.quadraticCurveTo(bottomPos.x, topY - bodyHeight * 0.05, bottomPos.x + bodyWidth * 0.2, topY + bodyWidth * 0.22);
    canvas.quadraticCurveTo(bottomPos.x + bodyWidth * 0.44, bottomPos.y - bodyHeight * 0.25, bottomPos.x + bodyWidth * 0.33, bottomPos.y);
    canvas.closePath();
    canvas.fill();

    canvas.fillStyle = '#4E4B81';
    canvas.beginPath();
    canvas.ellipse(bottomPos.x, topY + bodyWidth * 0.2, bodyWidth * 0.2, bodyWidth * 0.13, 0, 0, Math.PI * 2);
    canvas.fill();

    // 棋子头
    canvas.fillStyle = '#2E2B52';
    canvas.beginPath();
    canvas.arc(bottomPos.x, topY - bodyWidth * 0.1, bodyWidth * 0.16, 0, Math.PI * 2);
    canvas.fill();

    canvas.fillStyle = 'rgba(255,255,255,0.28)';
    canvas.beginPath();
    canvas.arc(bottomPos.x - bodyWidth * 0.05, topY - bodyWidth * 0.14, bodyWidth * 0.05, 0, Math.PI * 2);
    canvas.fill();

    if (gameState === GameState.CHARGING) {
      this.drawChargeRipple(canvas, bottomPos.x, bottomPos.y + 1, chargeProgress);
    }
  }

  private drawChargeRipple(canvas: CanvasRenderingContext2D, x: number, y: number, progress: number): void {
    const radius = 20 + progress * 26;
    canvas.strokeStyle = `rgba(255,255,255,${0.28 + progress * 0.2})`;
    canvas.lineWidth = 2;
    canvas.beginPath();
    canvas.arc(x, y, radius, 0, Math.PI * 2);
    canvas.stroke();

    canvas.strokeStyle = 'rgba(255,255,255,0.18)';
    canvas.beginPath();
    canvas.arc(x, y, radius + 10, 0, Math.PI * 2);
    canvas.stroke();
  }

  private drawChargeHint(canvas: CanvasRenderingContext2D, progress: number): void {
    const barWidth = 138;
    const barHeight = 11;
    const x = (this.canvasWidth - barWidth) / 2;
    const y = this.canvasHeight - 58;

    canvas.fillStyle = GameConstants.COLOR_CHARGE_BAR_BG;
    canvas.beginPath();
    canvas.roundRect(x, y, barWidth, barHeight, 6);
    canvas.fill();

    const fillGradient = canvas.createLinearGradient(x, y, x + barWidth, y);
    fillGradient.addColorStop(0, '#77C891');
    fillGradient.addColorStop(1, '#CFEF9C');
    canvas.fillStyle = fillGradient;
    canvas.beginPath();
    canvas.roundRect(x, y, barWidth * progress, barHeight, 6);
    canvas.fill();
  }

  private drawScore(canvas: CanvasRenderingContext2D, score: number): void {
    canvas.fillStyle = 'rgba(32, 32, 36, 0.82)';
    canvas.font = 'bold 42px sans-serif';
    canvas.textAlign = 'left';
    canvas.fillText(score.toString(), 24, 88);
  }

  private drawStartPrompt(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.18)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = 'rgba(255,255,255,0.96)';
    canvas.font = 'bold 34px sans-serif';
    canvas.textAlign = 'center';
    canvas.fillText('点击屏幕开始', this.canvasWidth / 2, this.canvasHeight * 0.54);
  }

  private drawGameOver(canvas: CanvasRenderingContext2D, score: number): void {
    canvas.fillStyle = 'rgba(16, 16, 20, 0.42)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = 'rgba(255,255,255,0.96)';
    canvas.textAlign = 'center';
    canvas.font = 'bold 42px sans-serif';
    canvas.fillText('游戏结束', this.canvasWidth / 2, this.canvasHeight / 2 - 56);

    canvas.font = 'bold 28px sans-serif';
    canvas.fillText(`得分 ${score}`, this.canvasWidth / 2, this.canvasHeight / 2 + 2);

    canvas.font = '24px sans-serif';
    canvas.fillText('点击任意位置返回', this.canvasWidth / 2, this.canvasHeight / 2 + 52);
  }
}
