# Hello Drone

## Hello Drone 如何工作？

Hello Drone 使用 RPC 客户端连接到 AirSim 自动启动的 RPC 服务器。RPC 服务器将所有命令路由到实现 [MultirotorApiBase](https://github.com/Microsoft/AirSim/tree/main/AirLib//include/vehicles/multirotor/api/MultirotorApiBase.hpp) 的类。本质上，MultirotorApiBase 定义了我们的抽象接口，用于从 quadrotor 获取数据并发回命令。我们目前已经为基于 MavLink 的车辆的 MultirotorApiBase 提供了具体的实现。DJI 无人机平台（特别是 Matrice）的实现正在进行中。

