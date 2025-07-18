# 在 Windows 上使用 FST 无人驾驶环境构建 AirSim

## 安装虚幻引擎

1. [下载](https://www.unrealengine.com/download) Epic Games 启动器。虽然虚幻引擎是开源的，可以免费下载，但仍然需要注册。
2. 运行 Epic Games 启动器，从左侧打开“库”选项卡，点击“添加版本”，此时会显示下载虚幻 4.18 的选项，如下所示。如果您安装了多个版本的虚幻引擎，请点击相应版本“启动”按钮旁边的向下箭头，确保 4.18 为“当前版本”。

!!! 注意
    本项目仅适用于 UE 4.18。如果您拥有 UE 4.16 或更早版本的项目，请参阅 [升级指南](https://github.com/Microsoft/AirSim/blob/master/docs/unreal_upgrade.md) 来升级您的项目。


## 构建 AirSim

1. 您将需要 Visual Studio 2017（确保安装 VC++ 和 Windows SDK 8.x）。
2. 启动 VS 2017 的 `x64 Native Tools Command Prompt`。为仓库创建一个文件夹并运行 `git clone https://github.com/Microsoft/AirSim.git`。
3. 从命令行运行 `build.cmd`。这将在 `Unreal\Plugins` 文件夹中创建可立即使用的插件，可将其放入任何 Unreal 项目中。


## 创建和设置虚幻环境

最后，您需要一个虚幻项目来托管您的车辆环境。请按照以下列表创建一个模拟 FSD 比赛的环境。

1. 确保已构建 AirSim 并已安装 Unreal 4.18，如上所述。
2. 打开 UE 编辑器，选择“新建项目(New Project)”。选择“空白(Blank)”，不包含任何启动内容。选择项目位置，输入项目名称（例如 `ProjectName`），然后点击“创建项目”。

![](../images/wiki/unreal_new_project.png)
