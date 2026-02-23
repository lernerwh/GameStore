import { Player } from '../../../model/Player';
import { Creature } from '../../../model/Creature';
import { GameState } from '../../../model/GameState';
import { GameConstants } from '../../../common/constants/GameConstants';
import { Camera, Point } from '../viewmodel/GameEngine';
import { ImageManager } from '../../../common/utils/ImageManager';

export interface JoystickRenderState {
  active: boolean;
  centerX: number;
  centerY: number;
  handleX: number;
  handleY: number;
}

/**
 * 游戏渲染器 - 召唤神龙
 */
export class GameRenderer {
  private canvasWidth: number = GameConstants.CANVAS_WIDTH;
  private canvasHeight: number = GameConstants.CANVAS_HEIGHT;
  private animTime: number = 0;
  private joystickMaxDistance: number = 90;

  render(
    canvas: CanvasRenderingContext2D,
    player: Player,
    creatures: Creature[],
    score: number,
    gameState: GameState,
    hasWon: boolean,
    playTime: number,
    camera: Camera,
    joystickState?: JoystickRenderState
  ): void {
    this.animTime = Date.now();
    this.clearCanvas(canvas);
    this.drawBackground(canvas);

    if (gameState === GameState.PLAYING || gameState === GameState.GAME_OVER) {
      this.drawCreatures(canvas, creatures, camera, player);
      this.drawPlayer(canvas, player, camera);
      this.drawBoundaryWarning(canvas, player, camera);
      this.drawMinimap(canvas, player, creatures, camera);
      this.drawHUD(canvas, player, score, playTime);
      this.drawJoystick(canvas, joystickState);
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

    // 玩家光晕（添加脉冲动画）
    const pulse = Math.sin(this.animTime / 400) * 0.1 + 1;
    const glowRadius = radius * 1.5 * pulse;
    const glowGradient = canvas.createRadialGradient(
      screenPos.x, screenPos.y, 0,
      screenPos.x, screenPos.y, glowRadius
    );
    glowGradient.addColorStop(0, 'rgba(255, 215, 0, 0.35)');
    glowGradient.addColorStop(1, 'rgba(255, 215, 0, 0)');
    canvas.fillStyle = glowGradient;
    canvas.beginPath();
    canvas.arc(screenPos.x, screenPos.y, glowRadius, 0, Math.PI * 2);
    canvas.fill();

    // 玩家阴影
    canvas.beginPath();
    canvas.arc(screenPos.x + 2, screenPos.y + 2, radius, 0, Math.PI * 2);
    canvas.fillStyle = 'rgba(0, 0, 0, 0.15)';
    canvas.fill();

    if (cachedImage) {
      // 使用图片绘制
      const breathe = Math.sin(this.animTime / 500) * 0.03 + 1;
      const imageRadius = radius * 2 * breathe;
      canvas.drawImage(
        cachedImage,
        screenPos.x - imageRadius / 2,
        screenPos.y - imageRadius / 2,
        imageRadius,
        imageRadius
      );
    } else {
      // 回退到圆形绘制
      canvas.fillStyle = player.getColor();
      canvas.beginPath();
      canvas.arc(screenPos.x, screenPos.y, radius, 0, Math.PI * 2);
      canvas.fill();
    }

    // 玩家边框（增强效果）
    canvas.strokeStyle = '#FFD700';
    canvas.lineWidth = 3;
    canvas.beginPath();
    canvas.arc(screenPos.x, screenPos.y, radius, 0, Math.PI * 2);
    canvas.stroke();

    // 高光
    canvas.strokeStyle = 'rgba(255, 255, 255, 0.3)';
    canvas.lineWidth = 2;
    canvas.beginPath();
    canvas.arc(screenPos.x, screenPos.y, radius * 0.8, 0, Math.PI * 2);
    canvas.stroke();

    // 玩家名称（添加阴影）
    canvas.shadowColor = 'rgba(0, 0, 0, 0.8)';
    canvas.shadowBlur = 4;
    canvas.shadowOffsetX = 2;
    canvas.shadowOffsetY = 2;
    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 38px sans-serif';
    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';
    canvas.fillText(player.getName(), screenPos.x, screenPos.y - radius - 22);
    canvas.shadowColor = 'transparent';
    canvas.shadowBlur = 0;
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

      // 根据相对大小决定边框颜色和效果
      let borderColor: string;
      let glowColor: string | undefined;
      if (creature.evolutionLevel <= player.evolutionLevel) {
        borderColor = '#90EE90'; // 可以吃 - 绿色
        glowColor = 'rgba(144, 238, 144, 0.2)';
      } else {
        borderColor = '#FF6B6B'; // 危险 - 红色
        glowColor = 'rgba(255, 107, 107, 0.2)';
      }

      // 危险生物添加脉冲效果
      if (creature.evolutionLevel > player.evolutionLevel) {
        const pulse = Math.sin(this.animTime / 300) * 0.15 + 1;
        const pulseRadius = radius * 1.2 * pulse;
        const pulseGradient = canvas.createRadialGradient(
          screenPos.x, screenPos.y, 0,
          screenPos.x, screenPos.y, pulseRadius
        );
        pulseGradient.addColorStop(0, glowColor || 'rgba(255, 107, 107, 0.3)');
        pulseGradient.addColorStop(1, 'rgba(255, 107, 107, 0)');
        canvas.fillStyle = pulseGradient;
        canvas.beginPath();
        canvas.arc(screenPos.x, screenPos.y, pulseRadius, 0, Math.PI * 2);
        canvas.fill();
      }

      // 阴影
      canvas.beginPath();
      canvas.arc(screenPos.x + 1, screenPos.y + 1, radius, 0, Math.PI * 2);
      canvas.fillStyle = 'rgba(0, 0, 0, 0.12)';
      canvas.fill();

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

      // 边框（增强效果）
      canvas.strokeStyle = borderColor;
      canvas.lineWidth = 2.5;
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
      canvas.font = 'bold 42px sans-serif';
      canvas.textAlign = 'center';
      canvas.fillText('⚠ 注意边界', this.canvasWidth / 2, 35);
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
    // 左上角信息（增强背景）
    canvas.fillStyle = 'rgba(0, 0, 0, 0.65)';
    canvas.fillRect(5, 5, 260, 170);
    canvas.strokeStyle = 'rgba(255, 255, 255, 0.2)';
    canvas.lineWidth = 1.5;
    canvas.strokeRect(5, 5, 260, 170);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 44px sans-serif';
    canvas.textAlign = 'left';
    canvas.textBaseline = 'top';
    canvas.fillText(`分数: ${score}`, 15, 10);

    // 游戏时间
    const minutes = Math.floor(playTime / 60);
    const seconds = Math.floor(playTime % 60);
    canvas.font = '36px sans-serif';
    canvas.fillText(`时间: ${minutes}:${seconds.toString().padStart(2, '0')}`, 15, 60);

    // 当前进化等级（添加阴影）
    canvas.shadowColor = 'rgba(0, 0, 0, 0.5)';
    canvas.shadowBlur = 3;
    canvas.shadowOffsetX = 1;
    canvas.shadowOffsetY = 1;
    canvas.fillStyle = player.getColor();
    canvas.font = 'bold 36px sans-serif';
    canvas.fillText(`${player.getName()}`, 15, 105);
    canvas.shadowColor = 'transparent';
    canvas.shadowBlur = 0;

    // 成长进度条
    this.drawGrowthProgress(canvas, player, score);
  }

  private drawGrowthProgress(canvas: CanvasRenderingContext2D, player: Player, score: number): void {
    const level = player.evolutionLevel;
    const isMaxLevel = level >= GameConstants.EVOLUTION_SCORES.length - 1;
    const currentNeed = GameConstants.EVOLUTION_SCORES[level];
    const nextNeed = isMaxLevel ? currentNeed : GameConstants.EVOLUTION_SCORES[level + 1];
    const gained = Math.max(0, score - currentNeed);
    const total = Math.max(1, nextNeed - currentNeed);
    const progress = isMaxLevel ? 1 : Math.max(0, Math.min(1, gained / total));

    const barX = 15;
    const barY = 133;
    const barW = 170;
    const barH = 12;

    canvas.fillStyle = '#88AFC7';
    canvas.font = '22px sans-serif';
    canvas.fillText('成长进度', barX, 122);

    canvas.fillStyle = 'rgba(255,255,255,0.2)';
    canvas.fillRect(barX, barY, barW, barH);

    const gradient = canvas.createLinearGradient(barX, barY, barX + barW, barY);
    gradient.addColorStop(0, '#4CAF50');
    gradient.addColorStop(1, '#FFD700');
    canvas.fillStyle = gradient;
    canvas.fillRect(barX, barY, barW * progress, barH);

    canvas.strokeStyle = 'rgba(255,255,255,0.35)';
    canvas.lineWidth = 1;
    canvas.strokeRect(barX, barY, barW, barH);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = '20px sans-serif';
    if (isMaxLevel) {
      canvas.fillText('已达神龙', barX + barW + 8, barY - 1);
    } else {
      canvas.fillText(`${Math.floor(progress * 100)}%`, barX + barW + 10, barY - 1);
    }
  }

  private drawJoystick(canvas: CanvasRenderingContext2D, joystickState?: JoystickRenderState): void {
    if (!joystickState || !joystickState.active) {
      return;
    }

    const baseRadius = 42;
    const handleRadius = 24;

    // 计算摇杆强度用于视觉反馈
    const deltaX = joystickState.handleX - joystickState.centerX;
    const deltaY = joystickState.handleY - joystickState.centerY;
    const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
    const intensity = Math.min(1, distance / this.joystickMaxDistance);

    // 摇杆底座（添加外发光效果）
    const baseGlowRadius = baseRadius * (1 + intensity * 0.2);
    const baseGlowGradient = canvas.createRadialGradient(
      joystickState.centerX, joystickState.centerY, 0,
      joystickState.centerX, joystickState.centerY, baseGlowRadius
    );
    baseGlowGradient.addColorStop(0, 'rgba(255, 255, 255, 0.15)');
    baseGlowGradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
    canvas.fillStyle = baseGlowGradient;
    canvas.beginPath();
    canvas.arc(joystickState.centerX, joystickState.centerY, baseGlowRadius, 0, Math.PI * 2);
    canvas.fill();

    // 摇杆底座
    canvas.fillStyle = 'rgba(255, 255, 255, 0.15)';
    canvas.beginPath();
    canvas.arc(joystickState.centerX, joystickState.centerY, baseRadius, 0, Math.PI * 2);
    canvas.fill();

    canvas.strokeStyle = 'rgba(255, 255, 255, 0.4)';
    canvas.lineWidth = 2.5;
    canvas.beginPath();
    canvas.arc(joystickState.centerX, joystickState.centerY, baseRadius, 0, Math.PI * 2);
    canvas.stroke();

    // 摇杆连线（增强效果）
    canvas.strokeStyle = `rgba(255, 255, 255, ${0.45 + intensity * 0.3})`;
    canvas.lineWidth = 3 + intensity * 2;
    canvas.beginPath();
    canvas.moveTo(joystickState.centerX, joystickState.centerY);
    canvas.lineTo(joystickState.handleX, joystickState.handleY);
    canvas.stroke();

    // 摇杆手柄（增强效果）
    const handlePulse = Math.sin(this.animTime / 200) * 0.05 + 1;
    const handleActualRadius = handleRadius * (1 + intensity * 0.1) * handlePulse;
    const handleGradient = canvas.createRadialGradient(
      joystickState.handleX,
      joystickState.handleY,
      4,
      joystickState.handleX,
      joystickState.handleY,
      handleActualRadius
    );
    handleGradient.addColorStop(0, 'rgba(255,255,255,0.98)');
    handleGradient.addColorStop(1, `rgba(173,216,230,${0.85 + intensity * 0.15})`);
    canvas.fillStyle = handleGradient;
    canvas.beginPath();
    canvas.arc(joystickState.handleX, joystickState.handleY, handleActualRadius, 0, Math.PI * 2);
    canvas.fill();

    // 手柄边框
    canvas.strokeStyle = 'rgba(255, 255, 255, 0.5)';
    canvas.lineWidth = 2;
    canvas.beginPath();
    canvas.arc(joystickState.handleX, joystickState.handleY, handleActualRadius, 0, Math.PI * 2);
    canvas.stroke();
  }

  private drawStartPrompt(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.6)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 添加边框
    canvas.strokeStyle = 'rgba(255, 215, 0, 0.3)';
    canvas.lineWidth = 4;
    canvas.strokeRect(20, 20, this.canvasWidth - 40, this.canvasHeight - 40);

    // 添加脉冲动画
    const pulse = Math.sin(this.animTime / 300) * 0.1 + 1;
    canvas.fillStyle = '#FFFFFF';
    canvas.font = `bold ${Math.floor(76 * pulse)}px sans-serif`;
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
      canvas.font = 'bold 72px sans-serif';
      canvas.fillText('🐉 恭喜你召唤出神龙! 🐉', this.canvasWidth / 2, this.canvasHeight / 2 - 80);
    } else {
      // 失败
      canvas.fillStyle = '#FF6B6B';
      canvas.font = 'bold 72px sans-serif';
      canvas.fillText('游戏结束', this.canvasWidth / 2, this.canvasHeight / 2 - 80);
    }

    canvas.fillStyle = '#FFFFFF';
    canvas.font = '52px sans-serif';
    canvas.fillText(`最终分数: ${score}`, this.canvasWidth / 2, this.canvasHeight / 2 + 20);

    canvas.fillStyle = '#AAAAAA';
    canvas.font = '42px sans-serif';
    canvas.fillText('点击返回主菜单', this.canvasWidth / 2, this.canvasHeight / 2 + 100);
  }
}
