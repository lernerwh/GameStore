/**
 * 红警 Lite 建筑管理器
 * 管理所有建筑的放置、更新、查询
 */

import { Building } from './Building';
import { MapData } from './MapData';
import {
  BuildingType,
  BuildingState,
  BUILDING_CONFIGS,
  TILE_SIZE,
  MAP_GRID_WIDTH,
  MAP_GRID_HEIGHT
} from './GameConstants';

// 电力统计接口
export interface PowerStats {
  supply: number;
  demand: number;
  balance: number;
}

// 建造结果
export enum PlaceResult {
  SUCCESS = 'success',
  NOT_ENOUGH_MONEY = 'not_enough_money',
  INVALID_POSITION = 'invalid_position',
  OVERLAPS_EXISTING = 'overlaps_existing',
  TERRAIN_BLOCKED = 'terrain_blocked'
}

// 建筑管理器
export class BuildingManager {
  private buildings: Map<string, Building> = new Map();
  private mapData: MapData | null = null;
  private occupiedGrids: Set<string> = new Set();
  private nextId: number = 0;

  // 设置地图数据
  setMapData(mapData: MapData): void {
    this.mapData = mapData;
  }

  // 检查是否可以放置建筑
  canPlaceBuilding(type: BuildingType, gridX: number, gridY: number, money: number): PlaceResult {
    const config = BUILDING_CONFIGS[type];
    const gridSize = config.gridSize;
    const width = gridSize[0];
    const height = gridSize[1];

    // 检查资金
    if (money < config.cost) {
      return PlaceResult.NOT_ENOUGH_MONEY;
    }

    // 检查边界
    if (gridX < 0 || gridY < 0 ||
        gridX + width > MAP_GRID_WIDTH ||
        gridY + height > MAP_GRID_HEIGHT) {
      return PlaceResult.INVALID_POSITION;
    }

    // 检查地形和已占用格子
    for (let dy = 0; dy < height; dy++) {
      for (let dx = 0; dx < width; dx++) {
        const checkX = gridX + dx;
        const checkY = gridY + dy;
        const key = `${checkX},${checkY}`;

        // 检查是否已被占用
        if (this.occupiedGrids.has(key)) {
          return PlaceResult.OVERLAPS_EXISTING;
        }

        // 检查地形是否可通行
        if (this.mapData) {
          const tile = this.mapData.getTile(checkX, checkY);
          if (tile && !tile.passable) {
            return PlaceResult.TERRAIN_BLOCKED;
          }
        }
      }
    }

    return PlaceResult.SUCCESS;
  }

  // 放置建筑
  placeBuilding(type: BuildingType, gridX: number, gridY: number, faction: string = 'player'): Building | null {
    const config = BUILDING_CONFIGS[type];
    const gridSize = config.gridSize;
    const width = gridSize[0];
    const height = gridSize[1];

    // 标记占用格子
    for (let dy = 0; dy < height; dy++) {
      for (let dx = 0; dx < width; dx++) {
        const key = `${gridX + dx},${gridY + dy}`;
        this.occupiedGrids.add(key);
      }
    }

    // 创建建筑
    const building = new Building(type, gridX, gridY, faction, `${type}_${this.nextId++}`);
    this.buildings.set(building.id, building);

    return building;
  }

  // 移除建筑
  removeBuilding(buildingId: string): boolean {
    const building = this.buildings.get(buildingId);
    if (!building) return false;

    // 释放占用格子
    const grids = building.getOccupiedGrids();
    for (const grid of grids) {
      const key = `${grid[0]},${grid[1]}`;
      this.occupiedGrids.delete(key);
    }

    this.buildings.delete(buildingId);
    return true;
  }

  // 获取建筑
  getBuilding(id: string): Building | undefined {
    return this.buildings.get(id);
  }

  // 获取所有建筑
  getAllBuildings(): Building[] {
    return Array.from(this.buildings.values());
  }

  // 获取指定阵营的建筑
  getBuildingsByFaction(faction: string): Building[] {
    return Array.from(this.buildings.values()).filter(b => b.faction === faction);
  }

  // 获取指定类型的建筑
  getBuildingsByType(type: BuildingType): Building[] {
    return Array.from(this.buildings.values()).filter(b => b.type === type);
  }

  // 获取完成的建筑
  getCompletedBuildings(): Building[] {
    return Array.from(this.buildings.values()).filter(b => b.isComplete());
  }

  // 更新所有建筑的建造进度
  updateBuildProgress(): void {
    this.buildings.forEach(building => {
      building.updateBuildProgress();
    });
  }

  // 计算总电力
  calculatePower(): PowerStats {
    let supply = 0;
    let demand = 0;

    this.buildings.forEach(building => {
      if (!building.isComplete()) return;

      const power = building.getPowerOutput();
      if (power > 0) {
        supply += power;
      } else {
        demand += Math.abs(power);
      }
    });

    const result: PowerStats = {
      supply: supply,
      demand: demand,
      balance: supply - demand
    };
    return result;
  }

  // 点击位置获取建筑
  getBuildingAtPoint(worldX: number, worldY: number): Building | null {
    for (const building of this.buildings.values()) {
      if (building.containsPoint(worldX, worldY)) {
        return building;
      }
    }
    return null;
  }

  // 初始化玩家基地
  initializePlayerBase(): Building {
    // 在地图中心附近放置建造厂
    const baseX = Math.floor(MAP_GRID_WIDTH / 2) - 1;
    const baseY = Math.floor(MAP_GRID_HEIGHT / 2) - 1;

    const base = this.placeBuilding(BuildingType.CONSTRUCTION_YARD, baseX, baseY, 'player');
    if (base) {
      // 建造厂立即完成
      base.state = BuildingState.ACTIVE;
      base.buildProgress = 1;
    }
    return base!;
  }

  // 清空所有建筑
  clear(): void {
    this.buildings.clear();
    this.occupiedGrids.clear();
    this.nextId = 0;
  }

  // 获取建筑数量
  getBuildingCount(): number {
    return this.buildings.size;
  }
}
