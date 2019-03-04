//
//  FFNomalViewController.m
//  FFPlayerDemo
//
//  Created by 曹诚飞 on 2019/3/1.
//  Copyright © 2019 曹诚飞. All rights reserved.
//

#import "FFNomalViewController.h"
#import "FFPlayer/FFVideoPlayer.h"
#import <FLEX.h>


@interface FFNomalViewController ()

@end

@implementation FFNomalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:@"https://douyin2018.oss-cn-shenzhen.aliyuncs.com/d9f94541f5c85847e51416754589e11e.mp4"];
    CGFloat width = self.view.bounds.size.width;
    CGFloat minWidth = MIN(width, self.view.bounds.size.height);
    FFVideoPlayer *player = [[FFVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, width, width * 0.6)];
    player.portraitReact = CGRectMake(0, 0, minWidth, minWidth * 0.6);
    player.videoURL = url;
    player.parentVC = self;
    [self.view addSubview:player];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc {
    NSLog(@"释放了");
}

#if DEBUG
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionBegan:motion withEvent:event];
    
    if (motion == UIEventSubtypeMotionShake) {
        [[FLEXManager sharedManager] showExplorer];
    }
}
#endif



@end
