# 营地局部实景样板 v1

> 最新进度：[墙面材质精修v2及实景对比](Material_v2/README.md)。下文保留首轮样板的制作记录；最新版资产库在Material_v2/Exports中。

2026-11-15。状态：S1样板已制作并在Studio观察，等待用户视觉评审；尚未替换整张地图。

原工程：晶脉峡谷_三区矿洞初稿.rbxlx。Studio停在Edit模式，镜头朝向样板。Explorer位置：Workspace → Camp Art Sample。样板原点约(420,0,0)，原营地和出生点保留。

## 看实际效果

- [Studio整体实景](Renders/Studio_Sample_Overview.jpg)
- [Studio地板与单个摊位近景](Renders/Studio_Sample_Close.jpg)
- [Blender墙体模块检查图](Renders/Blender_Wall_Review.png)

以上Studio图片为原始实机截图，无画面后期。Blender图是源模型检查图，不能代替实机。

## 实施范围

| 部位 | 实际制作路线 | 本版结果 |
|---|---|---|
| 围墙 | 原生CSG两轮试做后局部转Blender | 两款直段、一款转角；宽面、不同高低轮廓、浅层岩纹、贴地宽底 |
| 地板 | Roblox原生Part＋Concrete／Slate | 浅冷灰砖、深灰边带、厚路缘、一个T形交叉与小站台台阶 |
| 摊位 | 克隆现有MarketStall，只调整表面 | 原307个BasePart的几何保持，112个木构件用Wood、190个篷布件用Fabric，收敛绿／奶油配色 |
| NPC／练习石 | 直接复用 | 人物外观不改，基础练习石只作尺度参照 |
| 绿框 | 复用已有资产的视觉副本 | 去掉玩法标签、禁用Trigger，仅供视觉对照 |

原生尝试截图保留在Renders/Native_Attempt_01.jpg、Native_Attempt_02.jpg。第一轮砂岩材质出现大块砖缝感，第二轮轮廓仍偏方盒，按PRD触发墙体Blender后备路线。生成地砖材质也因斑驳不合适被弃用；最终使用内置细混凝土表面。未采用的材质候选已从工程清理。

## 可复用交付

- [完整环境资产库](Exports/Camp_Sample_Library.rbxmx)：包含墙体源模板、原生铺地模板、摊位材质候选及编辑期组装ModuleScript。
- [独立样板模型](Exports/Camp_Art_Sample.rbxmx)：可直接插入Studio查看完整局部组合。
- [Blender源文件](Source/CanyonWall_Kit.blend)：三个可编辑墙体，内嵌1024²底色贴图。
- Exports/CanyonWall_A.fbx、CanyonWall_B.fbx、CanyonWall_Corner.fbx及组合FBX。
- [原生组装源码](Source/CampNativeKit.luau)：保留原生CSG试做路线；有CanyonMeshKit时复用已导入墙体。
- [Blender建模源码](Source/build_canyon_fallback.py)：从几何、浅纹、UV到FBX的重建脚本。

源blend中的三个物体为便于检查而横向摆开；发布FBX由重建脚本在各自底部局部坐标原点导出。Studio模板统一以底部中心为Pivot，局部-Z朝营地内侧。墙体各一个材质、一个UV层；最终A/B各1160三角面、转角886三角面，共3206。闭合性检查通过，尺寸与Studio导入尺寸相符。

## 检查记录与边界

- 样板426个BasePart，全部Anchored；无执行脚本、无玩法标签、无启用Prompt。
- 已在Studio单人Play中实际按W走过地砖接缝，从z=16到约z=-3.20，没有掉落或停在接缝上。
- 在预览绿框内观察1.2秒，TrainingGain=0，力量1→1、金币0→0；本测试只验证没有误触发，未覆盖带矿背包。
- 最后一次墙体导入后做了Edit近景检查和尺寸检查，未重新做墙体碰撞穿行测试。
- 与修改前本地文件对比，原Gem Gulch序列化属性一致，既有脚本Source无变化，游戏自有脚本未缺失。外部演示包在修改前磁盘文件与当前Studio之间有脚本数量差异，本轮没有编辑该包；详细差异保存在delivery_verification.json，不从旧文件恢复用户现场状态。
- 本轮没有运行完整挖矿售卖回归、多人或移动设备检查，也未做FPS性能声明。
- Output仍见既有203785492类型不匹配；启动期间出现FieldKit等待警告，后续客户端确认FieldKit已存在。没有改这些脚本，不能宣称Output完全无警告。

制作与功能实测见[实施记录](implementation_record.json)，保存文件核验见[交付核验](delivery_verification.json)。

当前墙面纹理比概念稿更简洁，整体营地布局和光照尚未推广。此样板用于确认墙体轮廓、铺地明暗、保留原摊位时的搭配；尚未标记为可整图批量复制。
