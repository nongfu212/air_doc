# 修改记录数据

Air 具备 [记录功能](settings.md#recording) ，可轻松收集数据和图像。[记录 API](apis.md#recording-apis) 还允许使用 API 启动和停止录制。

然而，默认记录的数据可能不足以满足您的使用需求，因此最好记录其他数据，例如IMU、GPS传感器、旋翼速度（适用于旋翼飞行器）等。您可以使用现有的 Python 和 C++ API 来获取信息并按需存储，尤其适用于激光雷达数据。此外，您还可以通过修改 Air 内部的记录方法来添加 GPS 等小型字段或内部数据（例如虚幻引擎位置或其他数据）。本页面将介绍您可能需要修改的具体方法。

记录的数据以制表符分隔的格式写入 `airsim_rec.txt` 文件，图像则保存在 `images/` 文件夹中。默认情况下，整个文件夹位于`Documents(文档)`文件夹中（或在设置中指定），并以 `%Y-%M-%D-%H-%M-%S` 格式记录开始时间戳。

汽车载具记录以下字段：

```text
VehicleName TimeStamp   POS_X   POS_Y   POS_Z   Q_W Q_X Q_Y Q_Z Throttle    Steering    Brake   Gear    Handbrake   RPM Speed   ImageFile
```

对于多旋翼飞行器：

```text
VehicleName TimeStamp   POS_X   POS_Y   POS_Z   Q_W Q_X Q_Y Q_Z ImageFile
```

## 代码改变

!!! 注意
   这需要从源代码构建和使用 Air。如有需要，您可以自行修改后编译二进制文件。

填充要存储的数据的主要方法是 [`PawnSimApi::getRecordFileLine`](https://github.com/OpenHUTB/air/blob/880c5541fd4824ee2cd9bb82ca5f611eb1ab236a/Unreal/Plugins/AirSim/Source/PawnSimApi.cpp#L544)，它是所有载具的基本方法，Car 重写了它以记录附加数据，如 [`CarPawnSimApi::getRecordFileLine`](https://github.com/OpenHUTB/air/blob/880c5541fd4824ee2cd9bb82ca5f611eb1ab236a/Unreal/Plugins/AirSim/Source/Vehicles/Car/CarPawnSimApi.cpp#L34) 所示。


要记录多旋翼飞行器的更多数据，可以在 [MultirotorPawnSimApi.cpp/h](https://github.com/OpenHUTB/air/tree/main/Unreal/Plugins/AirSim/Source/Vehicles/Multirotor) 文件中添加类似的方法，该方法会覆盖基类的实现并附加其他数据。当前记录的数据也可以根据需要进行修改和删除。

例如，记录多旋翼飞行器的 GPS、IMU 和气压计数据：

```cpp
// MultirotorPawnSimApi.cpp
std::string MultirotorPawnSimApi::getRecordFileLine(bool is_header_line) const
{
    std::string common_line = PawnSimApi::getRecordFileLine(is_header_line);
    if (is_header_line) {
        return common_line +
               "Latitude\tLongitude\tAltitude\tPressure\tAccX\tAccY\tAccZ\t";
    }

    const auto& state = vehicle_api_->getMultirotorState();
    const auto& bar_data = vehicle_api_->getBarometerData("");
    const auto& imu_data = vehicle_api_->getImuData("");

    std::ostringstream ss;
    ss << common_line;
    ss << state.gps_location.latitude << "\t" << state.gps_location.longitude << "\t"
       << state.gps_location.altitude << "\t";

    ss << bar_data.pressure << "\t";

    ss << imu_data.linear_acceleration.x() << "\t" << imu_data.linear_acceleration.y() << "\t"
       << imu_data.linear_acceleration.z() << "\t";

    return ss.str();
}
```

```cpp
// MultirotorPawnSimApi.h
virtual std::string getRecordFileLine(bool is_header_line) const override;
```
