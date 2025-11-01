# 欢迎来到 GazeboDrone

GazeboDrone 可以将 Gazebo 无人机连接到 AirSim 无人机，利用 Gazebo 无人机作为飞行动力学模型 (Flight Dynamic Model, FDM)，并借助 AirSim 生成环境传感器数据。它可用于**多旋翼飞行器**、**固定翼飞行器**或任何其他飞行器。


## 依赖

### Gazebo

请确保您已安装 Gazebo 依赖项：

```
sudo apt-get install libgazebo9-dev
```

### AirLib

本项目使用 GCC 8 构建，因此 AirLib 也需要使用 GCC 8 构建。请从 AirSim 根目录运行：

```
./clean.sh
./setup.sh
./build.sh --gcc
```

## AirSim 模拟器

AirSim UE 插件需要使用 clang 编译，因此您不能使用上一步编译的版本。您可以使用我们提供的 [二进制文件](https://pan.baidu.com/s/1n2fJvWff4pbtMe97GOqtvQ?pwd=hutb) （位于`software/air`目录下），也可以将 AirSim 克隆到另一个文件夹，然后不使用上述选项进行编译，之后您就可以 [运行 Blocks](build_linux.md#how-to-use-airsim) 或您自己的环境了。


### AirSim 设置

在您的 `settings.json` 文件中添加以下行：
`"PhysicsEngineName":"ExternalPhysicsEngine"`.  
您可能需要更改 AirSim 无人机的视觉模型，为此，您可以参考 [此教程](https://youtu.be/Bp86WiLUC80) 。


## 构建 

请从 Air 根文件夹执行此操作：
```
cd GazeboDrone
mkdir build && cd build
cmake -DCMAKE_C_COMPILER=gcc-8 -DCMAKE_CXX_COMPILER=g++-8 ..
make
```

## 运行

首先运行 Air 模拟器和你的 Gazebo 模型，然后从 Air 根文件夹执行以下命令：

```
cd GazeboDrone/build
./GazeboDrone
```

