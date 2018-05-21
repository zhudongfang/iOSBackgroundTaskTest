//
//  SoundUtil.m
//  KeepAlive
//
//  Created by 朱东方 on 2018/5/22.
//  Copyright © 2018年 cmcm. All rights reserved.
//

#import "Utils.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@implementation Utils

+ (void)playSmsSound
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSString *path = @"/System/Library/Audio/UISounds/sms-received2.caf";
    //创建声音对象
    SystemSoundID theSoundID;
    OSStatus error =AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&theSoundID);
    if(error == kAudioServicesNoError){//创建成功
        // _soundID=theSoundID;
    } else {
        NSLog(@"Failed to create sound");
    }
}

+ (void)vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void)showLocalNotification:(NSString *)msg
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showLocalNotification:msg];
            return;
        });
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *oldNotifications = [app scheduledLocalNotifications];
    
    // Clear out the old notification before scheduling a new one.
    if ([oldNotifications count] > 0) {
        [app cancelAllLocalNotifications];
    }

    // Create a new notification.
    UILocalNotification *alarm = [[UILocalNotification alloc] init];
    if (alarm) {
        alarm.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        alarm.timeZone = [NSTimeZone defaultTimeZone];
        alarm.repeatInterval = 0;
        alarm.soundName = @"alarmsound.caf";
        if (msg) {
            alarm.alertBody = msg;
        } else {
            alarm.alertBody = @"Time to wake up!";
        }

        [app scheduleLocalNotification:alarm];
    }
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [fmt stringFromDate:date];
}

@end
