import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const PREFERENCES_NAME = 'flappy_bird_scores';
const KEY_HIGH_SCORE = 'high_score';

/**
 * 分数存储仓库 - 使用Preferences持久化
 */
export class ScoreRepository {
  private preferencesStore: preferences.Preferences | null = null;
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 初始化Preferences
   */
  async init(): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(this.context, PREFERENCES_NAME);
      hilog.info(0x0000, 'ScoreRepository', 'Preferences initialized successfully');
    } catch (error) {
      hilog.error(0x0000, 'ScoreRepository', 'Failed to init preferences: %{public}s', JSON.stringify(error));
    }
  }

  /**
   * 获取最高分
   */
  async getHighScore(): Promise<number> {
    try {
      if (this.preferencesStore === null) {
        await this.init();
      }
      const score = await this.preferencesStore!.get(KEY_HIGH_SCORE, 0) as number;
      return score;
    } catch (error) {
      hilog.error(0x0000, 'ScoreRepository', 'Failed to get high score: %{public}s', JSON.stringify(error));
      return 0;
    }
  }

  /**
   * 保存最高分
   * @param score 新分数
   * @returns 是否更新了最高分
   */
  async saveHighScore(score: number): Promise<boolean> {
    try {
      if (this.preferencesStore === null) {
        await this.init();
      }

      const currentHighScore = await this.getHighScore();
      if (score > currentHighScore) {
        await this.preferencesStore!.put(KEY_HIGH_SCORE, score);
        await this.preferencesStore!.flush();
        hilog.info(0x0000, 'ScoreRepository', 'New high score saved: %{public}d', score);
        return true;
      }
      return false;
    } catch (error) {
      hilog.error(0x0000, 'ScoreRepository', 'Failed to save high score: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  /**
   * 清除所有数据
   */
  async clear(): Promise<void> {
    try {
      if (this.preferencesStore !== null) {
        await this.preferencesStore.clear();
        await this.preferencesStore.flush();
      }
    } catch (error) {
      hilog.error(0x0000, 'ScoreRepository', 'Failed to clear: %{public}s', JSON.stringify(error));
    }
  }
}
