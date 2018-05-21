//
//  DeviceMoveDectector.h
//  KeepAlive
//
//  Created by 朱东方 on 2018/5/23.
//  Copyright © 2018年 cmcm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceMoveDectector : NSObject

+ (instancetype)sharedInstance;

- (void)start;
- (void)stop;

@end
