//
//  AppDelegate.m
//  KeepAlive
//
//  Created by 朱东方 on 2018/5/17.
//  Copyright © 2018年 cmcm. All rights reserved.
//

#import "AppDelegate.h"
#import "BackgroundAudioPlayer.h"
#import "BackgroundDownloader.h"
#import "DeviceMoveDectector.h"
#import "Utils.h"

#import <AVFoundation/AVFoundation.h>


#define BackgroundFetchUrl @"http://img1.lespark.cn/0prqPrk2O6GI8StHy3cX"


@interface AppDelegate ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"AppDelegate: applicationDidFinishLaunchingWithOptions");
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // Reister Remote Notification
    [application registerForRemoteNotifications];
    
    // Register Local Notification
    NSInteger types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *local = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:local];
    
    // UIApplicationBackgroundFetchIntervalMinimum
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [application cancelAllLocalNotifications];
    
    // 检测手机移动
    [[DeviceMoveDectector sharedInstance] start];
    
    [[NSUserDefaults standardUserDefaults] setObject:[Utils stringFromDate:[NSDate date]]
                                              forKey:@"last_launch_time"];

    sleep(2);
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"AppDelegate: 进入前台");
    [[BackgroundAudioPlayer sharedInstance] stop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"AppDelegate: 进入后台");
    
    BOOL isSysBackgroundTaskEnabled = NO;
    BOOL isDownloadFileEnabled = NO;
    BOOL isBackgroundMusicEnabled = NO;
    
    // UIApplication#beginBackgroundTask
    if (isSysBackgroundTaskEnabled)
    {
        NSLog(@"后台 beginBaskgroundTask");
        double beginTime = CACurrentMediaTime();
        __weak typeof (self) weakSelf = self;
        self.bgTask = [UIApplication.sharedApplication beginBackgroundTaskWithName:@"KeepAlive"
                                                                 expirationHandler:
                       ^{
                           NSLog(@"bgTask expired: %f", CACurrentMediaTime() - beginTime);
                           
                           [application endBackgroundTask:weakSelf.bgTask];
                           weakSelf.bgTask = UIBackgroundTaskInvalid;
                       }];
        
        NSLog(@"ttl: %f", UIApplication.sharedApplication.backgroundTimeRemaining);
    }
    
    // 下载文件
    if (isDownloadFileEnabled)
    {
        NSLog(@"后台 下载文件");
        [[BackgroundDownloader sharedInstance] runOnComletion:^{
            NSLog(@"BackgroundDownload task finished");
        }];
    }

    // 后台音乐
    if (isBackgroundMusicEnabled)
    {
        NSLog(@"后台 播放音乐");
        [[BackgroundAudioPlayer sharedInstance] play];
    }
}

#pragma mark -

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"backgroundURLSessionTask: %@", identifier);
    
    [Utils showLocalNotification:@"download success from appd elegate"];
    completionHandler();
}
#pragma mark - 推送

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"device token: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"remoetNotification received: %f", application.backgroundTimeRemaining);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completionHandler(UIBackgroundFetchResultNoData);
    });
    
    // 后台无法启动播放音频
    // [[BackgroundAudioPlayer sharedInstance] play];
    
    NSString *resUrl = userInfo[@"aps"][@"res_url"];
    if (!resUrl) {
        resUrl = @"http://img1.lespark.cn/86AAAODxFbBSXQMaFRCi";
    }
    
    [[BackgroundDownloader sharedInstance] download:resUrl];

    if (!userInfo[@"aps"][@"alert"]) {
        [Utils showLocalNotification:@"Remote Notification Received"];
    }

    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - Backgroud Fetch

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Background Fetch: %f", application.backgroundTimeRemaining);

    [[BackgroundDownloader sharedInstance] download:BackgroundFetchUrl];
    [[NSUserDefaults standardUserDefaults] setObject:[Utils stringFromDate:[NSDate date]]
                                              forKey:@"last_bg_fetch_time"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [Utils showLocalNotification:[NSString stringWithFormat:@"Background Fetch: %f", application.backgroundTimeRemaining]];
    });
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"AppDelegate: 即将终止");
}


@end
