//
//  ViewController.h
//  KeepAlive
//
//  Created by 朱东方 on 2018/5/17.
//  Copyright © 2018年 cmcm. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KeepAliveMethod) {
    KeepAliveMethod_UIApplication_BackgroundTask,
    KeepAliveMethod_NSURLSession_DownloadTask,
    
    KeepAliveMethod_Audio,
    KeepAliveMethod_Location,
    KeepAliveMethod_VoIP,
    KeepAliveMethod_NewsstandDownloads,     // 杂志定时更新
    KeepAliveMethod_AccessoryComm,          // 配件交互
    KeepAliveMethod_BluetoothComm,          // 蓝牙设备
    KeepAliveMethod_BackgroundFetch,        //
    KeepAliveMethod_RemoteNotification,     // 推送
};


@interface ViewController : UIViewController


@end

