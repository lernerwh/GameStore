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
      id: 'jumpjump',
      name: '跳一跳',
      description: '按住蓄力，松开跳跃到下一个方块',
      icon: '🦘',
      color: '#4CAF50',
      gradient: ['#F5DEB3', '#DEB887'],
      page: 'pages/JumpJumpGame',
      enabled: true
    },
    {
      id: 'dragon',
      name: '球球大作战',
      description: '吞噬小球持续成长，躲避强敌成为球场霸主',
      icon: '⚪',
      color: '#22D3EE',
      gradient: ['#102a43', '#0b1f33'],
      page: 'pages/DragonGame',
      enabled: true
    },
    {
      id: 'summondragon',
      name: '召唤神龙',
      description: '从小蝌蚪一路进化，吞噬成长召唤神龙',
      icon: '🐉',
      color: '#FFD700',
      gradient: ['#8ec6ef', '#87bee6'],
      page: 'pages/SummonDragonGame',
      enabled: true
    },
    {
      id: 'sudoku',
      name: '数独',
      description: '经典逻辑填数游戏，训练大脑',
      icon: '🔢',
      color: '#1976D2',
      gradient: ['#E3F2FD', '#BBDEFB'],
      page: 'pages/SudokuGame',
      enabled: true
    },
    {
      id: 'game2048',
      name: '2048',
      description: '滑动合并数字方块，挑战 2048',
      icon: '🧩',
      color: '#f59e0b',
      gradient: ['#78350f', '#b45309'],
      page: 'pages/Game2048',
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
