import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

/**
 * 启动参数接口
 */
interface LaunchParams {
  game?: string;      // 游戏 ID
  autostart?: boolean; // 是否自动开始
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'Ability onCreate');
    hilog.info(DOMAIN, TAG, 'want.uri: %{public}s', want.uri ?? 'null');
    hilog.info(DOMAIN, TAG, 'want.parameters: %{public}s', JSON.stringify(want.parameters));

    // 解析启动参数
    const params = this.parseLaunchParams(want);
    hilog.info(DOMAIN, TAG, 'Parsed params: game=%{public}s, autostart=%{public}s',
      params.game ?? 'null', String(params.autostart));

    if (params.game) {
      // 将参数存入 AppStorage，供页面使用
      AppStorage.setOrCreate('launchGameId', params.game);
      AppStorage.setOrCreate('launchAutoStart', params.autostart ?? false);
      hilog.info(DOMAIN, TAG, 'AppStorage set: launchGameId=%{public}s', params.game);
    } else {
      // 清除之前的启动参数
      AppStorage.setOrCreate('launchGameId', '');
      AppStorage.setOrCreate('launchAutoStart', false);
      hilog.info(DOMAIN, TAG, 'AppStorage cleared: no game param');
    }
  }

  /**
   * 解析启动参数
   * 支持两种方式：
   * 1. URI 参数: --uri "game=jumpjump&autostart=true"
   * 2. Want.parameters: -p game jumpjump -p autostart true
   */
  private parseLaunchParams(want: Want): LaunchParams {
    const params: LaunchParams = {};

    // 方式1: 从 URI 解析参数
    if (want.uri) {
      hilog.info(DOMAIN, TAG, 'URI: %{public}s', want.uri);
      const urlParams = this.parseUrlParams(want.uri);
      if (urlParams['game']) {
        params.game = urlParams['game'];
      }
      if (urlParams['autostart'] === 'true') {
        params.autostart = true;
      }
    }

    // 方式2: 从 Want.parameters 解析
    if (want.parameters) {
      if (want.parameters['game']) {
        params.game = String(want.parameters['game']);
      }
      if (want.parameters['autostart'] === true || want.parameters['autostart'] === 'true') {
        params.autostart = true;
      }
    }

    return params;
  }

  /**
   * 解析 URL 参数字符串
   * 支持格式:
   * 1. "game=jumpjump&autostart=true"
   * 2. "?game=jumpjump&autostart=true"
   */
  private parseUrlParams(query: string): Record<string, string> {
    const params: Record<string, string> = {};
    if (!query) {
      return params;
    }

    // 移除可能的 ? 前缀
    if (query.startsWith('?')) {
      query = query.substring(1);
    }

    // 按 & 分割参数
    const pairs = query.split('&');
    for (let i = 0; i < pairs.length; i++) {
      const pair = pairs[i];
      // 按 = 分割键值
      const eqIndex = pair.indexOf('=');
      if (eqIndex > 0) {
        const key = pair.substring(0, eqIndex);
        const value = pair.substring(eqIndex + 1);
        if (key && value) {
          params[key] = decodeURIComponent(value);
          hilog.info(DOMAIN, TAG, 'Parsed URL param: %{public}s=%{public}s', key, value);
        }
      }
    }

    return params;
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onBackground');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'Ability onNewWant');
    // 当应用已在后台时，再次启动会调用此方法
    this.onCreate(want, launchParam);
  }
}
