import { Player } from '../../../model/Player';
import { Creature } from '../../../model/Creature';
import { GameState } from '../../../model/GameState';
import { GameConstants } from '../../../common/constants/GameConstants';
import { Camera, Point } from '../viewmodel/GameEngine';
import { ImageManager } from '../../../common/utils/ImageManager';

/**
 * 游戏渲染器 - 召唤神龙
 */
export class GameRenderer {
  private canvasWidth: number = GameConstants.CANVAS_WIDTH;
  private canvasHeight: number = GameConstants.CANVAS_HEIGHT;

  render(
    canvas: CanvasRenderingContext2D,
    player: Player,
    creatures: Creature[],
    score: number,
    gameState: GameState,
    hasWon: boolean,
    playTime: number,
    camera: Camera
  ): void {
    this.clearCanvas(canvas);
    this.drawBackground(canvas);

    if (gameState === GameState.PLAYING || gameState === GameState.GAME_OVER) {
      this.drawCreatures(canvas, creatures, camera, player);
      this.drawPlayer(canvas, player, camera);
      this.drawBoundaryWarning(canvas, player, camera);
      this.drawMinimap(canvas, player, creatures, camera);
      this.drawHUD(canvas, player, score, playTime);
    }

    if (gameState === GameState.IDLE) {
      this.drawStartPrompt(canvas);
    } else if (gameState === GameState.GAME_OVER) {
      this.drawGameOver(canvas, score, hasWon);
    }
  }

  private clearCanvas(canvas: CanvasRenderingContext2D): void {
    canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private drawBackground(canvas: CanvasRenderingContext2D): void {
    // 深海渐变背景
    const gradient = canvas.createLinearGradient(0, 0, 0, this.canvasHeight);
    gradient.addColorStop(0, '#0a1628');
    gradient.addColorStop(0.5, '#1a4a7a');
    gradient.addColorStop(1, '#0d2847');
    canvas.fillStyle = gradient;
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 绘制水波纹效果
    canvas.strokeStyle = 'rgba(255, 255, 255, 0.03)';
    canvas.lineWidth = 1;
    for (let i = 0; i < 10; i++) {
      canvas.beginPath();
      canvas.arc(this.canvasWidth / 2, this.canvasHeight / 2, 50 + i * 40, 0, Math.PI * 2);
      canvas.stroke();
    }
  }

  private drawPlayer(canvas: CanvasRenderingContext2D, player: Player, camera: Camera): void {
    const screenPos: Point = camera.worldToScreen(player.x, player.y);
    const radius = player.getRadius();
    const imageManager = ImageManager.getInstance();
    const imageKey = imageManager.getPlayerImageKey(player.evolutionLevel);
    const cachedImage = imageManager.getCachedImage(imageKey);

    // 玩家光晕
    const glowGradient = canvas.createRadialGradient(
      screenPos.x, screenPos.y, 0,
      screenPos.x, screenPos.y, radius * 1.5
    );
    glowGradient.addColorStop(0, 'rgba(255, 215, 0, 0.3)');
    glowGradient.addColorStop(1, 'rgba(255, 215, 0, 0)');
    canvas.fillStyle = glowGradient;
    canvas.beginPath();
    canvas.arc(screenPos.x, screenPos.y, radius * 1.5, 0, Math.PI * 2);
    canvas.fill();

    if (cachedImage) {
      // 使用图片绘制
      canvas.drawImage(
        cachedImage,
        screenPos.x - radius,
        screenPos.y - radius,
        radius * 2,
        radius * 2
      );
    } else {
      // 回退到圆形绘制
      canvas.fillStyle = player.getColor();
      canvas.beginPath();
      canvas.arc(screenPos.x, screenPos.y, radius, 0, Math.PI * 2);
      canvas.fill();
    }

    // 玩家边框
    canvas.strokeStyle = '#FFD700';
    canvas.lineWidth = 2;
    canvas.beginPath();
    canvas.arc(screenPos.x, screenPos.y, radius, 0, Math.PI * 2);
    canvas.stroke();

    // 玩家名称
    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 24px sans-serif';
    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';
    canvas.fillText(player.getName(), screenPos.x, screenPos.y - radius - 15);
  }

  private drawCreatures(canvas: CanvasRenderingContext2D, creatures: Creature[], camera: Camera, player: Player): void {
    const playerRadius = player.getRadius();
    const imageManager = ImageManager.getInstance();

    for (const creature of creatures) {
      const screenPos: Point = camera.worldToScreen(creature.x, creature.y);
      const radius = creature.getRadius();

      // 只绘制在屏幕内的生物
      if (screenPos.x + radius < 0 || screenPos.x - radius > this.canvasWidth ||
          screenPos.y + radius < 0 || screenPos.y - radius > this.canvasHeight) {
        continue;
      }

      // 根据相对大小决定边框颜色
      let borderColor: string;
      if (creature.evolutionLevel <= player.evolutionLevel) {
        borderColor = '#90EE90'; // 可以吃 - 绿色
      } else {
        borderColor = '#FF6B6B'; // 危险 - 红色
      }

      const imageKey = imageManager.getCreatureImageKey(creature.evolutionLevel);
      const cachedImage = imageManager.getCachedImage(imageKey);

      if (cachedImage) {
        // 使用图片绘制
        canvas.drawImage(
          cachedImage,
          screenPos.x - radius,
          screenPos.y - radius,
          radius * 2,
          radius * 2
        );
      } else {
        // 回退到圆形绘制
        canvas.fillStyle = creature.getColor();
        canvas.beginPath();
        canvas.arc(screenPos.x, screenPos.y, radius, 0, Math.PI * 2);
        canvas.fill();
      }

      // 边框
      canvas.strokeStyle = borderColor;
      canvas.lineWidth = 2;
      canvas.beginPath();
      canvas.arc(screenPos.x, screenPos.y, radius, 0, Math.PI * 2);
      canvas.stroke();
    }
  }

  private drawBoundaryWarning(canvas: CanvasRenderingContext2D, player: Player, camera: Camera): void {
    const warningDistance = 100;
    const playerRadius = player.getRadius();

    // 检查是否靠近边界
    const nearLeft = player.x < warningDistance;
    const nearRight = player.x > GameConstants.WORLD_WIDTH - warningDistance;
    const nearTop = player.y < warningDistance;
    const nearBottom = player.y > GameConstants.WORLD_HEIGHT - warningDistance;

    if (nearLeft || nearRight || nearTop || nearBottom) {
      // 红色警告边缘
      canvas.strokeStyle = 'rgba(255, 0, 0, 0.5)';
      canvas.lineWidth = 10;
      canvas.strokeRect(5, 5, this.canvasWidth - 10, this.canvasHeight - 10);

      // 警告文字
      canvas.fillStyle = '#FF6B6B';
      canvas.font = 'bold 28px sans-serif';
      canvas.textAlign = 'center';
      canvas.fillText('⚠ 注意边界', this.canvasWidth / 2, 30);
    }
  }

  private drawMinimap(canvas: CanvasRenderingContext2D, player: Player, creatures: Creature[], camera: Camera): void {
    const minimapSize = 80;
    const minimapX = this.canvasWidth - minimapSize - 10;
    const minimapY = 10;
    const scaleX = minimapSize / GameConstants.WORLD_WIDTH;
    const scaleY = minimapSize / GameConstants.WORLD_HEIGHT;

    // 小地图背景
    canvas.fillStyle = 'rgba(0, 0, 0, 0.5)';
    canvas.fillRect(minimapX, minimapY, minimapSize, minimapSize);
    canvas.strokeStyle = 'rgba(255, 255, 255, 0.3)';
    canvas.lineWidth = 1;
    canvas.strokeRect(minimapX, minimapY, minimapSize, minimapSize);

    // 绘制视野范围
    const viewX = minimapX + camera.x * scaleX;
    const viewY = minimapY + camera.y * scaleY;
    const viewW = this.canvasWidth * scaleX;
    const viewH = this.canvasHeight * scaleY;
    canvas.strokeStyle = 'rgba(255, 255, 255, 0.5)';
    canvas.strokeRect(viewX, viewY, viewW, viewH);

    // 绘制敌人点
    for (const creature of creatures) {
      const dotX = minimapX + creature.x * scaleX;
      const dotY = minimapY + creature.y * scaleY;

      if (creature.evolutionLevel <= player.evolutionLevel) {
        canvas.fillStyle = '#90EE90'; // 可食用 - 绿色
      } else {
        canvas.fillStyle = '#FF6B6B'; // 危险 - 红色
      }
      canvas.beginPath();
      canvas.arc(dotX, dotY, 2, 0, Math.PI * 2);
      canvas.fill();
    }

    // 绘制玩家位置
    const playerDotX = minimapX + player.x * scaleX;
    const playerDotY = minimapY + player.y * scaleY;
    canvas.fillStyle = '#FFD700';
    canvas.beginPath();
    canvas.arc(playerDotX, playerDotY, 4, 0, Math.PI * 2);
    canvas.fill();
  }

  private drawHUD(canvas: CanvasRenderingContext2D, player: Player, score: number, playTime: number): void {
    // 左上角信息
    canvas.fillStyle = 'rgba(0, 0, 0, 0.5)';
    canvas.fillRect(5, 5, 180, 90);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 28px sans-serif';
    canvas.textAlign = 'left';
    canvas.textBaseline = 'top';
    canvas.fillText(`分数: ${score}`, 10, 10);

    // 游戏时间
    const minutes = Math.floor(playTime / 60);
    const seconds = Math.floor(playTime % 60);
    canvas.font = '24px sans-serif';
    canvas.fillText(`时间: ${minutes}:${seconds.toString().padStart(2, '0')}`, 10, 42);

    // 当前进化等级
    canvas.fillStyle = player.getColor();
    canvas.fillText(`${player.getName()}`, 10, 70);
  }

  private drawStartPrompt(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.5)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 48px sans-serif';
    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';
    canvas.fillText('点击开始游戏', this.canvasWidth / 2, this.canvasHeight / 2);
  }

  private drawGameOver(canvas: CanvasRenderingContext2D, score: number, hasWon: boolean): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.7)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';

    if (hasWon) {
      // 胜利
      canvas.fillStyle = '#FFD700';
      canvas.font = 'bold 48px sans-serif';
      canvas.fillText('🐉 恭喜你召唤出神龙! 🐉', this.canvasWidth / 2, this.canvasHeight / 2 - 60);
    } else {
      // 失败
      canvas.fillStyle = '#FF6B6B';
      canvas.font = 'bold 48px sans-serif';
      canvas.fillText('游戏结束', this.canvasWidth / 2, this.canvasHeight / 2 - 60);
    }

    canvas.fillStyle = '#FFFFFF';
    canvas.font = '36px sans-serif';
    canvas.fillText(`最终分数: ${score}`, this.canvasWidth / 2, this.canvasHeight / 2 + 20);

    canvas.fillStyle = '#AAAAAA';
    canvas.font = '28px sans-serif';
    canvas.fillText('点击返回主菜单', this.canvasWidth / 2, this.canvasHeight / 2 + 80);
  }
}
