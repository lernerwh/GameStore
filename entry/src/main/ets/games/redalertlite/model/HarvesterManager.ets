/**
 * 红警 Lite 采矿车管理器
 * 管理所有采矿车的创建、更新、与矿场的关联
 */

import { Building } from './Building';
import { BuildingManager } from './BuildingManager';
import { MapData } from './MapData';
import { BuildingType } from './GameConstants';
import { Harvester } from './Harvester';

// 采矿车管理器
export class HarvesterManager {
  private harvesters: Map<string, Harvester> = new Map();
  private buildingManager: BuildingManager | null = null;
  private mapData: MapData | null = null;
  private nextId: number = 0;

  constructor(buildingManager?: BuildingManager, mapData?: MapData) {
    if (buildingManager) {
      this.buildingManager = buildingManager;
    }
    if (mapData) {
      this.mapData = mapData;
    }
  }

  // 设置建筑管理器
  setBuildingManager(manager: BuildingManager): void {
    this.buildingManager = manager;
  }

  // 设置地图数据
  setMapData(mapData: MapData): void {
    this.mapData = mapData;
  }

  // 为矿场创建采矿车
  createHarvesterForRefinery(refinery: Building): Harvester | null {
    if (refinery.type !== BuildingType.REFINERY) return null;

    const harvester = new Harvester(
      refinery,
      refinery.faction,
      `harvester_${this.nextId++}`
    );

    this.harvesters.set(harvester.id, harvester);
    return harvester;
  }

  // 移除采矿车
  removeHarvester(harvesterId: string): boolean {
    return this.harvesters.delete(harvesterId);
  }

  // 获取采矿车
  getHarvester(id: string): Harvester | undefined {
    return this.harvesters.get(id);
  }

  // 获取所有采矿车
  getAllHarvesters(): Harvester[] {
    return Array.from(this.harvesters.values());
  }

  // 获取指定阵营的采矿车
  getHarvestersByFaction(faction: string): Harvester[] {
    return Array.from(this.harvesters.values()).filter(h => h.faction === faction);
  }

  // 更新所有采矿车
  updateAll(deltaMs: number): number {
    let totalMoneyEarned = 0;

    this.harvesters.forEach(harvester => {
      const earned = harvester.update(deltaMs, this.mapData);
      totalMoneyEarned += earned;
    });

    return totalMoneyEarned;
  }

  // 检查并为完成的矿场自动创建采矿车
  checkAndSpawnHarvesters(): void {
    if (!this.buildingManager) return;

    // 获取所有完成的矿场
    const refineries = this.buildingManager
      .getBuildingsByType(BuildingType.REFINERY)
      .filter(b => b.isComplete());

    for (const refinery of refineries) {
      // 检查该矿场是否已有采矿车
      const existingHarvesters = Array.from(this.harvesters.values())
        .filter(h => h.refinery !== null && h.refinery.id === refinery.id);

      if (existingHarvesters.length === 0) {
        this.createHarvesterForRefinery(refinery);
        console.info(`[HarvesterManager] 为矿场 ${refinery.id} 创建采矿车`);
      }
    }
  }

  // 获取采矿车数量
  getHarvesterCount(): number {
    return this.harvesters.size;
  }

  // 获取总载货量
  getTotalCargo(): number {
    let total = 0;
    this.harvesters.forEach(h => {
      total += h.cargoAmount;
    });
    return total;
  }

  // 清空所有采矿车
  clear(): void {
    this.harvesters.clear();
    this.nextId = 0;
  }
}
