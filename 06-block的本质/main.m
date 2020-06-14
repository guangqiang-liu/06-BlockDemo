//
//  main.m
//  06-block的本质
//
//  Created by 刘光强 on 2020/2/5.
//  Copyright © 2020 guangqiang.liu. All rights reserved.
//

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
  int num;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        // auto：自动变量，变量离开作用域就自动销毁的变量
        
        // age默认就是auto变量，可以省略不写
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
