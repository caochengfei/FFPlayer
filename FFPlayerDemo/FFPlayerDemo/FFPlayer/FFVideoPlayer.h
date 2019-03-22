//
//  FFVideoPlayer.h
//  MKPlayer
//
//  Created by 曹诚飞 on 2019/2/26.
//  Copyright © 2019 曹诚飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFPlayerCommandView.h"
#import "FFPlayerMacro.h"

NS_ASSUME_NONNULL_BEGIN

/**
 player填充模式

 - FFPlayerLayerGravityResize: 非均匀模式。两个维度完全填充至整个视图区域
 - FFPlayerLayerGravityResizeAspect: 等比例填充，直到一个维度到达区域边界
 - FFPlayerLayerGravityResizeAspectFill: 等比例填充，填充满整个视图区域，其中一个维度的部分区域会被裁剪
 */
typedef NS_ENUM(NSUInteger, FFPlayerLayerGravity) {
    FFPlayerLayerGravityResize,
    FFPlayerLayerGravityResizeAspect,
    FFPlayerLayerGravityResizeAspectFill,
};

@interface FFVideoPlayer : UIView
/// 视频链接
@property (nonatomic ,strong, nonnull) NSURL                    *videoURL;
/// 填充模式
@property (nonatomic ,assign) FFPlayerLayerGravity              playerLayerGravity;
/// 界面控制层
@property (nonatomic ,strong, nullable) FFPlayerCommandView     *commandView;
/// 播放器主页面
@property (nonatomic ,strong, nullable) UIViewController        *parentVC;
/// 竖屏坐标
@property (nonatomic ,assign) CGRect                            portraitReact;
/// 播放结束回调
@property (nonatomic ,copy) void(^playEndBlock)(void);
/// 初始化
- (instancetype)initWithFrame:(CGRect)frame;
/// 根据tableview初始化
- (instancetype)initWithTableView:(UITableView *)tableView;
/// 开始播放
- (void)startToPlayer;
/// 暂停播放
- (void)pauseToPlayer;
/// 准备播放
- (void)preparePlay;
/// 重新播放
- (void)replayBack;
/// 重置
- (void)resetPlayer;
/// 销毁，需要外部 player = nil;
- (void)destroyPlayer;
@end

NS_ASSUME_NONNULL_END
