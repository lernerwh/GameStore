import { GameConstants, TableState } from './GameConstants';

/**
 * 餐厅数据类 - 存储餐厅的整体状态
 */
export class Restaurant {
  // 金币
  coins: number;

  // 满意度统计
  totalCustomers: number;
  happyCustomers: number;

  // 等级
  level: number;
  experience: number;

  constructor() {
    this.coins = 0;
    this.totalCustomers = 0;
    this.happyCustomers = 0;
    this.level = 1;
    this.experience = 0;
  }

  /**
   * 添加金币
   */
  addCoins(amount: number): void {
    this.coins += amount;
    this.addExperience(amount);
    this.checkLevelUp();
  }

  /**
   * 消耗金币
   */
  spendCoins(amount: number): boolean {
    if (this.coins >= amount) {
      this.coins -= amount;
      return true;
    }
    return false;
  }

  /**
   * 记录顾客
   */
  recordCustomer(satisfied: boolean): void {
    this.totalCustomers++;
    if (satisfied) {
      this.happyCustomers++;
    }
  }

  /**
   * 获取满意度百分比
   */
  getSatisfactionRate(): number {
    if (this.totalCustomers === 0) return 100;
    return Math.round((this.happyCustomers / this.totalCustomers) * 100);
  }

  /**
   * 添加经验
   */
  private addExperience(amount: number): void {
    this.experience += Math.floor(amount / 2);
  }

  /**
   * 检查升级
   */
  private checkLevelUp(): void {
    const expNeeded = this.level * 100;
    if (this.experience >= expNeeded) {
      this.experience -= expNeeded;
      this.level++;
    }
  }

  /**
   * 获取升级所需经验
   */
  getExpNeeded(): number {
    return this.level * 100;
  }

  /**
   * 获取经验进度
   */
  getExpProgress(): number {
    return this.experience / this.getExpNeeded();
  }

  /**
   * 重置餐厅数据
   */
  reset(): void {
    this.coins = 0;
    this.totalCustomers = 0;
    this.happyCustomers = 0;
    this.level = 1;
    this.experience = 0;
  }
}
