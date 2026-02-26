/**
 * 红警 Lite 相机系统
 * 处理世界坐标与屏幕坐标的转换，支持拖拽平移
 */

export class Camera {
  // 相机位置（屏幕左上角对应的世界坐标）
  private offsetX: number = 0;
  private offsetY: number = 0;

  // 屏幕尺寸
  private screenWidth: number;
  private screenHeight: number;

  // 拖拽状态
  private isDragging: boolean = false;
  private lastDragX: number = 0;
  private lastDragY: number = 0;

  // 世界地图尺寸
  private readonly WORLD_WIDTH: number = 2640;
  private readonly WORLD_HEIGHT: number = 5280;

  // 边界余量
  private readonly BOUNDARY_MARGIN: number = 100;

  constructor(screenWidth: number, screenHeight: number) {
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
  }

  // 世界坐标 -> 屏幕坐标
  worldToScreen(worldX: number, worldY: number): [number, number] {
    return [worldX - this.offsetX, worldY - this.offsetY];
  }

  // 屏幕坐标 -> 世界坐标
  screenToWorld(screenX: number, screenY: number): [number, number] {
    return [screenX + this.offsetX, screenY + this.offsetY];
  }

  // 开始拖拽
  startDrag(screenX: number, screenY: number): void {
    this.isDragging = true;
    this.lastDragX = screenX;
    this.lastDragY = screenY;
  }

  // 拖拽移动
  drag(screenX: number, screenY: number): void {
    if (!this.isDragging) return;

    const deltaX = this.lastDragX - screenX;
    const deltaY = this.lastDragY - screenY;

    this.offsetX += deltaX;
    this.offsetY += deltaY;

    this.lastDragX = screenX;
    this.lastDragY = screenY;

    this.applyBoundaryConstraints();
  }

  // 结束拖拽
  endDrag(): void {
    this.isDragging = false;
  }

  // 边界限制
  private applyBoundaryConstraints(): void {
    const minOffsetX = -this.BOUNDARY_MARGIN;
    const maxOffsetX = this.WORLD_WIDTH - this.screenWidth + this.BOUNDARY_MARGIN;
    const minOffsetY = -this.BOUNDARY_MARGIN;
    const maxOffsetY = this.WORLD_HEIGHT - this.screenHeight + this.BOUNDARY_MARGIN;

    this.offsetX = Math.max(minOffsetX, Math.min(maxOffsetX, this.offsetX));
    this.offsetY = Math.max(minOffsetY, Math.min(maxOffsetY, this.offsetY));
  }

  // 获取当前偏移
  getOffset(): [number, number] {
    return [this.offsetX, this.offsetY];
  }

  // 是否正在拖拽
  getIsDragging(): boolean {
    return this.isDragging;
  }

  // 重置相机位置
  reset(): void {
    this.offsetX = 0;
    this.offsetY = 0;
  }
}
