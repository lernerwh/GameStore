import { Player } from '../../../model/Player';
import { Creature } from '../../../model/Creature';
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
  private targetX: number = 0;
  private targetY: number = 0;

  follow(targetX: number, targetY: number): void {
    this.targetX = targetX - GameConstants.CANVAS_WIDTH / 2;
    this.targetY = targetY - GameConstants.CANVAS_HEIGHT / 2;

    // 限制摄像机在世界范围内
    this.targetX = Math.max(0, Math.min(this.targetX, GameConstants.WORLD_WIDTH - GameConstants.CANVAS_WIDTH));
    this.targetY = Math.max(0, Math.min(this.targetY, GameConstants.WORLD_HEIGHT - GameConstants.CANVAS_HEIGHT));
  }

  update(): void {
    // 平滑跟随
    this.x += (this.targetX - this.x) * GameConstants.CAMERA_FOLLOW_SPEED;
    this.y += (this.targetY - this.y) * GameConstants.CAMERA_FOLLOW_SPEED;
  }

  worldToScreen(worldX: number, worldY: number): Point {
    const result: Point = { x: worldX - this.x, y: worldY - this.y };
    return result;
  }

  screenToWorld(screenX: number, screenY: number): Point {
    const result: Point = { x: screenX + this.x, y: screenY + this.y };
    return result;
  }
}

/**
 * 游戏引擎 - 召唤神龙核心逻辑
 */
export class GameEngine {
  private player: Player;
  private creatures: Creature[] = [];
  private gameState: GameState;
  private score: number = 0;
  private playTime: number = 0;
  private hasWon: boolean = false;
  private camera: Camera = new Camera();
  private spawnTimer: number = 0;

  constructor() {
    this.player = new Player();
    this.gameState = GameState.IDLE;
    this.initCreatures();
  }

  getPlayer(): Player {
    return this.player;
  }

  getCreatures(): Creature[] {
    return this.creatures;
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
    this.score = 0;
    this.playTime = 0;
    this.hasWon = false;
    this.creatures = [];
    this.initCreatures();
  }

  private initCreatures(): void {
    for (let i = 0; i < GameConstants.CREATURE_COUNT; i++) {
      this.spawnCreature();
    }
  }

  private spawnCreature(): void {
    const creature = new Creature();
    // 随机生成在世界上，但不要在玩家初始位置附近
    creature.x = Math.random() * GameConstants.WORLD_WIDTH;
    creature.y = Math.random() * GameConstants.WORLD_HEIGHT;
    this.creatures.push(creature);
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
    this.camera.follow(this.player.x, this.player.y);
    this.camera.update();

    // 更新生物
    for (const creature of this.creatures) {
      creature.update(deltaTime);
    }

    // 检查碰撞
    this.checkCollisions();

    // 检查进化
    this.checkEvolution();

    // 定期生成新生物
    this.spawnTimer += deltaTime * 1000;
    if (this.spawnTimer >= GameConstants.CREATURE_SPAWN_INTERVAL && this.creatures.length < GameConstants.CREATURE_COUNT * 1.5) {
      this.spawnCreature();
      this.spawnTimer = 0;
    }

    // 检查胜利条件
    if (this.player.evolutionLevel >= GameConstants.EVOLUTION_NAMES.length - 1) {
      this.hasWon = true;
      this.gameState = GameState.GAME_OVER;
    }
  }

  private checkCollisions(): void {
    const playerRadius = this.player.getRadius();

    for (let i = this.creatures.length - 1; i >= 0; i--) {
      const creature = this.creatures[i];
      const dx = this.player.x - creature.x;
      const dy = this.player.y - creature.y;
      const distance = Math.sqrt(dx * dx + dy * dy);
      const creatureRadius = creature.getRadius();

      if (distance < playerRadius + creatureRadius) {
        if (creature.evolutionLevel <= this.player.evolutionLevel) {
          // 吃掉生物
          this.score += (creature.evolutionLevel + 1) * 10;
          this.creatures.splice(i, 1);
        } else {
          // 被吃掉，游戏结束
          this.gameState = GameState.GAME_OVER;
          return;
        }
      }
    }
  }

  private checkEvolution(): void {
    const currentLevel = this.player.evolutionLevel;
    if (currentLevel < GameConstants.EVOLUTION_SCORES.length - 1) {
      const nextLevelScore = GameConstants.EVOLUTION_SCORES[currentLevel + 1];
      if (this.score >= nextLevelScore) {
        this.player.evolutionLevel = currentLevel + 1;
      }
    }
  }

  reset(): void {
    this.player.reset();
    this.score = 0;
    this.playTime = 0;
    this.hasWon = false;
    this.gameState = GameState.IDLE;
    this.creatures = [];
    this.spawnTimer = 0;
    this.camera = new Camera();
  }
}
