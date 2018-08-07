//
//  CJRequestUtil.m
//  CJNetworkDemo
//
//  Created by ciyouzen on 15/11/22.
//  Copyright © 2015年 dvlproad. All rights reserved.
//

#import "CJRequestUtil.h"
#import "CJNetworkErrorUtil.h"
#import "CJNetworkLogUtil.h"

@implementation CJRequestUtil

#pragma mark - POST请求
/* //详细的app中增加实现的通用方法的例子如下
+ (void)xx_postUrl:(NSString *)Url
            params:(id)params
           encrypt:(BOOL)encrypt
           success:(void (^)(NSDictionary *responseObject))success
           failure:(void (^)(NSError *error))failure {
    
    NSData * (^encryptBlock)(NSDictionary *requestParmas) = ^NSData *(NSDictionary *requestParmas) {
        NSData *bodyData = [CJEncryptAndDecryptTool encryptParmas:params];//在详细的app中需要实现的方法
        return bodyData;
    };
    
    NSDictionary * (^decryptBlock)(NSString *responseString) = ^NSDictionary *(NSString *responseString) {
        NSDictionary *responseObject = [CJEncryptAndDecryptTool decryptJsonString:responseString];//在详细的app中需要实现的方法
        return responseObject;
    };
    
    [self cj_postUrl:Url params:params encryptBlock:encryptBlock decryptBlock:decryptBlock success:success failure:failure];
}
*/


/* 完整的描述请参见文件头部 */
+ (NSURLSessionDataTask *)cj_postUrl:(NSString *)Url
                              params:(id)params
                             encrypt:(BOOL)encrypt
                        encryptBlock:(NSData * (^)(NSDictionary *requestParmas))encryptBlock
                        decryptBlock:(NSDictionary * (^)(NSString *responseString))decryptBlock
                             success:(void (^)(NSDictionary *responseObject))success
                             failure:(void (^)(NSError *error))failure
{
    /* 利用Url和params，通过加密的方法创建请求 */
    NSData *bodyData = nil;
    if (encrypt && encryptBlock) {
        //bodyData = [CJEncryptAndDecryptTool encryptParmas:params];
        bodyData = encryptBlock(params);
    } else {
        bodyData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    }
    
    NSURL *URL = [NSURL URLWithString:Url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPBody:bodyData];
    [request setHTTPMethod:@"POST"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error == nil) {
            NSDictionary *recognizableResponseObject = nil; //可识别的responseObject,如果是加密的还要解密
            if (encrypt && decryptBlock) {
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                //recognizableResponseObject = [CJEncryptAndDecryptTool decryptJsonString:responseString];
                recognizableResponseObject = decryptBlock(responseString);
                
            } else {
                recognizableResponseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            }
            
            //successNetworkLog
            id newResponseObject =
            [CJNetworkLogUtil printSuccessNetworkLogWithUrl:Url params:params responseObject:recognizableResponseObject];
            
            if (success) {
                success(newResponseObject);
            }
        }
        else
        {
            //errorNetworkLog
            NSError *newError = [CJNetworkLogUtil printErrorNetworkLogWithUrl:Url params:params error:error URLResponse:response];
            
            if (failure) {
                failure(newError);
            }
            
        }
    }];
    [task resume];
    
    return task;
}



#pragma mark - GET请求
/* 完整的描述请参见文件头部 */
+ (void)cj_getUrl:(NSString *)Url
           params:(id)params
          success:(void (^)(NSDictionary *responseObject))success
          failure:(void (^)(NSError *error))failure
{
    NSString *fullUrlForGet = [self connectRequestUrl:Url params:params];
    NSURL *URL = [NSURL URLWithString:fullUrlForGet];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"GET"]; //此行可省略，因为默认就是GET方法，附Get方法没有body
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error == nil) {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSLog(@"\n\n  >>>>>>>>>>>>  网络请求Start  >>>>>>>>>>>>  \n地址和参数：%@ \n结果：%@ \n  <<<<<<<<<<<<<  网络请求End  <<<<<<<<<<<<<  \n\n\n", fullUrlForGet, responseObject);
            
            if (success) {
                success(responseObject);
            }
        }
        else
        {
            //NSDictionary *responseObject = @{@"status":@(-1), @"message":@"网络异常"};
            if (failure) {
                failure(error);
            }
            
            NSString *errorMessage = [CJNetworkErrorUtil getErrorMessageFromURLResponse:response];
            NSLog(@"\n\n  >>>>>>>>>>>>  网络请求Start  >>>>>>>>>>>>  \n地址：%@ \n参数：%@ \n结果：%@ \n  <<<<<<<<<<<<<  网络请求End  <<<<<<<<<<<<<  \n\n\n", Url, params, errorMessage);
        }
    }];
    [task resume];
}


/**
 *  连接请求的地址与参数，返回连接后所形成的字符串
 *
 *  @param requestUrl       请求的地址
 *  @param requestParams    请求的参数
 *
 *  @return 连接后所形成的字符串
 */
+ (NSString *)connectRequestUrl:(NSString *)requestUrl params:(NSDictionary *)requestParams {
    if (requestParams == nil) {
        return requestUrl;
    }
    
    //获取GET方法的参数组成的字符串requestParmasString
    NSMutableString *requestParmasString = [NSMutableString new];
    for (NSString *key in [requestParams allKeys]) {
        id obj = [requestParams valueForKey:key];
        if ([obj isKindOfClass:[NSString class]]) { //NSString
            if (requestParmasString.length != 0) {
                [requestParmasString appendString:@"&"];
            } else {
                [requestParmasString appendString:@"?"];
            }
            
            NSString *keyValueString = obj;
            [requestParmasString appendFormat:@"%@=%@", key, keyValueString];
            
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            if (requestParmasString.length != 0) {
                [requestParmasString appendString:@"&"];
            } else {
                [requestParmasString appendString:@"?"];
            }
            
            NSString *keyValueString = [obj stringValue];
            [requestParmasString appendFormat:@"%@=%@", key, keyValueString];
            
        } else if ([obj isKindOfClass:[NSArray class]]) { //NSArray
            for (NSString *value in obj) {
                if (requestParmasString.length != 0) {
                    [requestParmasString appendString:@"&"];
                } else {
                    [requestParmasString appendString:@"?"];
                }
                
                NSString *keyValueString = value;
                [requestParmasString appendFormat:@"%@=%@", key, keyValueString];
            }
        } else {
            
        }
    }
    
    NSString *fullUrlForGet = [NSString stringWithFormat:@"%@%@", requestUrl, requestParmasString];
    return fullUrlForGet;
}








@end
