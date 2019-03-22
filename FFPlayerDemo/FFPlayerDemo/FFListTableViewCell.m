//
//  FFListTableViewCell.m
//  FFPlayerDemo
//
//  Created by 曹诚飞 on 2019/3/22.
//  Copyright © 2019 曹诚飞. All rights reserved.
//

#import "FFListTableViewCell.h"

@implementation FFListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.frame = CGRectMake(10, 10, 40, 40);
        self.iconView.layer.cornerRadius = self.iconView.bounds.size.width / 2;
        self.iconView.backgroundColor = [UIColor colorWithRed:0.29 green:0.95 blue:0.63 alpha:1.00];
        [self.contentView addSubview:self.iconView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, 100, 20)];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.textColor = UIColor.blackColor;
        [self.contentView addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(width - 100, 22.5, 90, 15)];
        self.timeLabel.font = [UIFont systemFontOfSize:14];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.textColor = UIColor.blackColor;
        [self.contentView addSubview:self.timeLabel];
        
        self.videoView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.iconView.frame) + 10, width - 20, (width - 20) * 0.57 - 3)];
        self.videoView.backgroundColor = UIColor.orangeColor;
        self.videoView.backgroundColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.00];
        [self.contentView addSubview:self.videoView];
    }
    return self;
}

- (void)setData:(NSDictionary *)data {
    _data = data;
    self.titleLabel.text = data[@"title"];
    self.timeLabel.text = data[@"time"];
    
    [self layoutIfNeeded];
    self.videoFrame = self.videoView.bounds;
}

@end
