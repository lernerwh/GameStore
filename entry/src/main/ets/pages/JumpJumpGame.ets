import { GameViewModel } from '../games/jumpjump/viewmodel/GameViewModel';
import { GameRenderer } from '../games/jumpjump/view/GameRenderer';
import { GameState } from '../games/jumpjump/model/GameState';
import { GameConstants } from '../games/jumpjump/model/GameConstants';
import { router } from '@kit.ArkUI';

interface PageParams {
  autoStart?: boolean;
}

@Entry
@Component
struct JumpJumpGame {
  @State isPlaying: boolean = false;
  @State viewModel: GameViewModel = new GameViewModel();
  @State buttonScale: number = 1.0;
  private renderer: GameRenderer = new GameRenderer();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private renderInterval: number | null = null;

  aboutToAppear(): void {
    const params = router.getParams() as PageParams;
    if (params?.autoStart) {
      this.startGame();
    }
  }

  aboutToDisappear(): void {
    this.cleanup();
  }

  build() {
    Stack() {
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
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#CFD1D9')

      Button('← 返回')
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('rgba(0,0,0,0.2)')
        .borderRadius(20)
        .height(36)
        .padding({ left: 15, right: 15 })
        .position({ x: 20, y: 56 })
        .onClick(() => { router.back(); })

      Column({ space: 22 }) {
        Text('跳一跳')
          .fontSize(58)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textShadow({ radius: 2, color: 'rgba(0,0,0,0.12)', offsetX: 0, offsetY: 1 })

        // 首页棋子+方块示意
        Stack() {
          Column()
            .width(96)
            .height(52)
            .backgroundColor('#8F8F8F')
            .position({ y: 30 })

          Column()
            .width(96)
            .height(18)
            .backgroundColor('#BBBBBB')
            .position({ y: 16 })

          Column()
            .width(96)
            .height(36)
            .backgroundColor('#E8E8E8')

          Column()
            .width(30)
            .height(40)
            .backgroundColor('#2C2A49')
            .borderRadius(15)
            .position({ y: -12 })

          Column()
            .width(18)
            .height(18)
            .backgroundColor('#3F3D67')
            .borderRadius(9)
            .position({ y: -32 })
        }
        .width(130)
        .height(120)

        Button() {
          Row({ space: 8 }) {
            Text('▶')
              .fontSize(18)
              .fontColor('#66C58B')
            Text('开始游戏')
              .fontSize(33)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E1F24')
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
        }
        .width(220)
        .height(56)
        .backgroundColor('#FFFFFF')
        .borderRadius(28)
        .scale({ x: this.buttonScale, y: this.buttonScale })
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.16)', offsetX: 0, offsetY: 3 })
        .onClick(() => {
          this.buttonScale = 0.96;
          setTimeout(() => {
            this.buttonScale = 1.0;
            this.startGame();
          }, 90);
        })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  GameView() {
    Stack() {
      Canvas(this.canvasContext)
        .width(GameConstants.CANVAS_WIDTH)
        .height(GameConstants.CANVAS_HEIGHT)
        .onReady(() => { this.onCanvasReady(); })

      Column() {
        Row({ space: 10 }) {
          Button('⌂')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('rgba(22,24,31,0.45)')
            .borderRadius(18)
            .width(36)
            .height(36)
            .onClick(() => { this.backToHome(); })

          Button('↻')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('rgba(46,132,83,0.72)')
            .borderRadius(18)
            .width(36)
            .height(36)
            .onClick(() => { this.restartGame(); })
        }
        .margin({ left: 14, top: 48 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#CFD1D9')
    .onTouch((event: TouchEvent) => { this.onCanvasTouch(event); })
  }

  private startGame(): void {
    this.isPlaying = true;
    this.viewModel = new GameViewModel();
  }

  private restartGame(): void {
    this.viewModel = new GameViewModel();
    this.viewModel.startGame();
  }

  private backToHome(): void {
    this.cleanup();
    this.isPlaying = false;
    this.viewModel = new GameViewModel();
  }

  private onCanvasReady(): void {
    if (this.renderInterval !== null) {
      clearInterval(this.renderInterval);
    }
    this.renderInterval = setInterval(() => { this.render(); }, 1000 / 60);
  }

  private onCanvasTouch(event: TouchEvent): void {
    if (event.touches.length === 0) {
      return;
    }
    const touch = event.touches[0];

    // 避免与左上角控制按钮区域冲突
    if (touch.x <= 132 && touch.y <= 120) {
      return;
    }

    const state = this.viewModel.gameState;

    if (state === GameState.IDLE && event.type === TouchType.Up) {
      this.viewModel.startGame();
      return;
    }

    if (state === GameState.PLAYING && event.type === TouchType.Down) {
      this.viewModel.startCharge();
      return;
    }

    if (state === GameState.CHARGING && event.type === TouchType.Up) {
      this.viewModel.releaseJump();
      return;
    }

    if (state === GameState.GAME_OVER && event.type === TouchType.Up) {
      this.cleanup();
      this.isPlaying = false;
    }
  }

  private render(): void {
    this.renderer.render(
      this.canvasContext,
      this.viewModel.player,
      this.viewModel.platforms,
      this.viewModel.score,
      this.viewModel.gameState,
      this.viewModel.cameraWorldX,
      this.viewModel.cameraWorldY,
      this.viewModel.chargeProgress
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
