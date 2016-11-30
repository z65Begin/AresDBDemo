//
//  ViewController.m
//  AresDBDemo
//
//  Created by Admin on 16/11/25.
//  Copyright © 2016年 AresBegin. All rights reserved.
//

#import "ViewController.h"

#import "AresElseTool.h"

#import "AresDBTool.h"
#import "TestModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
  
//    [scan scanCharactersFromSet:[NSCharacterSet  characterSetWithCharactersInString:@"a"] intoString:name];

//    test();
    test1();
   int a = test2();
    printf("test2->%d\n",a);
}

void test(){
    NSDictionary * dict = @{@"name":@"zhangshan"};
    NSLog(@"--%@",dict[@"key"]);
}

void test1(){
    NSDictionary * dict = @{@"name":@"张飞",@"age":@18,@"sex":@"男"};
    
    TestModel * model = [TestModel modelWithDictionary:dict];
//    [[AresDBTool instantiateTool] openDBWith:@"name.sqlite" Model:model];
    
    [[AresDBTool instantiateTool] insertDataWith:@"name.sqlite" Model:model];
    [[AresDBTool instantiateTool] deleteDataWith:@"name.sqlite"];
}
 int (^nameBlock)();
int test2(){
    
   __block int num = 0;
    nameBlock =  ^int {
        num += 10;
        return 0;
    };
//    NSLog(@"num->%d",num+1);
    return num + 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
