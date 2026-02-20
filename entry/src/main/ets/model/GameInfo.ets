/**
 * 游戏信息接口
 */
export interface GameInfo {
  id: string;
  name: string;
  description: string;
  icon: string;
  color: string;
  gradient: string[];
  page: string;
  enabled: boolean;
}

/**
 * 游戏目录
 */
export class GameCatalog {
  private static games: GameInfo[] = [
    {
      id: 'animalrestaurant',
      name: '动物餐厅',
      description: '招待可爱的动物顾客，经营温馨餐厅',
      icon: '🐱',
      color: '#FF9800',
      gradient: ['#FFF8E7', '#FFE4C4'],
      page: 'pages/AnimalRestaurantGame',
      enabled: true
    },
    {
      id: 'flappybird',
      name: '飞扬的小鸟',
      description: '点击屏幕让小鸟跳跃，避开管道',
      icon: '🐦',
      color: '#228B22',
      gradient: ['#87CEEB', '#98FB98'],
      page: 'pages/FlappyBirdGame',
      enabled: true
    },
    {
      id: 'dragon',
      name: '召唤神龙',
      description: '探索海洋，从小生物进化成神龙',
      icon: '🐉',
      color: '#FFD700',
      gradient: ['#1a4a7a', '#0d2847'],
      page: 'pages/DragonGame',
      enabled: true
    },
    {
      id: 'snake',
      name: '贪吃蛇',
      description: '经典街机游戏，控制蛇吃食物成长',
      icon: '🐍',
      color: '#4ade80',
      gradient: ['#1a3a2a', '#0d2820'],
      page: 'pages/SnakeGame',
      enabled: true
    },
  ];

  static getGames(): GameInfo[] {
    return GameCatalog.games.filter(g => g.enabled);
  }

  static getGameById(id: string): GameInfo | undefined {
    return GameCatalog.games.find(g => g.id === id);
  }
}
