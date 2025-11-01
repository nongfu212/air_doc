# Air 的 PX4 设置

[PX4 软件栈](http://github.com/px4/firmware)是一款开源且非常流行的飞行控制器，支持多种飞控板和传感器，并内置任务规划等高级功能。请访问 [px4.io](http://px4.io) 了解更多信息。

!!! 警告
    虽然所有版本的 AirSim 都经过 PX4 测试以确保兼容性，但设置 PX4 并非易事。除非您至少具备中级 PX4 协议栈的使用经验，否则我们建议您使用 [simple_flight](simple_flight.md) ，它现在是 AirSim 的默认设置。


## 支持的硬件

以下 Pixhawk 硬件已通过 Air 测试：

1. [Pixhawk PX4 2.4.8](http://www.banggood.com/Pixhawk-PX4-2_4_8-Flight-Controller-32-Bit-ARM-PX4FMU-PX4IO-Combo-for-Multicopters-p-1040416.html)
1. [PixFalcon](https://hobbyking.com/en_us/pixfalcon-micro-px4-autopilot.html?___store=en_us)
1. [PixRacer](https://www.banggood.com/Pixracer-Autopilot-Xracer-V1_0-Flight-Controller-Mini-PX4-Built-in-Wifi-For-FPV-Racing-RC-Multirotor-p-1056428.html?utm_source=google&utm_medium=cpc_ods&utm_content=starr&utm_campaign=Smlrfpv-ds-FPVracer&gclid=CjwKEAjw9MrIBRCr2LPek5-h8U0SJAD3jfhtbEfqhX4Lu94kPe88Zrr62A5qVgx-wRDBuUulGzHELRoCRVTw_wcB)
1. [Pixhawk 2.1](http://www.proficnc.com/)
1. [Pixhawk 4 mini from Holybro](https://shop.holybro.com/pixhawk4-mini_p1120.html)
1. [Pixhawk 4 from Holybro](https://shop.holybro.com/pixhawk-4beta-launch_p1089.html)

PX4 固件 1.11.2 版本也适用于 Pixhawk 4 设备。

## 设置 PX4 硬件在环

为此，您需要使用上面列出的支持设备之一。如果要进行手动飞行，您还需要遥控器和发射器。

1. 请确保您的遥控接收器已与遥控发射器配对。将遥控发射器连接到飞控的遥控端口。更多信息请参阅您的遥控器手册和 [PX4文档](https://docs.px4.io/en/getting_started/rc_transmitter_receiver.html) 。
2. 下载 [QGroundControl](http://qgroundcontrol.com/) ，启动它并将你的飞行控制器连接到 USB 端口。
3. 使用 QGroundControl 刷写最新的 PX4 飞行控制器协议栈。另请参阅 [初始固件设置视频](https://docs.px4.io/master/en/config/) 。
4. 在 QGroundControl 中，选择 HIL Quadrocopter X 机架，配置 Pixhawk 以进行 HIL 仿真。PX4 重启后，检查是否已选择“HIL Quadrocopter X”。 
5. 在 QGroundControl 中，转到“无线电(Radio)”选项卡并进行校准（确保遥控器已开启，并且接收器显示绑定指示灯）。 
6. 进入“飞行模式(Flight Mode)”选项卡，选择其中一个遥控器开关作为“模式通道(Mode Channel)”。然后，为该开关的两个位置分别设置（例如）“稳定(Stabilized)飞行模式”和“姿态(Attitude)飞行模式”。 
7. 前往 QGroundControl 的“调校”部分，并设置合适的数值。例如，对于 Fly Sky 的 FS-TH9X 遥控器，以下设置可提供更真实的操控感：悬停油门Throttle = mid+1 mark ，横滚和俯仰灵敏度 = mid-3 mark，高度和位置控制灵敏度 = mid-2 mark。 
8. 在 [Air 设置](settings.md) 文件中，将 PX4 指定为您的载具配置，如下所示： 
```
    {
        "SettingsVersion": 1.2,
        "SimMode": "Multirotor",
        "ClockType": "SteppableClock",
        "Vehicles": {
            "PX4": {
                "VehicleType": "PX4Multirotor",
                "UseSerial": true,
                "LockStep": true,
                "Sensors":{
                    "Barometer":{
                        "SensorType": 1,
                        "Enabled": true,
                        "PressureFactorSigma": 0.0001825
                    }
                },
                "Parameters": {
                    "NAV_RCL_ACT": 0,
                    "NAV_DLL_ACT": 0,
                    "COM_OBL_ACT": 1,
                    "LPE_LAT": 47.641468,
                    "LPE_LON": -122.140165
                }
            }
        }
    }
```

!!! 注意
    PX4`模拟器`使用的是 TCP 协议，因此我们需要添加`"UseTcp": true,`。另外，我们还启用了 `LockStep` 功能，更多信息请参阅 [PX4 LockStep](px4_lockstep.md) 文档。气压计`Barometer`设置能够让 PX4 正常工作，因为 Air 默认的气压计会产生过多的噪声。此设置可以稍微降低噪声，从而使 PX4 更快地锁定 GPS 信号。

完成上述设置后，您应该可以使用遥控器 (Remote Control, RC) 操控 Air 飞行。通常，您可以通过将遥控器的两根摇杆向下并向内拉合来启动飞行器。初始设置完成后，您无需再使用 QGroundControl。通常，稳定 Stabilized 模式（而非手动 Manual 模式）能为初学者提供更好的飞行体验。请参阅 [PX4 基础飞行指南](https://docs.px4.io/master/en/flying/basic_flying.html) 。

您还可以通过 [Python API](apis.md) 控制无人机。


请参阅 [演示视频](https://youtu.be/HNWdYrtw3f0) 和 [Unreal Air 设置视频](https://youtu.be/1oY8Qu5maQQ) ，其中展示了本文档中的所有设置步骤。


## 设置 PX4 软件在环(Software-in-Loop)

PX4 SITL 模式不需要您使用 Pixhawk 或 Pixracer 等单独的设备。事实上，PX4 团队推荐使用这种方式将 PX4 与模拟器配合使用。然而，这种方式的设置确实比较复杂。请参阅 [此专门页面](px4_sitl.md) 了解如何在 SITL 模式下设置 PX4。

## 常见问题解答

#### 无人机飞行不正常，总是“乱飞”。

造成这种情况的原因有很多。首先，请确保无人机在启动模拟器时不会从高处坠落。如果您创建了自定义的引擎环境，并且玩家起始点设置得过高，则可能会出现这种情况。似乎当这种情况发生时，PX4 的内部校准会出错。

您 [还应该使用 QGroundControl](#setting-up-px4-hardware-in-loop) ，并确保您可以在 QGroundControl 中正确解锁和起飞。

最后，在极少数情况下，这也可能是机器性能问题，请检查您的 [硬盘性能](hard_drive.md) 。

#### 我可以使用 Arducopter 或其他 MavLink 实现吗？

我们的代码已使用 [PX4 固件](https://dev.px4.io/) 进行测试。我们尚未测试 Arducopter 或其他 MAVLink 实现。部分飞行 API 会在 MAV_CMD_DO_SET_MODE 消息中使用 PX4 自定义模式（例如 PX4_CUSTOM_MAIN_MODE_AUTO）。

#### 它找不到我的 Pixhawk 硬件

检查 settings.json 文件中是否存在这样一行：`"SerialPort":"*,115200"`。这里的星号表示“查找任何看起来像 Pixhawk 设备的串口”，但这并非适用于所有类型的 Pixhawk 硬件。因此，在 Windows 系统中，您可以使用设备管理器找到实际的 COM 端口，在`Ports (COM & LPT)` 下查找，插入设备并查看显示的新 COM 端口。假设您看到一个名为`USB Serial Port (COM5)`的新端口。那么，请将 SerialPort 设置更改为：`"SerialPort":"COM5,115200"`。


在 Linux 系统中，可以通过运行 `ls /dev/serial/by-id` 命令来查找设备。如果看到类似 `usb-3D_Robotics_PX4_FMU_v2.x_0-if00` 的设备名称，就可以使用该名称进行连接，例如：`SerialPort":"/dev/serial/by-id/usb-3D_Robotics_PX4_FMU_v2.x_0-if00"`。需要注意的是，这个长名称实际上是指向实际名称的符号链接。使用 `ls -l ...` 命令可以找到该符号链接，它通常类似于 `/dev/ttyACM0`，因此也可以使用 `SerialPort":"/dev/ttyACM0,115200"`。但是，这种映射方式与 Windows 类似，它是自动分配的，并且可能会发生变化。而长名称即使在实际的 TTY 串口设备映射发生变化时仍然有效。

#### WARN  [commander] Takeoff denied, disarm and re-try

如果 PX4 尚未计算出返航位置，您就尝试起飞，就会发生这种情况。PX4 会在接收到 GPS 信号后报告返航位置，届时您将看到以下消息：

```
INFO  [commander] home: 47.6414680, -122.1401672, 119.99
INFO  [tone_alarm] home_set
```

但在此之前，PX4 仍会拒绝起飞指令。

#### 当我发出指令让无人机执行某项任务时，它总是会降落。

例如，您使用命令 `DroneShell moveToPosition -z -20 -x 50 -y 0`，程序会执行该命令，但当无人机到达目标位置时，它却开始降落。这是 PX4 在离线模式完成后默认的行为。要让无人机悬停，请设置以下 PX4 参数：

```
param set COM_OBL_ACT 1
```

#### 我收到消息长度不匹配的错误。

您可能需要在 QGC 中将 MAV_PROTO_VER 参数设置为“始终使用版本 1(`Always use version 1`)”。请参阅 [此问题](https://github.com/Microsoft/AirSim/issues/546) 了解更多详情。
