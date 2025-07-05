# 实施无人机调查脚本

您是否曾经想过拍摄一组特定地点的俯视图照片？`AirSimClient` Python API 让这一切变得非常简单。[代码请点击此处](https://github.com/microsoft/AirSim/blob/master/PythonClient/multirotor/survey.py) 查看。

![](../images/wiki/survey.png)

假设我们需要以下变量：

| 变量          | 描述         |
|-------------|------------|
| `boxsize` | 待测量方箱的整体尺寸 |
| `stripewidth` | 例如，泳道之间的间隔有多远，这取决于相机镜头的类型。 |
| `altitude` | 飞行调查的高度。 |
| `speed` | 调查的速度取决于相机拍摄照片的速度。 |


因此，我们可以使用以下代码计算方形路径框：

```python
        path = []
        distance = 0
        while x < self.boxsize:
            distance += self.boxsize 
            path.append(Vector3r(x, self.boxsize, z))
            x += self.stripewidth            
            distance += self.stripewidth 
            path.append(Vector3r(x, self.boxsize, z))
            distance += self.boxsize 
            path.append(Vector3r(x, -self.boxsize, z)) 
            x += self.stripewidth  
            distance += self.stripewidth 
            path.append(Vector3r(x, -self.boxsize, z))
            distance += self.boxsize 
```

假设我们从盒子的角落开始，将 x 增加条纹宽度，然后将 -boxsize 的整个 y 维度飞到 +boxsize，因此在这种情况下 boxsize 是我们将要覆盖的实际盒子大小的一半。


一旦我们有了 Vector3r 对象列表，我们就可以通过以下调用非常简单地执行此路径：

```python
result = self.client.moveOnPath(path, self.velocity, trip_time, DrivetrainType.ForwardOnly, 
                                YawMode(False,0), lookahead, 1)
```

我们可以通过将路径距离除以飞行速度来计算合适的 trip_time 超时时间。

这里平滑路径插值所需的前瞻 `lookahead` 可以通过使用 `self.velocity + (self.velocity/2)` 根据速度计算得出。前瞻次数越多，转弯越平滑。这就是为什么您在屏幕截图中看到每个泳道的末端都是平滑的转弯，而不是方框图案。这也可以使您的相机拍摄的视频更加流畅。

就是这样，很简单吧？

现在，您当然可以为其添加更多智能功能，使其避开地图上已知的障碍物，使其在山坡上爬上爬下，以便您勘察斜坡等等。乐趣无穷。
