//
//  LocationTool.h
//  AccurateLocation
//
//  Created by vochi on 2017/2/22.
//  Copyright © 2017年 vochi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationTool : NSObject

/**
 请求成功block
 */
typedef void (^requestLocationSuccessBlock) (NSString *address);

/**
 请求失败block
 */
typedef void (^requestLocationFailureBlock) (void);

+ (id)shareLocation;

//获取位置
- (void)getLocationPointSuccess:(requestLocationSuccessBlock)successHandler failure:(requestLocationFailureBlock)failureHandler;

@end
