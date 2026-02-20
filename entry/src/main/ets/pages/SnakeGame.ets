import { SnakeViewModel } from '../games/snake/viewmodel/SnakeViewModel';
import { SnakeRenderer } from '../games/snake/view/SnakeRenderer';
import { SnakeState } from '../games/snake/model/SnakeState';
import { SnakeConstants } from '../games/snake/model/SnakeConstants';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct SnakeGame {
  @State isPlaying: boolean = false;
  @State viewModel: SnakeViewModel = new SnakeViewModel();
  private renderer: SnakeRenderer = new SnakeRenderer();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private gameInterval: number | null = null;
  private touchStartX: number = 0;
  private touchStartY: number = 0;

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

      Text('贪吃蛇')
        .fontSize(42)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4ade80')
        .textShadow({ radius: 10, color: '#22c55e', offsetX: 0, offsetY: 0 })
        .margin({ top: 30, bottom: 20 })

      Text('🐍')
        .fontSize(80)
        .margin({ bottom: 30 })

      Text('经典街机游戏')
        .fontSize(18)
        .fontColor('#AAAAAA')
        .margin({ bottom: 10 })

      Text('吃掉食物，不断成长!')
        .fontSize(16)
        .fontColor('#888888')
        .margin({ bottom: 50 })

      Column() {
        Text('游戏规则:')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .margin({ bottom: 15 })

        Text('• 滑动屏幕控制方向')
          .fontSize(14)
          .fontColor('#CCCCCC')
          .margin({ bottom: 8 })

        Text('• 吃掉红色食物得分')
          .fontSize(14)
          .fontColor('#ef4444')
          .margin({ bottom: 8 })

        Text('• 不要撞墙或撞到自己')
          .fontSize(14)
          .fontColor('#FF6B6B')
          .margin({ bottom: 8 })

        Text('• 蛇越长，挑战越大!')
          .fontSize(14)
          .fontColor('#4ade80')
          .margin({ bottom: 20 })
      }
      .padding(20)
      .backgroundColor('rgba(255,255,255,0.1)')
      .borderRadius(15)
      .margin({ bottom: 40 })

      Button('开始游戏')
        .fontSize(22)
        .fontColor('#FFFFFF')
        .backgroundColor('#22c55e')
        .borderRadius(30)
        .width(180)
        .height(50)
        .shadow({ radius: 15, color: '#22c55e', offsetX: 0, offsetY: 5 })
        .onClick(() => { this.startGame(); })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [['#0a1628', 0.0], ['#1a3a2a', 0.5], ['#0d2820', 1.0]]
    })
  }

  @Builder
  GameView() {
    Column() {
      Canvas(this.canvasContext)
        .width(SnakeConstants.CANVAS_WIDTH)
        .height(SnakeConstants.CANVAS_HEIGHT)
        .backgroundColor(SnakeConstants.COLOR_BACKGROUND)
        .onReady(() => { this.onCanvasReady(); })
        .onClick((event) => { this.onCanvasClick(event); })
        .onTouch((event) => { this.onCanvasTouch(event); })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#0a1628')
  }

  private startGame(): void {
    this.isPlaying = true;
    this.viewModel = new SnakeViewModel();
  }

  private onCanvasReady(): void {
    if (this.gameInterval !== null) {
      clearInterval(this.gameInterval);
    }
    this.gameInterval = setInterval(() => {
      this.gameLoop();
    }, SnakeConstants.GAME_SPEED);
  }

  private gameLoop(): void {
    this.viewModel.update();
    this.renderer.render(
      this.canvasContext,
      this.viewModel.snake,
      this.viewModel.food,
      this.viewModel.score,
      this.viewModel.gameState
    );
  }

  private onCanvasClick(event: ClickEvent): void {
    const state = this.viewModel.gameState;
    if (state === SnakeState.IDLE) {
      this.viewModel.startGame();
    } else if (state === SnakeState.GAME_OVER) {
      this.viewModel.startGame();
    }
  }

  private onCanvasTouch(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.touchStartX = event.touches[0].x;
      this.touchStartY = event.touches[0].y;

      // 点击开始游戏
      if (this.viewModel.gameState === SnakeState.IDLE) {
        this.viewModel.startGame();
      }
    } else if (event.type === TouchType.Up) {
      const endX = event.touches[0].x;
      const endY = event.touches[0].y;
      this.viewModel.handleSwipe(this.touchStartX, this.touchStartY, endX, endY);
    }
  }

  private cleanup(): void {
    if (this.gameInterval !== null) {
      clearInterval(this.gameInterval);
      this.gameInterval = null;
    }
    this.viewModel.destroy();
  }
}
