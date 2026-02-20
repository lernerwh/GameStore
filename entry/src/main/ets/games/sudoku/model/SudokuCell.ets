/**
 * 数独单元格
 */
export class SudokuCell {
  value: number;           // 当前值 (0-9, 0表示空)
  fixed: boolean;          // 是否是固定的初始数字
  notes: Set<number>;      // 笔记/候选数字
  error: boolean;          // 是否有错误

  constructor(value: number = 0, fixed: boolean = false) {
    this.value = value;
    this.fixed = fixed;
    this.notes = new Set<number>();
    this.error = false;
  }

  hasValue(): boolean {
    return this.value > 0;
  }

  setValue(val: number): void {
    if (!this.fixed) {
      this.value = val;
      this.notes.clear();
    }
  }

  clearValue(): void {
    if (!this.fixed) {
      this.value = 0;
      this.error = false;
    }
  }

  toggleNote(num: number): void {
    if (!this.fixed && !this.hasValue()) {
      if (this.notes.has(num)) {
        this.notes.delete(num);
      } else {
        this.notes.add(num);
      }
    }
  }
}
