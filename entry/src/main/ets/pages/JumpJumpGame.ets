import { GameViewModel } from '../games/jumpjump/viewmodel/GameViewModel';
import { GameRenderer } from '../games/jumpjump/view/GameRenderer';
import { GameState } from '../games/jumpjump/model/GameState';
import { GameConstants } from '../games/jumpjump/model/GameConstants';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct JumpJumpGame {
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
        .backgroundColor('rgba(0,0,0,0.2)')
        .borderRadius(20)
        .height(36)
        .padding({ left: 15, right: 15 })
        .onClick(() => { router.back(); })
      }
      .width('100%')
      .padding({ left: 20, top: 50 })

      Text('跳一跳')
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C2C2C')
        .margin({ top: 50, bottom: 20 })

      // 玩家图标
      Column() {
        Column()
          .width(50)
          .height(60)
          .borderRadius(25)
          .backgroundColor('#2C2C2C')
      }
      .margin({ bottom: 40 })

      Text('按住屏幕蓄力')
        .fontSize(18)
        .fontColor('#666666')
        .margin({ bottom: 8 })

      Text('松开后跳跃到下一个方块')
        .fontSize(18)
        .fontColor('#666666')
        .margin({ bottom: 40 })

      Button('开始游戏')
        .fontSize(22)
        .fontColor('#FFFFFF')
        .backgroundColor('#4CAF50')
        .borderRadius(30)
        .width(180)
        .height(50)
        .onClick(() => { this.startGame(); })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [['#F5DEB3', 0.0], ['#DEB887', 1.0]]
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
        .onTouch((event: TouchEvent) => { this.onCanvasTouch(event); })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#DEB887')
  }

  private startGame(): void {
    this.isPlaying = true;
    this.viewModel = new GameViewModel();
  }

  private onCanvasReady(): void {
    if (this.renderInterval !== null) {
      clearInterval(this.renderInterval);
    }
    this.renderInterval = setInterval(() => { this.render(); }, 1000 / 60);
  }

  private onCanvasTouch(event: TouchEvent): void {
    const state = this.viewModel.gameState;

    if (state === GameState.IDLE) {
      // 点击开始游戏
      this.viewModel.startGame();
    } else if (state === GameState.PLAYING) {
      // 按下开始蓄力
      if (event.type === TouchType.Down) {
        this.viewModel.startCharge();
      }
    } else if (state === GameState.CHARGING) {
      // 松开释放跳跃
      if (event.type === TouchType.Up) {
        this.viewModel.releaseJump();
      }
    } else if (state === GameState.GAME_OVER) {
      // 点击重新开始
      if (event.type === TouchType.Up) {
        this.cleanup();
        this.isPlaying = false;
      }
    }
  }

  private render(): void {
    this.renderer.render(
      this.canvasContext,
      this.viewModel.player,
      this.viewModel.platforms,
      this.viewModel.score,
      this.viewModel.gameState,
      this.viewModel.cameraOffsetX,
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
