import { GameViewModel } from '../games/dragon/viewmodel/GameViewModel';
import { GameRenderer, JoystickRenderState } from '../games/dragon/view/GameRenderer';
import { GameState } from '../model/GameState';
import { GameConstants } from '../common/constants/GameConstants';
import { ImageManager } from '../common/utils/ImageManager';
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';

interface PageParams {
  autoStart?: boolean;
}

@Entry
@Component
struct DragonGame {
  @State isPlaying: boolean = false;
  @State viewModel: GameViewModel = new GameViewModel();
  @State isPaused: boolean = false;
  @State buttonScale: number = 1.0;
  @State heroFloatOffset: number = 0.0;
  private renderer: GameRenderer = new GameRenderer();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private renderInterval: number | null = null;
  private animationInterval: number | null = null;
  private imageManager: ImageManager = ImageManager.getInstance();
  private joystickMaxDistance: number = 90;
  @State joystickState: JoystickRenderState = {
    active: false,
    centerX: 0,
    centerY: 0,
    handleX: 0,
    handleY: 0
  };

  aboutToAppear(): void {
    // 初始化图片管理器
    this.initImageManager();

    // 检查是否需要自动开始游戏
    const params = router.getParams() as PageParams;
    if (params?.autoStart) {
      this.startGame();
    }

    // 启动主页浮动动画
    this.startHeroAnimation();
  }

  aboutToDisappear(): void {
    this.cleanup();
    this.stopHeroAnimation();
  }

  private startHeroAnimation(): void {
    this.animationInterval = setInterval(() => {
      this.heroFloatOffset = Math.sin(Date.now() / 500) * 5;
    }, 50);
  }

  private stopHeroAnimation(): void {
    if (this.animationInterval !== null) {
      clearInterval(this.animationInterval);
      this.animationInterval = null;
    }
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
      Scroll() {
        Column() {
          // 返回按钮
          Row() {
            Button() {
              Text('← 返回')
                .fontSize(20)
                .fontColor('#FFFFFF')
            }
            .backgroundColor('rgba(255,255,255,0.1)')
            .borderRadius(20)
            .height(40)
            .padding({ left: 18, right: 18 })
            .onClick(() => { router.back(); })
          }
          .width('100%')
          .padding({ left: 20, top: 50 })

          Text('球球大作战')
            .fontSize(52)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E0F2FE')
            .textShadow({ radius: 12, color: '#22D3EE', offsetX: 0, offsetY: 0 })
            .margin({ top: 30, bottom: 20 })

          Row({ space: 12 }) {
            Text('⚪')
              .fontSize(64)
            Text('🔵')
              .fontSize(76)
            Text('🟢')
              .fontSize(58)
          }
          .offset({ y: this.heroFloatOffset })
          .margin({ bottom: 26 })

          Text('吞噬成长竞技')
            .fontSize(24)
            .fontColor('#BAE6FD')
            .margin({ bottom: 10 })

          Text('吃小躲大，持续发育成为球场霸主!')
            .fontSize(20)
            .fontColor('#93C5FD')
            .margin({ bottom: 50 })

          Row({ space: 10 }) {
            Text('吞噬对抗')
              .fontSize(12)
              .fontColor('#BAE6FD')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('rgba(34,211,238,0.22)')
              .borderRadius(14)

            Text('即时博弈')
              .fontSize(12)
              .fontColor('#BAE6FD')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('rgba(34,211,238,0.22)')
              .borderRadius(14)
          }
          .margin({ bottom: 20 })

          Column() {
            Text('游戏规则:')
              .fontSize(20)
              .fontColor('#FFFFFF')
              .margin({ bottom: 15 })

            Text('• 手指任意位置按下并拖拽摇杆控制方向')
              .fontSize(18)
              .fontColor('#D1D5DB')
              .margin({ bottom: 10 })

            Text('• 吃掉比你小的球体成长')
              .fontSize(18)
              .fontColor('#86EFAC')
              .margin({ bottom: 10 })

            Text('• 躲避比你大的球体')
              .fontSize(18)
              .fontColor('#FCA5A5')
              .margin({ bottom: 10 })

            Text('• 目标：成为球王并继续扩张!')
              .fontSize(18)
              .fontColor('#FDE68A')
              .margin({ bottom: 20 })
          }
          .padding(25)
          .backgroundColor('rgba(148, 163, 184, 0.16)')
          .borderRadius(15)
          .margin({ bottom: 40 })

          Button('开始游戏')
            .fontSize(28)
            .fontColor('#FFFFFF')
            .backgroundColor('#0EA5E9')
            .borderRadius(30)
            .width(200)
            .height(60)
            .shadow({ radius: 15, color: '#0EA5E9', offsetX: 0, offsetY: 5 })
            .scale({ x: this.buttonScale, y: this.buttonScale })
            .onClick(() => {
              this.buttonScale = 0.95;
              setTimeout(() => {
                this.buttonScale = 1.0;
                this.startGame();
              }, 150);
            })
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
      colors: [['#061123', 0.0], ['#102a43', 0.5], ['#0b1f33', 1.0]]
    })
  }

  @Builder
  GameView() {
    Stack() {
      Column() {
        Row({ space: 12 }) {
          Button('主页')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('rgba(255,255,255,0.16)')
            .borderRadius(16)
            .height(34)
            .onClick(() => {
              this.backToHome();
            })

          Button('重开')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('rgba(76,175,80,0.85)')
            .borderRadius(16)
            .height(34)
            .onClick(() => {
              this.restartGame();
            })

          Text(`体积 ${this.viewModel.score} · ${Math.floor(this.viewModel.playTime)}s`)
            .fontSize(14)
            .fontColor('#BAE6FD')
        }
        .width(GameConstants.CANVAS_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 8 })

        Text('提示：避开红圈大球，优先追逐绿圈小球')
          .fontSize(12)
          .fontColor('#BFDBFE')
          .width(GameConstants.CANVAS_WIDTH)
          .textAlign(TextAlign.Start)
          .margin({ bottom: 6 })

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

      // 暂停按钮
      if (!this.isPaused) {
        Button() {
          Text('⏸️')
            .fontSize(24)
        }
        .backgroundColor('rgba(255,255,255,0.8)')
        .borderRadius(20)
        .width(40)
        .height(40)
        .position({ x: GameConstants.CANVAS_WIDTH - 50, y: 50 })
        .onClick(() => {
          this.isPaused = true;
        })
      } else {
        // 暂停界面
        Column() {
          Column() {
            Text('⏸️ 游戏暂停')
              .fontSize(48)
              .fontColor('#FFFFFF')
              .margin({ bottom: 20 })

            Button('继续游戏')
              .fontSize(24)
              .fontColor('#FFFFFF')
              .backgroundColor('#4CAF50')
              .borderRadius(25)
              .width(180)
              .height(50)
              .onClick(() => {
                this.isPaused = false;
              })

            Button('返回主页')
              .fontSize(24)
              .fontColor('#FFFFFF')
              .backgroundColor('#FF6B6B')
              .borderRadius(25)
              .width(180)
              .height(50)
              .margin({ top: 20 })
              .onClick(() => {
                this.backToHome();
              })
          }
          .padding(30)
          .backgroundColor('rgba(0,0,0,0.85)')
          .borderRadius(20)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(0,0,0,0.5)')
      }
    }
    .width('100%')
    .height('100%')
  }

  private startGame(): void {
    this.isPlaying = true;
    this.viewModel = new GameViewModel();
  }

  private restartGame(): void {
    this.viewModel = new GameViewModel();
    this.viewModel.startGame();
    this.joystickState = {
      active: false,
      centerX: 0,
      centerY: 0,
      handleX: 0,
      handleY: 0
    };
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

  private onCanvasClick(event: ClickEvent): void {
    const state = this.viewModel.gameState;
    if (state === GameState.IDLE) {
      this.viewModel.startGame();
    } else if (state === GameState.GAME_OVER) {
      this.cleanup();
      this.isPlaying = false;
    } else if (state === GameState.PLAYING) {
      this.viewModel.setPlayerTarget(event.x, event.y);
    } else {
      this.viewModel.setPlayerTarget(event.x, event.y);
    }
  }

  private onCanvasTouch(event: TouchEvent): void {
    if (this.viewModel.gameState !== GameState.PLAYING) {
      return;
    }

    if (event.type === TouchType.Down && event.touches.length > 0) {
      const touch = event.touches[0];
      this.joystickState = {
        active: true,
        centerX: touch.x,
        centerY: touch.y,
        handleX: touch.x,
        handleY: touch.y
      };
      return;
    }

    if (event.type === TouchType.Move && event.touches.length > 0 && this.joystickState.active) {
      const touch = event.touches[0];
      const deltaX = touch.x - this.joystickState.centerX;
      const deltaY = touch.y - this.joystickState.centerY;
      const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
      const clampedDistance = Math.min(distance, this.joystickMaxDistance);
      const ratio = distance > 0 ? clampedDistance / distance : 0;
      const handleX = this.joystickState.centerX + deltaX * ratio;
      const handleY = this.joystickState.centerY + deltaY * ratio;

      this.joystickState = {
        active: true,
        centerX: this.joystickState.centerX,
        centerY: this.joystickState.centerY,
        handleX,
        handleY
      };

      this.viewModel.setPlayerDirectionInput(
        handleX - this.joystickState.centerX,
        handleY - this.joystickState.centerY,
        clampedDistance / this.joystickMaxDistance
      );
      return;
    }

    this.joystickState = {
      active: false,
      centerX: this.joystickState.centerX,
      centerY: this.joystickState.centerY,
      handleX: this.joystickState.centerX,
      handleY: this.joystickState.centerY
    };
  }

  private render(): void {
    this.renderer.render(
      this.canvasContext,
      this.viewModel.player,
      this.viewModel.creatures,
      this.viewModel.pellets,
      this.viewModel.score,
      this.viewModel.gameState,
      this.viewModel.hasWon,
      this.viewModel.playTime,
      this.viewModel.getCamera(),
      this.joystickState
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
