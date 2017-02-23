//
//  LocationTool.m
//  AccurateLocation
//
//  Created by vochi on 2017/2/22.
//  Copyright © 2017年 vochi. All rights reserved.
//

#import "LocationTool.h"
#import "WGS84TOGCJ02.h"
#import "NetworkRequestTools.h"
#import "SVProgressHUD.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationTool () <CLLocationManagerDelegate>
{
    requestSuccessBlock _successBlock;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isStopLocation;
@property (nonatomic, copy) NSString *longitude;//经度
@property (nonatomic, copy) NSString *latitude;//纬度
@property (nonatomic, copy) NSString *address;

@end

static id locationTool;

@implementation LocationTool

+ (id)shareLocation
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationTool = [[LocationTool alloc] init];
    });
    return locationTool;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.isStopLocation = NO;
    }
    return self;
}

#pragma mark - 获取定位信息
- (void)getLocationPointSuccess:(requestLocationSuccessBlock)successHandler failure:(requestLocationFailureBlock)failureHandler
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"定位失败" message:@"请在“设置”－“隐私”－“定位服务”－“应用”中打开定位服务" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    else
    {
        _successBlock = successHandler;
        
        //定位
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate
// 地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //加上判断防止多次调用
    if (self.isStopLocation == NO)
    {
        //得到newLocation
        CLLocation *loc = [locations lastObject];
        
        //判断是不是属于国内范围
        if (![WGS84TOGCJ02 isLocationOutOfChina:[loc coordinate]]) {
            //转换后的coord
            CLLocationCoordinate2D coord = [WGS84TOGCJ02 transformFromWGSToGCJ:[loc coordinate]];
            NSLog(@"原始经度:%f***纬度:%f", [loc coordinate].longitude, [loc coordinate].latitude);
            NSLog(@"经度:%f***纬度:%f", coord.longitude, coord.latitude);
            
            self.longitude = [NSString stringWithFormat:@"%f", coord.longitude];
            self.latitude = [NSString stringWithFormat:@"%f", coord.latitude];
        }
        else
        {
            self.longitude = [NSString stringWithFormat:@"%f", loc.coordinate.longitude];
            self.latitude = [NSString stringWithFormat:@"%f", loc.coordinate.latitude];
        }

//        [SVProgressHUD show];
        
        //将系统坐标转换为百度坐标
        NSDictionary *parameters = @{@"ak": @"GQLfjGnzrWBHq0sIKvyxVXaKLAvpUnez",@"coords":[NSString stringWithFormat:@"%@,%@",self.longitude, self.latitude],@"from":@"3",@"output":@"json"};

        [NetworkRequestTools postRequest:@"http://api.map.baidu.com/geoconv/v1/" params:parameters success:^(id responseObj) {
            
            NSDictionary *tmpDict = (NSDictionary *)responseObj;
            NSLog(@"转换后字典:%@", tmpDict);
            
            NSString *status = [NSString stringWithFormat:@"%@", tmpDict[@"status"]];
            if ([status isEqualToString:@"0"]) {
                NSArray *arr = tmpDict[@"result"];
                if (arr && arr.count > 0) {
                    NSDictionary *locationDict = [arr objectAtIndex:0];
                    self.longitude = locationDict[@"x"];
                    self.latitude = locationDict[@"y"];
                    
                    //调用百度地图接口获得位置
                    NSDictionary *parameters1 = @{@"ak": @"GQLfjGnzrWBHq0sIKvyxVXaKLAvpUnez",@"callback":@"renderReverse",@"location":[NSString stringWithFormat:@"%@,%@",self.latitude, self.longitude],@"output":@"json",@"pois":@"1"};
                    
                    [NetworkRequestTools postRequest:@"http://api.map.baidu.com/geocoder/v2/" params:parameters1 success:^(id responseObj) {
                        
                        NSDictionary *tmpDict1 = (NSDictionary *)responseObj;
                        NSLog(@"获取的定位位置:%@", tmpDict1);
                        
                        NSString *status = [NSString stringWithFormat:@"%@", tmpDict1[@"status"]];
                        if ([status isEqualToString:@"0"]) {
                            NSString *cityStr = tmpDict1[@"result"][@"addressComponent"][@"city"];
                            NSString *districtStr = tmpDict1[@"result"][@"addressComponent"][@"district"];
                            
                            NSArray * arr1 = tmpDict1[@"result"][@"pois"];
                            if (arr1 && arr1.count > 0) {
                                NSDictionary *locationDict1 = [arr1 objectAtIndex:0];
                                
                                self.address = [NSString stringWithFormat:@"%@%@%@", cityStr, districtStr, locationDict1[@"addr"]];
                                NSLog(@"我的位置:%@", self.address);
                                
                                _successBlock(self.address);
                            }
                            
//                            [self requestNetworkData];
//                            NSString *accurateLocation = self.address;
                            
                            
                            [SVProgressHUD dismiss];
                        }
                        else
                        {
                            [self getMyselfLocation];
                        }
                    } failure:^(NSError *error) {
                        
                        [self getMyselfLocation];
                    }];
                }
            }
            else
            {
                [self getMyselfLocation];
            }
        } failure:^(NSError *error) {
            
            [self getMyselfLocation];
        }];
        
    }
    else
    {
        
    }
    
    // 停止位置更新
    [self.locationManager stopUpdatingLocation];
    
    self.isStopLocation = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied)
    {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown)
    {
        NSLog(@"无法获取位置信息");
    }
    
    [self getMyselfLocation];
}

//如果网络请求没成功,用自带框架根据经纬度反向地理编译出地址信息
- (void)getMyselfLocation
{
    //    [SVProgressHUD showWithStatus:@"登录中..."];
    [SVProgressHUD show];
    
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:[self.latitude floatValue] longitude:[self.longitude floatValue]];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             
             NSLog(@"位置信息^^^^%@ %@", placemark.name, placemark.thoroughfare);
             
             self.address = [NSString stringWithFormat:@"%@", placemark.name];
             
             //获取城市
             NSString *city = placemark.locality;
             if (!city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             NSLog(@"city = %@", city);
             
             _successBlock(self.address);
             
             [SVProgressHUD dismiss];
             
         }
         else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }
         else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
         
     }];
}

//防止空值
- (void)safeData
{
    if (self.latitude == nil) {
        self.latitude = @"39.929378";
    }
    if (self.longitude == nil) {
        self.longitude = @"116.521605";
    }
    if (self.address == nil) {
        self.address = @"北京市朝阳区青年路";
    }
}

@end
