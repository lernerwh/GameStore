/**
 * 红警 Lite 地图配置
 */

// 地形类型
export enum TerrainType {
  GRASS = 'grass',      // 草地（可通行）
  WATER = 'water',      // 水域（不可通行）
  ORE = 'ore',          // 矿区（可采集）
  ROCK = 'rock'         // 岩石（不可通行）
}

// 地形颜色
export const TERRAINColors: Record<TerrainType, string> = {
  [TerrainType.GRASS]: '#3d5a3d',
  [TerrainType.WATER]: '#1a4a6e',
  [TerrainType.ORE]: '#8b7355',
  [TerrainType.ROCK]: '#5a5a5a'
};

// 根据坐标生成地形类型（用于演示）
export function getTerrainAt(x: number, y: number): TerrainType {
  const hash = (Math.floor(x / 80) * 31 + Math.floor(y / 80) * 17) % 100;

  if (hash < 5) {
    return TerrainType.ORE;
  } else if (hash < 8) {
    return TerrainType.WATER;
  } else if (hash < 12) {
    return TerrainType.ROCK;
  } else {
    return TerrainType.GRASS;
  }
}
