/**
 * 红警 Lite 采矿车实体
 * 实现采矿车的状态机和移动逻辑
 */

import {
  HarvesterState,
  HarvesterConfig,
  HARVESTER_CONFIG,
  TILE_SIZE
} from './GameConstants';
import { Building } from './Building';
import { MapData } from './MapData';

// 采矿车实体
export class Harvester {
  // 僯一标识
  id: string;

  // 位置(世界坐标)
  worldX: number;
  worldY: number;

  // 目标位置
  targetX: number = 0;
  targetY: number = 0;

  // 所属矿场
  refinery: Building | null = null;

  // 状态
  state: HarvesterState = HarvesterState.IDLE;

  // 载货量
  cargoAmount: number = 0;
  maxCapacity: number;

  // 配置
  config: HarvesterConfig;

  // 所属阵营
  faction: string;

  // 当前目标矿点（格子坐标)
  targetOreGridX: number = -1;
  targetOreGridY: number = -1;

  // 状态计时器
  stateTimer: number = 0;

  constructor(
    refinery: Building,
    faction: string = 'player',
    id?: string
  ) {
    this.refinery = refinery;
    this.faction = faction;

    // 从矿场中心出生
    const center = refinery.getCenter();
    this.worldX = center[0];
    this.worldY = center[1];

    this.id = id || `harvester_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    this.config = HARVESTER_CONFIG;
    this.maxCapacity = this.config.maxCapacity;
    this.state = HarvesterState.IDLE;
  }

  // 更新状态
  update(deltaMs: number, mapData: MapData | null): number {
    // 返回本次卸货获得的资金
    let moneyEarned = 0;

    switch (this.state) {
      case HarvesterState.IDLE:
        // 空闲时开始寻找矿石
        this.state = HarvesterState.SEEKING_ORE;
        break;

      case HarvesterState.SEEKING_ORE:
        // 寻找最近的矿石
        this.findNearestOre(mapData);
        if (this.targetOreGridX >= 0) {
          this.targetX = this.targetOreGridX * TILE_SIZE + TILE_SIZE / 2;
          this.targetY = this.targetOreGridY * TILE_SIZE + TILE_SIZE / 2;
          this.state = HarvesterState.MOVING_TO_ORE;
        }
        break;

      case HarvesterState.MOVING_TO_ORE:
        // 移动到矿区
        if (this.moveToTarget(deltaMs)) {
          // 到达矿区，开始采集
          this.state = HarvesterState.HARVESTING;
          this.stateTimer = 0;
        }
        break;

      case HarvesterState.HARVESTING:
        // 采集矿石
        moneyEarned = this.harvest(deltaMs, mapData);
        if (this.cargoAmount >= this.maxCapacity) {
          // 货满
          this.returnToRefinery();
        } else if (this.targetOreGridX < 0 || !this.hasOreAtTarget(mapData)) {
          // 当前矿点耗尽
          this.findNearestOre(mapData);
          if (this.targetOreGridX >= 0) {
            this.targetX = this.targetOreGridX * TILE_SIZE + TILE_SIZE / 2;
            this.targetY = this.targetOreGridY * TILE_SIZE + TILE_SIZE / 2;
            this.state = HarvesterState.MOVING_TO_ORE;
          } else {
            // 没有矿石了
            this.returnToRefinery();
          }
        }
        break;

      case HarvesterState.RETURNING:
        // 返回矿场
        if (this.moveToTarget(deltaMs)) {
          // 到达矿场
          this.state = HarvesterState.UNLOADING;
          this.stateTimer = 0;
        }
        break;

      case HarvesterState.UNLOADING:
        // 卸货
        moneyEarned = this.unload(deltaMs);
        if (this.cargoAmount <= 0) {
          // 卸货完成
          this.cargoAmount = 0;
          this.state = HarvesterState.SEEKING_ORE;
        }
        break;
    }

    return moneyEarned;
  }

  // 移动到目标位置
  private moveToTarget(deltaMs: number): boolean {
    const dx = this.targetX - this.worldX;
    const dy = this.targetY - this.worldY;
    const distance = Math.sqrt(dx * dx + dy * dy);

    if (distance < 5) {
      // 到达目标
      this.worldX = this.targetX;
      this.worldY = this.targetY;
      return true;
    }

    // 按速度移动
    const moveDistance = (this.config.moveSpeed * deltaMs) / 1000;
    if (moveDistance >= distance) {
      this.worldX = this.targetX;
      this.worldY = this.targetY;
      return true;
    }

    // 移动
    const ratio = moveDistance / distance;
    this.worldX += dx * ratio;
    this.worldY += dy * ratio;
    return false;
  }

  // 寻找最近的矿石
  private findNearestOre(mapData: MapData | null): void {
    if (!mapData) {
      this.targetOreGridX = -1;
      this.targetOreGridY = -1;
      return;
    }

    const myGridX = Math.floor(this.worldX / TILE_SIZE);
    const myGridY = Math.floor(this.worldY / TILE_SIZE);

    let nearestDist = Infinity;
    let nearestX = -1;
    let nearestY = -1;

    const oreTiles = mapData.getResourceTiles();
    for (const tile of oreTiles) {
      const dist = Math.sqrt(
        Math.pow(tile.gridX - myGridX, 2) +
        Math.pow(tile.gridY - myGridY, 2)
      );

      if (dist < nearestDist && dist <= this.config.searchRange) {
        nearestDist = dist;
        nearestX = tile.gridX;
        nearestY = tile.gridY;
      }
    }

    this.targetOreGridX = nearestX;
    this.targetOreGridY = nearestY;
  }

  // 检查目标位置是否有矿石
  private hasOreAtTarget(mapData: MapData | null): boolean {
    if (!mapData || this.targetOreGridX < 0) return false;

    const tile = mapData.getTile(this.targetOreGridX, this.targetOreGridY);
    return tile !== undefined && tile.hasResource && tile.resourceAmount > 0;
  }

  // 采集矿石
  private harvest(deltaMs: number, mapData: MapData | null): number {
    if (!mapData || this.targetOreGridX < 0) return 0;

    // 计算本次采集量
    const harvestAmount = (this.config.harvestRate * deltaMs) / 1000;
    const canCarry = this.maxCapacity - this.cargoAmount;
    const actualHarvest = Math.min(harvestAmount, canCarry);

    // 从地图扣除矿石
    const harvested = mapData.harvestResource(
      this.targetOreGridX,
      this.targetOreGridY,
      actualHarvest
    );

    this.cargoAmount += harvested;
    return 0; // 采集时不产生资金
  }

  // 返回矿场
  private returnToRefinery(): void {
    if (this.refinery) {
      const center = this.refinery.getCenter();
      this.targetX = center[0];
      this.targetY = center[1];
      this.state = HarvesterState.RETURNING;
    } else {
      this.state = HarvesterState.IDLE;
    }
  }

  // 卸货
  private unload(deltaMs: number): number {
    // 计算本次卸货量
    const unloadAmount = (this.config.unloadRate * deltaMs) / 1000;
    const actualUnload = Math.min(unloadAmount, this.cargoAmount);

    this.cargoAmount -= actualUnload;

    // 返回获得的资金(1单位矿石 = 1资金)
    return actualUnload;
  }

  // 获取载货百分比
  getCargoPercent(): number {
    return Math.floor((this.cargoAmount / this.maxCapacity) * 100);
  }

  // 获取状态描述
  getStateDescription(): string {
    switch (this.state) {
      case HarvesterState.IDLE:
        return '空闲';
      case HarvesterState.SEEKING_ORE:
        return '寻找矿石';
      case HarvesterState.MOVING_TO_ORE:
        return '前往矿区';
      case HarvesterState.HARVESTING:
        return `采集 ${this.getCargoPercent()}%`;
      case HarvesterState.RETURNING:
        return '返回矿场';
      case HarvesterState.UNLOADING:
        return '卸货中';
      default:
        return '未知';
    }
  }

  // 设置所属矿场
  setRefinery(refinery: Building): void {
    this.refinery = refinery;
  }
}
