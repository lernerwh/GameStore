import {
  SummonCamera,
  SummonNpc,
  SummonPoint,
  SummonRenderCompanion
} from '../viewmodel/SummonDragonEngine';
import { GameState } from '../../../model/GameState';
import { ImageManager } from '../../../common/utils/ImageManager';

interface Cloud {
  x: number;
  y: number;
  r: number;
  speed: number;
  alpha: number;
}

export class SummonDragonRenderer {
  private canvasWidth: number;
  private canvasHeight: number;
  private animTime: number = 0;
  private clouds: Cloud[] = [];

  constructor(canvasWidth: number, canvasHeight: number) {
    this.canvasWidth = canvasWidth;
    this.canvasHeight = canvasHeight;
    this.initClouds();
  }

  render(
    canvas: CanvasRenderingContext2D,
    gameState: GameState,
    playerPos: SummonPoint,
    playerLevel: number,
    playerRadius: number,
    npcs: SummonNpc[],
    companions: SummonRenderCompanion[],
    camera: SummonCamera
  ): void {
    this.animTime = Date.now();
    this.clear(canvas);
    this.drawBackground(canvas);

    if (gameState === GameState.PLAYING || gameState === GameState.GAME_OVER) {
      this.drawClouds(canvas);
      this.drawNpcs(canvas, npcs, camera);
      this.drawCompanions(canvas, companions, camera);
      this.drawPlayer(canvas, playerPos, playerLevel, playerRadius, camera);
    }
  }

  private clear(canvas: CanvasRenderingContext2D): void {
    canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private drawBackground(canvas: CanvasRenderingContext2D): void {
    const gradient = canvas.createLinearGradient(0, 0, 0, this.canvasHeight);
    gradient.addColorStop(0, '#8ec6ef');
    gradient.addColorStop(0.62, '#8cc3eb');
    gradient.addColorStop(1, '#87bee6');
    canvas.fillStyle = gradient;
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private initClouds(): void {
    this.clouds = [];
    for (let i = 0; i < 9; i++) {
      this.clouds.push({
        x: Math.random() * this.canvasWidth,
        y: Math.random() * this.canvasHeight,
        r: 22 + Math.random() * 44,
        speed: 0.07 + Math.random() * 0.2,
        alpha: 0.12 + Math.random() * 0.2
      });
    }
  }

  private drawClouds(canvas: CanvasRenderingContext2D): void {
    for (const c of this.clouds) {
      c.x += c.speed;
      if (c.x - c.r > this.canvasWidth + 30) {
        c.x = -c.r - 30;
        c.y = Math.random() * this.canvasHeight;
      }

      const g = canvas.createRadialGradient(c.x, c.y, c.r * 0.2, c.x, c.y, c.r);
      g.addColorStop(0, `rgba(255,255,255,${c.alpha})`);
      g.addColorStop(1, 'rgba(255,255,255,0)');

      canvas.fillStyle = g;
      canvas.beginPath();
      canvas.arc(c.x, c.y, c.r, 0, Math.PI * 2);
      canvas.fill();
    }
  }

  private drawPlayer(
    canvas: CanvasRenderingContext2D,
    playerPos: SummonPoint,
    playerLevel: number,
    playerRadius: number,
    camera: SummonCamera
  ): void {
    const s = camera.worldToScreen(playerPos.x, playerPos.y);
    this.drawActorByLevel(canvas, s.x, s.y, playerLevel, playerRadius * 2.25 * camera.zoom, true);
  }

  private drawNpcs(canvas: CanvasRenderingContext2D, npcs: SummonNpc[], camera: SummonCamera): void {
    const margin = 120;
    for (let i = 0; i < npcs.length; i++) {
      const n = npcs[i];
      const s = camera.worldToScreen(n.x, n.y);
      if (s.x < -margin || s.x > this.canvasWidth + margin || s.y < -margin || s.y > this.canvasHeight + margin) {
        continue;
      }
      const size = this.levelToSize(n.level) * camera.zoom;
      this.drawActorByLevel(canvas, s.x, s.y, n.level, size, false);
    }
  }

  private drawCompanions(canvas: CanvasRenderingContext2D, companions: SummonRenderCompanion[], camera: SummonCamera): void {
    const margin = 120;
    for (let i = 0; i < companions.length; i++) {
      const c = companions[i];
      const s = camera.worldToScreen(c.x, c.y);
      if (s.x < -margin || s.x > this.canvasWidth + margin || s.y < -margin || s.y > this.canvasHeight + margin) {
        continue;
      }
      const size = this.levelToSize(c.level) * 0.92 * camera.zoom;
      this.drawActorByLevel(canvas, s.x, s.y, c.level, size, false);
    }
  }

  private drawActorByLevel(
    canvas: CanvasRenderingContext2D,
    x: number,
    y: number,
    level: number,
    size: number,
    isPlayer: boolean
  ): void {
    const imageManager = ImageManager.getInstance();
    const imageKey = isPlayer ? imageManager.getPlayerImageKey(level) : imageManager.getCreatureImageKey(level);
    const image = imageManager.getCachedImage(imageKey);

    if (image) {
      canvas.drawImage(image, x - size / 2, y - size / 2, size, size);
      return;
    }

    const hue = (level * 36) % 360;
    canvas.fillStyle = `hsl(${hue}, 70%, ${isPlayer ? 62 : 52}%)`;
    canvas.beginPath();
    canvas.arc(x, y, size * 0.32, 0, Math.PI * 2);
    canvas.fill();
  }

  private levelToSize(level: number): number {
    const base = [24, 32, 44, 58, 76, 100, 130, 168, 214, 270];
    const idx = Math.max(0, Math.min(base.length - 1, level));
    return base[idx];
  }
}
