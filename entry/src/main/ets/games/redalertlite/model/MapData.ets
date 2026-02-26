/**
 * 红警 Lite 地图数据结构
 * 管理地图网格、通行性、资源分布
 */

import { TerrainType, TERRAINColors } from './MapConfig';

// 地图格子
export interface Tile {
  gridX: number;          // 格子X坐标
  gridY: number;          // 格子Y坐标
  terrain: TerrainType;   // 地形类型
  passable: boolean;      // 是否可通行
  hasResource: boolean;   // 是否有资源
  resourceAmount: number; // 资源量（如果有）
}

// 地图数据
export class MapData {
  private tiles: Map<string, Tile> = new Map();
  private gridWidth: number;
  private gridHeight: number;
  private tileSize: number;

  constructor(gridWidth: number, gridHeight: number, tileSize: number) {
    this.gridWidth = gridWidth;
    this.gridHeight = gridHeight;
    this.tileSize = tileSize;
    this.generateMap();
  }

  // 生成地图
  private generateMap(): void {
    // 使用种子随机数生成一致的地形
    for (let y = 0; y < this.gridHeight; y++) {
      for (let x = 0; x < this.gridWidth; x++) {
        const terrain = this.generateTerrain(x, y);
        const tile: Tile = {
          gridX: x,
          gridY: y,
          terrain: terrain,
          passable: terrain !== TerrainType.WATER && terrain !== TerrainType.ROCK,
          hasResource: terrain === TerrainType.ORE,
          resourceAmount: terrain === TerrainType.ORE ? this.generateResourceAmount(x, y) : 0
        };
        this.tiles.set(this.getKey(x, y), tile);
      }
    }
  }

  // 生成地形类型
  private generateTerrain(gridX: number, gridY: number): TerrainType {
    // 使用简单的哈希函数生成伪随机地形
    const hash = (gridX * 31 + gridY * 17 + gridX * gridY * 7) % 100;

    // 在地图边缘和中心区域生成矿区
    const distFromCenter = Math.sqrt(
      Math.pow(gridX - this.gridWidth / 2, 2) +
      Math.pow(gridY - this.gridHeight / 2, 2)
    );

    // 矿区分布：边缘较多，中心也有一些
    if (hash < 8 || (distFromCenter > this.gridWidth * 0.3 && hash < 15)) {
      return TerrainType.ORE;
    } else if (hash < 12) {
      return TerrainType.WATER;
    } else if (hash < 16) {
      return TerrainType.ROCK;
    } else {
      return TerrainType.GRASS;
    }
  }

  // 生成资源量
  private generateResourceAmount(gridX: number, gridY: number): number {
    const base = 1500;
    const variation = ((gridX * 7 + gridY * 13) % 500);
    return base + variation;
  }

  // 获取格子键
  private getKey(gridX: number, gridY: number): string {
    return `${gridX},${gridY}`;
  }

  // 获取格子
  getTile(gridX: number, gridY: number): Tile | undefined {
    return this.tiles.get(this.getKey(gridX, gridY));
  }

  // 获取格子（世界坐标）
  getTileAtWorld(worldX: number, worldY: number): Tile | undefined {
    const gridX = Math.floor(worldX / this.tileSize);
    const gridY = Math.floor(worldY / this.tileSize);
    return this.getTile(gridX, gridY);
  }

  // 检查是否可通行
  isPassable(gridX: number, gridY: number): boolean {
    const tile = this.getTile(gridX, gridY);
    return tile ? tile.passable : false;
  }

  // 获取所有资源格子
  getResourceTiles(): Tile[] {
    const result: Tile[] = [];
    this.tiles.forEach((tile) => {
      if (tile.hasResource && tile.resourceAmount > 0) {
        result.push(tile);
      }
    });
    return result;
  }

  // 采集资源
  harvestResource(gridX: number, gridY: number, amount: number): number {
    const tile = this.getTile(gridX, gridY);
    if (!tile || !tile.hasResource || tile.resourceAmount <= 0) {
      return 0;
    }

    const harvested = Math.min(amount, tile.resourceAmount);
    tile.resourceAmount -= harvested;

    if (tile.resourceAmount <= 0) {
      tile.resourceAmount = 0;
      tile.hasResource = false;
      // 资源耗尽后变成普通草地
      tile.terrain = TerrainType.GRASS;
    }

    return harvested;
  }

  // 获取地形颜色
  getTerrainColor(terrain: TerrainType): string {
    return TERRAINColors[terrain];
  }

  // 获取地图尺寸
  getGridSize(): [number, number] {
    return [this.gridWidth, this.gridHeight];
  }

  getTileSize(): number {
    return this.tileSize;
  }

  // 获取世界尺寸
  getWorldSize(): [number, number] {
    return [this.gridWidth * this.tileSize, this.gridHeight * this.tileSize];
  }

  // 获取所有格子（用于渲染）
  getAllTiles(): Tile[] {
    return Array.from(this.tiles.values());
  }
}
