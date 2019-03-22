//
//  FFVideoPlayer.m
//  MKPlayer
//
//  Created by 曹诚飞 on 2019/2/26.
//  Copyright © 2019 曹诚飞. All rights reserved.
//

#import "FFVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "FFPlayerMacro.h"
#import "FFBrightnessView.h"

typedef NS_ENUM(NSUInteger, FFPlayerStatus) {
    FFPlayerStatusBuffering = 0,
    FFPlayerStatusPlaying = 1,
    FFPlayerStatusStopped = 2,
    FFPlayerStatusPause = 3,
};

@interface FFVideoPlayer ()
@property (nonatomic ,strong) AVPlayer          *player;
@property (nonatomic ,strong) AVPlayerItem      *playerItem;
@property (nonatomic ,strong) AVPlayerLayer     *playerLayer;
@property (nonatomic ,strong) NSTimer           *autoTimer;
@property (nonatomic ,assign) FFPlayerStatus    playerStatus;
@property (nonatomic ,assign) BOOL              isInteraction; // 是否正在交互
@property (nonatomic ,strong) id                playerTimeObserver;
@property (nonatomic ,assign) CGFloat           sumTime;
@property (nonatomic ,assign) BOOL              isHorizontalMove; //标记pan手势是水平还是垂直
@property (nonatomic ,assign) CGFloat           totalDuration; // 视频总时长
@property (nonatomic ,assign) CGFloat           sliderLastValue; //slider上次的值
@property (nonatomic ,assign) BOOL              isPlayEnd; // 是否播放完毕
@property (nonatomic ,assign) BOOL              isPauseByUser; // 是否用户暂停
@end

@implementation FFVideoPlayer

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initStep];
    }
    return self;
}

- (void)initStep {
    [self addSubview:self.commandView];
    self.sumTime = 0;
    if (self.portraitReact.size.width == 0) {
        self.portraitReact = self.frame;
    }
    /**----------------------------*/
    [self registerCommandViewCallback];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeTimer];
    [self removeKeyValueObserver];
}

#pragma mark - timer
- (void)addTimer {
    @weakify(self);
    self.playerTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self);
        CGFloat currentDuration = CMTimeGetSeconds(time);
        self.commandView.currentTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",[self timeFormate:currentDuration],[self timeFormate:self.totalDuration]];
        [self.commandView.slider setValue:currentDuration / self.totalDuration animated:NO];
    }];
    
    self.autoTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(handleAutoTimer) userInfo:nil repeats:YES];
}

- (void)removeTimer {
    @try {
        if (self.autoTimer) {
            [self.autoTimer invalidate];
            self.autoTimer = nil;
        }
        if (self.playerTimeObserver) {
            [self.player removeTimeObserver:self.playerTimeObserver];
            self.playerTimeObserver = nil;
        }
    } @catch (NSException *exception) {
        NSLog(@"removeTimer error:%@",exception.description);
    } @finally {}
}

/** 自动隐藏交互视图 */
- (void)handleAutoTimer {
    if (self.isInteraction) { return; }
    [self hideCommandView];
}

/** 返回格式化时间的便捷方法 */
- (NSString *)timeFormate:(CGFloat)timeValue {
    NSString *timeStr = @"";
    NSInteger t = (NSInteger)timeValue;
    if (t < 3600) {
        timeStr = [NSString stringWithFormat:@"%02ld:%02ld",t / 60,t % 60];
    } else {
        timeStr = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",t / 3600, t / 3600 / 60, (t / 3600 / 60) % 60];
    }
    return timeStr;
}


#pragma mark - Actions 功能
/** 注册命令视图的事件 */
- (void)registerCommandViewCallback {
    @weakify(self);
    self.commandView.playActionBlock = ^(int status) {
        @strongify(self);
        if (status == 1) {
            self.isPauseByUser = NO;
            [self startToPlayer];
        } else {
            self.isPauseByUser = YES;
            [self pauseToPlayer];
        }
    };
    
    self.commandView.sliderIsSlipping = ^(int status) {
        @strongify(self);
        [self sliderIsSlipping];
    };
    
    self.commandView.sliderDidChanged = ^(int value) {
        @strongify(self);
        [self sliderDidChanged];
    };
    
    self.commandView.fullActionBlock = ^(UIButton * _Nonnull screenButton) {
        @strongify(self);
        [self fullScreen:screenButton];
    };
    
    self.commandView.replayActionBlock = ^{
        @strongify(self);
        [self replayBack];
    };
    
    self.commandView.backActionBlock = ^{
        @strongify(self);
        [self backAction];
    };
    
    self.commandView.gestureActionBlock = ^(int status) {
        @strongify(self);
        status == 1 ? [self gestureActionSignel] : [self gestureActionDouble];
    };
    
    self.commandView.panActionBlock = ^(UIPanGestureRecognizer *gesture) {
        @strongify(self);
        [self playerViewDidPan:gesture];
    };
}

/** 开始播放 */
- (void)startToPlayer {
    [self addTimer];
    if ([self.videoURL.scheme isEqualToString:@"file"]) {
        self.playerStatus = FFPlayerStatusPlaying;
    } else {
        self.playerStatus = FFPlayerStatusBuffering;
    }
    self.commandView.playBtn.selected = YES;
    [self.player play];
}

/** 暂停播放 */
- (void)pauseToPlayer {
    [self removeTimer];
    self.commandView.playBtn.selected = NO;
    [self.commandView.activityView stopAnimating];
    self.playerStatus = FFPlayerStatusPause;
    [self.player pause];
}

/** 准备开始播放  */
- (void)preparePlay {
    self.totalDuration = self.playerItem.duration.value / self.playerItem.duration.timescale;
    _commandView.currentTimeLabel.text = [NSString stringWithFormat:@"00:00 / %@",[self timeFormate:_totalDuration]];
    if (!self.isPauseByUser) {
        [self startToPlayer];
    }
}

/** 重新播放 */
- (void)replayBack {
    self.commandView.progress.progress = 0.0f;
    self.commandView.slider.value = 0.0f;
    self.commandView.replayBtn.hidden = YES;
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        // 重置到0的进度开始播放
        self.isPlayEnd = NO;
        [self sliderDidChanged];
        [self startToPlayer];
        [self showCommandView];
    } else {
        [self setVideoURL:_videoURL];
    }
}

- (void)resetPlayer {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeKeyValueObserver];
    [self pauseToPlayer];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.commandView.progress.progress = 0;
    self.commandView.slider.value = 0;
    self.commandView.replayBtn.hidden = YES;
    [self.commandView removeFromSuperview];
}

- (void)destroyPlayer {
    [self resetPlayer];
    [self removeFromSuperview];
}

/** 单击屏幕 */
- (void)gestureActionSignel {
    self.commandView.topView.alpha == 0 ? [self showCommandView] : [self hideCommandView];
}

/** 双击屏幕 */
- (void)gestureActionDouble {
    if (self.isPlayEnd) return;
    if (self.commandView.playBtn.selected == NO) {
        self.isPauseByUser = NO;
        [self startToPlayer];
        [self hideCommandView];
    } else {
        self.isPauseByUser = YES;
        [self pauseToPlayer];
        [self showCommandView];
    }
}

/** 显示命令视图 */
- (void)showCommandView {
    [UIView animateWithDuration:0.3 animations:^{
        self.commandView.topView.alpha = 1;
        if (self.isPlayEnd == NO) {
            self.commandView.bottomView.alpha = 1;
        }
    } completion:^(BOOL finished) {
    }];
    
}

/** 隐藏命令视图 */
- (void)hideCommandView {
    [UIView animateWithDuration:0.3 animations:^{
        self.commandView.topView.alpha = 0;
        self.commandView.bottomView.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

/** 返回按钮点击 */
- (void)backAction {
    if (self.commandView.screenBtn.selected) {
        [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
    } else {
        // 返回
        
        [self resetPlayer];
        
        if (self.parentVC.navigationController != nil) {
            [self.parentVC.navigationController popViewControllerAnimated:YES];
            self.parentVC = nil;
        } else {
            [self.parentVC dismissViewControllerAnimated:YES completion:nil];
            self.parentVC = nil;
        }
    }
}

#pragma mark - 播放slider处理
/** slider 拖动 */
- (void)sliderIsSlipping {
    self.isInteraction = YES;
    [self removeTimer];
    if (_playerItem.duration.timescale != 0) {
        CGFloat sliderDuration = _totalDuration * self.commandView.slider.value;
        
        NSString *currentText = [self timeFormate:sliderDuration];
        NSString *totalText = [self timeFormate:self.totalDuration];
        self.commandView.currentTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",currentText,totalText];
        
        CGFloat value = self.commandView.slider.value - self.sliderLastValue;
        NSString *style = value > 0 ? @">>" : @"<<";
        self.sliderLastValue = self.commandView.slider.value;
        
        self.commandView.forwardOrBackward.hidden = NO;
        self.commandView.forwardOrBackward.text   = [NSString stringWithFormat:@"%@ %@ / %@",style, currentText, totalText];
    }
}

/** slider 点击 离开 取消 */
- (void)sliderDidChanged {
    BOOL isPlaying = NO;
    if (self.player.rate > 0) {
        isPlaying = YES;
        [self.player pause];
    }
    self.commandView.forwardOrBackward.hidden = YES;
    self.isInteraction = NO;
    // 先不更新进度
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        NSInteger dragedSeconds = floorf(_totalDuration * self.commandView.slider.value);
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        [self pauseToPlayer];
        [self.player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (isPlaying) {
                [self startToPlayer];
            }
            if (self.playerItem.isPlaybackLikelyToKeepUp) {
                self.playerStatus = FFPlayerStatusBuffering;
                [self.commandView.activityView startAnimating];
            }
        }];
    }
}

/** 滑动手势处理 */
- (void)playerViewDidPan:(UIPanGestureRecognizer *)pan {
    // 竖屏不响应
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) { return;}
    if (self.isPlayEnd) { return;}
    // 触点
    CGPoint localPoint = [pan locationInView:self];
    // 在指定视图的坐标系中，以点/秒为单位的平移速度（速率点）
    CGPoint velocityPoint = [pan velocityInView:self];
    // 指定视图的坐标系中的平移
//    CGPoint transitionPoint = [pan translationInView:self];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            // 使用绝对值得出pan是水平还是垂直方向
            CGFloat x = fabs(velocityPoint.x);
            CGFloat y = fabs(velocityPoint.y);
            
            if (x > y) {
                // 水平方向
                // 不是停止状态才可以快进快退
                if (self.playerStatus != FFPlayerStatusStopped) {
                    // 当前播放器的位置（秒）
                    CMTime time = self.player.currentTime;
                    self.sumTime = time.value / time.timescale;
                }
                self.isHorizontalMove = YES;
                self.commandView.forwardOrBackward.hidden = NO;
            } else {
                self.isHorizontalMove = NO;
            }
            
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (self.isHorizontalMove) {
                // slider每次叠加的时间
                self.sumTime += velocityPoint.x / 200;
                // 视图占位
                if (self.sumTime > self.totalDuration) {
                    self.sumTime = self.totalDuration;
                } else if (self.sumTime < 0) {
                    self.sumTime = 0;
                }
                self.commandView.slider.value = self.sumTime / self.totalDuration;
                
                // 更新slider和快进快退的文本显示
                [self sliderIsSlipping];
                
                /**
                 因为 sliderIsSlipping中已经做了更新操作 所里这里不用再写了
                 NSString *style = transitionPoint.x < 0 ? @"<<" : @">>";
                 self.commandView.forwardOrBackward.text = [NSString stringWithFormat:@"%@ %@ / %@",style,[self timeFormate:self.sumTime],[self timeFormate:self.totalDuration]];
                 */
                
            } else {
                // 垂直方向pan
                if (localPoint.x < [UIScreen mainScreen].bounds.size.height * 0.5) {
                    [UIScreen mainScreen].brightness -= velocityPoint.y / 10000;
                } else {
                    self.commandView.volumnSlider.value -= velocityPoint.y / 10000;
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            if (self.isHorizontalMove) {
                self.sumTime = 0;
                [self sliderDidChanged];
            }
            // 隐藏快进快退视图
            self.commandView.forwardOrBackward.hidden = YES;
        }
            break;
        default:
            break;
    }
}

#pragma mark - The observer - KVO
- (void)addKeyValueObserver {
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲区空了，等待缓冲
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲足够播放
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeKeyValueObserver {
    @try {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    } @catch (NSException *exception) {
        NSLog(@"removeKVO error:%@",exception.description);
    } @finally {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            // 准备播放
            [self preparePlay];
        } else {
            // 初始化播放器失败
            self.playerStatus = FFPlayerStatusStopped;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        // 缓冲进度
        NSTimeInterval timeInterval = [self availabelDuration];
        CGFloat totalDuration = CMTimeGetSeconds(self.playerItem.duration);
        [_commandView.progress setProgress:timeInterval / totalDuration];
        if (playerItem.isPlaybackLikelyToKeepUp) {
            [self.commandView.activityView stopAnimating];
        }
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"] && playerItem.isPlaybackBufferEmpty) {
        // 等待缓冲,暂停播放
        self.playerStatus = FFPlayerStatusBuffering;
        [self.commandView.activityView startAnimating];
        [self.player pause];
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        // 缓冲够了
        [self.commandView.activityView stopAnimating];
        if (!self.isPauseByUser) {
            [self.player play];
            self.commandView.playBtn.selected = YES;
        }
    }
}

/** 计算缓冲进度 */
- (NSTimeInterval)availabelDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    // 获取缓冲区域
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    // 计算缓冲总进度
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

#pragma mark - The observer - NSNotificationCenter
- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlaybackStalled) name:AVPlayerItemPlaybackStalledNotification object:_playerItem];
}

#pragma mark - The Observer - NotificationAction
/** 进入后台通知 */
- (void)appDidEnterBackground {
    self.playerStatus = FFPlayerStatusPause;
    [self pauseToPlayer];
}

/** 返回前台通知 */
- (void)appDidEnterPlayGround {
    if (self.playerStatus == FFPlayerStatusPause) {
        self.playerStatus = FFPlayerStatusPlaying;
        [self startToPlayer];
    }
}

/** 播放完毕通知 */
- (void)playerItemDidPlayEnd {
    self.playerStatus = FFPlayerStatusStopped;
    self.isPlayEnd = YES;
    _commandView.replayBtn.hidden = NO;
    [self removeTimer];
    
    // 播放完毕看情况是否需要释放当前播放器
    self.commandView.bottomView.alpha = 0;
    self.commandView.replayBtn.hidden = NO;
    [self.commandView.activityView stopAnimating];
}

/** 播放异常中断通知 */
- (void)playerItemPlaybackStalled {
    [self pauseToPlayer];
}


#pragma mark - 通知屏幕旋转处理
/** 手动点击全屏按钮 */
- (void)fullScreen:(UIButton *)btn {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        [self setInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    } else {
        [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
    }
}

/** 屏幕旋转通知 */
- (void)onDeviceOrientationChange {
    UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            [self autoRotateToProtrait];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [self autoRotateToLandscapeLeft:YES];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [self autoRotateToLandscapeLeft:NO];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        default:
            break;
    }
}

/** 自动横屏 isLeft左横屏 NO 右横屏 */
- (void)autoRotateToLandscapeLeft:(BOOL)isLeft {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [UIView animateWithDuration:0.0 animations:^{
        //用于不允许横屏的假横屏
        // self.transform = CGAffineTransformMakeRotation(isLeft ? M_PI_2 : - M_PI_2);
        self.frame = keyWindow.bounds;
        self.playerLayer.frame = self.bounds;
        self.commandView.frame = self.bounds;
        [self.commandView layoutSubviews];
    } completion:^(BOOL finished) {
        self.commandView.screenBtn.selected = YES;
        [UIApplication sharedApplication].statusBarHidden = YES;
//        [self.commandView layoutIfNeeded];
    }];

}

/** 自动竖屏 */
- (void)autoRotateToProtrait {
    [UIView animateWithDuration:0.0 animations:^{
        // 用于不允许横屏的假横屏
        // self.transform = CGAffineTransformIdentity;
        self.frame = self.portraitReact;
        self.playerLayer.frame = self.bounds;
        self.commandView.frame = self.bounds;
        [self.commandView layoutSubviews];
    } completion:^(BOOL finished) {
        self.commandView.screenBtn.selected = NO;
        [UIApplication sharedApplication].statusBarHidden = NO;
//        [self.commandView layoutIfNeeded];
    }];
}

/** 强制屏幕旋转 */
- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        // 从2开始因为selector 占用了0 target 占用了1
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];
    }
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
        [self setOrientationLandscape];
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
        [self setOrientationPortrait];
    }
}

- (void)setOrientationLandscape {

}

- (void)setOrientationPortrait {
    
}


#pragma mark - setter
/** 设置视频URL */
- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    NSParameterAssert(videoURL);
    self.totalDuration = 0;
    self.playerStatus = FFPlayerStatusStopped;
    self.isPlayEnd = NO;
    
    // 根据屏幕的方向设置相关UI
    [self setNeedsLayout];
    [self onDeviceOrientationChange];
    [self layoutIfNeeded];
    
    // 初始化playerItem
    self.playerItem = [[AVPlayerItem alloc] initWithURL:_videoURL];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    // 通知
    [self addNotificationObserver];
    
    
    // 初始化playerLayer
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
    // 添加到playerlayer到self.layer
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    [self showCommandView];
}

/** 设置播放状态 */
- (void)setPlayerStatus:(FFPlayerStatus)playerStatus {
    _playerStatus = playerStatus;
    if (playerStatus != FFPlayerStatusBuffering) {
        [self.commandView.activityView stopAnimating];
    }
}

/** 设置playerItem */
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) return;
    if (_playerItem) {
        [self removeKeyValueObserver];
    }
    _playerItem = playerItem;
    if (_playerItem) {
        [self addKeyValueObserver];
    }
}

/** 设置视频填充模式 */
- (void)setPlayerLayerGravity:(FFPlayerLayerGravity)playerLayerGravity {
    _playerLayerGravity = playerLayerGravity;
    switch (playerLayerGravity) {
        case FFPlayerLayerGravityResize:
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            break;
        case FFPlayerLayerGravityResizeAspect:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case FFPlayerLayerGravityResizeAspectFill:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
    }
}

#pragma mark - lazy-getter
- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = self.bounds;
        _playerLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _playerLayer;
}

- (FFPlayerCommandView *)commandView {
    if (!_commandView) {
        _commandView = [[FFPlayerCommandView alloc] initWithFrame:self.bounds];
        _commandView.backgroundColor = UIColor.clearColor;
    }
    return _commandView;
}


@end
