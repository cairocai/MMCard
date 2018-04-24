//
//  ViewController.m
//  MM
//
//  Created by 蔡君义 on 2017/12/21.
//  Copyright © 2017年 justin. All rights reserved.
//

#import "ViewController.h"
#import "PageViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置背景色
    self.view.backgroundColor = [UIColor whiteColor];
    // 添加子view
    PageViewController *pageViewController = [[PageViewController alloc] init];
    // 添加child viewcontroller使其响应事件
    [self addChildViewController:pageViewController];
    [self.view addSubview:pageViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
