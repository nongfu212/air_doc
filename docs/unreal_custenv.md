# 创建和设置虚幻环境

本页包含使用 AirSim 设置虚幻环境的完整说明。虚幻商城 (Unreal Marketplace) 提供了 [多个环境](https://www.unrealengine.com/marketplace/content-cat/assets/environments) ，您只需几分钟即可开始使用。您也可以使用 [turbosquid.com](https://www.turbosquid.com/) 或 [cgitrader.com](https://www.cgtrader.com/) 等网站上提供的环境，但需要稍加努力（点击此处观看 [教程视频](https://www.youtube.com/watch?v=y09VbdQWvQY&feature) ）。此外，还有几个 [免费环境](https://github.com/Microsoft/AirSim/issues/424) 可供使用。


下面我们将使用虚幻市场中可免费下载的环境，名为 Landscape Mountain，但对于其他环境，步骤都是相同的。


## Linux 用户须知

Linux 上没有 `Epic Games Launcher`，这意味着如果您需要创建自定义环境，则需要 Windows 设备来执行此操作。获取 Unreal 项目文件夹后，只需将其复制到您的 Linux 设备上即可。

## 分步说明

1. 确保已构建 AirSim 并已安装 Unreal 4.27，如 [构建说明](build_windows.md) 中所述。
2. 在 `Epic Games Launcher` 中，点击“Learn”选项卡，向下滚动找到`Landscape Mountains`。点击`Create Project`并下载此内容（下载量约 2GB）。 

    ![current version](images/landscape_mountains.png)

3. 打开 `LandscapeMountains.uproject`，它应该启动虚幻编辑器。

    ![unreal editor](images/unreal_editor.png)
    
    !!!注意

        景观山脉(Landscape Mountains)项目最高支持虚幻引擎 4.24 版本。如果您尚未安装 4.24 版本，您将看到一个名为`Select Unreal Engine Version`(选择虚幻引擎版本)的对话框，其中包含一个下拉菜单，用于从已安装的版本中进行选择。选择 4.27 或更高版本，即可将项目迁移到支持的引擎版本。如果您已安装 4.24 版本，则可以手动迁移项目，方法是：在 Windows 资源管理器中导航到相应的 .uproject 文件，右键单击该文件，然后选择`Switch Unreal Engine version...`(切换虚幻引擎版本...)选项。

4. 从`File`菜单中选择`New C++ class`，类类型保留默认`None`，点击`Next`，保留默认名称`MyClass`，然后点击`Create Class`。我们需要这样做是因为 Unreal 要求项目中至少有一个源文件。它会触发编译并打开 Visual Studio 解决方案 `LandscapeMountains.sln`。

5. 前往你的 AirSim 仓库文件夹，将 `Unreal\Plugins` 文件夹复制到 `LandscapeMountains` 文件夹中。这样，你的 Unreal 项目就拥有了 AirSim 插件。

    !!!注意

        如果 AirSim 安装是全新安装的，即之前从未构建过，请确保在复制 `Unreal\Plugins` 文件夹之前，先从根目录运行一次 `build.cmd`，以便 `AirLib` 文件也包含在内。如果您在 Blocks 环境中进行了某些更改，请确保从 `Unreal\Environments\Blocks` 运行 `update_to_git.bat` 来更新 `Unreal\Plugins` 中的文件。

6. 编辑 `LandscapeMountains.uproject`，使其看起来像这样

    ```json
    {
    	"FileVersion": 3,
    	"EngineAssociation": "4.27",
    	"Category": "Samples",
    	"Description": "",
    	"Modules": [
    		{
    			"Name": "LandscapeMountains",
    			"Type": "Runtime",
    			"LoadingPhase": "Default",
    			"AdditionalDependencies": [
    				"AirSim"
    			]
    		}
    	],
    	"TargetPlatforms": [
    		"MacNoEditor",
    		"WindowsNoEditor"
    	],
    	"Plugins": [
    		{
    			"Name": "AirSim",
    			"Enabled": true
    		}
    	]
    }
    ```
    
7. 编辑 `Config\DefaultGame.ini` 并在末尾添加以下行：

    ```
    +MapsToCook=(FilePath="/AirSim/AirSimAssets")
    ```
    
    这样做会强制虚幻引擎将所有必要的 AirSim 内容包含在项目的打包版本中。

8. 关闭 Visual Studio 和`Unreal Editor`，然后在 Windows 资源管理器中右键单击 LandscapeMountains.u 项目，并选择`Generate Visual Studio Project Files`。此步骤将检测虚幻项目中的所有插件和源文件，并为 Visual Studio 生成 `.sln` 文件。

    ![regen](images/regen_sln.png)

    !!!提示

        如果缺少`Generate Visual Studio Project Files`选项，您可能需要重启计算机以使 Unreal Shell 扩展生效。如果仍然缺少此选项，请在虚幻编辑器中打开 LandscapeMountains.uproject，然后从`File`菜单中选择`Refresh Visual Studio Project`。 

9. 在 Visual Studio 中重新打开 `LandscapeMountains.sln`，并确保“DebugGame Editor”和“Win64”构建配置是活动构建配置。

    ![build config](images/vsbuild_config.png)

10. 按 `F5` 来运行。这将启动虚幻编辑器。虚幻编辑器允许您编辑环境、资源和其他游戏相关设置。您首先需要在环境中设置 `PlayerStart` 对象。在 Landscape Mountains 环境中，PlayerStart 对象已经存在，您可以在 `World Outliner` 中找到它。确保其位置设置如图所示。AirSim 插件将在此处创建并放置车辆。如果位置过高，车辆会在您按下播放键时立即坠落，从而产生潜在的随机行为。

    ![lm_player_start_pos.png](images/lm_player_start_pos.png)

11. 在如下所示的 `Window/World Settings` 中，将 `GameMode Override` 设置为 `AirSimGameMode`：

    ![sim_game_mode.png](images/sim_game_mode.png)

12. 在虚幻编辑器中，前往“编辑->编辑器偏好设置”，在“搜索”框中输入“CPU”，并确保“在后台运行时使用较少 CPU”(Use Less CPU when in Background) 未勾选。如果不勾选，当虚幻引擎窗口失去焦点时，虚幻引擎的速度将显著下降。

13. 请务必`保存`这些编辑。点击虚幻编辑器中的“播放”按钮。了解 [如何使用 AirSim](https://github.com/Microsoft/AirSim/#how-to-use-it) 。

恭喜！您现在可以在自己的虚幻环境中运行 AirSim 了。


## 选择您的车辆：汽车或多旋翼飞行器

默认情况下，AirSim 会提示用户选择要使用的车辆。您可以通过设置 [SimMode](settings.md#SimMode) 轻松更改此设置。请参阅 [使用车辆](using_car.md) 指南。


## Updating Your Environment to Latest Version of AirSim
Once you have your environment using above instructions, you should frequently update your local AirSim code to latest version from GitHub. Below are the instructions to do this:

1. First put [clean.bat](https://github.com/Microsoft/AirSim/blob/main/Unreal/Environments/Blocks/clean.bat) (or [clean.sh](https://github.com/Microsoft/AirSim/blob/main/Unreal/Environments/Blocks/clean.sh) for Linux users) in the root folder of your environment. Run this file to clean up all intermediate files in your Unreal project.
2. Do `git pull` in your AirSim repo followed by `build.cmd` (or `./build.sh` for Linux users).
3. Replace [your project]/Plugins folder with AirSim/Unreal/Plugins folder.
4. Right click on your .uproject file and chose "Generate Visual Studio project files" option. This is not required for Linux.

## FAQ

#### What are other cool environments?
[Unreal Marketplace](https://www.unrealengine.com/marketplace) has dozens of prebuilt extra-ordinarily detailed [environments](https://www.unrealengine.com/marketplace/content-cat/assets/environments) ranging from Moon to Mars and everything in between. The one we have used for testing is called [Modular Neighborhood Pack](https://www.unrealengine.com/marketplace/modular-neighborhood-pack)
but you can use any environment. Another free environment is [Infinity Blade series](https://www.unrealengine.com/marketplace/infinity-blade-plain-lands). Alternatively, if you look under the Learn tab in Epic Game Launcher, you will find many free samples that you can use. One of our favorites is "A Boy and His Kite" which is a 100 square miles of highly detailed environment (caution: you will need *very* beefy PC to run it!).

#### When I press Play button some kind of video starts instead of my vehicle.
If the environment comes with MatineeActor, delete it to avoid any startup demo sequences. There might be other ways to remove it as well, for example, click on Blueprints button, then Level Blueprint and then look at Begin Play event in Event Graph. You might want to disconnect any connections that may be starting "matinee".

#### Is there easy way to sync code in my Unreal project with code in AirSim repo?
Sure, there is! You can find bunch of `.bat` files (for linux, `.sh`) in `AirSim\Unreal\Environments\Blocks`. Just copy them over to your own Unreal project. Most of these are quite simple and self explanatory.

#### I get some error about map.
You might have to set default map for your project. For example, if you are using Modular Neighborhood Pack, set the Editor Starter Map as well as Game Default Map to Demo_Map in Project Settings > Maps & Modes.

#### I see "Add to project" option for environment but not "Create project" option.
In this case, create a new blank C++ project with no Starter Content and add your environment in to it.

#### I already have my own Unreal project. How do I use AirSim with it?
Copy the `Unreal\Plugins` folder from the build you did in the above section into the root of your Unreal project's folder. In your Unreal project's .uproject file, add the key `AdditionalDependencies` to the "Modules" object
as we showed in the `LandscapeMountains.uproject` above.
```json
"AdditionalDependencies": [
    "AirSim"
]
```

and the `Plugins` section to the top level object:
```json
"Plugins": [
    {
        "Name": "AirSim",
        "Enabled": true
    }
]
```
