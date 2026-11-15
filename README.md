# Plus One Mining / 晶脉峡谷

当前 Studio 工程为「+1矿工」（placeId `95023028297106`），本轮已保存到云端版本 4。本地同一原型保留在 `outputs/晶脉峡谷_三区矿洞初稿.rbxlx`，按 F5 试玩；本轮同步了相同的力量反馈组件与脚本。

- 点击场景获得 +1 力量并弹出第二款卡通铁镐 PNG；点击不挥镐。待机时右肩扛镐，进入左侧练习区每约 0.533 秒自动敲击，靠近矿门和矿石自动采矿。
- 前方有三层矿洞，岩壁伤害按当前力量计算。矿石背包容量为 5，返回绿色光幕自动出售。
- 四面峡谷围合，十字石砖路的四个折角放置摊位；左侧霓虹练功区有三种巨型矿石与受击反馈。
- 玩家保留自己的 Roblox 形象和服装。

可编辑脚本在 `outputs/工程/src`，路径对应 Studio 的服务与容器。模型三视图、Blender 源文件、GLB 和可直接插入的 Roblox 预制件在 `outputs/工程/资产`。

`MiningAssets` 管理装备与矿石实例；`MiningService` 校验服务器玩法；`MiningMotion` 同步挥镐时刻；`MiningAnimator` 播放关节动作；`MiningFeedback` 管理点击圈、碎石和飘字。光幕继续复用 `ZoneVisuals`；`CampEnvironment` 管理峡谷环境，`RockImpact` 管理受击反馈。

当前是本地原型，进度按会话维护。试玩与复用说明见 `outputs/工程/三区矿洞初稿说明.md`。

第二款铁镐图标、Studio 导出的 UI 组件和接入说明见 `outputs/工程/资产/力量反馈_v2/README.md`。
