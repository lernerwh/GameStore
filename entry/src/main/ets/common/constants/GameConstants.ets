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
  static readonly PLAYER_INITIAL_SCORE: number = 18;
  static readonly WIN_SCORE: number = 2000;
  static readonly POST_DRAGON_RADIUS_PER_SCORE: number = 0.01;
  static readonly MIN_EAT_SIZE_RATIO: number = 1.05;
  static readonly PLAYER_EAT_SCORE_RATIO: number = 0.65;
  static readonly NPC_EAT_SCORE_RATIO: number = 0.55;
  static readonly PELLET_SCORE: number = 6;
  static readonly PELLET_RADIUS: number = 4;
  static readonly PELLET_COUNT: number = 320;
  static readonly PELLET_SPAWN_INTERVAL: number = 450;
  static readonly PELLET_COLORS: string[] = [
    '#FFD54F', // 金黄
    '#FF8A65', // 橙红
    '#4FC3F7', // 天蓝
    '#81C784', // 青绿
    '#BA68C8', // 紫色
    '#F06292', // 粉色
  ];

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
  static readonly CREATURE_INITIAL_COUNT: number = 50;
  static readonly CREATURE_MIN_COUNT: number = 70;
  static readonly CREATURE_MAX_COUNT: number = 150;
  static readonly CREATURE_SPAWN_INTERVAL: number = 1200;

  // 小豆豆配置
  static readonly PELLET_INITIAL_COUNT: number = 180;

  // 摄像机配置
  static readonly CAMERA_FOLLOW_SPEED: number = 0.1;
  static readonly CAMERA_ZOOM_LERP_SPEED: number = 0.1;
  static readonly CAMERA_MIN_ZOOM: number = 1.0;
  // 最大时可在一屏看到整张地图
  static readonly CAMERA_MAX_ZOOM: number = Math.max(
    GameConstants.WORLD_WIDTH / GameConstants.CANVAS_WIDTH,
    GameConstants.WORLD_HEIGHT / GameConstants.CANVAS_HEIGHT
  );
  static readonly CAMERA_BASE_RADIUS: number = GameConstants.EVOLUTION_SIZES[0] / 2;
  static readonly CAMERA_ZOOM_RADIUS_FACTOR: number = 0.026;

  static getEvolutionLevelByScore(score: number): number {
    const clampedScore = Math.max(0, score);
    for (let i = GameConstants.EVOLUTION_SCORES.length - 1; i >= 0; i--) {
      if (clampedScore >= GameConstants.EVOLUTION_SCORES[i]) {
        return i;
      }
    }
    return 0;
  }

  static getRadiusByScore(score: number): number {
    const minRadius = GameConstants.EVOLUTION_SIZES[0] / 2;
    const maxRadius = GameConstants.EVOLUTION_SIZES[GameConstants.EVOLUTION_SIZES.length - 1] / 2;
    const safeScore = Math.max(0, score);
    if (safeScore <= GameConstants.WIN_SCORE) {
      const progress = safeScore / GameConstants.WIN_SCORE;
      return minRadius + (maxRadius - minRadius) * progress;
    }

    return maxRadius + (safeScore - GameConstants.WIN_SCORE) * GameConstants.POST_DRAGON_RADIUS_PER_SCORE;
  }

  static getSpawnScoreByLevel(level: number): number {
    const clampedLevel = Math.max(0, Math.min(level, GameConstants.EVOLUTION_SCORES.length - 1));
    const min = GameConstants.EVOLUTION_SCORES[clampedLevel];
    const max = clampedLevel >= GameConstants.EVOLUTION_SCORES.length - 1
      ? GameConstants.WIN_SCORE
      : GameConstants.EVOLUTION_SCORES[clampedLevel + 1] - 1;
    return min + Math.floor(Math.random() * Math.max(1, max - min + 1));
  }

  static getCameraZoomByScore(score: number): number {
    const startScore = GameConstants.PLAYER_INITIAL_SCORE;
    const endScore = GameConstants.WIN_SCORE;
    const progress = Math.max(0, Math.min(1, (score - startScore) / Math.max(1, endScore - startScore)));
    const zoom = GameConstants.CAMERA_MIN_ZOOM +
      (GameConstants.CAMERA_MAX_ZOOM - GameConstants.CAMERA_MIN_ZOOM) * progress;
    return Math.max(GameConstants.CAMERA_MIN_ZOOM, Math.min(GameConstants.CAMERA_MAX_ZOOM, zoom));
  }
}
