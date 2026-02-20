import { Bird } from '../model/Bird';
import { Pipe } from '../model/Pipe';
import { GameState } from '../model/GameState';
import { GameConstants } from '../model/GameConstants';
import { drawing } from '@kit.ArkGraphics2D';

/**
 * 游戏渲染器 - Canvas绘制逻辑
 */
export class GameRenderer {
  private canvasWidth: number;
  private canvasHeight: number;

  constructor(width: number = GameConstants.CANVAS_WIDTH, height: number = GameConstants.CANVAS_HEIGHT) {
    this.canvasWidth = width;
    this.canvasHeight = height;
  }

  /**
   * 渲染游戏画面
   * @param canvas Canvas对象
   * @param bird 小鸟
   * @param pipes 管道列表
   * @param score 分数
   * @param gameState 游戏状态
   * @param groundY 地面Y坐标
   */
  render(
    canvas: CanvasRenderingContext2D,
    bird: Bird,
    pipes: Pipe[],
    score: number,
    gameState: GameState,
    groundY: number
  ): void {
    // 清空画布
    this.clearCanvas(canvas);

    // 绘制背景
    this.drawBackground(canvas);

    // 绘制管道
    this.drawPipes(canvas, pipes);

    // 绘制地面
    this.drawGround(canvas, groundY);

    // 绘制小鸟
    this.drawBird(canvas, bird);

    // 绘制分数
    this.drawScore(canvas, score);

    // 绘制游戏状态提示
    if (gameState === GameState.IDLE) {
      this.drawStartPrompt(canvas);
    } else if (gameState === GameState.GAME_OVER) {
      this.drawGameOver(canvas, score);
    }
  }

  /**
   * 清空画布
   */
  private clearCanvas(canvas: CanvasRenderingContext2D): void {
    canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  /**
   * 绘制背景
   */
  private drawBackground(canvas: CanvasRenderingContext2D): void {
    // 天空渐变背景
    const gradient = canvas.createLinearGradient(0, 0, 0, this.canvasHeight);
    gradient.addColorStop(0, '#87CEEB');
    gradient.addColorStop(0.7, '#B0E0E6');
    gradient.addColorStop(1, '#98FB98');

    canvas.fillStyle = gradient;
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 绘制简单的云朵
    this.drawClouds(canvas);
  }

  /**
   * 绘制云朵
   */
  private drawClouds(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = 'rgba(255, 255, 255, 0.8)';

    // 云朵1
    this.drawCloud(canvas, 50, 80, 40);
    // 云朵2
    this.drawCloud(canvas, 200, 120, 35);
    // 云朵3
    this.drawCloud(canvas, 300, 60, 30);
  }

  /**
   * 绘制单个云朵
   */
  private drawCloud(canvas: CanvasRenderingContext2D, x: number, y: number, size: number): void {
    canvas.beginPath();
    canvas.arc(x, y, size, 0, Math.PI * 2);
    canvas.arc(x + size * 0.8, y - size * 0.3, size * 0.7, 0, Math.PI * 2);
    canvas.arc(x + size * 1.5, y, size * 0.8, 0, Math.PI * 2);
    canvas.fill();
  }

  /**
   * 绘制管道
   */
  private drawPipes(canvas: CanvasRenderingContext2D, pipes: Pipe[]): void {
    for (const pipe of pipes) {
      // 上管道
      this.drawPipe(canvas, pipe.x, 0, pipe.width, pipe.topHeight, true);

      // 下管道
      const bottomHeight = this.canvasHeight - pipe.bottomY;
      this.drawPipe(canvas, pipe.x, pipe.bottomY, pipe.width, bottomHeight, false);
    }
  }

  /**
   * 绘制单个管道
   */
  private drawPipe(
    canvas: CanvasRenderingContext2D,
    x: number,
    y: number,
    width: number,
    height: number,
    isTop: boolean
  ): void {
    // 管道主体
    canvas.fillStyle = GameConstants.COLOR_PIPE;
    canvas.fillRect(x, y, width, height);

    // 管道边框
    canvas.strokeStyle = GameConstants.COLOR_PIPE_BORDER;
    canvas.lineWidth = 3;
    canvas.strokeRect(x, y, width, height);

    // 管道帽
    const capHeight = 20;
    const capWidth = width + 10;
    const capX = x - 5;
    const capY = isTop ? y + height - capHeight : y;

    canvas.fillStyle = GameConstants.COLOR_PIPE;
    canvas.fillRect(capX, capY, capWidth, capHeight);
    canvas.strokeRect(capX, capY, capWidth, capHeight);

    // 添加高光效果
    canvas.fillStyle = 'rgba(255, 255, 255, 0.3)';
    canvas.fillRect(x + 5, y, 8, height);
  }

  /**
   * 绘制地面
   */
  private drawGround(canvas: CanvasRenderingContext2D, groundY: number): void {
    const groundHeight = this.canvasHeight - groundY;

    // 地面主体
    canvas.fillStyle = '#8B4513';
    canvas.fillRect(0, groundY, this.canvasWidth, groundHeight);

    // 草地
    canvas.fillStyle = '#228B22';
    canvas.fillRect(0, groundY, this.canvasWidth, 15);

    // 草地纹理
    canvas.fillStyle = '#32CD32';
    for (let i = 0; i < this.canvasWidth; i += 20) {
      canvas.fillRect(i, groundY, 10, 5);
    }
  }

  /**
   * 绘制小鸟
   */
  private drawBird(canvas: CanvasRenderingContext2D, bird: Bird): void {
    canvas.save();

    // 移动到小鸟中心点
    const centerX = bird.x + bird.width / 2;
    const centerY = bird.y + bird.height / 2;
    canvas.translate(centerX, centerY);

    // 应用旋转
    canvas.rotate(bird.rotation);

    // 绘制小鸟身体
    canvas.fillStyle = GameConstants.COLOR_BIRD;
    canvas.beginPath();
    canvas.ellipse(0, 0, bird.width / 2, bird.height / 2, 0, 0, Math.PI * 2);
    canvas.fill();

    // 绘制小鸟边框
    canvas.strokeStyle = '#DAA520';
    canvas.lineWidth = 2;
    canvas.stroke();

    // 绘制眼睛
    canvas.fillStyle = '#FFFFFF';
    canvas.beginPath();
    canvas.arc(bird.width / 4, -bird.height / 6, 6, 0, Math.PI * 2);
    canvas.fill();

    canvas.fillStyle = '#000000';
    canvas.beginPath();
    canvas.arc(bird.width / 4 + 2, -bird.height / 6, 3, 0, Math.PI * 2);
    canvas.fill();

    // 绘制嘴巴
    canvas.fillStyle = '#FF6347';
    canvas.beginPath();
    canvas.moveTo(bird.width / 2, 0);
    canvas.lineTo(bird.width / 2 + 10, 3);
    canvas.lineTo(bird.width / 2, 6);
    canvas.closePath();
    canvas.fill();

    // 绘制翅膀
    canvas.fillStyle = '#FFA500';
    canvas.beginPath();
    canvas.ellipse(-5, 5, 8, 5, 0, 0, Math.PI * 2);
    canvas.fill();

    canvas.restore();
  }

  /**
   * 绘制分数
   */
  private drawScore(canvas: CanvasRenderingContext2D, score: number): void {
    canvas.fillStyle = '#FFFFFF';
    canvas.strokeStyle = '#000000';
    canvas.lineWidth = 4;
    canvas.font = 'bold 48px sans-serif';
    canvas.textAlign = 'center';
    canvas.textBaseline = 'top';

    const text = score.toString();
    const x = this.canvasWidth / 2;
    const y = 50;

    // 描边
    canvas.strokeText(text, x, y);
    // 填充
    canvas.fillText(text, x, y);
  }

  /**
   * 绘制开始提示
   */
  private drawStartPrompt(canvas: CanvasRenderingContext2D): void {
    // 半透明背景
    canvas.fillStyle = 'rgba(0, 0, 0, 0.3)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 提示文字
    canvas.fillStyle = '#FFFFFF';
    canvas.strokeStyle = '#000000';
    canvas.lineWidth = 3;
    canvas.font = 'bold 32px sans-serif';
    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';

    const text = '点击开始';
    const x = this.canvasWidth / 2;
    const y = this.canvasHeight / 2;

    canvas.strokeText(text, x, y);
    canvas.fillText(text, x, y);
  }

  /**
   * 绘制游戏结束画面
   */
  private drawGameOver(canvas: CanvasRenderingContext2D, score: number): void {
    // 半透明背景
    canvas.fillStyle = 'rgba(0, 0, 0, 0.5)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 游戏结束面板
    const panelWidth = 280;
    const panelHeight = 200;
    const panelX = (this.canvasWidth - panelWidth) / 2;
    const panelY = (this.canvasHeight - panelHeight) / 2;

    // 面板背景
    canvas.fillStyle = '#DEB887';
    canvas.strokeStyle = '#8B4513';
    canvas.lineWidth = 4;
    this.drawRoundRect(canvas, panelX, panelY, panelWidth, panelHeight, 15);

    // 游戏结束文字
    canvas.fillStyle = '#8B0000';
    canvas.font = 'bold 36px sans-serif';
    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';
    canvas.fillText('游戏结束', this.canvasWidth / 2, panelY + 50);

    // 分数
    canvas.fillStyle = '#000000';
    canvas.font = 'bold 24px sans-serif';
    canvas.fillText(`分数: ${score}`, this.canvasWidth / 2, panelY + 100);

    // 重新开始提示
    canvas.fillStyle = '#006400';
    canvas.font = '20px sans-serif';
    canvas.fillText('点击重新开始', this.canvasWidth / 2, panelY + 160);
  }

  /**
   * 绘制圆角矩形
   */
  private drawRoundRect(
    canvas: CanvasRenderingContext2D,
    x: number,
    y: number,
    width: number,
    height: number,
    radius: number
  ): void {
    canvas.beginPath();
    canvas.moveTo(x + radius, y);
    canvas.lineTo(x + width - radius, y);
    canvas.arcTo(x + width, y, x + width, y + radius, radius);
    canvas.lineTo(x + width, y + height - radius);
    canvas.arcTo(x + width, y + height, x + width - radius, y + height, radius);
    canvas.lineTo(x + radius, y + height);
    canvas.arcTo(x, y + height, x, y + height - radius, radius);
    canvas.lineTo(x, y + radius);
    canvas.arcTo(x, y, x + radius, y, radius);
    canvas.closePath();
    canvas.fill();
    canvas.stroke();
  }
}
