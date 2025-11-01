
Air 提供了一个基于 Python 的事件相机模拟器，旨在实现性能和与模拟一起实时运行的能力。


#### 事件相机

事件相机是一种特殊的视觉传感器，它测量对数亮度的变化，并仅报告“事件”。每个事件由一组四个值组成，每当对数亮度的绝对变化超过某个阈值时就会生成。事件包含测量的时间戳、像素位置（x 和 y 坐标）和极性：根据对数亮度是增加还是减少，极性为 +1/-1。大多数事件相机的时间分辨率为微秒级，这使其速度明显快于 RGB 传感器，并且还具有高动态范围和低运动模糊的特点。有关事件相机的更多详细信息，请参阅 [RPG-UZH 的本教程](http://rpg.ifi.uzh.ch/docs/scaramuzza/Tutorial_on_Event_Cameras_Scaramuzza.pdf) 。


#### Air 事件模拟器

Air 事件模拟器使用两张连续的 RGB 图像（转换为灰度图像），并根据两幅图像之间对数亮度的变化计算过渡期间可能发生的“历史事件”。这些事件以字节流的形式报告，格式如下：

`<x> <y> <timestamp> <pol>`

x 和 y 分别代表事件触发的像素位置，timestamp 是以微秒为单位的全局时间戳，pol 的值根据亮度是增加还是减少而取 +1 或 -1。除了这个字节流之外，还会构建一个二维帧上的事件累积图，称为“事件图像”，其中 +1 事件显示为红色像素，-1 事件显示为蓝色像素。事件图像示例如下所示：

![image](images/event_sim.png)

#### 使用

运行事件模拟器并与 AirSim 配合使用的示例脚本位于 [test_event_sim.py](https://github.com/microsoft/AirSim/blob/main/PythonClient/eventcamera_sim/test_event_sim.py) 。以下可选命令行参数可以传递给此脚本。

```
args.width, args.height (float): 模拟事件相机的分辨率
args.save (bool): 是否将事件数据保存到文件；args.debug（布尔值）：是否将模拟事件显示为图像, 
args.debug (bool): 是否将模拟事件显示为图像
```

实际事件模拟的实现是用 Python 和 numba 编写的，位于 [event_simulator.py](https://github.com/microsoft/AirSim/blob/main/PythonClient/eventcamera_sim/event_simulator.py) 。事件模拟器按如下方式初始化，参数控制相机的分辨率。

```
from event_simulator import *
ev_sim = EventSimulator(W, H)
```

事件的实际计算是通过 `image_callback` 函数触发的，该函数会在每次获取新的 RGB 图像时执行。由于缺少“先前”的图像，该函数首次调用时会作为事件模拟器的初始化。

```
event_img, events = ev_sim.image_callback(img, ts_delta)
```
此函数类似于回调函数（每次收到新图像时都会调用），它返回一个包含 +1/-1 值的一维数组，表示事件图像，仅指示每个像素是否检测到事件，而不指示事件发生的时间/数量。此一维数组可以转换为红/蓝事件图像，如函数 `convert_event_img_rgb` 所示。`events` 是一个 numpy 数组，其中包含事件，每个事件的格式为 `<x> <y> <timestamp> <pol>`。

通过此函数，事件模拟器计算过去图像和当前图像之间的差异，并计算事件流，然后将其作为 NumPy 数组返回。之后，可以将此数组追加到文件中。

为了达到事件模拟的视觉保真度/性能水平，可以调整许多参数。主要调整因素如下：

1. 相机的分辨率。
2. 用于确定检测到的变化是否计为事件的对数亮度阈值(threshold, `TOL`)。

!!! 注意：
    目前每对图像生成的事件数量也有最大限制，该限制也可以进行调整。


#### 算法
事件模拟器的工作原理大致遵循以下操作：
1. 计算当前帧和前一帧的对数强度之差。 
2. 遍历所有像素，根据对数强度变化的阈值计算每个像素的极性。
3. 根据强度变化超过阈值的程度，确定每个像素要触发的事件数。设 $N_{max}$ 为单个像素可发生的最大事件数，则在像素位置 $u$ 处要模拟的总触发次数为 $N_e(u) = min(N_{max}, \frac{\Delta L(u)}{TOL})$ 
4. 通过对前一帧图像和当前帧图像之间经过的时间间隔进行插值，确定每个插值事件的时间戳。
$t = t_{prev} + \frac{\Delta T}{N_e(u)}$  
5. 通过模拟每个像素的事件生成输出字节流，并按时间戳排序。
