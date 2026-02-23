/**
 * 召唤神龙 游戏常量定义
 */
export class GameConstants {
  // 画布尺寸
  static readonly CANVAS_WIDTH: number = 360;
  static readonly CANVAS_HEIGHT: number = 760;

  // 世界尺寸
  static readonly WORLD_WIDTH: number = 2000;
  static readonly WORLD_HEIGHT: number = 3000;

  // 玩家属性
  static readonly PLAYER_SIZE: number = 30;
  static readonly PLAYER_SPEED: number = 200;

  // 游戏规则
  static readonly SCORE_PER_HIT: number = 1;
  static readonly PLAYER_INITIAL_SCORE: number = 55;
  static readonly WIN_SCORE: number = 2000;
  static readonly POST_MAX_LEVEL_RADIUS_PER_SCORE: number = 0.01;
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
    '蝌蚪',
    '小虾',
    '海虾',
    '小鱼',
    '中鱼',
    '大鱼',
    '海龟',
    '海豚',
    '鲨鱼',
    '神龙'
  ];

  // 进化等级颜色
  static readonly EVOLUTION_COLORS: string[] = [
    '#0F172A', // 蝌蚪
    '#D97706', // 小虾
    '#F97316', // 海虾
    '#38BDF8', // 小鱼
    '#60A5FA', // 中鱼
    '#A78BFA', // 大鱼
    '#86EFAC', // 海龟
    '#34D399', // 海豚
    '#93C5FD', // 鲨鱼
    '#FACC15'  // 神龙
  ];

  // 进化等级大小
  static readonly EVOLUTION_SIZES: number[] = [
    12,  // 蝌蚪
    16,  // 小虾
    22,  // 海虾
    30,  // 小鱼
    42,  // 中鱼
    58,  // 大鱼
    80,  // 海龟
    108, // 海豚
    145, // 鲨鱼
    185  // 神龙
  ];

  // 进化所需分数
  static readonly EVOLUTION_SCORES: number[] = [
    0,    // 蝌蚪
    20,   // 小虾
    50,   // 海虾
    100,  // 小鱼
    180,  // 中鱼
    300,  // 大鱼
    450,  // 海龟
    700,  // 海豚
    1100, // 鲨鱼
    1600  // 神龙
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
  static readonly CAMERA_MIN_ZOOM: number = 0.95;
  static readonly CAMERA_MAX_ZOOM: number = 1.9;
  static readonly CAMERA_BASE_RADIUS: number = GameConstants.EVOLUTION_SIZES[0] / 2;
  static readonly CAMERA_ZOOM_RADIUS_FACTOR: number = 0.018;

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

    return maxRadius + (safeScore - GameConstants.WIN_SCORE) * GameConstants.POST_MAX_LEVEL_RADIUS_PER_SCORE;
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
