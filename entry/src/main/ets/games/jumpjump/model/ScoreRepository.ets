import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const PREFERENCES_NAME = 'game_scores';
const KEY_HIGH_SCORE = 'high_score';

export class ScoreRepository {
  private preferencesStore: preferences.Preferences | null = null;
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async init(): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(this.context, PREFERENCES_NAME);
    } catch (error) {
      hilog.error(0x0000, 'ScoreRepository', 'Failed to init: %{public}s', JSON.stringify(error));
    }
  }

  async getHighScore(): Promise<number> {
    try {
      if (this.preferencesStore === null) {
        await this.init();
      }
      return await this.preferencesStore!.get(KEY_HIGH_SCORE, 0) as number;
    } catch (error) {
      return 0;
    }
  }

  async saveHighScore(score: number): Promise<boolean> {
    try {
      if (this.preferencesStore === null) {
        await this.init();
      }
      const current = await this.getHighScore();
      if (score > current) {
        await this.preferencesStore!.put(KEY_HIGH_SCORE, score);
        await this.preferencesStore!.flush();
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }
}
