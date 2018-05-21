//
//  ViewController.m
//  KeepAlive
//
//  Created by 朱东方 on 2018/5/17.
//  Copyright © 2018年 cmcm. All rights reserved.
//

#import "ViewController.h"
#import "Toast.h"
#import "AppDelegate.h"
#import "INTULocationManager.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, copy) NSArray *types;
@property (nonatomic, copy) NSArray *titles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSStringFromClass(ViewController.class);
    
    _types = @[ @(KeepAliveMethod_UIApplication_BackgroundTask),
                @(KeepAliveMethod_NSURLSession_DownloadTask),
                
                @(KeepAliveMethod_Audio),
                @(KeepAliveMethod_Location),
                @(KeepAliveMethod_BackgroundFetch),
                @(KeepAliveMethod_RemoteNotification), ];
    
    _titles = @[ @"UIApplication#beginBackgroundTask",
                 @"NSURLSession Download Task",
                 
                 @"Audio",
                 @"Location",
                 @"Background Fetch",
                 @"Remote Notification",
                 ];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.imageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateImage)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __block NSInteger thread_count = 0;
        while (YES) {
            NSLog(@"thread count: %ld", thread_count++);
            sleep(1);
        }
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateImage];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row < _titles.count) {
        cell.textLabel.text = _titles[indexPath.row];
    }
    else if (indexPath.row == _titles.count) {
        NSString *launchTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_launch_time"];
        cell.textLabel.text = [NSString stringWithFormat:@"启动:%@", launchTime];
    }
    else if (indexPath.row == _titles.count + 1) {
        NSString *launchTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_bg_fetch_time"];
        cell.textLabel.text = [NSString stringWithFormat:@"Fetch:%@", launchTime];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Toast show:_titles[indexPath.row]];
    KeepAliveMethod method = [_types[indexPath.row] integerValue];
    switch (method) {
        case KeepAliveMethod_Location:
            [self requestLocation];
            break;
        default:
            [self updateImage];
            break;
    }
}

- (void)updateImage
{
    NSString *fp = [[NSUserDefaults standardUserDefaults] objectForKey:@"download_fp"];
    if (!fp) return;
    
    self.imageView.image = [UIImage imageWithContentsOfFile:fp];
}

- (void)requestLocation
{
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    __block NSInteger count = 0;
    [locMgr subscribeToLocationUpdatesWithDesiredAccuracy:INTULocationAccuracyHouse
                                                    block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                        NSLog(@"位置更新: %ld", count++);
                                                        if (status == INTULocationStatusSuccess) {
                                                            // A new updated location is available in currentLocation, and achievedAccuracy indicates how accurate this particular location is.
                                                        } else {
                                                            // An error occurred, more info is available by looking at the specific status returned. The subscription has been kept alive.
                                                        }
                                                    }];
}

#pragma mark -

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.rowHeight = 44.0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.frame = CGRectMake((CGRectGetWidth(UIScreen.mainScreen.bounds) - 200) / 2.0,
                                      (CGRectGetHeight(UIScreen.mainScreen.bounds) - 200),
                                      200, 200);
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _imageView;
}

@end
