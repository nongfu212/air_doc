# 现代 C++ 编码指南

我们正在使用现代 C++11。智能指针、Lambda 表达式和 C++11 多线程原语都是您的好帮手。

## 快速笔记

“标准” 的优点在于有很多可供选择：[ISO](https://isocpp.org/wiki/faq/coding-standards)、[Sutter &amp; Stroustrup](https://github.com/isocpp/CppCoreGuidelines/blob/master/CppCoreGuidelines.md)、[ROS](http://wiki.ros.org/CppStyleGuide)、[LINUX](https://www.kernel.org/doc/Documentation/process/coding-style.rst)、[Google](https://google.github.io/styleguide/cppguide.html)、[Microsoft](https://msdn.microsoft.com/en-us/library/888a6zcz.aspx)、[CERN](http://atlas-computing.web.cern.ch/atlas-computing/projects/qa/draft_guidelines.html)、[GCC](https://gcc.gnu.org/wiki/CppConventions) [ARM](http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0475c/CJAJAJCJ.html)、[LLVM](http://llvm.org/docs/CodingStandards.html) 以及其他数千个标准。遗憾的是，这些标准中的大多数甚至连像如何命名类或常量这样基本的规范都无法达成一致。这可能是因为这些标准由于支持现有代码库而经常存在许多遗留问题。本文档旨在创建尽可能接近 ISO、Sutter & Stroustrup 和 ROS 标准的指南，同时尽可能解决它们之间的冲突、缺点和不一致之处。


## clang-format

C++ 语法的格式化由 clang-format 工具进行规范化，该工具已将设置签入到本项目中的 `.clang-format` 文件中。这些设置符合以下列出的格式指南。您可以使用 clang-format 命令行或在每次编辑或保存文件时启用 Visual Studio 自动 clang 格式化来“格式化”文件。所有文件均已按此格式格式化，名为 `clang-format` 的 GitHub 工作流也将确保所有拉取请求都格式正确，因此应该保持简洁。显然，这不包括 `Eigen` 或 `rpclib` 等外部代码。

如果您发现 clang-format 中存在错误，您可以使用以下注释对禁用特定代码块的 clang 格式：

```c++
// clang-format off
...
// clang-format on
```

## 命名约定

避免在名称上使用任何类型的匈牙利表示法，避免在指针上使用“_ptr”。

| **代码元素** | **风格** | **评论** |
| --- | --- | --- |
| 命名空间 | under\_scored | 与类名区分 |
| 类名 | CamelCase | 为了与 ISO 推荐的 STL 类型区分开来（不要使用“C”或“T”前缀） |
| 函数名 | camelCase | 除了 .Net 世界之外，小写字母开头几乎是通用的 |
| 参数/局部变量 | under\_scored |绝大多数标准都推荐这样做，因为 \_ 对于 C++ 人群来说更具可读性（尽管对于 Java/.Net 人群来说并不多） |
| 成员变量 | under\_scored\_with\_ | 由于 ISO 对保留 \_identifiers 有规定，因此强烈不建议使用前缀 \_，因此我们建议使用后缀 |
| 枚举及其成员 | CamelCase | 除了非常古老的标准外，大多数标准都同意这一点 |
| 全局变量 | g\_under\_scored | 你首先就不应该拥有这些！ |
| 常量 | UPPER\_CASE | 非常有争议，我们只需要在这里选择一个，除非它是类或方法中的私有常量，然后使用成员或本地命名 |
| 文件名 | 匹配文件中的类名的大小写 | 无论如何，都有很多优点和缺点，但这消除了自动生成代码中的不一致性（对于 ROS 很重要） |

## 头文件

使用命名空间限定的 #ifdef 来防止多重包含：

```
#ifndef msr_airsim_MyHeader_hpp
#define msr_airsim_MyHeader_hpp

//--你的代码

#endif
```

我们不使用 #pragma once 的原因是，如果相同的头文件存在于多个地方（这在 ROS 构建系统下可能是可能的！），则不支持。


## 括在括弧内

在函数或方法体内，将花括号放在同一行。在函数或方法体外，命名空间、类和方法级别则单独一行。这被称为 [K&R 风格](https://en.wikipedia.org/wiki/Indent_style#K.26R_style)，其变体在 C++ 中被广泛使用，而其他风格在其他语言中更受欢迎。请注意，如果语句单一，则无需使用花括号，但复杂的语句使用大括号更容易保持正确。


在函数或方法体内，将花括号放在同一行。
除此之外，命名空间、类和方法级别使用单独的一行。
这称为 [K&R 风格](https://en.wikipedia.org/wiki/Indent_style#K.26R_style)，其变体在 C++ 中被广泛使用，而其他风格在其他语言中更受欢迎。
请注意，如果语句单一，则无需使用花括号，但复杂的语句使用大括号更容易保持正确。


```
int main(int argc, char* argv[])
{
     while (x == y) {
        f0();
        if (cont()) {
            f1();
        } else {
            f2();
            f3();
        }
        if (x > 100)
            break;
    }
}
```

## Const 和引用

认真检查所有声明为 const 和引用的非标量参数。如果您之前使用过 C#/Java/Python 等语言，最常犯的错误就是按值传递参数，而不是使用 `const T&;`。尤其是大多数字符串、向量和映射，如果它们是只读的，则应使用 `const T&;`；如果它们是可写的，则应使用 `T&`。此外，尽可能为方法添加 `const` 后缀。


## 重写
重写虚方法时，使用 override 后缀。


## 指针

这实际上与内存管理有关。模拟器包含许多性能关键代码，因此我们尽量避免通过大量调用 new/delete 来导致内存管理器过载。我们还希望避免在堆栈上进行过多的内容复制，因此我们尽可能通过引用传递内容。
但是，当对象确实需要比调用堆栈存活更长时间时，通常需要在堆上分配该对象，因此需要一个指针。现在，如果管理该对象的生命周期比较棘手，我们建议使用
[C++ 11 智能指针](https://cppstyle.wordpress.com/c11-smart-pointers/)。
但是智能指针确实存在成本，因此不要盲目地在所有地方使用它们。对于性能至关重要的私有代码，可以使用原始指针。在与仅接受指针类型的旧系统（例如套接字 API）交互时，通常也需要使用原始指针。但我们尝试尽可能地包装这些遗留接口，并避免这种编程风格泄露到更大的代码库中。


务必检查是否可以在所有地方使用 const，例如 `const float * const xP`。避免在变量名中使用前缀或后缀来指示指针类型，例如，除非为了更好地区分变量，否则请使用 `my_obj` 而不是 `myobj_ptr`，例如 `int mynum = 5; int* mynum_ptr = mynum;`。



## 空值检查

在虚幻 C++ 代码中，检查指针是否为空时，最好使用“IsValid(ptr)”。除了检查空指针之外，此函数还会返回 UObject 是否已正确初始化。这在 UObject 正在被垃圾回收但仍设置为非空值的情况下非常有用。


## 缩进

C++ 代码库使用四个空格进行缩进（而不是制表符）。

## 换行符

提交文件时应使用 Unix 换行符。在 Windows 上工作时，可以配置 git 检出带有 Windows 换行符的文件，并在提交时自动将 Windows 换行符转换为 Unix 换行符，具体操作如下：

```
git config --global core.autocrlf true
```

在 Linux 上工作时，最好通过运行以下命令将 git 配置为检出带有 Unix 换行符的文件：

```
git config --global core.autocrlf input
```

有关此设置的更多详细信息，请参阅[此文档](https://docs.github.com/en/get-started/getting-started-with-git/configuring-git-to-handle-line-endings)。



## 这太短了，是吗？

是的，这是故意的，因为没人喜欢读200页的编码指南。这里的目标是只涵盖最重要的内容，这些内容
在[GCC中的严格模式编译](http://shitalshah.com/p/how-to-enable-and-use-gcc-strict-mode-compilation/)和VC++中的4级警告错误中尚未涵盖。如果你想了解如何用C++编写更好的代码，请参阅[GotW](https://herbsutter.com/gotw/)
和[Effective Modern C++](http://shop.oreilly.com/product/0636920033707.do)这本书。


