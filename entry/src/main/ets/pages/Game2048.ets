import { router } from '@kit.ArkUI';
import { BOARD_SIZE, Game2048State, MoveDirection } from '../games/game2048/model/Game2048Constants';
import { Game2048ViewModel } from '../games/game2048/viewmodel/Game2048ViewModel';

interface PageParams {
  autoStart?: boolean;
}

@Entry
@Component
struct Game2048 {
  @State isPlaying: boolean = false;
  @State viewModel: Game2048ViewModel = new Game2048ViewModel();
  private touchStartX: number = 0;
  private touchStartY: number = 0;
  private readonly swipeThreshold: number = 24;

  aboutToAppear(): void {
    const params = router.getParams() as PageParams;
    if (params?.autoStart) {
      this.startGame();
    }
  }

  build() {
    Column() {
      if (this.isPlaying) {
        this.GameView();
      } else {
        this.HomeView();
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HomeView() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          Row() {
            Button('← 返回')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('rgba(255,255,255,0.12)')
              .borderRadius(18)
              .height(36)
              .onClick(() => {
                router.back();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .padding({ top: 50 })

          Text('2048')
            .fontSize(56)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fffbeb')
            .margin({ top: 30 })

          Text('🧩')
            .fontSize(84)
            .margin({ bottom: 6 })

          Text('滑动合并数字，目标达到 2048')
            .fontSize(16)
            .fontColor('#fde68a')

          Column({ space: 8 }) {
            Text('规则说明')
              .fontSize(17)
              .fontColor('#fff7ed')
              .fontWeight(FontWeight.Medium)
            Text('• 每次滑动，数字方块向同一方向移动')
              .fontSize(14)
              .fontColor('#ffedd5')
            Text('• 相同数字碰撞会合并并翻倍')
              .fontSize(14)
              .fontColor('#ffedd5')
            Text('• 每次移动后随机生成 2 或 4')
              .fontSize(14)
              .fontColor('#ffedd5')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(16)
          .borderRadius(16)
          .backgroundColor('rgba(120,53,15,0.35)')
          .margin({ top: 8, bottom: 14 })

          Button('开始挑战')
            .fontSize(22)
            .fontColor('#FFFFFF')
            .backgroundColor('#f59e0b')
            .borderRadius(28)
            .width(190)
            .height(52)
            .onClick(() => {
              this.startGame();
            })
        }
        .width('100%')
        .padding({ left: 22, right: 22, bottom: 48 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [['#78350f', 0.0], ['#92400e', 0.5], ['#b45309', 1.0]]
    })
  }

  @Builder
  GameView() {
    Column({ space: 12 }) {
      Row() {
        Button('主页')
          .fontSize(14)
          .fontColor('#fff7ed')
          .backgroundColor('#9a3412')
          .height(34)
          .borderRadius(15)
          .onClick(() => {
            this.isPlaying = false;
          })

        Button('重开')
          .fontSize(14)
          .fontColor('#fff7ed')
          .backgroundColor('#ea580c')
          .height(34)
          .borderRadius(15)
          .margin({ left: 8 })
          .onClick(() => {
            this.viewModel.resetGame();
          })

        Text(`分数 ${this.viewModel.score}`)
          .fontSize(14)
          .fontColor('#431407')
          .backgroundColor('rgba(255,255,255,0.75)')
          .borderRadius(12)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .margin({ left: 8 })

        Text(`最高 ${this.viewModel.bestScore}`)
          .fontSize(14)
          .fontColor('#431407')
          .backgroundColor('rgba(255,255,255,0.75)')
          .borderRadius(12)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Text('在棋盘区域滑动操作')
        .fontSize(13)
        .fontColor('#fde68a')
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 8 }) {
        ForEach(this.viewModel.board, (row: number[], rowIndex: number) => {
          Row({ space: 8 }) {
            ForEach(row, (value: number, colIndex: number) => {
              this.TileCell(value)
            })
          }
        })
      }
      .padding(12)
      .borderRadius(12)
      .backgroundColor('#8b5e34')
      .onTouch((event: TouchEvent) => {
        this.handleTouch(event);
      })

      if (this.viewModel.gameState === Game2048State.WON) {
        this.StateBanner('已达成 2048！可继续冲高分', '#14532d', '继续')
      } else if (this.viewModel.gameState === Game2048State.OVER) {
        this.StateBanner('游戏结束，试试新策略', '#7f1d1d', '再来一局')
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 44, bottom: 24 })
    .backgroundColor('#b45309')
  }

  @Builder
  TileCell(value: number) {
    Column() {
      Text(value === 0 ? '' : `${value}`)
        .fontSize(value >= 128 ? 22 : 26)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTileTextColor(value))
    }
    .width(72)
    .height(72)
    .justifyContent(FlexAlign.Center)
    .borderRadius(8)
    .backgroundColor(this.getTileColor(value))
  }

  @Builder
  StateBanner(message: string, actionColor: string, actionText: string) {
    Column({ space: 12 }) {
      Text(message)
        .fontSize(16)
        .fontColor('#fff7ed')
      Button(actionText)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor(actionColor)
        .height(36)
        .borderRadius(16)
        .onClick(() => {
          if (this.viewModel.gameState === Game2048State.WON) {
            this.viewModel.continueAfterWin();
          } else {
            this.viewModel.resetGame();
          }
        })
    }
    .width('100%')
    .padding(14)
    .borderRadius(12)
    .backgroundColor('rgba(0,0,0,0.32)')
  }

  private startGame(): void {
    this.viewModel = new Game2048ViewModel();
    this.isPlaying = true;
  }

  private handleTouch(event: TouchEvent): void {
    if (event.touches.length === 0) {
      return;
    }

    if (event.type === TouchType.Down) {
      this.touchStartX = event.touches[0].x;
      this.touchStartY = event.touches[0].y;
      return;
    }

    if (event.type !== TouchType.Up) {
      return;
    }

    const deltaX = event.touches[0].x - this.touchStartX;
    const deltaY = event.touches[0].y - this.touchStartY;

    if (Math.abs(deltaX) < this.swipeThreshold && Math.abs(deltaY) < this.swipeThreshold) {
      return;
    }

    if (Math.abs(deltaX) > Math.abs(deltaY)) {
      this.viewModel.move(deltaX > 0 ? MoveDirection.RIGHT : MoveDirection.LEFT);
    } else {
      this.viewModel.move(deltaY > 0 ? MoveDirection.DOWN : MoveDirection.UP);
    }
  }

  private getTileColor(value: number): string {
    if (value === 0) return '#d6c5b3';
    if (value === 2) return '#eee4da';
    if (value === 4) return '#ede0c8';
    if (value === 8) return '#f2b179';
    if (value === 16) return '#f59563';
    if (value === 32) return '#f67c5f';
    if (value === 64) return '#f65e3b';
    if (value === 128) return '#edcf72';
    if (value === 256) return '#edcc61';
    if (value === 512) return '#edc850';
    if (value === 1024) return '#edc53f';
    return '#edc22e';
  }

  private getTileTextColor(value: number): string {
    if (value === 0) return '#776e65';
    if (value <= 4) return '#776e65';
    return '#f9f6f2';
  }
}
