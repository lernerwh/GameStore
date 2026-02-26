/**
 * 红警 Lite 游戏常量
 */

// 游戏ID
export const GAME_ID = 'redalertlite';

// 地图设置
export const TILE_SIZE: number = 80;           // 每格像素 (80x80)
export const MAP_GRID_WIDTH: number = 33;      // 地图网格宽度 (33 格)
export const MAP_GRID_HEIGHT: number = 66;     // 地图网格高度 (66 格)

// 世界尺寸
export const WORLD_WIDTH: number = MAP_GRID_WIDTH * TILE_SIZE;   // 2640
export const WORLD_HEIGHT: number = MAP_GRID_HEIGHT * TILE_SIZE; // 5280

// 资源设置
export const INITIAL_MONEY: number = 5000;     // 初始资金
export const INITIAL_POWER: number = 50;       // 初始电力

// 矿石设置
export const ORE_HARVEST_RATE: number = 25;    // 每次采集量
export const ORE_DISPLAY_RADIUS: number = 30;  // 矿石显示半径

// 颜色接口定义
export interface FactionColors {
  player: string;
  enemy: string;
  neutral: string;
}

export interface TerrainColorSet {
  grass: string;
  grassLight: string;
  water: string;
  waterLight: string;
  ore: string;
  oreDark: string;
  rock: string;
  rockLight: string;
}

export interface UIColorSet {
  hudBg: string;
  hudText: string;
  hudTextDim: string;
  resourceBar: string;
  moneyText: string;
  powerNormal: string;
  powerLow: string;
}

// 阵营颜色
export const FACTION_COLORS: FactionColors = {
  player: '#4CAF50',
  enemy: '#FF6B6B',
  neutral: '#9E9E78'
};

// 地形颜色
export const TERRAIN_COLORS: TerrainColorSet = {
  grass: '#3d5a3d',
  grassLight: '#4a6b4a',
  water: '#1a4a6e',
  waterLight: '#2a5a7e',
  ore: '#c9a66b',
  oreDark: '#a8854a',
  rock: '#5a5a5a',
  rockLight: '#6a6a6a'
};

// UI 颜色
export const UI_COLORS: UIColorSet = {
  hudBg: 'rgba(0, 0, 0, 0.7)',
  hudText: '#FFD700',
  hudTextDim: '#888888',
  resourceBar: '#4CAF50',
  moneyText: '#FFD700',
  powerNormal: '#4CAF50',
  powerLow: '#FF5722'
};

// ==================== 建筑系统 ====================

// 建筑类型枚举
export enum BuildingType {
  CONSTRUCTION_YARD = 'construction_yard',  // 建造厂（基地）
  REFINERY = 'refinery',                     // 矿场
  POWER_PLANT = 'power_plant',               // 电厂
  BARRACKS = 'barracks',                     // 兵营
  WAR_FACTORY = 'war_factory'                // 战车工厂
}

// 建筑状态枚举
export enum BuildingState {
  PLACING = 'placing',      // 放置中（预览）
  BUILDING = 'building',    // 建造中
  ACTIVE = 'active',        // 活跃
  DAMAGED = 'damaged',      // 受损
  DESTROYED = 'destroyed'   // 已摧毁
}

// 建筑配置接口
export interface BuildingConfig {
  type: BuildingType;
  name: string;
  cost: number;              // 造价
  buildTime: number;         // 建造时间（毫秒）
  gridSize: [number, number]; // 占地格子数 [宽, 高]
  powerOutput: number;       // 电力产出（负数表示消耗）
  hp: number;                // 生命值
  description: string;
}

// 建筑配置表
export const BUILDING_CONFIGS: Record<string, BuildingConfig> = {
  [BuildingType.CONSTRUCTION_YARD]: {
    type: BuildingType.CONSTRUCTION_YARD,
    name: '建造厂',
    cost: 0,           // 初始免费
    buildTime: 0,      // 初始立即完成
    gridSize: [3, 3],
    powerOutput: 0,
    hp: 1000,
    description: '基地核心，提供建造能力'
  },
  [BuildingType.REFINERY]: {
    type: BuildingType.REFINERY,
    name: '矿场',
    cost: 1500,
    buildTime: 5000,   // 5秒
    gridSize: [3, 2],
    powerOutput: -10,  // 消耗10电力
    hp: 500,
    description: '处理矿石，提供资金'
  },
  [BuildingType.POWER_PLANT]: {
    type: BuildingType.POWER_PLANT,
    name: '电厂',
    cost: 500,
    buildTime: 3000,   // 3秒
    gridSize: [2, 2],
    powerOutput: 50,   // 产出50电力
    hp: 300,
    description: '提供建筑所需电力'
  },
  [BuildingType.BARRACKS]: {
    type: BuildingType.BARRACKS,
    name: '兵营',
    cost: 800,
    buildTime: 4000,
    gridSize: [2, 3],
    powerOutput: -15,
    hp: 400,
    description: '训练步兵单位'
  },
  [BuildingType.WAR_FACTORY]: {
    type: BuildingType.WAR_FACTORY,
    name: '战车工厂',
    cost: 2000,
    buildTime: 8000,
    gridSize: [3, 3],
    powerOutput: -25,
    hp: 600,
    description: '生产坦克等载具'
  }
};

// 建筑颜色配置
export interface BuildingColorSet {
  foundation: string;
  main: string;
  roof: string;
  accent: string;
  glow: string;
}

export const BUILDING_COLORS: Record<string, BuildingColorSet> = {
  [BuildingType.CONSTRUCTION_YARD]: {
    foundation: '#4a4a4a',
    main: '#5a7a9a',
    roof: '#7a9aba',
    accent: '#aad0f0',
    glow: 'rgba(100, 150, 200, 0.5)'
  },
  [BuildingType.REFINERY]: {
    foundation: '#4a4a4a',
    main: '#8a7a5a',
    roof: '#aa9a7a',
    accent: '#c9a66b',
    glow: 'rgba(200, 160, 100, 0.5)'
  },
  [BuildingType.POWER_PLANT]: {
    foundation: '#4a4a4a',
    main: '#5a8a5a',
    roof: '#7aaa7a',
    accent: '#a0f0a0',
    glow: 'rgba(100, 200, 100, 0.5)'
  },
  [BuildingType.BARRACKS]: {
    foundation: '#4a4a4a',
    main: '#6a5a5a',
    roof: '#8a7a7a',
    accent: '#c0a0a0',
    glow: 'rgba(150, 100, 100, 0.5)'
  },
  [BuildingType.WAR_FACTORY]: {
    foundation: '#4a4a4a',
    main: '#5a5a7a',
    roof: '#7a7a9a',
    accent: '#a0a0d0',
    glow: 'rgba(100, 100, 150, 0.5)'
  }
};

// ==================== 采矿车系统 ====================

// 采矿车状态枚举
export enum HarvesterState {
  IDLE = 'idle',              // 空闲（等待指令）
  SEEKING_ORE = 'seeking_ore', // 寻找矿石
  MOVING_TO_ORE = 'moving_to_ore', // 移动到矿区
  HARVESTING = 'harvesting',   // 采集中
  RETURNING = 'returning',     // 返回矿场
  UNLOADING = 'unloading'      // 卸货中
}

// 采矿车配置
export interface HarvesterConfig {
  maxCapacity: number;      // 最大载货量
  moveSpeed: number;        // 移动速度（像素/秒）
  harvestRate: number;      // 采集速率（单位/秒）
  unloadRate: number;       // 卸货速率（单位/秒）
  searchRange: number;      // 搜索矿石范围（格子数）
}

export const HARVESTER_CONFIG: HarvesterConfig = {
  maxCapacity: 500,
  moveSpeed: 80,      // 每秒移动1格
  harvestRate: 100,   // 每秒采集100单位
  unloadRate: 200,    // 每秒卸货200单位
  searchRange: 10     // 搜索范围10格
};

// 采矿车颜色接口
export interface HarvesterColorSet {
  body: string;
  cargo: string;
  empty: string;
  highlight: string;
}

// 采矿车颜色
export const HARVESTER_COLORS: HarvesterColorSet = {
  body: '#d4a574',        // 车身颜色（棕色）
  cargo: '#c9a66b',       // 货物颜色（金色）
  empty: '#8a8a8a',       // 空载颜色
  highlight: '#ffd700'    // 高亮颜色
};

// ==================== 电力系统 ====================

// 电力状态枚举
export enum PowerStatus {
  NORMAL = 'normal',      // 正常
  LOW = 'low',            // 低电
  CRITICAL = 'critical'   // 严重不足
}

// 电力配置
export interface PowerConfig {
  lowPowerThreshold: number;    // 低电阈值（电力平衡低于此值为低电）
  criticalThreshold: number;    // 严重不足阈值
  lowPowerSpeedMultiplier: number; // 低电时生产速度倍率
  criticalSpeedMultiplier: number; // 严重不足时速度倍率
}

export const POWER_CONFIG: PowerConfig = {
  lowPowerThreshold: 0,         // 电力平衡 <= 0 为低电
  criticalThreshold: -20,       // 电力平衡 <= -20 为严重不足
  lowPowerSpeedMultiplier: 0.5, // 低电时速度降为50%
  criticalSpeedMultiplier: 0.25 // 严重不足时速度降为25%
};

// ==================== 单位系统 ====================

// 单位类型枚举
export enum UnitType {
  INFANTRY = 'infantry',           // 步兵
  TANK = 'tank',                   // 坦克
  HARVESTER = 'harvester'          // 采矿车（特殊单位）
}

// 单位状态枚举
export enum UnitState {
  IDLE = 'idle',                   // 空闲
  MOVING = 'moving',               // 移动中
  ATTACKING = 'attacking',         // 攻击中
  DEAD = 'dead'                    // 死亡
}

// 单位配置接口
export interface UnitConfig {
  type: UnitType;
  name: string;
  cost: number;                    // 造价
  buildTime: number;               // 生产时间（毫秒）
  hp: number;                      // 生命值
  damage: number;                  // 伤害
  attackRange: number;             // 攻击范围（像素）
  attackCooldown: number;          // 攻击冷却（毫秒）
  moveSpeed: number;               // 移动速度（像素/秒）
  size: number;                    // 单位大小
  productionBuilding: BuildingType; // 生产建筑
}

// 单位配置表
export const UNIT_CONFIGS: Record<string, UnitConfig> = {
  [UnitType.INFANTRY]: {
    type: UnitType.INFANTRY,
    name: '步兵',
    cost: 100,
    buildTime: 3000,               // 3秒
    hp: 100,
    damage: 10,
    attackRange: 80,               // 1格
    attackCooldown: 1000,          // 1秒
    moveSpeed: 60,                 // 较慢
    size: 16,
    productionBuilding: BuildingType.BARRACKS
  },
  [UnitType.TANK]: {
    type: UnitType.TANK,
    name: '坦克',
    cost: 500,
    buildTime: 6000,               // 6秒
    hp: 300,
    damage: 30,
    attackRange: 160,              // 2格
    attackCooldown: 2000,          // 2秒
    moveSpeed: 40,                 // 较慢
    size: 24,
    productionBuilding: BuildingType.WAR_FACTORY
  }
};

// 单位颜色
export interface UnitColorSet {
  player: string;
  enemy: string;
  selected: string;
}

export const UNIT_COLORS: UnitColorSet = {
  player: '#4CAF50',
  enemy: '#FF6B6B',
  selected: '#FFD700'
};
