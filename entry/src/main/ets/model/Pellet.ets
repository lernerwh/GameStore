import { GameConstants } from '../common/constants/GameConstants';

/**
 * 静态可吞噬物：小豆豆
 */
export class Pellet {
  x: number = 0;
  y: number = 0;
  scoreValue: number = GameConstants.PELLET_SCORE;
  radius: number = GameConstants.PELLET_RADIUS;
  color: string = GameConstants.PELLET_COLORS[0];

  constructor() {
    const colors = GameConstants.PELLET_COLORS;
    this.color = colors[Math.floor(Math.random() * colors.length)];
  }
}
