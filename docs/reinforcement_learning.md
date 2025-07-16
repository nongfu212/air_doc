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

The main loop then sequences through obtaining the image, computing the action to take according to the current policy, getting a reward and so forth.
If the episode terminates then we reset the vehicle to the original state via `reset()`:

```
client.reset()
client.enableApiControl(True)
client.armDisarm(True)
car_control = interpret_action(1) // Reset position and drive straight for one second
client.setCarControls(car_control)
time.sleep(1)
```

Once the gym-styled environment wrapper is defined as in `car_env.py`, we then make use of stable-baselines3 to run a DQN training loop. The DQN training can be configured as follows, seen in `dqn_car.py`.

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

A training environment and an evaluation envrionment (see `EvalCallback` in `dqn_car.py`) can be defined. The evaluation environoment can be different from training, with different termination conditions/scene configuration. A tensorboard log directory is also defined as part of the DQN parameters. Finally, `model.learn()` starts the DQN training loop. Similarly, implementations of PPO, A3C etc. can be used from stable-baselines3.

Note that the simulation needs to be up and running before you execute `dqn_car.py`. The video below shows first few episodes of DQN training.

[![Reinforcement Learning - Car](images/dqn_car.png)](https://youtu.be/fv-oFPAqSZ4)

## RL with Quadrotor

[Source code](https://github.com/Microsoft/AirSim/tree/main/PythonClient/reinforcement_learning)

This example works with AirSimMountainLandscape environment available in [releases](https://github.com/Microsoft/AirSim/releases).

We can similarly apply RL for various autonomous flight scenarios with quadrotors. Below is an example on how RL could be used to train quadrotors to follow high tension power lines (e.g. application for energy infrastructure inspection).
There are seven discrete actions here that correspond to different directions in which the quadrotor can move in (six directions + one hovering action).

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

The reward again is a function how how fast the quad travels in conjunction with how far it gets from the known powerlines.

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

We consider an episode to terminate if it drifts too much away from the known power line coordinates, and then reset the drone to its starting point.

Once the gym-styled environment wrapper is defined as in `drone_env.py`, we then make use of stable-baselines3 to run a DQN training loop. The DQN training can be configured as follows, seen in `dqn_drone.py`.

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

A training environment and an evaluation envrionment (see `EvalCallback` in `dqn_drone.py`) can be defined. The evaluation environoment can be different from training, with different termination conditions/scene configuration. A tensorboard log directory is also defined as part of the DQN parameters. Finally, `model.learn()` starts the DQN training loop. Similarly, implementations of PPO, A3C etc. can be used from stable-baselines3.

Here is the video of first few episodes during the training.

[![Reinforcement Learning - Quadrotor](images/dqn_quadcopter.png)](https://youtu.be/uKm15Y3M1Nk)

## Related

Please also see [The Autonomous Driving Cookbook](https://aka.ms/AutonomousDrivingCookbook) by Microsoft Deep Learning and Robotics Garage Chapter.
