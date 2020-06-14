# 06-block的本质

在讲解block的底层原理前，我们先抛出如下block相关的问题：

* block的本质，底层数据结构？
* block的底层原理？
* block的类型？
* block的变量捕获？
* block属性修饰词copy?
* __block的底层原理?
* __weak的底层原理？

我们先来回顾下`block`的基本使用语法：

```
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        ^{
            NSLog(@"111");
            NSLog(@"111");
            NSLog(@"111");
        };
    }
    return 0;
}
```

我们在`main`函数中写了一个`block`代码块，并在`block`的内部执行了三句打印，当我们运行程序后，发现并没有任何打印，这是因为现在只是声明了一个`block`，并没有调用这个`block`，就和函数一样，只是声明了一个函数而不调用函数，函数是不会执行的

下面我们修改`main`函数内部的代码如下：

```
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        ^{
            NSLog(@"111");
            NSLog(@"111");
            NSLog(@"111");
        }();
    }
    return 0;
}
```

我们在`block`的结束符`}`括号后面添加`()`，就能够执行到`block`内部的代码，就想调用函数一样`func()`

我们这样写虽然能执行`block`内部的代码，但是一运行就直接执行了`block`，这样不便于我们来控制这个`block`的调用时机，我们可以创建一个变量来将这个`block`保存起来，修改代码如下：

```
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        // 创建一个myBlock变量来临时保存这个block
        void (^myBlock)(void) = ^{
            NSLog(@"111");
            NSLog(@"111");
            NSLog(@"111");
        };
        
        // 通过变量来执行block
        myBlock();
    }
    return 0;
}
```

通过上面的代码，我们就可以通过`myBlock`这个变量来控制`block`的执行时机了

我们在来看下带有参数的`block`的基本用法：

```
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        // 创建一个myBlock变量来临时保存这个block
        void (^myBlock)(int, int) = ^(int a, int b){
            NSLog(@"111");
            NSLog(@"%d", a);
            NSLog(@"%d", b);
        };
        
        // 通过变量来执行block
        myBlock(10, 20);
    }
    return 0;
}
```

接下来我们看看`block`代码块内部访问外部变量的情况

```
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        int age = 100;
        
        // 创建一个变量来临时保存这个block
        void (^myBlock)(int, int) = ^(int a, int b){
            NSLog(@"111");
            NSLog(@"外部的变量=%d", age); // 100
            NSLog(@"%d", a); // 10
            NSLog(@"%d", b); // 20
        };
        
        // 通过变量来执行block
        myBlock(10, 20);
    }
    return 0;
}
```

我们执行`xcrun  -sdk  iphoneos  clang  -arch  arm64  -rewrite-objc main.m`命令，将`main.m`文件转换为底层c++代码，来查看转换后`block`的底层数据结构

通过查看`main.cpp`文件，我们可以看到`block`底层数据结构如下：

`__main_block_impl_0`就是上面`main`函数中定义的`block`

```
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  
  // 这个age就是从block外部捕获的变量保存在block结构体中
  int age;
  
  /**
  	这个__main_block_impl_0()是c++的构造函数语法，相当于OC中的init初始化函数，这个函数返回结	构体对象`__main_block_impl_0`
  	
  	void *fp:这个指针就是__main_block_impl_0函数内存地址
  	desc:&__main_block_desc_0_DATA
  	_age:捕获的age变量的值
  */
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _age, int flags=0) : age(_age) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp; // fp指向的就是block代码块函数的内存地址
    Desc = desc;
  }
};
```

`__block_impl`结构体如下：

```
struct __block_impl {
  void *isa; // isa指针
  int Flags;
  int Reserved;
  void *FuncPtr; // block代码块的内存地址
};
```

`__main_block_func_0`函数，这个函数也就是block的代码块函数，所有block中需要执行的代码都包含在这个函数内：

```
static void __main_block_func_0(struct __main_block_impl_0 *__cself, int a, int b) {
  int num = __cself->num; // bound by copy

            NSLog((NSString *)&__NSConstantStringImpl__var_folders_lr_81gwkh751xzddx_ffhhb5_0m0000gn_T_main_5deef5_mi_0);
            NSLog((NSString *)&__NSConstantStringImpl__var_folders_lr_81gwkh751xzddx_ffhhb5_0m0000gn_T_main_5deef5_mi_1, num);
            NSLog((NSString *)&__NSConstantStringImpl__var_folders_lr_81gwkh751xzddx_ffhhb5_0m0000gn_T_main_5deef5_mi_2, a);
            NSLog((NSString *)&__NSConstantStringImpl__var_folders_lr_81gwkh751xzddx_ffhhb5_0m0000gn_T_main_5deef5_mi_3, b);
        }
```

`__main_block_desc_0`:结构体

```
static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  
  // __main_block_desc_0_DATA = {}:这个是c++的结构体语法，定义一个__main_block_desc_0_DATA结构体变量，并且给变量初始化赋值
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
```

`block`底层结构示意图如下：
![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200205-132825@2x.png)

`main`函数内代码转换如下：

```
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

        int age = 100;

        void (*block)(int, int) = ((void (*)(int, int))&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, age));

        ((void (*)(__block_impl *, int, int))((__block_impl *)block)->FuncPtr)((__block_impl *)block, 10, 20);
    }
    return 0;
}
```

我们将`main`函数内的c++代码的一些类型转换代码去掉，剩余代码如下：

```
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

        int age = 100;
        
        // `(*block)`:就是block的内存地址
        // `&__main_block_impl_0()`:函数返回的正好也是一个地址，也就是block的内存地址
        void (*block)(int, int) = &__main_block_impl_0(
                                                        __main_block_func_0,
                                                        &__main_block_desc_0_DATA,
                                                        age);
        // `block->FuncPtr()`:执行block，是通过block先找到FuncPtr，然后通过FuncPtr来调用block并传递参数
        block->FuncPtr(block, 10, 20);
    }
    return 0;
}
```

我们上面说`__main_block_impl_0`这个结构体就是`block`的底层数据结构，接下来我们将转换后c++代码中关键的几个结构体对象整合到`main.m`文件来证实，`main.m`代码如下：

```
#import <Foundation/Foundation.h>

struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
};

struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int age;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        int age = 100;
        
        // 创建一个变量来临时保存这个block
        void (^myBlock)(int, int) = ^(int a, int b){
            NSLog(@"111");
            NSLog(@"外部的变量=%d", age);
            NSLog(@"%d", a);
            NSLog(@"%d", b);
        };
        
        
        // 这里我们将`myBlock`类型转换为`struct __main_block_impl_0`指针类型
        struct __main_block_impl_0 *blockStruct = (__bridge struct __main_block_impl_0 *)myBlock;
        
        // 通过变量来执行block
        myBlock(10, 20);
    }
    return 0;
}
```

通过上面的代码`struct __main_block_impl_0 *blockStruct = (__bridge struct __main_block_impl_0 *)myBlock;` 将`myBlock`转换为`struct __main_block_impl_0 *`类型，我们打印下`blockStruct`变量和`myBlock`进行对比，如下图所示：

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200205-125029@2x.png)

我们发现`myBlock`对应的函数地址和`blockStruct`结构体对象中的`FuncPtr`是一致的，`block`的外部变量`age`也存放在`blockStruct`结构体内，从这也能说明`block`的底层数据结构就是`__main_block_impl_0`结构体对象

从上面的打印可以看到`blockStruct`对象中还包含了`isa`指针，这也说明`block`是一个`NSObject`对象

讲解示例代码Demo地址：[https://github.com/guangqiang-liu/06-BlockDemo]()

## 更多文章
* ReactNative开源项目OneM(1200+star)：**[https://github.com/guangqiang-liu/OneM](https://github.com/guangqiang-liu/OneM)**：欢迎小伙伴们 **star**
* iOS组件化开发实战项目(500+star)：**[https://github.com/guangqiang-liu/iOS-Component-Pro]()**：欢迎小伙伴们 **star**
* 简书主页：包含多篇iOS和RN开发相关的技术文章[http://www.jianshu.com/u/023338566ca5](http://www.jianshu.com/u/023338566ca5) 欢迎小伙伴们：**多多关注，点赞**
* ReactNative QQ技术交流群(2000人)：**620792950** 欢迎小伙伴进群交流学习
* iOS QQ技术交流群：**678441305** 欢迎小伙伴进群交流学习