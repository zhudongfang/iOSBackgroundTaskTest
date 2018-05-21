//
//  DeviceMoveDectector.m
//  KeepAlive
//
//  Created by 朱东方 on 2018/5/23.
//  Copyright © 2018年 cmcm. All rights reserved.
//

#import "DeviceMoveDectector.h"
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Utils.h"

@interface DeviceMoveDectector()

@property (nonatomic, strong) CMMotionManager *manager;

@property (nonatomic, assign) double oldX;
@property (nonatomic, assign) double oldY;
@property (nonatomic, assign) double oldZ;
@property (nonatomic, assign) NSInteger count;

@end


@implementation DeviceMoveDectector

+ (instancetype)sharedInstance
{
    static DeviceMoveDectector *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DeviceMoveDectector new];
    });
    return instance;
}

- (void)start
{
    if (_manager.isAccelerometerActive) return;
    
    if (!_manager) {
        _manager = [[CMMotionManager alloc] init];
        _manager.accelerometerUpdateInterval = 1.0;
    }
    __weak typeof (self) weakSelf = self;
    [_manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                   withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error)
     {
         double ttl = UIApplication.sharedApplication.backgroundTimeRemaining > NSIntegerMax ? NSIntegerMax : UIApplication.sharedApplication.backgroundTimeRemaining;
         NSLog(@"DeviceMoveDectector: count: %ld bg_ttl: %f", weakSelf.count++, ttl);
         
         double newX = accelerometerData.acceleration.x;
         double newY = accelerometerData.acceleration.y;
         double newZ = accelerometerData.acceleration.z;
         
         if (weakSelf.oldX == 0 && weakSelf.oldY == 0 && weakSelf.oldZ == 0) {
             weakSelf.oldX = newX;
             weakSelf.oldY = newY;
             weakSelf.oldZ = newZ;
             return;
         }
         
         if (fabs(newX - weakSelf.oldX) > 0.5 ||
             fabs(newY - weakSelf.oldY) > 0.5 ||
             fabs(newZ - weakSelf.oldZ) > 0.5)
         {
             weakSelf.oldX = newX;
             weakSelf.oldY = newY;
             weakSelf.oldZ = newZ;
             
             [weakSelf handleMove];
         }
     }];
}

- (void)stop
{
    if (_manager && _manager.isAccelerometerActive) {
        [_manager stopAccelerometerUpdates];
    }
}

- (void)handleMove
{
    [Utils vibrate];
    [Utils showLocalNotification:[NSString stringWithFormat:@"device move: %ld", self.count]];
}

@end
