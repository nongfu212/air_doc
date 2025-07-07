# 向 AirSim 添加新的 API

添加新的 API 需要修改源代码。许多更改是机械的，并且是 AirSim 支持的各个抽象级别所必需的。下面列出了需要修改的主要文件，并附上了一些提交和 PR 以供演示。PR 或提交的特定部分可能在某些地方有链接，但查看完整的 diff 有助于更好地了解工作流程。此外，如果您不确定如何进行更改或需要获取反馈，请随时提交问题或 PR 草稿。


## 实现 API

在添加包装器代码来调用和处理 API 之前，需要先实现它。具体实现的文件取决于它的具体功能。下面给出了一些示例，希望能帮助您入门。

### 基于车辆的 API

`moveByVelocityBodyFrameAsync` API 用于多旋翼飞行器 X-Y 框架中基于速度的运动。


主要实现在 [MultirotorBaseApi.cpp](https://github.com/microsoft/AirSim/pull/3169/files#diff-29ac01a05077b6e8e1f09221a113f779c952a80dc8823725eb451a9fc5d7de5f) 中完成，其中实现了大多数多旋翼 API。


在某些情况下，可能需要额外的结构来存储数据，[`getRotorStates` API](https://github.com/microsoft/AirSim/pull/3242) 就是一个很好的例子，这里 `RotorStates` 结构体在两处被定义，用于从 RPC 转换为内部代码。此外，它还需要在 AirLib 以及 Unreal/Plugins 中进行修改才能实现。




### 环境相关的 API

这些 API 需要与模拟环境本身交互，因此很可能在 `Unreal/Plugins` 文件夹中实现。


- `simCreateVoxelGrid` API 用于生成并保存 binvox 格式的环境网格 - [WorldSimApi.cpp](https://github.com/microsoft/AirSim/pull/3209/files#diff-89d4ec9b62486b1322e5ba2dd9936b13962f9ed113ec5e35a0678846889c7e2d) 

- `simAddVehicle` API 用于在运行时创建车辆 - [SimMode*, WorldSimApi 文件](https://github.com/microsoft/AirSim/pull/2390/files#diff-fcc0aa1fbc74a924fccd12589295aceeea59074c94256eccba7df3ce85d3a26c) 


### 物理相关的 API

`simSetWind` API 展示了一个修改物理行为并为其添加 API + 设置字段的示例。有关代码的详细信息，请参阅 [PR](https://github.com/microsoft/AirSim/pull/2867)。


## RPC 包装器

这些 API 通过 [TamÃ¡s Szelei](https://github.com/sztomi) 开发的 [rpclib](http://rpclib.net/) 使用 TCP/IP 上的 [msgpack-rpc 协议](https://github.com/msgpack-rpc/msgpack-rpc) ，该库允许您使用多种编程语言，包括 C++、C#、Python、Java 等。AirSim 启动时，会打开 41451 端口（可通过 [设置](settings.md) 更改）并监听传入请求。Python 或 C++ 客户端代码连接到此端口，并使用 [msgpack 序列化格式](https://msgpack.org) 发送 RPC 调用。


要添加 RPC 代码来调用新的 API，请按照以下步骤操作。其他 API 的实现请参见文件中定义的部分。


1. 在服务器中添加一个 RPC 处理程序，该处理程序会调用您在 [RpcLibServerBase.cpp](https://github.com/microsoft/AirSim/blob/main/AirLib/src/api/RpcLibServerBase.cpp) 中实现的方法。特定于车辆的 API 位于其各自的 Vehicle 子文件夹中。 

2. 在 [RpcClientBase.cpp](https://github.com/microsoft/AirSim/blob/main/AirLib/src/api/RpcLibClientBase.cpp) 中添加 C++ 客户端 API 方法

3. 在 [client.py](https://github.com/microsoft/AirSim/blob/main/PythonClient/airsim/client.py) 中添加 Python 客户端 API 方法。如果需要，请在 [types.py](https://github.com/microsoft/AirSim/blob/main/PythonClient/airsim/types.py) 中添加或修改结构体定义。 


## 测试

需要进行测试以确保 API 能够按预期运行。为此，您必须使用源代码构建的 AirSim 和 Blocks 环境。此外，如果使用 Python API，则必须使用源代码中的 `airsim` 软件包，而不是 PyPI 软件包。以下介绍了 2 种使用源代码软件包的方法

1. 使用 [setup_path.py](https://github.com/microsoft/AirSim/blob/main/PythonClient/multirotor/setup_path.py) 。它将设置路径，以便使用本地 airsim 模块而不是 pip 安装的软件包。许多脚本都使用这种方法，因为用户除了运行脚本之外无需执行任何其他操作。将示例脚本放在 `PythonClient` 中的某个文件夹中，例如 `multirotor`、`car` 等。您也可以创建一个单独的文件夹，然后从其他文件夹复制 `setup_path.py` 文件。在文件中的 `import airsim` 之前添加 `import setup_path`。现在将使用最新的主 API（或当前检出的任何分支）。 

2. 使用 [本地项目 pip install](https://pip.pypa.io/en/stable/cli/pip_install/#local-project-installs) 。常规安装会创建当前源的副本并使用它，而可编辑安装（在 `PythonClient` 文件夹中执行 `pip install -e .` ）则会在 Python API 文件发生更改时更改包。在处理多个分支或 API 尚未最终确定时，可编辑安装更具优势。

建议使用虚拟环境来处理 Python 打包，以免破坏任何现有设置。

提交 PR 时，请务必遵循 [编码指南](coding_guidelines.md) 。此外，请在 Python 文件中添加 API 的文档字符串，并包含脚本中所需的所有示例脚本和设置。

