import { TableState, GameConstants } from './GameConstants';
import { Rect } from './MathUtils';
import { Customer } from './Customer';

/**
 * 餐桌实体类
 */
export class Table {
  id: number;
  x: number;
  y: number;
  width: number;
  height: number;
  state: TableState;
  customer: Customer | null;

  private static nextId: number = 1;

  constructor(x: number, y: number) {
    this.id = Table.nextId++;
    this.x = x;
    this.y = y;
    this.width = GameConstants.TABLE_WIDTH;
    this.height = GameConstants.TABLE_HEIGHT;
    this.state = TableState.EMPTY;
    this.customer = null;
  }

  /**
   * 是否可用
   */
  isAvailable(): boolean {
    return this.state === TableState.EMPTY && this.customer === null;
  }

  /**
   * 安排顾客入座
   */
  seatCustomer(customer: Customer): void {
    this.customer = customer;
    this.state = TableState.OCCUPIED;
    customer.assignTable(this.id, this.x + this.width / 2, this.y + this.height + 20);
  }

  /**
   * 顾客离开，需要清理
   */
  customerLeave(): void {
    this.customer = null;
    this.state = TableState.NEEDS_CLEAN;
  }

  /**
   * 清理餐桌
   */
  clean(): void {
    if (this.state === TableState.NEEDS_CLEAN) {
      this.state = TableState.EMPTY;
    }
  }

  /**
   * 获取碰撞矩形
   */
  getCollisionRect(): Rect {
    const rect: Rect = {
      x: this.x,
      y: this.y,
      width: this.width,
      height: this.height
    };
    return rect;
  }
}
