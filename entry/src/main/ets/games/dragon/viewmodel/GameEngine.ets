import { Player } from '../../../model/Player';
import { Creature } from '../../../model/Creature';
import { Pellet } from '../../../model/Pellet';
import { GameState } from '../../../model/GameState';
import { GameConstants } from '../../../common/constants/GameConstants';

/**
 * 坐标点接口
 */
export interface Point {
  x: number;
  y: number;
}

/**
 * 摄像机类 - 管理视角
 */
export class Camera {
  x: number = 0;
  y: number = 0;
  zoom: number = 1;
  private targetX: number = 0;
  private targetY: number = 0;
  private targetZoom: number = 1;

  follow(targetX: number, targetY: number, targetRadius: number): void {
    this.targetZoom = this.calculateTargetZoom(targetRadius);
    const viewportWidth = this.getViewportWidthByZoom(this.targetZoom);
    const viewportHeight = this.getViewportHeightByZoom(this.targetZoom);
    this.targetX = targetX - viewportWidth / 2;
    this.targetY = targetY - viewportHeight / 2;

    // 限制摄像机在世界范围内
    this.targetX = Math.max(0, Math.min(this.targetX, GameConstants.WORLD_WIDTH - viewportWidth));
    this.targetY = Math.max(0, Math.min(this.targetY, GameConstants.WORLD_HEIGHT - viewportHeight));
  }

  update(): void {
    // 平滑跟随
    this.x += (this.targetX - this.x) * GameConstants.CAMERA_FOLLOW_SPEED;
    this.y += (this.targetY - this.y) * GameConstants.CAMERA_FOLLOW_SPEED;
    this.zoom += (this.targetZoom - this.zoom) * GameConstants.CAMERA_ZOOM_LERP_SPEED;
  }

  worldToScreen(worldX: number, worldY: number): Point {
    const result: Point = { x: (worldX - this.x) / this.zoom, y: (worldY - this.y) / this.zoom };
    return result;
  }

  screenToWorld(screenX: number, screenY: number): Point {
    const result: Point = { x: screenX * this.zoom + this.x, y: screenY * this.zoom + this.y };
    return result;
  }

  worldLengthToScreen(worldLength: number): number {
    return worldLength / this.zoom;
  }

  getViewportWidth(): number {
    return this.getViewportWidthByZoom(this.zoom);
  }

  getViewportHeight(): number {
    return this.getViewportHeightByZoom(this.zoom);
  }

  private calculateTargetZoom(targetRadius: number): number {
    const radiusDelta = Math.max(0, targetRadius - GameConstants.CAMERA_BASE_RADIUS);
    const zoom = GameConstants.CAMERA_MIN_ZOOM + radiusDelta * GameConstants.CAMERA_ZOOM_RADIUS_FACTOR;
    return Math.max(GameConstants.CAMERA_MIN_ZOOM, Math.min(GameConstants.CAMERA_MAX_ZOOM, zoom));
  }

  private getViewportWidthByZoom(zoom: number): number {
    return GameConstants.CANVAS_WIDTH * zoom;
  }

  private getViewportHeightByZoom(zoom: number): number {
    return GameConstants.CANVAS_HEIGHT * zoom;
  }
}

/**
 * 游戏引擎 - 召唤神龙核心逻辑
 */
export class GameEngine {
  private player: Player;
  private creatures: Creature[] = [];
  private pellets: Pellet[] = [];
  private gameState: GameState;
  private score: number = 0;
  private playTime: number = 0;
  private hasWon: boolean = false;
  private camera: Camera = new Camera();
  private spawnTimer: number = 0;
  private pelletSpawnTimer: number = 0;

  constructor() {
    this.player = new Player();
    this.gameState = GameState.IDLE;
    this.score = GameConstants.PLAYER_INITIAL_SCORE;
    this.player.setScore(this.score);
    this.initCreatures();
    this.initPellets();
  }

  getPlayer(): Player {
    return this.player;
  }

  getCreatures(): Creature[] {
    return this.creatures;
  }

  getPellets(): Pellet[] {
    return this.pellets;
  }

  getGameState(): GameState {
    return this.gameState;
  }

  getScore(): number {
    return this.score;
  }

  getPlayTime(): number {
    return this.playTime;
  }

  hasPlayerWon(): boolean {
    return this.hasWon;
  }

  getCamera(): Camera {
    return this.camera;
  }

  startGame(): void {
    this.gameState = GameState.PLAYING;
    this.player.reset();
    this.score = GameConstants.PLAYER_INITIAL_SCORE;
    this.player.setScore(this.score);
    this.playTime = 0;
    this.hasWon = false;
    this.creatures = [];
    this.pellets = [];
    this.initCreatures();
    this.initPellets();
  }

  private initCreatures(): void {
    for (let i = 0; i < GameConstants.CREATURE_COUNT; i++) {
      this.spawnCreature();
    }
  }

  private initPellets(): void {
    for (let i = 0; i < GameConstants.PELLET_COUNT; i++) {
      this.spawnPellet();
    }
  }

  private spawnCreature(): void {
    const creature = new Creature();
    // 随机生成在世界上，但不要在玩家初始位置附近
    creature.x = Math.random() * GameConstants.WORLD_WIDTH;
    creature.y = Math.random() * GameConstants.WORLD_HEIGHT;
    this.creatures.push(creature);
  }

  private spawnPellet(): void {
    const pellet = new Pellet();
    pellet.x = Math.random() * GameConstants.WORLD_WIDTH;
    pellet.y = Math.random() * GameConstants.WORLD_HEIGHT;
    this.pellets.push(pellet);
  }

  setPlayerTarget(worldX: number, worldY: number): void {
    this.player.setTarget(worldX, worldY);
  }

  update(deltaTime: number): void {
    if (this.gameState !== GameState.PLAYING) {
      return;
    }

    this.playTime += deltaTime;
    this.player.update(deltaTime);
    this.camera.follow(this.player.x, this.player.y, this.player.getRadius());
    this.camera.update();

    // 更新生物
    for (const creature of this.creatures) {
      creature.update(deltaTime);
    }

    // NPC 之间互相吞噬
    this.checkCreatureCollisions();

    // 玩家/NPC 吞噬小豆豆
    this.checkPelletCollisions();

    // 检查玩家碰撞
    this.checkPlayerCollisions();

    // 玩家分数驱动线性体型与进化等级
    this.player.setScore(this.score);

    // 定期生成新生物
    this.spawnTimer += deltaTime * 1000;
    if (this.spawnTimer >= GameConstants.CREATURE_SPAWN_INTERVAL && this.creatures.length < GameConstants.CREATURE_MAX_COUNT) {
      const belowMin = Math.max(0, GameConstants.CREATURE_MIN_COUNT - this.creatures.length);
      const baseSpawn = 1 + Math.floor(Math.random() * 3); // 1~3 随机刷新
      const spawnCount = Math.min(
        GameConstants.CREATURE_MAX_COUNT - this.creatures.length,
        baseSpawn + Math.min(3, belowMin)
      );
      for (let i = 0; i < spawnCount; i++) {
        this.spawnCreature();
      }
      this.spawnTimer = 0;
    }
    this.pelletSpawnTimer += deltaTime * 1000;
    if (this.pelletSpawnTimer >= GameConstants.PELLET_SPAWN_INTERVAL &&
      this.pellets.length < GameConstants.PELLET_COUNT * 1.6) {
      this.spawnPellet();
      this.pelletSpawnTimer = 0;
    }

    // 到达神龙后继续探索，不再直接结束游戏
    if (this.score >= GameConstants.WIN_SCORE) {
      this.hasWon = true;
    }
  }

  private checkPlayerCollisions(): void {
    const playerRadius = this.player.getRadius();

    for (let i = this.creatures.length - 1; i >= 0; i--) {
      const creature = this.creatures[i];
      const dx = this.player.x - creature.x;
      const dy = this.player.y - creature.y;
      const distance = Math.sqrt(dx * dx + dy * dy);
      const creatureRadius = creature.getRadius();

      if (distance < playerRadius + creatureRadius) {
        if (playerRadius >= creatureRadius * GameConstants.MIN_EAT_SIZE_RATIO &&
          this.canConsumeByOverlap(playerRadius, creatureRadius, distance)) {
          // 吃掉生物
          this.score += this.getEatGainScore(creature.score, GameConstants.PLAYER_EAT_SCORE_RATIO);
          this.creatures.splice(i, 1);
        } else if (creatureRadius >= playerRadius * GameConstants.MIN_EAT_SIZE_RATIO &&
          this.canConsumeByOverlap(creatureRadius, playerRadius, distance)) {
          // 被吃掉，游戏结束
          this.gameState = GameState.GAME_OVER;
          return;
        }
      }
    }
  }

  private checkCreatureCollisions(): void {
    let i = 0;
    while (i < this.creatures.length) {
      let iRemoved = false;
      let j = i + 1;

      while (j < this.creatures.length) {
        const a = this.creatures[i];
        const b = this.creatures[j];
        const dx = a.x - b.x;
        const dy = a.y - b.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        const aRadius = a.getRadius();
        const bRadius = b.getRadius();

        if (distance < aRadius + bRadius) {
          if (aRadius >= bRadius * GameConstants.MIN_EAT_SIZE_RATIO &&
            this.canConsumeByOverlap(aRadius, bRadius, distance)) {
            a.addScore(this.getEatGainScore(b.score, GameConstants.NPC_EAT_SCORE_RATIO));
            this.creatures.splice(j, 1);
            continue;
          } else if (bRadius >= aRadius * GameConstants.MIN_EAT_SIZE_RATIO &&
            this.canConsumeByOverlap(bRadius, aRadius, distance)) {
            b.addScore(this.getEatGainScore(a.score, GameConstants.NPC_EAT_SCORE_RATIO));
            this.creatures.splice(i, 1);
            iRemoved = true;
            break;
          }
        }
        j++;
      }

      if (!iRemoved) {
        i++;
      }
    }
  }

  private checkPelletCollisions(): void {
    for (let i = this.pellets.length - 1; i >= 0; i--) {
      const pellet = this.pellets[i];
      let eaten = false;

      const pdx = this.player.x - pellet.x;
      const pdy = this.player.y - pellet.y;
      const playerDistance = Math.sqrt(pdx * pdx + pdy * pdy);
      if (this.canConsumeByOverlap(this.player.getRadius(), pellet.radius, playerDistance)) {
        this.score += pellet.scoreValue;
        this.pellets.splice(i, 1);
        continue;
      }

      for (const creature of this.creatures) {
        const dx = creature.x - pellet.x;
        const dy = creature.y - pellet.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        if (this.canConsumeByOverlap(creature.getRadius(), pellet.radius, distance)) {
          creature.addScore(pellet.scoreValue);
          eaten = true;
          break;
        }
      }

      if (eaten) {
        this.pellets.splice(i, 1);
      }
    }
  }

  private getEatGainScore(targetScore: number, ratio: number): number {
    const gain = Math.floor(targetScore * ratio);
    return Math.max(1, gain);
  }

  private canConsumeByOverlap(predatorRadius: number, preyRadius: number, distance: number): boolean {
    if (distance >= predatorRadius + preyRadius) {
      return false;
    }
    const overlapArea = this.calculateCircleOverlapArea(predatorRadius, preyRadius, distance);
    const preyArea = Math.PI * preyRadius * preyRadius;
    return overlapArea >= preyArea * 0.5;
  }

  private calculateCircleOverlapArea(r1: number, r2: number, d: number): number {
    if (d >= r1 + r2) {
      return 0;
    }
    if (d <= Math.abs(r1 - r2)) {
      const minR = Math.min(r1, r2);
      return Math.PI * minR * minR;
    }
    const alpha = Math.acos((d * d + r1 * r1 - r2 * r2) / (2 * d * r1));
    const beta = Math.acos((d * d + r2 * r2 - r1 * r1) / (2 * d * r2));
    const area1 = r1 * r1 * alpha;
    const area2 = r2 * r2 * beta;
    const area3 = 0.5 * Math.sqrt(
      Math.max(0, (-d + r1 + r2) * (d + r1 - r2) * (d - r1 + r2) * (d + r1 + r2))
    );
    return area1 + area2 - area3;
  }

  reset(): void {
    this.player.reset();
    this.score = GameConstants.PLAYER_INITIAL_SCORE;
    this.player.setScore(this.score);
    this.playTime = 0;
    this.hasWon = false;
    this.gameState = GameState.IDLE;
    this.creatures = [];
    this.pellets = [];
    this.spawnTimer = 0;
    this.pelletSpawnTimer = 0;
    this.camera = new Camera();
  }
}
