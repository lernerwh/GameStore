import { GameViewModel } from '../games/dragon/viewmodel/GameViewModel';
import { GameRenderer } from '../games/dragon/view/GameRenderer';
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
  @State buttonScale: number = 1.0;
  @State showDeadOverlay: boolean = false;
  private renderer: GameRenderer = new GameRenderer();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private renderInterval: number | null = null;
  private imageManager: ImageManager = ImageManager.getInstance();
  private joystickMaxDistance: number = 90;
  @State joystickCenterX: number = 0;
  @State joystickCenterY: number = 0;
  @State joystickActive: boolean = false;

  aboutToAppear(): void {
    this.initImageManager();
    const params = router.getParams() as PageParams;
    if (params?.autoStart) {
      this.startGame();
    }
  }

  aboutToDisappear(): void {
    this.cleanup();
  }

  private async initImageManager(): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await this.imageManager.init(context);
    } catch (e) {
      console.error('Failed to initialize ImageManager:', e);
    }
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
        .linearGradient({
          angle: 180,
          colors: [['#8ec6ef', 0.0], ['#8cc3eb', 0.6], ['#87bee6', 1.0]]
        })

      // 左上角音量按钮
      Button() {
        Text('🔊')
          .fontSize(18)
      }
      .width(38)
      .height(38)
      .backgroundColor('#7BCB79')
      .borderRadius(8)
      .border({ width: 1, color: '#3C7E38' })
      .position({ x: 14, y: 110 })

      Column({ space: 14 }) {
        Button() {
          Text('开始游戏')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(140)
        .height(52)
        .borderRadius(10)
        .linearGradient({
          angle: 180,
          colors: [['#A56BF2', 0.0], ['#8B4DE0', 1.0]]
        })
        .border({ width: 2, color: '#D9C0FF' })
        .scale({ x: this.buttonScale, y: this.buttonScale })
        .onClick(() => {
          this.buttonScale = 0.95;
          setTimeout(() => {
            this.buttonScale = 1.0;
            this.startGame();
          }, 100);
        })

        Row({ space: 6 }) {
          Text('🐟')
            .fontSize(22)

          Button() {
            Text('进化神鲲')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width(140)
          .height(46)
          .borderRadius(9)
          .linearGradient({
            angle: 180,
            colors: [['#F6C955', 0.0], ['#DA9E2E', 1.0]]
          })
          .border({ width: 2, color: '#FFE49A' })
          .onClick(() => {
            this.startGame();
          })
        }
      }
      .position({ x: 102, y: 360 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  GameView() {
    Stack() {
      Column() {
        Canvas(this.canvasContext)
          .width(GameConstants.CANVAS_WIDTH)
          .height(GameConstants.CANVAS_HEIGHT)
          .onReady(() => { this.onCanvasReady(); })
          .onTouch((event) => { this.onCanvasTouch(event); })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#8cc3eb')

      // 左上角主页按钮
      Button() {
        Text('🏠')
          .fontSize(18)
      }
      .width(40)
      .height(40)
      .backgroundColor('#7BCB79')
      .borderRadius(8)
      .border({ width: 1, color: '#3C7E38' })
      .position({ x: 10, y: 98 })
      .onClick(() => {
        this.backToHome();
      })

      // 右侧无敌图标
      Column() {
        Row({ space: 2 }) {
          Text('▶')
            .fontSize(12)
            .fontColor('#3B4E66')
          Text('🛡️')
            .fontSize(20)
            .fontColor('#EAF1FF')
        }
        .width(50)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#7FA9D6')
        .borderRadius(8)
        .border({ width: 1, color: '#E7F0FF' })

        Text('无敌')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textShadow({ radius: 3, color: '#2f4668', offsetX: 0, offsetY: 1 })
      }
      .position({ x: GameConstants.CANVAS_WIDTH - 78, y: 250 })

      if (this.showDeadOverlay) {
        this.DeadOverlay();
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DeadOverlay() {
    Column() {
      Text('在哪里跌倒就在哪里爬起来!')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textShadow({ radius: 4, color: '#233446', offsetX: 0, offsetY: 1 })
        .margin({ top: 430, bottom: 16 })

      Row({ space: 14 }) {
        Button() {
          Text('▶ 原地复活')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(140)
        .height(46)
        .borderRadius(9)
        .linearGradient({
          angle: 180,
          colors: [['#9A6EF0', 0.0], ['#7A43DA', 1.0]]
        })
        .border({ width: 2, color: '#E2D4FF' })
        .onClick(() => {
          this.revive();
        })

        Button() {
          Text('下次一定')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(140)
        .height(46)
        .borderRadius(9)
        .linearGradient({
          angle: 180,
          colors: [['#F3C754', 0.0], ['#D89E2D', 1.0]]
        })
        .border({ width: 2, color: '#FFE49A' })
        .onClick(() => {
          this.backToHome();
        })
      }
    }
    .width(GameConstants.CANVAS_WIDTH)
    .height(GameConstants.CANVAS_HEIGHT)
    .justifyContent(FlexAlign.Start)
    .backgroundColor('rgba(16, 30, 45, 0.42)')
  }

  private startGame(): void {
    this.isPlaying = true;
    this.showDeadOverlay = false;
    this.viewModel = new GameViewModel();
    this.viewModel.startGame();
  }

  private revive(): void {
    this.showDeadOverlay = false;
    this.viewModel = new GameViewModel();
    this.viewModel.startGame();
  }

  private backToHome(): void {
    this.cleanup();
    this.isPlaying = false;
    this.showDeadOverlay = false;
    this.viewModel = new GameViewModel();
  }

  private onCanvasReady(): void {
    if (this.renderInterval !== null) {
      clearInterval(this.renderInterval);
    }
    this.renderInterval = setInterval(() => { this.render(); }, 1000 / 60);
  }

  private onCanvasTouch(event: TouchEvent): void {
    if (this.viewModel.gameState !== GameState.PLAYING) {
      return;
    }

    if (event.type === TouchType.Down && event.touches.length > 0) {
      const touch = event.touches[0];
      this.joystickActive = true;
      this.joystickCenterX = touch.x;
      this.joystickCenterY = touch.y;
      return;
    }

    if (event.type === TouchType.Move && event.touches.length > 0 && this.joystickActive) {
      const touch = event.touches[0];
      const deltaX = touch.x - this.joystickCenterX;
      const deltaY = touch.y - this.joystickCenterY;
      const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
      const clampedDistance = Math.min(distance, this.joystickMaxDistance);
      const ratio = distance > 0 ? clampedDistance / distance : 0;
      const handleX = this.joystickCenterX + deltaX * ratio;
      const handleY = this.joystickCenterY + deltaY * ratio;

      this.viewModel.setPlayerDirectionInput(
        handleX - this.joystickCenterX,
        handleY - this.joystickCenterY,
        clampedDistance / this.joystickMaxDistance
      );
      return;
    }

    this.joystickActive = false;
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
      this.viewModel.getCamera()
    );

    if (this.viewModel.gameState === GameState.GAME_OVER) {
      this.showDeadOverlay = true;
    }
  }

  private cleanup(): void {
    if (this.renderInterval !== null) {
      clearInterval(this.renderInterval);
      this.renderInterval = null;
    }
    this.viewModel.destroy();
  }
}
