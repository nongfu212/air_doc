# 升级到虚幻引擎 4.27

如果您已在虚幻引擎 4.25 上使用 AirSim，则这些说明适用。如果您从未安装过 AirSim，请参阅[如何获取](https://github.com/microsoft/airsim#how-to-get-it)。


**注意：**以下步骤将删除 AirSim 或 Unreal 文件夹中所有未保存的工作。

## 首先执行此操作

### 对于Windows用户
1. 安装带 C#、VC++、Python 的 Visual Studio 2022。
2. 通过 Epic Games Launcher 安装 UE 4.27。
3. 启动 `x64 Native Tools Command Prompt for VS 2022` 并导航到 AirSim 仓库。
4. 运行`clean_rebuild.bat`删除所有未选中/多余的内容并重建所有内容。
5. 另请参阅[在 Windows 上构建 AirSim](build_windows.md) 以了解更多信息。

### 对于Linux用户
1. 从您的 AirSim repo 文件夹中运行`clean_rebuild.sh`。
2. 重命名或删除虚幻引擎的现有文件夹。
3. 按照步骤 1 和 2 [安装 Unreal Engine 4.27](build_linux.md)。
4. 另请参阅[在 Linux 上构建 AirSim](build_linux.md) 以了解更多信息。


## 升级您的自定义虚幻项目
如果您使用旧版本的虚幻引擎创建了自己的虚幻项目，则需要将项目升级到虚幻引擎 4.27。为此，

1. 打开 .uproject 文件并查找行`"EngineAssociation"`并确保其读取方式类似于`"EngineAssociation": "4.27"`。
2. 删除虚幻项目文件夹中的`Plugins/AirSim`文件夹。
3. 转到您的 AirSim repo 文件夹并将`Unreal\Plugins`文件夹复制到您的 Unreal 项目的文件夹中。
4. 将 *.bat（或 Linux 的 *.sh）从 `Unreal\Environments\Blocks` 复制到项目文件夹。
5. 运行`clean.bat`（或 Linux 的`clean.sh`），然后运行`GenerateProjectFiles.bat`（仅适用于 Windows）。 

## FAQ

### 我有一个虚幻引擎项目，版本早于 4.16。该如何升级它？

#### 选项 1：重新创建项目

如果您的项目除了下载的环境之外没有任何代码或资产，那么您也可以简单地 [在虚幻 4.27 编辑器中重新创建项目](unreal_custenv.md)  ，然后从`AirSim/Unreal/Plugins`复制插件文件夹。


#### 选项 2：修改少量文件

虚幻引擎 4.15 之后的版本存在重大变更。因此，您需要修改虚幻引擎项目的`Source`文件夹中的 *.Build.cs 和 *.Target.cs 文件。那么，这些变更具体是什么呢？以下是概要，但您更应该参考[虚幻引擎官方 4.16 过渡帖](https://forums.unrealengine.com/showthread.php?145757-C-4-16-Transition-Guide)。


##### 在你的项目的 *.Target.cs 中
1. 将构造函数从 `public MyProject Target(TargetInfo Target)` 更改为 `public MyProjectTarget(TargetInfo Target) : base(Target)` 

2. 如果有的话，请删除 `Setup Binaries` 方法，并在上面的构造函数中添加以下行：`ExtraModuleNames.AddRange(new string[] { "MyProject" });` 

##### 在你的项目的 *.Build.cs 中

将构造函数从 `public MyProject(TargetInfo Target)` 更改为 `public MyProject(ReadOnlyTargetRules Target) : base(Target)` 。


##### 最后……

按照上述步骤继续升级。警告框可能只显示“打开副本”按钮。请勿点击该按钮。点击“更多选项”，即可显示更多按钮。选择`就地转换(Convert-In-Place option)`选项。*注意：*请务必先备份您的项目！如果您没有任何问题，就地转换应该会顺利完成，您现在就可以使用新版虚幻引擎了。


