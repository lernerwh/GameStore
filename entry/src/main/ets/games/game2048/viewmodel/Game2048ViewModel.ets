import { BOARD_SIZE, Game2048State, MoveDirection, WIN_VALUE } from '../model/Game2048Constants';

class LineMergeResult {
  line: number[] = [];
  gained: number = 0;
  reachedWin: boolean = false;
}

class EmptyCell {
  row: number = 0;
  col: number = 0;
}

@Observed
export class Game2048ViewModel {
  @Track board: number[][] = [];
  @Track score: number = 0;
  @Track bestScore: number = 0;
  @Track gameState: Game2048State = Game2048State.READY;

  private wonAcknowledged: boolean = false;

  constructor() {
    this.resetGame();
  }

  resetGame(): void {
    this.board = [];
    for (let row = 0; row < BOARD_SIZE; row++) {
      const rowData: number[] = [];
      for (let col = 0; col < BOARD_SIZE; col++) {
        rowData.push(0);
      }
      this.board.push(rowData);
    }

    this.score = 0;
    this.gameState = Game2048State.PLAYING;
    this.wonAcknowledged = false;
    this.spawnRandomTile();
    this.spawnRandomTile();
  }

  continueAfterWin(): void {
    if (this.gameState === Game2048State.WON) {
      this.gameState = Game2048State.PLAYING;
      this.wonAcknowledged = true;
    }
  }

  move(direction: MoveDirection): boolean {
    if (this.gameState === Game2048State.OVER) {
      return false;
    }

    if (this.gameState === Game2048State.WON && !this.wonAcknowledged) {
      return false;
    }

    const next = this.cloneBoard();
    let moved = false;
    let gainedScore = 0;
    let reachedWin = false;

    if (direction === MoveDirection.LEFT || direction === MoveDirection.RIGHT) {
      for (let row = 0; row < BOARD_SIZE; row++) {
        const line = next[row].slice();
        const input = direction === MoveDirection.LEFT ? line : line.reverse();
        const result = this.slideAndMergeLine(input);
        const merged = direction === MoveDirection.LEFT ? result.line : result.line.reverse();
        if (!this.sameLine(next[row], merged)) {
          moved = true;
        }
        next[row] = merged;
        gainedScore += result.gained;
        reachedWin = reachedWin || result.reachedWin;
      }
    } else {
      for (let col = 0; col < BOARD_SIZE; col++) {
        const line: number[] = [];
        for (let row = 0; row < BOARD_SIZE; row++) {
          line.push(next[row][col]);
        }
        const input = direction === MoveDirection.UP ? line : line.reverse();
        const result = this.slideAndMergeLine(input);
        const merged = direction === MoveDirection.UP ? result.line : result.line.reverse();

        if (!this.sameLine(line, merged)) {
          moved = true;
        }

        for (let row = 0; row < BOARD_SIZE; row++) {
          next[row][col] = merged[row];
        }
        gainedScore += result.gained;
        reachedWin = reachedWin || result.reachedWin;
      }
    }

    if (!moved) {
      return false;
    }

    this.board = next;
    this.score += gainedScore;
    if (this.score > this.bestScore) {
      this.bestScore = this.score;
    }

    this.spawnRandomTile();

    if (reachedWin && !this.wonAcknowledged) {
      this.gameState = Game2048State.WON;
      return true;
    }

    if (!this.canMove()) {
      this.gameState = Game2048State.OVER;
    } else {
      this.gameState = Game2048State.PLAYING;
    }

    return true;
  }

  private slideAndMergeLine(line: number[]): LineMergeResult {
    const filtered: number[] = line.filter(v => v !== 0);
    const merged: number[] = [];
    let gained = 0;
    let reachedWin = false;

    let idx = 0;
    while (idx < filtered.length) {
      if (idx + 1 < filtered.length && filtered[idx] === filtered[idx + 1]) {
        const value = filtered[idx] * 2;
        merged.push(value);
        gained += value;
        if (value >= WIN_VALUE) {
          reachedWin = true;
        }
        idx += 2;
      } else {
        merged.push(filtered[idx]);
        idx += 1;
      }
    }

    while (merged.length < BOARD_SIZE) {
      merged.push(0);
    }

    const result = new LineMergeResult();
    result.line = merged;
    result.gained = gained;
    result.reachedWin = reachedWin;
    return result;
  }

  private spawnRandomTile(): void {
    const emptyCells: EmptyCell[] = [];

    for (let row = 0; row < BOARD_SIZE; row++) {
      for (let col = 0; col < BOARD_SIZE; col++) {
        if (this.board[row][col] === 0) {
          const cell = new EmptyCell();
          cell.row = row;
          cell.col = col;
          emptyCells.push(cell);
        }
      }
    }

    if (emptyCells.length === 0) {
      return;
    }

    const target = emptyCells[Math.floor(Math.random() * emptyCells.length)];
    const tileValue = Math.random() < 0.9 ? 2 : 4;
    const next = this.cloneBoard();
    next[target.row][target.col] = tileValue;
    this.board = next;
  }

  private canMove(): boolean {
    for (let row = 0; row < BOARD_SIZE; row++) {
      for (let col = 0; col < BOARD_SIZE; col++) {
        const value = this.board[row][col];
        if (value === 0) {
          return true;
        }

        if (col + 1 < BOARD_SIZE && value === this.board[row][col + 1]) {
          return true;
        }

        if (row + 1 < BOARD_SIZE && value === this.board[row + 1][col]) {
          return true;
        }
      }
    }

    return false;
  }

  private cloneBoard(): number[][] {
    return this.board.map(row => row.slice());
  }

  private sameLine(a: number[], b: number[]): boolean {
    for (let i = 0; i < a.length; i++) {
      if (a[i] !== b[i]) {
        return false;
      }
    }
    return true;
  }
}
