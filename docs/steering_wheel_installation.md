# 罗技 G920 方向盘安装

要将 Logitech G920 方向盘与 AirSim 配合使用，请按照以下步骤操作：

1. 将方向盘连接到计算机并等待驱动程序安装完成。

2. 从 [这里](http://support.logitech.com/en_us/software/lgs) 安装 Logitech 游戏软件

3. 在调试之前，你需要将 AirSim 代码中的值标准化。在 CarPawn.cpp 中执行以下更改（根据 git 中的当前更新）： 
  在第 382 行，将“Val”更改为“1 - Val”。（[0.0,1.0] 范围内的补码值）。
  在第 404 行，将“Val”更改为“4(1 - Val)”。（[0.0,1.0] 范围内的补码值）。
 
4. 调试 AirSim 项目（在方向盘连接的情况下 - 这很重要）。

5. 在虚幻编辑器上，转到编辑->插件->输入设备并启用“Windows RawInput”。

6. 进入编辑->项目设置->原始输入，添加新的设备配置：
  Vendor ID: 0x046d (如果是 Logitech G920，否则您可能需要检查它).  
  Product ID: 0xc261 (如果是 Logitech G920，否则您可能需要检查它).  
  在“轴属性”下，确保“GenericUSBController Axis 2”、“GenericUSBController Axis 4”和“GenericUSBController Axis 5”均已启用，偏移量为 1.0。
  说明：轴 2 负责转向，轴 4 负责刹车，轴 5 负责油门。如果需要配置离合器，则位于轴 3 上。
  
  ![steering_wheel](images/steering_wheel_instructions_1.png)

7. 转到编辑->项目设置->输入，在“轴映射”中的绑定下：  
  从组“MoveRight”和“MoveForward”中删除现有映射。 
  为组“MoveRight”添加新的轴映射，使用 GenericUSBController 轴 2，比例为 1.0。  
  为“MoveForward”组添加新的轴映射，使用 GenericUSBController 轴 5，比例尺为 1.0。
  添加一组新的轴映射，命名为“FootBrake”，并向该组添加新的轴映射，使用 GenericUSBController 轴 4，比例尺为 1.0。
  
  ![steering_wheel](images/steering_wheel_instructions_2.png)
  
8. 边玩边开车！

### 注意

请注意，在调试后第一次“玩”时，我们需要触摸轮子来“重置”值。

### 提示

在游戏软件中，您可以将按钮配置为键盘快捷键，我们用它来配置记录数据集或全屏播放的快捷方式。
