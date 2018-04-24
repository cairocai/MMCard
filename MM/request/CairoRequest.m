//
//  CairoRequest.m
//  MM
//
//  Created by 蔡君义 on 2017/12/22.
//  Copyright © 2017年 justin. All rights reserved.
//

#import "CairoRequest.h"
#import <MJExtension.h>
#import "AFNetworkingRequest.h"

@interface CairoRequest ()

@property (nonatomic,strong) AFNetworkingRequest * AFRequest;

@end

@implementation CairoRequest

- (AFNetworkingRequest *) getAFRequest
{
    if (!_AFRequest) {
        _AFRequest = [[AFNetworkingRequest alloc] init];
    }
    return _AFRequest;
}

- (void)getUrlbyAF:(NSString *)url andParam:(id)param
   resultClass:(Class)resultClass
       success:(void (^)(id result))success
       failure:(void (^)(NSError *error))failure{
    //传参转换
    NSDictionary *params = [param mj_keyValues];
    [self.getAFRequest getUrl:url andParams:params success:^(id responseObj) {
        if (success) {
            //json转对象
            id result = [resultClass mj_objectWithKeyValues:responseObj];
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)postUrlbyAF:(NSString *)url andParam:(id)param
    resultClass:(Class)resultClass
        success:(void (^)(id result))success
        failure:(void (^)(NSError *error)) failure{
    //传参转换
    NSDictionary *params = [param mj_keyValues];
    [self.getAFRequest postUrl:url andParams:params success:^(id responseObj) {
        if (success) {
            NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            success(dictData);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
