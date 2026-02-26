/**
 * 红警 Lite 建筑实体
 * 定义单个建筑的属性和状态
 */

import {
  BuildingType,
  BuildingState,
  BuildingConfig,
  BUILDING_CONFIGS,
  TILE_SIZE
} from './GameConstants';

// 建筑实体
export class Building {
  // 唯一标识
  id: string;

  // 建筑类型
  type: BuildingType;

  // 配置信息
  config: BuildingConfig;

  // 世界坐标（左上角）
  worldX: number;
  worldY: number;

  // 格子坐标
  gridX: number;
  gridY: number;

  // 状态
  state: BuildingState;

  // 生命值
  hp: number;
  maxHp: number;

  // 建造进度（0-1）
  buildProgress: number;

  // 建造开始时间
  buildStartTime: number;

  // 所属阵营（player/enemy）
  faction: string;

  constructor(
    type: BuildingType,
    gridX: number,
    gridY: number,
    faction: string = 'player',
    id?: string
  ) {
    this.type = type;
    this.config = BUILDING_CONFIGS[type];
    this.gridX = gridX;
    this.gridY = gridY;
    this.worldX = gridX * TILE_SIZE;
    this.worldY = gridY * TILE_SIZE;
    this.faction = faction;

    this.id = id || `${type}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    this.state = BuildingState.BUILDING;
    this.hp = this.config.hp;
    this.maxHp = this.config.hp;
    this.buildProgress = 0;
    this.buildStartTime = Date.now();
  }

  // 更新建造成度
  updateBuildProgress(): void {
    if (this.state !== BuildingState.BUILDING) return;

    if (this.config.buildTime <= 0) {
      // 立即完成
      this.buildProgress = 1;
      this.state = BuildingState.ACTIVE;
      return;
    }

    const elapsed = Date.now() - this.buildStartTime;
    this.buildProgress = Math.min(1, elapsed / this.config.buildTime);

    if (this.buildProgress >= 1) {
      this.state = BuildingState.ACTIVE;
    }
  }

  // 获取完成百分比
  getBuildPercent(): number {
    return Math.floor(this.buildProgress * 100);
  }

  // 是否建造完成
  isComplete(): boolean {
    return this.state === BuildingState.ACTIVE;
  }

  // 受到伤害
  takeDamage(damage: number): void {
    this.hp = Math.max(0, this.hp - damage);
    if (this.hp <= 0) {
      this.state = BuildingState.DESTROYED;
    } else if (this.hp < this.maxHp * 0.5) {
      this.state = BuildingState.DAMAGED;
    }
  }

  // 修复
  repair(amount: number): void {
    this.hp = Math.min(this.maxHp, this.hp + amount);
    if (this.hp >= this.maxHp * 0.5) {
      this.state = BuildingState.ACTIVE;
    }
  }

  // 获取占地范围
  getOccupiedGrids(): Array<[number, number]> {
    const grids: Array<[number, number]> = [];
    const gridSize = this.config.gridSize;
    const width = gridSize[0];
    const height = gridSize[1];
    for (let dy = 0; dy < height; dy++) {
      for (let dx = 0; dx < width; dx++) {
        grids.push([this.gridX + dx, this.gridY + dy]);
      }
    }
    return grids;
  }

  // 获取边界框（世界坐标）
  getBounds(): [number, number, number, number]{
    const gridSize = this.config.gridSize;
    const width = gridSize[0];
    const height = gridSize[1];
    return [
      this.worldX,
      this.worldY,
      this.worldX + width * TILE_SIZE,
      this.worldY + height * TILE_SIZE
    ];
  }

  // 获取中心点（世界坐标）
  getCenter(): [number, number]{
    const gridSize = this.config.gridSize;
    const width = gridSize[0];
    const height = gridSize[1];
    return [
      this.worldX + (width * TILE_SIZE) / 2,
      this.worldY + (height * TILE_SIZE) / 2
    ];
  }

  // 检查点是否在建筑内
  containsPoint(worldX: number, worldY: number): boolean{
    const bounds = this.getBounds();
    const left = bounds[0];
    const top = bounds[1];
    const right = bounds[2];
    const bottom = bounds[3];
    return worldX >= left && worldX < right && worldY >= top && worldY < bottom;
  }

  // 获取电力产出
  getPowerOutput(): number {
    if (!this.isComplete()) return 0;
    return this.config.powerOutput;
  }

  // 序列化
  toJSON(): Map<string, Object> {
    const result = new Map<string, Object>();
    result.set('id', this.id);
    result.set('type', this.type);
    result.set('gridX', this.gridX);
    result.set('gridY', this.gridY);
    result.set('worldX', this.worldX);
    result.set('worldY', this.worldY);
    result.set('state', this.state);
    result.set('hp', this.hp);
    result.set('maxHp', this.maxHp);
    result.set('buildProgress', this.buildProgress);
    result.set('faction', this.faction);
    return result;
  }
}
