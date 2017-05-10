//
//  ViewController.h
//  AMapRoutsMove
//
//  Created by 666GPS on 2017/3/9.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,Stion){
    StionOne = 1,
    StionTwo = 2,
};

@interface ViewController : UIViewController

-(void)showT:(NSString *)str;
@property (nonatomic,assign) Stion a;
@end

