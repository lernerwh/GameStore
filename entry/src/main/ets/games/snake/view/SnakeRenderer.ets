import { Snake } from '../model/Snake';
import { Food } from '../model/Food';
import { SnakeState } from '../model/SnakeState';
import { SnakeConstants } from '../model/SnakeConstants';
import { SnakePoint } from '../model/Point';

/**
 * 贪吃蛇渲染器
 */
export class SnakeRenderer {
  private animTime: number = 0;
  render(
    context: CanvasRenderingContext2D,
    snake: Snake,
    food: Food,
    score: number,
    gameState: SnakeState
  ): void {
    this.animTime = Date.now();

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
    context.lineWidth = 0.8;

    // 绘制垂直线
    for (let x = 0; x <= SnakeConstants.GRID_WIDTH; x++) {
      context.beginPath();
      context.moveTo(x * SnakeConstants.GRID_SIZE, 0);
      context.lineTo(x * SnakeConstants.GRID_SIZE, SnakeConstants.CANVAS_HEIGHT);
      context.stroke();
    }

    // 绘制水平线
    for (let y = 0; y <= SnakeConstants.GRID_HEIGHT; y++) {
      context.beginPath();
      context.moveTo(0, y * SnakeConstants.GRID_SIZE);
      context.lineTo(SnakeConstants.CANVAS_WIDTH, y * SnakeConstants.GRID_SIZE);
      context.stroke();
    }

    // 添加交叉点装饰
    context.fillStyle = 'rgba(34, 197, 94, 0.1)';
    const dotSize = 2;
    for (let x = 0; x <= SnakeConstants.GRID_WIDTH; x++) {
      for (let y = 0; y <= SnakeConstants.GRID_HEIGHT; y++) {
        context.beginPath();
        context.arc(x * SnakeConstants.GRID_SIZE, y * SnakeConstants.GRID_SIZE, dotSize, 0, Math.PI * 2);
        context.fill();
      }
    }
  }

  private drawSnake(context: CanvasRenderingContext2D, snake: Snake): void {
    snake.body.forEach((segment: SnakePoint, index: number) => {
      const x = segment.x * SnakeConstants.GRID_SIZE;
      const y = segment.y * SnakeConstants.GRID_SIZE;
      const size = SnakeConstants.GRID_SIZE - 2;

      // 添加阴影效果
      context.fillStyle = 'rgba(0, 0, 0, 0.15)';
      context.beginPath();
      context.roundRect(x + 2, y + 2, size, size, 6);
      context.fill();

      if (index === 0) {
        // 蛇头（增强效果）
        context.fillStyle = SnakeConstants.COLOR_SNAKE_HEAD;
        context.beginPath();
        context.roundRect(x + 1, y + 1, size, size, 7);
        context.fill();

        // 高光
        context.fillStyle = 'rgba(255, 255, 255, 0.3)';
        context.beginPath();
        context.roundRect(x + 3, y + 3, size * 0.4, size * 0.4, 4);
        context.fill();

        // 眼睛（增强效果）
        const eyeSize = 4;
        const eyeOffset = 6;
        const eyePulse = Math.sin(this.animTime / 150) * 0.5 + 4;

        context.fillStyle = '#FFFFFF';
        if (snake.direction === SnakeConstants.DIRECTION_RIGHT) {
          // 右眼
          context.beginPath();
          context.arc(x + size - eyeOffset, y + 5 + 1, eyePulse, 0, Math.PI * 2);
          context.fill();
          // 右眼瞳孔
          context.fillStyle = '#000000';
          context.beginPath();
          context.arc(x + size - eyeOffset + 1, y + 5 + 1, 2, 0, Math.PI * 2);
          context.fill();
          context.fillStyle = '#FFFFFF';
          // 左眼
          context.beginPath();
          context.arc(x + size - eyeOffset, y + size - 5 - 1, eyePulse, 0, Math.PI * 2);
          context.fill();
          // 左眼瞳孔
          context.fillStyle = '#000000';
          context.beginPath();
          context.arc(x + size - eyeOffset + 1, y + size - 5 - 1, 2, 0, Math.PI * 2);
          context.fill();
        } else if (snake.direction === SnakeConstants.DIRECTION_LEFT) {
          // 左眼
          context.beginPath();
          context.arc(x + eyeOffset, y + 5 + 1, eyePulse, 0, Math.PI * 2);
          context.fill();
          // 左眼瞳孔
          context.fillStyle = '#000000';
          context.beginPath();
          context.arc(x + eyeOffset - 1, y + 5 + 1, 2, 0, Math.PI * 2);
          context.fill();
          context.fillStyle = '#FFFFFF';
          // 右眼
          context.beginPath();
          context.arc(x + eyeOffset, y + size - 5 - 1, eyePulse, 0, Math.PI * 2);
          context.fill();
          // 右眼瞳孔
          context.fillStyle = '#000000';
          context.beginPath();
          context.arc(x + eyeOffset - 1, y + size - 5 - 1, 2, 0, Math.PI * 2);
          context.fill();
        } else if (snake.direction === SnakeConstants.DIRECTION_UP) {
          // 左眼
          context.beginPath();
          context.arc(x + 5 + 1, y + eyeOffset, eyePulse, 0, Math.PI * 2);
          context.fill();
          // 左眼瞳孔
          context.fillStyle = '#000000';
          context.beginPath();
          context.arc(x + 5 + 1, y + eyeOffset - 1, 2, 0, Math.PI * 2);
          context.fill();
          context.fillStyle = '#FFFFFF';
          // 右眼
          context.beginPath();
          context.arc(x + size - 5 - 1, y + eyeOffset, eyePulse, 0, Math.PI * 2);
          context.fill();
          // 右眼瞳孔
          context.fillStyle = '#000000';
          context.beginPath();
          context.arc(x + size - 5 - 1, y + eyeOffset - 1, 2, 0, Math.PI * 2);
          context.fill();
        } else {
          // 左眼
          context.beginPath();
          context.arc(x + 5 + 1, y + size - eyeOffset, eyePulse, 0, Math.PI * 2);
          context.fill();
          // 左眼瞳孔
          context.fillStyle = '#000000';
          context.beginPath();
          context.arc(x + 5 + 1, y + size - eyeOffset + 1, 2, 0, Math.PI * 2);
          context.fill();
          context.fillStyle = '#FFFFFF';
          // 右眼
          context.beginPath();
          context.arc(x + size - 5 - 1, y + size - eyeOffset, eyePulse, 0, Math.PI * 2);
          context.fill();
          // 右眼瞳孔
          context.fillStyle = '#000000';
          context.beginPath();
          context.arc(x + size - 5 - 1, y + size - eyeOffset + 1, 2, 0, Math.PI * 2);
          context.fill();
        }
      } else {
        // 蛇身（增强效果）
        const alpha = 0.9 - (index / snake.body.length) * 0.4;
        context.fillStyle = `rgba(34, 197, 94, ${alpha})`;
        context.beginPath();
        context.roundRect(x + 1, y + 1, size, size, 5);
        context.fill();

        // 高光
        context.fillStyle = `rgba(255, 255, 255, ${0.15 * alpha})`;
        context.beginPath();
        context.roundRect(x + 2, y + 2, size * 0.4, size * 0.4, 3);
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

    // 呼吸动画
    const pulse = Math.sin(this.animTime / 200) * 0.08 + 1;
    const appleSize = (size / 2 - 2) * pulse;

    // 绘制苹果阴影
    context.fillStyle = 'rgba(0, 0, 0, 0.15)';
    context.beginPath();
    context.arc(centerX + 1, centerY + 3, appleSize, 0, Math.PI * 2);
    context.fill();

    // 绘制苹果形状（增强效果）
    context.fillStyle = SnakeConstants.COLOR_FOOD;
    context.beginPath();
    context.arc(centerX, centerY + 2, appleSize, 0, Math.PI * 2);
    context.fill();

    // 苹果高光（增强效果）
    context.fillStyle = 'rgba(255, 255, 255, 0.35)';
    context.beginPath();
    context.arc(centerX - appleSize * 0.3, centerY - appleSize * 0.2, appleSize * 0.25, 0, Math.PI * 2);
    context.fill();

    // 苹果茎（增强效果）
    context.fillStyle = '#65a30d';
    context.fillRect(centerX - 1.5, y + 1, 3, 5);
    // 茎高光
    context.fillStyle = 'rgba(255, 255, 255, 0.2)';
    context.fillRect(centerX - 1, y + 1, 1, 5);

    // 叶子
    context.fillStyle = '#84cc16';
    context.beginPath();
    context.ellipse(centerX + 4, y + 4, 3, 1.5, 0.5, 0, Math.PI * 2);
    context.fill();
  }

  private drawScore(context: CanvasRenderingContext2D, score: number): void {
    context.shadowColor = 'rgba(0, 0, 0, 0.7)';
    context.shadowBlur = 6;
    context.shadowOffsetX = 2;
    context.shadowOffsetY = 2;
    context.fillStyle = SnakeConstants.COLOR_TEXT;
    context.font = 'bold 48px sans-serif';
    context.textAlign = 'left';
    context.textBaseline = 'top';
    context.fillText(`分数: ${score}`, 10, 12);
    context.shadowColor = 'transparent';
    context.shadowBlur = 0;
  }

  private drawMessage(context: CanvasRenderingContext2D, message: string, color: string): void {
    context.fillStyle = color;
    context.font = '36px sans-serif';
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
    context.fillStyle = 'rgba(0, 0, 0, 0.75)';
    context.fillRect(0, 0, SnakeConstants.CANVAS_WIDTH, SnakeConstants.CANVAS_HEIGHT);

    // 添加脉冲动画
    const pulse = Math.sin(this.animTime / 300) * 0.1 + 1;

    // 游戏结束文字（增强效果）
    context.shadowColor = 'rgba(0, 0, 0, 0.8)';
    context.shadowBlur = 8;
    context.shadowOffsetX = 3;
    context.shadowOffsetY = 3;
    context.fillStyle = '#ef4444';
    context.font = `bold ${Math.floor(58 * pulse)}px sans-serif`;
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillText(
      '游戏结束',
      SnakeConstants.CANVAS_WIDTH / 2,
      SnakeConstants.CANVAS_HEIGHT / 2 - 70
    );
    context.shadowColor = 'transparent';
    context.shadowBlur = 0;

    // 分数（增强效果）
    context.font = 'bold 48px sans-serif';
    context.fillText(
      `得分: ${score}`,
      SnakeConstants.CANVAS_WIDTH / 2,
      SnakeConstants.CANVAS_HEIGHT / 2 + 10
    );

    // 提示（增强效果）
    context.fillStyle = '#888888';
    context.font = '38px sans-serif';
    context.fillText(
      '点击重新开始',
      SnakeConstants.CANVAS_WIDTH / 2,
      SnakeConstants.CANVAS_HEIGHT / 2 + 90
    );
  }
}
