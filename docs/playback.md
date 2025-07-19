# 回放

AirSim 支持回放使用 MavLinkTest 应用记录的 *.mavlink 日志文件中的高级命令，以便比较真实飞行和模拟飞行。[recording.mavlink](logs/recording.mavlink) 是使用真实无人机通过以下命令行捕获的日志文件示例：

```
MavLinkTest -serial:/dev/ttyACM0,115200 -logdir:. 
```

然后日志文件包含执行的命令，其中包括几个“轨道(orbit)”命令，生成的飞行 GPS 地图如下所示：


![real flight](images/RealFlight.png)

## 并排比较

现在，我们可以将 MavLinkTest 记录的 *.mavlink 日志文件复制到运行 Unreal 模拟器（带 AirSim 插件）的电脑上。当模拟器运行，并且无人机停在地图上足够进行相同操作的位置时，我们可以运行以下 MavLinkTest 命令行：

```
MavLinkTest -server:127.0.0.1:14550
```

这样就连接到模拟器了。现在你可以输入以下命令：

```
PlayLog recording.mavlink
```

您在真实无人机上执行的相同命令现在将在模拟器中再次播放。然后您可以按“t”键查看轨迹，它会显示真实无人机和模拟无人机的轨迹。每次再次按“t”键时，您可以重置线条，使它们同步到当前位置。这样，我就能捕捉到本次录制中执行的“轨道(orbit)”命令的并排轨迹，从而生成下面的图片。粉色线是模拟飞行，红色线是真实飞行：


![playback](images/Playback.png)


!!! 注意
    我使用模拟器中的“；”键通过键盘控制相机位置来拍摄这张照片。

## 参数

将模拟器设置为与真实无人机相同的一些飞行参数可能会有所帮助。例如，
在我的情况下，我使用了低于正常巡航速度、较慢的起飞速度，并且告诉模拟器
在解除武装之前等待很长时间（COM_DISARM_LAND）并关闭安全开关 NAV_RCL_ACT 和 NAV_DLL_ACT
（在真实无人机上`不要`这样做）会有所帮助。

```
param MPC_XY_CRUISE 2
param MPC_XY_VEL_MAX 2
param MPC_TKO_SPEED 1
param COM_DISARM_LAND 60
param NAV_RCL_ACT 0
param NAV_DLL_ACT 0
```

