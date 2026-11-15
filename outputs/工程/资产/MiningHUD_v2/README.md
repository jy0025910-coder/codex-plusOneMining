# 矿工 HUD v2：平面按钮、放射光与渐隐资源栏

2026-11-16。继续修改同一个原型和同一个 `StarterGui.MiningHUD`，复用全部已确认图标，不上传新图片，不增加购买或经济功能。

- 菜单：统一平面的浅天蓝底色；商店为暖黄，重生为浅紫。去掉按钮 UIGradient 和悬停/按下缩放，只轻微变色。
- 右侧礼包：去掉卡片底板和描边。铁镐后面添加白色米字光芒：横、竖、两条斜向光束，每条从中心向两端透明渐隐，中心叠加低透明度圆形柔光。不是外部贴图，不需要新图片授权。
- 资源栏：行容器完全透明，只保留中间较深、两侧透明的黑色阴影；去掉背包/金币/重生的小字标签。钱数采用亮绿色 FredokaOne、3.5 px 黑描边；宽屏数字放大至 42 px。
- 宽屏礼包约 178×132，窄屏保留折叠与横排适配。低矮宽屏菜单按钮适当收紧，避免与放大后的资源栏相撞。

`ReplicatedStorage.Shared.HUDDecor` 提供编辑时的 `Burst()` 与 `ResourceShade()`，可单独复用；原生 GUI 仍是可编辑的真实 Instances。主题颜色、布局和交互继续分别由 HUDTheme、HUDLayout、HUDController 管理。游戏运行时不重新创建整套界面。

## 文件

- `Exports/MiningHUDKit.rbxm`：通过 Roblox SerializationService 直接生成，并在 Studio 反序列化验证的原生组件包。
- `Exports/MiningHUDKit.rbxmx`：可读 XML 副本，从引擎可读且可序列化属性、Attributes 和脚本源代码生成。已在 Studio 中成功反序列化，对比原生实例属性快照，差异为 0；元数据身份值不作跨序列化保留承诺。
- `Source/native_snapshot.json`：此次层级与可读序列化属性记录；`snapshot_ui.luau` / `snapshot_to_xml.py` 为配套导出流程。
- `Source/build_hud.luau`：本版编辑时创建脚本，依赖 Shared 中的 HUDTheme 与 HUDDecor。
- `Source/sync_export.py`：把导出组件与 UI 模块同步回本地原 rbxlx，保留原挖矿控制器。
- `Source/verify_saved.py` / `static_verification.json`：验证范围与源文件一致性。
- `Renders/HUD_Polish_Desktop.jpg`：实际运行截图，玩家真实初始资源。
- `Renders/HUD_Polish_CurrencySample.jpg`：实际运行的字体/阴影评审截图，临时设定金币 16,882、背包 3/5；拍摄后已经恢复，不是新增奖励。

组件包的 Shared 增加了 HUDDecor，其余复用方式见 MiningHUD_v1。全部图标、图片 ID 与来源记录仍见 `../MiningHUD_v1/asset-manifest.json`。

## 检查

实际 Studio 单人客户端视口 2352×909（安全区域 2352×851）完成视觉检查；确认菜单没有 UIGradient、悬停 UIScale 保持 1、资源与礼包容器 BackgroundTransparency=1、金币为 FredokaOne 亮绿色。首次光芒被铁镐遮住，随后扩大到图标外围并重新检查。

5 组引擎内克隆布局画布（1600×900、1280×720、1024×600、844×390、390×780）分别检查关闭、菜单展开、礼包展开，金币统一用 16,882，最终均无 TextFits 失败和画布越界。这不是手机真机或设备模拟测试。

原生 RBXM 往返反序列化成功，组件包后代 275；XML 副本往返成功，属性快照差异 0。静态校验确认地图、灯光、服务端逻辑与资产、旧弹字/动画、原挖矿控制器保持不变。

Output 仍观察到原来的 203785492 类型提示和 3 个 rbxassethash 权限提示；未观察到本轮新增 Luau 错误。未重测手机触屏、手柄、多人、性能或购买流程；购买仍未开放。
