import { SudokuCell } from '../model/SudokuCell';
import { SudokuConstants, SudokuState } from '../model/SudokuConstants';

/**
 * 数独渲染器
 */
export class SudokuRenderer {
  private canvasWidth: number = SudokuConstants.CANVAS_WIDTH;
  private canvasHeight: number = SudokuConstants.CANVAS_HEIGHT;

  render(
    canvas: CanvasRenderingContext2D,
    cells: SudokuCell[][],
    selectedRow: number,
    selectedCol: number,
    relatedPositions: Set<string>,
    sameNumberPositions: Set<string>,
    timer: string,
    mistakes: number,
    gameState: SudokuState,
    noteMode: boolean
  ): void {
    this.clearCanvas(canvas);
    this.drawBackground(canvas);
    this.drawHeader(canvas, timer, mistakes, noteMode);
    this.drawGrid(canvas, cells, selectedRow, selectedCol, relatedPositions, sameNumberPositions);
    this.drawNumberPanel(canvas, cells);

    if (gameState === SudokuState.COMPLETED) {
      this.drawCompleted(canvas);
    }
  }

  private clearCanvas(canvas: CanvasRenderingContext2D): void {
    canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private drawBackground(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = SudokuConstants.COLOR_BACKGROUND;
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private drawHeader(canvas: CanvasRenderingContext2D, timer: string, mistakes: number, noteMode: boolean): void {
    // 时间
    canvas.fillStyle = '#333333';
    canvas.font = 'bold 20px sans-serif';
    canvas.textAlign = 'left';
    canvas.fillText(`⏱ ${timer}`, 20, 40);

    // 错误数
    canvas.fillStyle = '#F44336';
    canvas.textAlign = 'right';
    canvas.fillText(`❌ ${mistakes}/3`, 340, 40);

    // 笔记模式指示
    if (noteMode) {
      canvas.fillStyle = '#4CAF50';
      canvas.font = '16px sans-serif';
      canvas.textAlign = 'center';
      canvas.fillText('📝 笔记模式', 180, 70);
    }
  }

  private drawGrid(
    canvas: CanvasRenderingContext2D,
    cells: SudokuCell[][],
    selectedRow: number,
    selectedCol: number,
    relatedPositions: Set<string>,
    sameNumberPositions: Set<string>
  ): void {
    const startX = SudokuConstants.GRID_START_X;
    const startY = SudokuConstants.GRID_START_Y;
    const cellSize = SudokuConstants.CELL_SIZE;

    // 绘制单元格背景
    for (let i = 0; i < 9; i++) {
      for (let j = 0; j < 9; j++) {
        const x = startX + j * cellSize;
        const y = startY + i * cellSize;
        const cell = cells[i][j];
        const posKey = `${i},${j}`;

        // 确定背景颜色
        let bgColor = SudokuConstants.COLOR_CELL_BG;
        if (i === selectedRow && j === selectedCol) {
          bgColor = SudokuConstants.COLOR_CELL_SELECTED;
        } else if (sameNumberPositions.has(posKey)) {
          bgColor = SudokuConstants.COLOR_CELL_SAME_NUM;
        } else if (relatedPositions.has(posKey)) {
          bgColor = SudokuConstants.COLOR_CELL_SAME_ROW_COL;
        }

        if (cell.error) {
          bgColor = SudokuConstants.COLOR_CELL_ERROR;
        }

        canvas.fillStyle = bgColor;
        canvas.fillRect(x, y, cellSize, cellSize);
      }
    }

    // 绘制细网格线
    canvas.strokeStyle = '#CCCCCC';
    canvas.lineWidth = 1;
    for (let i = 0; i <= 9; i++) {
      // 水平线
      canvas.beginPath();
      canvas.moveTo(startX, startY + i * cellSize);
      canvas.lineTo(startX + 9 * cellSize, startY + i * cellSize);
      canvas.stroke();

      // 垂直线
      canvas.beginPath();
      canvas.moveTo(startX + i * cellSize, startY);
      canvas.lineTo(startX + i * cellSize, startY + 9 * cellSize);
      canvas.stroke();
    }

    // 绘制粗网格线（3x3宫格）
    canvas.strokeStyle = SudokuConstants.COLOR_GRID;
    canvas.lineWidth = 3;
    for (let i = 0; i <= 3; i++) {
      // 水平线
      canvas.beginPath();
      canvas.moveTo(startX, startY + i * 3 * cellSize);
      canvas.lineTo(startX + 9 * cellSize, startY + i * 3 * cellSize);
      canvas.stroke();

      // 垂直线
      canvas.beginPath();
      canvas.moveTo(startX + i * 3 * cellSize, startY);
      canvas.lineTo(startX + i * 3 * cellSize, startY + 9 * cellSize);
      canvas.stroke();
    }

    // 绘制数字
    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';

    for (let i = 0; i < 9; i++) {
      for (let j = 0; j < 9; j++) {
        const x = startX + j * cellSize + cellSize / 2;
        const y = startY + i * cellSize + cellSize / 2;
        const cell = cells[i][j];

        if (cell.hasValue()) {
          // 显示数字
          canvas.font = 'bold 22px sans-serif';
          canvas.fillStyle = cell.fixed ? SudokuConstants.COLOR_FIXED : SudokuConstants.COLOR_USER;
          canvas.fillText(cell.value.toString(), x, y);
        } else if (cell.notes.size > 0) {
          // 显示笔记
          canvas.font = '10px sans-serif';
          canvas.fillStyle = '#999999';
          const noteSize = cellSize / 3;
          for (let n = 1; n <= 9; n++) {
            if (cell.notes.has(n)) {
              const noteRow = Math.floor((n - 1) / 3);
              const noteCol = (n - 1) % 3;
              const noteX = startX + j * cellSize + noteCol * noteSize + noteSize / 2;
              const noteY = startY + i * cellSize + noteRow * noteSize + noteSize / 2;
              canvas.fillText(n.toString(), noteX, noteY);
            }
          }
        }
      }
    }
  }

  private drawNumberPanel(canvas: CanvasRenderingContext2D, cells: SudokuCell[][]): void {
    const startX = (this.canvasWidth - 9 * 36) / 2;
    const startY = SudokuConstants.NUMBER_PANEL_Y;
    const size = 36;

    // 统计已使用的数字数量
    const usedCount: Map<number, number> = new Map();
    for (let i = 1; i <= 9; i++) usedCount.set(i, 0);

    for (let i = 0; i < 9; i++) {
      for (let j = 0; j < 9; j++) {
        const val = cells[i][j].value;
        if (val > 0) {
          usedCount.set(val, (usedCount.get(val) || 0) + 1);
        }
      }
    }

    for (let i = 1; i <= 9; i++) {
      const x = startX + (i - 1) * size;
      const y = startY;
      const count = usedCount.get(i) || 0;
      const completed = count >= 9;

      // 按钮背景
      canvas.fillStyle = completed ? '#CCCCCC' : SudokuConstants.COLOR_NUMBER_BTN;
      canvas.beginPath();
      canvas.roundRect(x + 2, y, size - 4, size, 8);
      canvas.fill();

      // 数字
      canvas.fillStyle = '#FFFFFF';
      canvas.font = 'bold 22px sans-serif';
      canvas.textAlign = 'center';
      canvas.textBaseline = 'middle';
      canvas.fillText(i.toString(), x + size / 2, y + size / 2);
    }
  }

  private drawCompleted(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.7)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = '#FFD700';
    canvas.font = 'bold 36px sans-serif';
    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';
    canvas.fillText('🎉 恭喜完成！', this.canvasWidth / 2, this.canvasHeight / 2 - 30);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = '18px sans-serif';
    canvas.fillText('点击返回', this.canvasWidth / 2, this.canvasHeight / 2 + 30);
  }

  /**
   * 获取点击位置对应的单元格
   */
  static getCellFromPosition(x: number, y: number): [number, number] | null {
    const startX = SudokuConstants.GRID_START_X;
    const startY = SudokuConstants.GRID_START_Y;
    const cellSize = SudokuConstants.CELL_SIZE;

    if (x >= startX && x < startX + 9 * cellSize &&
        y >= startY && y < startY + 9 * cellSize) {
      const col = Math.floor((x - startX) / cellSize);
      const row = Math.floor((y - startY) / cellSize);
      if (row >= 0 && row < 9 && col >= 0 && col < 9) {
        return [row, col];
      }
    }
    return null;
  }

  /**
   * 获取点击位置对应的数字按钮
   */
  static getNumberFromPosition(x: number, y: number): number {
    const startX = (SudokuConstants.CANVAS_WIDTH - 9 * 36) / 2;
    const startY = SudokuConstants.NUMBER_PANEL_Y;
    const size = 36;

    if (y >= startY && y < startY + size) {
      const num = Math.floor((x - startX) / size) + 1;
      if (num >= 1 && num <= 9) {
        return num;
      }
    }
    return 0;
  }
}
