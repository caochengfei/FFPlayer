//
//  FFPlayerCommandView.m
//  MKPlayer
//
//  Created by 曹诚飞 on 2019/2/26.
//  Copyright © 2019 曹诚飞. All rights reserved.
//

#import "FFPlayerCommandView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FFBrightnessView.h"

@interface FFPlayerCommandView ()<UIGestureRecognizerDelegate>
@end

@implementation FFPlayerCommandView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initStep];
    }
    return self;
}

- (void)initStep {
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self addSubview:self.replayBtn];
    [self addSubview:self.forwardOrBackward];
    [self addSubview:self.activityView];
    
    [_bottomView addSubview:self.playBtn];
    [_bottomView addSubview:self.progress];
    [_bottomView addSubview:self.slider];
    [_bottomView addSubview:self.currentTimeLabel];
    [_bottomView addSubview:self.screenBtn];
    [_topView    addSubview:self.backBtn];
    
    [self addGestureRecognizer:self.tapGesture];
    [self addGestureRecognizer:self.doubleTapGesture];
    [self addGestureRecognizer:self.panGesture];
}

- (void)dealloc {
    [_currentTimeLabel removeObserver:self forKeyPath:@"text"];
}

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            [self setPortraitLayout];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [self setLandscapeLayout];
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            [self setLandscapeLayout];
            break;
        default:
            [self setPortraitLayout];
            break;
    }
}

- (void)changeCurrentTimeLabelLayout {
    
    [_currentTimeLabel sizeToFit];
    CGFloat labelWidth = _currentTimeLabel.bounds.size.width;
    _currentTimeLabel.frame = CGRectMake(self.screenBtn.frame.origin.x - labelWidth, 10, labelWidth, 20);
    
    CGFloat sliderW = self.frame.size.width - CGRectGetMaxX(_playBtn.frame) - self.currentTimeLabel.frame.size.width - self.screenBtn.frame.size.width - 10 - 15;
    _progress.frame = CGRectMake(CGRectGetMaxX(_playBtn.frame) + 5, 19, sliderW, 10);
    _slider.frame = CGRectMake(_progress.frame.origin.x - 2, 0, _progress.bounds.size.width + 4 ,_bottomView.frame.size.height - 10);
}


- (void)setPortraitLayout {
    _topView.frame = CGRectMake(0, 0, self.frame.size.width, 50);
    _backBtn.frame = CGRectMake(5, 0, 50, 50);

    CGFloat bottomH = 50;
    _bottomView.frame = CGRectMake(0, self.frame.size.height - bottomH, self.frame.size.width, bottomH);
    _playBtn.frame = CGRectMake(5, 0, 40, 40);
    
    _screenBtn.frame = CGRectMake(self.frame.size.width - 45, 0, 40, 40);
    // 计算slider的长度
    [self changeCurrentTimeLabelLayout];
    
    _replayBtn.frame = CGRectMake(0, 0, 40, 40);
    _replayBtn.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _forwardOrBackward.frame = CGRectMake(0, 0, 160, 40);
    _forwardOrBackward.center = _replayBtn.center;
    
    _activityView.center = _replayBtn.center;
    
    [FFBrightnessView sharedBrightnessView].center = [UIApplication sharedApplication].keyWindow.center;
}

- (void)setLandscapeLayout {
    _topView.frame = CGRectMake(0, 0, self.frame.size.width, 40);
    _backBtn.frame = CGRectMake(5, 0, 40, 40);
    
    CGFloat bottomH = 50;
    _bottomView.frame = CGRectMake(0, self.frame.size.height - bottomH, self.frame.size.width, bottomH);
    _playBtn.frame = CGRectMake(10, 0, 40, 40);
    
    _screenBtn.frame = CGRectMake(self.frame.size.width - 50, 0, 40, 40);

    // 计算slider的长度
    [self changeCurrentTimeLabelLayout];
    
    _replayBtn.frame = CGRectMake(0, 0, 40, 40);
    _replayBtn.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _forwardOrBackward.frame = CGRectMake(0, 0, 160, 40);
    _forwardOrBackward.center = _replayBtn.center;
    
    _activityView.center = _replayBtn.center;
    
    [FFBrightnessView sharedBrightnessView].center = [UIApplication sharedApplication].keyWindow.center;
}

#pragma mark - action
- (void)playBtnAction:(UIButton *)button {
    if (self.playActionBlock) {
        BOOL status = button.selected;
        self.playActionBlock(!status);
    }
}

- (void)progressSlider:(UISlider *)slider {
    if (self.sliderIsSlipping) {
        self.sliderIsSlipping(slider.value);
    }
}

- (void)sliderDidChanged:(UISlider *)slider {
    if (self.sliderDidChanged) {
        self.sliderDidChanged(slider.value);
    }
}

- (void)screenBtnAction:(UIButton *)button {
    if (self.fullActionBlock) {
        self.fullActionBlock(button);
    }
}

- (void)replayBtnAction:(UIButton *)button {
    if (self.replayActionBlock) {
        self.replayActionBlock();
    }
}

- (void)backBtnAcction:(UIButton *)button {
    if (self.backActionBlock) {
        self.backActionBlock();
    }
}

- (void)tapAction:(UITapGestureRecognizer *)gesture {
    if (gesture.numberOfTapsRequired == 1) {
        if (self.gestureActionBlock) {
            self.gestureActionBlock(1);
        }
    }
    
    if (gesture.numberOfTapsRequired == 2) {
        if (self.gestureActionBlock) {
            self.gestureActionBlock(2);
        }
    }
}

- (void)panAction:(UIPanGestureRecognizer *)gesture {
    if (self.panActionBlock) {
        self.panActionBlock(gesture);
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    if (point.y > self.bottomView.frame.origin.y) {
        return  NO;
    }
    return YES;
}


#pragma mark - 监听时间文本的变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self changeCurrentTimeLabelLayout];
}

#pragma mark - setter
- (void)setIsPlayEnd:(BOOL)isPlayEnd {
    
}

#pragma mark - lazy getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _bottomView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"play_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"play_pause"] forState:UIControlStateSelected];
        [_playBtn setImage:[UIImage imageNamed:@"play_pause"] forState:UIControlStateSelected | UIControlStateHighlighted];
        _playBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);

        _playBtn.adjustsImageWhenHighlighted = NO;
        [_playBtn addTarget:self action:@selector(playBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIProgressView *)progress {
    if (!_progress) {
        _progress = [[UIProgressView alloc] init];
        _progress.progressTintColor = UIColor.grayColor;
    }
    return _progress;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        [_slider setThumbImage:[UIImage imageNamed:@"play_slider"] forState:UIControlStateNormal];
        _slider.minimumTrackTintColor = [UIColor colorWithRed:0.51 green:0.88 blue:0.72 alpha:1.00];
        _slider.minimumValue = 0.f;
        _slider.maximumValue = 1.f;
        _slider.value = 0.f;
        [_slider addTarget:self action:@selector(progressSlider:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderDidChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(sliderDidChanged:) forControlEvents:UIControlEventTouchUpOutside];
        [_slider addTarget:self action:@selector(sliderDidChanged:) forControlEvents:UIControlEventTouchCancel];
        _slider.exclusiveTouch = YES;
    }
    return _slider;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = UIColor.whiteColor;
        _currentTimeLabel.font = [UIFont systemFontOfSize:12];
        _currentTimeLabel.text = @"00:00 / 00:00";
        [_currentTimeLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _currentTimeLabel;
}

- (UIButton *)screenBtn {
    if (!_screenBtn) {
        _screenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_screenBtn addTarget:self action:@selector(screenBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_screenBtn setImage:[UIImage imageNamed:@"play_full_screen"] forState:UIControlStateNormal];
        [_screenBtn setImage:[UIImage imageNamed:@"play_full_screen"] forState:UIControlStateSelected];
        _screenBtn.adjustsImageWhenHighlighted = NO;
        _screenBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return _screenBtn;
}

- (UIButton *)replayBtn {
    if (!_replayBtn) {
        _replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_replayBtn setImage:[UIImage imageNamed:@"play_replay"] forState:UIControlStateNormal];
        [_replayBtn addTarget:self action:@selector(replayBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _replayBtn.adjustsImageWhenHighlighted = NO;
        _replayBtn.hidden = YES;
    }
    return _replayBtn;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"play_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnAcction:) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.adjustsImageWhenHighlighted = NO;
        _backBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return _backBtn;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        _tapGesture.numberOfTapsRequired = 1;
        _tapGesture.numberOfTouchesRequired = 1;
        [_tapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_panGesture setMaximumNumberOfTouches:1];
        [_panGesture setMinimumNumberOfTouches:1];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)doubleTapGesture {
    if (!_doubleTapGesture) {
        _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_doubleTapGesture setNumberOfTapsRequired:2];
    }
    return _doubleTapGesture;
}

- (UISlider *)volumnSlider {
    if (!_volumnSlider) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in volumeView.subviews) {
            if ([[view.class description] isEqualToString:@"MPVolumeSlider"]) {
                _volumnSlider = (UISlider *)view;
                break;
            }
        }
    }
    return _volumnSlider;
}

- (UILabel *)forwardOrBackward {
    if (!_forwardOrBackward) {
        _forwardOrBackward = [[UILabel alloc] init];
        _forwardOrBackward.textColor = UIColor.whiteColor;
        _forwardOrBackward.textAlignment = NSTextAlignmentCenter;
        _forwardOrBackward.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _forwardOrBackward.hidden = YES;
    }
    return _forwardOrBackward;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
    }
    return _activityView;
}



@end
