/**
 * 红警 Lite 电力管理器
 * 管理电力系统和低电惩罚
 */

import { BuildingManager, PowerStats } from './BuildingManager';
import {
  PowerStatus,
  PowerConfig,
  POWER_CONFIG
} from './GameConstants';

// 电力管理器
export class PowerManager {
  private buildingManager: BuildingManager | null = null;
  private config: PowerConfig;

  // 当前电力状态
  private currentStats: PowerStats = {
    supply: 0,
    demand: 0,
    balance: 0
  };
  private currentStatus: PowerStatus = PowerStatus.NORMAL;

  constructor(buildingManager?: BuildingManager) {
    this.config = POWER_CONFIG;
    if (buildingManager) {
      this.buildingManager = buildingManager;
    }
  }

  // 设置建筑管理器
  setBuildingManager(manager: BuildingManager): void {
    this.buildingManager = manager;
  }

  // 更新电力状态
  update(): void {
    if (!this.buildingManager) return;

    // 计算电力统计
    this.currentStats = this.buildingManager.calculatePower();

    // 确定电力状态
    if (this.currentStats.balance <= this.config.criticalThreshold) {
      this.currentStatus = PowerStatus.CRITICAL;
    } else if (this.currentStats.balance <= this.config.lowPowerThreshold) {
      this.currentStatus = PowerStatus.LOW;
    } else {
      this.currentStatus = PowerStatus.NORMAL;
    }
  }

  // 获取当前电力统计
  getPowerStats(): PowerStats {
    return this.currentStats;
  }

  // 获取当前电力状态
  getPowerStatus(): PowerStatus {
    return this.currentStatus;
  }

  // 是否低电
  isLowPower(): boolean {
    return this.currentStatus === PowerStatus.LOW ||
           this.currentStatus === PowerStatus.CRITICAL;
  }

  // 是否严重不足
  isCritical(): boolean {
    return this.currentStatus === PowerStatus.CRITICAL;
  }

  // 获取生产速度倍率（考虑低电惩罚）
  getProductionSpeedMultiplier(): number {
    switch (this.currentStatus) {
      case PowerStatus.CRITICAL:
        return this.config.criticalSpeedMultiplier;
      case PowerStatus.LOW:
        return this.config.lowPowerSpeedMultiplier;
      default:
        return 1.0;
    }
  }

  // 获取电力平衡
  getPowerBalance(): number {
    return this.currentStats.balance;
  }

  // 获取供电量
  getPowerSupply(): number {
    return this.currentStats.supply;
  }

  // 获取电力需求
  getPowerDemand(): number {
    return this.currentStats.demand;
  }

  // 获取状态描述
  getStatusDescription(): string {
    switch (this.currentStatus) {
      case PowerStatus.CRITICAL:
        return '电力严重不足';
      case PowerStatus.LOW:
        return '电力不足';
      default:
        return '电力正常';
    }
  }

  // 获取状态颜色
  getStatusColor(): string {
    switch (this.currentStatus) {
      case PowerStatus.CRITICAL:
        return '#FF0000'; // 红色
      case PowerStatus.LOW:
        return '#FF9800'; // 橙色
      default:
        return '#4CAF50'; // 绿色
    }
  }
}
