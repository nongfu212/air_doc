# 遥控

要手动飞行，您需要遥控器或 RC(Remote Control)。如果没有遥控器，您可以使用 [APIs](apis.md) 以编程方式飞行，或者使用所谓的 [计算机视觉模式](image_apis.md) 通过键盘操控飞行。

## 默认配置的遥控设置

默认情况下，AirSim 使用 [simple_flight](simple_flight.md)  作为其飞行控制器，通过 USB 端口将 RC 连接到您的计算机。

您可以使用 XBox 控制器或 [FrSky Taranis X9D Plus](https://hobbyking.com/en_us/frsky-2-4ghz-accst-taranis-x9d-plus-and-x8r-combo-digital-telemetry-radio-system-mode-2.html)。请注意，XBox 360 控制器不够精准，如果您想要更真实的游戏体验，不推荐使用。如果出现问题，请参阅下方的常见问题解答。


### 其他设备

AirSim 可以检测各种设备，但除上述设备外，其他设备可能需要额外配置。未来我们将添加通过 settings.json 设置此配置的功能。目前，如果一切正常，您可以尝试 [x360ce](http://www.x360ce.com/) 等变通方法，或更改 [SimJoystick.cpp 文件](https://github.com/microsoft/AirSim/blob/main/Unreal/Plugins/AirSim/Source/SimJoyStick/SimJoyStick.cpp#L50) 中的代码。


### FrSky Taranis X9D Plus 注意事项

[FrSky Taranis X9D Plus](https://hobbyking.com/en_us/frsky-2-4ghz-accst-taranis-x9d-plus-and-x8r-combo-digital-telemetry-radio-system-mode-2.html) 是一款真正的无人机遥控器，其优势在于它配备 USB 端口，可直接连接到电脑。您可以 [下载 AirSim 配置文件](misc/AirSim_FrSkyTaranis.bin) ，并 [按照本教程](https://www.youtube.com/watch?v=qe-13Gyb0sw) 将其导入您的遥控器。之后，您应该会在遥控器中看到所有通道均已正确配置的“sim”模型。

### Linux 注意事项

目前 Linux 上的默认配置适用于 Xbox 控制器。这意味着其他设备可能无法正常工作。未来我们将在 settings.json 中添加配置 RC 的功能，但目前您 *可能* 需要修改 [SimJoystick.cpp file](https://github.com/microsoft/AirSim/blob/main/Unreal/Plugins/AirSim/Source/SimJoyStick/SimJoyStick.cpp#L340) 文件中的代码才能使用其他设备。


## PX4 的遥控设置

AirSim 支持 PX4 飞行控制器，但设置方法有所不同。四旋翼飞行器可以使用多种遥控选项。我们已成功将 FrSky Taranis X9D Plus、FlySky FS-TH9X 和 Futaba 14SG 与 AirSim 配合使用。以下是配置遥控器的详细步骤：


1. 如果您要使用硬件在环模式，您需要与您的 RC 品牌对应的遥控器进行绑定。您可以在 RC 的用户指南中找到相关信息。 
2. 对于硬件在环模式，您需要将发射器连接到 Pixhawk。通常您可以找到在线文档或 YouTube 视频教程来了解如何操作。 
3. [在 QGroundControl 中校准您的 RC。](https://docs.qgroundcontrol.com/en/SetupView/Radio.html).

请参阅 [PX4 RC 配置](https://docs.px4.io/en/getting_started/rc_transmitter_receiver.html) 并参阅 [本指南](https://docs.px4.io/master/en/getting_started/rc_transmitter_receiver.html#px4-compatible-receivers) 以了解更多信息。


### 使用 XBox 360 USB 游戏手柄

您也可以在 SITL 模式下使用 Xbox 控制器，但它的精度不如真正的 RC 控制器。有关如何设置的详细信息，请参阅 [Xbox 控制器](xbox_controller.md) 。


### 使用 Playstation 3 控制器

已确认 Playstation 3 控制器可以用作 AirSim 控制器。但在 Windows 上，需要使用模拟器才能使其看起来像 Xbox 360 控制器。网上有很多不同的解决方案，例如 [x360ce Xbox 360 控制器模拟器](https://github.com/x360ce/x360ce) 。


### DJI 控制器

Nils Tijtgat 写了一篇关于如何让 [DJI 控制器与 AirSim 协同工作](https://timebutt.github.io/static/using-a-phantom-dji-controller-in-airsim/) 的精彩博客。


## FAQ

#### 我正在使用默认配置，但 AirSim 说我的 RC 在 USB 上未被检测到。

如果您连接了多个遥控器或 XBox/Playstation 游戏手柄等，通常会发生这种情况。在 Windows 系统中，按下 Windows+S 键并搜索“设置 USB 游戏控制器”（在旧版 Windows 中，请尝试“游戏杆”）。这将显示所有连接到您电脑的游戏控制器。如果您没有看到您的控制器，则表示 Windows 尚未检测到它，因此您需要先解决该问题。如果您看到了您的控制器，但不在列表顶部（即索引 0），则需要告知 AirSim，因为 AirSim 默认尝试使用索引 0 处的 RC。为此，请导航到您的 `~/Documents/AirSim` 文件夹，打开 `settings.json` 并添加/修改以下设置。以下设置告知 AirSim 使用索引 = 2 处的 RC。

```
{
    "SettingsVersion": 1.2,
    "SimMode": "Multirotor",
    "Vehicles": {
        "SimpleFlight": {
            "VehicleType": "SimpleFlight",
            "RC": {
              "RemoteControlID": 2
            }
        }
    }
}
```

#### 使用 XBox/PS3 控制器时车辆似乎不稳定

普通游戏手柄精度不高，而且有很多随机噪声。大多数情况下，您还可能会看到明显的偏移（例如，摇杆位置为 0 时，输出不为 0）。因此，这种行为是可以预料的。


#### AirSim 中的 RC 校准在哪里？

我们尚未实现此功能。这意味着您的 RC 固件目前需要具备校准功能。


#### 我的 RC 无法与 PX4 设置配合使用。

首先，您需要确保您的遥控器在 [QGroundControl](https://docs.qgroundcontrol.com/en/SetupView/Radio.html) 中正常工作。如果无法正常工作，则肯定无法在 AirSim 中正常工作。PX4 模式适合具有中级以上经验的用户，能够处理与 PX4 相关的各种问题，我们通常建议您从 PX4 论坛获取帮助。


