# 向 AirSim 添加新的 API

添加新的 API 需要修改源代码。许多更改是机械的，并且是 AirSim 支持的各个抽象级别所必需的。下面列出了需要修改的主要文件，并附上了一些提交和 PR 以供演示。PR 或提交的特定部分可能在某些地方有链接，但查看完整的 diff 有助于更好地了解工作流程。此外，如果您不确定如何进行更改或需要获取反馈，请随时提交问题或 PR 草稿。


## 实现 API

在添加包装器代码来调用和处理 API 之前，需要先实现它。具体实现的文件取决于它的具体功能。下面给出了一些示例，希望能帮助您入门。

### 基于车辆的 API

`moveByVelocityBodyFrameAsync` API for velocity-based movement in the multirotor's X-Y frame.

The main implementation is done in [MultirotorBaseApi.cpp](https://github.com/microsoft/AirSim/pull/3169/files#diff-29ac01a05077b6e8e1f09221a113f779c952a80dc8823725eb451a9fc5d7de5f), where most of the multirotor APIs are implemented.

In some cases, additional structures might be needed for storing data, [`getRotorStates` API](https://github.com/microsoft/AirSim/pull/3242) is a good example for this, here the `RotorStates` struct is defined in 2 places for conversion from RPC to internal code. It also requires modifications in AirLib as well as Unreal/Plugins for the implementation.

### 环境相关的 API

These APIs need to interact with the simulation environment itself, hence it's likely that it'll be implemented inside the `Unreal/Plugins` folder.

- `simCreateVoxelGrid` API to generate and save a binvox-formatted grid of the environment - [WorldSimApi.cpp](https://github.com/microsoft/AirSim/pull/3209/files#diff-89d4ec9b62486b1322e5ba2dd9936b13962f9ed113ec5e35a0678846889c7e2d)

- `simAddVehicle` API to create vehicles at runtime - [SimMode*, WorldSimApi files](https://github.com/microsoft/AirSim/pull/2390/files#diff-fcc0aa1fbc74a924fccd12589295aceeea59074c94256eccba7df3ce85d3a26c)

### 物理相关的 API

`simSetWind` API 展示了一个修改物理行为并为其添加 API + 设置字段的示例。有关代码的详细信息，请参阅 [PR](https://github.com/microsoft/AirSim/pull/2867)。


## RPC 包装器

The APIs use [msgpack-rpc protocol](https://github.com/msgpack-rpc/msgpack-rpc) over TCP/IP through [rpclib](http://rpclib.net/) developed by [TamÃ¡s Szelei](https://github.com/sztomi) which allows you to use variety of programming languages including C++, C#, Python, Java etc. When AirSim starts, it opens port 41451 (this can be changed via [settings](settings.md)) and listens for incoming request. The Python or C++ client code connects to this port and sends RPC calls using [msgpack serialization format](https://msgpack.org).

To add the RPC code to call the new API, follow the steps below. Follow the implementation of other APIs defined in the files.

1. Add an RPC handler in the server which calls your implemented method in [RpcLibServerBase.cpp](https://github.com/microsoft/AirSim/blob/main/AirLib/src/api/RpcLibServerBase.cpp). Vehicle-specific APIs are in their respective vehicle subfolder.

2. Add the C++ client API method in [RpcClientBase.cpp](https://github.com/microsoft/AirSim/blob/main/AirLib/src/api/RpcLibClientBase.cpp)

3. Add the Python client API method in [client.py](https://github.com/microsoft/AirSim/blob/main/PythonClient/airsim/client.py). If needed, add or modify a structure definition in [types.py](https://github.com/microsoft/AirSim/blob/main/PythonClient/airsim/types.py)

## 测试

需要进行测试以确保 API 能够按预期运行。为此，您必须使用源代码构建的 AirSim 和 Blocks 环境。此外，如果使用 Python API，则必须使用源代码中的 `airsim` 软件包，而不是 PyPI 软件包。以下介绍了 2 种使用源代码软件包的方法

1. 使用 [setup_path.py](https://github.com/microsoft/AirSim/blob/main/PythonClient/multirotor/setup_path.py) 。它将设置路径，以便使用本地 airsim 模块而不是 pip 安装的软件包。许多脚本都使用这种方法，因为用户除了运行脚本之外无需执行任何其他操作。将示例脚本放在 `PythonClient` 中的某个文件夹中，例如 `multirotor`、`car` 等。您也可以创建一个单独的文件夹，然后从其他文件夹复制 `setup_path.py` 文件。在文件中的 `import airsim` 之前添加 `import setup_path`。现在将使用最新的主 API（或当前检出的任何分支）。 

2. 使用 [本地项目 pip install](https://pip.pypa.io/en/stable/cli/pip_install/#local-project-installs) 。常规安装会创建当前源的副本并使用它，而可编辑安装（在 `PythonClient` 文件夹中执行 `pip install -e .` ）则会在 Python API 文件发生更改时更改包。在处理多个分支或 API 尚未最终确定时，可编辑安装更具优势。

建议使用虚拟环境来处理 Python 打包，以免破坏任何现有设置。

提交 PR 时，请务必遵循 [编码指南](coding_guidelines.md) 。此外，请在 Python 文件中添加 API 的文档字符串，并包含脚本中所需的所有示例脚本和设置。

