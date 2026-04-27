# 编译中的问题


* 在编辑器中运行时提示没有兼容的载具且没有无人机生成
提示信息：
```
There were no compatible vehicles created for current SimMode! Check your settings.json.
```
在编辑器的`运行`下拉菜单中，选择`选中的视口`进行运行。



* 测试时报错：
```text
test_webmerc_location_to_geo_and_back (smoke.test_geoconversion.TestGeoLocationConversion) ... INFO:  Found the required file in cache!  Carla/Maps/Nav/Town03.bin
TestGeoLocationConversion.test_webmerc_location_to_geo_and_back
INFO:  Found the required file in cache!  Carla/Maps/Nav/Town03.bin
ok

======================================================================
FAIL: test_spawn_points (smoke.test_spawnpoints.TestSpawnpoints)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "D:\hutb\PythonAPI\test\smoke\test_spawnpoints.py", line 73, in test_spawn_points
    if spawn_errors else "Spawn errors detected (no details)"
AssertionError: True is not false : Spawn errors detected:
  - idx=248, bp=vehicle.bmw.grandtourer, actor_id=0, loc=(42.596,-4.344,0.275), rot=(0.00,-179.14,0.00), error=Spawn failed because of collision at spawn position

----------------------------------------------------------------------
Ran 37 tests in 1243.142s

FAILED (failures=1)
-[Check]: [TIME]: Running smoke test took 1270 seconds.
SUCCESS: The process with PID 32096 has been terminated.
-[Check]: [TIME]: Overall testing took 1272 seconds.
```

测试命令：
```shell
CarlaUE4.exe --carla-rpc-port=3654 --carla-streaming-port=0 -nosound
python -m nose2 -v smoke.test_spawnpoints.TestSpawnpoints
```

单独测试生成点测试报错：
```text
INFO:  Found the required file in cache!  Carla/Maps/Nav/Town03.bin
FAIL

======================================================================
FAIL: test_spawn_points (smoke.test_spawnpoints.TestSpawnpoints)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "D:\hutb\PythonAPI\test\smoke\test_spawnpoints.py", line 73, in test_spawn_points
    if spawn_errors else "Spawn errors detected (no details)"
AssertionError: True is not false : Spawn errors detected:
  - idx=248, bp=vehicle.bmw.grandtourer, actor_id=0, loc=(42.596,-4.344,0.275), rot=(0.00,-179.14,0.00), error=Spawn failed because of collision at spawn position

----------------------------------------------------------------------
Ran 1 test in 195.029s

FAILED (failures=1)
```

原因：在Town03场景中，无人机占用了原来的生成点的位置。





* 执行`make launch`到`BuildCarlaUE4`时报错：
```text
“TRUE”: 未声明的标识符

D:\hutb\Unreal\CarlaUE4\Plugins\Carla\CarlaDependencies\include\boost/asio/detail/impl/winsock_init.ipp(36): error C2039: "InterlockedIncrement": ���� "`global namespace'" �ĳ�Ա
...
D:\hutb\Unreal\CarlaUE4\Plugins\AirSim\Source\Vehicles/Multirotor/MultirotorPawnSimApi.h(85): error C3646: ��collision_response��: 未知重写说明符
...
D:/hutb/Unreal/CarlaUE4/Plugins/AirSim/Source/Vehicles/Multirotor/MultirotorPawnSimApi.cpp(148): error C2660: ��UAirBlueprintLib::LogMessage��: ���������� 2 ������
...
  D:/hutb/Unreal/CarlaUE4/Plugins/AirSim/Source/WorldSimApi.cpp(482): error C2671: ��WorldSimApi::setObjectMaterialFromTexture��: ��̬��Ա����û�С�this��ָ��
  D:/hutb/Unreal/CarlaUE4/Plugins/AirSim/Source/WorldSimApi.cpp(508): error C2440: ��<function-style-cast>��: �޷��ӡ�initializer list��ת��Ϊ��WorldSimApi::setObjectMaterialFromTexture::<lambda_ada7d7381434a2d23717f3ff26793be2>��
```

原因：LibCarla\source\compiler\disable-ue4-macros.h 和 LibCarla\source\compiler\enable-ue4-macros.h 中的 carla_air 引入的操作。
```cpp
#pragma push_macro("InterlockedIncrement")  // 把 UE 的定义压栈保存
#undef InterlockedIncrement                 // 清除 UE 的版本
```
UE4 把 InterlockedIncrement 等宏 define 成了自己封装的版本；第三方库（boost、rpclib 等）也用这些名字，两者冲突会导致编译错误。

本质是：在包含第三方头文件前后，用 push/pop 做"宏的现场保护"，防止 UE 宏污染第三方库，也防止第三方库破坏 UE 的宏环境。


解决：[wrap boost asio include in ue4 macro bridge](https://github.com/louiszengCN/CarlaAir/commit/434d364de8d206f85c1f51808ad72e044e9863f6)