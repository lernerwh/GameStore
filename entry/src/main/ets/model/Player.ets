import { GameConstants } from '../common/constants/GameConstants';

/**
 * 玩家实体类 - 召唤神龙
 */
export class Player {
  x: number;
  y: number;
  evolutionLevel: number = 0;
  private targetX: number = 0;
  private targetY: number = 0;
  private isMoving: boolean = false;

  constructor() {
    this.x = GameConstants.WORLD_WIDTH / 2;
    this.y = GameConstants.WORLD_HEIGHT / 2;
    this.evolutionLevel = 0;
  }

  getRadius(): number {
    return GameConstants.EVOLUTION_SIZES[this.evolutionLevel] / 2;
  }

  getColor(): string {
    return GameConstants.EVOLUTION_COLORS[this.evolutionLevel];
  }

  getName(): string {
    return GameConstants.EVOLUTION_NAMES[this.evolutionLevel];
  }

  setTarget(worldX: number, worldY: number): void {
    this.targetX = worldX;
    this.targetY = worldY;
    this.isMoving = true;
  }

  reset(): void {
    this.x = GameConstants.WORLD_WIDTH / 2;
    this.y = GameConstants.WORLD_HEIGHT / 2;
    this.evolutionLevel = 0;
    this.targetX = this.x;
    this.targetY = this.y;
    this.isMoving = false;
  }

  update(deltaTime: number): void {
    if (!this.isMoving) {
      return;
    }

    const dx = this.targetX - this.x;
    const dy = this.targetY - this.y;
    const distance = Math.sqrt(dx * dx + dy * dy);

    if (distance > 5) {
      const speed = GameConstants.PLAYER_SPEED * deltaTime;
      this.x += (dx / distance) * speed;
      this.y += (dy / distance) * speed;
    } else {
      this.isMoving = false;
    }

    // 边界限制
    const radius = this.getRadius();
    this.x = Math.max(radius, Math.min(GameConstants.WORLD_WIDTH - radius, this.x));
    this.y = Math.max(radius, Math.min(GameConstants.WORLD_HEIGHT - radius, this.y));
  }
}
