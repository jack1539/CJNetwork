//
//  LoginHelper.h
//  LoginDemo
//
//  Created by ciyouzen on 7/4/15.
//  Copyright (c) 2015 dvlproad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginHelper : NSObject

+ (void)login_name:(NSString *)name pasd:(NSString *)pasd;
+ (void)logout;

+ (BOOL)isLogin;

+ (NSString *)loginName;
+ (NSString *)loginPasd;


@end
