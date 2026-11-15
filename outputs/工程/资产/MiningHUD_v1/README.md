# 矿工 HUD v1：游戏内展示版

基于用户已确认的 HUD 视觉稿，金币采用 A 款矿纹金币。当前「+1矿工」placeId `95023028297106` 已保存到 Roblox 云端版本 **9**，没有执行发布。本地同一原型 `outputs/晶脉峡谷_三区矿洞初稿.rbxlx` 也已同步。

## 当前范围

- 顶部等级、升级进度、升级差额与双铁镐 ×2 / R$ 9；等级 4、58/68、差 10 为明确标注的示例。
- 左侧八个菜单、左下背包/金币/重生显示、右侧三档力量礼包。
- Power / Ore / Capacity / Coins 读取现有玩家属性。重生尚无系统，显示 0；未来有 Rebirths 属性时自动展示。
- 商品价格和数量为样稿值；没有产品 ID、MarketplaceService 或购买调用。菜单点击只提示“界面展示”，不扣款、不加商品力量。
- 现有点击加力量、自动敲击、卖矿和回营地仍由原有系统处理。这次只改变 HUD 所有权与展示。

## 实际尺寸

| 布局 | 菜单 | 资源 | 礼包 |
|---|---|---|---|
| 安全区域宽 ≥1100 且高 ≥650 | 82×88 按钮，图标框 72×65；2 列 4 行 | 图标 54×54，三行 | 218×91，右侧竖排 |
| 空间不足 | 58×58 菜单入口；展开后 62×68 按钮 | 顶部 34 高横排，图标 38×38 | 折叠入口；矮横屏展开后改为横排 |

图片自带安全边距，实际图形略小于图标框。正文和价格为原生文字，图标没有烘焙按钮底板。保留中央采矿视野。

## 资产与模块

- `Icons/`：9 张独立原始透明 PNG，通过内置 ImageGen 参照已批准的图标板逐张制作。未裁切其他游戏截图。图标尺寸/透明度/哈希及 Roblox IDs 见 `asset-manifest.json`。
- 铁镐复用已批准的 `140555305371223`；双倍图标由两张该铁镐 ImageLabel 与 ×2 文本组合。
- `Exports/MiningHUDKit.rbxmx`：Studio 原生导出的组件包，含 ScreenGui、HUDTheme、HUDLayout、HUDController 与本游戏 DigController 迁移版本。
- `Source/build_hud.luau`：仅编辑时创建层级；玩家运行时不重新生成整套 UI。
- `Source/icon-prompts.json`：本轮 9 张 PNG 的提示词与参考来源。
- `Renders/`：实际游戏宽屏、小窗口及菜单展开截图，不是生成的实装效果图。

实际拥有者：

```text
StarterGui.MiningHUD.Root
  TopRow / MenuGrid / ResourceList / PowerOffers / Status
ReplicatedStorage.Shared
  HUDTheme / HUDLayout
StarterPlayer.StarterPlayerScripts
  HUDController / DigController
```

FieldKit 继续作为原有 +1 / 点击圈的效果容器。旧 DigController 的临时 HUD 构造代码已移除，目标/提示/回营地引用新的原生层级，避免出现两套 HUD。

复用到其他项目时，将 kit 的 MiningHUD 放入 StarterGui，Shared 两个模块放入 ReplicatedStorage.Shared，Client.HUDController 放入 StarterPlayerScripts；它可以独立显示 HUD。`ExistingGameIntegration.DigController` 依赖本游戏挖矿系统，仅作为当前游戏的迁移代码，不能直接放到其他项目执行。图片资产跨账号/体验复用仍需具有相应访问权。

模板在编辑模式默认 Enabled=false，避免在小编辑视口覆盖场景；HUDController 先完成布局再启用玩家界面。需要编辑图形时可临时开启模板预览。

## 验证与边界

实际单人 Test 检查过：2352×909 宽屏与 1072×431 小窗口；所有可见新图标显示成功；菜单点击不加力量，场景点击 +1，飘字正常清理；角色重生后保留一套 HUD；背包 2/5、金币 1,280 展示更新；折叠菜单/礼包切换与标签正确。临时属性样本、诊断 GUI、离屏布局画布和导出暂存 Folder 均已清理。

另在实际引擎中用克隆 UI 画布检查 1600×900、1280×720、1024×600、844×390、390×780，每组包含关闭/菜单/礼包三种状态，最终没有文字 TextFits 失败或边界溢出。这是布局检查，**不是手机设备模拟或真机触屏测试**。未测试手柄焦点、多人和性能基准。

首次加载新图时出现过延迟；Output 中还观察到既有 203785492 类型不匹配和 3 个 rbxassethash 权限提示，所有本轮可见 HUD 图片随后均正确显示，未观察到 Luau 运行错误。没有把 Output 称为完全干净。

`static_verification.json` 证明地图、灯光、服务端资产与逻辑、已有弹字/动画模板不变；四份脚本与本地源文件一致，GUI 与 Studio 导出一致。`runtime_verification.json` 记录实际运行证据和未执行的项目。
