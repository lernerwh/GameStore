import { GameViewModel } from '../games/dragon/viewmodel/GameViewModel';
import { GameRenderer } from '../games/dragon/view/GameRenderer';
import { GameState } from '../model/GameState';
import { GameConstants } from '../common/constants/GameConstants';
import { ImageManager } from '../common/utils/ImageManager';
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct DragonGame {
  @State isPlaying: boolean = false;
  @State viewModel: GameViewModel = new GameViewModel();
  private renderer: GameRenderer = new GameRenderer();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private renderInterval: number | null = null;
  private imageManager: ImageManager = ImageManager.getInstance();

  aboutToAppear(): void {
    // 初始化图片管理器
    this.initImageManager();
  }

  aboutToDisappear(): void {
    this.cleanup();
  }

  private async initImageManager(): Promise<void> {
    try {
      // 使用 UIContext 获取 context
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await this.imageManager.init(context);
    } catch (e) {
      console.error('Failed to initialize ImageManager:', e);
    }
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

      Text('召唤神龙')
        .fontSize(42)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFD700')
        .textShadow({ radius: 10, color: '#FF6B00', offsetX: 0, offsetY: 0 })
        .margin({ top: 30, bottom: 20 })

      Text('🐉')
        .fontSize(80)
        .margin({ bottom: 30 })

      Text('进化成长游戏')
        .fontSize(18)
        .fontColor('#AAAAAA')
        .margin({ bottom: 10 })

      Text('从浮游生物进化成神龙!')
        .fontSize(16)
        .fontColor('#888888')
        .margin({ bottom: 50 })

      Column() {
        Text('游戏规则:')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .margin({ bottom: 15 })

        Text('• 点击屏幕控制移动方向')
          .fontSize(14)
          .fontColor('#CCCCCC')
          .margin({ bottom: 8 })

        Text('• 吃掉比你小的生物成长')
          .fontSize(14)
          .fontColor('#90EE90')
          .margin({ bottom: 8 })

        Text('• 躲避比你大的生物')
          .fontSize(14)
          .fontColor('#FF6B6B')
          .margin({ bottom: 8 })

        Text('• 目标：进化成神龙!')
          .fontSize(14)
          .fontColor('#FFD700')
          .margin({ bottom: 20 })
      }
      .padding(20)
      .backgroundColor('rgba(255,255,255,0.1)')
      .borderRadius(15)
      .margin({ bottom: 40 })

      Button('开始游戏')
        .fontSize(22)
        .fontColor('#FFFFFF')
        .backgroundColor('#4CAF50')
        .borderRadius(30)
        .width(180)
        .height(50)
        .shadow({ radius: 15, color: '#4CAF50', offsetX: 0, offsetY: 5 })
        .onClick(() => { this.startGame(); })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [['#0a1628', 0.0], ['#1a4a7a', 0.5], ['#0d2847', 1.0]]
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
    this.viewModel = new GameViewModel();
  }

  private onCanvasReady(): void {
    if (this.renderInterval !== null) {
      clearInterval(this.renderInterval);
    }
    this.renderInterval = setInterval(() => { this.render(); }, 1000 / 60);
  }

  private onCanvasClick(event: ClickEvent): void {
    const state = this.viewModel.gameState;
    if (state === GameState.IDLE) {
      this.viewModel.startGame();
    } else if (state === GameState.GAME_OVER) {
      this.cleanup();
      this.isPlaying = false;
    } else {
      // 游戏中，设置移动目标
      this.viewModel.setPlayerTarget(event.x, event.y);
    }
  }

  private onCanvasTouch(event: TouchEvent): void {
    if (this.viewModel.gameState !== GameState.PLAYING) {
      return;
    }

    if (event.type === TouchType.Move || event.type === TouchType.Down) {
      this.viewModel.setPlayerTarget(event.touches[0].x, event.touches[0].y);
    }
  }

  private render(): void {
    this.renderer.render(
      this.canvasContext,
      this.viewModel.player,
      this.viewModel.creatures,
      this.viewModel.score,
      this.viewModel.gameState,
      this.viewModel.hasWon,
      this.viewModel.playTime,
      this.viewModel.getCamera()
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
