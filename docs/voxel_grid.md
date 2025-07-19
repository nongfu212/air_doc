

AirSim提供了一种功能，可以直接从虚幻引擎构建世界的真实体素栅格。体素栅格是给定世界/地图的占用表示，通过离散化为特定大小的单元；以及如果该特定位置被占用，则记录体素。


构建体素网格的逻辑在`WorldSimApi.cpp->createVoxelGrid()`中。目前，假设体素网格是一个立方体，来自Python的API调用具有以下结构：

```
simCreateVoxelGrid(self, position, x, y, z, res, of)

position (Vector3r): Global position around which voxel grid is centered in m
x, y, z (float): Size of each voxel grid dimension in m
res (float): Resolution of voxel grid in m
of (str): Name of output file to save voxel grid as
```

在 `createVoxelGrid()` 中，返回占用率的主虚幻引擎函数是 [OverlapBlockingTestByChannel](https://docs.unrealengine.com/en-US/API/Runtime/Engine/Engine/UWorld/OverlapBlockingTestByChannel/index.html) 。

```
OverlapBlockingTestByChannel(position, rotation, ECollisionChannel, FCollisionShape, params);
```

在希望将贴图离散化到的所有“单元”的位置上调用该函数，并将返回的占用结果收集到数组`voxel_grid_`中。单元占用值的索引遵循 [binvox](https://www.patrickmin.com/binvox/binvox.html) 格式的约定。

```
for (float i = 0; i < ncells_x; i++) {
    for (float k = 0; k < ncells_z; k++) {
        for (float j = 0; j < ncells_y; j++) {
            int idx = i + ncells_x * (k + ncells_z * j);
            FVector position = FVector((i - ncells_x /2) * scale_cm, (j - ncells_y /2) * scale_cm, (k - ncells_z /2) * scale_cm) + position_in_UE_frame;
            voxel_grid_[idx] = simmode_->GetWorld()->OverlapBlockingTestByChannel(position, FQuat::Identity, ECollisionChannel::ECC_Pawn, FCollisionShape::MakeBox(FVector(scale_cm /2)), params);
        }
    }
}
```

在所有离散化单元上迭代计算映射的占用率，这可以使其成为依赖于单元的分辨率和被测量区域的总大小的密集操作。如果用户感兴趣的地图变化不大，则可以在此地图上运行一次体素栅格操作，并保存体素栅格并重新使用它。为了提高性能或使用动态环境，我们建议对机器人周围的小区域运行体素栅格生成；并随后将其用于局部规划目的。



体素栅格以binvox格式存储，然后用户可以将其转换为octomap.bt或任何其他相关的所需格式。随后，可以在映射/规划中使用这些体素栅格/八进制映射。一个漂亮的小实用程序是 [viewvox](https://www.patrickmin.com/viewvox/) ，它可以可视化创建的 binvox 文件。类似地，`binvox2bt` 可以将binvox转换为octomap文件。


##### 块地图(Blocks)中的体素栅格示例：
![image](images/voxel_grid.png)

##### 块地图（Blocks）体素栅格转换为Octomap格式（在rviz中可视化）：
![image](images/octomap.png)

例如，一旦 Blocks 环境启动并运行，就可以如下构造体素栅格：

```
import airsim
c = airsim.VehicleClient()
center = airsim.Vector3r(0, 0, 0)
output_path = os.path.join(os.getcwd(), "map.binvox")
c.simCreateVoxelGrid(center, 100, 100, 100, 0.5, output_path)
```

并通过`viewvox map.binvox`可视化。

