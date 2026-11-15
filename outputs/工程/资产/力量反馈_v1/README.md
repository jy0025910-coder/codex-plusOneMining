# 力量增长反馈与自动敲击 v1

日期：2026-11-15。继续保存至原《晶脉峡谷_三区矿洞初稿.rbxlx》。本轮以原有铁镐作为力量增长图标；手臂、拳套、砝码、铁砧、闪电PNG均为未采用的探索稿。

## 最终行为

- 点击世界、轻点世界或F／手柄X，只通过原Practice RemoteEvent请求+1力量；服务端限频0.15秒。点击不调用MiningMotion、不产生目标受击效果，也不向Dig发送攻击目标。
- 自动练习沿用原TrainingZone和+1／+3／+6。靠近未打通的矿门、已解锁区域的矿脉，会由服务端寻找可达目标并自动敲击；离开后停。矿门前距约11studs，矿脉中心距约11studs，旧19studs服务端攻击上限保留。
- 目标必须在当前营地矿洞内、有合法层级及类型、在解锁进度允许范围内，且射线可达。已打开的门在个人查询中排除；不同玩家仍保留个人门血量与进度。客户端手动Dig不再连接攻击处理器。
- 背包满5块后停止自动采集矿脉。自动敲矿与点击分别限频，点击不会抢占自动敲击时钟。
- 矿门、矿脉挥镐与原自动练习保持1.5倍动作速度，受击反馈使用同一速度对齐。

## UI组件

`ReplicatedStorage.Shared.PowerGainTemplate`为可编辑CanvasGroup，含铁镐ViewportFrame、白色FredokaOne数字、4px深色描边和UIScale。图标直接复用现有`Tool.IronPickaxe`的7个可见MeshPart，共享原网格和材质，不创建新上传资产。

每次克隆组件后，约0.16秒弹出，铁镐轻摆，整体上浮，约0.76秒清理。位置落在屏幕中部随机区域，尽量避开前一次；按视口缩放。ReducedMotionEnabled启用时取消位移和弹跳，仅淡出。Camera实例不会复制到客户端，因此模板保存相机CFrame／FOV属性，客户端为每个组件重建独立Camera。

复用入口：

- `MiningFeedback:Power(amount)`：纯UI力量提示。
- `MiningFeedback:CreatePowerPopup(amount)`：从模板创建组件，供开发预览或其他UI使用；调用方负责Parent和清理。
- `MiningFeedback:Stroke(target,amount,speed)`：只由自动敲击反馈调用，保留受击时点。
- `Source/build_feedback_template.luau`：编辑期模板构建源。
- `Exports/PowerGainTemplate.rbxmx`：从保存后的原工程导出的完整可复用组件。

生产代码仍在原`outputs/工程/src`下的PrototypeConfig、MiningService、DigController和MiningFeedback，不创建平行输入系统或新RemoteEvent。

## 已执行的单人Play检查

- 休息站点击：Power增加1，MiningStrokeAt仍为空；字体FredokaOne、字号70；组件独立Camera存在，0.9秒后无残留。
- 无点击靠近第一道门：门血量自动下降，出现挥镐，最终Gate1HP=0、DeepestLayer=1。
- 离开矿门回中央：AutoMining=false，挥镐状态清除，第二道门仍为300耐久。
- 无点击靠近首层矿脉：观察到背包从3增长到5，随后AutoMining=false。
- 走进基础训练光区：TrainingGain=1、力量自动增加、挥镐存在。
- 重生后点击：+1正常、Camera重建成功、无点击挥镐。
- 最后一次Output只有既存203785492资源类型不符提示；早先开发预览直接访问未复制Camera产生的诊断错误已通过相机属性重建修正，并在重生后复核。

未执行：双客户端、触屏设备实测、手柄实测、移动设备性能基准。每个提示包含一个7网格ViewportFrame；高点击率与低端手机成本尚未测量，不报告为已优化。

## 预览说明与资产审批

`Renders/Pickaxe_Gain_Component_Studio.jpg`是Studio单人Play中的真实组件放大预览，临时面板及静止展示仅用于审阅，已移除；实际点击只生成铁镐和数字的短暂提示。

曾尝试上传未采用的候选PNG：HTTP上传未成功，Open Cloud创建临时Decal被自动审批拒绝，未取得任何新图片AssetId。用户随后改为铁镐图标，最终复用已有模型，未继续上传候选或绕过拒绝。
