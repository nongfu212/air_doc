# 无人机沿着路径移动(moveOnPath)演示

在 DroneShell 中添加了一个 moveOnPath 命令，它会调用 DroneControlBase::moveOnPath 方法。为了演示这一点，我从虚幻商城下载了 [Modular Neighborhood 包](https://www.unrealengine.com/marketplace/modular-neighborhood-pack) ，并将玩家的起始位置设置为以下位置：
```text
x=310.0 cm, y=11200.0 cm, z=235.0 cm
```

然后启动无人机并起飞，然后执行以下命令：
```text
Moveonpath -path 0,-256,-4,126,-256,-4,126,0,-4,-5,0,-4 -velocity 10 -lookahead 10
```
如果设置此 PX4 参数，则可以加快速度：
```text
param set SYS_MC_EST_GROUP 2
param set MPC_XY_VEL_MAX 20
param set MPC_XY_CRUISE 5
param set COM_OBL_ACT 1
param set COM_OBL_RC_ACT 5
param set NAV_RCL_ACT 0
param set NAV_DLL_ACT 0
```

结果如下，请看 [演示视频](https://youtu.be/9CkHgC0a2Xs) ：
![](../images/wiki/moveOnPath.jpg)



