/**
 * 召唤神龙 游戏常量定义
 */
export class GameConstants {
  // 画布尺寸
  static readonly CANVAS_WIDTH: number = 360;
  static readonly CANVAS_HEIGHT: number = 640;

  // 世界尺寸
  static readonly WORLD_WIDTH: number = 2000;
  static readonly WORLD_HEIGHT: number = 3000;

  // 玩家属性
  static readonly PLAYER_SIZE: number = 30;
  static readonly PLAYER_SPEED: number = 200;

  // 游戏规则
  static readonly SCORE_PER_HIT: number = 1;

  // 颜色定义
  static readonly COLOR_BACKGROUND: string = '#0a1628';
  static readonly COLOR_PLAYER: string = '#FFD700';
  static readonly COLOR_ENEMY: string = '#FF6B6B';
  static readonly COLOR_TEXT: string = '#FFFFFF';

  // 进化等级名称
  static readonly EVOLUTION_NAMES: string[] = [
    '浮游生物',
    '小虾',
    '小鱼',
    '中鱼',
    '大鱼',
    '海龟',
    '海豚',
    '鲨鱼',
    '虎鲸',
    '神龙'
  ];

  // 进化等级颜色
  static readonly EVOLUTION_COLORS: string[] = [
    '#90EE90', // 浮游生物 - 浅绿
    '#98FB98', // 小虾 - 淡绿
    '#00CED1', // 小鱼 - 青色
    '#1E90FF', // 中鱼 - 道奇蓝
    '#4169E1', // 大鱼 - 皇家蓝
    '#8A2BE2', // 海龟 - 紫罗兰
    '#FF6347', // 海豚 - 番茄红
    '#FF4500', // 鲨鱼 - 橙红
    '#DC143C', // 虎鲸 - 深红
    '#FFD700'  // 神龙 - 金色
  ];

  // 进化等级大小
  static readonly EVOLUTION_SIZES: number[] = [
    15,  // 浮游生物
    20,  // 小虾
    28,  // 小鱼
    38,  // 中鱼
    50,  // 大鱼
    65,  // 海龟
    85,  // 海豚
    110, // 鲨鱼
    140, // 虎鲸
    180  // 神龙
  ];

  // 进化所需分数
  static readonly EVOLUTION_SCORES: number[] = [
    0,    // 浮游生物
    30,   // 小虾
    80,   // 小鱼
    150,  // 中鱼
    250,  // 大鱼
    400,  // 海龟
    600,  // 海豚
    900,  // 鲨鱼
    1300, // 虎鲸
    2000  // 神龙
  ];

  // 生物数量配置
  static readonly CREATURE_COUNT: number = 80;
  static readonly CREATURE_SPAWN_INTERVAL: number = 3000;

  // 摄像机配置
  static readonly CAMERA_FOLLOW_SPEED: number = 0.1;
}
