import { SudokuCell } from './SudokuCell';
import { SudokuConstants, Difficulty } from './SudokuConstants';

/**
 * 数独棋盘
 */
export class SudokuBoard {
  cells: SudokuCell[][];   // 9x9 网格
  solution: number[][];    // 解答
  selectedRow: number;
  selectedCol: number;

  constructor() {
    this.cells = [];
    this.solution = [];
    this.selectedRow = -1;
    this.selectedCol = -1;

    // 初始化空网格
    for (let i = 0; i < 9; i++) {
      this.cells[i] = [];
      this.solution[i] = [];
      for (let j = 0; j < 9; j++) {
        this.cells[i][j] = new SudokuCell();
        this.solution[i][j] = 0;
      }
    }
  }

  /**
   * 生成新游戏
   */
  generateNewGame(difficulty: Difficulty): void {
    // 先生成完整的解答
    this.generateSolution();

    // 复制解答到棋盘
    for (let i = 0; i < 9; i++) {
      for (let j = 0; j < 9; j++) {
        this.cells[i][j] = new SudokuCell(this.solution[i][j], true);
      }
    }

    // 根据难度移除数字
    let removeCount: number;
    switch (difficulty) {
      case Difficulty.EASY:
        removeCount = SudokuConstants.DIFFICULTY_EASY;
        break;
      case Difficulty.MEDIUM:
        removeCount = SudokuConstants.DIFFICULTY_MEDIUM;
        break;
      case Difficulty.HARD:
        removeCount = SudokuConstants.DIFFICULTY_HARD;
        break;
      default:
        removeCount = SudokuConstants.DIFFICULTY_MEDIUM;
    }

    this.removeNumbers(removeCount);
    this.selectedRow = -1;
    this.selectedCol = -1;
  }

  /**
   * 生成完整解答
   */
  private generateSolution(): void {
    // 清空
    for (let i = 0; i < 9; i++) {
      for (let j = 0; j < 9; j++) {
        this.solution[i][j] = 0;
      }
    }
    this.solveSudoku();
  }

  /**
   * 使用回溯法解数独
   */
  private solveSudoku(): boolean {
    const emptyCell = this.findEmptyCell();
    if (!emptyCell) {
      return true; // 全部填满
    }

    const row = emptyCell[0];
    const col = emptyCell[1];
    const numbers = this.shuffleArray([1, 2, 3, 4, 5, 6, 7, 8, 9]);

    for (const num of numbers) {
      if (this.isValidPlacement(row, col, num)) {
        this.solution[row][col] = num;
        if (this.solveSudoku()) {
          return true;
        }
        this.solution[row][col] = 0;
      }
    }

    return false;
  }

  /**
   * 查找空单元格
   */
  private findEmptyCell(): [number, number] | null {
    for (let i = 0; i < 9; i++) {
      for (let j = 0; j < 9; j++) {
        if (this.solution[i][j] === 0) {
          return [i, j];
        }
      }
    }
    return null;
  }

  /**
   * 检查数字是否可以放置
   */
  private isValidPlacement(row: number, col: number, num: number): boolean {
    // 检查行
    for (let j = 0; j < 9; j++) {
      if (this.solution[row][j] === num) return false;
    }

    // 检查列
    for (let i = 0; i < 9; i++) {
      if (this.solution[i][col] === num) return false;
    }

    // 检查3x3宫格
    const boxRow = Math.floor(row / 3) * 3;
    const boxCol = Math.floor(col / 3) * 3;
    for (let i = 0; i < 3; i++) {
      for (let j = 0; j < 3; j++) {
        if (this.solution[boxRow + i][boxCol + j] === num) return false;
      }
    }

    return true;
  }

  /**
   * 随机打乱数组
   */
  private shuffleArray<T>(array: T[]): T[] {
    const result = [...array];
    for (let i = result.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      const temp = result[i];
      result[i] = result[j];
      result[j] = temp;
    }
    return result;
  }

  /**
   * 移除指定数量的数字
   */
  private removeNumbers(count: number): void {
    let removed = 0;
    const positions: [number, number][] = [];
    for (let i = 0; i < 9; i++) {
      for (let j = 0; j < 9; j++) {
        positions.push([i, j]);
      }
    }
    this.shuffleArray(positions);

    for (let i = 0; i < positions.length; i++) {
      if (removed >= count) break;
      const row = positions[i][0];
      const col = positions[i][1];
      if (this.cells[row][col].hasValue()) {
        this.cells[row][col].value = 0;
        this.cells[row][col].fixed = false;
        removed++;
      }
    }
  }

  /**
   * 选择单元格
   */
  selectCell(row: number, col: number): void {
    if (row >= 0 && row < 9 && col >= 0 && col < 9) {
      this.selectedRow = row;
      this.selectedCol = col;
    }
  }

  /**
   * 获取选中的单元格
   */
  getSelectedCell(): SudokuCell | null {
    if (this.selectedRow >= 0 && this.selectedCol >= 0) {
      return this.cells[this.selectedRow][this.selectedCol];
    }
    return null;
  }

  /**
   * 在选中单元格输入数字
   */
  inputNumber(num: number): boolean {
    const cell = this.getSelectedCell();
    if (cell && !cell.fixed) {
      cell.setValue(num);
      this.validateCell(this.selectedRow, this.selectedCol);
      return true;
    }
    return false;
  }

  /**
   * 切换笔记
   */
  toggleNote(num: number): void {
    const cell = this.getSelectedCell();
    if (cell) {
      cell.toggleNote(num);
    }
  }

  /**
   * 清除选中单元格
   */
  clearSelectedCell(): void {
    const cell = this.getSelectedCell();
    if (cell) {
      cell.clearValue();
    }
  }

  /**
   * 验证单元格是否正确
   */
  private validateCell(row: number, col: number): void {
    const cell = this.cells[row][col];
    if (cell.hasValue()) {
      cell.error = cell.value !== this.solution[row][col];
    } else {
      cell.error = false;
    }
  }

  /**
   * 检查是否完成
   */
  isComplete(): boolean {
    for (let i = 0; i < 9; i++) {
      for (let j = 0; j < 9; j++) {
        if (this.cells[i][j].value !== this.solution[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  /**
   * 获取与选中单元格同行、同列、同宫的单元格位置
   */
  getRelatedPositions(): Set<string> {
    const related = new Set<string>();
    if (this.selectedRow < 0 || this.selectedCol < 0) return related;

    // 同行
    for (let j = 0; j < 9; j++) {
      related.add(`${this.selectedRow},${j}`);
    }

    // 同列
    for (let i = 0; i < 9; i++) {
      related.add(`${i},${this.selectedCol}`);
    }

    // 同宫
    const boxRow = Math.floor(this.selectedRow / 3) * 3;
    const boxCol = Math.floor(this.selectedCol / 3) * 3;
    for (let i = 0; i < 3; i++) {
      for (let j = 0; j < 3; j++) {
        related.add(`${boxRow + i},${boxCol + j}`);
      }
    }

    return related;
  }

  /**
   * 获取与选中数字相同的位置
   */
  getSameNumberPositions(): Set<string> {
    const same = new Set<string>();
    const cell = this.getSelectedCell();
    if (!cell || !cell.hasValue()) return same;

    for (let i = 0; i < 9; i++) {
      for (let j = 0; j < 9; j++) {
        if (this.cells[i][j].value === cell.value) {
          same.add(`${i},${j}`);
        }
      }
    }

    return same;
  }

  /**
   * 重置棋盘
   */
  reset(): void {
    for (let i = 0; i < 9; i++) {
      for (let j = 0; j < 9; j++) {
        if (!this.cells[i][j].fixed) {
          this.cells[i][j].clearValue();
          this.cells[i][j].notes.clear();
        }
      }
    }
    this.selectedRow = -1;
    this.selectedCol = -1;
  }
}
