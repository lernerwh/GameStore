import { GameConstants } from '../common/constants/GameConstants';

/**
 * 生物实体类 - 召唤神龙中的 NPC 生物
 */
export class Creature {
  x: number = 0;
  y: number = 0;
  velocityX: number = 0;
  velocityY: number = 0;
  score: number = 0;
  evolutionLevel: number = 0;

  constructor(initialScore?: number) {
    // 随机进化等级 (0-9)，但偏向低等级
    if (typeof initialScore === 'number') {
      this.score = Math.max(0, initialScore);
    } else {
      const rand = Math.random();
      let level = 0;
      if (rand < 0.4) {
        level = Math.floor(Math.random() * 3); // 0-2
      } else if (rand < 0.7) {
        level = Math.floor(Math.random() * 5); // 0-4
      } else if (rand < 0.9) {
        level = Math.floor(Math.random() * 7); // 0-6
      } else {
        level = Math.floor(Math.random() * 10); // 0-9
      }
      this.score = GameConstants.getSpawnScoreByLevel(level);
    }
    this.evolutionLevel = GameConstants.getEvolutionLevelByScore(this.score);

    // 根据体型设置速度（越大越慢）
    const speed = 45 + Math.random() * 45 - this.getRadius() * 0.2;
    const angle = Math.random() * Math.PI * 2;
    this.velocityX = Math.cos(angle) * speed;
    this.velocityY = Math.sin(angle) * speed;
  }

  getRadius(): number {
    return GameConstants.getRadiusByScore(this.score);
  }

  getColor(): string {
    return GameConstants.EVOLUTION_COLORS[this.evolutionLevel];
  }

  getName(): string {
    return GameConstants.EVOLUTION_NAMES[this.evolutionLevel];
  }

  addScore(deltaScore: number): void {
    this.score = Math.max(0, this.score + deltaScore);
    this.evolutionLevel = GameConstants.getEvolutionLevelByScore(this.score);
  }

  update(deltaTime: number): void {
    this.x += this.velocityX * deltaTime;
    this.y += this.velocityY * deltaTime;

    // 边界反弹
    const radius = this.getRadius();

    if (this.x - radius < 0) {
      this.x = radius;
      this.velocityX = Math.abs(this.velocityX);
    } else if (this.x + radius > GameConstants.WORLD_WIDTH) {
      this.x = GameConstants.WORLD_WIDTH - radius;
      this.velocityX = -Math.abs(this.velocityX);
    }

    if (this.y - radius < 0) {
      this.y = radius;
      this.velocityY = Math.abs(this.velocityY);
    } else if (this.y + radius > GameConstants.WORLD_HEIGHT) {
      this.y = GameConstants.WORLD_HEIGHT - radius;
      this.velocityY = -Math.abs(this.velocityY);
    }
  }
}
