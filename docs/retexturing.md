# 运行时纹理交换

## 如何让参与者可重新纹理化


要实现纹理可交换，Actor 必须从父类 TextureShuffleActor 派生。
父类可以通过 Actor 蓝图中的“设置”选项卡进行设置。


![Parent Class](images/tex_shuffle_actor.png)

将父类设置为 TextureShuffActor 后，该对象将获得动态材质(DynamicMaterial) 成员。
场景中所有参与者实例的 DynamicMaterial 都需要设置为 TextureSwappableMaterial。


!!! 警告
    在蓝图类中静态设置动态材质可能会导致渲染错误。在蓝图类中的所有 Actor 实例上设置该属性似乎效果更好。


![TextureSwappableMaterial](images/tex_swap_material.png)

## 如何定义可供选择的纹理集

通常，某些参与者子集会彼此共享一组纹理选项。（例如，属于同一建筑物的墙壁）


It's easy to set up these groupings by using Unreal Engine's group editing functionality.
Select all the instances that should have the same texture selection, and add the textures to all of them simultaneously via the Details panel.
Use the same technique to add descriptive tags to groups of actors, which will be used to address them in the API.

![Group Editing](images/tex_swap_group_editing.png)

It's ideal to work from larger groupings to smaller groupings, simply deselecting actors to narrow down the grouping as you go, and applying any individual actor properties last.

![Subset Editing](images/tex_swap_subset.png)

## How to Swap Textures from the API

The following API is available in C++ and python. (C++ shown)

```C++
std::vector<std::string> simSwapTextures(const std::string& tags, int tex_id);
```

The string of "," or ", " delimited tags identifies on which actors to perform the swap.
The tex_id indexes the array of textures assigned to each actor undergoing a swap.
The function will return the list of objects which matched the provided tags and had the texture swap perfomed.
If tex_id is out-of-bounds for some object's texture set, it will be taken modulo the number of textures that were available.

Demo (Python):

```Python
import airsim
import time

c = airsim.client.MultirotorClient()
print(c.simSwapTextures("furniture", 0))
time.sleep(2)
print(c.simSwapTextures("chair", 1))
time.sleep(2)
print(c.simSwapTextures("table", 1))
time.sleep(2)
print(c.simSwapTextures("chair, right", 0))
```

Results:

```bash
['RetexturableChair', 'RetexturableChair2', 'RetexturableTable']
['RetexturableChair', 'RetexturableChair2']
['RetexturableTable']
['RetexturableChair2']
```

![Demo](images/tex_swap_demo.gif)

Note that in this example, different textures were chosen on each actor for the same index value.

You can also use the `simSetObjectMaterial` and `simSetObjectMaterialFromTexture` APIs to set an object's material to any material asset or filepath of a texture. For more information on using these APIs, see [Texture APIs](apis.md#texture-apis).
