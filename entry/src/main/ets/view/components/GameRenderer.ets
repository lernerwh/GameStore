import { Player } from '../../model/entities/Player';
import { GameState } from '../../model/entities/GameState';
import { GameConstants } from '../../common/constants/GameConstants';

export class GameRenderer {
  private canvasWidth: number = GameConstants.CANVAS_WIDTH;
  private canvasHeight: number = GameConstants.CANVAS_HEIGHT;

  render(
    canvas: CanvasRenderingContext2D,
    player: Player,
    score: number,
    gameState: GameState
  ): void {
    this.clearCanvas(canvas);
    this.drawBackground(canvas);
    this.drawPlayer(canvas, player);
    this.drawScore(canvas, score);

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

  private drawPlayer(canvas: CanvasRenderingContext2D, player: Player): void {
    canvas.fillStyle = GameConstants.COLOR_PLAYER;
    canvas.fillRect(player.x, player.y, player.width, player.height);
  }

  private drawScore(canvas: CanvasRenderingContext2D, score: number): void {
    canvas.fillStyle = '#FFFFFF';
    canvas.strokeStyle = '#000000';
    canvas.lineWidth = 3;
    canvas.font = 'bold 36px sans-serif';
    canvas.textAlign = 'center';
    canvas.strokeText(score.toString(), this.canvasWidth / 2, 50);
    canvas.fillText(score.toString(), this.canvasWidth / 2, 50);
  }

  private drawStartPrompt(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.5)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 28px sans-serif';
    canvas.textAlign = 'center';
    canvas.fillText('点击开始', this.canvasWidth / 2, this.canvasHeight / 2);
  }

  private drawGameOver(canvas: CanvasRenderingContext2D, score: number): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.6)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 36px sans-serif';
    canvas.textAlign = 'center';
    canvas.fillText('游戏结束', this.canvasWidth / 2, this.canvasHeight / 2 - 30);

    canvas.font = '24px sans-serif';
    canvas.fillText('分数: ' + score, this.canvasWidth / 2, this.canvasHeight / 2 + 20);
    canvas.fillText('点击重新开始', this.canvasWidth / 2, this.canvasHeight / 2 + 60);
  }
}
