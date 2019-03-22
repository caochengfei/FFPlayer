//
//  FFPlayerCommandView.h
//  MKPlayer
//
//  Created by 曹诚飞 on 2019/2/26.
//  Copyright © 2019 曹诚飞. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PlayActionBlock)(int status);
typedef void(^SliderSlippingBlock)(int value);
typedef void(^SliderDidChangedBlock)(int value);
typedef void(^FullActionBlock)(UIButton *screenButton);
typedef void(^GestureActionBlock)(int status);
typedef void(^PanActionBlock)(UIPanGestureRecognizer *gesture);
typedef void(^ReplayActionBlock)(void);
typedef void(^BackActionBlock)(void);

@interface FFPlayerCommandView : UIView
// CallBack
@property (nonatomic ,copy) PlayActionBlock         playActionBlock;
@property (nonatomic ,copy) SliderSlippingBlock     sliderIsSlipping;
@property (nonatomic ,copy) SliderDidChangedBlock   sliderDidChanged;
@property (nonatomic ,copy) FullActionBlock         fullActionBlock;
@property (nonatomic ,copy) GestureActionBlock      gestureActionBlock;
@property (nonatomic ,copy) PanActionBlock          panActionBlock;
@property (nonatomic ,copy) ReplayActionBlock       replayActionBlock;
@property (nonatomic ,copy) BackActionBlock         backActionBlock;
// View
@property (nonatomic ,strong) UIView                    *topView;           // 上部视图
@property (nonatomic ,strong) UIView                    *bottomView;        // 底部视图
@property (nonatomic ,strong) UIProgressView            *progress;          // 缓冲进度
@property (nonatomic ,strong) UISlider                  *slider;            // 播放进度
@property (nonatomic ,strong) UILabel                   *currentTimeLabel;  // 当前时间
@property (nonatomic ,strong) UIButton                  *playBtn;           // 播放/暂停按钮
@property (nonatomic ,strong) UIButton                  *screenBtn;         // 全屏按钮
@property (nonatomic ,strong) UIButton                  *replayBtn;         // 重播按钮
@property (nonatomic ,strong) UIButton                  *backBtn;           // 返回按钮
@property (nonatomic ,strong) UISlider                  *volumnSlider;      // 音量slider
@property (nonatomic ,strong) UILabel                   *forwardOrBackward; // 快进快退label
@property (nonatomic ,strong) UIActivityIndicatorView   *activityView;      // 缓冲小菊花
// UITapGestureRecognizer
@property (nonatomic ,strong) UITapGestureRecognizer    *tapGesture;        // 单击手势
@property (nonatomic ,strong) UITapGestureRecognizer    *doubleTapGesture;  // 双击手势
@property (nonatomic ,strong) UIPanGestureRecognizer    *panGesture;        // 滑动手势
@end

NS_ASSUME_NONNULL_END
