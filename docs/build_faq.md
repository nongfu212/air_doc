# FAQ

---

## Windows 构建

* [如何强制 Unreal 使用 Visual Studio 2019？](#how-to-force-unreal-to-use-visual-studio-2019)
* [报错: 'where' is not recognized as an internal or external command](#i-get-error-where-is-not-recognized-as-an-internal-or-external-command)
* [报错：`<MyProject> could not be compiled. Try rebuilding from source manually`](#im-getting-error-myproject-could-not-be-compiled-try-rebuilding-from-source-manually)
* [当运行 build.cmd 时报错：`error C100 : An internal error has occurred in the compiler`](#i-get-error-c100--an-internal-error-has-occurred-in-the-compiler-when-running-buildcmd)
* [报错："'corecrt.h': No such file or directory" or "Windows SDK version 8.1 not found"](#i-get-error-corecrth-no-such-file-or-directory-or-windows-sdk-version-81-not-found)
* [如何将 PX4 固件与 AirSim 一起使用？](#how-do-i-use-px4-firmware-with-airsim)
* [在 Visual Studio 中做了更改，但没有效果](#i-made-changes-in-visual-studio-but-there-is-no-effect)
* [Unreal 仍然使用 VS2015，否则我会收到一些链接错误](#unreal-still-uses-vs2015-or-im-getting-some-link-error)

---

## Linux 构建

* [I'm getting error `<MyProject> could not be compiled. Try rebuilding from source manually`.](#im-getting-error-myproject-could-not-be-compiled-try-rebuilding-from-source-manually)
* [Unreal crashed! How do I know what went wrong?](#unreal-crashed-how-do-i-know-what-went-wrong)
* [How do I use an IDE on Linux?](#how-do-i-use-an-ide-on-linux)
* [Can I cross compile for Linux from a Windows machine?](#can-i-cross-compile-for-linux-from-a-windows-machine)
* [What compiler and stdlib does AirSim use?](#what-compiler-and-stdlib-does-airsim-use)
* [What version of CMake does the AirSim build use?](#what-version-of-cmake-does-the-airsim-build-use)
* [Can I compile AirSim in BashOnWindows?](#can-i-compile-airsim-in-bashonwindows)
* [Where can I find more info on running Unreal on Linux?](#where-can-i-find-more-info-on-running-unreal-on-linux)

---

## 其他

* [打包 AirSim](#packaging-a-binary-including-the-airsim-plugin)

---

<!-- ======================================================================= -->
## Windows 构建
<!-- ======================================================================= -->

###### 如何强制 Unreal 使用 Visual Studio 2019？

>If the default `update_from_git.bat` file results in VS 2017 project, then you may need to run the `C:\Program Files\Epic Games\UE_4.25\Engine\Binaries\DotNET\UnrealBuildTool.exe` tool manually, with the command line options `-projectfiles -project=<your.uproject>  -game -rocket -progress -2019`.
>
>If you are upgrading from 4.18 to 4.25 you may also need to add `BuildSettingsVersion.V2` to your `*.Target.cs` and `*Editor.Target.cs` build files, like this:
>
>```c#
>	public AirSimNHTestTarget(TargetInfo Target) : base(Target)
>	{
>		Type = TargetType.Game;
>		DefaultBuildSettings = BuildSettingsVersion.V2;
>		ExtraModuleNames.AddRange(new string[] { "AirSimNHTest" });
>	}
>```
>
>You may also need to edit this file:
>
>```
>"%APPDATA%\Unreal Engine\UnrealBuildTool\BuildConfiguration.xml
>```
>
>And add this Compiler version setting:
>
>```xml
><Configuration xmlns="https://www.unrealengine.com/BuildConfiguration">
>  <WindowsPlatform>
>    <Compiler>VisualStudio2019</Compiler>
>  </WindowsPlatform>
></Configuration>
>```

<!-- ======================================================================= -->

###### 报错: 'where' is not recognized as an internal or external command

>您必须将 `C:\WINDOWS\SYSTEM32` 添加到您的 PATH 环境变量中。 

<!-- ======================================================================= -->

###### 报错 `<MyProject> could not be compiled. Try rebuilding from source manually`

>当出现编译错误时，就会发生这种情况。日志存储在 `<My-Project>\Saved\Logs` 中，可用于查找问题。 
>
>一个常见问题可能是 Visual Studio 版本冲突，AirSim 使用的是 VS 2019，而 UE 使用的是 VS 2017，可以通过在日志文件中搜索`2017`来找到。在这种情况下，请参阅上面的答案。
>
>如果您修改了 AirSim 插件文件，那么您可以右键单击 `.uproject` 文件，选择`Generate Visual Studio solution file`，然后在 VS 中打开 `.sln` 文件以修复错误并再次构建。

<!-- ======================================================================= -->

###### I get `error C100 : An internal error has occurred in the compiler` when running build.cmd

>We have noticed this happening with VS version `15.9.0` and have checked-in a workaround in AirSim code. If you have this VS version, please make sure to pull the latest AirSim code.

<!-- ======================================================================= -->

###### 报错："'corecrt.h': No such file or directory" or "Windows SDK version 8.1 not found"

>Very likely you don't have [Windows SDK](https://developercommunity.visualstudio.com/content/problem/3754/cant-compile-c-program-because-of-sdk-81cant-add-a.html) installed with Visual Studio.

<!-- ======================================================================= -->

###### 如何将 PX4 固件与 AirSim 一起使用？

>默认情况下，AirSim 使用其内置固件 [simple_flight](simple_flight.md) 。如果您只想使用它，则无需进行其他设置。如果您想改用 PX4，请参阅 [本指南](px4_setup.md) 。 

<!-- ======================================================================= -->

###### 在 Visual Studio 中做了更改，但没有效果

>有时，如果仅更改头文件，Unreal + VS 构建系统可能无法重新编译。为了确保重新编译，请将一些基于 Unreal 的 cpp 文件（例如 AirSimGameMode.cpp）设置为“dirty”。 

<!-- ======================================================================= -->

###### Unreal 仍然使用 VS2015，否则我会收到一些链接错误

>运行多个版本的 VS 可能会导致编译 UE 项目时出现问题。其中一个问题是 UE 会尝试使用旧版本的 VS 进行编译，而旧版本的 VS 可能无法正常工作。虚幻引擎中有两个设置，一个用于引擎，一个用于项目，用于调整要使用的 VS 版本。 
>
>1. Edit -> Editor preferences -> General -> Source code -> Source Code Editor
>2. Edit -> Project Settings -> Platforms -> Windows -> Toolchain ->CompilerVersion
>
>在某些情况下，这些设置仍然不会产生预期的结果，并且可能会产生如下错误：LINK:致命错误 LNK1181:无法打开输入文件“ws2_32.lib” 
>
>为了解决此类问题，可以采用以下步骤：
>
>1. 使用 [VisualStudioUninstaller](https://github.com/Microsoft/VisualStudioUninstaller/releases) 卸载所有旧版本的 VS
>2. Repair/Install VS 2019
>3. 重启机器并安装 Epic 启动器和所需版本的引擎

---

## Linux 构建
<!-- ======================================================================= -->

###### 报错：`<MyProject> could not be compiled. Try rebuilding from source manually`.

>This could either happen because of compile error or the fact that your gch files are outdated. Look in to your console window. Do you see something like below?
>
>`fatal error: file '/usr/include/linux/version.h''/usr/include/linux/version.h' has been modified since the precompiled header`
>
>If this is the case then look for *.gch file(s) that follows after that message, delete them and try again. Here's [relevant thread](https://answers.unrealengine.com/questions/412349/linux-ue4-build-precompiled-header-fatal-error.html) on Unreal Engine forums.
>
>If you see other compile errors in console then open up those source files and see if it is due to changes you made. If not, then report it as issue on GitHub.

<!-- ======================================================================= -->

###### Unreal crashed! How do I know what went wrong?

>Go to the `MyUnrealProject/Saved/Crashes` folder and search for the file `MyProject.log` within its subdirectories. At the end of this file you will see the stack trace and messages.
>You can also take a look at the `Diagnostics.txt` file.

<!-- ======================================================================= -->

###### How do I use an IDE on Linux?

>You can use Qt Creator or CodeLite. Instructions for Qt Creator are available [here](https://docs.unrealengine.com/en-US/SharingAndReleasing/Linux/BeginnerLinuxDeveloper/SettingUpQtCreator/index.html).

<!-- ======================================================================= -->

###### Can I cross compile for Linux from a Windows machine?

>Yes, you can, but we haven't tested it. You can find the instructions [here](https://docs.unrealengine.com/latest/INT/Platforms/Linux/GettingStarted/index.html).

<!-- ======================================================================= -->

###### What compiler and stdlib does AirSim use?

>We use the same compiler that Unreal Engine uses, **Clang 8**, and stdlib, **libc++**. AirSim's `setup.sh` will automatically download them.

<!-- ======================================================================= -->

###### What version of CMake does the AirSim build use?

>3.10.0 or higher. This is *not* the default in Ubuntu 16.04 so setup.sh installs it for you. You can check your CMake version using `cmake --version`. If you have an older version, follow [these instructions](cmake_linux.md) or see the [CMake website](https://cmake.org/install/).

<!-- ======================================================================= -->

###### Can I compile AirSim in BashOnWindows?

>Yes, however, you can't run Unreal from BashOnWindows. So this is kind of useful to check a Linux compile, but not for an end-to-end run.
>See the [BashOnWindows install guide](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide).
>Make sure to have the latest version (Windows 10 Creators Edition) as previous versions had various issues.
>Also, don't invoke `bash` from `Visual Studio Command Prompt`, otherwise CMake might find VC++ and try and use that!

<!-- ======================================================================= -->

###### Where can I find more info on running Unreal on Linux?
>Start here: [Unreal on Linux](https://docs.unrealengine.com/latest/INT/Platforms/Linux/index.html)
>[Building Unreal on Linux](https://wiki.unrealengine.com/Building_On_Linux#Clang)
>[Unreal Linux Support](https://wiki.unrealengine.com/Linux_Support)
>[Unreal Cross Compilation](https://wiki.unrealengine.com/Compiling_For_Linux)

---

## 其他
<!-- ======================================================================= -->

###### Packaging a binary including the AirSim plugin

>In order to package a custom environment with the AirSim plugin, there are a few project settings that are necessary for ensuring all required assets needed for AirSim are included inside the package. Under `Edit -> Project Settings... -> Project -> Packaging`, please ensure the following settings are configured properly:
>
>- `List of maps to include in a packaged build`: ensure one entry exists for `/AirSim/AirSimAssets` 
>- `Additional Asset Directories to Cook`: ensure one entry exists for `/AirSim/HUDAssets`
