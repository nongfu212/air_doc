
# 为 AirSim 设置 Blocks 环境

Blocks 环境位于代码库的`Unreal/Environments/Blocks`文件夹中，其设计非常轻量。这意味着它非常基础，但运行速度很快。


以下是启动和运行 Blocks 环境的快速步骤：

## Windows

1. 确保你已经[安装了 Unreal 并构建了 AirSim](build_windows.md)。
2. 导航到文件夹`AirSim\Unreal\Environments\Blocks`，双击 Blocks.sln 文件以在 Visual Studio 中打开。默认情况下，此项目配置为 Visual Studio 2019。但是，如果您想为 Visual Studio 2022 生成此项目，请在虚幻编辑器中转到“编辑->编辑器首选项->源代码”，并在“源代码编辑器”设置中选择“Visual Studio 2022”。 
3. 确保`Blocks`项目是启动项目，构建配置设置为`DebugGame_Editor`和`Win64`。按 F5 运行。
4. 按下虚幻编辑器中的“播放”按钮，您将看到类似以下视频的内容。另请参阅[如何使用 AirSim](https://github.com/Microsoft/AirSim/#how-to-use-it)。 

### 更改代码并重建

对于 Windows，您只需在 Visual Studio 中更改代码，按 F5 并重新运行即可。`AirSim\Unreal\Environments\Blocks`文件夹中有一些批处理文件，可用于同步代码、清理代码等。


## Linux
1. 确保你已经[构建了虚幻引擎和 AirSim](build_linux.md)。 
2. 导航到您的 UnrealEngine repo 文件夹并运行`Engine/Binaries/Linux/UE4Editor`，这将启动虚幻编辑器。 
3. 首次启动时，您可能在 UE4 编辑器中看不到任何项目。点击“项目”选项卡，点击“浏览”按钮，然后导航到`AirSim/Unreal/Environments/Blocks/Blocks.uproject`。 
4. 如果系统提示您版本不兼容或转换不兼容，请选择“就地转换”，该选项通常位于“更多”选项下。如果系统提示您缺少模块，请确保选择“否”，以免退出。
5. 最后，当提示是否构建 AirSim 时，选择“是”。现在可能需要一点时间，所以去喝杯咖啡吧 :)。
6. 按下虚幻编辑器中的“播放”按钮，您将看到类似以下视频的内容。另请参阅[如何使用 AirSim](https://github.com/microsoft/AirSim/#how-to-use-it)。 

[![Blocks Demo Video](images/blocks_video.png)](https://www.youtube.com/watch?v=-r_QGaxMT4A)

### 更改代码并重建

对于 Linux，请在 AirLib 或 Unreal/Plugins 文件夹中更改代码，然后运行 `./build.sh` 进行重建。此步骤还会将构建输出复制到 Blocks 示例项目中。然后，您可以再次按照上述步骤重新运行。


## 选择您的车辆：汽车或多旋翼飞行器

AirSim 默认会生成多旋翼飞行器。您可以轻松将其更改为汽车，并使用 AirSim 的所有功能。请参阅 [使用汽车](using_car.md) 指南。


## FAQ
#### 我看到有关“_BuitData”文件丢失的警告。

这些是中间文件，您可以放心地忽略它。
