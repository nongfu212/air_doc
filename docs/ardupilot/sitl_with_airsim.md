# [将 SITL 与 Air 结合使用](https://ardupilot.org/dev/docs/sitl-with-airsim.html)

目前，AirSim 和 ArduPilot 已经开发出对直升机和 Rover 的支持。

该集成方案已在单台 Linux 机器和多台运行 Ubuntu 16.04 和 18.04 的机器上进行了测试，也测试了在 Windows 10 系统下运行 AirSim 并在 WSL（Ubuntu 18.04）中运行 ArduPilot 的情况。AirSim 可以在 macOS 上运行，但尚未在 macOS 上测试与 ArduPilot 的集成。

AirSim 是一个优秀的平台，可用于在模拟车辆上测试和开发基于计算机视觉等技术的系统。它是一款功能非常丰富的模拟器，拥有精细的环境和用于数据采集的 API（Python、C++、ROS）。有关详细信息和可用功能，请参阅AirSim 的主自述文件。

使用 ArduPilot SITL 运行 AirSim 的演示

[![ArduPilot SITL AirSim](../images/ardupilot/airsim_with_ardupilot.jpg)](https://www.youtube.com/watch?v=ElFAqtpEfKo)


为了方便页面浏览，这里列出了几个主题：

* [__安装 AirSim__](#installing_airsim)
    *   [在 Windows 上构建](../build_windows.md)  
    *   [基于 Linux 构建](../build_linux.md)
    *   [基于 macOS 构建](../build_macos.md)  
* [__设置虚幻环境__](../unreal_custenv.md)
* [__使用 ArduPilot 的 AirSim__](#)
* [__启动直升机的软件在环(SITL)模拟__](#copter)   
* [__启动 Rover 的软件在环__](#rover)   
* [__使用激光雷达__](#)   
* [__使用测距仪__](#)   
* [__使用遥控器进行手动飞行__](#)   
* [__多载具仿真__](#)   
* [__ROS与多载具__](#)
* [__自定义环境__](#)
* [__使用 AirSim API__](#)
* [__在不同的机器上运行__](#)
* [__调试和开发工作流程__](#) 


## 使用 ArduPilot 的 AirSim

请确保您已[安装 ArduPilot SITL](https://ardupilot.org/dev/docs/building-the-code.html#building-the-code)，完成 Unreal 环境的设置，或者已下载并验证相关二进制文件能够分别正常运行，然后再继续操作。如果您不熟悉 SITL，请参阅SITL 使用示例。

!!! 笔记
    在 UE 编辑器中运行：转到Edit->Editor Preferences，在 Search 框中键入CPU并确保 Use Less CPU when in Background 未选中。

!!! 笔记
    如果您使用 Windows Subsystem for Linux 2 在 Windows 下运行 ArduPilot 和 AirSim，请参阅 [链接](https://discuss.ardupilot.org/t/gsoc-2019-airsim-simulator-support-for-ardupilot-sitl-part-ii/46395/5) 了解如何连接它们。

[AirSim 的 settings.json 文件](https://github.com/microsoft/AirSim/blob/master/docs/settings.md) 用于指定飞行器及其各种属性。请参阅该页面了解可用选项。

它存储在以下位置——Windows：`Documents\AirSim`，Linux：`~/Documents/AirSim`

该文件采用标准的 JSON 格式。首次启动时，AirSim 会创建一个没有任何设置的 settings.json 文件。

## 启动直升机的软件在环(SITL)模拟

使用 ArduCopter 的设置如下：

```json
{
  "SettingsVersion": 1.2,
  "LogMessagesVisible": true,
  "SimMode": "Multirotor",
  "OriginGeopoint": {
    "Latitude": -35.363261,
    "Longitude": 149.165230,
    "Altitude": 583
  },
  "Vehicles": {
    "Copter": {
      "VehicleType": "ArduCopter",
      "UseSerial": false,
      "LocalHostIp": "127.0.0.1",
      "UdpIp": "127.0.0.1",
      "UdpPort": 9003,
      "ControlPort": 9002
    }
  }
}
```

!!! 笔记
    之前在设置中 `SitlPort` 使用的是 `ControlPort` 。此更改适用于最新的 AirSim 主程序和二进制文件 v1.3.0 及更高版本。此更新向下兼容，因此即使您正在使用 `SitlPort`，它也能正常工作。

首先启动 AirSim，然后启动 ArduPilot SITL。

```shell
sim_vehicle.py -v ArduCopter -f airsim-copter --console --map
```

!!! 笔记
    最初，如果 ArduPilot SITL 尚未启动（这是由于锁定步长调度导致的），按下“播放”按钮后编辑器会卡住。运行 sim_vehicle.py 后应该就能恢复正常。


关闭时，请先按下停止按钮停止 AirSim 模拟，然后再关闭 ArduPilot。如果先关闭 ArduPilot，UE 会卡死，您需要强制关闭它。

您只需按下播放按钮，然后启动 ArduPilot 端即可重新启动，无需完全关闭编辑器然后再重新启动。










