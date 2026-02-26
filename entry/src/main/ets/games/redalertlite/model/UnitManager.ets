/**
 * 红警 Lite 单位管理器
 * 管理所有单位的创建、更新、战斗、死亡
 */

import { Unit } from './Unit';
import { Building } from './Building';
import { BuildingManager } from './BuildingManager';
import {
  UnitType,
  UnitState,
  UNIT_CONFIGS,
  BuildingType,
  TILE_SIZE
} from './GameConstants';

// 单位管理器
export class UnitManager {
  private units: Map<string, Unit> = new Map();
  private buildingManager: BuildingManager | null = null;
  private nextId: number = 0;

  // 设置建筑管理器
  setBuildingManager(manager: BuildingManager): void {
    this.buildingManager = manager;
  }

  // 创建单位
  createUnit(type: UnitType, worldX: number, worldY: number, faction: string = 'player'): Unit {
    const unit = new Unit(type, worldX, worldY, faction, `unit_${this.nextId++}`);
    this.units.set(unit.id, unit);
    return unit;
  }

  // 在建筑附近创建单位
  createUnitAtBuilding(type: UnitType, building: Building, faction: string = 'player'): Unit | null {
    const center = building.getCenter();
    // 在建筑下方创建
    const gridSize = building.config.gridSize;
    const spawnX = center[0];
    const spawnY = center[1] + (gridSize[1] * TILE_SIZE) / 2 + 30;

    return this.createUnit(type, spawnX, spawnY, faction);
  }

  // 移除单位
  removeUnit(unitId: string): boolean {
    return this.units.delete(unitId);
  }

  // 获取单位
  getUnit(id: string): Unit | undefined {
    return this.units.get(id);
  }

  // 获取所有单位
  getAllUnits(): Unit[] {
    return Array.from(this.units.values());
  }

  // 获取存活的单位
  getAliveUnits(): Unit[] {
    return Array.from(this.units.values()).filter(u => !u.isDead());
  }

  // 获取指定阵营的单位
  getUnitsByFaction(faction: string): Unit[] {
    return Array.from(this.units.values()).filter(u => u.faction === faction && !u.isDead());
  }

  // 更新所有单位
  updateAll(deltaMs: number): void {
    // 更新单位
    this.units.forEach(unit => {
      if (!unit.isDead()) {
        unit.update(deltaMs);
      }
    });

    // 自动索敌
    this.autoFindTargets();

    // 清理死亡单位
    this.cleanupDeadUnits();
  }

  // 自动寻找目标
  private autoFindTargets(): void {
    const playerUnits = this.getUnitsByFaction('player');
    const enemyUnits = this.getUnitsByFaction('enemy');

    // 玩家单位寻找敌人
    for (const unit of playerUnits) {
      if (unit.state === UnitState.IDLE) {
        const nearestEnemy = this.findNearestEnemy(unit, enemyUnits);
        if (nearestEnemy) {
          unit.setAttackTarget(nearestEnemy);
        }
      }
    }

    // 敌人单位寻找玩家
    for (const unit of enemyUnits) {
      if (unit.state === UnitState.IDLE) {
        const nearestEnemy = this.findNearestEnemy(unit, playerUnits);
        if (nearestEnemy) {
          unit.setAttackTarget(nearestEnemy);
        }
      }
    }
  }

  // 寻找最近的敌人
  private findNearestEnemy(unit: Unit, enemies: Unit[]): Unit | null {
    let nearest: Unit | null = null;
    let minDist = Infinity;

    for (const enemy of enemies) {
      if (enemy.isDead()) continue;

      const dist = Math.sqrt(
        Math.pow(enemy.worldX - unit.worldX, 2) +
        Math.pow(enemy.worldY - unit.worldY, 2)
      );

      if (dist < minDist) {
        minDist = dist;
        nearest = enemy;
      }
    }

    return nearest;
  }

  // 清理死亡单位
  private cleanupDeadUnits(): void {
    const deadIds: string[] = [];
    this.units.forEach((unit, id) => {
      if (unit.isDead()) {
        deadIds.push(id);
      }
    });

    // 保留死亡单位一段时间后再移除（可以显示死亡动画）
    // for (const id of deadIds) {
    //   this.units.delete(id);
    // }
  }

  // 点击位置获取单位
  getUnitAtPoint(worldX: number, worldY: number): Unit | null {
    for (const unit of this.units.values()) {
      if (unit.isDead()) continue;

      const dx = Math.abs(unit.worldX - worldX);
      const dy = Math.abs(unit.worldY - worldY);
      if (dx < unit.config.size && dy < unit.config.size) {
        return unit;
      }
    }
    return null;
  }

  // 选中单位（框选）
  selectUnitsInRect(x1: number, y1: number, x2: number, y2: number, faction: string): Unit[] {
    const selected: Unit[] = [];
    const minX = Math.min(x1, x2);
    const maxX = Math.max(x1, x2);
    const minY = Math.min(y1, y2);
    const maxY = Math.max(y1, y2);

    for (const unit of this.units.values()) {
      if (unit.isDead()) continue;
      if (unit.faction !== faction) continue;

      if (unit.worldX >= minX && unit.worldX <= maxX &&
          unit.worldY >= minY && unit.worldY <= maxY) {
        unit.isSelected = true;
        selected.push(unit);
      }
    }

    return selected;
  }

  // 清除选中
  clearSelection(): void {
    this.units.forEach(unit => {
      unit.isSelected = false;
    });
  }

  // 获取选中的单位
  getSelectedUnits(): Unit[] {
    return Array.from(this.units.values()).filter(u => u.isSelected && !u.isDead());
  }

  // 命令选中单位移动
  commandSelectedToMove(worldX: number, worldY: number): void {
    const selected = this.getSelectedUnits();
    for (const unit of selected) {
      unit.setTarget(worldX, worldY);
    }
  }

  // 命令选中单位攻击
  commandSelectedToAttack(target: Unit): void {
    const selected = this.getSelectedUnits();
    for (const unit of selected) {
      unit.setAttackTarget(target);
    }
  }

  // 获取单位数量
  getUnitCount(): number {
    return this.units.size;
  }

  // 清空所有单位
  clear(): void {
    this.units.clear();
    this.nextId = 0;
  }
}
