//
//  SoundUtil.h
//  KeepAlive
//
//  Created by 朱东方 on 2018/5/22.
//  Copyright © 2018年 cmcm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (void)playSmsSound;
+ (void)vibrate;

+ (void)showLocalNotification:(NSString *)msg;

+ (NSString *)stringFromDate:(NSDate *)date;

@end
