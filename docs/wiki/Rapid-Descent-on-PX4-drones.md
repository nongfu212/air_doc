# PX4 无人机快速下降

你可能已经注意到，对于基于 PX4 的无人机，当你发出着陆命令时，它会缓慢而小心地下降。现在 PX4 有一个设置可以提高下降速度，但随后它会重重地撞到地面。我们真正想要的是快速下降到离地面某个安全距离，比如 5 米，然后从那里切换到 PX4 着陆，以获得如羽毛般轻柔的落地感。

让我们尝试使用以下 Python 代码来实现这一点：

```python
from AirSimClient import *
client = MultirotorClient()
client.enableApiControl(True)
client.moveToPosition(0, 0, -5, 2)
client.land()
```

因此，我们尝试以每秒 2 米的速度快速下降，然后当达到 5 米时切换到自动着陆。

这应该可行，但 PX4 也内置了最大垂直下降速度限制。因此，要启用上述技巧，您需要设置以下参数：

```text
param set MPC_Z_VEL_MAX_DN 2
```

结果如下：

![](../images/wiki/rapid_descent.png)

你可以随意设置，还有一个 `MPC_Z_VEL_MAX_UP` 参数，方便你快速爬升。有些无人机可以以惊人的速度爬升。PX4 限制这些参数的唯一原因是，很多新手飞行员在没有这些限制的情况下会遇到麻烦。所以，在实际无人机上操作之前，请先在模拟器上尝试一下！
