import { GameViewModel } from '../games/flappybird/viewmodel/GameViewModel';
import { GameRenderer } from '../games/flappybird/view/GameRenderer';
import { ScoreRepository } from '../games/flappybird/model/ScoreRepository';
import { GameState } from '../games/flappybird/model/GameState';
import { GameConstants } from '../games/flappybird/model/GameConstants';
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';

/**
 * Flappy Bird 游戏页面
 */
@Entry
@Component
struct FlappyBirdGame {
  // 页面状态
  @State isPlaying: boolean = false;
  @State highScore: number = 0;

  // 游戏相关
  @State viewModel: GameViewModel = new GameViewModel();
  private renderer: GameRenderer = new GameRenderer();
  private scoreRepository: ScoreRepository | null = null;

  // Canvas相关
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private renderInterval: number | null = null;

  aboutToAppear(): void {
    this.initScoreRepository();
  }

  aboutToDisappear(): void {
    this.cleanup();
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
        .margin({ bottom: 40 })

      // 最高分
      Text(`最高分: ${this.highScore}`)
        .fontSize(24)
        .fontColor('#333333')
        .margin({ bottom: 40 })

      // 开始游戏按钮
      Button('开始游戏')
        .fontSize(24)
        .fontColor('#FFFFFF')
        .backgroundColor('#228B22')
        .borderRadius(25)
        .width(200)
        .height(50)
        .onClick(() => {
          this.startGame();
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
