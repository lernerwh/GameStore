import { GameCatalog, GameInfo } from '../model/GameInfo';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State games: GameInfo[] = [];

  aboutToAppear(): void {
    this.games = GameCatalog.getGames();
  }

  build() {
    Column() {
      // 标题区域
      this.TitleView()

      // 游戏列表
      this.GameList()

      // 底部信息
      this.FooterView()
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [['#0a1628', 0.0], ['#1a2a4a', 0.5], ['#0d1f3c', 1.0]]
    })
  }

  @Builder
  TitleView() {
    Column() {
      Text('🎮')
        .fontSize(60)
        .margin({ top: 70, bottom: 15 })

      Text('游戏中心')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textShadow({ radius: 8, color: '#4a90d9', offsetX: 0, offsetY: 2 })

      Text('选择游戏开始体验')
        .fontSize(16)
        .fontColor('#888888')
        .margin({ top: 10 })
    }
    .width('100%')
    .padding({ bottom: 25 })
  }

  @Builder
  GameList() {
    Scroll() {
      Column({ space: 16 }) {
        ForEach(this.games, (game: GameInfo) => {
          this.GameCard(game)
        })

        // 占位卡片 - 更多游戏敬请期待
        this.ComingSoonCard()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 10 })
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }

  @Builder
  GameCard(game: GameInfo) {
    Column() {
      Row() {
        // 游戏图标背景
        Column() {
          Text(game.icon)
            .fontSize(36)
        }
        .width(70)
        .height(70)
        .justifyContent(FlexAlign.Center)
        .borderRadius(16)
        .linearGradient({
          angle: 135,
          colors: [['#1a4a7a', 0.0], ['#0d2847', 1.0]]
        })
        .shadow({ radius: 10, color: game.color, offsetX: 0, offsetY: 4 })

        // 游戏信息
        Column({ space: 8 }) {
          Text(game.name)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text(game.description)
            .fontSize(14)
            .fontColor('#AAAAAA')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 16, right: 10 })
        .height('100%')

        // 开始按钮
        Column() {
          Text('▶')
            .fontSize(18)
            .fontColor('#FFFFFF')
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .borderRadius(20)
        .backgroundColor(game.color)
        .shadow({ radius: 8, color: game.color, offsetX: 0, offsetY: 3 })
      }
      .width('100%')
      .height(90)
      .padding({ left: 15, right: 15 })
    }
    .width('100%')
    .borderRadius(20)
    .backgroundColor('rgba(255,255,255,0.08)')
    .border({ width: 1, color: 'rgba(255,255,255,0.12)' })
    .onClick(() => {
      this.startGame(game);
    })
  }

  @Builder
  ComingSoonCard() {
    Column() {
      Row() {
        Column() {
          Text('🔮')
            .fontSize(36)
        }
        .width(70)
        .height(70)
        .justifyContent(FlexAlign.Center)
        .borderRadius(16)
        .backgroundColor('rgba(255,255,255,0.05)')
        .border({ width: 1, color: 'rgba(255,255,255,0.1)', style: BorderStyle.Dashed })

        Column({ space: 8 }) {
          Text('更多游戏')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#666666')

          Text('敬请期待...')
            .fontSize(14)
            .fontColor('#555555')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
      }
      .width('100%')
      .height(90)
      .padding({ left: 15, right: 15 })
    }
    .width('100%')
    .borderRadius(20)
    .backgroundColor('rgba(255,255,255,0.03)')
    .border({ width: 1, color: 'rgba(255,255,255,0.06)', style: BorderStyle.Dashed })
  }

  @Builder
  FooterView() {
    Column() {
      Text('版本 1.0.0')
        .fontSize(12)
        .fontColor('#444444')
    }
    .width('100%')
    .padding({ top: 15, bottom: 20 })
  }

  private startGame(game: GameInfo): void {
    router.pushUrl({
      url: game.page
    }).catch((err: Error) => {
      console.error('Failed to start game:', err.message);
    });
  }
}
