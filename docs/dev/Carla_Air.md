## 空地一体仿真

该模块是一个开源的空地联合仿真平台。它通过在底层 C++ 将全球领先的自动驾驶仿真器（Carla）与机器人仿真器（AirSim）合并为单一的 `ASimWorldGameMode`，实现了真正的帧级传感器同步、统一的物理引擎，以及无缝的双 Python API 交互。

![](../images/dev/CarlaAir.gif)


## ✨ 核心亮点

- 🚀 **单进程深度集成**：拒绝跨进程通信桥接（Bridge），无延迟损耗。Carla 与 AirSim 共享同一个 UE4 世界、天气系统与物理引擎。
- 🎯 **绝对坐标对齐**：彻底解决 Carla（左手系）与 AirSim（NED）之间的坐标转换问题，误差精确控制在 `0.0000m`。
- 🚁 **内置 FPS 无人机控制**：无需编写任何代码，在仿真窗口内直接使用 `WASD` + 鼠标 即可像玩 FPS 游戏一样丝滑驾驶无人机。
- 🚦 **开箱即用的城市交通**：启动器默认自动生成 30 辆背景车辆与 50 个行人，立即构建逼真城市场景。
- 📸 **18路同步传感器**：支持在地面车辆和空中无人机上同时挂载 RGB、激光雷达、深度图、语义分割、IMU 和 GNSS，数据严格对齐。
- 🐍 **双 API 无缝协作**：在同一个 Python 脚本中，同时调用 `carla.Client`（端口 2000）和 `airsim.MultirotorClient`（端口 41451）。



---

## 🎮 快速开始

### 选项 A：使用预编译版本（推荐）

```bash
# 1. 下载并解压 CarlaAir-v0.1.7
tar xzf CarlaAir-v0.1.7.tar.gz
cd CarlaAir-v0.1.7

# 2. 一键环境配置（仅首次需要）
bash env_setup/setup_env.sh      # 创建 conda 环境，安装依赖，部署 carla 模块
conda activate carlaAir
bash env_setup/test_env.sh        # 验证环境：应全部显示 PASS

# 3. 启动仿真器（自动生成交通流）
./CarlaAir.sh Town10HD

# 4. 运行展示脚本！（另开一个终端）
conda activate carlaAir
python3 examples/quick_start_showcase.py
```

> **你将看到：** 一辆特斯拉在城市中自动巡航，无人机从空中追踪。4 分屏同时展示 **RGB · 深度图 · 语义分割 · LiDAR 鸟瞰** — 全部实时同步。天气自动轮换。

### 选项 B：从源码编译

如果您需要修改底层 C++ 代码，请参考 [源码编译指南](build_guide_ubuntu.md)，了解如何使用 UE4.26 编译 CarlaAir。

---

## 🐍 一个脚本，两个世界

两套 API 共享**同一个仿真世界** — 无桥接、无同步烦恼。

```python
import carla, airsim

carla_client = carla.Client("localhost", 2000)
air_client   = airsim.MultirotorClient(port=41451)
world = carla_client.get_world()

# 一次天气调用，影响所有传感器 — 地面和空中
world.set_weather(carla.WeatherParameters.HardRainSunset)

# 生成一辆汽车，自动驾驶
vehicle = world.spawn_actor(vehicle_bp, spawn_point)
vehicle.set_autopilot(True)

# 无人机起飞 — 同一个世界，同一场雨，同一套物理
air_client.takeoffAsync().join()
air_client.moveToPositionAsync(80, 30, -25, 5)
```

**6 个演示脚本** — 逐个试试：

```bash
python3 examples/quick_start_showcase.py   # 🎬 4分屏传感器 + 无人机追踪 + 天气轮换
python3 examples/drive_vehicle.py          # 🚗 WASD 驾驶特斯拉
python3 examples/walk_pedestrian.py        # 🚶 鼠标+键盘 城市漫步
python3 examples/switch_maps.py            # 🗺️  自动飞越全部 13 张地图
python3 examples/sensor_gallery.py         # 📸 单车 6 传感器网格展示
python3 examples/air_ground_sync.py        # 🔄 车+无人机分屏：同一场雨，同一世界
```

**录制工具** — 录制车辆、无人机、行人轨迹，然后用导演相机回放：

```bash
python3 examples/recording/record_vehicle.py     # 🚗 键盘驾驶并录制车辆轨迹
python3 examples/recording/record_drone.py       # 🚁 飞行并录制无人机轨迹（零侵入）
python3 examples/recording/record_walker.py      # 🚶 行走并录制行人轨迹
python3 examples/recording/demo_director.py \    # 🎬 多轨迹回放 + 自由相机 + MP4 录制
    trajectories/vehicle_*.json trajectories/drone_*.json
```



---

## ⌨️ 飞行控制说明

在 CarlaAir 窗口中，使用内置 FPS 控制器直接驾驶无人机（无需代码）：

| 按键 | 功能 |
|-----|--------|
| `W` / `A` / `S` / `D` | 前进 / 左移 / 后退 / 右移 |
| `Space` / `Shift` | 上升 / 下降 |
| `Mouse` | 偏航转向 |
| `Scroll` | 调节速度 |
| `N` | 切换天气 |
| `P` | 碰撞模式切换 |
| `H` | 帮助菜单 |
| `1` / `2` / `3` | 传感器画面 |

---

## 📚 文档与示例

**完整文档：**

- [技术文档](technical_document.md)

- [快速入门指南](quick_start.md)

- [技术架构详解](architecture.md)

- [坐标系换算](coordinate_systems.md)

- [录制 CarlaAir 演示视频的完整工具集](./recording.md)

- [常见问题](FAQ.md)

**开发**

- [上游代码修改清单](modifications.md)

- [CarlaAir 安装与运行指南](./install.md)

- [Carla + AirSim 集成开发进度记录](./dev_progress_log.md)

- [Carla + AirSim 测试教程](./test_tutorial.md)

- [carla-air v0.1 Release 测试报告](./v0.1_release_test_report.md)

- [v0.1.7 发布信息](./release_note.md)

- [编译问题记录](./build_faq.md)

---

## 📜 许可证与致谢

该项目是站在巨人的肩膀上。我们诚挚感谢以下开源项目的开发者：

- [Carla Simulator](https://github.com/carla-simulator/carla) (MIT License)

- [Microsoft AirSim](https://github.com/microsoft/AirSim) (MIT License)

- [Unreal Engine](https://www.unrealengine.com/)


Carla 相关的资产遵循 CC-BY 许可证。
其他相关资产（包括湖南工商大学大学场景、长沙中电软件园场景）和代码基于 **MIT 许可证** 开源。
