import { GameConstants } from '../constants/GameConstants';
import { resourceManager } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';

/**
 * 图片资源管理器
 * 管理游戏中所有生物的图片资源
 */
export class ImageManager {
  private static instance: ImageManager | null = null;

  // 图片资源名称配置 - 对应 10 个进化等级
  private static readonly IMAGE_NAMES: Map<string, string> = new Map([
    // 玩家各进化等级的图片 (0-9)
    ['player_0', 'creature_plankton.png'],
    ['player_1', 'creature_tadpole.png'],
    ['player_2', 'creature_shrimp.png'],
    ['player_3', 'creature_small_fish.png'],
    ['player_4', 'creature_medium_fish.png'],
    ['player_5', 'creature_large_fish.png'],
    ['player_6', 'creature_turtle.png'],
    ['player_7', 'creature_dolphin.png'],
    ['player_8', 'creature_shark.png'],
    ['player_9', 'creature_shark.png'],

    // NPC 生物各等级的图片 (0-9)
    ['creature_0', 'creature_plankton.png'],
    ['creature_1', 'creature_tadpole.png'],
    ['creature_2', 'creature_shrimp.png'],
    ['creature_3', 'creature_small_fish.png'],
    ['creature_4', 'creature_medium_fish.png'],
    ['creature_5', 'creature_large_fish.png'],
    ['creature_6', 'creature_turtle.png'],
    ['creature_7', 'creature_dolphin.png'],
    ['creature_8', 'creature_shark.png'],
    ['creature_9', 'creature_shark.png'],
  ]);

  // 图片缓存 - 使用 PixelMap，避免 ImageBitmap 兼容问题
  private imageCache: Map<string, image.PixelMap> = new Map();
  private resMgr: resourceManager.ResourceManager | null = null;

  static getInstance(): ImageManager {
    if (!ImageManager.instance) {
      ImageManager.instance = new ImageManager();
    }
    return ImageManager.instance;
  }

  /**
   * 初始化资源管理器，预加载所有图片
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.resMgr = context.resourceManager;
      // 预加载所有图片
      await this.preloadImages();
    } catch (e) {
      console.error('ImageManager init failed:', e);
    }
  }

  /**
   * 预加载所有图片到缓存
   */
  private async preloadImages(): Promise<void> {
    if (!this.resMgr) {
      return;
    }

    const loadPromises: Promise<void>[] = [];

    ImageManager.IMAGE_NAMES.forEach((imageName: string, key: string) => {
      loadPromises.push(this.loadImage(key, imageName));
    });

    await Promise.all(loadPromises);
  }

  /**
   * 加载单个图片
   */
  private async loadImage(key: string, imageName: string): Promise<void> {
    if (!this.resMgr) {
      return;
    }

    try {
      const filePath = `creatures/${imageName}`;
      const fileData = await this.resMgr.getRawFileContent(filePath);
      const arrayBuffer = fileData.buffer.slice(0);

      // 使用 image 模块创建 PixelMap
      const imageSource = image.createImageSource(arrayBuffer);
      const pixelMap = await imageSource.createPixelMap();

      this.imageCache.set(key, pixelMap);
    } catch (e) {
      // 图片加载失败，静默处理，使用默认绘制
      console.warn(`Failed to load image: ${imageName}`, e);
    }
  }

  /**
   * 获取缓存的图片
   */
  getCachedImage(key: string): image.PixelMap | undefined {
    return this.imageCache.get(key);
  }

  /**
   * 获取玩家图片名称
   */
  getPlayerImageKey(evolutionLevel: number): string {
    return `player_${Math.min(evolutionLevel, GameConstants.EVOLUTION_NAMES.length - 1)}`;
  }

  /**
   * 获取生物图片名称
   */
  getCreatureImageKey(evolutionLevel: number): string {
    return `creature_${Math.min(evolutionLevel, GameConstants.EVOLUTION_NAMES.length - 1)}`;
  }

  /**
   * 检查是否应该使用图片模式
   */
  shouldUseImages(): boolean {
    return this.imageCache.size > 0;
  }

  /**
   * 获取所有需要的图片路径列表
   */
  static getRequiredImages(): string[] {
    return Array.from(ImageManager.IMAGE_NAMES.values()).map(name => `creatures/${name}`);
  }
}
