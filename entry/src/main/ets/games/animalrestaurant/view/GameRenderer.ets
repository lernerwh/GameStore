import { Customer } from '../model/Customer';
import { Table } from '../model/Table';
import { Dish } from '../model/Dish';
import { Restaurant } from '../model/Restaurant';
import { GameConstants, GameState, CustomerState, TableState, DishState } from '../model/GameConstants';

/**
 * 游戏渲染器 - 负责绘制动物餐厅的所有元素
 */
export class GameRenderer {
  private canvasWidth: number = GameConstants.CANVAS_WIDTH;
  private canvasHeight: number = GameConstants.CANVAS_HEIGHT;

  /**
   * 主渲染方法
   */
  render(
    canvas: CanvasRenderingContext2D,
    tables: Table[],
    waitingCustomers: Customer[],
    allCustomers: Customer[],
    dishes: Dish[],
    restaurant: Restaurant,
    gameState: GameState
  ): void {
    this.clearCanvas(canvas);
    this.drawBackground(canvas);
    this.drawKitchen(canvas);
    this.drawWaitingArea(canvas, waitingCustomers);
    this.drawTables(canvas, tables);
    this.drawCustomers(canvas, allCustomers);
    this.drawDishes(canvas, dishes);
    this.drawHUD(canvas, restaurant);

    if (gameState === GameState.IDLE) {
      this.drawStartPrompt(canvas);
    } else if (gameState === GameState.PAUSED) {
      this.drawPaused(canvas);
    }
  }

  /**
   * 清空画布
   */
  private clearCanvas(canvas: CanvasRenderingContext2D): void {
    canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  /**
   * 绘制背景
   */
  private drawBackground(canvas: CanvasRenderingContext2D): void {
    // 温馨的米色背景
    canvas.fillStyle = GameConstants.COLOR_BACKGROUND;
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 地板
    canvas.fillStyle = '#DEB887';
    canvas.fillRect(0, GameConstants.TABLE_START_Y - 20, this.canvasWidth, this.canvasHeight);

    // 地板纹理
    canvas.strokeStyle = '#C4A777';
    canvas.lineWidth = 1;
    for (let i = 0; i < this.canvasWidth; i += 40) {
      canvas.beginPath();
      canvas.moveTo(i, GameConstants.TABLE_START_Y - 20);
      canvas.lineTo(i, this.canvasHeight);
      canvas.stroke();
    }
  }

  /**
   * 绘制厨房区域
   */
  private drawKitchen(canvas: CanvasRenderingContext2D): void {
    // 厨房背景
    canvas.fillStyle = GameConstants.COLOR_KITCHEN;
    canvas.fillRect(
      GameConstants.KITCHEN_X,
      GameConstants.KITCHEN_Y,
      GameConstants.KITCHEN_WIDTH,
      GameConstants.KITCHEN_HEIGHT
    );

    // 厨房边框
    canvas.strokeStyle = '#333333';
    canvas.lineWidth = 2;
    canvas.strokeRect(
      GameConstants.KITCHEN_X,
      GameConstants.KITCHEN_Y,
      GameConstants.KITCHEN_WIDTH,
      GameConstants.KITCHEN_HEIGHT
    );

    // 厨房标签
    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 20px sans-serif';
    canvas.textAlign = 'center';
    canvas.fillText('厨房', GameConstants.KITCHEN_X + GameConstants.KITCHEN_WIDTH / 2, GameConstants.KITCHEN_Y + 28);

    // 厨师图标
    canvas.font = '36px sans-serif';
    canvas.fillText('👨‍🍳', GameConstants.KITCHEN_X + GameConstants.KITCHEN_WIDTH / 2, GameConstants.KITCHEN_Y + 62);
  }

  /**
   * 绘制等待区
   */
  private drawWaitingArea(canvas: CanvasRenderingContext2D, customers: Customer[]): void {
    // 等待区背景
    canvas.fillStyle = '#E8E8E8';
    canvas.fillRect(GameConstants.KITCHEN_X + GameConstants.KITCHEN_WIDTH + 10, GameConstants.KITCHEN_Y, 180, GameConstants.KITCHEN_HEIGHT);

    // 等待区边框
    canvas.strokeStyle = '#CCCCCC';
    canvas.lineWidth = 1;
    canvas.strokeRect(GameConstants.KITCHEN_X + GameConstants.KITCHEN_WIDTH + 10, GameConstants.KITCHEN_Y, 180, GameConstants.KITCHEN_HEIGHT);

    // 等待区标签
    canvas.fillStyle = '#666666';
    canvas.font = '18px sans-serif';
    canvas.textAlign = 'center';
    canvas.fillText('等待区', GameConstants.KITCHEN_X + GameConstants.KITCHEN_WIDTH + 100, GameConstants.KITCHEN_Y + 20);
  }

  /**
   * 绘制餐桌
   */
  private drawTables(canvas: CanvasRenderingContext2D, tables: Table[]): void {
    for (const table of tables) {
      // 桌子阴影
      canvas.fillStyle = 'rgba(0, 0, 0, 0.1)';
      canvas.fillRect(table.x + 3, table.y + 3, table.width, table.height);

      // 桌子本体
      canvas.fillStyle = GameConstants.COLOR_TABLE;
      canvas.fillRect(table.x, table.y, table.width, table.height);

      // 桌布
      canvas.fillStyle = GameConstants.COLOR_TABLECLOTH;
      canvas.fillRect(table.x + 5, table.y + 5, table.width - 10, table.height - 10);

      // 根据状态绘制指示
      if (table.state === TableState.NEEDS_CLEAN) {
        // 需要清理 - 显示脏盘子
        canvas.fillStyle = '#FF6B6B';
        canvas.font = '16px sans-serif';
        canvas.textAlign = 'center';
        canvas.fillText('🍽️', table.x + table.width / 2, table.y + table.height / 2 + 5);
        canvas.font = '10px sans-serif';
        canvas.fillText('点击清理', table.x + table.width / 2, table.y + table.height + 12);
      } else if (table.state === TableState.OCCUPIED && table.customer) {
        // 有顾客 - 显示点餐气泡
        if (table.customer.state === CustomerState.ORDERING) {
          canvas.fillStyle = '#4CAF50';
          canvas.font = '12px sans-serif';
          canvas.fillText('💭', table.x + table.width / 2, table.y - 5);
        } else if (table.customer.state === CustomerState.WAITING_FOOD) {
          canvas.fillStyle = '#FF9800';
          canvas.font = '12px sans-serif';
          canvas.fillText('⏳', table.x + table.width / 2, table.y - 5);
        }
      }

      // 桌子边框
      canvas.strokeStyle = '#5D4037';
      canvas.lineWidth = 2;
      canvas.strokeRect(table.x, table.y, table.width, table.height);
    }
  }

  /**
   * 绘制顾客
   */
  private drawCustomers(canvas: CanvasRenderingContext2D, customers: Customer[]): void {
    for (const customer of customers) {
      const rect = customer.getCollisionRect();

      // 顾客背景圆
      canvas.beginPath();
      canvas.arc(customer.x, customer.y, customer.size / 2, 0, Math.PI * 2);
      canvas.fillStyle = customer.color;
      canvas.fill();
      canvas.strokeStyle = '#333333';
      canvas.lineWidth = 2;
      canvas.stroke();

      // 动物emoji
      canvas.font = `${customer.size * 0.8}px sans-serif`;
      canvas.textAlign = 'center';
      canvas.textBaseline = 'middle';
      canvas.fillText(customer.emoji, customer.x, customer.y);

      // 耐心条（仅在等待或等待食物时显示）
      if (customer.state === CustomerState.WAITING ||
          customer.state === CustomerState.WAITING_FOOD) {
        this.drawPatienceBar(canvas, customer);
      }

      // 状态指示
      if (customer.state === CustomerState.EATING) {
        canvas.font = '12px sans-serif';
        canvas.fillText('😋', customer.x, customer.y - customer.size / 2 - 10);
      } else if (customer.state === CustomerState.ORDERING) {
        canvas.font = '12px sans-serif';
        canvas.fillText('📋', customer.x, customer.y - customer.size / 2 - 10);
      }
    }
  }

  /**
   * 绘制耐心条
   */
  private drawPatienceBar(canvas: CanvasRenderingContext2D, customer: Customer): void {
    const barWidth = 40;
    const barHeight = 6;
    const barX = customer.x - barWidth / 2;
    const barY = customer.y + customer.size / 2 + 5;

    // 背景条
    canvas.fillStyle = '#CCCCCC';
    canvas.fillRect(barX, barY, barWidth, barHeight);

    // 耐心进度
    const patiencePercent = customer.getPatiencePercent();
    let color = GameConstants.COLOR_HAPPY;
    if (patiencePercent < 0.3) {
      color = GameConstants.COLOR_DANGER;
    } else if (patiencePercent < 0.6) {
      color = GameConstants.COLOR_WARNING;
    }

    canvas.fillStyle = color;
    canvas.fillRect(barX, barY, barWidth * patiencePercent, barHeight);

    // 边框
    canvas.strokeStyle = '#333333';
    canvas.lineWidth = 1;
    canvas.strokeRect(barX, barY, barWidth, barHeight);
  }

  /**
   * 绘制菜品
   */
  private drawDishes(canvas: CanvasRenderingContext2D, dishes: Dish[]): void {
    for (const dish of dishes) {
      // 菜品背景
      canvas.beginPath();
      canvas.arc(dish.x, dish.y, dish.size / 2, 0, Math.PI * 2);
      canvas.fillStyle = '#FFFFFF';
      canvas.fill();
      canvas.strokeStyle = dish.color;
      canvas.lineWidth = 2;
      canvas.stroke();

      // 菜品emoji
      canvas.font = `${dish.size * 0.5}px sans-serif`;
      canvas.textAlign = 'center';
      canvas.textBaseline = 'middle';
      canvas.fillText(dish.emoji, dish.x, dish.y);

      // 烹饪进度条
      if (dish.state === DishState.COOKING) {
        const barWidth = 30;
        const barHeight = 4;
        const barX = dish.x - barWidth / 2;
        const barY = dish.y + dish.size / 2 + 3;

        canvas.fillStyle = '#CCCCCC';
        canvas.fillRect(barX, barY, barWidth, barHeight);
        canvas.fillStyle = '#4CAF50';
        canvas.fillRect(barX, barY, barWidth * dish.cookingProgress, barHeight);
      }

      // 准备好提示
      if (dish.state === DishState.READY) {
        canvas.fillStyle = '#4CAF50';
        canvas.font = '10px sans-serif';
        canvas.fillText('✓ 点击上菜', dish.x, dish.y + dish.size / 2 + 12);
      }
    }
  }

  /**
   * 绘制HUD（头部信息）
   */
  private drawHUD(canvas: CanvasRenderingContext2D, restaurant: Restaurant): void {
    // 金币
    canvas.fillStyle = GameConstants.COLOR_GOLD;
    canvas.font = 'bold 24px sans-serif';
    canvas.textAlign = 'left';
    canvas.textBaseline = 'top';
    canvas.fillText(`💰 ${restaurant.coins}`, 170, GameConstants.KITCHEN_Y + 18);

    // 等级
    canvas.fillStyle = '#4CAF50';
    canvas.fillText(`⭐ Lv.${restaurant.level}`, 170, GameConstants.KITCHEN_Y + 48);

    // 满意度
    canvas.fillStyle = '#FF6B6B';
    canvas.fillText(`❤️ ${restaurant.getSatisfactionRate()}%`, 170, GameConstants.KITCHEN_Y + 78);
  }

  /**
   * 绘制开始提示
   */
  private drawStartPrompt(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.5)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 32px sans-serif';
    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';
    canvas.fillText('🐾 动物餐厅 🐾', this.canvasWidth / 2, this.canvasHeight / 2 - 60);

    canvas.font = '18px sans-serif';
    canvas.fillText('欢迎来到温馨的动物餐厅！', this.canvasWidth / 2, this.canvasHeight / 2 - 20);

    canvas.font = '16px sans-serif';
    canvas.fillText('招待可爱的动物顾客', this.canvasWidth / 2, this.canvasHeight / 2 + 20);
    canvas.fillText('烹饪美味的菜肴', this.canvasWidth / 2, this.canvasHeight / 2 + 45);

    canvas.font = 'bold 20px sans-serif';
    canvas.fillStyle = '#4CAF50';
    canvas.fillText('点击开始营业', this.canvasWidth / 2, this.canvasHeight / 2 + 90);
  }

  /**
   * 绘制暂停界面
   */
  private drawPaused(canvas: CanvasRenderingContext2D): void {
    canvas.fillStyle = 'rgba(0, 0, 0, 0.5)';
    canvas.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    canvas.fillStyle = '#FFFFFF';
    canvas.font = 'bold 32px sans-serif';
    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';
    canvas.fillText('⏸️ 游戏暂停', this.canvasWidth / 2, this.canvasHeight / 2 - 20);

    canvas.font = '18px sans-serif';
    canvas.fillText('点击继续', this.canvasWidth / 2, this.canvasHeight / 2 + 30);
  }
}
