import { Snake } from '../model/Snake';
import { Food } from '../model/Food';
import { SnakeState } from '../model/SnakeState';
import { SnakeConstants } from '../model/SnakeConstants';
import { SnakePoint } from '../model/Point';

/**
 * 贪吃蛇渲染器
 */
export class SnakeRenderer {
  render(
    context: CanvasRenderingContext2D,
    snake: Snake,
    food: Food,
    score: number,
    gameState: SnakeState
  ): void {
    // 清空画布
    context.fillStyle = SnakeConstants.COLOR_BACKGROUND;
    context.fillRect(0, 0, SnakeConstants.CANVAS_WIDTH, SnakeConstants.CANVAS_HEIGHT);

    // 绘制网格
    this.drawGrid(context);

    // 绘制食物
    this.drawFood(context, food);

    // 绘制蛇
    this.drawSnake(context, snake);

    // 绘制分数
    this.drawScore(context, score);

    // 绘制游戏状态提示
    if (gameState === SnakeState.IDLE) {
      this.drawMessage(context, '滑动屏幕开始游戏', '#888888');
    } else if (gameState === SnakeState.GAME_OVER) {
      this.drawGameOver(context, score);
    }
  }

  private drawGrid(context: CanvasRenderingContext2D): void {
    context.strokeStyle = SnakeConstants.COLOR_GRID;
    context.lineWidth = 0.5;

    for (let x = 0; x <= SnakeConstants.GRID_WIDTH; x++) {
      context.beginPath();
      context.moveTo(x * SnakeConstants.GRID_SIZE, 0);
      context.lineTo(x * SnakeConstants.GRID_SIZE, SnakeConstants.CANVAS_HEIGHT);
      context.stroke();
    }

    for (let y = 0; y <= SnakeConstants.GRID_HEIGHT; y++) {
      context.beginPath();
      context.moveTo(0, y * SnakeConstants.GRID_SIZE);
      context.lineTo(SnakeConstants.CANVAS_WIDTH, y * SnakeConstants.GRID_SIZE);
      context.stroke();
    }
  }

  private drawSnake(context: CanvasRenderingContext2D, snake: Snake): void {
    snake.body.forEach((segment: SnakePoint, index: number) => {
      const x = segment.x * SnakeConstants.GRID_SIZE;
      const y = segment.y * SnakeConstants.GRID_SIZE;
      const size = SnakeConstants.GRID_SIZE - 2;

      if (index === 0) {
        // 蛇头
        context.fillStyle = SnakeConstants.COLOR_SNAKE_HEAD;
        context.beginPath();
        context.roundRect(x + 1, y + 1, size, size, 6);
        context.fill();

        // 眼睛
        context.fillStyle = '#000000';
        const eyeSize = 3;
        const eyeOffset = 5;
        if (snake.direction === SnakeConstants.DIRECTION_RIGHT) {
          context.fillRect(x + size - eyeOffset, y + 5, eyeSize, eyeSize);
          context.fillRect(x + size - eyeOffset, y + size - 5, eyeSize, eyeSize);
        } else if (snake.direction === SnakeConstants.DIRECTION_LEFT) {
          context.fillRect(x + eyeOffset, y + 5, eyeSize, eyeSize);
          context.fillRect(x + eyeOffset, y + size - 5, eyeSize, eyeSize);
        } else if (snake.direction === SnakeConstants.DIRECTION_UP) {
          context.fillRect(x + 5, y + eyeOffset, eyeSize, eyeSize);
          context.fillRect(x + size - 5, y + eyeOffset, eyeSize, eyeSize);
        } else {
          context.fillRect(x + 5, y + size - eyeOffset, eyeSize, eyeSize);
          context.fillRect(x + size - 5, y + size - eyeOffset, eyeSize, eyeSize);
        }
      } else {
        // 蛇身 - 渐变色
        const alpha = 1 - (index / snake.body.length) * 0.5;
        context.fillStyle = `rgba(34, 197, 94, ${alpha})`;
        context.beginPath();
        context.roundRect(x + 1, y + 1, size, size, 4);
        context.fill();
      }
    });
  }

  private drawFood(context: CanvasRenderingContext2D, food: Food): void {
    const x = food.position.x * SnakeConstants.GRID_SIZE;
    const y = food.position.y * SnakeConstants.GRID_SIZE;
    const size = SnakeConstants.GRID_SIZE - 2;
    const centerX = x + SnakeConstants.GRID_SIZE / 2;
    const centerY = y + SnakeConstants.GRID_SIZE / 2;

    // 绘制苹果形状
    context.fillStyle = SnakeConstants.COLOR_FOOD;
    context.beginPath();
    context.arc(centerX, centerY + 2, size / 2 - 2, 0, Math.PI * 2);
    context.fill();

    // 苹果茎
    context.fillStyle = '#65a30d';
    context.fillRect(centerX - 1, y + 2, 3, 4);

    // 高光
    context.fillStyle = 'rgba(255, 255, 255, 0.3)';
    context.beginPath();
    context.arc(centerX - 2, centerY, 2, 0, Math.PI * 2);
    context.fill();
  }

  private drawScore(context: CanvasRenderingContext2D, score: number): void {
    context.fillStyle = SnakeConstants.COLOR_TEXT;
    context.font = 'bold 20px sans-serif';
    context.textAlign = 'left';
    context.textBaseline = 'top';
    context.fillText(`分数: ${score}`, 10, 10);
  }

  private drawMessage(context: CanvasRenderingContext2D, message: string, color: string): void {
    context.fillStyle = color;
    context.font = '18px sans-serif';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillText(
      message,
      SnakeConstants.CANVAS_WIDTH / 2,
      SnakeConstants.CANVAS_HEIGHT / 2
    );
  }

  private drawGameOver(context: CanvasRenderingContext2D, score: number): void {
    // 半透明背景
    context.fillStyle = 'rgba(0, 0, 0, 0.7)';
    context.fillRect(0, 0, SnakeConstants.CANVAS_WIDTH, SnakeConstants.CANVAS_HEIGHT);

    // 游戏结束文字
    context.fillStyle = '#ef4444';
    context.font = 'bold 32px sans-serif';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillText(
      '游戏结束',
      SnakeConstants.CANVAS_WIDTH / 2,
      SnakeConstants.CANVAS_HEIGHT / 2 - 30
    );

    // 分数
    context.fillStyle = '#ffffff';
    context.font = '20px sans-serif';
    context.fillText(
      `得分: ${score}`,
      SnakeConstants.CANVAS_WIDTH / 2,
      SnakeConstants.CANVAS_HEIGHT / 2 + 20
    );

    // 提示
    context.fillStyle = '#888888';
    context.font = '16px sans-serif';
    context.fillText(
      '点击重新开始',
      SnakeConstants.CANVAS_WIDTH / 2,
      SnakeConstants.CANVAS_HEIGHT / 2 + 60
    );
  }
}
