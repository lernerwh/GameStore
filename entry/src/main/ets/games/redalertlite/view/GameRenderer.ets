/**
 * 红警 Lite 游戏渲染器
 * 负责绘制地图、网格、资源点、建筑、采矿车、调试信息
 */

import { Camera } from '../model/Camera';
import { MapData, Tile } from '../model/MapData';
import { TerrainType, TERRAINColors } from '../model/MapConfig';
import { Building } from '../model/Building';
import { BuildingManager, PlaceResult } from '../model/BuildingManager';
import { Harvester } from '../model/Harvester';
import { HarvesterManager } from '../model/HarvesterManager';
import { Unit } from '../model/Unit';
import { UnitManager } from '../model/UnitManager';
import {
  TILE_SIZE,
  TERRAIN_COLORS,
  UI_COLORS,
  ORE_DISPLAY_RADIUS,
  MAP_GRID_WIDTH,
  MAP_GRID_HEIGHT,
  BuildingType,
  BuildingState,
  BUILDING_CONFIGS,
  BUILDING_COLORS,
  BuildingColorSet,
  HARVESTER_COLORS,
  HarvesterState,
  UnitType,
  UnitState,
  UNIT_COLORS
} from '../model/GameConstants';

export class GameRenderer {
  private camera: Camera;
  private mapData: MapData | null = null;
  private buildingManager: BuildingManager | null = null;
  private harvesterManager: HarvesterManager | null = null;
  private unitManager: UnitManager | null = null;

  // 建筑放置预览
  private previewType: BuildingType | null = null;
  private previewGridX: number = 0;
  private previewGridY: number = 0;
  private previewResult: PlaceResult = PlaceResult.SUCCESS;

  constructor(camera: Camera) {
    this.camera = camera;
  }

  // 设置地图数据
  setMapData(mapData: MapData): void {
    this.mapData = mapData;
  }

  // 设置建筑管理器
  setBuildingManager(manager: BuildingManager): void {
    this.buildingManager = manager;
  }

  // 设置采矿车管理器
  setHarvesterManager(manager: HarvesterManager): void {
    this.harvesterManager = manager;
  }

  // 设置单位管理器
  setUnitManager(manager: UnitManager): void {
    this.unitManager = manager;
  }

  // 设置放置预览
  setPlacementPreview(type: BuildingType | null, gridX: number, gridY: number, result: PlaceResult): void {
    this.previewType = type;
    this.previewGridX = gridX;
    this.previewGridY = gridY;
    this.previewResult = result;
  }

  // 清除放置预览
  clearPlacementPreview(): void {
    this.previewType = null;
  }

  // 渲染整个场景
  render(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    // 清空画布
    ctx.clearRect(0, 0, width, height);

    // 绘制地图背景
    this.drawMapBackground(ctx, width, height);

    // 绘制网格线
    this.drawGrid(ctx, width, height);

    // 绘制建筑
    this.drawBuildings(ctx, width, height);

    // 绘制单位
    this.drawUnits(ctx);

    // 绘制采矿车
    this.drawHarvesters(ctx);

    // 绘制建筑放置预览
    this.drawPlacementPreview(ctx);

    // 绘制中心标记（调试用）
    this.drawCenterMarker(ctx, width, height);
  }

  // 绘制地图背景
  private drawMapBackground(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    // 深色背景
    ctx.fillStyle = '#1a2a1a';
    ctx.fillRect(0, 0, width, height);

    if (!this.mapData) {
      // 如果没有地图数据，使用简单地形
      this.drawSimpleTerrain(ctx, width, height);
      return;
    }

    // 使用地图数据绘制
    const offset = this.camera.getOffset();
    const offsetX = offset[0];
    const offsetY = offset[1];

    // 计算可见区域
    const startCol = Math.max(0, Math.floor(offsetX / TILE_SIZE) - 1);
    const startRow = Math.max(0, Math.floor(offsetY / TILE_SIZE) - 1);
    const endCol = Math.min(MAP_GRID_WIDTH, Math.ceil((offsetX + width) / TILE_SIZE) + 1);
    const endRow = Math.min(MAP_GRID_HEIGHT, Math.ceil((offsetY + height) / TILE_SIZE) + 1);

    // 绘制可见格子
    for (let row = startRow; row <= endRow; row++) {
      for (let col = startCol; col <= endCol; col++) {
        const tile = this.mapData.getTile(col, row);
        if (tile) {
          this.drawTile(ctx, tile, offsetX, offsetY);
        }
      }
    }
  }

  // 绘制单个格子
  private drawTile(ctx: CanvasRenderingContext2D, tile: Tile, offsetX: number, offsetY: number): void {
    const screenPos = this.camera.worldToScreen(
      tile.gridX * TILE_SIZE,
      tile.gridY * TILE_SIZE
    );
    const screenX = screenPos[0];
    const screenY = screenPos[1];

    // 根据地形类型选择颜色
    let color: string;
    let hasVariation = true;

    switch (tile.terrain) {
      case TerrainType.ORE:
        // 矿区显示金色/棕色
        if (tile.resourceAmount > 1000) {
          color = TERRAIN_COLORS.ore;
        } else if (tile.resourceAmount > 500) {
          color = TERRAIN_COLORS.oreDark;
        } else {
          color = '#8b7355';
        }
        hasVariation = false;
        break;
      case TerrainType.WATER:
        color = TERRAIN_COLORS.water;
        break;
      case TerrainType.ROCK:
        color = TERRAIN_COLORS.rock;
        break;
      case TerrainType.GRASS:
      default:
        // 草地有颜色变化
        const hash = (tile.gridX * 31 + tile.gridY * 17) % 20;
        const greenBase = 90 + hash;
        color = `rgb(${60 + hash}, ${greenBase}, ${60 + hash})`;
        break;
    }

    ctx.fillStyle = color;
    ctx.fillRect(screenX, screenY, TILE_SIZE, TILE_SIZE);

    // 为矿区添加闪烁效果
    if (tile.terrain === TerrainType.ORE && tile.resourceAmount > 0) {
      this.drawOreGlow(ctx, screenX, screenY, tile.resourceAmount);
    }
  }

  // 绘制矿石发光效果
  private drawOreGlow(ctx: CanvasRenderingContext2D, x: number, y: number, amount: number): void {
    const centerX = x + TILE_SIZE / 2;
    const centerY = y + TILE_SIZE / 2;

    // 根据资源量调整发光强度
    const intensity = Math.min(1, amount / 2000);
    const radius = ORE_DISPLAY_RADIUS * (0.8 + intensity * 0.4);

    // 绘制发光效果
    const gradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, radius);
    gradient.addColorStop(0, `rgba(255, 215, 0, ${0.4 * intensity})`);
    gradient.addColorStop(0.5, `rgba(255, 180, 0, ${0.2 * intensity})`);
    gradient.addColorStop(1, 'rgba(255, 150, 0, 0)');

    ctx.fillStyle = gradient;
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
    ctx.fill();

    // 绘制矿石图标（简单的钻石形状）
    ctx.fillStyle = `rgba(255, 215, 0, ${0.6 + intensity * 0.4})`;
    ctx.beginPath();
    ctx.moveTo(centerX, centerY - 10);
    ctx.lineTo(centerX + 8, centerY);
    ctx.lineTo(centerX, centerY + 10);
    ctx.lineTo(centerX - 8, centerY);
    ctx.closePath();
    ctx.fill();
  }

  // 简单地形绘制（无地图数据时）
  private drawSimpleTerrain(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    const offset = this.camera.getOffset();
    const offsetX = offset[0];
    const offsetY = offset[1];

    const startCol = Math.floor(offsetX / TILE_SIZE);
    const startRow = Math.floor(offsetY / TILE_SIZE);
    const endCol = startCol + Math.ceil(width / TILE_SIZE) + 1;
    const endRow = startRow + Math.ceil(height / TILE_SIZE) + 1;

    for (let row = startRow; row <= endRow; row++) {
      for (let col = startCol; col <= endCol; col++) {
        const worldX = col * TILE_SIZE;
        const worldY = row * TILE_SIZE;
        const screen = this.camera.worldToScreen(worldX, worldY);
        const screenX = screen[0];
        const screenY = screen[1];

        // 根据位置生成不同颜色
        const hash = (row * 31 + col * 17) % 100;
        let color: string;

        if (hash < 5) {
          color = '#c9a66b'; // 矿石区域
        } else if (hash < 8) {
          color = '#1a4a6e'; // 水域
        } else if (hash < 12) {
          color = '#5a5a5a'; // 岩石
        } else {
          const greenVar = 30 + (hash % 20);
          color = `rgb(${45 + hash % 10}, ${80 + greenVar}, ${45 + hash % 10})`;
        }

        ctx.fillStyle = color;
        ctx.fillRect(screenX, screenY, TILE_SIZE, TILE_SIZE);
      }
    }
  }

  // 绘制资源节点（从 ResourceManager）
  private drawResourceNodes(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    // 资源点已经在 drawTile 中绘制
    // 这里可以添加额外的资源统计信息
  }

  // 绘制网格
  private drawGrid(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.08)';
    ctx.lineWidth = 1;

    const offset = this.camera.getOffset();
    const offsetX = offset[0];
    const offsetY = offset[1];

    // 计算起始位置（对齐网格）
    const startX = -(offsetX % TILE_SIZE);
    const startY = -(offsetY % TILE_SIZE);

    // 绘制垂直线
    for (let x = startX; x < width; x += TILE_SIZE) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, height);
      ctx.stroke();
    }

    // 绘制水平线
    for (let y = startY; y < height; y += TILE_SIZE) {
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(width, y);
      ctx.stroke();
    }
  }

  // 绘制中心标记
  private drawCenterMarker(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    const centerX = width / 2;
    const centerY = height / 2;

    // 十字标记
    ctx.strokeStyle = 'rgba(255, 100, 100, 0.3)';
    ctx.lineWidth = 1;

    ctx.beginPath();
    ctx.moveTo(centerX - 15, centerY);
    ctx.lineTo(centerX + 15, centerY);
    ctx.moveTo(centerX, centerY - 15);
    ctx.lineTo(centerX, centerY + 15);
    ctx.stroke();
  }

  // 绘制 HUD 资源信息
  drawResourceHUD(
    ctx: CanvasRenderingContext2D,
    money: number,
    power: number,
    maxPower: number,
    oreCount: number,
    totalOre: number
  ): void {
    // 这个方法保留用于 Canvas 绘制，但主要 HUD 使用 ArkUI 组件
  }

  // ==================== 建筑渲染 ====================

  // 绘制所有建筑
  private drawBuildings(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    if (!this.buildingManager) return;

    const buildings = this.buildingManager.getAllBuildings();

    // 按Y坐标排序（实现简单的深度排序）
    buildings.sort((a, b) => a.gridY - b.gridY);

    for (const building of buildings) {
      this.drawBuilding(ctx, building);
    }
  }

  // 绘制单个建筑
  private drawBuilding(ctx: CanvasRenderingContext2D, building: Building): void {
    const screenPos = this.camera.worldToScreen(building.worldX, building.worldY);
    const screenX = screenPos[0];
    const screenY = screenPos[1];

    const config = building.config;
    const gridSize = config.gridSize;
    const gridWidth = gridSize[0];
    const gridHeight = gridSize[1];
    const pixelWidth = gridWidth * TILE_SIZE;
    const pixelHeight = gridHeight * TILE_SIZE;

    // 获取建筑颜色
    const colors = BUILDING_COLORS[building.type];
    if (!colors) return;

    // 建造进度影响透明度
    const alpha = building.state === BuildingState.BUILDING ? 0.5 + building.buildProgress * 0.5 : 1;

    // 绘制地基
    ctx.fillStyle = colors.foundation;
    ctx.fillRect(screenX + 4, screenY + 4, pixelWidth - 8, pixelHeight - 8);

    // 绘制主体
    ctx.fillStyle = colors.main;
    ctx.fillRect(screenX + 8, screenY + 8, pixelWidth - 16, pixelHeight - 16);

    // 绘制屋顶
    ctx.fillStyle = colors.roof;
    ctx.fillRect(screenX + 16, screenY + 12, pixelWidth - 32, pixelHeight - 32);

    // 绘制边框
    ctx.strokeStyle = colors.accent;
    ctx.lineWidth = 2;
    ctx.strokeRect(screenX + 4, screenY + 4, pixelWidth - 8, pixelHeight - 8);

    // 如果是建造厂，绘制特殊标记
    if (building.type === BuildingType.CONSTRUCTION_YARD) {
      this.drawConstructionYardDetail(ctx, screenX, screenY, pixelWidth, pixelHeight, colors);
    }

    // 如果是矿场，绘制矿石处理设施
    if (building.type === BuildingType.REFINERY) {
      this.drawRefineryDetail(ctx, screenX, screenY, pixelWidth, pixelHeight, colors);
    }

    // 如果是电厂，绘制电力效果
    if (building.type === BuildingType.POWER_PLANT) {
      this.drawPowerPlantDetail(ctx, screenX, screenY, pixelWidth, pixelHeight, colors);
    }

    // 建造中显示进度条
    if (building.state === BuildingState.BUILDING) {
      this.drawBuildProgressBar(ctx, screenX, screenY, pixelWidth, building.buildProgress);
    }

    // 建筑名称标签
    if (building.isComplete()) {
      ctx.font = '12px sans-serif';
      ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
      ctx.textAlign = 'center';
      ctx.fillText(config.name, screenX + pixelWidth / 2, screenY + pixelHeight - 8);
    }
  }

  // 建造厂细节
  private drawConstructionYardDetail(
    ctx: CanvasRenderingContext2D,
    x: number, y: number,
    width: number, height: number,
    colors: BuildingColorSet
  ): void {
    const centerX = x + width / 2;
    const centerY = y + height / 2;

    // 绘制中心标志
    ctx.fillStyle = colors.accent;
    ctx.beginPath();
    ctx.moveTo(centerX, centerY - 20);
    ctx.lineTo(centerX + 20, centerY);
    ctx.lineTo(centerX, centerY + 20);
    ctx.lineTo(centerX - 20, centerY);
    ctx.closePath();
    ctx.fill();

    // 发光效果
    ctx.fillStyle = colors.glow;
    ctx.beginPath();
    ctx.arc(centerX, centerY, 25, 0, Math.PI * 2);
    ctx.fill();
  }

  // 矿场细节
  private drawRefineryDetail(
    ctx: CanvasRenderingContext2D,
    x: number, y: number,
    width: number, height: number,
    colors: BuildingColorSet
  ): void {
    // 绘制储存罐
    ctx.fillStyle = colors.accent;
    ctx.beginPath();
    ctx.arc(x + width - 40, y + height / 2, 20, 0, Math.PI * 2);
    ctx.fill();
  }

  // 电厂细节
  private drawPowerPlantDetail(
    ctx: CanvasRenderingContext2D,
    x: number, y: number,
    width: number, height: number,
    colors: BuildingColorSet
  ): void {
    const centerX = x + width / 2;
    const centerY = y + height / 2;

    // 绘制电力图标
    ctx.fillStyle = colors.accent;
    ctx.font = '24px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('⚡', centerX, centerY);

    // 电力光环
    const gradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, 30);
    gradient.addColorStop(0, 'rgba(160, 240, 160, 0.3)');
    gradient.addColorStop(1, 'rgba(160, 240, 160, 0)');
    ctx.fillStyle = gradient;
    ctx.beginPath();
    ctx.arc(centerX, centerY, 30, 0, Math.PI * 2);
    ctx.fill();
  }

  // 建造进度条
  private drawBuildProgressBar(ctx: CanvasRenderingContext2D, x: number, y: number, width: number, progress: number): void {
    const barHeight = 6;
    const barY = y - 12;
    const barWidth = width - 20;

    // 背景
    ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
    ctx.fillRect(x + 10, barY, barWidth, barHeight);

    // 进度
    const progressWidth = barWidth * progress;
    ctx.fillStyle = progress < 1 ? '#FFD700' : '#4CAF50';
    ctx.fillRect(x + 10, barY, progressWidth, barHeight);

    // 边框
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.5)';
    ctx.lineWidth = 1;
    ctx.strokeRect(x + 10, barY, barWidth, barHeight);

    // 百分比
    ctx.font = '10px sans-serif';
    ctx.fillStyle = '#FFFFFF';
    ctx.textAlign = 'center';
    ctx.fillText(`${Math.floor(progress * 100)}%`, x + width / 2, barY - 2);
  }

  // 绘制建筑放置预览
  private drawPlacementPreview(ctx: CanvasRenderingContext2D): void {
    if (!this.previewType) return;

    const config = BUILDING_CONFIGS[this.previewType];
    if (!config) return;

    const gridSize = config.gridSize;
    const gridWidth = gridSize[0];
    const gridHeight = gridSize[1];
    const pixelWidth = gridWidth * TILE_SIZE;
    const pixelHeight = gridHeight * TILE_SIZE;

    const screenPos = this.camera.worldToScreen(
      this.previewGridX * TILE_SIZE,
      this.previewGridY * TILE_SIZE
    );
    const screenX = screenPos[0];
    const screenY = screenPos[1];

    // 根据放置结果显示不同颜色
    let previewColor: string;
    let borderColor: string;
    switch (this.previewResult) {
      case PlaceResult.SUCCESS:
        previewColor = 'rgba(76, 175, 80, 0.4)';
        borderColor = '#4CAF50';
        break;
      case PlaceResult.NOT_ENOUGH_MONEY:
        previewColor = 'rgba(255, 152, 0, 0.4)';
        borderColor = '#FF9800';
        break;
      default:
        previewColor = 'rgba(244, 67, 54, 0.4)';
        borderColor = '#F44336';
        break;
    }

    // 绘制预览区域
    ctx.fillStyle = previewColor;
    ctx.fillRect(screenX, screenY, pixelWidth, pixelHeight);

    // 绘制网格
    ctx.strokeStyle = borderColor;
    ctx.lineWidth = 2;
    ctx.setLineDash([5, 5]);
    ctx.strokeRect(screenX, screenY, pixelWidth, pixelHeight);
    ctx.setLineDash([]);

    // 显示建筑名称和造价
    ctx.font = '14px sans-serif';
    ctx.fillStyle = '#FFFFFF';
    ctx.textAlign = 'center';
    ctx.fillText(`${config.name} -$${config.cost}`, screenX + pixelWidth / 2, screenY - 8);
  }

  // ==================== 采矿车渲染 ====================

  // 绘制所有采矿车
  private drawHarvesters(ctx: CanvasRenderingContext2D): void {
    if (!this.harvesterManager) return;

    const harvesters = this.harvesterManager.getAllHarvesters();

    for (const harvester of harvesters) {
      this.drawHarvester(ctx, harvester);
    }
  }

  // 绘制单个采矿车
  private drawHarvester(ctx: CanvasRenderingContext2D, harvester: Harvester): void {
    const screenPos = this.camera.worldToScreen(harvester.worldX, harvester.worldY);
    const screenX = screenPos[0];
    const screenY = screenPos[1];

    const size = 24;
    const cargoPercent = harvester.getCargoPercent();

    // 计算载货颜色
    const cargoAlpha = Math.min(1, cargoPercent / 100);
    const cargoColor = `rgba(201, 166, 107, ${cargoAlpha})`;

    // 绘制车身（矩形）
    ctx.fillStyle = HARVESTER_COLORS.body;
    ctx.fillRect(screenX - size / 2, screenY - size / 2, size, size);

    // 绘制货物（如果有）
    if (cargoPercent > 0) {
      const cargoHeight = size * 0.6 * cargoPercent / 100;
      ctx.fillStyle = cargoColor;
      ctx.fillRect(screenX - size / 4, screenY - size / 4 - cargoHeight, size / 2, cargoHeight);
    }

    // 绘制方向指示（移动时显示箭头)
    if (harvester.state === HarvesterState.MOVING_TO_ORE ||
        harvester.state === HarvesterState.RETURNING) {
      ctx.strokeStyle = HARVESTER_COLORS.highlight;
      ctx.lineWidth = 2;
      ctx.beginPath();
      // 简单的移动方向箭头
      const targetPos = this.camera.worldToScreen(harvester.targetX, harvester.targetY);
      const targetScreenX = targetPos[0];
      const targetScreenY = targetPos[1];

      const dx = targetScreenX - screenX;
      const dy = targetScreenY - screenY;
      const distance = Math.sqrt(dx * dx + dy * dy);

      if (distance > 5) {
        ctx.moveTo(screenX, screenY);
        ctx.lineTo(screenX + dx * 0.3, screenY + dy * 0.3);
        ctx.stroke();
      }
    }

    // 绘制状态标签
    ctx.font = '9px sans-serif';
    ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
    ctx.textAlign = 'center';
    const stateDesc = harvester.getStateDescription();
    ctx.fillText(stateDesc, screenX, screenY - size - 12);

    // 绘制载货进度条
    const barWidth = size * 1.8;
    const barX = screenX - barWidth / 2;
    const barY = screenY + size + 4;
    const barHeight = 3;
    const cargoBarWidth = barWidth * (cargoPercent / 100);

    ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
    ctx.fillRect(barX, barY, barWidth, barHeight);
    ctx.fillStyle = cargoColor;
    ctx.fillRect(barX, barY, cargoBarWidth, barHeight);
  }

  // ==================== 单位渲染 ====================

  // 绘制所有单位
  private drawUnits(ctx: CanvasRenderingContext2D): void {
    if (!this.unitManager) return;

    const units = this.unitManager.getAliveUnits();

    for (const unit of units) {
      this.drawUnit(ctx, unit);
    }
  }

  // 绘制单个单位
  private drawUnit(ctx: CanvasRenderingContext2D, unit: Unit): void {
    const screenPos = this.camera.worldToScreen(unit.worldX, unit.worldY);
    const screenX = screenPos[0];
    const screenY = screenPos[1];
    const size = unit.config.size;

    // 获取颜色
    const color = unit.getColor();

    // 绘制阴影
    ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
    ctx.beginPath();
    ctx.ellipse(screenX, screenY + size / 2, size * 0.8, size * 0.3, 0, 0, Math.PI * 2);
    ctx.fill();

    // 根据单位类型绘制不同形状
    switch (unit.type) {
      case UnitType.INFANTRY:
        // 步兵 - 圆形
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.arc(screenX, screenY, size, 0, Math.PI * 2);
        ctx.fill();
        break;

      case UnitType.TANK:
        // 坦克 - 矩形
        ctx.fillStyle = color;
        ctx.fillRect(screenX - size, screenY - size * 0.7, size * 2, size * 1.4);
        // 炮管
        ctx.fillStyle = '#555555';
        ctx.fillRect(screenX + size * 0.3, screenY - 2, size * 0.8, 4);
        break;
    }

    // 选中高亮
    if (unit.isSelected) {
      ctx.strokeStyle = UNIT_COLORS.selected;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(screenX, screenY, size + 4, 0, Math.PI * 2);
      ctx.stroke();
    }

    // 绘制血条
    const hpPercent = unit.getHpPercent();
    if (hpPercent < 100) {
      const barWidth = size * 2;
      const barX = screenX - barWidth / 2;
      const barY = screenY - size - 8;

      // 背景
      ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
      ctx.fillRect(barX, barY, barWidth, 4);

      // 血量
      const hpColor = hpPercent > 50 ? '#4CAF50' : hpPercent > 25 ? '#FF9800' : '#FF5722';
      ctx.fillStyle = hpColor;
      ctx.fillRect(barX, barY, barWidth * (hpPercent / 100), 4);
    }

    // 攻击目标线
    if (unit.state === UnitState.ATTACKING && unit.attackTarget) {
      const targetPos = this.camera.worldToScreen(
        unit.attackTarget.worldX,
        unit.attackTarget.worldY
      );
      ctx.strokeStyle = 'rgba(255, 0, 0, 0.3)';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(screenX, screenY);
      ctx.lineTo(targetPos[0], targetPos[1]);
      ctx.stroke();
    }
  }
}
