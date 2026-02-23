import { Player } from '../../../model/Player';
import { Creature } from '../../../model/Creature';
import { Pellet } from '../../../model/Pellet';
import { GameState } from '../../../model/GameState';
import { GameConstants } from '../../../common/constants/GameConstants';
import { Camera, Point } from '../viewmodel/GameEngine';
import { ImageManager } from '../../../common/utils/ImageManager';

interface Cloud {
  x: number;
  y: number;
  r: number;
  speed: number;
  alpha: number;
}

/**
 * 游戏渲染器 - 经典召唤神龙风格
 */
export class GameRenderer {
  private canvasWidth: number = GameConstants.CANVAS_WIDTH;
  private canvasHeight: number = GameConstants.CANVAS_HEIGHT;
  private animTime: number = 0;
  private clouds: Cloud[] = [];

  constructor() {
    this.initClouds();
  }

  render(
    canvas: CanvasRenderingContext2D,
    player: Player,
    creatures: Creature[],
    pellets: Pellet[],
    score: number,
    gameState: GameState,
    hasWon: boolean,
    playTime: number,
    camera: Camera
  ): void {
    this.animTime = Date.now();
    this.clearCanvas(canvas);
    this.drawBackground(canvas);

    if (gameState === GameState.PLAYING || gameState === GameState.GAME_OVER) {
      this.drawClouds(canvas);
      this.drawPellets(canvas, pellets, camera);
      this.drawCreatures(canvas, creatures, camera);
      this.drawPlayer(canvas, player, camera);
    }

    if (gameState === GameState.IDLE) {
      this.drawIdlePrompt(canvas);
    }
  }

  private clearCanvas(canvas: CanvasRenderingContext2D): void {
    canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private initClouds(): void {
    this.clouds = [];
    for (let i = 0; i < 8; i++) {
      this.clouds.push({
        x: Math.random() * this.canvasWidth,
        y: Math.random() * this.canvasHeight,
        r: 24 + Math.random() * 42,
        speed: 0.08 + Math.random() * 0.2,
        alpha: 0.15 + Math.random() * 0.2
      });
    }
  }

  private drawBackground(canvas: CanvasRenderingContext2D): void {
    const gradient = canvas.createLinearGradient(0, 0, 0, this.canvasHeight);
    gradient.addColorStop(0, '#8ec6ef');
    gradient.addColorStop(0.6, '#8cc3eb');
    gradient.addColorStop(1, '#87bee6');
    canvas.fillStyle = gradient;
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private drawClouds(canvas: CanvasRenderingContext2D): void {
    for (const cloud of this.clouds) {
      cloud.x += cloud.speed;
      if (cloud.x - cloud.r > this.canvasWidth + 40) {
        cloud.x = -cloud.r - 40;
        cloud.y = Math.random() * this.canvasHeight;
      }

      const gradient = canvas.createRadialGradient(
        cloud.x,
        cloud.y,
        cloud.r * 0.2,
        cloud.x,
        cloud.y,
        cloud.r
      );
      gradient.addColorStop(0, `rgba(255,255,255,${cloud.alpha})`);
      gradient.addColorStop(1, 'rgba(255,255,255,0)');

      canvas.fillStyle = gradient;
      canvas.beginPath();
      canvas.arc(cloud.x, cloud.y, cloud.r, 0, Math.PI * 2);
      canvas.fill();
    }
  }

  private drawPlayer(canvas: CanvasRenderingContext2D, player: Player, camera: Camera): void {
    const screenPos: Point = camera.worldToScreen(player.x, player.y);
    const radius = camera.worldLengthToScreen(player.getRadius());
    const imageManager = ImageManager.getInstance();
    const imageKey = imageManager.getPlayerImageKey(player.evolutionLevel);
    const cachedImage = imageManager.getCachedImage(imageKey);

    if (cachedImage) {
      const imageSize = radius * 4.6;
      canvas.drawImage(
        cachedImage,
        screenPos.x - imageSize / 2,
        screenPos.y - imageSize / 2,
        imageSize,
        imageSize
      );
      return;
    }

    canvas.fillStyle = '#f29f56';
    canvas.beginPath();
    canvas.arc(screenPos.x, screenPos.y, radius, 0, Math.PI * 2);
    canvas.fill();
  }

  private drawCreatures(canvas: CanvasRenderingContext2D, creatures: Creature[], camera: Camera): void {
    const imageManager = ImageManager.getInstance();

    for (const creature of creatures) {
      const screenPos: Point = camera.worldToScreen(creature.x, creature.y);
      const radius = camera.worldLengthToScreen(creature.getRadius());

      if (screenPos.x + radius < -20 || screenPos.x - radius > this.canvasWidth + 20 ||
        screenPos.y + radius < -20 || screenPos.y - radius > this.canvasHeight + 20) {
        continue;
      }

      const imageKey = imageManager.getCreatureImageKey(creature.evolutionLevel);
      const cachedImage = imageManager.getCachedImage(imageKey);

      if (cachedImage) {
        const imageSize = radius * 4.6;
        canvas.drawImage(
          cachedImage,
          screenPos.x - imageSize / 2,
          screenPos.y - imageSize / 2,
          imageSize,
          imageSize
        );
      } else {
        canvas.fillStyle = creature.getColor();
        canvas.beginPath();
        canvas.arc(screenPos.x, screenPos.y, radius, 0, Math.PI * 2);
        canvas.fill();
      }
    }
  }

  private drawPellets(canvas: CanvasRenderingContext2D, pellets: Pellet[], camera: Camera): void {
    for (const pellet of pellets) {
      const screenPos: Point = camera.worldToScreen(pellet.x, pellet.y);
      const radius = Math.max(1.5, camera.worldLengthToScreen(pellet.radius));

      if (screenPos.x + radius < -4 || screenPos.x - radius > this.canvasWidth + 4 ||
        screenPos.y + radius < -4 || screenPos.y - radius > this.canvasHeight + 4) {
        continue;
      }

      const twinkle = 0.6 + (Math.sin((this.animTime + pellet.x + pellet.y) / 220) + 1) * 0.2;
      canvas.fillStyle = `rgba(255,255,255,${twinkle})`;
      canvas.beginPath();
      canvas.arc(screenPos.x, screenPos.y, radius, 0, Math.PI * 2);
      canvas.fill();

      canvas.fillStyle = `rgba(255,192,250,${twinkle * 0.35})`;
      canvas.beginPath();
      canvas.arc(screenPos.x + 1, screenPos.y - 1, radius * 1.8, 0, Math.PI * 2);
      canvas.fill();
    }
  }

  private drawIdlePrompt(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = 'rgba(255, 255, 255, 0.15)';
    canvas.font = 'bold 20px sans-serif';
    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';
    canvas.fillText('点击开始游戏', this.canvasWidth / 2, this.canvasHeight / 2);
  }
}
