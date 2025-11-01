# 如何在 AIR 中访问网格

Air 支持访问构成场景的静态网格。


## 网格结构体
每个网格都用以下结构体表示。
```cpp
struct MeshPositionVertexBuffersResponse {

	Vector3r position;
	Quaternionr orientation;

	std::vector<float> vertices;
	std::vector<uint32_t> indices;
	std::string name;
};
```

* 位置和朝向均采用引擎坐标系。
* 网格本身是一个三角形网格，由顶点和索引表示。
	* 这种三角形网格类型通常被称为 [面顶点(Face-Vertex)](https://en.wikipedia.org/wiki/Polygon_mesh#Face-vertex_meshes) 网格。这意味着每个索引三元组都保存着构成三角形/面的顶点的索引。 
	* 所有顶点的 x、y、z 坐标都存储在一个向量中。这意味着顶点向量是 N×3 的，其中 N 是顶点的数量。 
    * 顶点的位置是引擎坐标系中的全局位置。这意味着它们已经根据位置和方向进行了变换。

## 如何使用
获取场景网格的 API 非常简单。但是需要注意的是，该函数调用开销很大，因此应尽量避免调用。通常情况下，这没有问题，因为该函数仅访问静态网格，而对于大多数应用程序来说，这些网格在程序运行期间不会发生变化。

请注意，您需要使用第三方库或自定义代码才能与接收到的网格进行交互。下面我使用 [libigl](https://github.com/libigl/libigl) 的 Python 绑定来可视化接收到的网格。

```python
import airsim

AIRSIM_HOST_IP='127.0.0.1'

client = airsim.VehicleClient(ip=AIRSIM_HOST_IP)
client.confirmConnection()

# 通过此函数接收返回的网格列表。
meshes=client.simGetMeshPositionVertexBuffers()


index=0
for m in meshes:
    # 在 Blocks 环境中找到一个立方体网格。
    if 'cube' in m.name:
        # 从这里开始的代码依赖于 libigl。
        # libigl 使用 pybind11 封装 C++ 代码。
        # 因此，这里构建的 pyigl.so 库与示例代码位于同一目录下。
        # 之所以在此说明，是因为您自己的网格库代码也可能需要类似的实现。
        from pyigl import *
        from iglhelpers import *

        # 将列表转换为numpy数组
        vertex_list=np.array(m.vertices,dtype=np.float32)
        indices=np.array(m.indices,dtype=np.uint32)

        num_vertices=int(len(vertex_list)/3)
        num_indices=len(indices)

        # Libigl 要求形状为 Nx3，其中 N 为顶点数或索引数。
        # 它还要求顶点的实际类型为 double（float64），三角形/索引的实际类型为 int64。
        vertices_reshaped=vertex_list.reshape((num_vertices,3))
        indices_reshaped=indices.reshape((int(num_indices/3),3))
        vertices_reshaped=vertices_reshaped.astype(np.float64)
        indices_reshaped=indices_reshaped.astype(np.int64)

        # Libigl 函数用于转换为 Eigen 内部格式
        v_eig=p2e(vertices_reshaped)
        i_eig=p2e(indices_reshaped)

        # 查看网格
        viewer = igl.glfw.Viewer()
        viewer.data().set_mesh(v_eig,i_eig)
        viewer.launch()
        break
```
