import { Customer } from '../model/Customer';
import { Table } from '../model/Table';
import { Dish } from '../model/Dish';
import { Restaurant } from '../model/Restaurant';
import { GameConstants, GameState, DishType, CustomerState, TableState } from '../model/GameConstants';
import { MathUtils } from '../model/MathUtils';

/**
 * 游戏引擎 - 动物餐厅核心逻辑
 */
export class GameEngine {
  // 游戏状态
  private gameState: GameState;

  // 餐厅实体
  private restaurant: Restaurant;
  private tables: Table[];
  private waitingCustomers: Customer[];   // 等待入座的顾客
  private allCustomers: Customer[];       // 所有顾客（用于更新）
  private dishes: Dish[];                 // 所有菜品

  // 计时器
  private customerSpawnTimer: number;
  private orderingTimer: Map<number, number>;  // 顾客ID -> 点餐计时

  constructor() {
    this.gameState = GameState.IDLE;
    this.restaurant = new Restaurant();
    this.tables = [];
    this.waitingCustomers = [];
    this.allCustomers = [];
    this.dishes = [];
    this.customerSpawnTimer = 0;
    this.orderingTimer = new Map();

    this.initTables();
  }

  /**
   * 初始化餐桌
   */
  private initTables(): void {
    this.tables = [];
    for (let i = 0; i < GameConstants.TABLE_COUNT; i++) {
      const row = Math.floor(i / 2);
      const col = i % 2;
      const x = GameConstants.TABLE_START_X + col * (GameConstants.TABLE_WIDTH + GameConstants.TABLE_GAP + 180);
      const y = GameConstants.TABLE_START_Y + row * (GameConstants.TABLE_HEIGHT + GameConstants.TABLE_GAP + 80);
      this.tables.push(new Table(x, y));
    }
  }

  /**
   * 获取游戏状态
   */
  getGameState(): GameState {
    return this.gameState;
  }

  /**
   * 获取餐厅数据
   */
  getRestaurant(): Restaurant {
    return this.restaurant;
  }

  /**
   * 获取餐桌列表
   */
  getTables(): Table[] {
    return this.tables;
  }

  /**
   * 获取等待的顾客
   */
  getWaitingCustomers(): Customer[] {
    return this.waitingCustomers;
  }

  /**
   * 获取所有顾客
   */
  getAllCustomers(): Customer[] {
    return this.allCustomers;
  }

  /**
   * 获取所有菜品
   */
  getDishes(): Dish[] {
    return this.dishes;
  }

  /**
   * 获取金币
   */
  getCoins(): number {
    return this.restaurant.coins;
  }

  /**
   * 开始游戏
   */
  startGame(): void {
    this.gameState = GameState.PLAYING;
    this.restaurant.reset();
    this.tables = [];
    this.waitingCustomers = [];
    this.allCustomers = [];
    this.dishes = [];
    this.customerSpawnTimer = 0;
    this.orderingTimer.clear();
    this.initTables();
  }

  /**
   * 暂停游戏
   */
  pauseGame(): void {
    this.gameState = GameState.PAUSED;
  }

  /**
   * 继续游戏
   */
  resumeGame(): void {
    this.gameState = GameState.PLAYING;
  }

  /**
   * 更新游戏状态
   */
  update(deltaTime: number): void {
    if (this.gameState !== GameState.PLAYING) {
      return;
    }

    // 生成新顾客
    this.spawnCustomers(deltaTime);

    // 更新所有顾客
    this.updateCustomers(deltaTime);

    // 更新所有菜品
    this.updateDishes(deltaTime);

    // 处理点餐
    this.processOrdering(deltaTime);

    // 安排顾客入座
    this.seatWaitingCustomers();

    // 清理离开的顾客
    this.cleanupCustomers();
  }

  /**
   * 生成新顾客
   */
  private spawnCustomers(deltaTime: number): void {
    this.customerSpawnTimer += deltaTime * 1000;

    if (this.customerSpawnTimer >= GameConstants.CUSTOMER_SPAWN_INTERVAL) {
      this.customerSpawnTimer = 0;

      // 限制最大等待顾客数量
      if (this.waitingCustomers.length < 4) {
        const customer = new Customer();
        customer.x = GameConstants.CUSTOMER_WAIT_X + this.waitingCustomers.length * 60;
        customer.y = GameConstants.CUSTOMER_WAIT_Y;
        this.waitingCustomers.push(customer);
        this.allCustomers.push(customer);
      }
    }
  }

  /**
   * 更新所有顾客
   */
  private updateCustomers(deltaTime: number): void {
    for (const customer of this.allCustomers) {
      customer.update(deltaTime);

      // 顾客离开时处理
      if (customer.state === CustomerState.LEAVING && customer.tableId !== null) {
        const table = this.tables.find(t => t.id === customer.tableId);
        if (table) {
          table.customerLeave();
          // 记录满意度
          const satisfied = customer.getPatiencePercent() > 0.3;
          this.restaurant.recordCustomer(satisfied);
          // 根据满意度给金币
          if (satisfied) {
            const bonus = Math.floor(customer.getPatiencePercent() * 20);
            this.restaurant.addCoins(bonus);
          }
        }
        customer.tableId = null;
      }
    }
  }

  /**
   * 更新所有菜品
   */
  private updateDishes(deltaTime: number): void {
    for (const dish of this.dishes) {
      dish.update(deltaTime);

      // 菜品送达后，给顾客上菜
      if (dish.isServed() && dish.customerId !== null) {
        const customer = this.allCustomers.find(c => c.id === dish.customerId);
        if (customer) {
          customer.serveFood();
        }
        // 从列表移除已送达的菜品
        const index = this.dishes.indexOf(dish);
        if (index > -1) {
          this.dishes.splice(index, 1);
        }
      }
    }
  }

  /**
   * 处理点餐逻辑
   */
  private processOrdering(deltaTime: number): void {
    for (const table of this.tables) {
      if (table.customer && table.customer.state === CustomerState.SITTING) {
        // 顾客坐下后，1秒后开始点餐
        let timer = this.orderingTimer.get(table.customer.id) ?? 0;
        timer += deltaTime * 1000;
        this.orderingTimer.set(table.customer.id, timer);

        if (timer >= 1000) {
          const orderedDish = table.customer.order();
          table.customer.finishOrdering();
          this.orderingTimer.delete(table.customer.id);

          // 创建菜品开始烹饪
          const dish = new Dish(orderedDish);
          dish.customerId = table.customer.id;
          this.dishes.push(dish);
        }
      }
    }
  }

  /**
   * 安排等待的顾客入座
   */
  private seatWaitingCustomers(): void {
    const availableTables = this.tables.filter(t => t.isAvailable());

    for (const table of availableTables) {
      if (this.waitingCustomers.length > 0) {
        const customer = this.waitingCustomers[0];
        this.waitingCustomers.splice(0, 1);
        if (customer) {
          table.seatCustomer(customer);
        }
      }
    }
  }

  /**
   * 清理已离开的顾客
   */
  private cleanupCustomers(): void {
    this.allCustomers = this.allCustomers.filter(c => !c.isOffScreen());
  }

  /**
   * 点击餐桌 - 清理或安排入座
   */
  clickTable(tableId: number): void {
    const table = this.tables.find(t => t.id === tableId);
    if (table) {
      if (table.state === TableState.NEEDS_CLEAN) {
        table.clean();
      }
    }
  }

  /**
   * 点击菜品 - 上菜
   */
  clickDish(dishId: number): void {
    const dish = this.dishes.find(d => d.id === dishId);
    if (dish && dish.isReady() && dish.customerId !== null) {
      const customer = this.allCustomers.find(c => c.id === dish.customerId);
      if (customer && customer.tableId !== null) {
        const table = this.tables.find(t => t.id === customer.tableId);
        if (table) {
          // 设置配送目标到餐桌
          dish.setDeliverTarget(
            table.x + table.width / 2,
            table.y + table.height / 2,
            customer.id
          );
        }
      }
    }
  }

  /**
   * 点击顾客 - 加速服务（可选功能）
   */
  clickCustomer(customerId: number): void {
    // 可以添加特殊功能，比如安抚顾客
    const customer = this.allCustomers.find(c => c.id === customerId);
    if (customer) {
      // 恢复一些耐心
      customer.patience = Math.min(customer.patience + 5000, customer.maxPatience);
    }
  }

  /**
   * 重置游戏
   */
  reset(): void {
    this.gameState = GameState.IDLE;
    this.restaurant.reset();
    this.tables = [];
    this.waitingCustomers = [];
    this.allCustomers = [];
    this.dishes = [];
    this.customerSpawnTimer = 0;
    this.orderingTimer.clear();
    this.initTables();
  }
}
