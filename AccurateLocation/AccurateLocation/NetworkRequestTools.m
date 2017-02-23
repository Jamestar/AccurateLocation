//
//  NetworkRequestTools.m
//  AFNetworking3.1Tools
//
//  Created by vochi on 16/6/14.
//  Copyright © 2016年 vochi. All rights reserved.
//

#import "NetworkRequestTools.h"

@implementation NetworkRequestTools

/**
 监控网络状态
 */
+ (BOOL)checkNetworkStatus
{
    
    __block BOOL isNetworkUse = YES;
    
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusUnknown) {
            isNetworkUse = YES;
        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
            isNetworkUse = YES;
        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            isNetworkUse = YES;
        } else if (status == AFNetworkReachabilityStatusNotReachable){
            // 网络异常操作
            isNetworkUse = NO;
            NSLog(@"网络异常,请检查网络是否可用！");
        }
    }];
    [reachabilityManager startMonitoring];
    return isNetworkUse;
}

/**
 get请求
 */
+ (void)getRequest:(NSString *)url params:(id)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler
{
    //网络不可用
    if (![self checkNetworkStatus]) {
        successHandler(nil);
        failureHandler(nil);
        return;
    }
    AFHTTPSessionManager * mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain", @"text/json", @"text/javascript", nil];
    [mgr GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"------网络请求失败-------%@",error);
        failureHandler(error);
    }];
    
}

/**
 post请求
 */
+ (void)postRequest:(NSString *)url params:(id)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler
{
    //网络不可用
    if (![self checkNetworkStatus]) {
        successHandler(nil);
        failureHandler(nil);
        return;
    }
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain", @"text/json", @"text/javascript", nil];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         successHandler(responseObject);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"------网络请求失败-------%@",error);
         failureHandler(error);
     }];
}

/**
 下载文件，监听下载进度
 */
+ (void)downloadRequest:(NSString *)url successAndProgress:(downloadProgressBlock)progressHandler complete:(responseBlock)completionHandler
{
    if (![self checkNetworkStatus])
    {
        progressHandler(nil);
        
        completionHandler(nil, nil);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    if (!request) {
        return;
    }
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain", @"text/json", @"text/javascript", nil];
    
    NSURLSessionDownloadTask* downLoadTask =  [mgr downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progressHandler(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSURL *documentUrl = [[NSFileManager defaultManager] URLForDirectory :NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        return [documentUrl URLByAppendingPathComponent:[response suggestedFilename]];
        
    }completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (error)
        {
            NSLog(@"------下载失败--------%@",error);
        }
        completionHandler(response,error);
    }];
    [mgr setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        //bytesWritten单次下载字节,totalBytesWritten已经下载的字节,totalBytesExpectedToWrite总共的字节
        //        progressHandler(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    }];
    [downLoadTask resume];
}

+ (void)downloadRequest:(NSString *)url toPath:(NSString *)savePath successAndProgress:(downloadProgressBlock)progressHandler complete:(responseBlock)completionHandler
{
    if (![self checkNetworkStatus])
    {
        progressHandler(nil);
        
        completionHandler(nil, nil);
        return;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    if (!request) {
        return;
    }
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain", @"text/json", @"text/javascript", nil];
    
    NSURLSessionDownloadTask* downLoadTask =  [mgr downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
//        NSLog(@"AFN内下载进度:%lf", downloadProgress.fractionCompleted);
        progressHandler(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        if (!savePath) {
            
            NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//            NSLog(@"默认路径--%@",downloadURL);
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
            
        }else{
            return [NSURL fileURLWithPath:savePath];
        }
        
    }completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"------下载失败--------%@",error);
        }
        completionHandler(response,error);
    }];
    [mgr setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        //已完成进度
//        CGFloat downProgress = (CGFloat)totalBytesWritten/totalBytesExpectedToWrite;
//        NSLog(@"已完成进度:%lf", downProgress);
    }];
    [downLoadTask resume];
}

/**
 *  发送一个POST请求
 *  无上传进度监听
 */
+ (void)uploadRequest:(NSString *)url params:(NSDictionary *)params fileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName fileType:(NSString *)fileType success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler
{
    if (![self checkNetworkStatus])
    {
        successHandler(nil);
        failureHandler(nil);
        return;
    }
    AFHTTPSessionManager  *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain", @"text/json", @"text/javascript",@"text/html", nil];
    [mgr POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
     {
         [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:fileType];
     } progress:^(NSProgress * _Nonnull uploadProgress) {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         successHandler(responseObject);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"--------上传失败-----%@",error);
         failureHandler(error);
     }];
}

/**
 *  发送一个POST请求
 *  有上传进度监听
 */
+ (void)uploadRequest:(NSString *)url params:(NSDictionary *)params fileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName fileType:(NSString *)fileType successAndProgress:(uploadProgressBlock)progressHandler complete:(responseBlock)completionHandler
{
    if (![self checkNetworkStatus])
    {
        progressHandler(nil);
        completionHandler(nil, nil);
        return;
    }
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:fileType];
        
    } error:nil];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain", @"text/json", @"text/javascript",@"text/html", nil];
    NSURLSessionUploadTask *uploadTask = [mgr uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        progressHandler(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error)
        {
            return ;
        }
        completionHandler(responseObject,nil);
    }];
    
    [uploadTask resume];
}

@end
