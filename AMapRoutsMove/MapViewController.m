//
//  MapViewController.m
//  AMapRoutsMove
//
//  Created by 666GPS on 2017/3/9.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "MapViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define blueColor UIColorFromRGB(0x208de0)//天蓝色
#define greenColor UIColorFromRGB(0x24c552)//绿色

@interface MapViewController ()<AMapSearchDelegate,MAMapViewDelegate>{
    UIButton * _startButton;//开始
    UIButton * _endButton;//停止
    UIButton * _suspendButton;//暂停
    double speedNumber;//速度
    UIProgressView * _progressView;//进度条
    UIStepper * _stepper;//改变速度
}

@property (nonatomic, strong) MAMapView *mapView;/**<地图*/
@property (nonatomic, strong) MAAnimatedAnnotation *car1;/**车辆图标*/
@property (nonatomic, strong) MAPolyline *fullTraceLine;/**<全轨迹overlay*/
@property (nonatomic, strong) MAPolyline *passedTraceLine;/**<走过轨迹的overlay*/
@property (nonatomic, assign) int passedTraceCoordIndex;/**<*/
@property (nonatomic, strong) NSArray *distanceArray;/**<*/
@property (nonatomic, assign) double sumDistance;/**<线路的总里程*/
@property (nonatomic, weak) MAAnnotationView *car1View;/**<*/

@property (nonatomic) CLLocationCoordinate2D * coordinate;

@property (nonatomic,strong) UIView * buttonView;/**<开始按钮等背景view*/
@property (nonatomic,strong) NSTimer * timer;//开始运动的时候，开启定时器去计算总进度

@end

@implementation MapViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"展示地图页";
    self.view.backgroundColor = [UIColor whiteColor];
    //把拿到的数据转化为坐标点并计算出总里程
    [self getCoordinate];
    //加载地图
    [self addMap];
    //加载开始结束按钮
    [self creatButtonAndSlider];
    
}
#pragma mark -  把拿到的数据转化为坐标点
-(void)getCoordinate{
    //赋值坐标点
    self.coordinate = (CLLocationCoordinate2D *)malloc(_dataArray.count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < _dataArray.count; i++) {
        NSDictionary * dic = _dataArray[i];
        self.coordinate[i] = CLLocationCoordinate2DMake([dic[@"lat"] doubleValue], [dic[@"lng"] doubleValue]);
    }
    //计算总里程，方便后期更改速度
    double sum = 0;
    for (int i = 0; i < _dataArray.count - 1; i++) {
        NSDictionary * dic = _dataArray[i];
        CLLocation * begin = [[CLLocation alloc]initWithLatitude:[dic[@"lat"] doubleValue] longitude:[dic[@"lng"] doubleValue]];
        NSDictionary * dic1 = _dataArray[i + 1];
        CLLocation * end = [[CLLocation alloc]initWithLatitude:[dic1[@"lat"] doubleValue] longitude:[dic1[@"lng"] doubleValue]];
        CLLocationDistance dis = [begin distanceFromLocation:end];
        sum += dis;
    }
    self.sumDistance = sum;
    //赋值初速度。一般为80km/h
    speedNumber = 80;
}
#pragma mark -  加载地图
-(void)addMap{
    self.mapView = [[MAMapView alloc]initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
}
#pragma mark -  map delegate
-(void)mapInitComplete:(MAMapView *)mapView{

    //开始画轨迹
    self.fullTraceLine = [MAPolyline polylineWithCoordinates:_coordinate count:_dataArray.count];
    [self.mapView addOverlay:self.fullTraceLine];
    
    NSMutableArray * routeAnno = [NSMutableArray array];
    for (int i = 0 ; i < _dataArray.count; i++) {
        MAPointAnnotation * a = [[MAPointAnnotation alloc] init];
        a.coordinate = self.coordinate[i];
        a.title = @"route";
        [routeAnno addObject:a];
    }
    [self.mapView addAnnotations:routeAnno];
    [self.mapView showAnnotations:routeAnno animated:NO];
    
    
    self.car1 = [[MAAnimatedAnnotation alloc] init];
    self.car1.title = @"car1";
    [self.mapView addAnnotation:self.car1];
    
    [self.car1 setCoordinate:self.coordinate[0]];

}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if (annotation == self.car1) {
        //车辆起始点的大头针
        NSString *pointReuseIndetifier = @"pointReuseIndetifier1";
        MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if(!annotationView) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            annotationView.canShowCallout = YES;
            UIImage *imge  =  [UIImage imageNamed:@"car1"];
            annotationView.image =  imge;
            self.car1View = annotationView;
        }
        
        return annotationView;
    }  else if([annotation isKindOfClass:[MAPointAnnotation class]]) {
        //线路的大头针
        NSString *pointReuseIndetifier = @"pointReuseIndetifier2";
        MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            annotationView.canShowCallout = YES;
        }
        
        if ([annotation.title isEqualToString:@"route"]) {
            annotationView.enabled = NO;
            annotationView.image = [UIImage imageNamed:@"trackingPoints"];
        }
        
        [self.car1View.superview bringSubviewToFront:self.car1View];
        
        return annotationView;
    }
    
    return nil;
}

- (MAPolylineRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if(overlay == self.fullTraceLine) {
        //所有的轨迹
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth   = 6.f;
        polylineView.strokeColor = [UIColor redColor];;
        
        return polylineView;
    } else if(overlay == self.passedTraceLine) {
        //走过的轨迹
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth   = 6.f;
        polylineView.strokeColor = [UIColor grayColor];
        
        return polylineView;
    }
    
    return nil;
}
#pragma mark -  添加开始结束按钮
-(void)creatButtonAndSlider{
    _buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height * 9 / 11, self.view.frame.size.width, self.view.frame.size.height * 2 / 11)];
    _buttonView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_buttonView];
    
    float viewW = _buttonView.frame.size.width;
    float viewH = _buttonView.frame.size.height;
    
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(8, viewH * 3 / 12, viewW * 5 / 8, 5)];
    _progressView.progressTintColor = [UIColor redColor];
    _progressView.trackTintColor = [UIColor grayColor];
    _progressView.progress = 0 ;
    [_buttonView addSubview:_progressView];
    
    _stepper = [[UIStepper alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_progressView.frame) + 8, viewH * 2 / 12, viewW / 8, viewH * 2 / 12)];
    _stepper.continuous = YES;//设置是否可以长按连续变化
    _stepper.wraps = NO;//设置是否可以循环
    _stepper.maximumValue = 10;
    _stepper.minimumValue = 1;
    _stepper.stepValue = 1;//每次改变的值
    [_stepper addTarget:self action:@selector(stepperAction) forControlEvents:UIControlEventValueChanged];
    [_buttonView addSubview:_stepper];
    
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_startButton setTitle:@"开始" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_startButton addTarget:self action:@selector(startButtonAction) forControlEvents:UIControlEventTouchUpInside];
    _startButton.frame = CGRectMake(viewW / 16, viewH * 7 / 12, viewW / 4, viewH * 4 / 12);
    _startButton.backgroundColor = greenColor;
    [_buttonView addSubview:_startButton];
    
    _suspendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_suspendButton setTitle:@"暂停" forState:UIControlStateNormal];
    [_suspendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_suspendButton addTarget:self action:@selector(suspendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    _suspendButton.frame = CGRectMake(viewW * 6 / 16, viewH * 7 / 12, viewW / 4, viewH * 4 / 12);
    _suspendButton.backgroundColor = blueColor;
    [_buttonView addSubview:_suspendButton];
    
    _endButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_endButton setTitle:@"结束" forState:UIControlStateNormal];
    [_endButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_endButton addTarget:self action:@selector(endButtonAction) forControlEvents:UIControlEventTouchUpInside];
    _endButton.frame = CGRectMake(viewW * 11 / 16, viewH * 7 / 12, viewW / 4, viewH * 4 / 12);
    _endButton.backgroundColor = greenColor;
    [_buttonView addSubview:_endButton];
}
//开始运动
-(void)startButtonAction{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self.timer fire];
    __block MapViewController * wself = self;
    [self.car1 setCoordinate:self.coordinate[0]];
    [self.car1 addMoveAnimationWithKeyCoordinates:self.coordinate count:_dataArray.count withDuration:self.sumDistance / speedNumber withName:nil completeCallback:^(BOOL isFinished) {
        //结束的时候最后进行一次进度获取，否则定时器获取的进度达不到最后一个时间点
        [wself timerAction];
        [wself.timer invalidate];
    }];
}
-(void)suspendButtonAction{
    NSArray * array = [self.car1 allMoveAnimations];
    NSLog(@"arr == %@",array);
    MAAnnotationMoveAnimation * animation = array[0];
//    [animation cancel];
    CLLocationCoordinate2D * coor = animation.coordinates;
    [self.car1 setCoordinate:coor[0]];
}
//结束运动
-(void)endButtonAction{
    for(MAAnnotationMoveAnimation *animation in [self.car1 allMoveAnimations]) {
        [animation cancel];
    }
    self.car1.movingDirection = 0;
    [self.car1 setCoordinate:self.coordinate[0]];
}
//改变速度
-(void)stepperAction{
    NSLog(@"这事的速度是   %f",_stepper.value);
    NSArray * array = [self.car1 allMoveAnimations];
    NSLog(@"arr == %@",array);
    MAAnnotationMoveAnimation * animation = array[0];
    CLLocationCoordinate2D coor = *(animation.coordinates);
    [self.car1 setCoordinate:coor];
}
//显示进度
-(void)timerAction{
    for(MAAnnotationMoveAnimation *animation in [self.car1 allMoveAnimations]) {
        float pro = animation.elapsedTime / animation.duration;
        float na = pro * _dataArray.count;
        
        NSLog(@"那到数据的   %.0f",na);
        [_progressView setProgress:pro animated:YES];
       }
}
#pragma mark -  懒加载定时器
-(NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
    return _timer;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
