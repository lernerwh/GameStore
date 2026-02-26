/**
 * 红警 Lite 单位实体
 * 实现单位的移动、攻击、状态管理
 */

import {
  UnitType,
  UnitState,
  UnitConfig,
  UNIT_CONFIGS,
  UNIT_COLORS,
  TILE_SIZE
} from './GameConstants';

// 单位实体
export class Unit {
  // 唯一标识
  id: string;

  // 类型
  type: UnitType;

  // 配置
  config: UnitConfig;

  // 位置（世界坐标）
  worldX: number;
  worldY: number;

  // 目标位置
  targetX: number = 0;
  targetY: number = 0;

  // 状态
  state: UnitState = UnitState.IDLE;

  // 生命值
  hp: number;
  maxHp: number;

  // 阵营
  faction: string;

  // 攻击目标
  attackTarget: Unit | null = null;

  // 攻击冷却
  attackCooldown: number = 0;

  // 是否被选中
  isSelected: boolean = false;

  constructor(
    type: UnitType,
    worldX: number,
    worldY: number,
    faction: string = 'player',
    id?: string
  ) {
    this.type = type;
    this.config = UNIT_CONFIGS[type];
    this.worldX = worldX;
    this.worldY = worldY;
    this.faction = faction;
    this.id = id || `unit_${type}_${Date.now()}_${Math.floor(Math.random() * 1000000)}`;
    this.hp = this.config.hp;
    this.maxHp = this.config.hp;
    this.targetX = worldX;
    this.targetY = worldY;
  }

  // 更新单位
  update(deltaMs: number): void {
    // 更新攻击冷却
    if (this.attackCooldown > 0) {
      this.attackCooldown -= deltaMs;
    }

    switch (this.state) {
      case UnitState.IDLE:
        // 空闲时自动寻找敌人
        this.findEnemy();
        break;

      case UnitState.MOVING:
        this.moveToTarget(deltaMs);
        break;

      case UnitState.ATTACKING:
        this.performAttack(deltaMs);
        break;

      case UnitState.DEAD:
        // 已死亡，不处理
        break;
    }
  }

  // 移动到目标
  private moveToTarget(deltaMs: number): void {
    const dx = this.targetX - this.worldX;
    const dy = this.targetY - this.worldY;
    const distance = Math.sqrt(dx * dx + dy * dy);

    if (distance < 5) {
      // 到达目标
      this.worldX = this.targetX;
      this.worldY = this.targetY;
      this.state = UnitState.IDLE;
      return;
    }

    // 移动
    const moveDistance = (this.config.moveSpeed * deltaMs) / 1000;
    if (moveDistance >= distance) {
      this.worldX = this.targetX;
      this.worldY = this.targetY;
      this.state = UnitState.IDLE;
    } else {
      const ratio = moveDistance / distance;
      this.worldX += dx * ratio;
      this.worldY += dy * ratio;
    }
  }

  // 执行攻击
  private performAttack(deltaMs: number): void {
    if (!this.attackTarget || this.attackTarget.state === UnitState.DEAD) {
      // 目标已死亡
      this.attackTarget = null;
      this.state = UnitState.IDLE;
      return;
    }

    // 检查距离
    const dx = this.attackTarget.worldX - this.worldX;
    const dy = this.attackTarget.worldY - this.worldY;
    const distance = Math.sqrt(dx * dx + dy * dy);

    if (distance > this.config.attackRange) {
      // 目标超出范围，移动接近
      this.targetX = this.attackTarget.worldX;
      this.targetY = this.attackTarget.worldY;
      this.state = UnitState.MOVING;
      return;
    }

    // 攻击冷却结束，执行攻击
    if (this.attackCooldown <= 0) {
      this.attackTarget.takeDamage(this.config.damage);
      this.attackCooldown = this.config.attackCooldown;
    }
  }

  // 寻找敌人（自动索敌）
  private findEnemy(): void {
    // 由 UnitManager 来设置攻击目标
  }

  // 受到伤害
  takeDamage(damage: number): void {
    this.hp -= damage;
    if (this.hp <= 0) {
      this.hp = 0;
      this.state = UnitState.DEAD;
    }
  }

  // 设置移动目标
  setTarget(worldX: number, worldY: number): void {
    this.targetX = worldX;
    this.targetY = worldY;
    this.state = UnitState.MOVING;
    this.attackTarget = null;
  }

  // 设置攻击目标
  setAttackTarget(target: Unit): void {
    this.attackTarget = target;
    this.state = UnitState.ATTACKING;
  }

  // 是否死亡
  isDead(): boolean {
    return this.state === UnitState.DEAD || this.hp <= 0;
  }

  // 获取血量百分比
  getHpPercent(): number {
    return Math.floor((this.hp / this.maxHp) * 100);
  }

  // 获取颜色
  getColor(): string {
    if (this.isSelected) {
      return UNIT_COLORS.selected;
    }
    return this.faction === 'player' ? UNIT_COLORS.player : UNIT_COLORS.enemy;
  }
}
