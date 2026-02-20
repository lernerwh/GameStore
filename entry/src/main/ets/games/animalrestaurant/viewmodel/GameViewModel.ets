import { GameEngine } from './GameEngine';
import { Customer } from '../model/Customer';
import { Table } from '../model/Table';
import { Dish } from '../model/Dish';
import { Restaurant } from '../model/Restaurant';
import { GameState } from '../model/GameConstants';

/**
 * 游戏视图模型 - 连接游戏引擎和UI视图
 */
@Observed
export class GameViewModel {
  private engine: GameEngine;

  // 可观察的状态
  @Track gameState: GameState;
  @Track coins: number;
  @Track level: number;
  @Track satisfactionRate: number;

  // 游戏循环
  private intervalId: number | null = null;
  private lastFrameTime: number = 0;
  private readonly FRAME_TIME: number = 1000 / 60;

  constructor() {
    this.engine = new GameEngine();
    this.gameState = GameState.IDLE;
    this.coins = 0;
    this.level = 1;
    this.satisfactionRate = 100;
  }

  /**
   * 获取游戏引擎（用于渲染器获取数据）
   */
  getEngine(): GameEngine {
    return this.engine;
  }

  /**
   * 获取餐桌列表
   */
  getTables(): Table[] {
    return this.engine.getTables();
  }

  /**
   * 获取等待的顾客
   */
  getWaitingCustomers(): Customer[] {
    return this.engine.getWaitingCustomers();
  }

  /**
   * 获取所有顾客
   */
  getAllCustomers(): Customer[] {
    return this.engine.getAllCustomers();
  }

  /**
   * 获取所有菜品
   */
  getDishes(): Dish[] {
    return this.engine.getDishes();
  }

  /**
   * 获取餐厅数据
   */
  getRestaurant(): Restaurant {
    return this.engine.getRestaurant();
  }

  /**
   * 开始游戏
   */
  startGame(): void {
    this.engine.startGame();
    this.gameState = this.engine.getGameState();
    this.startGameLoop();
  }

  /**
   * 暂停游戏
   */
  pauseGame(): void {
    this.engine.pauseGame();
    this.gameState = this.engine.getGameState();
  }

  /**
   * 继续游戏
   */
  resumeGame(): void {
    this.engine.resumeGame();
    this.gameState = this.engine.getGameState();
  }

  /**
   * 启动游戏循环
   */
  private startGameLoop(): void {
    this.lastFrameTime = Date.now();
    this.intervalId = setInterval(() => {
      this.gameLoop();
    }, this.FRAME_TIME);
  }

  /**
   * 游戏循环
   */
  private gameLoop(): void {
    const now = Date.now();
    const deltaTime = Math.min((now - this.lastFrameTime) / 1000, 0.1);
    this.lastFrameTime = now;

    this.engine.update(deltaTime);
    this.syncState();
  }

  /**
   * 同步状态到视图
   */
  private syncState(): void {
    this.gameState = this.engine.getGameState();
    const restaurant = this.engine.getRestaurant();
    this.coins = restaurant.coins;
    this.level = restaurant.level;
    this.satisfactionRate = restaurant.getSatisfactionRate();
  }

  /**
   * 停止游戏循环
   */
  private stopGameLoop(): void {
    if (this.intervalId !== null) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  /**
   * 点击餐桌
   */
  clickTable(tableId: number): void {
    this.engine.clickTable(tableId);
  }

  /**
   * 点击菜品
   */
  clickDish(dishId: number): void {
    this.engine.clickDish(dishId);
  }

  /**
   * 点击顾客
   */
  clickCustomer(customerId: number): void {
    this.engine.clickCustomer(customerId);
  }

  /**
   * 销毁视图模型
   */
  destroy(): void {
    this.stopGameLoop();
    this.engine.reset();
  }
}
