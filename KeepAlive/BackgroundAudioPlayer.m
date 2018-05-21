//
//  BackgroundAudioPlayer.m
//  KeepAlive
//
//  Created by 朱东方 on 2018/5/23.
//  Copyright © 2018年 cmcm. All rights reserved.
//

#import "BackgroundAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface BackgroundAudioPlayer()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation BackgroundAudioPlayer

+ (instancetype)sharedInstance
{
    static BackgroundAudioPlayer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [BackgroundAudioPlayer new];
    });
    return instance;
}

- (void)play
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [self stop];
    _audioPlayer = nil;

    if (!_audioPlayer) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"10years" ofType:@"mp3"]];;
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (error) {
            NSLog(@"BackgroundAudioPlayer: init player error: %@", error);
            return;
        }
        _audioPlayer.numberOfLoops = -1;
        _audioPlayer.delegate = self;
    }

    if (_audioPlayer.isPlaying) return;
    
    BOOL succ = [_audioPlayer play];
    if (succ) {
        NSLog(@"BackgroundAudioPlayer: succ");
    } else {
        NSLog(@"BackgroundAudioPlayer: fail");
    }
}

- (void)stop
{
    if (_audioPlayer) {
        [_audioPlayer stop];
    }
}

#pragma mark -

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"BackgroundAudioPlayer: finish");
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    NSLog(@"BackgroundAudioPlayer: %@", error);
}

@end
