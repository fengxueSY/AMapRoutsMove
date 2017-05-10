//
//  OCModel.m
//  AMapRoutsMove
//
//  Created by 666GPS on 2017/3/24.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "OCModel.h"

@implementation OCModel
+(void)str:(NSString *)str1 Success:(void (^)(id))seccess Fail:(void (^)(id))fail{
    if ([str1 isEqualToString:@"1"]) {
        seccess(@"这里显示的是1");
    }else{
        fail(@"这里我西安市多会死啊很低调和");
    }
}
@end
