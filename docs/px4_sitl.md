# 设置 PX4 软件在环

[PX4](http://dev.px4.io) 软件提供了其堆栈的“软件在环”仿真 (software-in-loop, SITL) 版本，可在 Linux 上运行。如果您使用的是 Windows，则可以使用 [Cygwin 工具链](https://dev.px4.io/master/en/setup/dev_env_windows_cygwin.html) ，或者您可以使用适用于 [Linux 的 Windows 子系统](https://docs.microsoft.com/en-us/windows/wsl/install-win10) 并按照 PX4 Linux 工具链的设置进行操作。

如果您使用的是 WSL2，请阅读这些 [附加说明](px4_sitl_wsl2.md) 。


**请注意** ，每次停止虚幻应用程序时，都必须重新启动 px4 应用程序。

1. 在您的 Bash 终端上，按照 [Linux 系统的步骤操作](https://docs.px4.io/master/en/dev_setup/dev_env_linux.html) ，并按照 `基于 NuttX 的硬件下` 的所有说明安装必备组件。我们还附上​​了我们自己的 [PX4 构建说明](px4_build.md) ，它更简洁地说明了我们的具体需求。 

2. 获取 PX4 源代码并构建 PX4 的 posix SITL 版本：
    ```
    mkdir -p PX4
    cd PX4
    git clone https://github.com/PX4/PX4-Autopilot.git --recursive
    bash ./PX4-Autopilot/Tools/setup/ubuntu.sh --no-nuttx --no-sim-tools
    cd PX4-Autopilot
    ```
    从 [https://github.com/PX4/PX4-Autopilot/releases](https://github.com/PX4/PX4-Autopilot/releases) 找到最新的稳定版本，并检出与该版本匹配的源代码，例如：
    ```
    git checkout v1.11.3
    ```

3. 使用以下命令在 SITL 模式下构建并启动 PX4 固件：
    ```
    make px4_sitl_default none_iris
    ```
   如果您使用的是旧版本 v1.8.*，请改用以下命令：`make posix_sitl_ekf2 none_iris`。 

4. 您应该会看到一条消息，提示 SITL PX4 应用正在等待模拟器 (AirSim) 连接。您还会看到有关为 PX4 应用的 MAVLink 连接配置了哪些端口的信息。默认端口最近有所更改，因此请仔细检查以确保 AirSim 设置正确。
    ```
    INFO  [simulator] Waiting for simulator to connect on TCP port 4560
    INFO  [init] Mixer: etc/mixers/quad_w.main.mix on /dev/pwm_output0
    INFO  [mavlink] mode: Normal, data rate: 4000000 B/s on udp port 14570 remote port 14550
    INFO  [mavlink] mode: Onboard, data rate: 4000000 B/s on udp port 14580 remote port 14540
    ```

    注意：这也是一个交互式 PX4 控制台，输入 `help` 可查看可在此处输入的命令列表。这些命令大多是底层 PX4 命令，但其中一些可用于调试。

5. 现在编辑 [AirSim 设置](settings.md) 文件，确保 UDP 和 TCP 端口设置匹配：
    ```json
    {
        "SettingsVersion": 1.2,
        "SimMode": "Multirotor",
        "ClockType": "SteppableClock",
        "Vehicles": {
            "PX4": {
                "VehicleType": "PX4Multirotor",
                "UseSerial": false,
                "LockStep": true,
                "UseTcp": true,
                "TcpPort": 4560,
                "ControlPortLocal": 14540,
                "ControlPortRemote": 14580,
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
    请注意，PX4 `[simulator]` 使用的是 TCP 协议，因此我们需要添加`"UseTcp": true,`。另外，我们还启用了 `LockStep` 功能，更多信息请参阅 [PX4 LockStep](px4_lockstep.md) 文档。气压计设置能够让 PX4 正常工作，因为 AirSim 默认的气压计会产生过多的噪声。此设置可以稍微降低噪声，从而使 PX4 更快地锁定 GPS 信号。

6. 使用防火墙配置打开入站 TCP 端口 4560 和入站 UDP 端口 14540。

7. 现在运行你的 Unreal AirSim 环境，它应该会通过 TCP 连接到 SITL PX4。你应该会在 SITL PX4 窗口中看到一系列消息。具体来说，以下消息会告诉你 AirSim 已正确连接，并且 GPS 融合稳定：
    ```
    INFO  [simulator] Simulator connected on UDP port 14560
    INFO  [mavlink] partner IP: 127.0.0.1
    INFO  [ecl/EKF] EKF GPS checks passed (WGS-84 origin set)
    INFO  [ecl/EKF] EKF commencing GPS fusion
    ```

    如果您没有看到这些消息，请检查您的端口设置。

8. 您应该也可以在 SITL 模式下使用 QGroundControl。请确保没有插入 Pixhawk 硬件，否则 QGroundControl 会选择使用它。请注意，由于我们没有实体飞控板，因此无法直接连接遥控器。所以，您可以选择使用 Xbox 360 控制器，或者通过 USB 连接遥控器（例如，FrSky Taranis X9D Plus），或者使用教练 USB 线缆连接到您的电脑。这样，您的遥控器就会像一个虚拟摇杆一样工作。您需要在 QGroundControl 中进行额外的设置才能使用虚拟摇杆进行遥控器控制。除非您计划在 AirSim 中手动操控无人机，否则无需进行此操作。使用 Python API 进行自主飞行不需要遥控器，请参阅下文“无遥控器（`No Remote Control`）”部分。 

## 设置 GPS 原点

请注意，以上设置是在 `settings.json` 文件的 `params` 部分中提供的：
```
    "LPE_LAT": 47.641468,
    "LPE_LON": -122.140165,
```

需要配置 PX4 SITL 模式才能正确获取原点位置。原点位置需要设置为与 [OriginGeopoint](settings.md#origingeopoint) 中定义的坐标相同的坐标。

您也可以在 SITL PX4 控制台窗口中运行以下命令，以检查这些值是否设置正确。

```
param show LPE_LAT
param show LPE_LON
```

## Smooth Offboard Transitions

请注意，上述设置在 `settings.json` 文件的 `params` 部分中提供：
```
    "COM_OBL_ACT": 1
```

这会使无人机在每次完成远程控制指令后自动悬停（默认设置为降落）。悬停可以使多个远程指令之间的过渡更加平滑。您可以通过运行以下 PX4 控制台命令来检查此设置：

```
param show COM_OBL_ACT
```

## 检查主位置

如果您使用 DroneShell 执行命令（解锁、起飞等），则应等待返航位置设置完毕。您将在 PX4 SITL 控制台中看到以下消息输出：

```
INFO  [commander] home: 47.6414680, -122.1401672, 119.99
INFO  [tone_alarm] home_set
```

现在，DroneShell 的“pos”命令应该会报告这个位置，并且 PX4 应该会接受这些命令。如果您尝试在没有返航位置的情况下起飞，您将会看到以下消息：

```
WARN  [commander] Takeoff denied, disarm and re-try
```

设置好归位位置后，检查“pos”命令报告的本地位置：

```
Local position: x=-0.0326988, y=0.00656854, z=5.48506
```

如果 z 坐标值像这样过大，则起飞可能无法按预期进行。重置 SITL 和仿真应该可以解决这个问题。

## WSL 2

适用于 Linux 的 Windows 子系统版本 2 在虚拟机中运行。这需要额外的设置——请参阅 [其他说明](px4_sitl_wsl2.md) 。

## 没有遥控器

请注意，上述设置在 `settings.json` 文件的 `params` 部分中提供：

```
    "NAV_RCL_ACT": 0,
    "NAV_DLL_ACT": 0,
```

如果您计划不使用遥控器，仅通过 Python 脚本等方式操控 SITL 模式的 PX4，则需要进行此设置。这些参数可以防止 PX4 在每次移动指令完成后都触发“安全模式”。您可以使用以下 PX4 命令来检查这些值是否设置正确：

```
param show NAV_RCL_ACT
param show NAV_DLL_ACT
```

!!! 注意
    `请勿`在真正的无人机上进行此操作，因为如果没有这些安全措施，飞行非常危险。


## 手动设置参数

您也可以在 PX4 控制台中运行以下命令来手动设置所有这些参数：

```
param set NAV_RCL_ACT 0
param set NAV_DLL_ACT 0
```

## 建立多载具仿真

您可以使用 AirSim 在 SITL 模式下模拟多架无人机。但是，这需要设置多个 PX4 固件模拟器实例，以便监听每架无人机在独立 TCP 端口（4560、4561 等）上的连接。请参阅 [此专门页面](px4_multi_vehicle.md) ，了解如何在 SITL 模式下设置多个 PX4 实例。


## 使用 VirtualBox Ubuntu

如果您想在 `VirtualBox Ubuntu` 虚拟机中运行上述 posix_sitl 程序，那么它的 IP 地址将与本地主机不同。因此，在这种情况下，您需要编辑 [配置文件](settings.md) ，将 UdpIp 和 SitlIp 更改为虚拟机的 IP 地址，并将 LocalIpAddress 设置为运行虚幻引擎的主机的 IP 地址。

## 遥控器

模拟无人机的操控方式有多种，可以使用遥控器或类似 Xbox 游戏手柄的操纵杆。请参阅 [遥控器](remote_control.md#rc-setup-for-px4) 部分。
