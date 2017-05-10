//
//  OCModel.h
//  AMapRoutsMove
//
//  Created by 666GPS on 2017/3/24.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCModel : NSObject
+(void)str:(NSString *)str1 Success:(void(^)(id successed))seccess Fail:(void(^)(id failed))fail;

@end
