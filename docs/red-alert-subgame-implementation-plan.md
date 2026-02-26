# GameStore 子游戏《红警 Lite》详细实施计划（供 Codex 多轮迭代执行）

## 1. 文档定位
本文档是给 Codex 的执行计划，不是产品概念稿。
目标是在当前 `GameStore` 中新增一个“红警风格 RTS 子游戏”（以下称 **红警 Lite**），并按“小步快跑、每轮可验收、每轮可提交”的方式推进。

范围约束：
- 只做“红警风格玩法内核”，不复刻原作全部内容。
- 不影响现有 `球球大作战`、`召唤神龙`、`跳一跳` 等已上线子游戏。
- 美术、音效、文案尽量使用原创或可替代资源，避免版权风险。

---

## 2. 联网调研结论（实现基线）

### 2.1 核心玩法抽象
结合经典 RA 玩法与可实现性，红警 Lite 的第一性原理是：
1. 经济循环：采集资源 -> 资金增长 -> 建造/产兵。
2. 基地循环：建筑前置 + 电力约束（低电惩罚）。
3. 战斗循环：单位移动、索敌、攻击、损毁、胜负。
4. 操作循环：选择单位、下达命令、观察小地图与状态。

### 2.2 可借鉴系统拆分（OpenRA 文档）
可按“Trait/系统”方式模块化：
- 生产：`Production` / `ProductionQueue`
- 电力：`Power` / `PowerManager`
- 经济：`Harvester`
- 前置：`GrantConditionOnPrerequisite`
- 交战：自动索敌与攻击循环

这类拆分适合当前项目已有的 `model + viewmodel + view` 结构。

### 2.3 工程与合规边界
- OpenRA 法律页明确说明原作资产归 EA 所有，社区项目本身不代表可直接商用原资产。
- 因此本项目建议采用“玩法致敬 + 原创资源命名”。

---

## 3. 与当前项目的集成方案

## 3.1 新增子游戏，不改旧游戏逻辑
接入点：
- `/Users/jiwei/Code/AtomicService/GameStore/entry/src/main/ets/model/GameInfo.ets`
- `/Users/jiwei/Code/AtomicService/GameStore/entry/src/main/ets/pages/Index.ets`

新增页面：
- `/Users/jiwei/Code/AtomicService/GameStore/entry/src/main/ets/pages/RedAlertLiteGame.ets`

新增目录（建议）：
- `/Users/jiwei/Code/AtomicService/GameStore/entry/src/main/ets/games/redalertlite/model`
- `/Users/jiwei/Code/AtomicService/GameStore/entry/src/main/ets/games/redalertlite/system`
- `/Users/jiwei/Code/AtomicService/GameStore/entry/src/main/ets/games/redalertlite/viewmodel`
- `/Users/jiwei/Code/AtomicService/GameStore/entry/src/main/ets/games/redalertlite/view`
- `/Users/jiwei/Code/AtomicService/GameStore/entry/src/main/resources/base/media/redalertlite`

## 3.2 架构职责
- `model`：实体结构与枚举（单位、建筑、资源、命令、阵营）。
- `system`：纯逻辑系统（采矿、生产、建造、战斗、AI、胜负）。
- `viewmodel`：Tick 循环、状态聚合、输入命令队列。
- `view`：地图、单位、建筑、UI/HUD、最小地图。

---

## 4. 迭代节奏与通用执行规则

每个迭代必须满足：
1. 只实现一个主目标（避免混改）。
2. 本轮可编译、可安装、可验证。
3. 模拟器先验证，再决定是否安装真机。
4. 产出一条独立 commit。

每轮固定流程：
1. 明确本轮目标与验收条件。
2. 编码并本地编译。
3. 安装模拟器并自动启动到目标页面。
4. 最短路径自测（至少一次完整操作链路）。
5. 记录结果与风险。
6. git 提交。

推荐命令模板（按本机环境调整）：
- 构建：`./hvigorw --mode module -p module=entry@default -p product=default -p buildMode=debug assembleHap`
- 安装：`hdc install -r <hap路径>`
- 启动：`hdc shell aa start -a EntryAbility -b <bundleName>`

---

## 5. 详细迭代计划（可直接给 Codex 执行）

## Iteration 01：入口与空场景
目标：游戏中心可进入“红警 Lite”空场景。

任务：
- 在 `GameInfo.ets` 注册新卡片（名称、描述、icon、page）。
- 新建 `RedAlertLiteGame.ets` 页面。
- 新建空 `RedAlertLiteViewModel`，页面绑定基础状态。

验收：
- 能从游戏中心进入页面。
- 页面显示“红警 Lite 开发中”占位信息。

提交信息建议：
- `feat(redalert-lite): add game entry and empty page`

---

## Iteration 02：世界坐标与相机系统
目标：建立 RTS 地图坐标和相机。

任务：
- 实现 world 坐标与 screen 坐标转换。
- 支持拖拽平移相机。
- 加入基础边界（不能拖出地图过远）。

验收：
- 地图可平滑拖动。
- 单位占位点在拖动后位置正确。

提交信息建议：
- `feat(redalert-lite): add camera and coordinate transform`

---

## Iteration 03：地图与资源点
目标：可见地图 + ore 资源点。

任务：
- 地图数据结构：宽高、通行格、资源格。
- 渲染资源点与简单背景。
- 资源点具备 `amount`（可耗尽）。

验收：
- 地图上出现可识别资源区。
- 资源点状态可随调试操作变化。

提交信息建议：
- `feat(redalert-lite): add map tiles and ore nodes`

---

## Iteration 04：基地核心建筑（Construction Yard / Refinery / Power Plant）
目标：完成最小建筑闭环。

任务：
- 建筑实体与占地判定。
- 支持放置 3 类建筑：建造厂、矿场、电厂。
- 扣费与建造时长。

验收：
- 资金足够时可成功建造。
- 建筑不能重叠。

提交信息建议：
- `feat(redalert-lite): add basic building placement and costs`

---

## Iteration 05：采矿车循环（Harvester）
目标：资金增长闭环跑通。

任务：
- 增加采矿车状态机：找矿 -> 采矿 -> 回矿场 -> 卸货。
- UI 显示当前资金。
- 资源耗尽后采矿车切换寻矿逻辑。

验收：
- 资金会持续增长。
- 资源逐步减少。

提交信息建议：
- `feat(redalert-lite): implement harvester economy loop`

---

## Iteration 06：电力系统与低电惩罚
目标：引入红警核心策略点“电力”。

任务：
- 统计 `powerSupply` / `powerDemand`。
- HUD 增加电力条。
- 低电时：生产速度降低、雷达禁用（先禁用 mini map 高级层）。

验收：
- 拆除/失去电厂后明显进入低电状态。
- 恢复电厂后状态恢复。

提交信息建议：
- `feat(redalert-lite): add power grid and low-power penalties`

---

## Iteration 07：兵营与基础步兵生产
目标：可产兵并控制移动。

任务：
- 增加兵营建筑。
- 增加步兵单位配置、生产队列、出生点。
- 支持点选单位与点地移动。

验收：
- 可连续生产步兵。
- 步兵可响应移动命令。

提交信息建议：
- `feat(redalert-lite): add barracks and infantry production`

---

## Iteration 08：战车工厂与载具生产
目标：第二类生产线上线。

任务：
- 增加战车工厂与坦克单位。
- 引入更稳定寻路（栅格 A* 简化版）。

验收：
- 坦克可绕开障碍到达目标点。

提交信息建议：
- `feat(redalert-lite): add war factory and vehicle pathfinding`

---

## Iteration 09：战斗系统 V1
目标：形成战斗闭环。

任务：
- 攻击属性：射程、冷却、伤害、血量。
- 自动索敌（最近/威胁优先二选一）。
- 单位死亡与建筑摧毁表现。

验收：
- 双方单位可自动交战并产生胜负趋势。

提交信息建议：
- `feat(redalert-lite): implement auto combat v1`

---

## Iteration 10：胜负结算与重开
目标：完成一局闭环。

任务：
- 定义胜利/失败条件（至少基地摧毁判定）。
- 增加结算 UI 与“再来一局”。
- 回收并重置对局状态。

验收：
- 一局游戏可从开始到结束再到重开。

提交信息建议：
- `feat(redalert-lite): add match result and restart flow`

---

## Iteration 11：科技树与前置依赖
目标：从“能建”升级为“按前置可建”。

任务：
- 配置化前置依赖表。
- UI 对未满足前置项做置灰提示。
- 拆除关键建筑后动态影响可生产项。

验收：
- 前置关系在 UI 与逻辑层一致。

提交信息建议：
- `feat(redalert-lite): add tech prerequisites`

---

## Iteration 12：迷雾与小地图
目标：提升 RTS 感知体验。

任务：
- 单位视野半径。
- 迷雾（未探索/已探索/可见）三态简化。
- 小地图同步可见区域。

验收：
- 低电时小地图功能受限。
- 探索区域有渐进变化。

提交信息建议：
- `feat(redalert-lite): add fog of war and minimap`

---

## Iteration 13：AI 对手 V1
目标：可打“人机局”。

任务：
- AI 基础建造顺序。
- AI 维持采矿与补电。
- AI 定时出兵进攻。

验收：
- 1v1 人机可形成完整对抗。

提交信息建议：
- `feat(redalert-lite): add basic skirmish ai`

---

## Iteration 14：性能优化轮
目标：解决中后期单位增多带来的卡顿。

任务：
- 渲染裁剪（仅渲染视口内实体）。
- Tick 分帧预算（逻辑分批处理）。
- 减少不必要状态拷贝与 UI 全量刷新。

验收：
- 中等规模对局帧率显著稳定。
- 启动与首帧加载更快。

提交信息建议：
- `perf(redalert-lite): optimize render and simulation loops`

---

## Iteration 15：打磨与发布收口
目标：可交付的子游戏版本。

任务：
- UI 风格统一（红警科幻感、按钮与面板风格）。
- 新手引导（3 步：采矿/建造/出兵）。
- 崩溃保护与日志埋点。
- 文档化核心参数与调优方法。

验收：
- 新用户可在 3 分钟内理解玩法。
- 无阻断型崩溃。

提交信息建议：
- `chore(redalert-lite): polish ux and release baseline`

---

## 6. 参数与数据配置建议

建议在 `games/redalertlite/model/config` 下维护：
- `buildings.json`：建造时间、造价、电力供需、前置。
- `units.json`：血量、速度、攻击、射程、生产建筑。
- `economy.json`：采矿速率、载荷、矿点容量。
- `rules.json`：胜负条件、低电倍率、AI 频率。

原则：
- 规则配置化，逻辑代码只消费配置。
- 每轮改平衡时只改配置，不动系统主逻辑。

---

## 7. 验收清单（每轮）

每轮在 PR/提交说明中固定输出：
1. 改动文件列表。
2. 验证步骤（模拟器上可复现）。
3. 结果截图/关键日志。
4. 已知问题与下一轮计划。

---

## 8. 风险与规避

- 版权风险：
  - 规避：原创素材、原创命名、玩法借鉴而非资源搬运。
- 性能风险（RTS 实体多）：
  - 规避：尽早做实体分层与渲染裁剪。
- 复杂度失控：
  - 规避：严格迭代边界，每轮只做一个主目标。

---

## 9. 参考资料（联网调研来源）

1. OpenRA Traits 文档（生产、电力、采矿等模块拆分）  
   https://docs.openra.net/en/release/traits/
2. OpenRA 法律说明（资产与商标边界）  
   https://www.openra.net/legal/
3. OpenRA 项目主页  
   https://github.com/OpenRA/OpenRA
4. 红警手册资料页（经典单位与建筑说明参考）  
   https://cnc.fandom.com/wiki/Command_%26_Conquer%3A_Red_Alert_manual
5. RTS lockstep 相关实现参考（用于后续联机扩展）  
   https://github.com/mrdav30/LockstepRTSEngine

