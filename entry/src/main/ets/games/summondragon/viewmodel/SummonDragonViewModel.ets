import { GameState } from '../../../model/GameState';
import {
  SummonDragonEngine,
  SummonNpc,
  SummonRenderCompanion,
  SummonCamera,
  SummonPoint
} from './SummonDragonEngine';

export class SummonDragonViewModel {
  private engine: SummonDragonEngine = new SummonDragonEngine();

  gameState: GameState = GameState.IDLE;
  playTime: number = 0;
  playerLevel: number = 0;
  absorbedCount: number = 0;

  private intervalId: number | null = null;
  private lastFrameTime: number = 0;
  private readonly FRAME_TIME: number = 1000 / 60;

  get canvasWidth(): number {
    return this.engine.CANVAS_WIDTH;
  }

  get canvasHeight(): number {
    return this.engine.CANVAS_HEIGHT;
  }

  get npcs(): SummonNpc[] {
    return this.engine.getNpcs();
  }

  get companions(): SummonRenderCompanion[] {
    return this.engine.getCompanionRenderList();
  }

  get playerPos(): SummonPoint {
    return this.engine.getPlayerPosition();
  }

  get playerRadius(): number {
    return this.engine.getPlayerRadius();
  }

  get camera(): SummonCamera {
    return this.engine.getCamera();
  }

  startGame(): void {
    this.engine.startGame();
    this.syncState();
    this.startLoop();
  }

  setPlayerTarget(screenX: number, screenY: number): void {
    const world = this.engine.getCamera().screenToWorld(screenX, screenY);
    this.engine.setPlayerTargetWorld(world.x, world.y);
  }

  setPlayerDirectionInput(deltaX: number, deltaY: number, strength: number): void {
    const len = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
    if (len < 1) {
      return;
    }

    const nx = deltaX / len;
    const ny = deltaY / len;
    const clamped = Math.max(0, Math.min(1, strength));
    const zoomComp = 1 / Math.max(0.35, this.engine.getCamera().zoom);
    const targetOffset = (130 + clamped * 420) * zoomComp;
    const p = this.engine.getPlayerPosition();

    this.engine.setPlayerTargetWorld(
      p.x + nx * targetOffset,
      p.y + ny * targetOffset
    );
  }

  destroy(): void {
    this.stopLoop();
    this.engine.reset();
  }

  private startLoop(): void {
    this.stopLoop();
    this.lastFrameTime = Date.now();
    this.intervalId = setInterval(() => {
      this.tick();
    }, this.FRAME_TIME);
  }

  private stopLoop(): void {
    if (this.intervalId !== null) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  private tick(): void {
    const now = Date.now();
    const delta = Math.min(0.1, (now - this.lastFrameTime) / 1000);
    this.lastFrameTime = now;

    this.engine.update(delta);
    this.syncState();

    if (this.gameState === GameState.GAME_OVER) {
      this.stopLoop();
    }
  }

  private syncState(): void {
    this.gameState = this.engine.getGameState();
    this.playTime = this.engine.getPlayTime();
    this.playerLevel = this.engine.getPlayerLevel();
    this.absorbedCount = this.engine.getAbsorbedCount();
  }
}
