//
//  ViewController.m
//  FFPlayerDemo
//
//  Created by 曹诚飞 on 2019/2/28.
//  Copyright © 2019 曹诚飞. All rights reserved.
//

#import "ViewController.h"
#import <FLEXManager.h>
#import "FFListViewController.h"
#import "FFNomalViewController.h"
#import "FFVideoPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
//    NSURL *url = [NSURL URLWithString:@"https://douyin2018.oss-cn-shenzhen.aliyuncs.com/d9f94541f5c85847e51416754589e11e.mp4"];
//    CGFloat width = self.view.bounds.size.width;
//    FFVideoPlayer *player = [[FFVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, width, width * 0.6)];
//    player.videoURL = url;
//    player.parentVC = self;
//    [self.view addSubview:player];
    
    
    UIButton *nomalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nomalBtn.backgroundColor = UIColor.grayColor;
    [nomalBtn setTitle:@"普通" forState:UIControlStateNormal];
    [nomalBtn addTarget:self action:@selector(nomalBtnAction) forControlEvents:UIControlEventTouchUpInside];
    nomalBtn.frame = CGRectMake(0, 0, 100, 50);
    nomalBtn.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 50);
    [self.view addSubview:nomalBtn];
    
    UIButton *listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    listBtn.backgroundColor = UIColor.grayColor;
    [listBtn setTitle:@"列表" forState:UIControlStateNormal];
    listBtn.frame = CGRectMake(0, 0, 100, 50);
    listBtn.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 + 50);
    [listBtn addTarget:self action:@selector(listBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:listBtn];
}

- (void)nomalBtnAction {
    FFNomalViewController *nomalVc = [[FFNomalViewController alloc] init];
    [self.navigationController pushViewController:nomalVc animated:YES];
}

- (void)listBtnAction {
    FFListViewController *listVc = [[FFListViewController alloc] init];
    [self.navigationController pushViewController:listVc animated:YES];
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

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
