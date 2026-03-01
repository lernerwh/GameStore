/**
 * 红警 Lite 敌人AI系统
 * 简化版：敌人定期攻击玩家建筑
 */

import { BuildingManager } from './BuildingManager';
import { Building } from './Building';
import { BuildingType, BuildingState } from './GameConstants';

// 敌人AI配置
export interface EnemyAIConfig {
  attackInterval: number;      // 攻击间隔（毫秒）
  attackDamage: number;        // 每次攻击伤害
  targetBuildings: BuildingType[]; // 优先攻击的建筑类型
}

// 默认配置
export const DEFAULT_ENEMY_AI_CONFIG: EnemyAIConfig = {
  attackInterval: 5000,  // 5秒攻击一次
  attackDamage: 50,    // 每次造成50点伤害
  targetBuildings: [
    BuildingType.CONSTRUCTION_YARD,
    BuildingType.REFINERY,
    BuildingType.POWER_PLANT,
    BuildingType.BARRACKS,
    BuildingType.WAR_FACTORY
  ]
};

// 敌人AI管理器
export class EnemyAI {
  private buildingManager: BuildingManager | null = null;
  private config: EnemyAIConfig;
  private lastAttackTime: number = 0;
  private isAttacking: boolean = false;

  constructor(config: EnemyAIConfig = DEFAULT_ENEMY_AI_CONFIG) {
    this.config = config;
  }

  // 设置建筑管理器
  setBuildingManager(manager: BuildingManager): void {
    this.buildingManager = manager;
  }

  // 更新AI
  update(now: number): void {
    if (!this.buildingManager) return;

    // 检查是否应该攻击
    if (now - this.lastAttackTime >= this.config.attackInterval) {
      this.performAttack();
      this.lastAttackTime = now;
    }
  }

  // 执行攻击
  private performAttack(): void {
    if (!this.buildingManager) return;

    // 获取玩家活跃建筑
    const playerBuildings = this.buildingManager.getBuildingsByFaction('player')
      .filter(b => b.state === BuildingState.ACTIVE);

    if (playerBuildings.length === 0) {
      return;
    }

    // 按优先级选择目标
    const target = this.selectTarget(playerBuildings);

    if (target) {
      // 对建筑造成伤害
      target.takeDamage(this.config.attackDamage);
      this.isAttacking = true;
    }
  }

  // 选择攻击目标
  private selectTarget(buildings: Building[]): Building | null {
    if (buildings.length === 0) return null;

    // 优先攻击特定类型的建筑
    for (const preferredType of this.config.targetBuildings) {
      const found = buildings.find(b => b.type === preferredType);
      if (found) return found;
    }

    // 如果没有优先目标，随机选择一个
    const randomIndex = Math.floor(Math.random() * buildings.length);
    return buildings[randomIndex];
  }

  // 获取AI状态
  getAIStatus(): string {
    if (!this.buildingManager) return '未初始化';

    const playerBuildings = this.buildingManager.getBuildingsByFaction('player')
      .filter(b => b.state === BuildingState.ACTIVE);

    if (playerBuildings.length === 0) {
      return '胜利';
    }

    return this.isAttacking ? '攻击中' : '待机';
  }
}
