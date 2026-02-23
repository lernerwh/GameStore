import { GameViewModel } from '../games/flappybird/viewmodel/GameViewModel';
import { GameRenderer } from '../games/flappybird/view/GameRenderer';
import { ScoreRepository } from '../games/flappybird/model/ScoreRepository';
import { GameState } from '../games/flappybird/model/GameState';
import { GameConstants } from '../games/flappybird/model/GameConstants';
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';

interface PageParams {
  autoStart?: boolean;
}

/**
 * Flappy Bird 游戏页面
 */
@Entry
@Component
struct FlappyBirdGame {
  // 页面状态
  @State isPlaying: boolean = false;
  @State highScore: number = 0;
  @State buttonScale: number = 1.0;
  @State birdFlapOffset: number = 0.0;

  // 游戏相关
  @State viewModel: GameViewModel = new GameViewModel();
  private renderer: GameRenderer = new GameRenderer();
  private scoreRepository: ScoreRepository | null = null;

  // Canvas相关
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private renderInterval: number | null = null;
  private animationInterval: number | null = null;

  aboutToAppear(): void {
    this.initScoreRepository();

    // 检查是否需要自动开始游戏
    const params = router.getParams() as PageParams;
    if (params?.autoStart) {
      this.startGame();
    }

    // 启动小鸟翅膀动画
    this.startBirdAnimation();
  }

  aboutToDisappear(): void {
    this.cleanup();
    this.stopBirdAnimation();
  }

  private startBirdAnimation(): void {
    this.animationInterval = setInterval(() => {
      this.birdFlapOffset = Math.sin(Date.now() / 200) * 3;
    }, 50);
  }

  private stopBirdAnimation(): void {
    if (this.animationInterval !== null) {
      clearInterval(this.animationInterval);
      this.animationInterval = null;
    }
  }

  build() {
    Column() {
      if (!this.isPlaying) {
        // 首页界面
        this.HomeView();
      } else {
        // 游戏界面
        this.GameView();
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 首页视图
   */
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
            .backgroundColor('rgba(0,0,0,0.2)')
            .borderRadius(20)
            .height(36)
            .padding({ left: 15, right: 15 })
            .onClick(() => { router.back(); })
          }
          .width('100%')
          .padding({ left: 20, top: 50 })

          // 标题
          Text('Flappy Bird')
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .textShadow({
              radius: 4,
              color: '#000000',
              offsetX: 2,
              offsetY: 2
            })
            .margin({ top: 30, bottom: 20 })

          // 小鸟图标
          Text('🐦')
            .fontSize(80)
            .offset({ y: this.birdFlapOffset })
            .margin({ bottom: 40 })

          Row({ space: 10 }) {
            Text('节奏挑战')
              .fontSize(12)
              .fontColor('#7c4a00')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('rgba(255,215,0,0.25)')
              .borderRadius(14)
            Text('单击起跳')
              .fontSize(12)
              .fontColor('#7c4a00')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('rgba(255,215,0,0.22)')
              .borderRadius(14)
          }
          .margin({ bottom: 18 })

          // 最高分
          Text(`最高分: ${this.highScore}`)
            .fontSize(24)
            .fontColor('#333333')
            .margin({ bottom: 40 })

          Text(`本局目标: ${Math.max(5, this.highScore + 1)} 分`)
            .fontSize(14)
            .fontColor('#2f4f4f')
            .margin({ bottom: 14 })

          // 开始游戏按钮
          Button('开始游戏')
            .fontSize(24)
            .fontColor('#FFFFFF')
            .backgroundColor('#228B22')
            .borderRadius(25)
            .width(200)
            .height(50)
            .scale({ x: this.buttonScale, y: this.buttonScale })
            .onClick(() => {
              this.buttonScale = 0.95;
              setTimeout(() => {
                this.buttonScale = 1.0;
                this.startGame();
              }, 150);
            })

          // 说明文字
          Text('点击屏幕让小鸟跳跃\n避开管道获得分数')
            .fontSize(16)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
            .margin({ top: 40 })
            .lineHeight(24)
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
      colors: [['#87CEEB', 0.0], ['#98FB98', 1.0]]
    })
  }

  /**
   * 游戏视图
   */
  @Builder
  GameView() {
    Column() {
      Row({ space: 12 }) {
        Button('主页')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(0,0,0,0.3)')
          .borderRadius(16)
          .height(34)
          .onClick(() => {
            this.backToHome();
          })

        Button('重开')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(34,139,34,0.8)')
          .borderRadius(16)
          .height(34)
          .onClick(() => {
            this.restartGame();
          })

        Text(`当前分数: ${this.viewModel.score}`)
          .fontSize(14)
          .fontColor('#FFFFFF')
      }
      .width(GameConstants.CANVAS_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 8 })

      // 游戏画布
      Canvas(this.canvasContext)
        .width(GameConstants.CANVAS_WIDTH)
        .height(GameConstants.CANVAS_HEIGHT)
        .backgroundColor(GameConstants.COLOR_SKY)
        .onReady(() => {
          this.onCanvasReady();
        })
        .onClick(() => {
          this.onCanvasClick();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#333333')
  }

  /**
   * 初始化分数仓库
   */
  private async initScoreRepository(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      this.scoreRepository = new ScoreRepository(context);
      await this.scoreRepository.init();
      this.highScore = await this.scoreRepository.getHighScore();
    } catch (error) {
      console.error('Failed to init score repository:', error);
    }
  }

  /**
   * 开始游戏
   */
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

  /**
   * Canvas准备完成
   */
  private onCanvasReady(): void {
    this.startRenderLoop();
  }

  /**
   * Canvas点击事件
   */
  private onCanvasClick(): void {
    const gameState = this.viewModel.gameState;

    if (gameState === GameState.IDLE) {
      this.viewModel.startGame();
    } else if (gameState === GameState.PLAYING) {
      this.viewModel.jump();
    } else if (gameState === GameState.GAME_OVER) {
      this.handleGameOver();
    }
  }

  /**
   * 处理游戏结束
   */
  private async handleGameOver(): Promise<void> {
    // 保存分数
    if (this.scoreRepository) {
      const score = this.viewModel.score;
      const isNewHighScore = await this.scoreRepository.saveHighScore(score);
      if (isNewHighScore) {
        this.highScore = score;
      }
    }

    // 返回首页
    this.cleanup();
    this.isPlaying = false;
  }

  /**
   * 开始渲染循环
   */
  private startRenderLoop(): void {
    if (this.renderInterval !== null) {
      clearInterval(this.renderInterval);
    }

    this.renderInterval = setInterval(() => {
      this.render();
    }, 1000 / 60);
  }

  /**
   * 渲染游戏画面
   */
  private render(): void {
    this.renderer.render(
      this.canvasContext,
      this.viewModel.bird,
      this.viewModel.pipes,
      this.viewModel.score,
      this.viewModel.gameState,
      this.viewModel.groundY
    );
  }

  /**
   * 清理资源
   */
  private cleanup(): void {
    if (this.renderInterval !== null) {
      clearInterval(this.renderInterval);
      this.renderInterval = null;
    }
    this.viewModel.destroy();
  }
}
