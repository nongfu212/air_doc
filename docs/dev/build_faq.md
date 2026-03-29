# 编译中的问题

```text
D:\hutb\Unreal\CarlaUE4\Plugins\Carla\CarlaDependencies\include\boost/asio/detail/impl/win_iocp_socket_service_base.ipp(800): error C3861: ��InterlockedCompareExchangePointer��: �Ҳ�����ʶ��
...
D:\hutb\Unreal\CarlaUE4\Plugins\AirSim\Source\Vehicles/Multirotor/MultirotorPawnSimApi.h(88): error C4430: 
```

error C3646: 如果在使用时出现两个类分别在两个不同的文件中编写，并且相互引用，则会出现**循环引用**，引发此错误。