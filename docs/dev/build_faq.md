# 编译中的问题

执行`make launch`到`BuildCarlaUE4`时报错：
```text
D:\hutb\Unreal\CarlaUE4\Plugins\Carla\CarlaDependencies\include\boost/asio/detail/impl/winsock_init.ipp(36): error C2039: "InterlockedIncrement": ���� "`global namespace'" �ĳ�Ա
...
D:\hutb\Unreal\CarlaUE4\Plugins\AirSim\Source\Vehicles/Multirotor/MultirotorPawnSimApi.h(85): error C3646: ��collision_response��: 未知重写说明符
...
D:/hutb/Unreal/CarlaUE4/Plugins/AirSim/Source/Vehicles/Multirotor/MultirotorPawnSimApi.cpp(148): error C2660: ��UAirBlueprintLib::LogMessage��: ���������� 2 ������
...
  D:/hutb/Unreal/CarlaUE4/Plugins/AirSim/Source/WorldSimApi.cpp(482): error C2671: ��WorldSimApi::setObjectMaterialFromTexture��: ��̬��Ա����û�С�this��ָ��
  D:/hutb/Unreal/CarlaUE4/Plugins/AirSim/Source/WorldSimApi.cpp(508): error C2440: ��<function-style-cast>��: �޷��ӡ�initializer list��ת��Ϊ��WorldSimApi::setObjectMaterialFromTexture::<lambda_ada7d7381434a2d23717f3ff26793be2>��
```

error C3646: 如果在使用时出现两个类分别在两个不同的文件中编写，并且相互引用，则会出现**循环引用**，引发此错误。