//
//  CairoRequest.h
//  MM
//
//  Created by 蔡君义 on 2017/12/22.
//  Copyright © 2017年 justin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CairoRequest : NSObject

//get方法
- (void)getUrlbyAF:(NSString *)url andParam:(id)param
   resultClass:(Class)resultClass
       success:(void (^)(id result))success
       failure:(void (^)(NSError *error))failure;

//post方法
- (void)postUrlbyAF:(NSString *)url andParam:(id)param
    resultClass:(Class)resultClass
        success:(void (^)(id result))success
        failure:(void (^)(NSError *error)) failure;

@end
