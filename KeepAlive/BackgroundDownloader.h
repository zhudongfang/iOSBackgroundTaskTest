//
//  BackgroundDownloadTask.h
//  KeepAlive
//
//  Created by 朱东方 on 2018/5/23.
//  Copyright © 2018年 cmcm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackgroundDownloader : NSObject

+ (instancetype)sharedInstance;

- (void)createSessionWithIdentifier:(NSString *)identifier;

- (void)runOnComletion:(void (^)(void))completionHandler;

- (void)download:(NSString *)resUrl;

@end
