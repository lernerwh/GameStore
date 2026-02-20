import { SudokuViewModel } from '../games/sudoku/viewmodel/SudokuViewModel';
import { SudokuRenderer } from '../games/sudoku/view/SudokuRenderer';
import { SudokuConstants, SudokuState, Difficulty } from '../games/sudoku/model/SudokuConstants';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct SudokuGame {
  @State isPlaying: boolean = false;
  @State viewModel: SudokuViewModel = new SudokuViewModel();
  @State selectedDifficulty: number = 1; // 0=简单, 1=中等, 2=困难

  private renderer: SudokuRenderer = new SudokuRenderer();
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

      Text('数独')
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1976D2')
        .margin({ top: 30, bottom: 10 })

      Text('Sudoku')
        .fontSize(18)
        .fontColor('#666666')
        .margin({ bottom: 30 })

      // 数独图标
      Column() {
        Row() {
          Text('1').fontSize(20).fontColor('#1976D2')
          Text(' ').fontSize(20)
          Text('3').fontSize(20).fontColor('#1976D2')
        }
        Row() {
          Text(' ').fontSize(20)
          Text('5').fontSize(20).fontColor('#1976D2')
          Text(' ').fontSize(20)
        }
        Row() {
          Text('7').fontSize(20).fontColor('#1976D2')
          Text(' ').fontSize(20)
          Text('9').fontSize(20).fontColor('#1976D2')
        }
      }
      .width(100)
      .height(100)
      .justifyContent(FlexAlign.Center)
      .borderRadius(10)
      .border({ width: 2, color: '#1976D2' })
      .margin({ bottom: 40 })

      // 难度选择
      Text('选择难度')
        .fontSize(18)
        .fontColor('#333333')
        .margin({ bottom: 15 })

      Row({ space: 15 }) {
        ForEach(['简单', '中等', '困难'], (level: string, index: number) => {
          Button(level)
            .fontSize(16)
            .fontColor(this.selectedDifficulty === index ? '#FFFFFF' : '#1976D2')
            .backgroundColor(this.selectedDifficulty === index ? '#1976D2' : '#E3F2FD')
            .borderRadius(20)
            .width(80)
            .height(36)
            .onClick(() => { this.selectedDifficulty = index; })
        })
      }
      .margin({ bottom: 40 })

      Button('开始游戏')
        .fontSize(22)
        .fontColor('#FFFFFF')
        .backgroundColor('#1976D2')
        .borderRadius(30)
        .width(180)
        .height(50)
        .onClick(() => { this.startGame(); })

      // 说明
      Column() {
        Text('游戏规则')
          .fontSize(16)
          .fontColor('#333333')
          .margin({ bottom: 10 })

        Text('• 每行、每列、每个3x3宫格内1-9不重复')
          .fontSize(14)
          .fontColor('#666666')
        Text('• 点击空格选择，再点击数字填入')
          .fontSize(14)
          .fontColor('#666666')
        Text('• 蓝色数字为初始固定数字')
          .fontSize(14)
          .fontColor('#666666')
      }
      .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [['#E3F2FD', 0.0], ['#BBDEFB', 1.0]]
    })
  }

  @Builder
  GameView() {
    Column() {
      Canvas(this.canvasContext)
        .width(SudokuConstants.CANVAS_WIDTH)
        .height(SudokuConstants.CANVAS_HEIGHT)
        .backgroundColor(SudokuConstants.COLOR_BACKGROUND)
        .onReady(() => { this.onCanvasReady(); })
        .onClick((event) => { this.onCanvasClick(event.x, event.y); })

      // 控制按钮
      Row({ space: 20 }) {
        Button(this.viewModel.noteMode ? '📝 笔记' : '✏️ 笔记')
          .fontSize(14)
          .fontColor(this.viewModel.noteMode ? '#FFFFFF' : '#333333')
          .backgroundColor(this.viewModel.noteMode ? '#4CAF50' : '#E0E0E0')
          .borderRadius(20)
          .height(36)
          .onClick(() => {
            this.viewModel.toggleNoteMode();
          })

        Button('🗑️ 清除')
          .fontSize(14)
          .fontColor('#333333')
          .backgroundColor('#E0E0E0')
          .borderRadius(20)
          .height(36)
          .onClick(() => {
            this.viewModel.clearCell();
          })

        Button('💡 提示')
          .fontSize(14)
          .fontColor('#333333')
          .backgroundColor('#E0E0E0')
          .borderRadius(20)
          .height(36)
          .onClick(() => {
            this.viewModel.useHint();
          })

        Button('🔄 重置')
          .fontSize(14)
          .fontColor('#333333')
          .backgroundColor('#E0E0E0')
          .borderRadius(20)
          .height(36)
          .onClick(() => {
            this.viewModel.resetGame();
          })
      }
      .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#E3F2FD')
  }

  private startGame(): void {
    this.isPlaying = true;
    this.viewModel = new SudokuViewModel();

    const difficulties = [Difficulty.EASY, Difficulty.MEDIUM, Difficulty.HARD];
    this.viewModel.startNewGame(difficulties[this.selectedDifficulty]);
  }

  private onCanvasReady(): void {
    if (this.renderInterval !== null) {
      clearInterval(this.renderInterval);
    }
    this.renderInterval = setInterval(() => { this.render(); }, 1000 / 30);
  }

  private onCanvasClick(x: number, y: number): void {
    if (this.viewModel.gameState === SudokuState.COMPLETED) {
      this.cleanup();
      this.isPlaying = false;
      return;
    }

    // 检查是否点击了网格
    const cell = SudokuRenderer.getCellFromPosition(x, y);
    if (cell) {
      const row = cell[0];
      const col = cell[1];
      this.viewModel.selectCell(row, col);
      return;
    }

    // 检查是否点击了数字面板
    const num = SudokuRenderer.getNumberFromPosition(x, y);
    if (num > 0) {
      this.viewModel.inputNumber(num);
    }
  }

  private render(): void {
    this.renderer.render(
      this.canvasContext,
      this.viewModel.cells,
      this.viewModel.selectedRow,
      this.viewModel.selectedCol,
      this.viewModel.getRelatedPositions(),
      this.viewModel.getSameNumberPositions(),
      this.viewModel.getFormattedTime(),
      this.viewModel.mistakes,
      this.viewModel.gameState,
      this.viewModel.noteMode
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
