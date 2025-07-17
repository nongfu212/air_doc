# AirSim 设置

## 设置存储在哪里？
AirSim 正在按以下顺序搜索设置定义。将使用第一个匹配项：

1. 查看 `-settings` 命令行参数指定的（绝对）路径。
例如，在 Windows 系统中：`AirSim.exe -settings="C:\path\to\settings.json"`
在 Linux 系统中：`./Blocks.sh -settings="/home/$USER/path/to/settings.json"`  

2. 查找通过 `-settings` 参数作为命令行参数传递的 JSON 文档。
例如，在 Windows 系统中：`AirSim.exe -settings={"foo":"bar"}`
在 Linux 系统中：`./Blocks.sh -settings={"foo":"bar"}` 

3. 在可执行文件的文件夹中查找名为`settings.json`的文件。
这将是编辑器或二进制文件实际可执行文件的深层位置。
例如，对于 Blocks 二进制文件，搜索的位置是`<path-of-binary>/LinuxNoEditor/Blocks/Binaries/Linux/settings.json`。 

4. 在启动可执行文件的文件夹中搜索`settings.json` 

    这是包含启动脚本或可执行文件的顶级目录。例如，Linux：`<path-of-binary>/LinuxNoEditor/settings.json`，Windows：`<path-of-binary>/WindowsNoEditor/settings.json` 

    请注意，此路径会根据调用位置而变化。在 Linux 上，如果从 LinuxNoEditor 文件夹内部（例如`./Blocks.sh`）执行`Blocks.sh`脚本，则使用前面提到的路径。但是，如果从 LinuxNoEditor 文件夹外部（例如`./LinuxNoEditor/Blocks.sh`）启动，则将使用`<path-of-binary>/settings.json`。 

5. 在 AirSim 子文件夹中查找名为`settings.json`的文件。在 Windows 系统中，AirSim 子文件夹位于`Documents\AirSim`；在 Linux 系统中，AirSim 子文件夹位于`~/Documents/AirSim`。


该文件采用常见的 [json 格式](https://en.wikipedia.org/wiki/JSON)。首次启动时，AirSim 会在用户主文件夹中创建 `settings.json` 文件，该文件不包含任何设置。为避免出现问题，请始终使用 ASCII 格式保存 json 文件。  


## 如何在汽车和多旋翼飞行器之间进行选择？
默认使用多旋翼飞行器。要使用汽车，只需设置`"SimMode": "Car"`，如下所示： 

```
{
  "SettingsVersion": 1.2,
  "SimMode": "Car"
}
```

要选择多旋翼飞行器，请设置 `"SimMode": "Multirotor"`。如果您想提示用户选择飞行器类型，请使用 `"SimMode": ""`。


## 可用设置及其默认值

以下是可用设置及其默认值的完整列表。如果 json 文件中缺少任何设置，则使用默认值。某些默认值仅以“""”指定，这意味着实际值可能根据您使用的车辆选择。例如，`ViewMode`设置的默认值为`""`，对于无人机，其默认值为`"FlyWithMe"`，对于汽车，其默认值为`"SpringArmChase"`。


**警告：** 请勿将以下所有内容复制粘贴到您的 settings.json 中。我们强烈建议您仅添加那些您不想使用默认值的设置。唯一必需的元素是`"SettingsVersion"`。 

```json
{
  "SimMode": "",
  "ClockType": "",
  "ClockSpeed": 1,
  "LocalHostIp": "127.0.0.1",
  "ApiServerPort": 41451,
  "RecordUIVisible": true,
  "LogMessagesVisible": true,
  "ShowLosDebugLines": false,
  "ViewMode": "",
  "RpcEnabled": true,
  "EngineSound": true,
  "PhysicsEngineName": "",
  "SpeedUnitFactor": 1.0,
  "SpeedUnitLabel": "m/s",
  "Wind": { "X": 0, "Y": 0, "Z": 0 },
  "CameraDirector": {
    "FollowDistance": -3,
    "X": NaN, "Y": NaN, "Z": NaN,
    "Pitch": NaN, "Roll": NaN, "Yaw": NaN
  },
  "Recording": {
    "RecordOnMove": false,
    "RecordInterval": 0.05,
    "Folder": "",
    "Enabled": false,
    "Cameras": [
        { "CameraName": "0", "ImageType": 0, "PixelsAsFloat": false,  "VehicleName": "", "Compress": true }
    ]
  },
  "CameraDefaults": {
    "CaptureSettings": [
      {
        "ImageType": 0,
        "Width": 256,
        "Height": 144,
        "FOV_Degrees": 90,
        "AutoExposureSpeed": 100,
        "AutoExposureBias": 0,
        "AutoExposureMaxBrightness": 0.64,
        "AutoExposureMinBrightness": 0.03,
        "MotionBlurAmount": 0,
        "TargetGamma": 1.0,
        "ProjectionMode": "",
        "OrthoWidth": 5.12
      }
    ],
    "NoiseSettings": [
      {
        "Enabled": false,
        "ImageType": 0,

        "RandContrib": 0.2,
        "RandSpeed": 100000.0,
        "RandSize": 500.0,
        "RandDensity": 2,

        "HorzWaveContrib":0.03,
        "HorzWaveStrength": 0.08,
        "HorzWaveVertSize": 1.0,
        "HorzWaveScreenSize": 1.0,

        "HorzNoiseLinesContrib": 1.0,
        "HorzNoiseLinesDensityY": 0.01,
        "HorzNoiseLinesDensityXY": 0.5,

        "HorzDistortionContrib": 1.0,
        "HorzDistortionStrength": 0.002
      }
    ],
    "Gimbal": {
      "Stabilization": 0,
      "Pitch": NaN, "Roll": NaN, "Yaw": NaN
    },
    "X": NaN, "Y": NaN, "Z": NaN,
    "Pitch": NaN, "Roll": NaN, "Yaw": NaN,
    "UnrealEngine": {
      "PixelFormatOverride": [
        {
          "ImageType": 0,
          "PixelFormat": 0
        }
      ]
    }
  },
  "OriginGeopoint": {
    "Latitude": 47.641468,
    "Longitude": -122.140165,
    "Altitude": 122
  },
  "TimeOfDay": {
    "Enabled": false,
    "StartDateTime": "",
    "CelestialClockSpeed": 1,
    "StartDateTimeDst": false,
    "UpdateIntervalSecs": 60
  },
  "SubWindows": [
    {"WindowID": 0, "CameraName": "0", "ImageType": 3, "VehicleName": "", "Visible": false, "External": false},
    {"WindowID": 1, "CameraName": "0", "ImageType": 5, "VehicleName": "", "Visible": false, "External": false},
    {"WindowID": 2, "CameraName": "0", "ImageType": 0, "VehicleName": "", "Visible": false, "External": false}
  ],
  "SegmentationSettings": {
    "InitMethod": "",
    "MeshNamingMethod": "",
    "OverrideExisting": true
  },
  "PawnPaths": {
    "BareboneCar": {"PawnBP": "Class'/AirSim/VehicleAdv/Vehicle/VehicleAdvPawn.VehicleAdvPawn_C'"},
    "DefaultCar": {"PawnBP": "Class'/AirSim/VehicleAdv/SUV/SuvCarPawn.SuvCarPawn_C'"},
    "DefaultQuadrotor": {"PawnBP": "Class'/AirSim/Blueprints/BP_FlyingPawn.BP_FlyingPawn_C'"},
    "DefaultComputerVision": {"PawnBP": "Class'/AirSim/Blueprints/BP_ComputerVisionPawn.BP_ComputerVisionPawn_C'"}
  },
  "Vehicles": {
    "SimpleFlight": {
      "VehicleType": "SimpleFlight",
      "DefaultVehicleState": "Armed",
      "AutoCreate": true,
      "PawnPath": "",
      "EnableCollisionPassthrogh": false,
      "EnableCollisions": true,
      "AllowAPIAlways": true,
      "EnableTrace": false,
      "RC": {
        "RemoteControlID": 0,
        "AllowAPIWhenDisconnected": false
      },
      "Cameras": {
        //same elements as CameraDefaults above, key as name
      },
      "X": NaN, "Y": NaN, "Z": NaN,
      "Pitch": NaN, "Roll": NaN, "Yaw": NaN
    },
    "PhysXCar": {
      "VehicleType": "PhysXCar",
      "DefaultVehicleState": "",
      "AutoCreate": true,
      "PawnPath": "",
      "EnableCollisionPassthrogh": false,
      "EnableCollisions": true,
      "RC": {
        "RemoteControlID": -1
      },
      "Cameras": {
        "MyCamera1": {
          //same elements as elements inside CameraDefaults above
        },
        "MyCamera2": {
          //same elements as elements inside CameraDefaults above
        },
      },
      "X": NaN, "Y": NaN, "Z": NaN,
      "Pitch": NaN, "Roll": NaN, "Yaw": NaN
    }
  },
  "ExternalCameras": {
    "FixedCamera1": {
        // same elements as in CameraDefaults above
    },
    "FixedCamera2": {
        // same elements as in CameraDefaults above
    }
  }
}
```

## SimMode
SimMode 决定使用哪种模拟模式。以下是当前支持的值：
- `""`: 提示用户选择飞行器类型：多旋翼飞行器或汽车
- `"Multirotor"`: 使用多旋翼飞行器模拟
- `"Car"`: 使用汽车模拟
- `"ComputerVision"`: 仅使用摄像头，不使用飞行器或物理系统

## ViewMode
ViewMode 决定了默认使用哪个摄像头以及摄像头如何跟随飞行器。对于多旋翼飞行器，默认 ViewMode 为`"FlyWithMe"`，而对于汽车，默认 ViewMode 为`"SpringArmChase"`。


* `FlyWithMe`: 以 6 个自由度从后面追赶车辆
* `GroundObserver`: 从距地面 6 英尺的高度追逐车辆，但在 XY 平面上具有完全的自由。
* `Fpv`: 从车辆前置摄像头查看场景
* `Manual`: 不自动移动摄像头。使用箭头键和 ASWD 键手动移动摄像头。
* `SpringArmChase`: 使用安装在（隐形）臂上的摄像头追逐车辆，该臂通过弹簧连接到车辆上（因此在运动中有一定的延迟）。
* `NoDisplay`: 这将冻结主屏幕的渲染，但子窗口、录制和 API 的渲染仍然有效。此模式有助于在“无头”模式下节省资源，因为在“无头”模式下，您只需获取图像，而不关心主屏幕上渲染的内容。这也可能提高录制图像的 FPS。


## TimeOfDay

此设置控制环境中太阳的位置。默认情况下，`Enabled`为 false，这意味着太阳的位置将保留在环境中的默认位置，并且不会随时间变化。如果`Enabled`为 true，则使用`OriginGeopoint`部分中指定的经度、纬度和高度，针对`StartDateTime`中指定的日期（字符串格式为 [%Y-%m-%d %H:%M:%S](https://en.cppreference.com/w/cpp/io/manip/get_time) ）计算太阳位置，例如`2018-02-12 15:20:00`。如果此字符串为空，则使用当前日期和时间。如果`StartDateTimeDst`为 true，则我们会调整夏令时。然后，太阳的位置将按照`UpdateIntervalSecs`中指定的间隔持续更新。在某些情况下，可能希望天体时钟运行得比模拟时钟更快或更慢。这可以使用`CelestialClockSpeed`来指定，例如，值 100 表示模拟时钟每 1 秒，太阳的位置就会前进 100 秒，因此太阳在天空中的移动速度会更快。

另请参阅 [时间 API](apis.md#time-of-day-api) 。


## OriginGeopoint

此设置指定放置在虚幻环境中的玩家起始点组件的纬度、经度和海拔高度。飞行器的起始点使用此变换计算。请注意，所有通过 API 公开的坐标均使用国际单位制 (SI) 的 NED 系统，这意味着每辆车的起始点在 NED 系统中为 (0, 0, 0)。时间设置是根据`OriginGeopoint`中指定的地理坐标计算的。


## SubWindows

此设置决定了按下 1、2、3 键时可见的 3 个子窗口中分别显示的内容。

* `WindowID`: 可以是 0 到 2
* `CameraName`: 车辆上是否有任何 [可用摄像头](image_apis.md#available-cameras) 或外部摄像头
* `ImageType`: 整数值根据 [ImageType 枚举](image_apis.md#available-imagetype-values) 决定显示哪种类型的图像。  
* `VehicleName`: 此字符串用于指定要使用摄像头的车辆，当设置中指定了多辆车辆时使用。如果出现任何错误，例如车辆名称错误或只有一辆车，则将使用第一辆车的摄像头。
* `External`: 如果摄像头是外置摄像头，则将其设置为`true`。如果为 true，则`VehicleName`参数将被忽略


例如，对于单辆汽车，下面分别显示驾驶员视图、前保险杠视图和后视图作为场景、深度和表面法线。
```json
  "SubWindows": [
    {"WindowID": 0, "ImageType": 0, "CameraName": "3", "Visible": true},
    {"WindowID": 1, "ImageType": 3, "CameraName": "0", "Visible": true},
    {"WindowID": 2, "ImageType": 6, "CameraName": "4", "Visible": true}
  ]
```

如果有多辆车辆，可以按如下方式指定不同的车辆：

```json
    "SubWindows": [
        {"WindowID": 0, "CameraName": "0", "ImageType": 3, "VehicleName": "Car1", "Visible": false},
        {"WindowID": 1, "CameraName": "0", "ImageType": 5, "VehicleName": "Car2", "Visible": false},
        {"WindowID": 2, "CameraName": "0", "ImageType": 0, "VehicleName": "Car1", "Visible": false}
    ]
```

## 记录

记录功能允许您以指定的时间间隔记录位置、方向、速度等数据以及捕获的图像。您可以按下右下角的红色录制按钮或 R 键开始录制。数据存储在`Documents\AirSim`文件夹（或使用`Folder`指定的文件夹）中，每个录制会话都会有一个带有时间戳的子文件夹，并以制表符分隔的文件形式保存。


* `RecordInterval`: 指定捕获两幅图像之间的最小间隔（以秒为单位）。
* `RecordOnMove`: 指定如果车辆的位置或方向没有改变则不记录帧。
* `Folder`: 父文件夹，用于创建包含时间戳的记录子文件夹。必须指定目录的绝对路径。如果未指定，则将使用`Documents/AirSim`文件夹。例如：`"Folder": "/home/<user>/Documents"` 
* `Enabled`: 记录是否从头开始，设置为`true`表示模拟开始时自动开始记录。默认设置为`false`
* `Cameras`: 此元素控制使用哪些摄像头采集图像。默认情况下，摄像头 0 的场景图像会被记录为压缩的 png 格式。此设置是一个 JSON 数组，因此您可以指定多个摄像头采集图像，每个摄像头可能具有不同的[图像类型](settings.md#image-capture-settings) 。
    * 当 `PixelsAsFloat` 为真时，图像将保存为 [pfm](pfm.md) 文件而不是 png 文件。
    * `VehicleName` 选项允许您为每辆车指定单独的摄像头。如果不存在`Cameras`元素，则将记录每辆车默认摄像头的`Scene`图像。
    * 如果您不想记录任何图像而只想记录车辆的物理数据，请指定`Cameras`元素但将其留空，如下所示：`"Cameras": []` 
    * 目前不支持外接摄像头记录

例如，下面的`Cameras`元素记录了`Car1`的场景和分割图像以及`Car2`的场景：


```json
"Cameras": [
    { "CameraName": "0", "ImageType": 0, "PixelsAsFloat": false, "VehicleName": "Car1", "Compress": true },
    { "CameraName": "0", "ImageType": 5, "PixelsAsFloat": false, "VehicleName": "Car1", "Compress": true },
    { "CameraName": "0", "ImageType": 0, "PixelsAsFloat": false, "VehicleName": "Car2", "Compress": true }
]
```

查看修改记录数据来了解如何 [修改正在记录的](modify_recording_data.md) 运动学数据的详细信息。


## ClockSpeed

此设置允许您设置模拟时钟相对于挂钟的速度。例如，值为 5.0 表示当挂钟已过去 1 秒时，模拟时钟已过去 5 秒（即模拟运行速度更快）。值为 0.1 表示模拟时钟比挂钟慢 10 倍。值为 1 表示模拟实时运行。需要注意的是，模拟时钟运行速度越快，模拟质量可能会下降。您可能会看到一些伪影，例如物体越过障碍物，因为未检测到碰撞。但是，降低模拟时钟速度（即值小于 1.0）通常可以提高模拟质量。


## 分割设置

`InitMethod` 决定了启动时如何初始化对象 ID 以生成 [分割](image_apis.md#segmentation)。值为 "" 或 "CommonObjectsRandomIDs"（默认值）表示在启动时为每个对象分配随机 ID。这将生成为每个对象分配随机颜色的分割视图。值为 "None" 表示不初始化对象 ID。这将导致分割视图呈现单一纯色。如果您计划使用 [API](image_apis.md#segmentation) 设置对象 ID，此模式非常有用，并且可以在像 CityEnviron 这样的大型环境中节省启动时的大量延迟。


如果`OverrideExisting`为假，则初始化不会改变已经分配的非零对象 ID，否则会改变。


如果`MeshNamingMethod`为“”或“OwnerName”，则我们使用网格的所有者名称生成随机哈希值作为对象ID。如果为“StaticMeshName”，则我们使用静态网格的名称生成随机哈希值作为对象ID。请注意，这种方式无法区分同一个静态网格的不同实例，但名称通常更直观。


## 风的设置

此设置指定世界坐标系中北纬方向的风速。值以米/秒为单位。默认情况下，速度为 0，即无风。


## Camera Director 设置

此元素指定用于在 ViewPort 中跟随车辆的摄像机的设置。

* `FollowDistance`: 摄像头跟随车辆的距离，汽车默认为-8（8米），其他默认为-3。 
* `X, Y, Z, Yaw, Roll, Pitch`: 这些元素允许您指定摄像机相对于车辆的位置和方向。位置采用国际单位制 (SI) 的 NED 坐标系，原点设置为虚幻环境中的玩家起始位置。方向以度为单位。 

## 相机设置

根级别的`CameraDefaults`元素指定所有摄像头的默认值。这些默认值可以在“Vehicles”类中的`Cameras`元素中为单个摄像头覆盖，具体方法请见后文。


### 关于 ImageType 元素的注释

JSON 数组中的 `ImageType` 元素决定了设置应用于哪种图像类型。有效值在 [ImageType 部分](image_apis.md#available-imagetype) 中进行了说明。此外，我们还支持特殊值 `ImageType: -1`，用于将设置应用于外部摄像头（即您正在屏幕上查看的内容）。


例如，`CaptureSettings`元素是 json 数组，因此您可以轻松添加多种图像类型的设置。


### CaptureSettings

`CaptureSettings` 决定了不同图像类型（例如场景、深度、视差、表面法线和分割视图）的渲染方式。“Width”、“Height” 和 “FOV” 的设置含义不言自明。“AutoExposureSpeed” 决定了人眼适应的速度。我们通常将其设置为较高的值（例如 100），以避免图像采集过程中出现伪影。同样，我们默认将“MotionBlurAmount”设置为 0，以避免地面实况图像中出现伪影。`ProjectionMode` 决定了采集相机使用的投影方式，可以采用“perspective”（默认）或“orthographic”值。如果投影模式为“orthographic”，则`OrthoWidth`决定了采集投影区域的宽度（以米为单位）。


有关其他设置的说明，请参阅[本文](https://docs.unrealengine.com/latest/INT/Engine/Rendering/PostProcessEffects/AutomaticExposure/)。


### NoiseSettings

“噪声设置 (`NoiseSettings`)” 允许为指定类型的图像添加噪声，以模拟相机传感器噪声、干扰和其他伪影。默认情况下不添加噪声，即`Enabled: false`。如果设置为`Enabled: true`，则会启用以下不同类型的噪声和干扰伪影，每种类型都可以通过设置进一步调整。噪声效果通过着色器实现，该着色器在虚幻引擎中作为后期处理材质创建，名为 [CameraSensorNoise](https://github.com/Microsoft/AirSim/blob/main/Unreal/Plugins/AirSim/Content/HUDAssets/CameraSensorNoise.uasset)。


相机噪声和干扰模拟演示：

[![AirSim Drone Demo Video](images/camera_noise_demo.png)](https://youtu.be/1BeCEZmQyp0)

#### 随机噪声
这将添加具有以下参数的随机噪声斑点。
* `RandContrib`: 这决定了噪声像素与图像像素的混合比，0 表示无噪声，1 表示只有噪声。
* `RandSpeed`: 这决定了噪声波动的速度，1 表示没有波动，而更高的值（如 1E6）表示完全波动。
* `RandSize`: 这决定了噪声的粗略程度，1 表示每个像素都有自己的噪声，而更高的值表示超过 1 个像素共享相同的噪声值。 
* `RandDensity`: 这决定了总共有多少像素会有噪点，1 表示所有像素，而值越高表示像素数量越少（呈指数级）。

#### 水平凹凸变形
这会增加水平凹凸/闪烁/重影效果。
* `HorzWaveContrib`: 这决定了噪声像素与图像像素的混合比，0 表示无噪声，1 表示只有噪声。
* `HorzWaveStrength`: 这决定了效果的整体强度。
* `HorzWaveVertSize`: 这决定了有多少垂直像素会受到该效果的影响。
* `HorzWaveScreenSize`: 这决定了屏幕的多少部分会受到该效果的影响。

#### 水平噪声线
这会在水平线上增加噪声区域。
* `HorzNoiseLinesContrib`: 这决定了噪声像素与图像像素的混合比，0 表示无噪声，1 表示只有噪声。
* `HorzNoiseLinesDensityY`: 这决定了水平线上有多少像素受到影响。
* `HorzNoiseLinesDensityXY`: 这决定了屏幕上有多少行受到影响。

#### 水平线畸变
这增加了水平线的波动。
* `HorzDistortionContrib`: 这决定了噪声像素与图像像素的混合比，0 表示无噪声，1 表示只有噪声。
* `HorzDistortionStrength`: 这决定了失真程度有多大。

### Gimbal
`Gimbal`元素允许冻结摄像机的俯仰、横滚和/或偏航方向。除非`ImageType`为-1，否则此设置将被忽略。`Stabilization`默认为0，表示无万向节，即摄像机方向在所有轴上随车身方向而变化。值为1表示完全稳定。0到1之间的值作为`Pitch`、`Roll`和`Yaw` 元素中指定的固定角度（以度为单位，在世界坐标系中）和车身方向的权重。当json中省略任何角度或将其设置为NaN时，该角度不稳定（即它会随车身一起移动）。


### 虚幻引擎
此元素包含虚幻引擎特有的设置。这些设置将在 Unity 项目中被忽略。
* `PixelFormatOverride`: 这包含一个包含`ImageType`和`PixelFormat`设置的元素列表。每个元素都允许您覆盖`ImageType`设置指定的捕获实例化的 UTextureRenderTarget2D 对象的默认像素格式。指定此元素可以防止由意外像素格式引起的崩溃（有关这些崩溃的示例，请参阅 [#4120](https://github.com/microsoft/AirSim/issues/4120) 和 [#4339](https://github.com/microsoft/AirSim/issues/4339)。完整的像素格式列表可在[此处](https://docs.unrealengine.com/4.27/en-US/API/Runtime/Core/EPixelFormat/)查看。

## 外接摄像头

此元素允许指定独立于车辆上安装的摄像头（例如闭路电视摄像头）。这些摄像头是固定摄像头，不会随车辆移动。该元素中的键是摄像头的名称，值（即设置）与上面描述的`CameraDefaults`相同。所有摄像头 API 均可与外部摄像头配合使用，包括通过在 API 调用中传递参数`external=True`来捕获图像、更改姿势等。


## 车辆设置

每种模拟模式都会遍历此设置中指定的车辆列表，并创建具有`"AutoCreate": true` 的车辆。此设置中指定的每辆车辆都有一个键，该键将成为车辆的名称。如果缺少`"Vehicles"`元素，则此列表将填充名为“PhysXCar”的默认车辆和名为“SimpleFlight”的默认多旋翼飞行器。


### 常用车辆设置
- `VehicleType`: 这可以是以下任意一种：`PhysXCar`、`SimpleFlight`、`PX4Multirotor`、`ComputerVision`、`ArduCopter` 和 `ArduRover`。由于没有默认值，因此必须指定此元素。
- `PawnPath`: 这允许覆盖用于载具的 pawn 蓝图。例如，您可以在 AirSim 代码之外的项目中，为仓库机器人创建一个源自 ACarPawn 的新 pawn 蓝图，然后在此处指定其路径。另请参阅 [PawnPaths](settings.md#PawnPaths)。请注意，您必须在全局 `PawnPaths` 对象中使用您专有定义的对象名称指定自定义 pawn 蓝图类路径，并在 `Vehicles` 设置中引用该名称。例如： 
```json
    {
      ...
      "PawnPaths": {
        "CustomPawn": {"PawnBP": "Class'/Game/Assets/Blueprints/MyPawn.MyPawn_C'"}
      },
      "Vehicles": {
        "MyVehicle": {
          "VehicleType": ...,
          "PawnPath": "CustomPawn",
          ...
        }
      }
    }
```
- `DefaultVehicleState`: 多旋翼飞行器的可能值是`Armed`或`Disarmed`。
- `AutoCreate`: 如果为真，那么该车辆就会被生成（如果所选模拟模式支持）。
- `RC`: 此子元素允许使用`RemoteControlID`指定飞行器使用的遥控器。值为 -1 表示使用键盘（多旋翼飞行器尚不支持）。值 >= 0 表示指定连接到系统的多个遥控器之一。例如，可以在 Windows 系统的“游戏控制器”面板中查看可用的遥控器列表。
- `X, Y, Z, Yaw, Roll, Pitch`: 这些元素允许您指定车辆的初始位置和方向。位置采用国际单位制 (SI) 的 NED 坐标系，原点设置为虚幻环境中的玩家起始位置。方向以度为单位。
- `IsFpvVehicle`: 此设置允许指定当 ViewMode 设置为 FPV 时，哪个车辆摄像头将跟随哪个车辆以及显示的视图。默认情况下，AirSim 选择设置中的第一个车辆作为 FPV 车辆。 
- `Sensors`: 该元素指定与车辆关联的传感器，详情请参阅 [传感器页面](sensors.md) 。
- `Cameras`: 此元素指定车辆的摄像头设置。此元素的键是 [可用摄像头](image_apis.md#available_cameras) 的名称，值与上文所述的`CameraDefaults`相同。例如，要将前中央摄像头的视野 (FOV) 更改为 120 度，您可以在“车辆”设置中使用此元素：

```json
"Vehicles": {
    "FishEyeDrone": {
      "VehicleType": "SimpleFlight",
      "Cameras": {
        "front-center": {
          "CaptureSettings": [
            {
              "ImageType": 0,
              "FOV_Degrees": 120
            }
          ]
        }
      }
    }
}
```

### 使用 PX4

默认情况下，我们使用 [simple_flight](simple_flight.md)，因此您无需单独进行 HITL 或 SITL 设置。我们还为高级用户提供 ["PX4"](px4_setup.md) 支持。要将 PX4 与 AirSim 配合使用，您可以使用以下`Vehicles`设置：

```
"Vehicles": {
    "PX4": {
      "VehicleType": "PX4Multirotor",
    }
}
```

#### 其他 PX4 设置

PX4 默认启用 **硬件在环** 设置。PX4 还有其他各种设置及其默认值：


```
"Vehicles": {
    "PX4": {
      "VehicleType": "PX4Multirotor",
      "Lockstep": true,
      "ControlIp": "127.0.0.1",
      "ControlPortLocal": 14540,
      "ControlPortRemote": 14580,
      "LogViewerHostIp": "127.0.0.1",
      "LogViewerPort": 14388,
      "OffboardCompID": 1,
      "OffboardSysID": 134,
      "QgcHostIp": "127.0.0.1",
      "QgcPort": 14550,
      "SerialBaudRate": 115200,
      "SerialPort": "*",
      "SimCompID": 42,
      "SimSysID": 142,
      "TcpPort": 4560,
      "UdpIp": "127.0.0.1",
      "UdpPort": 14560,
      "UseSerial": true,
      "UseTcp": false,
      "VehicleCompID": 1,
      "VehicleSysID": 135,
      "Model": "Generic",
      "LocalHostIp": "127.0.0.1",
      "Logs": "d:\\temp\\mavlink",
      "Sensors": {
        ...
      }
      "Parameters": {
        ...
      }
    }
}
```

这些设置定义了 MavLink 模拟器的 SystemId 和 ComponentId（SimSysID、SimCompID）、飞行器（VehicleSysID、VehicleCompID）以及允许从其他应用程序远程控制无人机的节点（称为机外节点）（OffboardSysID、OffboardCompID）。


如果您希望模拟器也能将 mavlink 消息转发到您的地面控制应用程序（例如 QGroundControl），您也可以设置该应用程序的 UDP 地址，以便在其他机器上运行该应用程序（QgcHostIp、QgcPort）。默认地址为本地主机，因此 QGroundControl 应该“仅在”同一台机器上运行即可正常工作。


您可以通过设置 UDP 地址（LogViewerHostIp、LogViewerPort）将模拟器连接到此 repo 中提供的 LogViewer 应用程序。


对于每个添加到模拟器的飞行无人机，都有一个命名的附加设置块。在上图中，您可以看到默认名称“PX4”。您可以在虚幻编辑器中添加新的 BP_FlyingPawn 资源时更改此名称。您将看到这些属性分组在“MavLink”类别下。
此 Pawn 的 MavLink 节点可以通过 UDP 远程连接，也可以连接到本地串行端口。
如果是串行连接，则将 UseSerial 设置为 true，否则将 UseSerial 设置为 false。对于串行连接，您还需要设置适当的 SerialBaudRate。默认值 115200 适用于 Pixhawk 2 版本，
通过 USB 连接。


通过串口与 PX4 无人机通信时，HIL_* 消息和飞行器控制消息共享同一串口。通过 UDP 或 TCP 通信时，PX4 需要两个独立的通道。如果 UseTcp 为 false，则使用 UdpIp 和 UdpPort 发送 HIL_* 消息，否则使用 TcpPort。PX4 在 1.9.2 版本中新增了 TCP 支持，并添加了 `lockstep` 功能，因为 TCP 提供的消息传递保证是 lockstep 正常运行的必要条件。
在这种情况下，AirSim 将成为 TCP 服务器，并等待来自 PX4 应用程序的连接。用于控制飞行器的第二个通道由 (ControlIp, ControlPort) 定义，并且始终为 UDP 通道。


传感器 `Sensors` 部分可以为模拟传感器提供自定义设置，请参阅
[Sensors](sensors.md)。`Parameters` 部分可以在 PX4 连接初始化期间设置 PX4 参数。有关示例，请参阅 [设置 PX4 软件在环](px4_sitl.md) 。


### 使用 ArduPilot

[ArduPilot](https://ardupilot.org/) 直升机和漫游车在最新的 AirSim 主分支及版本 `v1.3.0` 及更高版本中均受支持。有关设置和使用方法，请参阅 [ArduPilot SITL 与 AirSim 的配合使用](https://ardupilot.org/dev/docs/sitl-with-airsim.html) 。


## 其他设置

### EngineSound

要关闭引擎声音，请使用 [设置](settings.md) `"EngineSound": false`。目前此设置仅适用于汽车。


### PawnPaths

这允许您指定自己的车辆 pawn 蓝图，例如，您可以用自己的车辆替换 AirSim 中的默认车辆。您的车辆蓝图可以位于您自己的虚幻项目的 Content 文件夹中（即 AirSim 插件文件夹之外）。例如，如果您的项目中有一个位于`Content\MyCar\MySedanBP.uasset`文件中的车辆蓝图，那么您可以设置`"DefaultCar": {"PawnBP":"Class'/Game/MyCar/MySedanBP.MySedanBP_C'"}`。`XYZ.XYZ_C`是指定 BP`XYZ`类所需的特殊符号。请注意，您的 BP 必须衍生自 CarPawn 类。默认情况下并非如此，但您可以在打开 BP 后，使用 UE 编辑器工具栏中的“类设置”按钮，然后在“类选项”中选择“Car Pawn”作为父类设置，从而重新设置 BP 的父类。建议禁用“自动附身玩家”和“自动附身AI”，并在BP详情中将AI控制器类别设置为“无”。如果您正在创建二进制文件，请确保您的资源已包含在打包选项中以供烘焙。


### PhysicsEngineName

对于汽车，我们目前仅支持 PhysX（无论此设置中的值如何）。对于多旋翼飞行器，我们支持`"FastPhysicsEngine"`和`"ExternalPhysicsEngine"`。`"ExternalPhysicsEngine"`允许通过 setVehiclePose () 控制无人机，使无人机保持原位直到下一次调用。这对于使用外部模拟器或沿已保存的路径移动 AirSim 无人机尤其有用。


### LocalHostIp 设置

现在，当连接到远程机器时，您可能需要选择一个特定的以太网适配器来连接这些机器，例如，它可能是通过以太网、Wi-Fi、其他特殊的虚拟适配器或VPN。您的电脑可能有多个网络，而这些网络可能不允许相互通信，在这种情况下，来自一个网络的UDP消息将无法传递到其他网络。


因此，LocalHostIp 允许您配置如何访问这些机器。默认值 127.0.0.1 无法访问外部机器，
仅当您要通信的所有内容都包含在一台 PC 上时才使用此默认值。


### ApiServerPort

此设置决定了 airsim 客户端使用的服务器端口，默认端口为 41451。通过指定不同的端口，用户可以并行运行多个环境以加速数据收集过程。

### SpeedUnitFactor

与“米/秒”相关的速度单位换算系数，默认值为 1。与 SpeedUnitLabel 结合使用。该系数仅可用于显示目的，例如在汽车行驶时显示速度。例如，要获取 “英里/小时”(`miles/hr`) 的速度，请使用系数 2.23694。


### SpeedUnitLabel

速度单位标签，默认为 `m/s`。与 SpeedUnitFactor 配合使用。


