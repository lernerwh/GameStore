/**
 * 红警 Lite 游戏主页面
 * 基于 RedAlertLiteViewModel
 */

import { router } from '@kit.ArkUI';
import { Camera } from '../games/redalertlite/model/Camera';
import { MapData } from '../games/redalertlite/model/MapData';
import { GameRenderer } from '../games/redalertlite/view/GameRenderer';
import { BuildingManager, PlaceResult } from '../games/redalertlite/model/BuildingManager';
import { HarvesterManager } from '../games/redalertlite/model/HarvesterManager';
import { PowerManager } from '../games/redalertlite/model/PowerManager';
import {
  INITIAL_MONEY,
  MAP_GRID_WIDTH,
  MAP_GRID_HEIGHT,
  TILE_SIZE,
  BuildingType,
  BUILDING_CONFIGS,
  PowerStatus
} from '../games/redalertlite/model/GameConstants';

@Entry
@Component
struct RedAlertLiteGame {
  // 屏幕尺寸
  @State screenWidth: number = 1320;
  @State screenHeight: number = 2848;

  // 系统组件
  private camera: Camera | null = null;
  private renderer: GameRenderer | null = null;
  private mapData: MapData | null = null;
  private buildingManager: BuildingManager | null = null;
  private harvesterManager: HarvesterManager | null = null;
  private powerManager: PowerManager | null = null;

  // Canvas 上下文
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  // 交互状态
  private isDragging: boolean = false;
  private lastX: number = 0;
  private lastY: number = 0;

  // 游戏状态
  @State money: number = INITIAL_MONEY;
  @State powerSupply: number = 0;
  @State powerDemand: number = 0;
  @State powerBalance: number = 0;
  @State powerStatus: PowerStatus = PowerStatus.NORMAL;
  @State oreNodeCount: number = 0;
  @State totalOre: number = 0;
  @State buildingCount: number = 0;
  @State harvesterCount: number = 0;

  // 建造模式
  @State isBuildMode: boolean = false;
  @State selectedBuildingType: BuildingType | null = null;
  @State previewGridX: number = 0;
  @State previewGridY: number = 0;
  @State canPlace: boolean = false;
  @State placeMessage: string = '';

  // 调试信息
  @State cameraOffset: string = '0, 0';
  @State fps: number = 0;
  private frameCount: number = 0;
  private lastFpsTime: number = 0;

  // 游戏循环
  private gameInterval: number = 0;
  private lastUpdateTime: number = 0;

  aboutToAppear(): void {
    console.info('[RedAlertLite] aboutToAppear');

    // 初始化系统
    this.camera = new Camera(this.screenWidth, this.screenHeight);
    this.renderer = new GameRenderer(this.camera);
    this.mapData = new MapData(MAP_GRID_WIDTH, MAP_GRID_HEIGHT, TILE_SIZE);
    this.buildingManager = new BuildingManager();
    this.harvesterManager = new HarvesterManager();
    this.powerManager = new PowerManager();

    // 连接各系统
    this.buildingManager.setMapData(this.mapData);
    this.harvesterManager.setBuildingManager(this.buildingManager);
    this.harvesterManager.setMapData(this.mapData);
    this.powerManager.setBuildingManager(this.buildingManager);
    this.renderer.setMapData(this.mapData);
    this.renderer.setBuildingManager(this.buildingManager);
    this.renderer.setHarvesterManager(this.harvesterManager);

    // 初始化资源统计
    this.updateResourceStats();

    // 初始化玩家基地
    this.buildingManager.initializePlayerBase();
    this.updatePowerStats();

    // 启动游戏循环
    this.lastUpdateTime = Date.now();
    this.startGameLoop();
  }

  aboutToDisappear(): void {
    console.info('[RedAlertLite] aboutToDisappear');
    this.stopGameLoop();
  }

  // 启动游戏循环
  private startGameLoop(): void {
    this.gameInterval = setInterval(() => {
      this.updateGame();
    }, 100); // 每100ms更新一次
  }

  // 停止游戏循环
  private stopGameLoop(): void {
    if (this.gameInterval) {
      clearInterval(this.gameInterval);
      this.gameInterval = 0;
    }
  }

  // 游戏更新
  private updateGame(): void {
    if (!this.buildingManager) return;

    // 计算时间增量
    const now = Date.now();
    const deltaMs = now - this.lastUpdateTime;
    this.lastUpdateTime = now;

    // 更新建筑建造进度
    this.buildingManager.updateBuildProgress();

    // 更新电力系统
    if (this.powerManager) {
      this.powerManager.update();
    }

    // 检查并为矿场生成采矿车
    if (this.harvesterManager) {
      this.harvesterManager.checkAndSpawnHarvesters();

      // 获取生产速度倍率（考虑低电惩罚）
      let speedMultiplier = 1.0;
      if (this.powerManager) {
        speedMultiplier = this.powerManager.getProductionSpeedMultiplier();
      }

      // 更新采矿车，获取产生的资金（考虑低电惩罚）
      const adjustedDelta = deltaMs * speedMultiplier;
      const moneyEarned = this.harvesterManager.updateAll(adjustedDelta);
      if (moneyEarned > 0) {
        this.money += Math.floor(moneyEarned);
      }

      // 更新采矿车数量
      this.harvesterCount = this.harvesterManager.getHarvesterCount();
    }

    // 更新电力统计
    this.updatePowerStats();

    // 更新建筑数量
    this.buildingCount = this.buildingManager.getBuildingCount();

    // 更新矿石统计
    this.updateResourceStats();
  }

  // 更新资源统计
  private updateResourceStats(): void {
    if (!this.mapData) return;

    const oreTiles = this.mapData.getResourceTiles();
    this.oreNodeCount = oreTiles.length;
    this.totalOre = oreTiles.reduce((sum, tile) => sum + tile.resourceAmount, 0);
  }

  // 更新电力统计
  private updatePowerStats(): void {
    if (!this.powerManager) return;

    this.powerManager.update();
    const stats = this.powerManager.getPowerStats();
    this.powerSupply = stats.supply;
    this.powerDemand = stats.demand;
    this.powerBalance = stats.balance;
    this.powerStatus = this.powerManager.getPowerStatus();
  }

  // 渲染帧
  private renderFrame(): void {
    if (!this.context || !this.renderer || !this.camera) return;

    // 更新预览状态
    if (this.isBuildMode && this.selectedBuildingType && this.buildingManager) {
      const result = this.buildingManager.canPlaceBuilding(
        this.selectedBuildingType,
        this.previewGridX,
        this.previewGridY,
        this.money
      );
      this.renderer.setPlacementPreview(
        this.selectedBuildingType,
        this.previewGridX,
        this.previewGridY,
        result
      );
      this.canPlace = result === PlaceResult.SUCCESS;
    } else {
      this.renderer.clearPlacementPreview();
    }

    // 渲染
    this.renderer.render(this.context, this.screenWidth, this.screenHeight);

    // 更新调试信息
    const offset = this.camera.getOffset();
    this.cameraOffset = `${Math.round(offset[0])}, ${Math.round(offset[1])}`;

    // FPS 计算
    this.frameCount++;
    const now = Date.now();
    if (now - this.lastFpsTime >= 1000) {
      this.fps = this.frameCount;
      this.frameCount = 0;
      this.lastFpsTime = now;
    }
  }

  build() {
    Column() {
      // 顶部状态栏
      this.HUD()

      // 游戏画布
      Stack() {
        Canvas(this.context)
          .width('100%')
          .height('100%')
          .onReady(() => {
            console.info('[RedAlertLite] Canvas ready');
            this.renderFrame();
          })
          .onTouch((event: TouchEvent) => {
            this.handleTouch(event);
          })
      }
      .layoutWeight(1)
      .backgroundColor('#0a0a0a')

      // 建造面板
      this.BuildPanel()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0f111a')
  }

  @Builder
  HUD() {
    Column() {
      // 第一行：标题和返回按钮
      Row() {
        Button() {
          Text('←')
            .fontSize(20)
            .fontColor('#FFFFFF')
        }
        .width(44)
        .height(44)
        .borderRadius(22)
        .backgroundColor('rgba(255,255,255,0.15)')
        .onClick(() => {
          router.back();
        })

        Text('红警 Lite')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFD700')
          .margin({ left: 16 })

        Blank()

        Column() {
          Text(`相机: ${this.cameraOffset}`)
            .fontSize(10)
            .fontColor('#888888')
          Text(`FPS: ${this.fps}`)
            .fontSize(10)
            .fontColor('#888888')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })

      // 第二行：资源信息
      Row() {
        // 资金
        Row() {
          Text('💰')
            .fontSize(16)
          Text(`$${this.money}`)
            .fontSize(16)
            .fontColor('#FFD700')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 4 })
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('rgba(0,0,0,0.5)')
        .borderRadius(8)

        // 电力
        Row() {
          Text('⚡')
            .fontSize(16)
          Text(`${this.powerBalance}`)
            .fontSize(16)
            .fontColor(this.powerManager?.getStatusColor() || '#4CAF50')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 4 })

          // 低电警告图标
          if (this.powerStatus !== PowerStatus.NORMAL) {
            Text('⚠')
              .fontSize(14)
              .fontColor('#FF5722')
              .margin({ left: 4 })
          }
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(this.powerStatus === PowerStatus.NORMAL ? 'rgba(0,0,0,0.5)' : 'rgba(255,87,34,0.2)')
        .borderRadius(8)
        .margin({ left: 12 })

        // 建筑
        Row() {
          Text('🏠')
            .fontSize(14)
          Text(`${this.buildingCount}`)
            .fontSize(14)
            .fontColor('#87CEEB')
            .margin({ left: 4 })
        }
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor('rgba(0,0,0,0.5)')
        .borderRadius(6)
        .margin({ left: 12 })

        // 采矿车数量
        if (this.harvesterCount > 0) {
          Row() {
            Text('🚛')
              .fontSize(14)
            Text(`${this.harvesterCount}`)
              .fontSize(14)
              .fontColor('#d4a574')
              .margin({ left: 4 })
          }
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor('rgba(0,0,0,0.5)')
          .borderRadius(6)
          .margin({ left: 8 })
        }

        Blank()

        // 矿石统计
        Row() {
          Text('🔶')
            .fontSize(14)
          Text(`${this.oreNodeCount}矿`)
            .fontSize(12)
            .fontColor('#c9a66b')
            .margin({ left: 4 })
        }
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor('rgba(0,0,0,0.5)')
        .borderRadius(6)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 4, bottom: 8 })

      // 第三行：电力条
      this.PowerBar()
    }
    .width('100%')
    .backgroundColor('rgba(0,0,0,0.7)')
  }

  @Builder
  PowerBar() {
    Row() {
      Text('电力')
        .fontSize(12)
        .fontColor('#888888')
        .width(40)

      // 电力条背景
      Stack() {
        // 背景条
        Row()
          .width('100%')
          .height(8)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(4)

        // 需求条（红色）
        if (this.powerDemand > 0) {
          Row()
            .width(`${Math.min(100, (this.powerDemand / Math.max(this.powerSupply, this.powerDemand, 1)) * 100)}%`)
            .height(8)
            .backgroundColor(this.powerSupply >= this.powerDemand ? 'rgba(255,87,34,0.3)' : 'rgba(255,87,34,0.8)')
            .borderRadius(4)
        }

        // 供应条（绿色）
        if (this.powerSupply > 0) {
          Row()
            .width(`${Math.min(100, (this.powerSupply / Math.max(this.powerSupply, this.powerDemand, 1)) * 100)}%`)
            .height(8)
            .backgroundColor(this.powerStatus === PowerStatus.NORMAL ? '#4CAF50' :
                            this.powerStatus === PowerStatus.LOW ? '#FF9800' : '#FF5722')
            .borderRadius(4)
        }
      }
      .width(200)

      // 状态文字
      Text(this.powerManager?.getStatusDescription() || '电力正常')
        .fontSize(10)
        .fontColor(this.powerManager?.getStatusColor() || '#4CAF50')
        .margin({ left: 8 })
        .width(80)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 2, bottom: 6 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  BuildPanel() {
    Column() {
      // 建造模式提示
      if (this.isBuildMode) {
        Row() {
          Text(`放置: ${this.selectedBuildingType ? BUILDING_CONFIGS[this.selectedBuildingType].name : ''}`)
            .fontSize(14)
            .fontColor('#FFD700')

          Blank()

          Text(this.canPlace ? '✓ 可放置' : '✗ 不可放置')
            .fontSize(12)
            .fontColor(this.canPlace ? '#4CAF50' : '#FF5722')

          Button('取消')
            .fontSize(12)
            .height(28)
            .backgroundColor('rgba(255,255,255,0.2)')
            .margin({ left: 12 })
            .onClick(() => {
              this.isBuildMode = false;
              this.selectedBuildingType = null;
              this.renderFrame();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('rgba(0,0,0,0.8)')
      }

      // 建筑按钮列表
      Row() {
        this.BuildButton(BuildingType.POWER_PLANT, '电厂', '⚡', 500)
        this.BuildButton(BuildingType.REFINERY, '矿场', '🏭', 1500)
        this.BuildButton(BuildingType.BARRACKS, '兵营', '🎖️', 800)
        this.BuildButton(BuildingType.WAR_FACTORY, '战车厂', '🏭', 2000)
      }
      .width('100%')
      .padding(8)
      .justifyContent(FlexAlign.SpaceEvenly)
      .backgroundColor('rgba(0,0,0,0.7)')
    }
  }

  @Builder
  BuildButton(type: BuildingType, name: string, icon: string, cost: number) {
    Column() {
      Text(icon)
        .fontSize(24)
      Text(name)
        .fontSize(11)
        .fontColor('#FFFFFF')
        .margin({ top: 2 })
      Text(`$${cost}`)
        .fontSize(10)
        .fontColor(this.money >= cost ? '#4CAF50' : '#FF5722')
    }
    .width(70)
    .height(70)
    .padding(4)
    .borderRadius(8)
    .backgroundColor(this.selectedBuildingType === type ? 'rgba(255,200,0,0.3)' : 'rgba(255,255,255,0.1)')
    .border({
      width: this.selectedBuildingType === type ? 2 : 1,
      color: this.selectedBuildingType === type ? '#FFD700' : 'rgba(255,255,255,0.2)'
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.money >= cost) {
        this.isBuildMode = true;
        this.selectedBuildingType = type;
        this.renderFrame();
      }
    })
  }

  // 触摸处理
  private handleTouch(event: TouchEvent): void {
    if (!this.camera) return;

    const touch = event.touches[0];
    const x = touch.x;
    const y = touch.y;

    switch (event.type) {
      case TouchType.Down:
        this.isDragging = true;
        this.lastX = x;
        this.lastY = y;

        if (this.isBuildMode) {
          // 建造模式下更新预览位置
          this.updatePreviewPosition(x, y);
        } else {
          this.camera.startDrag(x, y);
        }
        break;

      case TouchType.Move:
        if (this.isDragging) {
          if (this.isBuildMode) {
            // 建造模式下更新预览位置
            this.updatePreviewPosition(x, y);
          } else {
            this.camera.drag(x, y);
          }
          this.lastX = x;
          this.lastY = y;
          this.renderFrame();
        }
        break;

      case TouchType.Up:
        if (this.isBuildMode && this.selectedBuildingType && this.canPlace && this.buildingManager) {
          // 放置建筑
          const config = BUILDING_CONFIGS[this.selectedBuildingType];
          const result = this.buildingManager.canPlaceBuilding(
            this.selectedBuildingType,
            this.previewGridX,
            this.previewGridY,
            this.money
          );

          if (result === PlaceResult.SUCCESS) {
            this.buildingManager.placeBuilding(
              this.selectedBuildingType,
              this.previewGridX,
              this.previewGridY,
              'player'
            );
            this.money -= config.cost;
            this.isBuildMode = false;
            this.selectedBuildingType = null;
          }
        }
        this.isDragging = false;
        this.camera.endDrag();
        this.renderFrame();
        break;

      case TouchType.Cancel:
        this.isDragging = false;
        this.camera.endDrag();
        break;
    }
  }

  // 更新预览位置
  private updatePreviewPosition(screenX: number, screenY: number): void {
    if (!this.camera || !this.selectedBuildingType) return;

    const worldPos = this.camera.screenToWorld(screenX, screenY);
    const config = BUILDING_CONFIGS[this.selectedBuildingType];
    const gridSize = config.gridSize;
    const gridWidth = gridSize[0];
    const gridHeight = gridSize[1];

    // 计算格子位置（居中对齐）
    this.previewGridX = Math.floor(worldPos[0] / TILE_SIZE - gridWidth / 2);
    this.previewGridY = Math.floor(worldPos[1] / TILE_SIZE - gridHeight / 2);
  }
}
