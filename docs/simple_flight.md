# simple_flight

如果您不知道飞行控制器的作用，请参阅 [什么是飞行控制器](flight_controller.md) 。
 
AirSim 内置一个名为 [simple_flight](https://marekcel.pl/mscsim) 的飞行控制器，默认使用。您无需进行任何操作即可使用或配置它。AirSim 还支持 [PX4](px4_setup.md) 作为高级用户的另一种飞行控制器。未来，我们还计划支持 [ROSFlight](https://rosflight.org/) 和 [Hackflight](https://github.com/simondlevy/hackflight)。


## 优势

使用 simple_flight 的优势在于您无需进行任何额外设置，它就能“直接运行”。此外，simple_flight 使用步进时钟，这意味着您可以暂停模拟，并且不会受到操作系统提供的高方差低精度时钟的影响。此外，simple_flight 简单易用、跨平台，并且 100% 由头文件无依赖的 C++ 代码组成，这意味着您可以在同一个代码库中在模拟器和飞行控制器代码之间切换！

## 设计

通常，飞行控制器设计用于在实际的飞行器硬件上运行，而它们对模拟器的支持差异很大。对于非专业用户来说，配置起来通常相当困难，而且通常构建复杂，缺乏跨平台支持。所有这些问题在 simple_flight 的设计中都发挥了重要作用。


simple_flight 从一开始就被设计成一个库，它拥有简洁的接口，可以在飞行器和模拟器中运行。其核心原则是，飞行控制器无法指定特殊的模拟模式，因此无法判断它是作为模拟运行还是作为真实飞行器运行。因此，我们将飞行控制器简单地视为打包在库中的一组算法。另一个重点是将此代码开发为无依赖、仅包含头文件的纯标准 C++11 代码。这意味着编译 simple_flight 无需任何特殊构建。您只需将其源代码复制到任何您想要的项目中，它就可以运行。


## 控制

simple_flight 可以通过接收角速率、角度、速度或位置等所需输入来控制飞行器。每个控制轴都可以使用其中一种模式指定。在内部，simple_flight 使用级联 PID 控制器来最终生成执行器信号。这意味着位置 PID 驱动速度 PID，速度 PID 又驱动角度 PID，角度 PID 最终驱动角速率 PID。


## 状态估计

在当前版本中，我们使用来自模拟器的真实值进行状态估计。我们计划在不久的将来添加一个基于滤波器的免费状态估计器，用于使用两个传感器（陀螺仪和加速度计）进行角速度和方向估计。从长远来看，我们计划集成另一个库，使用 4 个传感器（陀螺仪、加速度计、磁力计和气压计）并结合扩展卡尔曼滤波器 (EKF) 进行速度和位置估计。如果您在这方面有经验，我们鼓励您与我们互动并做出贡献！

## 支持的主板

目前，我们已经为模拟板实现了 simple_flight 接口。我们计划将其实现到 Pixhawk V2 板，甚至可能实现到 Naze32 板。我们预计所有代码将保持不变，实现主要包括为各种传感器添加驱动程序、处理 ISR 以及管理其他板级相关细节。如果您在这方面有经验，我们鼓励您与我们互动并做出贡献！


## 配置

要让 AirSim 使用 simple_flight，您可以在 [settings.json](settings.md) 中指定它，如下所示。请注意，这是默认设置，因此您无需明确指定。


```
"Vehicles": {
    "SimpleFlight": {
      "VehicleType": "SimpleFlight",
    }
}
```

默认情况下，使用 simple_flight 的飞行器已经处于武装状态，因此你会看到它的螺旋桨在旋转。但是，如果你不想这样，可以将 `DefaultVehicleState` 设置为 `Inactive`，如下所示：


```
"Vehicles": {
    "SimpleFlight": {
      "VehicleType": "SimpleFlight",
      "DefaultVehicleState": "Inactive"
    }
}
```

在这种情况下，您需要手动将遥控摇杆向下向内放置，或使用 API 进行解锁。


出于安全考虑，飞行控制器不允许 API 控制，除非操作员已通过遥控上的开关同意使用 API。此外，当遥控失去控制时，出于安全考虑，飞行器应禁用 API 控制并进入悬停模式。为了简化操作，simple_flight 默认启用 API 控制，无需操作员同意，即使遥控未被检测到，也无需人工干预。不过，您可以使用以下设置更改此设置：

```
"Vehicles": {
    "SimpleFlight": {
      "VehicleType": "SimpleFlight",

      "AllowAPIAlways": true,
      "RC": {
        "RemoteControlID": 0,      
        "AllowAPIWhenDisconnected": true
      }
    }
}
```

最后，simple_flight 默认使用步进时钟，这意味着当模拟器发出指令时，时钟会前进（不像挂钟那样严格按照时间的推移前进）。这意味着时钟可以暂停，例如，当代码遇到断点且时钟的方差为零时（除非是“实时”操作系统，否则操作系统提供的时钟 API 可能会有显著的方差）。如果您希望 simple_flight 使用挂钟，请使用以下设置：

```
  "ClockType": "ScalableClock"
```
