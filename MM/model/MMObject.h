//
//  MMObject.h
//  MM
//
//  Created by 蔡君义 on 2017/12/21.
//  Copyright © 2017年 justin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageObject.h"

@interface MMObject : NSObject

//类别
@property (copy, nonatomic) NSString *category;
//页码
@property (nonatomic,copy) NSString *page;
//列表
@property (nonatomic,copy) NSMutableArray<ImageObject *> *results;

@end
