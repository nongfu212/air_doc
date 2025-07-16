# AirSim 中的强化学习

下面我们将介绍如何在 AirSim 中实现 DQN，具体方法是使用 OpenAI Gym 封装 AirSim API 的包装器，并使用标准强化学习算法的稳定基线实现。为了运行这些示例，我们建议安装 stable-baselines3（请参阅 https://github.com/DLR-RM/stable-baselines3）。


#### 免责声明

这仍在积极开发中。下面我们分享的是一个可以扩展和调整以获得更佳性能的框架。

#### Gym wrapper

为了将 AirSim 用作训练环境，我们扩展并重新实现了 AirSim 及其相关任务所需的基础方法，例如 `step`、`_get_obs`、`_compute_reward` 和 `reset`。这些示例中用于汽车和无人机的示例环境位于 `PythonClient/reinforcement_learning/*_env.py` 中。


## RL 与汽车

[源代码](https://github.com/Microsoft/AirSim/tree/main/PythonClient/reinforcement_learning)

此示例适用于 [发行版](https://github.com/Microsoft/AirSim/releases) 中提供的 AirSimNeighborhood 环境。


首先，我们需要从模拟中获取图像并对其进行适当的转换。下面，我们将展示如何从自我相机获取深度图像并将其转换为 84x84 的输入到网络。（您也可以使用其他传感器模态和传感器输入——当然，您需要相应地修改代码）。


```
responses = client.simGetImages([ImageRequest(0, AirSimImageType.DepthPerspective, True, False)])
current_state = transform_input(responses)
```

我们进一步定义了代理可以执行的 6 个动作（刹车、直行带油门、左转带油门全开、右转带油门全开、左转半开带油门、右转半开带油门）。这通过函数`interpret_action`实现：


```
def interpret_action(action):
    car_controls.brake = 0
    car_controls.throttle = 1
    if action == 0:
        car_controls.throttle = 0
        car_controls.brake = 1
    elif action == 1:
        car_controls.steering = 0
    elif action == 2:
        car_controls.steering = 0.5
    elif action == 3:
        car_controls.steering = -0.5
    elif action == 4:
        car_controls.steering = 0.25
    else:
        car_controls.steering = -0.25
    return car_controls
```

然后，我们在`_compute_reward`中将奖励函数定义为车辆行驶速度与偏离中心线距离的凸组合。当代理快速行驶并保持在车道中心时，代理将获得高奖励。


```
def _compute_reward(car_state):
    MAX_SPEED = 300
    MIN_SPEED = 10
    thresh_dist = 3.5
    beta = 3

    z = 0
    pts = [np.array([0, -1, z]), np.array([130, -1, z]), np.array([130, 125, z]), np.array([0, 125, z]), np.array([0, -1, z]), np.array([130, -1, z]), np.array([130, -128, z]), np.array([0, -128, z]), np.array([0, -1, z])]
    pd = car_state.position
    car_pt = np.array(list(pd.values()))

    dist = 10000000
    for i in range(0, len(pts)-1):
        dist = min(dist, np.linalg.norm(np.cross((car_pt - pts[i]), (car_pt - pts[i+1])))/np.linalg.norm(pts[i]-pts[i+1]))

    #print(dist)
    if dist > thresh_dist:
        reward = -3
    else:
        reward_dist = (math.exp(-beta*dist) - 0.5)
        reward_speed = (((car_state.speed - MIN_SPEED)/(MAX_SPEED - MIN_SPEED)) - 0.5)
        reward = reward_dist + reward_speed

    return reward
```

计算奖励函数随后还会判断该场景是否已终止（例如，由于碰撞）。我们会观察车辆的速度，如果速度低于阈值，则认为该场景已终止。

```
done = 0
if reward < -1:
    done = 1
if car_controls.brake == 0:
    if car_state.speed <= 5:
        done = 1
return done
```

然后，主循环依次执行获取图像、根据当前策略计算要采取的行动、获得奖励等步骤。如果回合结束，我们会通过 `reset()` 将车辆重置为原始状态：


```
client.reset()
client.enableApiControl(True)
client.armDisarm(True)
car_control = interpret_action(1) // Reset position and drive straight for one second
client.setCarControls(car_control)
time.sleep(1)
```

一旦在`car_env.py`中定义了 gym 风格的环境包装器，我们就可以利用 stable-baselines3 运行 DQN 训练循环。DQN 训练的配置如下，详见`dqn_car.py`。


```
model = DQN(
    "CnnPolicy",
    env,
    learning_rate=0.00025,
    verbose=1,
    batch_size=32,
    train_freq=4,
    target_update_interval=10000,
    learning_starts=200000,
    buffer_size=500000,
    max_grad_norm=10,
    exploration_fraction=0.1,
    exploration_final_eps=0.01,
    device="cuda",
    tensorboard_log="./tb_logs/",
)
```

可以定义训练环境和评估环境（参见 `dqn_car.py` 中的 `EvalCallback`）。评估环境可以与训练环境不同，具有不同的终止条件/场景配置。Tensorboard 日志目录也作为 DQN 参数的一部分定义。最后，`model.learn()` 启动 DQN 训练循环。同样，可以从 stable-baselines3 中使用 PPO、A3C 等实现。


请注意，在执行`dqn_car.py`之前，需要启动并运行模拟。下方视频展示了 DQN 训练的前几轮。


[![Reinforcement Learning - Car](images/dqn_car.png)](https://youtu.be/fv-oFPAqSZ4)

## RL 与四旋翼飞行器

[源代码](https://github.com/Microsoft/AirSim/tree/main/PythonClient/reinforcement_learning)


此示例适用于 [发行版](https://github.com/Microsoft/AirSim/releases) 中可用的 AirSimMountainLandscape 环境。


类似地，我们可以将强化学习应用于四旋翼飞行器的各种自主飞行场景。以下示例展示了如何使用强化学习训练四旋翼飞行器沿高压电线飞行（例如，能源基础设施巡检应用）。
这里有七个离散动作，分别对应四旋翼飞行器可以移动的不同方向（6 个方向 + 1 个悬停动作）。


```
def interpret_action(self, action):
    if action == 0:
        quad_offset = (self.step_length, 0, 0)
    elif action == 1:
        quad_offset = (0, self.step_length, 0)
    elif action == 2:
        quad_offset = (0, 0, self.step_length)
    elif action == 3:
        quad_offset = (-self.step_length, 0, 0)
    elif action == 4:
        quad_offset = (0, -self.step_length, 0)
    elif action == 5:
        quad_offset = (0, 0, -self.step_length)
    else:
        quad_offset = (0, 0, 0)
```

奖励再次是一个函数，它决定了四轮车的行驶速度以及它与已知电力线的距离。


```
def compute_reward(quad_state, quad_vel, collision_info):
    thresh_dist = 7
    beta = 1

    z = -10
    pts = [np.array([-0.55265, -31.9786, -19.0225]),np.array([48.59735, -63.3286, -60.07256]),np.array([193.5974, -55.0786, -46.32256]),np.array([369.2474, 35.32137, -62.5725]),np.array([541.3474, 143.6714, -32.07256]),]

    quad_pt = np.array(list((self.state["position"].x_val, self.state["position"].y_val,self.state["position"].z_val,)))

    if self.state["collision"]:
        reward = -100
    else:
        dist = 10000000
        for i in range(0, len(pts) - 1):
            dist = min(dist, np.linalg.norm(np.cross((quad_pt - pts[i]), (quad_pt - pts[i + 1]))) / np.linalg.norm(pts[i] - pts[i + 1]))

        if dist > thresh_dist:
            reward = -10
        else:
            reward_dist = math.exp(-beta * dist) - 0.5
            reward_speed = (np.linalg.norm([self.state["velocity"].x_val, self.state["velocity"].y_val, self.state["velocity"].z_val,])- 0.5)
            reward = reward_dist + reward_speed
```

如果事件偏离已知电力线坐标太远，我们会认为该事件终止，然后将无人机重置到其起点。


一旦在`drone_env.py`中定义了 gym 风格的环境包装器，我们就可以利用 stable-baselines3 运行 DQN 训练循环。DQN 训练的配置如下，详见`dqn_drone.py`。

```
model = DQN(
    "CnnPolicy",
    env,
    learning_rate=0.00025,
    verbose=1,
    batch_size=32,
    train_freq=4,
    target_update_interval=10000,
    learning_starts=10000,
    buffer_size=500000,
    max_grad_norm=10,
    exploration_fraction=0.1,
    exploration_final_eps=0.01,
    device="cuda",
    tensorboard_log="./tb_logs/",
)
```

可以定义训练环境和评估环境（参见 `dqn_drone.py` 中的 `EvalCallback`）。评估环境可以与训练环境不同，具有不同的终止条件/场景配置。Tensorboard 日志目录也被定义为 DQN 参数的一部分。最后，`model.learn()` 启动 DQN 训练循环。同样，可以使用 stable-baselines3 中的 PPO、A3C 等实现。


以下是训练期间前几代的视频。

[![Reinforcement Learning - Quadrotor](images/dqn_quadcopter.png)](https://youtu.be/uKm15Y3M1Nk)

## 相关内容

另请参阅 Microsoft 深度学习和机器人车库章节的 [自动驾驶手册](https://aka.ms/AutonomousDrivingCookbook)。

