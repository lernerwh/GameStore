import { SudokuBoard } from '../model/SudokuBoard';
import { SudokuState, Difficulty } from '../model/SudokuConstants';

/**
 * 数独游戏视图模型
 */
@Observed
export class SudokuViewModel {
  private board: SudokuBoard;

  @Track gameState: SudokuState;
  @Track difficulty: Difficulty;
  @Track timer: number;
  @Track mistakes: number;
  @Track noteMode: boolean;

  private timerInterval: number | null = null;

  constructor() {
    this.board = new SudokuBoard();
    this.gameState = SudokuState.IDLE;
    this.difficulty = Difficulty.MEDIUM;
    this.timer = 0;
    this.mistakes = 0;
    this.noteMode = false;
  }

  get cells() { return this.board.cells; }
  get selectedRow() { return this.board.selectedRow; }
  get selectedCol() { return this.board.selectedCol; }

  /**
   * 开始新游戏
   */
  startNewGame(difficulty: Difficulty): void {
    this.difficulty = difficulty;
    this.board.generateNewGame(difficulty);
    this.gameState = SudokuState.PLAYING;
    this.timer = 0;
    this.mistakes = 0;
    this.noteMode = false;
    this.startTimer();
  }

  /**
   * 选择单元格
   */
  selectCell(row: number, col: number): void {
    this.board.selectCell(row, col);
  }

  /**
   * 输入数字
   */
  inputNumber(num: number): void {
    if (this.gameState !== SudokuState.PLAYING) return;

    if (this.noteMode) {
      this.board.toggleNote(num);
    } else {
      const cell = this.board.getSelectedCell();
      const wasCorrect = cell?.value === this.board.solution[this.selectedRow]?.[this.selectedCol];
      this.board.inputNumber(num);
      const isCorrect = cell?.value === this.board.solution[this.selectedRow]?.[this.selectedCol];

      // 检查是否犯错
      if (cell?.hasValue() && cell?.error) {
        this.mistakes++;
      }

      // 检查是否完成
      if (this.board.isComplete()) {
        this.gameState = SudokuState.COMPLETED;
        this.stopTimer();
      }
    }
  }

  /**
   * 清除选中单元格
   */
  clearCell(): void {
    if (this.gameState !== SudokuState.PLAYING) return;
    this.board.clearSelectedCell();
  }

  /**
   * 切换笔记模式
   */
  toggleNoteMode(): void {
    this.noteMode = !this.noteMode;
  }

  /**
   * 重置游戏
   */
  resetGame(): void {
    this.board.reset();
    this.timer = 0;
    this.mistakes = 0;
    this.noteMode = false;
  }

  /**
   * 获取相关位置
   */
  getRelatedPositions(): Set<string> {
    return this.board.getRelatedPositions();
  }

  /**
   * 获取相同数字位置
   */
  getSameNumberPositions(): Set<string> {
    return this.board.getSameNumberPositions();
  }

  /**
   * 获取解答（提示用）
   */
  getHint(): number {
    if (this.selectedRow >= 0 && this.selectedCol >= 0) {
      return this.board.solution[this.selectedRow][this.selectedCol];
    }
    return 0;
  }

  /**
   * 使用提示
   */
  useHint(): void {
    if (this.gameState !== SudokuState.PLAYING) return;
    if (this.selectedRow < 0 || this.selectedCol < 0) return;

    const hint = this.getHint();
    if (hint > 0) {
      this.board.inputNumber(hint);
      if (this.board.isComplete()) {
        this.gameState = SudokuState.COMPLETED;
        this.stopTimer();
      }
    }
  }

  /**
   * 开始计时
   */
  private startTimer(): void {
    this.stopTimer();
    this.timerInterval = setInterval(() => {
      this.timer++;
    }, 1000);
  }

  /**
   * 停止计时
   */
  private stopTimer(): void {
    if (this.timerInterval !== null) {
      clearInterval(this.timerInterval);
      this.timerInterval = null;
    }
  }

  /**
   * 格式化时间
   */
  getFormattedTime(): string {
    const minutes = Math.floor(this.timer / 60);
    const seconds = this.timer % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  /**
   * 销毁
   */
  destroy(): void {
    this.stopTimer();
  }
}
