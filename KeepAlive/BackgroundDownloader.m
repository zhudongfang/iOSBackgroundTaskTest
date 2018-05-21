//
//  BackgroundDownloadTask.m
//  KeepAlive
//
//  Created by 朱东方 on 2018/5/23.
//  Copyright © 2018年 cmcm. All rights reserved.
//

#import "BackgroundDownloader.h"
#import "Utils.h"

@interface BackgroundDownloader()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) void(^completionHandler)(void);

@end

@implementation BackgroundDownloader

+ (instancetype)sharedInstance
{
    static BackgroundDownloader *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [BackgroundDownloader new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createSessionWithIdentifier:@"Test"];
    }
    return self;
}

- (void)createSessionWithIdentifier:(NSString *)identifier
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"Test"];
    config.sessionSendsLaunchEvents = YES;
    _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
}

- (void)runOnComletion:(void (^)(void))completionHandler
{
    NSLog(@"BackgroundDownloader 开始下载");
    self.completionHandler = completionHandler;
    
    [self download:@"http://7xor4j.com1.z0.glb.clouddn.com/officialweb_h5_video01.mp4"];
}

- (void)download:(NSString *)resUrl
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:resUrl]];
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request];
    [downloadTask resume];
}

#pragma -mark NSURLSessionDownloadDelegate

/**
 写数据
 @param session 会话对象
 @param downloadTask 下载任务
 @param bytesWritten 本次写入的数据大小
 @param totalBytesWritten 下载的数据总大小
 @param totalBytesExpectedToWrite 文件总大小
 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // 文件的下载进度
    NSLog(@"%f",1.0 * totalBytesWritten / totalBytesExpectedToWrite);
}

/**
 当恢复下载的时候调用该方法
 
 @param fileOffset 从什么地方下载
 @param expectedTotalBytes 文件总大小
 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
}

/**
 当下载完成的时候调用
 @param location 文件的临时存储路径
 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"%@",location);
    // 1. 拼接cache路径
    NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    // 2. 剪切到指定位置
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
    NSLog(@"%@",fullPath);
    
    if (self.completionHandler) {
        self.completionHandler();
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:fullPath forKey:@"download_fp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [Utils showLocalNotification:@"download success from session delegate"];
}

/**
 请求结束时调用
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"BackgroundDownloader 完成下载: error=%@", error);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    [Utils showLocalNotification:@"download succ from sess delegate 2"];
}


@end
