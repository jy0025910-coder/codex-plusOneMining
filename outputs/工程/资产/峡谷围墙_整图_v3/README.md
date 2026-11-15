# 峡谷围墙 v3：原地图集成

日期：2026-11-15。沿用原《晶脉峡谷_三区矿洞初稿.rbxlx》。本轮仅替换围墙，未实施PRD里的全地图扩建、铺地或设施重新布局。

## 回退与范围

修改前版本已提交并推送至指定 GitHub 仓库：`7bd5c82`，包含已认可练习石、围墙材质样板、设计稿及PRD。未提交旧废稿、工作缓存、SSH密钥或重复FBM目录。

保留原地面、四个摊位、NPC、训练站、两项排行榜、出生点和三层矿洞的位置与玩法。PrototypeVersion仍为2，没有用版本升级触发整图重建。

## 实际制作

- Blender从已认可v2网格修改：岩层按位置和高度分别起伏，旧凹槽深度局部淡化；不再把所有层纹排成相同间距的整圈。保留原有UV和三套橙色手绘砂岩贴图。
- 三个模板均为封闭网格，合计3206三角面，沿用哑光Concrete底材、Reflectance=0和直接TextureID，未使用此前加载不稳定的SurfaceAppearance路线。
- 原地图围墙用近处主墙、后排上下两层岩脊、四角内凸岩肩和矿洞岩冠组合。78个共享模板视觉实例、34个独立简单碰撞代理，约8万三角面；并非78套独占贴图。
- 最终围墙世界轴对齐外包约267×56×268 studs。可玩内场和设施未等比例扩大；主墙中心约±98，矿洞门位保持原值。
- 两次斜视检查发现局部透天，补入后排下层岩体和矿洞上方过渡块。碰撞布局不变。
- 原远处样板转存至`ServerStorage.GameAssets.Environment.ReviewSamples`，不再放在Workspace运行场景中；作为历史视觉样板保留，未改成玩法站点。

## 可复用入口

- 模板：`ServerStorage.GameAssets.Environment.CanyonMeshKit`，AssetVersion=3。
- 正式实例：`Workspace.Gem Gulch.Canyon rim`。
- 生产代码：`outputs/工程/src/ServerScriptService/Services/CampEnvironment.luau`的`ReplaceRim(town)`。仅构造新围墙并替换旧围墙；原有Build在模板v3可用时复用该入口，缺失模板则沿用旧后备路线。
- `Source/rim_builder.luau`为该函数的可读副本，修改时同步生产代码。
- `Source/irregular_strata.py`和`.blend`为源资产；FBX在`Exports`。纹理来源及生成提示词见上一版`营地原生样板_v1/Material_v2/texture_prompt.md`。
- `Exports/CanyonMeshKit_v3.rbxmx`、`CanyonRim_Integrated_v3.rbxmx`由保存后的原place提取，可独立导入复用。

最终Studio网格／贴图：

| 模板 | MeshId | TextureID（沿用v2） |
|---|---|---|
| A | 112904994536981 | 80241492425048 |
| B | 135907110245641 | 124207543160591 |
| Corner | 114785705213439 | 113511616860746 |

## 验证记录与边界

已在原place执行：

- Edit和单人Play客户端，六个唯一网格／图片内容均Preload成功。
- 新围墙对出生、练习区、排行榜、入口和三道门的走路空间无碰撞重叠；以5度间隔检查中心向外围的阻挡，除保留矿洞方向外无漏挡。
- 单人Play观察到训练Gain=1及力量增长。测试准备时将角色移离石头后，Gain归零且力量保持。
- 角色用Humanoid.MoveTo从矿洞前通道走到第一道门前；通过现有Dig RemoteEvent攻击，Gate1HP从100降到0、DeepestLayer变为1；随后实际走入第一间矿室，Z约-93.22。
- 将角色准备到左侧墙前，MoveTo越界目标，实际停在X约-90.03，角色存活。
- 两处后加的上方过渡块及19个后排下层块均为无碰撞、不可查询的视觉件；之后重新截图与静态保存校验，未重复整轮Play。
- Output只有既存203785492资源类型不符提示，未观察到本轮新增脚本报错。

未做完整采集5块—售卖—升级循环、多客户端、移动设备和性能基准；不将这些报告为已测试。character_navigation工具第二次报告Success但角色仍在原训练石上，因此未将该结果计入通行通过依据；上述矿洞通行用实际位置和Humanoid.MoveTo另行验证。

`verification.json`由保存文件和修改前备份比较产生，检查地面／设施／原玩法脚本／光照保持以及生产Source一致。

## 实景图

- `Renders/Studio_Integrated.jpg`：营地内部斜视，最终78个视觉实例版本。
- `Renders/Studio_Wall_Close.jpg`：训练区旁近景。
- `Renders/Studio_Overview.jpg`：整体包围关系。
- `Renders/Blender_Irregular_Strata.png`：源网格检查图，不作为Studio成品证明。

前三张均为未经修色、补画或替换材质的原始Studio截图。
