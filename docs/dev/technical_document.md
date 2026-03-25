# 面向自主系统的统一空地仿真

---

## 1. 引言和动机

### 1.1 问题

自主系统研究日益需要**联合空地仿真**——即无人机（UAV）与地面车辆/行人在共享的城市环境中共存和交互的场景。应用领域包括：

- **对自主交通进行空中监视**: 无人机监控和跟踪地面车辆
- **协同感知**: 无人机提供鸟瞰视角，以补充车辆级感知
- **社交导航**: 行人、车辆和无人机共享城市空间
- **多模态数据集生成**: 同步地面和空中传感器数据
- **搜救**: 无人机侦察，地面机器人穿梭于碎片之中


然而，这两个主流的开源模拟器服务于不同的领域：

- **CARLA** (英特尔实验室，巴塞罗那自治大学CVC): 高保真自动驾驶模拟器，包含车辆、行人、交通管理、10多种传感器类型和 OpenDRIVE 道路网络——但**不支持原生无人机**。 
- **AirSim** (微软): 无人机和汽车模拟，具备基于物理的飞行动力学、空中传感器和多种飞行控制器后端——但**不包含交通管理、行人AI或城市道路网络**。

将它们作为**单独的进程**运行，并进行进程间同步是不切实际的：没有共享的物理引擎，没有共享的渲染引擎，没有坐标系对齐，而且由于复制了 UE4 渲染管线，会造成严重的性能开销。

### 1.2 解决方案

该解决方案将 CARLA 0.9.16 和 AirSim 1.8.1 整合到**一个虚幻引擎进程**中，使得两个 Python API（`carla.Client` 位于 2000 端口，`airsim.MultirotorClient` 位于 41451 端口）能够同时在同一个模拟世界中运行。该系统**无需对面向用户的 Python API 进行任何修改**——现有的 CARLA 和 AirSim 脚本无需修改即可正常工作。

### 1.3 主要贡献

1. **统一游戏模式(GameMode)架构**: 一种新颖的单继承+组合模式（`ASimWorldGameMode`），解决了UE4每个世界只能有一个游戏模式的基本限制。
2. **双 API 服务器共存**: 两个独立的 RPC 服务器（CARLA rpclib + AirSim rpclib）在同一进程内运行于不同的端口。
3. **观察者棋子(Spectator Pawn)解耦**: 一种在满足 CARLA 旁观者要求的同时保留 AirSim 棋子占有模型的技术
4. **全面的空地联动功能**: 超过 220 个 actor 蓝图、超过 16 种传感器类型、14 种天气预设、13 张地图以及基于物理的无人机飞行——所有这些都可同时访问。
5. **离屏数据集生成**: 结合地面和空中视角的无头多模态数据采集

---

## 2. 系统架构

### 2.1 核心挑战：UE4 的单一游戏模式限制

虚幻引擎 4 强制执行一项严格的架构限制：**每个世界（关卡）只能有一个游戏模式**。游戏模式控制着基本的模拟生命周期——玩家生成、游戏规则、比赛状态和初始化顺序。

- CARLA 使用 `ACarlaGameModeBase` 作为其游戏模式，该模式初始化了Episode 系统、天气系统、交通灯管理器、Actor 工厂、记录器和 RPC 服务器。
- AirSim 使用 `AAirSimGameMode` 作为其游戏模式，该模式会初始化 SimHUD、读取 settings.json 文件并生成 SimMode 参与者。


这两种游戏模式无法通过标准的UE4机制**共存**。之前的各种方法（例如，关卡流式传输、仅插件集成）都失败了，因为这两个系统都假定游戏模式关卡(GameMode-level)对模拟生命周期拥有控制权。


### 2.2 解决方案：单一继承 + 组合模式

该解决方案利用了这两个系统之间的架构不对称性：

- CARLA 的子系统（Episode、天气、交通管理器、Actor 工厂）通过继承和友元(`friend`)声明与 `ACarlaGameModeBase` **紧密耦合**。
- AirSim 的模拟逻辑位于 `ASimModeBase` 中，它继承自 `AActor`（而非 `AGameModeBase`），因此可以作为常规世界 Actor 生成。

这里使用统一的 `ASimWorldGameMode` 类：

```
                    UE4 单游戏模式(GameMode)插槽
                            |
                    AGameModeBase (UE4)
                            |
                    ACarlaGameModeBase          ← 通过继承的 CARLA 子系统
                            |
                    ASimWorldGameMode           ← 占用游戏模式(GameMode)插槽
                            |
                            |--- [拥有] ASimModeBase (由 AActor 生成)  ← AirSim 通过组合
                            |              |
                            |              |--- FastPhysicsEngine (333 Hz 异步线程)
                            |              |--- MultirotorRpcLibServer (端口 41451)
                            |              |--- AFlyingPawn (无人机)
                            |              |--- ApiProvider (载具 APIs)
                            |
                            |--- [继承] UCarlaEpisode
                            |--- [继承] AWeather
                            |--- [继承] ACarlaRecorder
                            |--- [继承] ATrafficLightManager
                            |--- [继承] ActorDispatcher + ActorFactories
```

!!! 关键思想
    通过让 `ASimWorldGameMode` **继承**自 `ACarlaGameModeBase`，可以让所有 CARLA 子系统都经历标准的 UE4 生命周期（`InitGame` → `BeginPlay` → `Tick`）。在 CARLA 初始化完成后，AirSim 的 `ASimModeBase` 会在 `BeginPlay` 期间作为**普通 Actor 生成**到游戏世界中。这样就避免了任何插槽冲突，因为 `ASimModeBase` 不会与 GameMode 插槽竞争。

### 2.3 类层次结构

```cpp
// 统一游戏模式 GameMode（在 AirSim 插件模块中，依赖于 Carla 模块）
UCLASS()
class AIRSIM_API ASimWorldGameMode : public ACarlaGameModeBase {
    // CARLA: 继承了 Episode, 天气Weather, 记录器Recorder, ActorFactories, 交通 Traffic
    // AirSim: 包含 SimMode, HUD 空间, 输入绑定
private:
    UPROPERTY() ASimModeBase* SimMode_;        // AirSim 仿真 (生成参与者)
    UPROPERTY() USimHUDWidget* AirSimWidget_;  // 调试叠加层
    TSubclassOf<ASimModeBase> SimModeClass_;   // 来自 settings.json
};
```

### 2.4 初始化序列

```
UE4 引擎开始
│
├── ASimWorldGameMode 构造函数
│   ├── ACarlaGameModeBase() → 创建 Episode, Recorder
│   ├── DefaultPawnClass = nullptr  ← 对 AirSim 至关重要
│   ├── 加载 BP_Weather 蓝图类
│   ├── 注册 8 个参与者工厂 (5 个 C++ 和 3 个蓝图)
│   │   ├── ASensorFactory, AStaticMeshFactory, ATriggerFactory
│   │   ├── AUtilActorFactory, AAIControllerFactory
│   │   ├── BP VehicleFactory, WalkerFactory, PropFactory
│   └── 初始化 AirSim logger 和 ImageWrapper 模块
│
├── ACarlaGameModeBase::InitGame()
│   ├── 生成 Weather 参与者 (从 BP_Weather)
│   ├── 使用 Episode 生成并注册所有 ActorFactories
│   ├── 解析 OpenDRIVE 路网 (.xodr)
│   ├── 根据道路拓扑结构生成生成点
│   └── 初始化 CarlaGameInstance → FCarlaEngine → 开始 CARLA RPC (port 2000)
│
├── ASimWorldGameMode::BeginPlay()
│   ├── 阶段 1: ACarlaGameModeBase::BeginPlay()
│   │   ├── 对世界所有参与者进行语义标记
│   │   ├── 交通灯管理器初始化
│   │   ├── Episode::InitializeAtBeginPlay()
│   │   ├── 应用默认天气参数
│   │   ├── 开始记录器/重放器(Recorder/Replayer)
│   │   └── 注册环境对象
│   │
│   ├── 阶段 2: 创建观察者棋子
│   │   ├── 生成 ASpectatorPawn (未占有)
│   │   ├── 注册成为 Episode->Spectator (友元访问权限)
│   │   └── 在 ActorDispatcher 注册表中注册
│   │
│   └── 阶段 3: AirSim Bootstrap
│       ├── InitializeAirSimSettings() → 读取配置文件 settings.json
│       ├── SetUnrealEngineSettings() → 禁用运动模糊，自定义景深
│       ├── CreateSimMode() → SpawnActor<ASimModeWorldMultiRotor>()
│       │   └── ASimModeBase::BeginPlay()
│       │       ├── NED 坐标系设置
│       │       ├── 创建 ApiProvider 和 WorldSimApi
│       │       ├── 生成 BP_FlyingPawn (无人机棋子)
│       │       ├── 创建 MultirotorPawnSimApi
│       │       │   ├── MultiRotorPhysicsBody (4 个旋翼 + 6 阻力面)
│       │       │   ├── SimpleFlight 控制器
│       │       │   └── 传感器: IMU, Barometer, GPS, Magnetometer
│       │       ├── 创建 FastPhysicsEngine
│       │       └──以 333 赫兹开始异步物理线程
│       ├── CreateAirSimWidget() → UMG 调试覆盖
│       ├── SetupAirSimInputBindings()
│       └── SimMode_->startApiServer() → 端口 41451
│
└── 两个API均已准备就绪
    ├── Carla Python API 在端口 2000 上运行
    └── AirSim Python API 在端口 41451 上运行
```

### 2.5 观察者棋子问题

在 AirSim 中，**必须**将 `DefaultPawnClass` 设置为 `nullptr`，因为 UE4 的默认行为是自动生成并拥有一个玩家控制器控制的棋子。如果任一一个棋子被控制，AirSim 的 `SimpleFlightApi` 输入管道就会中断，那么无人机将无法接收控制命令。

但是，Carla 希望 `Episode->Spectator` 指向一个有效的棋子（用于相机控制、场景观察，以及作为 Python API 的 `world.get_spectator()` 返回值）。

**解决方案**：生成一个观察者棋子(`ASpectatorPawn`)对象，但**不拥有它的控制权**。它作为一个“孤儿” 棋子存在（Carla 的 API 可以访问它），但 UE4 的玩家控制器系统无法访问它。我们使用 C++ 友元类(`friend class`)声明直接设置 `Episode->Spectator`（一个私有成员），绕过了 Carla 的正常初始化流程。

```cpp
// 在 ASimWorldGameMode::BeginPlay() 中，在 Super::BeginPlay() 之后
FActorSpawnParameters SpawnParams;
SpawnParams.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
ASpectatorPawn* Spectator = GetWorld()->SpawnActor<ASpectatorPawn>(
    ASpectatorPawn::StaticClass(), &SpawnTransform, SpawnParams);
// 不要调用 PlayerController->Possess(Spectator)
Episode->Spectator = Spectator;  // 直接友元访问
Episode->ActorDispatcher->GetActorRegistry().Register(
    FCarlaActor::IdType(Spectator->GetUniqueID()), *Spectator);
```

### 2.6 构建系统集成

这两个插件是作为同一个UE4项目的一部分编译的：

```
CarlaUE4.uproject
├── Plugins/Carla/    (LoadingPhase: PostConfigInit)
│   └── Carla.Build.cs  → libcarla_server.a, librpc.a
└── Plugins/AirSim/   (LoadingPhase: PreDefault)
    └── AirSim.Build.cs → PrivateDependency: "Carla"
                         → AirLib (header-only), rpclib, Eigen3, MavLinkCom
```

**单向依赖关系**（AirSim 依赖 Carla：AirSim → Carla）至关重要：`AirSim.Build.cs` 声明了 `PrivateDependencyModuleNames.Add("Carla")`，允许 `SimWorldGameMode.cpp` 包含 Carla 头文件。反向依赖关系不存在，即 Carla 的代码无法识别 AirSim。Carla 源代码仅做了两处修改：

1. `CarlaGameModeBase.h`: `WeatherClass` 和 `ActorFactories` 从私有的成员 `private` 更改为受保护的成员 `protected`
2. `CarlaEpisode.h`: 添加 `friend class ASimWorldGameMode`


### 2.7 配置

**`Unreal/CarlaUE4/Config/DefaultEngine.ini`** (关键条目):
```ini
GlobalDefaultGameMode=/Script/AirSim.SimWorldGameMode
GameInstanceClass=/Script/Carla.CarlaGameInstance
TransitionMap=/AirSim/AirSimAssets
r.CustomDepth=3           ; 语义分割所需
bEnableEnhancedDeterminism=True
```

**`Unreal/CarlaUE4/Config/DefaultGame.ini`** (packaging):
```ini
; 13 CARLA maps + AirSim asset map
+MapsToCook=(FilePath="/Game/Carla/Maps/Town01")
+MapsToCook=(FilePath="/AirSim/AirSimAssets")
; 6 AirSim content directories for cooking
+DirectoriesToAlwaysCook=(Path="AirSim/Blueprints")
+DirectoriesToAlwaysCook=(Path="AirSim/Models")
+DirectoriesToAlwaysCook=(Path="AirSim/Weather")
```

**`~/Documents/AirSim/settings.json`** (runtime):
```json
{
    "SettingsVersion": 1.2,
    "SimMode": "Multirotor",
    "Vehicles": {
        "SimpleFlight": {
            "VehicleType": "SimpleFlight",
            "AutoCreate": true,
            "Cameras": {
                "0": { "CaptureSettings": [{"ImageType": 0, "Width": 1280, "Height": 960}] }
            }
        }
    }
}
```

---

## 3. Dual Communication Architecture

### 3.1 CARLA Server (Port 2000)

CARLA uses a **three-port architecture**:

| Port | Protocol | Purpose |
|------|----------|---------|
| 2000 | rpclib (MessagePack-RPC) | Synchronous commands: spawn, destroy, weather, tick |
| 2001 | TCP streaming | High-throughput sensor data (camera images, LiDAR) |
| 2002 | TCP secondary | Multi-GPU synchronization |

**RPC binding pattern**: Operations that modify UE4 state are **sync-bound** to the game thread via `boost::asio::io_context` post-and-wait. Read-only operations are **async-bound** to RPC worker threads.

**Sensor data pipeline**:
1. Sensor captures data during UE4 tick (game thread)
2. `FPixelReader::SendPixelsInRenderThread()` enqueues a render command
3. GPU pixels are read via `FRHICommandListImmediate`
4. Data is serialized through `SensorRegistry::Serialize()` (type-dispatched)
5. Sent via dedicated TCP stream (each sensor has a unique stream token)

### 3.2 AirSim Server (Port 41451)

AirSim uses a **single-port RPC architecture** via rpclib:

| Port | Protocol | Purpose |
|------|----------|---------|
| 41451 | rpclib (MessagePack-RPC) | All commands: flight control, image capture, sensor queries |

**Image capture**: Unlike CARLA's streaming model, AirSim images are requested on-demand through RPC calls (`simGetImages`). The server reads the UE4 render target synchronously and returns raw pixel data in the RPC response.

**Physics thread interaction**: Flight commands (e.g., `moveToPositionAsync`) are posted to AirSim's internal command queue. The `FastPhysicsEngine` running on a dedicated async thread at 333 Hz reads commands and updates the physics state. The RPC server reads back state on demand.

### 3.3 Coexistence

Both RPC servers run within the same process, sharing the UE4 world. They do not interfere because:
- They bind to different ports (2000 vs 41451)
- They use independent rpclib server instances
- Game-thread operations are serialized naturally by UE4's single-threaded game loop
- AirSim's async physics thread operates on its own kinematic state, reading UE4 collision geometry but not modifying CARLA actors

---

## 4. Sensor Systems

### 4.1 CARLA Ground Sensors (10 types)

CARLA provides a comprehensive ground-vehicle sensor suite, all spawnable as actors attached to any vehicle:

| Sensor | Class Hierarchy | Data Format | Key Parameters |
|--------|----------------|-------------|----------------|
| RGB Camera | `ASceneCaptureCamera` : `ASceneCaptureSensor` : `ASensor` | BGRA uint8 | Resolution, FOV, lens distortion |
| Depth Camera | `ADepthCamera` : `AShaderBasedSensor` : `ASceneCaptureSensor` | Encoded R+G×256+B×65536, normalized to meters | Same as RGB |
| Semantic Segmentation | `ASemanticSegmentationCamera` : `AShaderBasedSensor` | Label index in R channel (20+ CityScapes-compatible classes) | Same as RGB |
| Instance Segmentation | `AInstanceSegmentationCamera` : `AShaderBasedSensor` | Per-instance unique color | Same as RGB |
| LiDAR | `ARayCastLidar` : `ARayCastSemanticLidar` : `ASensor` | float32 [x, y, z, intensity] per point | Channels (16-128), range, points/sec, rotation freq |
| Radar | `ARadar` : `ASensor` | Per-detection: azimuth, altitude, depth, velocity | H-FOV, V-FOV, range, points/sec |
| IMU | `AInertialMeasurementUnit` : `ASensor` | Accelerometer (3D), gyroscope (3D), compass | Noise std dev, bias |
| GNSS | `AGnssSensor` : `ASensor` | Latitude, longitude, altitude | Noise deviation |
| Collision | `ACollisionSensor` : `ASensor` | Event-driven: other actor, impulse | -- |
| Lane Invasion | `ALaneInvasionSensor` : `ASensor` | Event-driven: crossed lane markings | -- |

**Shader-based rendering**: Depth, segmentation, normals, and optical flow cameras apply post-process materials to UE4's scene capture pipeline. Materials write to the G-buffer channels, which are then read back as pixel data. This achieves pixel-perfect alignment with RGB images at negligible additional rendering cost.

**LiDAR implementation**: Uses UE4 `LineTraceSingleByChannel` for ray-casting. Points are generated in a rotating pattern matching real LiDAR scan patterns. Intensity is computed via an attenuation model: `α × I₀ + β`, where I₀ depends on hit distance and material reflectivity. Supports atmospheric attenuation for rain/fog conditions.

### 4.2 AirSim Aerial Sensors (6 types)

| Sensor | Implementation | Data Format | Noise Model |
|--------|---------------|-------------|-------------|
| RGB Camera | `APIPCamera` + `USceneCaptureComponent2D` | uint8 BGRA | -- |
| Depth Camera | Post-process material on same component | float32 (meters) or uint8 (visualization) | -- |
| Segmentation | Post-process material on same component | uint8 label colors | -- |
| IMU | `ImuSimple` (AirLib) | Accelerometer, gyroscope, compass | Angle Random Walk, Velocity Random Walk, Gaussian-Markov bias drift |
| GPS | `GpsSimple` (AirLib) | Lat, lon, alt, velocity | EPH/EPV convergence filter, update rate limiting, latency |
| Barometer | `BarometerSimple` (AirLib) | Altitude (m), pressure (Pa) | Gaussian-Markov drift (~10m/hr), uncorrelated noise (~0.2m σ) |
| Magnetometer | `MagnetometerSimple` (AirLib) | Body-frame magnetic field (3D) | Gaussian noise + uniform bias |

**Camera system**: Each drone has 5 camera mount points (front_center, front_right, front_left, bottom_center, back_center). Each mount creates multiple `USceneCaptureComponent2D` instances for different image types. Images are captured on-demand through the RPC API. Default resolution: 1280×960.

**Sensor noise models**: AirSim implements physically-motivated noise models based on Oliver Woodman's "An introduction to inertial navigation" (Cambridge TR-696):
- **IMU**: ARW (angle random walk) for gyroscope drift, VRW (velocity random walk) for accelerometer bias, with configurable turn-on bias
- **GPS**: First-order low-pass filter for horizontal/vertical position error convergence, simulating cold-start behavior
- **Barometer**: Gaussian-Markov process for slow pressure drift, plus high-frequency measurement noise

### 4.3 Combined Sensor Capabilities

In SimWorld, **all 16 sensor types can operate simultaneously**:

| Perspective | Sensors Available | Total Streams |
|-------------|-------------------|---------------|
| Ground Vehicle | RGB, Depth, Segmentation, Instance Seg, LiDAR, Radar, IMU, GNSS, Collision, Lane Invasion | 10 |
| Aerial Drone | RGB, Depth, Segmentation, Infrared, IMU, GPS, Barometer, Magnetometer | 8 |
| **Combined** | **All of the above, synchronized to the same world state** | **18** |

This is a unique capability -- no other simulator provides synchronized ground + aerial multi-modal sensor data in a single rendering pass.

---

## 5. Physics and Flight Dynamics

### 5.1 Ground Vehicle Physics

CARLA uses UE4's native PhysX vehicle physics (`AWheeledVehicle`):
- 4-wheel (standard cars) and N-wheel (trucks, buses) configurations
- Torque curve, steering curve, mass, drag, center of mass tuning
- Ackermann steering model with PID controller
- Integration with Project Chrono for higher-fidelity tire models (optional)

### 5.2 Drone Flight Dynamics (FastPhysicsEngine)

AirSim implements a **custom rigid-body dynamics engine** running on a dedicated async thread at 333 Hz:

**Integration**: Second-order Verlet method for both linear and angular motion:
```
v(t+dt) = v(t) + a(t) × dt
x(t+dt) = x(t) + v(t+dt) × dt
```

**Force model**: Each rotor contributes a thrust force vector and torque. Total wrench is the sum over 4 rotors. Aerodynamic drag uses a 6-face box model with velocity-squared dependence:
```
F_drag = -0.5 × ρ × Cd × A × |v_rel|² × v̂_rel
```
where `v_rel` accounts for wind.

**Collision response**: Impulse-based method with Coulomb friction:
```
j = -(1 + e) × (v · n) / (1/m + ((I⁻¹(r × n)) × r) · n)
```
Ground lock prevents micro-bouncing on landing surfaces.

**Flight controllers**:
- **SimpleFlight** (default): Built-in PID controller for position, velocity, and attitude control. Runs within AirLib, no external dependencies.
- **PX4** (optional): Software-in-the-loop with PX4 Autopilot via MAVLink
- **ArduPilot** (optional): SITL integration

### 5.3 Coordinate Systems

| System | Convention | Origin | Units |
|--------|-----------|--------|-------|
| UE4 / CARLA | Left-handed, Z-up | Map origin (0, 0, 0) | Centimeters (internally), meters (API) |
| AirSim | NED (North-East-Down) | PlayerStart location | Meters |

**Coordinate mapping**: AirSim creates a `NedTransform` at BeginPlay that maps between UE4 world coordinates and the NED frame anchored at the drone's spawn point. For drone-follows-car applications, we use a **relative offset method**:
1. Record initial CARLA car position `(cx₀, cy₀)` and AirSim drone NED position `(dx₀, dy₀)`
2. Per frame: `Δ = (cx - cx₀, cy - cy₀)`, target drone NED = `(dx₀ + Δx, dy₀ + Δy, -altitude)`

---

## 6. Traffic and Environment

### 6.1 Traffic Manager

CARLA's Traffic Manager is a **client-side pipeline architecture** running on a dedicated thread:

| Stage | Function |
|-------|----------|
| ALSM | Actor Lifecycle and State Management -- syncs simulation state |
| Localization | Waypoint horizon maintenance, lane change decisions |
| Collision | Polygon-based collision prediction (boost::geometry) |
| Traffic Light | Signal compliance logic |
| Motion Plan | PID controller: separate urban/highway parameters |
| Vehicle Light | Automatic headlight/brake light management |

The TM maintains an **InMemoryMap** (cached waypoint graph) for O(1) spatial queries and a **SimulationState** tracking all managed actors' kinematics.

### 6.2 Weather System

15 continuous parameters controlling atmospheric conditions:

| Parameter | Range | Effect |
|-----------|-------|--------|
| Cloudiness | 0-100 | Cloud cover density |
| Precipitation | 0-100 | Rain intensity |
| PrecipitationDeposits | 0-100 | Water puddle accumulation |
| WindIntensity | 0-100 | Wind speed |
| SunAzimuthAngle | 0-360 | Sun horizontal angle |
| SunAltitudeAngle | -90 to 90 | Sun elevation (negative = night) |
| FogDensity | 0-100 | Volumetric fog thickness |
| FogDistance | 0+ | Fog start distance (m) |
| Wetness | 0-100 | Surface wetness (reflections) |
| DustStorm | 0-100 | Dust/sandstorm intensity |

14 named presets covering day/night, clear/cloudy/rain/storm conditions. Weather affects **both** CARLA rendering and AirSim's aerial views simultaneously.

### 6.3 Maps and Road Networks

| Map | Description | Spawn Points | Area |
|-----|-------------|--------------|------|
| Town01 | Small town, T-junctions | 252 | ~1 km² |
| Town02 | Residential area | ~100 | ~0.5 km² |
| Town03 | Urban downtown, highway ramp | 265 | ~2 km² |
| Town04 | Highway with small town | ~300 | ~5 km² |
| Town05 | Urban grid with multi-lane roads | 302 | ~3 km² |
| Town10HD | HD downtown with detailed buildings | 155 | ~1.5 km² |

Each map includes:
- **OpenDRIVE** (.xodr): Complete road network definition with lane geometry, junctions, signals
- **Navigation mesh**: Recast-generated pedestrian walkable areas
- **Traffic infrastructure**: Traffic lights (with timing), stop signs, speed limits
- **Environment objects**: Buildings, vegetation, street furniture (13000+ objects in Town10HD)

---

## 7. Actor System

### 7.1 Actor Blueprint Library

| Category | Count | Examples |
|----------|-------|---------|
| Vehicles | 41 | Tesla Model 3, BMW Gran Tourer, Audi A2, Bus, Truck, Motorcycle, Bicycle |
| Walkers | 52 | Male/female adults, children, with diverse clothing and body types |
| Sensors | 25 | All sensor types listed in Section 4 |
| Props | 99 | Barriers, containers, trash cans, vendor stalls, benches |
| Other | 3 | Controller types |
| **Total** | **220** | |

### 7.2 Actor Spawn Pipeline

```
Python: world.spawn_actor(blueprint, transform)
  → RPC: carla::rpc::Command::SpawnActor
    → FCarlaServer::FPimpl (game thread)
      → UCarlaEpisode::SpawnActorWithInfo()
        → UActorDispatcher::SpawnActor()
          → ACarlaActorFactory::SpawnActor()  (type-specific factory)
            → UWorld::SpawnActor<>()  (UE4 native spawn)
          → FActorRegistry::Register(actor_id, actor)
        → return carla::rpc::Actor (serialized to client)
```

### 7.3 Pedestrian AI Navigation

Walkers use UE4's **Recast navigation mesh** for pathfinding:
- Navigation mesh is pre-built from map geometry
- `AWalkerAIController` provides the Python API interface
- `controller.go_to_location(target)` triggers A* pathfinding on the navmesh
- `controller.set_max_speed(speed)` controls movement speed

---

## 8. Application Domains and Research Capabilities

### 8.1 Autonomous Driving

- Full ego-vehicle sensor suite (RGB, depth, segmentation, LiDAR, radar, IMU, GNSS)
- Traffic Manager with per-vehicle behavioral parameters
- Ackermann steering model with PID controller
- 41 vehicle types across 6+ maps with OpenDRIVE road networks
- Deterministic simulation mode for reproducible experiments

### 8.2 UAV Navigation and Control

- 6-DOF flight control: position, velocity, body-frame velocity, yaw rate, path following
- Physics-based dynamics at 333 Hz with wind and aerodynamic drag
- Multi-camera aerial sensing (5 mount points per drone)
- Configurable flight controllers (SimpleFlight, PX4, ArduPilot)
- Sensor noise models (IMU, GPS, barometer, magnetometer) for realistic perception

### 8.3 Air-Ground Cooperative Systems (Novel)

This is SimWorld's unique research capability:

- **Drone-car tracking**: UAV follows ground vehicles with real-time coordinate translation
- **Aerial traffic monitoring**: Bird's-eye-view vehicle detection and counting
- **Cooperative perception**: Ground-level + aerial sensor fusion datasets
- **Multi-agent coordination**: Multiple CARLA vehicles + AirSim drone in shared scenarios
- **Emergency response**: Aerial scouting + ground navigation in urban environments

### 8.4 Social Navigation

- FPS-style first-person pedestrian control with mouse-look
- 52 pedestrian types with AI-controlled navigation
- Large-scale crowd simulation (50+ vehicles + 20+ pedestrians)
- Pedestrian-vehicle interaction in traffic environments
- Variable weather and lighting conditions

### 8.5 Multi-Modal Dataset Generation

SimWorld enables generating datasets with **unprecedented modality coverage**:

| Modality | Source | Format | Resolution |
|----------|--------|--------|------------|
| Ground RGB | CARLA camera | PNG/JPG | Configurable (up to 4K) |
| Ground Depth | CARLA depth camera | float32 NPY (meters) | Same as RGB |
| Ground Segmentation | CARLA seg camera | uint8 NPY (20+ classes) | Same as RGB |
| Ground Instance Seg | CARLA instance camera | RGB (per-instance) | Same as RGB |
| Ground LiDAR | CARLA ray-cast | float32 NPY (x,y,z,intensity) | 16-128 channels |
| Ground Radar | CARLA radar | float32 (azimuth, depth, velocity) | Configurable |
| Ground IMU | CARLA IMU | JSON (accel, gyro, compass) | 100+ Hz |
| Ground GNSS | CARLA GNSS | JSON (lat, lon, alt) | 10+ Hz |
| Aerial RGB | AirSim camera | PNG/NPY | 1280×960 (configurable) |
| Aerial Depth | AirSim depth | float32 NPY (meters) | 1280×960 |
| Aerial Segmentation | AirSim seg | PNG (label colors) | 1280×960 |
| Aerial IMU | AirSim IMU | JSON (with noise) | 333 Hz |
| Aerial GPS | AirSim GPS | JSON (with convergence) | Configurable |
| Aerial Barometer | AirSim barometer | JSON (altitude, pressure) | Configurable |
| Ego Vehicle Pose | CARLA transform | JSON (x,y,z,pitch,yaw,roll) | Per frame |
| Drone Pose | AirSim kinematics | JSON (NED position, quaternion) | Per frame |

All modalities are **synchronized to the same simulation frame** and share the same world state. The off-screen rendering mode (`-RenderOffScreen`) enables headless operation on GPU servers for large-scale data production.

---

## 9. ROS Integration

SimWorld supports dual ROS2 bridges for integration with robotics stacks:

### 9.1 CARLA ROS Bridge

- Workspace: `carla-ros-bridge` (ROS2 Humble)
- Published topics: `/carla/world_info`, `/carla/status`, `/clock`, per-vehicle sensor topics
- Services: `/carla/spawn_object`, `/carla/destroy_object`, `/carla/get_blueprints`
- Namespace: `/carla/*`

### 9.2 AirSim ROS Wrapper

- Package: `airsim_ros_pkgs` (ROS2 Humble)
- Published topics: `/airsim_node/SimpleFlight/imu/imu`, `/airsim_node/SimpleFlight/front_center/Scene`, GPS, barometer, magnetometer, odometry
- Services: takeoff, land, reset
- Namespace: `/airsim_node/*`

### 9.3 Simultaneous Operation

Both bridges run concurrently under the same ROS master with **zero namespace conflicts** (`/carla/` vs `/airsim_node/`). This enables standard ROS2 tools (rviz2, rosbag2, nav2) to consume both ground and aerial data streams.

---

## 10. Performance Characteristics

### 10.1 System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| GPU | 4 GB VRAM (Vulkan) | 8+ GB VRAM (NVIDIA RTX) |
| RAM | 16 GB | 32 GB |
| CPU | 4 cores | 8+ cores |
| Disk | 20 GB (packaged) | 40 GB (source + build) |
| OS | Ubuntu 18.04+ | Ubuntu 20.04/22.04 |

### 10.2 GPU Memory Usage (Tested on RTX A4000, 16 GB)

| Scenario | VRAM Usage |
|----------|------------|
| Idle (Town10HD loaded) | ~3700 MiB |
| + 3 vehicles + 2 walkers + drone | ~3870 MiB |
| 3-hour continuous operation | ~3878 MiB (stable, no leak) |
| Peak during map loading | ~5000 MiB |

### 10.3 Stability

| Test | Duration | Cycles | Errors | Result |
|------|----------|--------|--------|--------|
| Continuous spawn/destroy + drone | 3 hours | 357 | 0 | PASS |
| Map switching (Town01→03→05) | ~15 min | 3 maps | 0 | PASS |
| 89-item comprehensive API test | ~5 min | 89 tests | 0 | PASS |

### 10.4 Known Limitations

| Limitation | Cause | Workaround |
|-----------|-------|-----------|
| Autopilot vehicles ≤ 10 with drone | AirSim physics ↔ CARLA Traffic Manager quaternion conflict | Limit traffic count or disable autopilot |
| Map switch latency: 2-5 min | Full asset reload in Shipping build | Use API with 300s timeout |
| Single drone instance | AirSim settings.json limitation | Configurable for multi-drone |

---

## 11. Build and Deployment

### 11.1 Compilation

```bash
# Module-level compilation (avoids features.h cross-compile error)
export UE4_ROOT=/path/to/UnrealEngine-4.26
${UE4_ROOT}/Engine/Build/BatchFiles/Linux/Build.sh CarlaUE4Editor Linux Development \
    -project="/path/to/CarlaUE4.uproject" -module=Carla    # ~290s
${UE4_ROOT}/Engine/Build/BatchFiles/Linux/Build.sh CarlaUE4Editor Linux Development \
    -project="/path/to/CarlaUE4.uproject" -module=AirSim   # ~100s
```

### 11.2 Packaging

```bash
./Util/BuildTools/Package.sh --config=Shipping --no-zip
# Output: Dist/CARLA_Shipping_<version>/LinuxNoEditor/ (~19 GB)
# Compile: ~800s (656 units), Cook: ~2h (13459 packages)
```

### 11.3 Distribution

Packaged build: **7.3 GB** compressed (excluding debug symbols), containing:
- Shipping binary for Linux x86_64
- 13 cooked maps + AirSim assets
- 17 example Python scripts
- CARLA PythonAPI source
- AirSim configuration template

---

## 12. Comparison with Related Work

| Feature | CARLA | AirSim | LGSVL | ISAAC Sim | **SimWorld** |
|---------|-------|--------|-------|-----------|-------------|
| Ground vehicles | ✅ 41 types | ✅ Limited | ✅ | ✅ | ✅ 41 types |
| Pedestrians | ✅ 52 types | ❌ | ✅ | ✅ | ✅ 52 types |
| Drones (physics-based) | ❌ | ✅ | ❌ | ❌ | ✅ |
| Traffic Manager | ✅ | ❌ | ✅ | ❌ | ✅ |
| OpenDRIVE road network | ✅ | ❌ | ✅ | ❌ | ✅ |
| Weather system | ✅ 15 params | ✅ Basic | ✅ | ✅ | ✅ 15 params |
| Ground sensors (10+) | ✅ | ❌ | ✅ | ✅ | ✅ |
| Aerial sensors (6+) | ❌ | ✅ | ❌ | ❌ | ✅ |
| Sensor noise models | Basic | ✅ Detailed | Basic | ✅ | ✅ Detailed |
| ROS integration | ✅ | ✅ | ✅ | ✅ | ✅ Dual bridges |
| Air-ground joint sim | ❌ | ❌ | ❌ | ❌ | ✅ |
| Single-process rendering | N/A | N/A | N/A | N/A | ✅ |
| Open source | ✅ MIT | ✅ MIT | ❌ Discontinued | ❌ Proprietary | ✅ |

**Key differentiator**: SimWorld is the only platform providing physics-based drone flight, comprehensive ground traffic management, and multi-modal synchronized air-ground sensor data in a single rendering process.

---

## 13. Potential Paper Contributions

### For NeurIPS / ICLR Submission

1. **System paper**: Novel architecture solving the single-GameMode constraint for simulator unification
2. **Benchmark paper**: New benchmark for air-ground cooperative perception
3. **Dataset paper**: Large-scale multi-modal dataset with synchronized ground + aerial annotations
4. **Application paper**: Aerial-assisted autonomous driving / social navigation with air-ground data

### Potential Evaluation Experiments

- **Object detection**: Compare detection accuracy using ground-only vs. ground+aerial data
- **Trajectory prediction**: Pedestrian/vehicle trajectory prediction with aerial context
- **Multi-modal fusion**: Sensor fusion benchmarks across 16+ synchronized modalities
- **Sim-to-real transfer**: Domain adaptation from SimWorld synthetic data to real-world datasets
- **Cooperative perception**: Communication-constrained air-ground perception fusion
- **Social navigation**: Pedestrian interaction modeling with drone presence
- **RL-based drone control**: Training drone policies for car-following, surveillance, search tasks

### Comparable Published Work at Top Venues

- **CARLA**: "CARLA: An Open Urban Driving Simulator" (CoRL 2017)
- **AirSim**: "AirSim: High-Fidelity Visual and Physical Simulation for Autonomous Vehicles" (FSR 2017)
- **Habitat**: "Habitat: A Platform for Embodied AI Research" (ICCV 2019)
- **ISAAC Sim**: "Isaac Sim: An Extensible Robotics Simulator" (ICRA 2022)
- **MetaDrive**: "MetaDrive: Composing Diverse Driving Scenarios for Generalizable RL" (TPAMI 2022)

SimWorld fills the gap between driving simulators and aerial simulators, enabling a new class of research at the intersection of autonomous driving, drone navigation, and multi-agent systems.

---

## Appendix A: Complete File Inventory

### Core Architecture Files

| File | Description |
|------|-------------|
| `Plugins/AirSim/Source/SimWorldGameMode.h/.cpp` | Unified GameMode (432 lines) |
| `Plugins/Carla/Source/Carla/Game/CarlaGameModeBase.h/.cpp` | CARLA base GameMode |
| `Plugins/Carla/Source/Carla/Game/CarlaEpisode.h/.cpp` | Episode manager |
| `Plugins/AirSim/Source/SimMode/SimModeBase.h/.cpp` | AirSim simulation mode |
| `Plugins/AirSim/Source/AirSim.Build.cs` | Build config (Carla dependency) |
| `Config/DefaultEngine.ini` | GameMode registration |
| `Config/DefaultGame.ini` | Packaging config |

### CARLA Sensor Files

| File | Sensor |
|------|--------|
| `Sensor/SceneCaptureCamera.h/.cpp` | RGB Camera |
| `Sensor/DepthCamera.h/.cpp` | Depth Camera |
| `Sensor/SemanticSegmentationCamera.h/.cpp` | Semantic Segmentation |
| `Sensor/InstanceSegmentationCamera.h/.cpp` | Instance Segmentation |
| `Sensor/RayCastLidar.h/.cpp` | LiDAR |
| `Sensor/Radar.h/.cpp` | Radar |
| `Sensor/InertialMeasurementUnit.h/.cpp` | IMU |
| `Sensor/GnssSensor.h/.cpp` | GNSS |

### AirSim Core Files

| File | Component |
|------|-----------|
| `Vehicles/Multirotor/FlyingPawn.h/.cpp` | Drone pawn |
| `Vehicles/Multirotor/MultirotorPawnSimApi.h/.cpp` | Drone API wrapper |
| `Vehicles/Multirotor/SimModeWorldMultiRotor.h/.cpp` | Multirotor sim mode |
| `AirLib/include/physics/FastPhysicsEngine.hpp` | Drone physics |
| `AirLib/include/vehicles/multirotor/MultiRotorPhysicsBody.hpp` | Rigid body model |
| `AirLib/include/vehicles/multirotor/api/MultirotorRpcLibServer.hpp` | API server |
| `AirLib/include/sensors/imu/ImuSimple.hpp` | IMU with noise |
| `AirLib/include/sensors/gps/GpsSimple.hpp` | GPS with noise |
| `AirLib/include/sensors/barometer/BarometerSimple.hpp` | Barometer with noise |

## Appendix B: Python API Quick Reference

### CARLA API (port 2000)
```python
import carla
client = carla.Client('localhost', 2000)
world = client.get_world()

# Environment
world.set_weather(carla.WeatherParameters.ClearNoon)
world.get_map().get_spawn_points()

# Actors
bp = world.get_blueprint_library().find('vehicle.tesla.model3')
vehicle = world.spawn_actor(bp, spawn_point)
vehicle.set_autopilot(True)

# Sensors
cam_bp = world.get_blueprint_library().find('sensor.camera.rgb')
camera = world.spawn_actor(cam_bp, transform, attach_to=vehicle)
camera.listen(lambda image: process(image))
```

### AirSim API (port 41451)
```python
import airsim
client = airsim.MultirotorClient(port=41451)
client.confirmConnection()
client.enableApiControl(True)
client.armDisarm(True)

# Flight
client.takeoffAsync().join()
client.moveToPositionAsync(x, y, z, speed).join()
client.moveByVelocityAsync(vx, vy, vz, duration).join()

# Sensors
responses = client.simGetImages([
    airsim.ImageRequest("0", airsim.ImageType.Scene, False, False),
    airsim.ImageRequest("0", airsim.ImageType.DepthPerspective, True),
    airsim.ImageRequest("0", airsim.ImageType.Segmentation, False, False),
])
imu = client.getImuData()
gps = client.getGpsData()
```

### Combined Usage
```python
import carla, airsim, threading

# Both APIs on the same world
carla_client = carla.Client('localhost', 2000)
air_client = airsim.MultirotorClient(port=41451)

# Spawn CARLA traffic while flying AirSim drone
world = carla_client.get_world()
vehicle = world.spawn_actor(vehicle_bp, spawn_point)
vehicle.set_autopilot(True)

air_client.takeoffAsync().join()
air_client.moveToZAsync(-30, 5).join()  # 30m altitude

# Collect synchronized ground + aerial data
ground_image = carla_camera.listen(callback)
aerial_images = air_client.simGetImages([...])
```
