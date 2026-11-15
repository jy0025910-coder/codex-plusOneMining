# 力量反馈 v2：用户选择的第二款铁镐

2026-11-15，使用选定的 B 款原图，仅等比缩放到 512×512，保留透明背景。未重新生成或改画。

- 图片 Image ID：`140555305371223`，UI 使用 `rbxassetid://140555305371223`。
- 上传生成的 Decal ID：`82197395158159`，所有者为当前 Studio 用户 `11832238976`。审核 Approved。
- 当前 Studio 工程：`+1矿工`，placeId `95023028297106`，已保存至云端版本 4。此次没有执行发布。
- 可复用原生组件：`Exports/PowerGainTemplate_v2.rbxmx`，从 Studio 实际对象保存到文件。
- 创建脚本：`Source/build_feedback_template.luau`。组件位于 `ReplicatedStorage.Shared.PowerGainTemplate`。
- 行为模块：`../../src/ReplicatedStorage/Shared/MiningFeedback.luau`。使用 ImageLabel，并兼容原有 ViewportFrame 模板。

复用时把组件放在 MiningFeedback 同级，调用 `Feedback.new(screenGui, player):Power(amount)`。界面只负责展示；力量数值仍由已有服务端逻辑决定。换到其他账号/体验时需要确认该图片的使用权限。

保留原有 86×86 图标区域、白字黑边 FredokaOne、随机位置、弹出/上飘/淡出和清理逻辑；地图、训练、自动挥镐和服务端加力量逻辑没有修改。

## 验证

Studio 单人 Test、客户端视口 1072×431：选定图片在实际 PlayerGui 中 `IsLoaded=true`，画面已检查。一次真实鼠标点击使 Power 从 1 变为 2，捕获到 ImageLabel 的「铁镐 +1」；角色未出现 MiningStrokeAt，1 秒后 PowerGain 数量为 0。Output 仅有之前已存在的 `203785492` 类型不匹配提示。

`Renders/SelectedPickaxeB_ClientReview.jpg` 是游戏内实际组件的放大静态检查图（1.5 倍，用于查看图标细节）；临时检查对象已删除。`Selected_B_SizeReview.png` 是离线尺寸对照图。

`Source/sync_export.py` 把实际导出的组件与脚本同步到本地原 rbxlx，保留其余世界。`Source/verify_saved.py` 比较同步前备份，校验地图、灯光、服务端资产与玩法、数字样式不变，以及本地组件和 Studio 导出一致。`verification.json` 记录静态结果；`runtime_verification.json` 记录实际运行结果。

本轮没有重测手机设备、多人联机或完整采矿流程。完整当前云端工程下载备份另存于本机 `work/icon_b_cloud_snapshot.rbxlx.rbxl`，是 Studio 原生二进制 rbxl，仅扩展名来自下载对话框自动追加；不作为新的游戏版本开发。
