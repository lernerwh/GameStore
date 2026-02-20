import { DishType, DishConfig, GameConstants, DishState } from './GameConstants';
import { Rect } from './MathUtils';

/**
 * 菜品实体类
 */
export class Dish {
  id: number;
  type: DishType;
  name: string;
  color: string;
  emoji: string;
  price: number;

  x: number;
  y: number;
  targetX: number;
  targetY: number;
  size: number;

  state: DishState;
  cookingProgress: number;  // 0-1
  cookingTime: number;      // 总烹饪时间（毫秒）
  customerId: number | null; // 目标顾客ID

  private static nextId: number = 1;

  constructor(type: DishType) {
    this.id = Dish.nextId++;
    this.type = type;
    const config = DishConfig.getDish(type);
    this.name = config.name;
    this.color = config.color;
    this.emoji = config.emoji;
    this.price = config.price;

    // 初始位置在厨房
    this.x = GameConstants.KITCHEN_X + GameConstants.KITCHEN_WIDTH / 2;
    this.y = GameConstants.KITCHEN_Y + GameConstants.KITCHEN_HEIGHT + 20;
    this.targetX = this.x;
    this.targetY = this.y;
    this.size = GameConstants.DISH_SIZE;

    this.state = DishState.COOKING;
    this.cookingProgress = 0;
    this.cookingTime = GameConstants.COOKING_TIME;
    this.customerId = null;
  }

  /**
   * 更新菜品状态
   */
  update(deltaTime: number): void {
    if (this.state === DishState.COOKING) {
      this.cookingProgress += (deltaTime * 1000) / this.cookingTime;
      if (this.cookingProgress >= 1) {
        this.cookingProgress = 1;
        this.state = DishState.READY;
      }
    }

    if (this.state === DishState.DELIVERING) {
      this.moveToTarget(deltaTime);
    }
  }

  /**
   * 移动到目标位置
   */
  private moveToTarget(deltaTime: number): void {
    const speed = 200;
    const dx = this.targetX - this.x;
    const dy = this.targetY - this.y;
    const dist = Math.sqrt(dx * dx + dy * dy);

    if (dist > 5) {
      const moveDistance = speed * deltaTime;
      const ratio = Math.min(moveDistance / dist, 1);
      this.x += dx * ratio;
      this.y += dy * ratio;
    } else {
      this.x = this.targetX;
      this.y = this.targetY;
      this.state = DishState.SERVED;
    }
  }

  /**
   * 设置配送目标
   */
  setDeliverTarget(x: number, y: number, customerId: number): void {
    this.targetX = x;
    this.targetY = y;
    this.customerId = customerId;
    this.state = DishState.DELIVERING;
  }

  /**
   * 是否烹饪完成
   */
  isReady(): boolean {
    return this.state === DishState.READY;
  }

  /**
   * 是否已送达
   */
  isServed(): boolean {
    return this.state === DishState.SERVED;
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
}
