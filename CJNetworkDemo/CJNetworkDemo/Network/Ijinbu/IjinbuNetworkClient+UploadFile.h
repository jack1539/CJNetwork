//
//  IjinbuNetworkClient+UploadFile.h
//  CJNetworkDemo
//
//  Created by ciyouzen on 2017/4/5.
//  Copyright © 2017年 dvlproad. All rights reserved.
//

#import "IjinbuNetworkClient.h"
#import "AFHTTPSessionManager+CJUploadFile.h"
#import "IjinbuUploadItemRequest.h"

@interface IjinbuNetworkClient (UploadFile)

/** 多个文件上传 */
- (nullable NSURLSessionDataTask *)requestUploadItems:(NSArray<CJUploadFileModel *> * _Nullable)uploadFileModels
                                     toWhere:(NSInteger)uploadItemToWhere
                                    progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                                        completeBlock:(void (^)(IjinbuResponseModel *responseModel))completeBlock;

/** 单个文件上传1 */
- (nullable NSURLSessionDataTask *)requestUploadLocalItem:(NSString * _Nullable)localRelativePath
                                        itemType:(CJUploadItemType)uploadItemType
                                         toWhere:(NSInteger)uploadItemToWhere
                                            completeBlock:(void (^)(IjinbuResponseModel *responseModel))completeBlock;

/** 单个文件上传2 */
- (nullable NSURLSessionDataTask *)requestUploadItemData:(NSData * _Nullable)data
                                       itemName:(NSString *_Nullable)fileName
                                       itemType:(CJUploadItemType)uploadItemType
                                        toWhere:(NSInteger)uploadItemToWhere
                                           completeBlock:(void (^)(IjinbuResponseModel *responseModel))completeBlock;

/** 上传文件 */
- (nullable NSURLSessionDataTask *)requestUploadFile:(IjinbuUploadItemRequest *_Nullable)request
                                   progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                                       completeBlock:(void (^)(IjinbuResponseModel *responseModel))completeBlock;




@end
