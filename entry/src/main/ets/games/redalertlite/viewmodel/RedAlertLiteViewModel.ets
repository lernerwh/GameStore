/**
 * 红警 Lite 游戏视图模型
 */

import { GameConstants, from '../model/GameConstants';

export class RedAlertLiteViewModel {
  // 游戏状态
  private isInitialized: boolean = false;
  private statusMessage: string = '正在初始化...';

  // 初始化游戏
  initGame(): void {
    this.isInitialized = true;
    this.statusMessage = '游戏已初始化，点击开始游戏';
  }

}
