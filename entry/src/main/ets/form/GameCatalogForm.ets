/**
 * 游戏中心桌面卡片 - 2x2 尺寸
 */
@Entry
@Component
struct GameCatalogCard {
  build() {
    Column() {
      // 卡片内容
      Column({ space: 8 }) {
        Text('🎮')
          .fontSize(32)

        Text('游戏中心')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text('点击进入')
          .fontSize(12)
          .fontColor('#888888')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .borderRadius(16)
    .linearGradient({
      angle: 135,
      colors: [['#1a4a7a', 0.0], ['#0d2847', 1.0]]
    })
    .border({ width: 1, color: 'rgba(255,255,255,0.2)' })
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 4 })
    .onClick(() => {
      // 点击卡片时打开游戏中心
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: {
          game: '',
          autostart: false
        }
      });
    })
  }
}
