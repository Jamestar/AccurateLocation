//
//  NetworkRequestTools.h
//  AFNetworking3.1Tools
//
//  Created by vochi on 16/6/14.
//  Copyright © 2016年 vochi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class FileConfig;

@interface NetworkRequestTools : NSObject

/**
 请求成功block
 */
typedef void (^requestSuccessBlock)(id responseObj);

/**
 请求失败block
 */
typedef void (^requestFailureBlock) (NSError *error);

/**
 请求响应block
 */
typedef void (^responseBlock)(id dataObj, NSError *error);

/**
 下载进度响应block
 */
typedef void (^downloadProgressBlock)(NSProgress *downloadProgress);

/**
 上传进度响应block
 */
typedef void (^uploadProgressBlock)(NSProgress *uploadProgress);

//typedef void (^progressBlock)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

/**
 GET请求
 */
+ (void)getRequest:(NSString *)url params:(id)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler;

/**
 POST请求
 */
+ (void)postRequest:(NSString *)url params:(id)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler;

/**
 下载文件，监听下载进度
 */
+ (void)downloadRequest:(NSString *)url successAndProgress:(downloadProgressBlock)progressHandler complete:(responseBlock)completionHandler;

/**
 下载文件，监听下载进度,并指定保存路径
 */
+ (void)downloadRequest:(NSString *)url toPath:(NSString *)savePath successAndProgress:(downloadProgressBlock)progressHandler complete:(responseBlock)completionHandler;
/**
 文件上传
 */
+ (void)uploadRequest:(NSString *)url params:(NSDictionary *)params fileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName fileType:(NSString *)fileType success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler;

/**
 文件上传，监听上传进度
 */
+ (void)uploadRequest:(NSString *)url params:(NSDictionary *)params fileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName fileType:(NSString *)fileType successAndProgress:(uploadProgressBlock)progressHandler complete:(responseBlock)completionHandler;

@end
