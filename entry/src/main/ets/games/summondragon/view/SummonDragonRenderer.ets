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

interface MistPatch {
  x: number;
  y: number;
  r: number;
  alpha: number;
}

interface Twinkle {
  x: number;
  y: number;
  size: number;
  phase: number;
}

interface CloudAnchor {
  x: number;
  y: number;
}

export class SummonDragonRenderer {
  private canvasWidth: number;
  private canvasHeight: number;
  private animTime: number = 0;
  private clouds: Cloud[] = [];
  private mistPatches: MistPatch[] = [];
  private twinkles: Twinkle[] = [];

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
    gradient.addColorStop(0, '#9dcdf1');
    gradient.addColorStop(0.55, '#8fc4eb');
    gradient.addColorStop(1, '#86bce4');
    canvas.fillStyle = gradient;
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    this.drawMistPatches(canvas);
  }

  private initClouds(): void {
    this.clouds = [];
    for (let i = 0; i < 10; i++) {
      this.clouds.push({
        x: Math.random() * this.canvasWidth,
        y: Math.random() * this.canvasHeight,
        r: 24 + Math.random() * 38,
        speed: 0.06 + Math.random() * 0.12,
        alpha: 0.09 + Math.random() * 0.13
      });
    }

    this.mistPatches = [];
    for (let i = 0; i < 16; i++) {
      this.mistPatches.push({
        x: Math.random() * this.canvasWidth,
        y: Math.random() * this.canvasHeight,
        r: 46 + Math.random() * 92,
        alpha: 0.045 + Math.random() * 0.08
      });
    }

    this.twinkles = [];
    for (let i = 0; i < 24; i++) {
      this.twinkles.push({
        x: Math.random() * this.canvasWidth,
        y: Math.random() * this.canvasHeight,
        size: 1.3 + Math.random() * 2.6,
        phase: Math.random() * Math.PI * 2
      });
    }
  }

  private drawMistPatches(canvas: CanvasRenderingContext2D): void {
    for (const m of this.mistPatches) {
      const g = canvas.createRadialGradient(m.x, m.y, m.r * 0.2, m.x, m.y, m.r);
      g.addColorStop(0, `rgba(255,255,255,${m.alpha})`);
      g.addColorStop(1, 'rgba(255,255,255,0)');
      canvas.fillStyle = g;
      canvas.beginPath();
      canvas.arc(m.x, m.y, m.r, 0, Math.PI * 2);
      canvas.fill();
    }
  }

  private drawClouds(canvas: CanvasRenderingContext2D): void {
    const t = this.animTime / 1000;

    for (const c of this.clouds) {
      c.x += c.speed;
      if (c.x - c.r > this.canvasWidth + 30) {
        c.x = -c.r - 30;
        c.y = Math.random() * this.canvasHeight;
      }

      const floatY = Math.sin(t * 0.36 + c.x * 0.01) * 2.4;
      const cx = c.x;
      const cy = c.y + floatY;

      const g = canvas.createRadialGradient(cx, cy, c.r * 0.2, cx, cy, c.r);
      g.addColorStop(0, `rgba(250,255,255,${c.alpha})`);
      g.addColorStop(1, 'rgba(255,255,255,0)');

      canvas.fillStyle = g;
      canvas.beginPath();
      canvas.arc(cx, cy, c.r, 0, Math.PI * 2);
      canvas.fill();
    }

    this.drawCloudForms(canvas, t);
    this.drawTwinkles(canvas, t);
  }

  private drawCloudForms(canvas: CanvasRenderingContext2D, t: number): void {
    const cloudAlpha = 0.2;
    const anchors: CloudAnchor[] = [
      { x: this.canvasWidth * 0.74, y: 130 },
      { x: this.canvasWidth * 0.3, y: 220 },
      { x: this.canvasWidth * 0.52, y: this.canvasHeight * 0.72 },
    ];

    for (let i = 0; i < anchors.length; i++) {
      const a = anchors[i];
      const driftX = Math.sin(t * 0.18 + i * 1.4) * 6;
      const driftY = Math.cos(t * 0.2 + i) * 4;
      const cx = a.x + driftX;
      const cy = a.y + driftY;

      canvas.fillStyle = `rgba(236, 252, 255, ${cloudAlpha})`;
      canvas.beginPath();
      canvas.arc(cx - 26, cy + 6, 18, 0, Math.PI * 2);
      canvas.arc(cx, cy, 23, 0, Math.PI * 2);
      canvas.arc(cx + 24, cy + 7, 17, 0, Math.PI * 2);
      canvas.fill();
    }

    // 底部轻雾云带，贴近参考图 4 的层状感
    const bandY = this.canvasHeight * 0.78 + Math.sin(t * 0.24) * 6;
    const g = canvas.createLinearGradient(0, bandY - 45, 0, bandY + 50);
    g.addColorStop(0, 'rgba(236,252,255,0)');
    g.addColorStop(0.5, 'rgba(236,252,255,0.18)');
    g.addColorStop(1, 'rgba(236,252,255,0)');
    canvas.fillStyle = g;
    canvas.fillRect(0, bandY - 45, this.canvasWidth, 95);
  }

  private drawTwinkles(canvas: CanvasRenderingContext2D, t: number): void {
    for (const s of this.twinkles) {
      const pulse = 0.4 + 0.6 * (Math.sin(t * 1.8 + s.phase) * 0.5 + 0.5);
      const alpha = 0.09 * pulse;

      canvas.fillStyle = `rgba(255,236,255,${alpha})`;
      canvas.beginPath();
      canvas.arc(s.x, s.y, s.size, 0, Math.PI * 2);
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
