# 练功石三款 · 示意图对齐重制

## 本轮微调（版本 3）

- A 灰色款：右下、右上和后侧包裹岩块收窄、减薄；左上岩块提高并向前补齐，延伸到接近主岩体顶部。
- C 紫色款：两条层缝的径向凹入量降至原来的约四成，宽度稍减，缝内底色提亮；保留原有层次、倾斜方向和标记。
- B 蓝色款：保留已认可的版本；源模型、FBX/GLB、贴图及五张单款预览的 10 个文件 SHA-256 全部一致。
- 外观微调阶段只调整 Blender 资产；用户确认后已接入原游戏，见下方 Roblox 状态。

`Renders/A_C_Refinement_Before_After.png` 为同一相机、同一灯光下的调整前后对照；`refinement_manifest.json` 保存变更及蓝色款文件核对记录。

本目录取代前一版「规格版」作为新的造型审阅稿。按用户本轮反馈，以示意图的形体和符号为视觉目标；保留原规格的厚度、尺寸、性能和无发光要求。A 款从文字中的矿脉改回图中的金色回形标记与内菱形，B 改为浅青菱形边框与实心小菱形，C 保留紫色旋涡与弯折层缝。三款标记直接分离了用户原图的符号轮廓，保留形状的转折、粗细和中间独立标记，未将示意图的岩体、光照、草地或背景直接投射到模型上。

## 改动与检查

- 移除上一版沿整圈均匀收缩的环带结构。
- A：主受击面、左右高低不同的咬合岩块、底部相连的小岩块；顶部收窄，边缘做实际缺口。
- B：宽大的主体受击面，斜向凹入的青色裂带，大小不一的肩部和底部岩块。
- C：三段连续岩体，顶部收窄，层缝倾斜并弯折；紫色旋涡位于完整面内。
- 大切面由不同角度的切割平面形成；实际布尔合并后清理、控制三角面预算。不是三个独立浮空层，也没有围栏、水晶或光效。
- 所有纹路绘制在 UV 底色中，不使用悬空线条。哑光材质，Emission=0。

`Renders/Reference_vs_Blender.png` 上排直接裁取用户示意图，下排为本轮实际 Blender 网格渲染，只做排版和缩放。没有把生成图片冒充实模截图。源参考画面中的手绘磨损、边缘明暗仍比实模丰富，本轮不宣称像素级一致。

`Source/trace_reference_symbols.py`、`ReferenceMark_A/B/C.png` 和 `reference_symbols.json` 保存符号分离过程与结果，建模文件不依赖临时参考图路径即可再次生成。

## 交付文件

- `Source/PracticeRock_A_Classic.blend`、`PracticeRock_B_Rune.blend`、`PracticeRock_C_Layered.blend`：独立源文件，贴图打包在内。
- `Source/Three_Rocks_Review.blend`：三款并排的可旋转审阅场景。
- `Exports/`：三款 FBX、GLB 与同目录贴图；仅导出岩体，不含预览地面、灯和相机。
- `Textures/`：每款一张 2048×2048 RGB BaseColor，无真实照片纹理。
- `Renders/`：每款正、侧、背、顶和斜视截图，以及并排渲染、参考对照图。
- `asset_manifest.json`：重新打开三份源文件核验所得的几何与 FBX 往返导入结果。
- `Exports/PracticeRock_TrainingLibrary.rbxmx`：从实际保存的原工程提取的三款可复用模板，含永久 MeshId、SurfaceAppearance.ColorMap、底部原点和版本属性。
- `studio_integration.json`：原生导入资产 ID、试玩结果及已知外部素材告警记录。
- `Renders/Roblox_Studio_Integrated.png`、`Roblox_Practice_B_Playtest.png`：当前游戏场景与实际自动敲击截图。

全部模型使用 Blender 5.2.3 LTS 制作。X 宽、Y 深、Z 高：8×6.5×6.5；底部中心为原点，旋转为 0，缩放为 1。每款一个闭合且相连的 Mesh、一个材质、一层 UV，不超过 1000 三角面。

## Roblox 状态

用户确认后，三款已通过 Studio 原生 FBX 导入，上传网格与贴图，替换到同一个 `晶脉峡谷_三区矿洞初稿.rbxlx` 的左侧练习区。世界尺寸统一为 8×6.5×6.5 Stud，标记朝广场 +X。没有更换工程文件名或发布游戏。

`ServerStorage.GameAssets.TrainingRocks` 已更新为最新版。`MiningAssets.CreateTrainingRockVisual` 复用模板，配置通过 `PrototypeConfig.Trainings.PracticeAsset/PracticeScale/PracticeYaw` 控制，未来重建地图不会退回旧矿石。显示网格负责受击抖动，单独的透明 Hull 碰撞体固定不动；原 `Target` 保留查询和训练标签，避免隐藏的大盒子挡住人物。

单人 Studio 试玩已检查 Server 与 Client：三处自动训练分别增加 +1/+3/+6；观察到闪白、抖动与碎屑；碰撞体在抖动期间保持固定；离开区域力量不再自动增长，实际鼠标点击从 1068 增加到 1069。三款客户端网格预加载均返回 Success，三处点击射线都命中 Target。蓝色底板下与其共面的 25 块路砖已清理，建图模块同步跳过被练习平台覆盖的砖，消除闪烁。

保存前已停止试玩，清理临时碎屑与导入暂存对象。未宣称多客户端、移动端或完整挖矿销售流程回归测试。试玩 Output 中仍有项目原有外部演示包缺少 `Scriptforplayer` 和资产 203785492 类型不匹配的告警，记录在 `studio_integration.json`；本次没有修改这些外部演示素材。

## 重建与复用

`build_rocks.py` 中 `convex_stone`、`boolean`、`inlaid_seam`、`clean_and_scale` 为复用的岩块、合并、嵌入层缝和规范化步骤；每款的手工形体参数在 `build` 的对应分支。配色与符号在 `PROFILES` / `paint` 内。`rock_pipeline.py` 负责 UV、底色贴图、导出前检查和预览设置。

每款独立运行，防止一个型号失败影响其他型号：

```powershell
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background --threads 4 --python 'Source/build_rocks.py' -- A
```

将末尾 A 换成 B、C。三款全部完成后，运行 `Source/validate_and_review.py` 核验源文件、FBX 往返导入并生成并排场景；`compose_comparison.py` 仅用于参考与实模的排版对照。

来源：用户提供设计图；网格和纹路由项目内 Blender Python 脚本制作，没有导入第三方网格或照片素材。
