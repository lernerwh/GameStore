/**
 * 动物餐厅 - 游戏常量定义
 */
export class GameConstants {
  // 画布尺寸
  static readonly CANVAS_WIDTH: number = 360;
  static readonly CANVAS_HEIGHT: number = 700;

  // 餐厅配置
  static readonly TABLE_COUNT: number = 4;          // 餐桌数量
  static readonly TABLE_WIDTH: number = 80;
  static readonly TABLE_HEIGHT: number = 60;
  static readonly TABLE_GAP: number = 10;
  static readonly TABLE_START_X: number = 20;
  static readonly TABLE_START_Y: number = 200;

  // 顾客配置
  static readonly CUSTOMER_SIZE: number = 100;         // 顾客大小
  static readonly CUSTOMER_SPAWN_INTERVAL: number = 3000;  // 3秒生成一个顾客
  static readonly CUSTOMER_PATIENCE_MAX: number = 30000;    // 30秒耐心值
  static readonly CUSTOMER_WAIT_X: number = 180;            // 等待区X坐标
  static readonly CUSTOMER_WAIT_Y: number = 120;            // 等待区Y坐标

  // 厨房配置
  static readonly KITCHEN_X: number = 10;
  static readonly KITCHEN_Y: number = 10;
  static readonly KITCHEN_WIDTH: number = 150;
  static readonly KITCHEN_HEIGHT: number = 80;
  static readonly COOKING_TIME: number = 5000;   // 烹饪时间5秒

  // 菜品配置
  static readonly DISH_SIZE: number = 40;

  // 金币配置
  static readonly COIN_PER_DISH: number = 10;
  static readonly COIN_PER_HAPPY: number = 5;    // 满意度奖励

  // 颜色定义 - 温馨餐厅风格
  static readonly COLOR_BACKGROUND: string = '#FFF8E7';      // 米色背景
  static readonly COLOR_TABLE: string = '#8B4513';           // 棕色桌子
  static readonly COLOR_TABLECLOTH: string = '#FFFFFF';      // 白色桌布
  static readonly COLOR_KITCHEN: string = '#4A4A4A';         // 深灰色厨房
  static readonly COLOR_COUNTER: string = '#D2691E';         // 柜台色
  static readonly COLOR_TEXT: string = '#333333';
  static readonly COLOR_GOLD: string = '#FFD700';
  static readonly COLOR_HAPPY: string = '#4CAF50';           // 满意绿色
  static readonly COLOR_WARNING: string = '#FF9800';         // 警告橙色
  static readonly COLOR_DANGER: string = '#F44336';          // 危险红色
}

/**
 * 动物类型枚举
 */
export enum AnimalType {
  CAT = 0,       // 猫咪
  DOG = 1,       // 狗狗
  RABBIT = 2,    // 兔子
  BEAR = 3,      // 熊熊
  FOX = 4,       // 狐狸
  PANDA = 5      // 熊猫
}

/**
 * 动物配置数据类
 */
export class AnimalData {
  name: string = '';
  color: string = '';
  emoji: string = '';

  constructor(name: string, color: string, emoji: string) {
    this.name = name;
    this.color = color;
    this.emoji = emoji;
  }
}

/**
 * 动物配置管理类
 */
export class AnimalConfig {
  private static readonly animalList: AnimalData[] = [
    new AnimalData('猫咪', '#FFB6C1', '🐱'),
    new AnimalData('狗狗', '#DEB887', '🐕'),
    new AnimalData('兔子', '#FFE4E1', '🐰'),
    new AnimalData('熊熊', '#8B4513', '🐻'),
    new AnimalData('狐狸', '#FF6B35', '🦊'),
    new AnimalData('熊猫', '#2C2C2C', '🐼')
  ];

  static getAnimal(type: AnimalType): AnimalData {
    return AnimalConfig.animalList[type];
  }

  static getAllAnimals(): AnimalData[] {
    return AnimalConfig.animalList;
  }

  static getAnimalCount(): number {
    return AnimalConfig.animalList.length;
  }
}

/**
 * 菜品类型枚举
 */
export enum DishType {
  FISH = 0,      // 烤鱼
  MEAT = 1,      // 烤肉
  SOUP = 2,      // 浓汤
  SALAD = 3,     // 沙拉
  CAKE = 4,      // 蛋糕
  DRINK = 5      // 饮料
}

/**
 * 菜品配置数据类
 */
export class DishData {
  name: string = '';
  color: string = '';
  price: number = 0;
  emoji: string = '';

  constructor(name: string, color: string, price: number, emoji: string) {
    this.name = name;
    this.color = color;
    this.price = price;
    this.emoji = emoji;
  }
}

/**
 * 菜品配置管理类
 */
export class DishConfig {
  private static readonly dishList: DishData[] = [
    new DishData('烤鱼', '#4169E1', 15, '🐟'),
    new DishData('烤肉', '#8B0000', 20, '🍖'),
    new DishData('浓汤', '#FFA500', 12, '🍲'),
    new DishData('沙拉', '#32CD32', 10, '🥗'),
    new DishData('蛋糕', '#FFB6C1', 18, '🍰'),
    new DishData('饮料', '#87CEEB', 8, '🥤')
  ];

  static getDish(type: DishType): DishData {
    return DishConfig.dishList[type];
  }

  static getAllDishes(): DishData[] {
    return DishConfig.dishList;
  }

  static getDishCount(): number {
    return DishConfig.dishList.length;
  }
}

/**
 * 顾客状态枚举
 */
export enum CustomerState {
  WAITING = 0,           // 等待入座
  WALKING_TO_TABLE = 1,  // 走向餐桌
  SITTING = 2,           // 已入座，等待点餐
  ORDERING = 3,          // 点餐中
  WAITING_FOOD = 4,      // 等待上菜
  EATING = 5,            // 进食中
  LEAVING = 6            // 离开
}

/**
 * 餐桌状态枚举
 */
export enum TableState {
  EMPTY = 0,           // 空桌
  OCCUPIED = 1,        // 有人
  NEEDS_CLEAN = 2      // 需要清理
}

/**
 * 菜品状态枚举
 */
export enum DishState {
  COOKING = 0,      // 烹饪中
  READY = 1,        // 已准备好
  DELIVERING = 2,   // 配送中
  SERVED = 3        // 已上菜
}

/**
 * 游戏状态枚举
 */
export enum GameState {
  IDLE = 0,
  PLAYING = 1,
  PAUSED = 2
}
