# 山石材质精修 v2

状态：已更新原工程中的局部样板和可复用岩壁模板，供视觉评审；整图尚未推广。

## 实际改动

- 从大面积近纯橙色，改为宽窄不一的赭红／暖橙层岩纹，加入少量断续风化纹与片状色差。
- 三款墙体保留原剪影、尺寸、UV和三角面数；原规则浅槽的径向内收量减为约原来的32%，弱化装饰腰线感。
- 使用图像生成工具制作二维底色源，在Blender中以镜像箱式投影烘焙到模型UV；每款底色图由1024²提升到2048²。没有烘焙场景投影或日光。
- 最终Studio表面采用直接TextureID＋粗糙Concrete基底，Reflectance=0。保留彩绘底色，同时抑制SmoothPlastic的大块白色高光。不是把灰色混凝土纹理直接当砂岩成品。
- 当前未发布place的SurfaceAppearance纹理打包请求曾出现HTTP 502／需要PlaceId等失败；改用直接底色路径后，对9个模板／实例的网格和贴图进行预加载，18项回调均为Success。历史Output中的失败信息未抹除。
- B款先前图像交付失败，制作极轻微偏冷的色彩变体并重新上传；最终图像ID见asset_manifest.json。两次打包尝试的源脚本保留，方便追溯。

## 看实机

- [相同机位前后对比](Renders/Studio_Before_After.png)
- [新版整体](Renders/Studio_After.jpg)
- [墙面近景](Renders/Studio_Close.jpg)

实机截图原样保存，对比图只添加标题并排摆放，无调色、修图或生成画面替代。

对比图的“调整前”使用上一版已保存的Studio_Sample_Overview.jpg；“调整后”以相同相机坐标(449,20,43)、目标(420,11,-12)重新截图。未使用本轮导入过程中带有悬空待处理网格的临时画面作为基准，避免导入物阴影影响地面对比。

## 复用与源文件

- [最新版原生资产库](Exports/Camp_Sample_Library_v2.rbxmx)
- [最新版局部样板](Exports/Camp_Art_Sample_v2.rbxmx)
- [Blender组合源文件](CanyonWall_Kit_Material_v2.blend)
- Exports/CanyonWall_Material_v2.fbx：三款组合；导入后以本版原生资产库的材质设置为准。
- CanyonWall_B_SurfaceFix.blend：B款轻微色彩变体的中间源文件。
- [纹理源和完整提示词](texture_prompt.md)：使用内置image_gen；输出Textures/Sandstone_PaintedStrata_Source.png。
- refine_wall_material.py：烘焙和浅槽调整；export_b_retry.py：B款色彩变体及组合导出。依次运行可重建。

## 核验范围

保存文件与本轮修改前快照逐项对比：原营地、样板地面、摊位、NPC、练习石、绿框、全局光照、墙体碰撞代理均保持一致。仅替换墙体视觉网格／底色，并更新编辑期组装模块的材质版本元数据。

[文件核验结果](verification.json)。本轮做了Edit实景检查和最终资产预加载；期间启动过单人Play用于加载诊断，未做最终版本的完整玩法、多人或移动端验证。材质增加显存开销，未做性能数值承诺。

当前结果仍为待用户审阅的局部样板。
