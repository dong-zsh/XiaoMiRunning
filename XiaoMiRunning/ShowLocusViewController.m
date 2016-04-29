//
//  ShowLocusViewController.m
//  XiaoMiRunning
//
//  Created by 张东东 on 16/4/28.
//  Copyright © 2016年 zhangdongdong. All rights reserved.
//

#import "ShowLocusViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "DataBaseHelper.h"

@interface ShowLocusViewController ()<BMKMapViewDelegate>
{
    BMKMapView *mapView;
    NSMutableArray *rundataArr;
    CLLocation *firstLocation;
    CLLocation *lastLocation;
}
@end

@implementation ShowLocusViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [mapView viewWillAppear];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [mapView viewWillDisappear];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    rundataArr = [NSMutableArray array];
    mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [mapView setMapType:BMKMapTypeStandard];
    mapView.delegate = self;
    self.view = mapView;
    //取出所有的点
    [self selectAllDataWithTime];
    //设置当前地图的显示范围，根据第一个点
    if (rundataArr.count > 0) {
        firstLocation = (CLLocation *)rundataArr[0];
        lastLocation = (CLLocation *)[rundataArr lastObject];
        [self passLocationValueWithLocation:firstLocation];
        //画出折线图
        [self drawLocusMap];
        //添加开始，结束标注
        [self setAnnotation];
    }
    
    
    
}
- (void)setAnnotation
{
    BMKPointAnnotation *startAnn = [[BMKPointAnnotation alloc] init];
    startAnn.coordinate = firstLocation.coordinate;
    startAnn.title = @"开始";
    BMKPointAnnotation *stopAnn = [[BMKPointAnnotation alloc] init];
    stopAnn.coordinate = lastLocation.coordinate;
    stopAnn.title = @"结束";
    NSArray *arr = [NSArray arrayWithObjects:startAnn,stopAnn, nil];
    [mapView addAnnotations:arr];
    
}
- (void)drawLocusMap
{
    CLLocationCoordinate2D coors[1000] = {0};
    for (int index = 0; index < rundataArr.count; index ++) {
        CLLocation *location = rundataArr[index];
        coors[index] =location.coordinate;
    }
    BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:coors count:rundataArr.count];
    [mapView addOverlay:polyline];
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
- (void)selectAllDataWithTime
{
    NSData *runData = [DataBaseHelper selectRunDataWithTime:self.time];
    rundataArr = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:runData];
}
#pragma mark BMKMapViewDelegate
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
