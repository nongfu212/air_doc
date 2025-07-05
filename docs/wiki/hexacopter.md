## 构造六旋翼飞行器
那么 AirSim 能飞六旋翼飞行器吗？答案是可以，但设置起来需要一些工作。具体来说，需要更新三个组件：首先是 PX4 固件，然后是 AirSim 物理系统，最后是渲染模型。

### PX4 修改

PX4 需要处于`六轴飞行器模式(hexacopter mode)`，才能为所有 6 个电机提供输出。但是，如果您熟悉 QGroundControl 的“HIL 四轴飞行器”机身，您会注意到它没有 HIL 六轴飞行器。根据 PX4 团队的说法，我们不需要使用特殊的机身就能让 PX4 在 HIL 模式下正常工作，但很遗憾，今天我们不得不这么做。PX4 存在一些 bug，会导致 HIL 模式在任何机身上都无法正常工作。因此，除了修复这些 bug 之外，以下是获取 HIL 六轴飞行器机身选项的快速方法。首先，按照 [px4](https://github.com/Microsoft/AirSim/wiki/px4.md%5D) 中的说明克隆 git 仓库，然后执行以下操作：

```shell
cd ROMFS/px4fmu_common/init.d
cp 1001_rc_quad_x.hil 1004_rc_hex_x.hil
gedit 1004_rc_hex_x.hil
```

并使其包含以下内容：
```shell
#!nsh
#
# @name HIL Quadcopter +
#
# @type Simulation
#
# @maintainer Anton Babushkin <anton@px4.io>
#

sh /etc/init.d/rc.mc_defaults

set MIXER hexa_x

# Need to set all 8 channels
set PWM_OUT 12345678

set HIL yes
```

保存此文件，然后使用 `make px4fmu-v2_default` 命令重新构建 px4。如果您已经构建过，请删除之前的构建输出 `build_px4fmu-v2_default`，以确保您的新构建选择这个新的ROMFS文件。

现在找到名为 `PX4AirframeFactMetaData.xml` 的 QGroundControl 配置文件，在 Windows 上，它位于 `%APPDATA%\QGroundControl.org\PX4AirframeFactMetaData.xml`。找到 airframe id="1001"，复制整个 airframe XML 元素并将其替换为：

```xml
    <airframe id="1004" maintainer="Anton Babushkin &lt;anton@px4.io&gt;" name="HIL Hexacopter X">
      <maintainer>Anton Babushkin &lt;anton@px4.io&gt;</maintainer>
      <type>Simulation</type>
    </airframe>
```

您可以将维护者设置为任意人。现在，当您的 Pixhawk 重启时，QGroundControl 应该会在“HIL”机身类型下显示一个 `HIL Hexacopter X` 选项，选择它并将其应用到 PX4 上，重启后，它就可以在 HIL 模式下作为六轴飞行器飞行了。


### AirSim 物理系统


### 渲染