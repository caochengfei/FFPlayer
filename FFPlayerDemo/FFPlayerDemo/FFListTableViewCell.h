//
//  FFListTableViewCell.h
//  FFPlayerDemo
//
//  Created by 曹诚飞 on 2019/3/22.
//  Copyright © 2019 曹诚飞. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FFListTableViewCell : UITableViewCell
@property (nonatomic ,strong) UIImageView *iconView;
@property (nonatomic ,strong) UILabel *titleLabel;
@property (nonatomic ,strong) UILabel *timeLabel;
@property (nonatomic ,strong) UIView *videoView;
/// 用来记录播放器在cell的frame
@property (nonatomic ,assign) CGRect videoFrame;
// data
@property (nonatomic ,strong) NSDictionary *data;
@end

NS_ASSUME_NONNULL_END
