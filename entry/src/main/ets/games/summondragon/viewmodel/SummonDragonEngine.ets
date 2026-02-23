import { GameState } from '../../../model/GameState';

export interface SummonPoint {
  x: number;
  y: number;
}

export interface SummonNpc {
  id: number;
  x: number;
  y: number;
  vx: number;
  vy: number;
  level: number;
}

export interface SummonCompanion {
  id: number;
  level: number;
  seed: number;
}

export interface SummonRenderCompanion {
  x: number;
  y: number;
  level: number;
}

export class SummonCamera {
  x: number = 0;
  y: number = 0;
  zoom: number = 1;

  private viewportWidth: number;
  private viewportHeight: number;
  private worldWidth: number;
  private worldHeight: number;

  private targetX: number = 0;
  private targetY: number = 0;
  private targetZoom: number = 1;

  constructor(viewportWidth: number, viewportHeight: number, worldWidth: number, worldHeight: number) {
    this.viewportWidth = viewportWidth;
    this.viewportHeight = viewportHeight;
    this.worldWidth = worldWidth;
    this.worldHeight = worldHeight;
  }

  setZoom(zoom: number): void {
    this.targetZoom = Math.max(0.2, Math.min(1, zoom));
  }

  follow(targetX: number, targetY: number): void {
    const visibleWidth = this.viewportWidth / this.zoom;
    const visibleHeight = this.viewportHeight / this.zoom;

    this.targetX = targetX - visibleWidth / 2;
    this.targetY = targetY - visibleHeight / 2;

    this.targetX = Math.max(0, Math.min(this.targetX, this.worldWidth - visibleWidth));
    this.targetY = Math.max(0, Math.min(this.targetY, this.worldHeight - visibleHeight));
  }

  update(): void {
    this.zoom += (this.targetZoom - this.zoom) * 0.08;
    this.x += (this.targetX - this.x) * 0.12;
    this.y += (this.targetY - this.y) * 0.12;
  }

  worldToScreen(worldX: number, worldY: number): SummonPoint {
    return { x: (worldX - this.x) * this.zoom, y: (worldY - this.y) * this.zoom };
  }

  screenToWorld(screenX: number, screenY: number): SummonPoint {
    return { x: screenX / this.zoom + this.x, y: screenY / this.zoom + this.y };
  }
}

export class SummonDragonEngine {
  readonly CANVAS_WIDTH: number = 360;
  readonly CANVAS_HEIGHT: number = 760;
  readonly WORLD_WIDTH: number = 2000;
  readonly WORLD_HEIGHT: number = 3200;

  private readonly PLAYER_SPEED: number = 240;
  private readonly PLAYER_ACCEL: number = 1350;
  private readonly PLAYER_DRAG: number = 4.8;
  private readonly MAX_NPC: number = 55;
  private readonly MIN_NPC: number = 40;
  private readonly NPC_SPAWN_INTERVAL_MS: number = 900;
  private readonly START_SAFE_TIME_SEC: number = 2.2;

  private readonly LEVEL_RADII: number[] = [10, 14, 20, 26, 34, 46, 60, 78, 100, 128];
  // 分场景碰撞阈值，降低误判热区。
  private readonly COLLISION_PLAYER_ABSORB: number = 0.72;
  private readonly COLLISION_PLAYER_DIE: number = 0.58;
  private readonly COLLISION_NPC_NPC: number = 0.7;
  private readonly COLLISION_NPC_COMPANION: number = 0.68;

  private nextId: number = 1;
  private playerX: number = this.WORLD_WIDTH / 2;
  private playerY: number = this.WORLD_HEIGHT / 2;
  private playerVx: number = 0;
  private playerVy: number = 0;
  private playerTargetX: number = this.playerX;
  private playerTargetY: number = this.playerY;
  private playerLevel: number = 2;
  private safeTimeRemaining: number = 0;

  // 各等级单位数量，包含玩家本体。通过 3 合 1 规则演化。
  private teamCounts: number[] = new Array(10).fill(0);

  private npcs: SummonNpc[] = [];
  private companions: SummonCompanion[] = [];

  private gameState: GameState = GameState.IDLE;
  private playTime: number = 0;
  private spawnTimerMs: number = 0;

  private camera: SummonCamera = new SummonCamera(
    this.CANVAS_WIDTH,
    this.CANVAS_HEIGHT,
    this.WORLD_WIDTH,
    this.WORLD_HEIGHT
  );

  constructor() {
    this.resetWorld();
  }

  getGameState(): GameState {
    return this.gameState;
  }

  getPlayTime(): number {
    return this.playTime;
  }

  getPlayerLevel(): number {
    return this.playerLevel;
  }

  getAbsorbedCount(): number {
    let total = 0;
    for (let i = 0; i < this.teamCounts.length; i++) {
      total += this.teamCounts[i];
    }
    return Math.max(0, total - 1);
  }

  getPlayerPosition(): SummonPoint {
    return { x: this.playerX, y: this.playerY };
  }

  getPlayerRadius(): number {
    return this.LEVEL_RADII[this.playerLevel];
  }

  getNpcs(): SummonNpc[] {
    return this.npcs;
  }

  getCamera(): SummonCamera {
    return this.camera;
  }

  getCompanionRenderList(): SummonRenderCompanion[] {
    const out: SummonRenderCompanion[] = [];
    const now = Date.now() / 1000;

    for (let i = 0; i < this.companions.length; i++) {
      const c = this.companions[i];
      const row = Math.floor(i / 4);
      const col = i % 4;
      const baseX = (col - 1.5) * 34;
      const baseY = 44 + row * 28;
      const swayX = Math.sin(now * 2 + c.seed) * 4;
      const swayY = Math.cos(now * 2.2 + c.seed) * 3;
      out.push({
        x: this.playerX + baseX + swayX,
        y: this.playerY + baseY + swayY,
        level: c.level
      });
    }

    return out;
  }

  startGame(): void {
    this.resetWorld();
    this.gameState = GameState.PLAYING;
  }

  reset(): void {
    this.resetWorld();
    this.gameState = GameState.IDLE;
  }

  setPlayerTargetWorld(x: number, y: number): void {
    this.playerTargetX = x;
    this.playerTargetY = y;
  }

  update(deltaTime: number): void {
    if (this.gameState !== GameState.PLAYING) {
      return;
    }

    this.playTime += deltaTime;
    this.updatePlayer(deltaTime);
    this.updateNpcs(deltaTime);

    this.resolvePlayerNpcCollisions();
    if (this.gameState !== GameState.PLAYING) {
      return;
    }

    this.resolveNpcNpcCollisions();
    this.resolveNpcCompanionCollisions();

    this.spawnTimerMs += deltaTime * 1000;
    if (this.spawnTimerMs >= this.NPC_SPAWN_INTERVAL_MS) {
      this.spawnTimerMs = 0;
      this.ensureNpcCount();
    }

    this.camera.setZoom(this.getAutoCameraZoom());
    this.camera.follow(this.playerX, this.playerY);
    this.camera.update();
  }

  private resetWorld(): void {
    this.nextId = 1;
    this.playerX = this.WORLD_WIDTH / 2;
    this.playerY = this.WORLD_HEIGHT / 2;
    this.playerVx = 0;
    this.playerVy = 0;
    this.playerTargetX = this.playerX;
    this.playerTargetY = this.playerY;
    this.playerLevel = 2;
    this.safeTimeRemaining = this.START_SAFE_TIME_SEC;

    this.teamCounts = new Array(10).fill(0);
    this.teamCounts[this.playerLevel] = 1;

    this.npcs = [];
    this.companions = [];
    this.playTime = 0;
    this.spawnTimerMs = 0;
    this.camera = new SummonCamera(
      this.CANVAS_WIDTH,
      this.CANVAS_HEIGHT,
      this.WORLD_WIDTH,
      this.WORLD_HEIGHT
    );

    for (let i = 0; i < this.MIN_NPC; i++) {
      this.spawnNpc();
    }
    this.rebuildCompanions();
  }

  private updatePlayer(deltaTime: number): void {
    const dx = this.playerTargetX - this.playerX;
    const dy = this.playerTargetY - this.playerY;
    const d = Math.sqrt(dx * dx + dy * dy);
    if (d > 0.01) {
      const nx = dx / d;
      const ny = dy / d;
      const speedRatio = Math.min(1, d / 220);
      const desiredVx = nx * this.PLAYER_SPEED * speedRatio;
      const desiredVy = ny * this.PLAYER_SPEED * speedRatio;

      const lerp = Math.min(1, this.PLAYER_ACCEL * deltaTime / this.PLAYER_SPEED);
      this.playerVx += (desiredVx - this.playerVx) * lerp;
      this.playerVy += (desiredVy - this.playerVy) * lerp;
    } else {
      const drag = Math.max(0, 1 - this.PLAYER_DRAG * deltaTime);
      this.playerVx *= drag;
      this.playerVy *= drag;
    }

    this.playerX += this.playerVx * deltaTime;
    this.playerY += this.playerVy * deltaTime;

    const r = this.getPlayerRadius();
    const clampedX = Math.max(r, Math.min(this.WORLD_WIDTH - r, this.playerX));
    const clampedY = Math.max(r, Math.min(this.WORLD_HEIGHT - r, this.playerY));
    if (clampedX !== this.playerX) {
      this.playerVx = 0;
    }
    if (clampedY !== this.playerY) {
      this.playerVy = 0;
    }
    this.playerX = clampedX;
    this.playerY = clampedY;

    if (this.safeTimeRemaining > 0) {
      this.safeTimeRemaining = Math.max(0, this.safeTimeRemaining - deltaTime);
    }
  }

  private updateNpcs(deltaTime: number): void {
    for (let i = 0; i < this.npcs.length; i++) {
      const n = this.npcs[i];
      n.x += n.vx * deltaTime;
      n.y += n.vy * deltaTime;

      const r = this.LEVEL_RADII[n.level];

      if (n.x < r) {
        n.x = r;
        n.vx = Math.abs(n.vx);
      } else if (n.x > this.WORLD_WIDTH - r) {
        n.x = this.WORLD_WIDTH - r;
        n.vx = -Math.abs(n.vx);
      }

      if (n.y < r) {
        n.y = r;
        n.vy = Math.abs(n.vy);
      } else if (n.y > this.WORLD_HEIGHT - r) {
        n.y = this.WORLD_HEIGHT - r;
        n.vy = -Math.abs(n.vy);
      }
    }
  }

  private resolvePlayerNpcCollisions(): void {
    const pr = this.getPlayerRadius();

    for (let i = this.npcs.length - 1; i >= 0; i--) {
      const n = this.npcs[i];
      const nr = this.LEVEL_RADII[n.level];
      const dx = n.x - this.playerX;
      const dy = n.y - this.playerY;
      const d = Math.sqrt(dx * dx + dy * dy);

      if (n.level <= this.playerLevel) {
        if (d > (pr + nr) * this.COLLISION_PLAYER_ABSORB) {
          continue;
        }
        this.absorbNpc(n);
        this.npcs.splice(i, 1);
      } else {
        if (d > (pr + nr) * this.COLLISION_PLAYER_DIE || this.safeTimeRemaining > 0) {
          continue;
        }
        this.gameState = GameState.GAME_OVER;
        return;
      }
    }
  }

  private resolveNpcNpcCollisions(): void {
    const removed = new Set<number>();

    for (let i = 0; i < this.npcs.length; i++) {
      if (removed.has(i)) {
        continue;
      }
      for (let j = i + 1; j < this.npcs.length; j++) {
        if (removed.has(j)) {
          continue;
        }
        const a = this.npcs[i];
        const b = this.npcs[j];
        if (a.level === b.level) {
          continue;
        }

        const ar = this.LEVEL_RADII[a.level];
        const br = this.LEVEL_RADII[b.level];
        const dx = a.x - b.x;
        const dy = a.y - b.y;
        const d = Math.sqrt(dx * dx + dy * dy);
        if (d > (ar + br) * this.COLLISION_NPC_NPC) {
          continue;
        }

        if (a.level > b.level) {
          removed.add(j);
        } else {
          removed.add(i);
          break;
        }
      }
    }

    if (removed.size > 0) {
      this.npcs = this.npcs.filter((_, idx) => !removed.has(idx));
    }
  }

  private resolveNpcCompanionCollisions(): void {
    if (this.companions.length === 0 || this.npcs.length === 0) {
      return;
    }

    const compPos = this.getCompanionRenderList();
    const removeNpc = new Set<number>();
    const removeComp = new Set<number>();

    for (let i = 0; i < this.npcs.length; i++) {
      const npc = this.npcs[i];
      const nr = this.LEVEL_RADII[npc.level];

      for (let j = 0; j < compPos.length; j++) {
        if (removeComp.has(j)) {
          continue;
        }
        const cp = compPos[j];
        const cr = this.LEVEL_RADII[cp.level] * 0.92;
        const dx = npc.x - cp.x;
        const dy = npc.y - cp.y;
        const d = Math.sqrt(dx * dx + dy * dy);
        if (d > (nr + cr) * this.COLLISION_NPC_COMPANION) {
          continue;
        }

        if (npc.level > cp.level) {
          removeComp.add(j);
        } else if (npc.level < cp.level) {
          removeNpc.add(i);
          break;
        }
      }
    }

    if (removeNpc.size > 0) {
      this.npcs = this.npcs.filter((_, idx) => !removeNpc.has(idx));
    }

    if (removeComp.size > 0) {
      const removedLevels: number[] = [];
      for (const idx of removeComp.values()) {
        if (idx >= 0 && idx < this.companions.length) {
          removedLevels.push(this.companions[idx].level);
        }
      }
      for (let i = 0; i < removedLevels.length; i++) {
        const lv = removedLevels[i];
        if (this.teamCounts[lv] > 0) {
          this.teamCounts[lv] -= 1;
        }
      }
      this.normalizePlayerFromTeam();
      this.rebuildCompanions();
    }
  }

  private absorbNpc(npc: SummonNpc): void {
    this.teamCounts[npc.level] += 1;
    this.mergeTeamByThreeRule();
    this.normalizePlayerFromTeam();
    this.rebuildCompanions();
  }

  private mergeTeamByThreeRule(): void {
    // 连锁合并：同级单位数量>=3 时，3合1进阶。
    for (let level = 0; level < this.teamCounts.length - 1; level++) {
      while (this.teamCounts[level] >= 3) {
        this.teamCounts[level] -= 3;
        this.teamCounts[level + 1] += 1;
      }
    }
  }

  private normalizePlayerFromTeam(): void {
    let top = -1;
    for (let i = this.teamCounts.length - 1; i >= 0; i--) {
      if (this.teamCounts[i] > 0) {
        top = i;
        break;
      }
    }

    if (top < 0) {
      this.gameState = GameState.GAME_OVER;
      return;
    }

    this.playerLevel = top;

    // 保证玩家本体始终存在。
    if (this.teamCounts[this.playerLevel] < 1) {
      this.teamCounts[this.playerLevel] = 1;
    }
  }

  private rebuildCompanions(): void {
    const newCompanions: SummonCompanion[] = [];

    for (let level = 0; level < this.teamCounts.length; level++) {
      let count = this.teamCounts[level];

      // 玩家本体占用一个最高级单位，其余作为伴随生物并列显示。
      if (level === this.playerLevel) {
        count = Math.max(0, count - 1);
      }

      for (let i = 0; i < count; i++) {
        newCompanions.push({
          id: this.nextId++,
          level,
          seed: Math.random() * Math.PI * 2
        });
      }
    }

    this.companions = newCompanions;
  }

  private ensureNpcCount(): void {
    const target = this.MIN_NPC + Math.floor(Math.random() * 8);
    while (this.npcs.length < Math.min(this.MAX_NPC, target)) {
      this.spawnNpc();
    }
  }

  private spawnNpc(): void {
    const level = this.randomNpcLevel();
    const r = this.LEVEL_RADII[level];

    const npc: SummonNpc = {
      id: this.nextId++,
      x: r + Math.random() * (this.WORLD_WIDTH - 2 * r),
      y: r + Math.random() * (this.WORLD_HEIGHT - 2 * r),
      vx: 0,
      vy: 0,
      level
    };

    const speed = 36 + Math.random() * 54 - level * 1.5;
    const angle = Math.random() * Math.PI * 2;
    npc.vx = Math.cos(angle) * speed;
    npc.vy = Math.sin(angle) * speed;

    this.npcs.push(npc);
  }

  private randomNpcLevel(): number {
    const r = Math.random();
    if (r < 0.24) {
      return Math.floor(Math.random() * 3);
    }
    if (r < 0.48) {
      return 2 + Math.floor(Math.random() * 3);
    }
    if (r < 0.72) {
      return 4 + Math.floor(Math.random() * 3);
    }
    if (r < 0.9) {
      return 6 + Math.floor(Math.random() * 2);
    }
    return 8 + Math.floor(Math.random() * 2);
  }

  // 视野规则：等级越高、队伍规模越大，镜头越拉远（zoom 越小）。
  private getAutoCameraZoom(): number {
    const levelProgress = this.playerLevel / (this.LEVEL_RADII.length - 1);
    const groupProgress = Math.min(1, this.getAbsorbedCount() / 18);
    const progress = Math.max(levelProgress, levelProgress * 0.7 + groupProgress * 0.3);
    const minZoom = 0.3;
    return 1 - progress * (1 - minZoom);
  }
}
