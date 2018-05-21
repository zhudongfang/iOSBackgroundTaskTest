//
//  Toast.m
//  KeepAlive
//
//  Created by 朱东方 on 2018/5/21.
//  Copyright © 2018年 cmcm. All rights reserved.
//

#import "Toast.h"

@implementation Toast

+ (void)show:(NSString *)text
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self show:text];
            return;
        });
    }
    
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    UILabel *label = [keyWindow viewWithTag:10010];
    if (!label) {
        label = [UILabel new];
        label.layer.cornerRadius = 8.0;
        label.layer.masksToBounds = YES;
        [keyWindow addSubview:label];
    }
    
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 10010;
    label.text = text;

    CGSize size = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(UIScreen.mainScreen.bounds) - 40 * 2 - 10 * 2, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: label.font}
                                     context:nil].size;
    size.width += 20;
    size.height += 20;
    
    label.frame = CGRectMake((CGRectGetWidth(UIScreen.mainScreen.bounds) - size.width) / 2.0 - 10,
                             CGRectGetHeight(UIScreen.mainScreen.bounds) - size.height - 40,
                             size.width, size.height);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:label];
    [label performSelector:@selector(removeFromSuperview)
                withObject:nil
                afterDelay:3.0
                   inModes:@[NSRunLoopCommonModes]];
}

@end
