//
//  ImageObject.h
//  MM
//
//  Created by 蔡君义 on 2017/12/21.
//  Copyright © 2017年 justin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageObject : NSObject

@property (copy, nonatomic) NSString *category;

@property (nonatomic,copy) NSString *group_url;

@property (nonatomic,copy) NSString *image_url;

@property(nonatomic,copy) NSString *objectId;

@property(nonatomic,copy) NSString *thumb_url;

@property(nonatomic,copy) NSString *title;

@end
