import { GameViewModel } from '../games/animalrestaurant/viewmodel/GameViewModel';
import { GameRenderer } from '../games/animalrestaurant/view/GameRenderer';
import { GameState } from '../games/animalrestaurant/model/GameConstants';
import { Table } from '../games/animalrestaurant/model/Table';
import { Dish } from '../games/animalrestaurant/model/Dish';
import { Customer } from '../games/animalrestaurant/model/Customer';
import { MathUtils, Point } from '../games/animalrestaurant/model/MathUtils';
import { GameConstants } from '../games/animalrestaurant/model/GameConstants';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct AnimalRestaurantGame {
  @State isPlaying: boolean = false;
  @State viewModel: GameViewModel = new GameViewModel();

  private renderer: GameRenderer = new GameRenderer();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private renderInterval: number | null = null;

  aboutToDisappear(): void {
    this.cleanup();
  }

  build() {
    Column() {
      if (!this.isPlaying) {
        this.HomeView();
      } else {
        this.GameView();
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HomeView() {
    Column() {
      // 返回按钮
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(16)
            .fontColor('#FFFFFF')
        }
        .backgroundColor('rgba(255,255,255,0.1)')
        .borderRadius(20)
        .height(36)
        .padding({ left: 15, right: 15 })
        .onClick(() => { router.back(); })
      }
      .width('100%')
      .padding({ left: 20, top: 50 })

      Text('🐾 动物餐厅 🐾')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#8B4513')
        .margin({ top: 30, bottom: 10 })

      Text('Animal Restaurant')
        .fontSize(16)
        .fontColor('#A0522D')
        .margin({ bottom: 30 })

      // 可爱的动物图标
      Row() {
        Text('🐱').fontSize(40)
        Text('🐕').fontSize(40)
        Text('🐰').fontSize(40)
        Text('🐻').fontSize(40)
        Text('🦊').fontSize(40)
        Text('🐼').fontSize(40)
      }
      .margin({ bottom: 30 })

      // 游戏简介
      Column() {
        Text('欢迎来到温馨的动物餐厅！')
          .fontSize(18)
          .fontColor('#5D4037')
          .margin({ bottom: 10 })

        Text('招待可爱的动物顾客')
          .fontSize(14)
          .fontColor('#795548')
        Text('烹饪美味的菜肴')
          .fontSize(14)
          .fontColor('#795548')
        Text('赚取金币升级餐厅')
          .fontSize(14)
          .fontColor('#795548')
      }
      .margin({ bottom: 40 })

      // 开始按钮
      Button('开始营业')
        .fontSize(24)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF9800')
        .borderRadius(30)
        .width(200)
        .height(50)
        .shadow({ radius: 10, color: '#FF9800', offsetX: 0, offsetY: 5 })
        .onClick(() => { this.startGame(); })

      // 提示
      Text('点击画面与游戏互动')
        .fontSize(12)
        .fontColor('#9E9E9E')
        .margin({ top: 30 })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [['#FFF8E7', 0.0], ['#FFE4C4', 0.5], ['#FFDAB9', 1.0]]
    })
  }

  @Builder
  GameView() {
    Column() {
      Canvas(this.canvasContext)
        .width(GameConstants.CANVAS_WIDTH)
        .height(GameConstants.CANVAS_HEIGHT)
        .backgroundColor(GameConstants.COLOR_BACKGROUND)
        .onReady(() => { this.onCanvasReady(); })
        .onClick((event) => { this.onCanvasClick(event.x, event.y); })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5DC')
  }

  private startGame(): void {
    this.isPlaying = true;
    this.viewModel = new GameViewModel();
  }

  private onCanvasReady(): void {
    if (this.renderInterval !== null) {
      clearInterval(this.renderInterval);
    }

    // 立即开始游戏
    this.viewModel.startGame();

    // 启动渲染循环
    this.renderInterval = setInterval(() => { this.render(); }, 1000 / 60);
  }

  private onCanvasClick(x: number, y: number): void {
    const state = this.viewModel.gameState;

    if (state === GameState.IDLE) {
      this.viewModel.startGame();
      return;
    }

    if (state === GameState.PAUSED) {
      this.viewModel.resumeGame();
      return;
    }

    if (state === GameState.PLAYING) {
      // 检查点击的是菜品、餐桌还是顾客
      const clickPoint: Point = { x, y };

      // 优先检查菜品（准备好的菜品需要点击上菜）
      const dishes = this.viewModel.getDishes();
      for (const dish of dishes) {
        if (dish.isReady()) {
          const rect = dish.getCollisionRect();
          if (MathUtils.isPointInRect(clickPoint, rect)) {
            this.viewModel.clickDish(dish.id);
            return;
          }
        }
      }

      // 检查餐桌（需要清理的餐桌）
      const tables = this.viewModel.getTables();
      for (const table of tables) {
        const rect = table.getCollisionRect();
        if (MathUtils.isPointInRect(clickPoint, rect)) {
          this.viewModel.clickTable(table.id);
          return;
        }
      }

      // 检查顾客（可以安抚等待的顾客）
      const customers = this.viewModel.getAllCustomers();
      for (const customer of customers) {
        const rect = customer.getCollisionRect();
        if (MathUtils.isPointInRect(clickPoint, rect)) {
          this.viewModel.clickCustomer(customer.id);
          return;
        }
      }
    }
  }

  private render(): void {
    const engine = this.viewModel.getEngine();
    this.renderer.render(
      this.canvasContext,
      this.viewModel.getTables(),
      this.viewModel.getWaitingCustomers(),
      this.viewModel.getAllCustomers(),
      this.viewModel.getDishes(),
      this.viewModel.getRestaurant(),
      this.viewModel.gameState
    );
  }

  private cleanup(): void {
    if (this.renderInterval !== null) {
      clearInterval(this.renderInterval);
      this.renderInterval = null;
    }
    this.viewModel.destroy();
  }
}
