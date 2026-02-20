import { AnimalType, AnimalConfig, CustomerState, DishType, DishConfig, GameConstants } from './GameConstants';
import { MathUtils, Rect } from './MathUtils';

/**
 * 顾客实体类 - 代表一位来餐厅的动物顾客
 */
export class Customer {
  // 基础属性
  id: number;
  animalType: AnimalType;
  name: string;
  color: string;
  emoji: string;

  // 位置属性
  x: number;
  y: number;
  targetX: number;
  targetY: number;
  size: number;

  // 状态属性
  state: CustomerState;
  patience: number;          // 耐心值（毫秒）
  maxPatience: number;       // 最大耐心值
  tableId: number | null;    // 分配的餐桌ID
  orderDish: DishType | null; // 点的菜品
  eatingProgress: number;    // 进食进度 0-1

  // 动画属性
  moveSpeed: number;

  private static nextId: number = 1;

  constructor(animalType?: AnimalType) {
    this.id = Customer.nextId++;

    // 随机选择动物类型
    if (animalType !== undefined) {
      this.animalType = animalType;
    } else {
      const animalCount = AnimalConfig.getAnimalCount();
      this.animalType = MathUtils.randomInt(0, animalCount - 1) as AnimalType;
    }

    const config = AnimalConfig.getAnimal(this.animalType);
    this.name = config.name;
    this.color = config.color;
    this.emoji = config.emoji;

    // 初始位置在入口
    this.x = -60;
    this.y = GameConstants.CUSTOMER_WAIT_Y;
    this.targetX = this.x;
    this.targetY = this.y;
    this.size = GameConstants.CUSTOMER_SIZE;

    this.state = CustomerState.WAITING;
    this.maxPatience = GameConstants.CUSTOMER_PATIENCE_MAX;
    this.patience = this.maxPatience;
    this.tableId = null;
    this.orderDish = null;
    this.eatingProgress = 0;

    this.moveSpeed = 150; // 移动速度（像素/秒）
  }

  /**
   * 设置目标位置
   */
  setTarget(x: number, y: number): void {
    this.targetX = x;
    this.targetY = y;
  }

  /**
   * 更新顾客状态
   */
  update(deltaTime: number): void {
    // 移动到目标位置
    if (this.state === CustomerState.WALKING_TO_TABLE || this.state === CustomerState.LEAVING) {
      this.moveToTarget(deltaTime);
    }

    // 等待时消耗耐心
    if (this.state === CustomerState.WAITING ||
        this.state === CustomerState.WAITING_FOOD) {
      this.patience -= deltaTime * 1000;
      if (this.patience <= 0) {
        this.patience = 0;
        // 耐心耗尽，离开
        this.state = CustomerState.LEAVING;
      }
    }

    // 进食
    if (this.state === CustomerState.EATING) {
      this.eatingProgress += deltaTime * 0.5; // 2秒吃完
      if (this.eatingProgress >= 1) {
        this.eatingProgress = 1;
        this.state = CustomerState.LEAVING;
        this.setTarget(-60, this.y);
      }
    }
  }

  /**
   * 移动到目标位置
   */
  private moveToTarget(deltaTime: number): void {
    const dx = this.targetX - this.x;
    const dy = this.targetY - this.y;
    const dist = Math.sqrt(dx * dx + dy * dy);

    if (dist > 5) {
      const moveDistance = this.moveSpeed * deltaTime;
      const ratio = Math.min(moveDistance / dist, 1);
      this.x += dx * ratio;
      this.y += dy * ratio;
    } else {
      this.x = this.targetX;
      this.y = this.targetY;

      // 到达目标后更新状态
      if (this.state === CustomerState.WALKING_TO_TABLE) {
        this.state = CustomerState.SITTING;
        this.patience = this.maxPatience; // 重置耐心
      }
    }
  }

  /**
   * 分配餐桌
   */
  assignTable(tableId: number, tableX: number, tableY: number): void {
    this.tableId = tableId;
    this.state = CustomerState.WALKING_TO_TABLE;
    this.setTarget(tableX, tableY);
  }

  /**
   * 点餐
   */
  order(): DishType {
    this.state = CustomerState.ORDERING;
    // 随机点一道菜
    const dishCount = DishConfig.getDishCount();
    this.orderDish = MathUtils.randomInt(0, dishCount - 1) as DishType;
    return this.orderDish;
  }

  /**
   * 上菜
   */
  serveFood(): void {
    if (this.state === CustomerState.WAITING_FOOD && this.orderDish !== null) {
      this.state = CustomerState.EATING;
      this.eatingProgress = 0;
    }
  }

  /**
   * 获取耐心百分比
   */
  getPatiencePercent(): number {
    return this.patience / this.maxPatience;
  }

  /**
   * 获取碰撞矩形
   */
  getCollisionRect(): Rect {
    const rect: Rect = {
      x: this.x - this.size / 2,
      y: this.y - this.size / 2,
      width: this.size,
      height: this.size
    };
    return rect;
  }

  /**
   * 是否已离开屏幕
   */
  isOffScreen(): boolean {
    return this.x < -this.size && this.state === CustomerState.LEAVING;
  }

  /**
   * 完成点餐，开始等待上菜
   */
  finishOrdering(): void {
    if (this.state === CustomerState.ORDERING) {
      this.state = CustomerState.WAITING_FOOD;
    }
  }

  /**
   * 获取满意度分数（0-100）
   */
  getSatisfactionScore(): number {
    return Math.round(this.getPatiencePercent() * 100);
  }
}
