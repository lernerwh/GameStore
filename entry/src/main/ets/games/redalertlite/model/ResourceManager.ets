/**
 * 红警 Lite 资源系统
 * 管理矿石资源的采集和消耗
 */

// 资源节点
export interface ResourceNode {
  id: string;
  worldX: number;
  worldY: number;
  amount: number;        // 剩余矿石量
  maxAmount: number;     // 最大容量
  isDepleted: boolean;   // 是否耗尽
}

// 资源管理器
export class ResourceManager {
  private nodes: ResourceNode[] = [];
  private nextId: number = 0;

  // 初始化地图资源点
  initializeResources(): void {
    this.nodes = [];
    this.nextId = 0;

    // 在地图上生成资源点
    const resourcePositions = [
      { x: 200, y: 400, amount: 2000 },
      { x: 600, y: 300, amount: 1500 },
      { x: 400, y: 800, amount: 2500 },
      { x: 800, y: 600, amount: 1800 },
      { x: 300, y: 1200, amount: 2200 },
      { x: 700, y: 1000, amount: 1600 },
      { x: 500, y: 1500, amount: 2000 },
      { x: 200, y: 1800, amount: 1800 },
      { x: 600, y: 2000, amount: 2400 },
      { x: 400, y: 2400, amount: 2000 },
    ];

    for (const pos of resourcePositions) {
      this.addNode(pos.x, pos.y, pos.amount);
    }
  }

  // 添加资源点
  addNode(worldX: number, worldY: number, amount: number): ResourceNode {
    const node: ResourceNode = {
      id: `ore_${this.nextId++}`,
      worldX,
      worldY,
      amount,
      maxAmount: amount,
      isDepleted: false
    };
    this.nodes.push(node);
    return node;
  }

  // 采集资源
  harvest(nodeId: string, amount: number): number {
    const node = this.nodes.find(n => n.id === nodeId);
    if (!node || node.isDepleted) return 0;

    const harvested = Math.min(amount, node.amount);
    node.amount -= harvested;

    if (node.amount <= 0) {
      node.amount = 0;
      node.isDepleted = true;
    }

    return harvested;
  }

  // 获取最近的资源点
  getNearestNode(worldX: number, worldY: number, excludeDepleted: boolean = true): ResourceNode | null {
    let nearest: ResourceNode | null = null;
    let minDist = Infinity;

    for (const node of this.nodes) {
      if (excludeDepleted && node.isDepleted) continue;

      const dist = Math.sqrt(
        Math.pow(node.worldX - worldX, 2) +
        Math.pow(node.worldY - worldY, 2)
      );

      if (dist < minDist) {
        minDist = dist;
        nearest = node;
      }
    }

    return nearest;
  }

  // 获取所有资源点
  getAllNodes(): ResourceNode[] {
    return this.nodes;
  }

  // 获取活跃资源点数量
  getActiveNodeCount(): number {
    return this.nodes.filter(n => !n.isDepleted).length;
  }

  // 获取总剩余资源量
  getTotalRemaining(): number {
    return this.nodes.reduce((sum, n) => sum + n.amount, 0);
  }
}
