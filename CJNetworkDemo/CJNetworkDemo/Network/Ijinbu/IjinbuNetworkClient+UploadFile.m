//
//  IjinbuNetworkClient+UploadFile.m
//  CJNetworkDemo
//
//  Created by ciyouzen on 2017/4/5.
//  Copyright © 2017年 dvlproad. All rights reserved.
//

#import "IjinbuNetworkClient+UploadFile.h"
#import "IjinbuHTTPSessionManager.h"
//#import "CJImageUploadItem.h"

@implementation IjinbuNetworkClient (UploadFile)

/** 多个文件上传 */
- (NSURLSessionDataTask *)requestUploadItems:(NSArray<CJUploadFileModel *> *)uploadFileModels
                                     toWhere:(NSInteger)uploadItemToWhere
                                    progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                                     completeBlock:(void (^)(IjinbuResponseModel *responseModel))completeBlock
{
    IjinbuUploadItemRequest *uploadItemRequest = [[IjinbuUploadItemRequest alloc] init];
    uploadItemRequest.uploadItemToWhere = uploadItemToWhere;
    uploadItemRequest.uploadFileModels = uploadFileModels;
    
    NSURLSessionDataTask *requestOperation =
    [self requestUploadFile:uploadItemRequest progress:uploadProgress completeBlock:completeBlock];
    
    return requestOperation;
}

/** 单个文件上传1 */
- (NSURLSessionDataTask *)requestUploadLocalItem:(NSString *)localRelativePath
                                        itemType:(CJUploadItemType)uploadItemType
                                         toWhere:(NSInteger)uploadItemToWhere
                                         completeBlock:(void (^)(IjinbuResponseModel *responseModel))completeBlock {
    NSAssert(localRelativePath != nil, @"本地相对路径错误");
    
    NSString *localAbsolutePath = [[NSHomeDirectory() stringByAppendingPathComponent:localRelativePath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:localAbsolutePath];
    if (fileExists == NO) {
        NSAssert(NO, @"Error：要上传的文件不存在");
        
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:localAbsolutePath];
    NSAssert(data != nil, @"Error：路径存在，但是获取数据为空");
    
    NSString *fileName = localAbsolutePath.lastPathComponent;
    
    NSURLSessionDataTask *requestOperation =
    [self requestUploadItemData:data itemName:fileName itemType:uploadItemType toWhere:uploadItemToWhere completeBlock:completeBlock];
    
    return requestOperation;
}

/** 单个文件上传2 */
- (NSURLSessionDataTask *)requestUploadItemData:(NSData *)data
                                       itemName:(NSString *)fileName
                                       itemType:(CJUploadItemType)uploadItemType
                                        toWhere:(NSInteger)uploadItemToWhere
                                        completeBlock:(void (^)(IjinbuResponseModel *responseModel))completeBlock
{
    NSAssert(data != nil, @"Error：路径存在，但是获取数据为空");
    
    CJUploadFileModel *uploadFileModel = [[CJUploadFileModel alloc] init];
    uploadFileModel.uploadItemType = uploadItemType;
    uploadFileModel.uploadItemData = data;
    uploadFileModel.uploadItemName = fileName;
    NSArray<CJUploadFileModel *> *uploadFileModels = @[uploadFileModel];
    
    IjinbuUploadItemRequest *uploadItemRequest = [[IjinbuUploadItemRequest alloc] init];
    uploadItemRequest.uploadItemToWhere = uploadItemToWhere;
    uploadItemRequest.uploadFileModels = uploadFileModels;
    
    NSURLSessionDataTask *requestOperation =
    [self ijinbu_uploadFile:uploadItemRequest progress:nil completeBlock:completeBlock];
    
    return requestOperation;
    
}





/*
- (CJImageUploadItem *)cjUploadImage:(UIImage *)image
                             toWhere:(NSInteger)uploadItemToWhere
                      andSaveToLocal:(BOOL)saveToLocal
                             success:(void(^)(CJImageUploadItem *uploadItem))success
                             failure:(void(^)(void))failure
{
    NSLog(@"dealWithPickPhotoCompleteImage");
    CJImageUploadItem *imageUploadItem = [[CJImageUploadItem alloc] init];
    imageUploadItem.image = [UIImage adjustImageWithImage:image];
    NSData *imageData = UIImageJPEGRepresentation(imageUploadItem.image, 0.8);
    
    //文件名
    NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *fileName = [identifier stringByAppendingPathExtension:@"jpg"];
    
    if (saveToLocal) {
        NSString *localRelativePath = [CJFileManager saveFileData:imageData
                                                     withFileName:fileName
                                               inSubDirectoryPath:@"UploadImage"
                                              searchPathDirectory:NSCachesDirectory];
        
        //上传图片
        imageUploadItem.localRelativePath = localRelativePath;
    }
    
    imageUploadItem.operation =
    [self requestUploadItemData:imageData itemName:fileName itemType:CJUploadItemTypeImage toWhere:uploadItemToWhere success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        CJResponseModel *responseModel = nil;
        
        imageUploadItem.responseModel = responseModel;
        
        if (!responseModel.result && [responseModel.result isKindOfClass:[NSArray class]])
        {
            NSArray *array = responseModel.result;
            if (array.count > 0) {
                if (success) {
                    success(imageUploadItem);
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //        [UIGlobal showMessage:error.localizedDescription];
        
        if (failure) {
            failure();
        }
    }];
    
    
    return imageUploadItem;
}
*/

@end
