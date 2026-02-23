import { GameViewModel } from '../games/animalrestaurant/viewmodel/GameViewModel';
import { GameRenderer } from '../games/animalrestaurant/view/GameRenderer';
import { GameState } from '../games/animalrestaurant/model/GameConstants';
import { Table } from '../games/animalrestaurant/model/Table';
import { Dish } from '../games/animalrestaurant/model/Dish';
import { Customer } from '../games/animalrestaurant/model/Customer';
import { MathUtils, Point } from '../games/animalrestaurant/model/MathUtils';
import { GameConstants } from '../games/animalrestaurant/model/GameConstants';
import { router } from '@kit.ArkUI';

interface PageParams {
  autoStart?: boolean;
}

@Entry
@Component
struct AnimalRestaurantGame {
  @State isPlaying: boolean = false;
  @State viewModel: GameViewModel = new GameViewModel();
  @State isPaused: boolean = false;
  @State soundEnabled: boolean = true;
  @State buttonScale: number = 1.0;
  @State animalFloatOffset: number = 0.0;

  private renderer: GameRenderer = new GameRenderer();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private renderInterval: number | null = null;
  private animationInterval: number | null = null;

  aboutToAppear(): void {
    // 检查是否需要自动开始游戏
    const params = router.getParams() as PageParams;
    if (params?.autoStart) {
      this.startGame();
    }
    this.startAnimalAnimation();
  }

  aboutToDisappear(): void {
    this.cleanup();
    this.stopAnimalAnimation();
  }

  private startAnimalAnimation(): void {
    this.animationInterval = setInterval(() => {
      this.animalFloatOffset = Math.sin(Date.now() / 500) * 5;
    }, 50);
  }

  private stopAnimalAnimation(): void {
    if (this.animationInterval !== null) {
      clearInterval(this.animationInterval);
      this.animationInterval = null;
    }
  }

  private playSound(type: string): void {
    if (!this.soundEnabled) return;
    // 可以在此添加实际音效播放代码
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
      Scroll() {
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
            Text('🐱').fontSize(40).offset({ y: this.animalFloatOffset })
            Text('🐕').fontSize(40).offset({ y: -this.animalFloatOffset })
            Text('🐰').fontSize(40).offset({ y: this.animalFloatOffset })
            Text('🐻').fontSize(40).offset({ y: -this.animalFloatOffset })
            Text('🦊').fontSize(40).offset({ y: this.animalFloatOffset })
            Text('🐼').fontSize(40).offset({ y: -this.animalFloatOffset })
          }
          .margin({ bottom: 30 })

          Row({ space: 10 }) {
            Text('经营养成')
              .fontSize(12)
              .fontColor('#6d4c41')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('rgba(255,152,0,0.2)')
              .borderRadius(14)
            Text('顾客互动')
              .fontSize(12)
              .fontColor('#6d4c41')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('rgba(255,152,0,0.2)')
              .borderRadius(14)
          }
          .margin({ bottom: 20 })

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
            .scale({ x: this.buttonScale, y: this.buttonScale })
            .onClick(() => {
              this.playSound('click');
              this.buttonScale = 0.95;
              setTimeout(() => {
                this.buttonScale = 1.0;
                this.startGame();
              }, 150);
            })

          // 提示
          Text('点击画面与游戏互动')
            .fontSize(12)
            .fontColor('#9E9E9E')
            .margin({ top: 30 })
        }
        .width('100%')
        .padding({ bottom: 48 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
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
    Stack() {
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

      // 控制按钮层
      Column() {
        Row() {
          Button('主页')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('rgba(141,110,99,0.92)')
            .borderRadius(18)
            .height(36)
            .onClick(() => {
              this.backToHome();
            })

          Button('重开')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('rgba(255,152,0,0.95)')
            .borderRadius(18)
            .height(36)
            .margin({ left: 8 })
            .onClick(() => {
              this.restartGame();
            })

          Text(`金币 ${this.viewModel.coins}`)
            .fontSize(14)
            .fontColor('#5d4037')
            .backgroundColor('rgba(255,255,255,0.78)')
            .borderRadius(14)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ left: 8, right: 8 })

          Text(this.isPaused ? '暂停中' : '营业中')
            .fontSize(12)
            .fontColor(this.isPaused ? '#d84315' : '#2e7d32')
            .backgroundColor('rgba(255,255,255,0.82)')
            .borderRadius(12)
            .padding({ left: 8, right: 8, top: 6, bottom: 6 })
            .margin({ right: 8 })

          Button() {
            Text('⏸️')
              .fontSize(24)
          }
          .backgroundColor('rgba(255,255,255,0.8)')
          .borderRadius(20)
          .width(40)
          .height(40)
          .onClick(() => {
            this.playSound('click');
            this.isPaused = !this.isPaused;
            if (this.isPaused) {
              this.viewModel.pauseGame();
            } else {
              this.viewModel.resumeGame();
            }
          })

          Button() {
            Text(this.soundEnabled ? '🔊' : '🔇')
              .fontSize(24)
          }
          .backgroundColor('rgba(255,255,255,0.8)')
          .borderRadius(20)
          .width(40)
          .height(40)
          .margin({ left: 10 })
          .onClick(() => {
            this.playSound('click');
            this.soundEnabled = !this.soundEnabled;
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 50 })
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
    .width('100%')
    .height('100%')
  }

  private startGame(): void {
    this.viewModel.destroy();
    this.isPlaying = true;
    this.viewModel = new GameViewModel();
    this.isPaused = false;
  }

  private restartGame(): void {
    this.viewModel.destroy();
    this.viewModel = new GameViewModel();
    this.viewModel.startGame();
    this.isPaused = false;
  }

  private backToHome(): void {
    this.cleanup();
    this.isPlaying = false;
    this.isPaused = false;
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
      this.playSound('start');
      this.viewModel.startGame();
      return;
    }

    if (state === GameState.PAUSED) {
      this.playSound('resume');
      this.viewModel.resumeGame();
      return;
    }

    if (state === GameState.PLAYING) {
      // 检查点击的是菜品、餐桌还是顾客
      const clickPoint: Point = { x, y };
      let clicked = false;

      // 优先检查菜品（准备好的菜品需要点击上菜）
      const dishes = this.viewModel.getDishes();
      for (const dish of dishes) {
        if (dish.isReady()) {
          const rect = dish.getCollisionRect();
          if (MathUtils.isPointInRect(clickPoint, rect)) {
            this.playSound('serve');
            this.viewModel.clickDish(dish.id);
            this.showClickRipple(x, y);
            clicked = true;
            break;
          }
        }
      }

      // 检查餐桌（需要清理的餐桌）
      if (!clicked) {
        const tables = this.viewModel.getTables();
        for (const table of tables) {
          const rect = table.getCollisionRect();
          if (MathUtils.isPointInRect(clickPoint, rect)) {
            this.playSound('clean');
            this.viewModel.clickTable(table.id);
            this.showClickRipple(x, y);
            clicked = true;
            break;
          }
        }
      }

      // 检查顾客（可以安抚等待的顾客）
      if (!clicked) {
        const customers = this.viewModel.getAllCustomers();
        for (const customer of customers) {
          const rect = customer.getCollisionRect();
          if (MathUtils.isPointInRect(clickPoint, rect)) {
            this.playSound('pet');
            this.viewModel.clickCustomer(customer.id);
            this.showClickRipple(x, y);
            break;
          }
        }
      }
    }
  }

  private showClickRipple(x: number, y: number): void {
    // 可以在此添加波纹动画效果
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
