//
//  MainMapViewController.m
//  XiaoMiRunning
//
//  Created by 张东东 on 16/4/25.
//  Copyright © 2016年 zhangdongdong. All rights reserved.
//

#define Kwidth self.view.bounds.size.width
#define Kheight self.view.bounds.size.height


#import "MainMapViewController.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import "SingleLocationManager.h"
#import "RunHistoryViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "DataBaseHelper.h"

@interface MainMapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,CLLocationManagerDelegate>
{
    BMKMapView *mapView;
    BMKLocationService *locService;
    BMKPointAnnotation *startAnnotation;
    BMKPointAnnotation *stopAnnotation;
    
    SingleLocationManager *manager;

    NSTimer *RunTimer;
    BOOL first;
    BOOL trackMode;
    BOOL alltime;
    NSMutableArray *coorArray;
    UIButton *startBtn;
    UIButton *stopBtn;
    CLLocation *lastLocation;//保存上一个坐标点
}
@end

@implementation MainMapViewController

- (void)viewWillAppear:(BOOL)animated
{
    [mapView viewWillAppear];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [mapView viewWillDisappear];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = self.view.tintColor;
    [self setNavigationBar];
    [DataBaseHelper creatdb];
    first = NO;
    trackMode = NO;
    alltime = YES;
    coorArray = [NSMutableArray array];
    
    manager = [SingleLocationManager shareManager];
    //初始化百度定位类
    locService = manager.bmkLocation;
    locService.delegate = self;
    locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locService.distanceFilter = kCLDistanceFilterNone;
    [locService startUserLocationService];
    //初始化mapview
    [self setUpMapView];
    //开启百度定位
    [locService startUserLocationService];
    
}
- (void)setNavigationBar
{
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake((Kwidth-100)/2, 30, 100, 20)];
    titleLable.text = @"跑吧";
    titleLable.textColor = [UIColor whiteColor];
    titleLable.font = [UIFont systemFontOfSize:18];
    titleLable.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = (UIView *)titleLable;
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"记录" style:UIBarButtonItemStylePlain target:self action:@selector(pushNextVc:)];
    rightBtn.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:rightBtn];
    
}
//初始化地图
- (void)setUpMapView
{
    mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self setStartButton];
    [self setStopButton];
    //地图类型
    [mapView setMapType:BMKMapTypeStandard];
    mapView.showsUserLocation = NO;
    mapView.userTrackingMode = BMKUserTrackingModeNone;
    mapView.showsUserLocation = YES;
    mapView.delegate = self;
    self.view = mapView;
}
- (void)setStartButton
{
    startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.backgroundColor = [UIColor whiteColor];
    startBtn.alpha = 0.8;
    [startBtn setTitle:@"开始" forState:UIControlStateNormal];
    [startBtn setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    startBtn.frame = CGRectMake(20, 84, 80, 40);
    [startBtn addTarget:self action:@selector(startTrackMode) forControlEvents:UIControlEventTouchUpInside];
    [mapView addSubview:startBtn];
}
- (void)startTrackMode
{
    //先实时定位
    alltime = NO;
    [locService stopUserLocationService];
    
    startBtn.selected = YES;
    [startBtn setTitle:@"定位中..." forState:UIControlStateSelected];
    startBtn.userInteractionEnabled = NO;
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];
    RunTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(doOnecLocation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:RunTimer forMode:NSDefaultRunLoopMode];
    [RunTimer fire];
    //添加开始标注点
    [self addStartAnnotation];
}
- (void)addStartAnnotation
{
    startAnnotation = [[BMKPointAnnotation alloc] init];
    startAnnotation.coordinate = lastLocation.coordinate;
    startAnnotation.title = @"开始";
    [mapView addAnnotation:startAnnotation];
}
- (void)setStopButton
{
    stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopBtn.backgroundColor = [UIColor whiteColor];
    stopBtn.alpha = 0.8;
    [stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    [stopBtn setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    stopBtn.frame = CGRectMake(280, 84, 80, 40);
    [stopBtn addTarget:self action:@selector(stopLocation) forControlEvents:UIControlEventTouchUpInside];
    [mapView addSubview:stopBtn];
    
}
- (void)stopLocation
{
    startBtn.selected = NO;
    startBtn.userInteractionEnabled = YES;
    [RunTimer invalidate];
    trackMode = NO;
    NSLog(@"收集到的所有点%@",coorArray);
    //将多有数据保存进数据库
    [self saveAllDataToDatabaseWithArr:coorArray];
    [coorArray removeAllObjects];
    [self addStopAnnotation];
    //开启实时定位
    [locService startUserLocationService];
    alltime = YES;
}
- (void)addStopAnnotation
{
    stopAnnotation = [[BMKPointAnnotation alloc] init];
    stopAnnotation.coordinate = lastLocation.coordinate;
    stopAnnotation.title = @"停止";
    [mapView addAnnotation:stopAnnotation];
}
- (void)pushNextVc:(id)sender
{
    //验证指纹是否可用
    [self authenticateUser];
    
}
- (void)authenticateUser
{
    //初始化上下文对象
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"输入密码";
    //判断设备是否支持
    NSString *result = @"需要验证你的指纹";
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
        //支持
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:result reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                //验证成功主线程处理ui
                dispatch_async(dispatch_get_main_queue(), ^{
                    RunHistoryViewController *runVc = [[RunHistoryViewController alloc] init];
                    [self.navigationController pushViewController:runVc animated:YES];
                });
            }else{
                NSLog(@"%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        //切换到其他APP，系统取消验证Touch ID
                        NSLog(@"Authentication was cancelled by the system");
                        break;
                    }
                        
                    case LAErrorUserCancel:
                    {
                        //用户取消验证Touch ID
                        NSLog(@"Authentication was cancelled by the user");
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        NSLog(@"User selected to enter custom password");
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //用户选择输入密码，切换主线程处理
                            
                        }];
                        break;
                    }
                    default:
                        break;
                }
            }
        }];
    }else{
        NSLog(@"不支持TouchId");
    }
    
}
- (void)doOnecLocation
{
    NSLog(@"定位一次");
    trackMode = YES;
    [locService startUserLocationService];
    
}
//保存到数据库
- (void)saveAllDataToDatabaseWithArr:(NSMutableArray *)array
{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formmatter = [[NSDateFormatter alloc] init];
    [formmatter setDateFormat:@"yyyy-MM-dd hh-mm"];
    NSString *nowDateStr = [formmatter stringFromDate:nowDate];
    
    //归档
    NSData *rundata = [NSKeyedArchiver archivedDataWithRootObject:array];
    NSDictionary *saveDic = @{@"time":nowDateStr,@"runData":rundata};
    //插入数据库
    [DataBaseHelper insertRunDataWithdic:saveDic];
}
- (void)updateMapViewShowWithLOcation:(CLLocation *)location
{
    NSLog(@"%@",location);
    [locService stopUserLocationService];
    //收集坐标dian
    [coorArray addObject:location];
    //计算本次定位数据与上次定位数据之间的距离
    CGFloat distance = [location distanceFromLocation:lastLocation];
    if (distance < 5 || distance > 100 || location.speed < 0.5) {
        //如果移动距离小于5或大于50，不绘制图层
        NSLog(@"偏移距离%0.0f------无效点",distance);
        return;
    }
    //直接根据两点画出实时轨迹图
    CLLocationCoordinate2D coors[2] = {0};
    coors[0] = lastLocation.coordinate;
    coors[1] = location.coordinate;
    BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:coors count:2];
    [mapView addOverlay:polyline];
    //更新上一个点
    lastLocation = location;
    
}

-(void)passLocationValueWithLocation:(CLLocation *)location
{
    CLLocationCoordinate2D coor;
    coor = location.coordinate;
    BMKCoordinateRegion viewRegion;
    viewRegion.center = coor;
    viewRegion.span.latitudeDelta = 0.008;
    viewRegion.span.longitudeDelta = 0.008;
    BMKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    
}

#pragma mark BMKMapviewDelegate
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = 8.0;
        return polylineView;
    }
    return nil;
}
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

#pragma mark BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"正在定位");
    [mapView updateLocationData:userLocation];
    //定位到当前位置并显示最适合的地图范围
    if (first == NO) {
        [self passLocationValueWithLocation:userLocation.location];
        first =YES;
    }
    //实时更新用户的最新位置
    if (alltime == YES) {
        lastLocation = userLocation.location;
    }

    if (trackMode == YES) {
        [self updateMapViewShowWithLOcation:userLocation.location];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
