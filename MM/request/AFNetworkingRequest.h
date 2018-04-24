//
//  AFNetworkingRequest.h
//  MM
//
//  Created by 蔡君义 on 2017/12/22.
//  Copyright © 2017年 justin. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface AFNetworkingRequest : NSObject

- (void)getUrl:(NSString *)url andParams:(NSDictionary *)params success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;

- (void)postUrl:(NSString *)url andParams:(NSDictionary *)params success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;

@end
