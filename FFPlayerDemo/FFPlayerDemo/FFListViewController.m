//
//  FFListViewController.m
//  FFPlayerDemo
//
//  Created by 曹诚飞 on 2019/3/1.
//  Copyright © 2019 曹诚飞. All rights reserved.
//

#import "FFListViewController.h"
#import "FFPlayer/FFVideoPlayer.h"
#import "FFListTableViewCell.h"

@interface FFListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) FFVideoPlayer *player;
@property (nonatomic ,assign) NSInteger  playingIndex;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@end

@implementation FFListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpView];
    [self getData];
}

- (void)setUpView {
    [self.view addSubview:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player destroyPlayer];
    self.player = nil;
}

- (void)dealloc {
    NSLog(@"listController释放了");
}

- (void)getData {
    NSDictionary *data = @{@"title":@"this is a title",
                           @"time":@"2019-03-22",
                           @"url":@"https://douyin2018.oss-cn-shenzhen.aliyuncs.com/d9f94541f5c85847e51416754589e11e.mp4"};
    
    self.dataArray = @[].mutableCopy;
    for (int i = 0; i < 20; i++) {
        [self.dataArray addObject:data];
    }
    
    [self.tableView reloadData];
    [self playVideoInVisiableCells];
}

- (void)playVideoInVisiableCells {
    NSArray *visiableCells = [self.tableView visibleCells];
    
    /**
     // 找到所有有视频信息的cell,如果都是同一个cell类型，可以忽略
     __block FFListTableViewCell *firstCell = nil;
     [visiableCells enumerateObjectsUsingBlock:^(id  _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
     if ([cell isKindOfClass:[FFListTableViewCell class]]) {
     firstCell = (FFListTableViewCell *)cell;
     *stop = YES;
     }
     }];
     */
    
    // 播放第一个视频
    FFListTableViewCell *firstCell = visiableCells[0];
    [self initPlayerView:firstCell playClick:self.dataArray[0]];
}

- (void)initPlayerView:(FFListTableViewCell *)cell playClick:(NSDictionary *)data {
    self.playingIndex = [self.tableView indexPathForCell:cell].row;
    
    [self.player destroyPlayer];
    self.player = nil;
    
    self.player = [[FFVideoPlayer alloc] initWithFrame:cell.videoFrame];
    [cell.videoView addSubview:self.player];
    
    NSURL *url = [NSURL URLWithString:data[@"url"]];
    self.player.videoURL = url;
    [self.player startToPlayer];
    
    // 返回按钮事件
    self.player.commandView.backActionBlock = ^{
        NSLog(@"返回按钮被点击");
    };
    // 播放完成回调
    @weakify(self);
    self.player.playEndBlock = ^{
        @strongify(self);
        [self.player destroyPlayer];
        self.player = nil;
    };
}

//
- (void)handleScrollPlaying:(UIScrollView *)scrollView {
    //标记的cell  在tableView中的坐标值
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_playingIndex inSection:0];
    CGRect  recttIntableview = [self.tableView rectForRowAtIndexPath:indexPath];
    //当前cell在屏幕中的坐标值
    CGRect rectInSuperView = [self.tableView convertRect:recttIntableview toView:self.view];
    
    //滑动到了屏幕下方
    if ( rectInSuperView.origin.y > self.view.frame.size.height) {
        // 对已经移出屏幕的 Cell 做相应的处理
    } else if (rectInSuperView.origin.y + rectInSuperView.size.height < 0){
        //当前操作的cell高度  rectInSuperView.size.heigt
        //滑动到了屏幕上方
    } else {
        return;
    }
    NSArray *visiableCells = [self.tableView visibleCells];
    /**
     // 找到所有有视频信息的cell,如果都是同一个cell类型，可以忽略
     __block NSMutableArray *tempVideoCells = @[].mutableCopy;
     [visiableCells enumerateObjectsUsingBlock:^(id  _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
     if ([cell isKindOfClass:[FFListTableViewCell class]]) {
     [tempVideoCells addObject:cell];
     }
     }];
     */
    
    __block FFListTableViewCell *willPlayingCell = nil;
    __block NSMutableArray *indexPaths = @[].mutableCopy;
    __block CGFloat gap = MAXFLOAT;
    [visiableCells enumerateObjectsUsingBlock:^(FFListTableViewCell *  _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[self.tableView indexPathForCell:cell]];
        // 计算距离中心最近的cell
        CGPoint convertCenter = [cell.superview convertPoint:cell.center toView:nil];
        CGFloat delta = fabs(convertCenter.y - [UIScreen mainScreen].bounds.size.height * 0.4);
        
        if (delta < gap) {
            gap = delta;
            willPlayingCell = cell;
        }
    }];
    
    // 判断正在播放的cell和willplayingcell是否同一个
    
    if (willPlayingCell != nil && self.playingIndex != [self.tableView indexPathForCell:willPlayingCell].row) {
        if (self.player) {
            [self.player destroyPlayer];
            self.player = nil;
        }
        [self initPlayerView:willPlayingCell playClick:willPlayingCell.data];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 滑动出屏幕可见范围的播放器销毁
    NSArray *cells = [self.tableView visibleCells];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.playingIndex inSection:0];
    if (![cells containsObject:[self.tableView cellForRowAtIndexPath:indexPath]]) {
        if (self.player) {
            [self.player destroyPlayer];
            self.player = nil;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 滑动结束开始播放
    [self handleScrollPlaying:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // 拖动结束且没有减速过程 开始播放视频
        [self handleScrollPlaying:scrollView];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // todo..
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FFListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FFListTableViewCell class])];
    if (!cell) {
        cell = [[FFListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([FFListTableViewCell class])];
    }
    cell.data = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - lazy
- (UITableView *)tableView {
    if(!_tableView){
        CGRect rect = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
        _tableView = [[UITableView alloc] initWithFrame:rect];
        _tableView.rowHeight = self.view.bounds.size.width * 0.6 + 60;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
