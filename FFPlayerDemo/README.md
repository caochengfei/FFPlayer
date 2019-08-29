# FFPlayer
A video player based on AVFoundation

1.open the info.plist add View controller-based status bar appearance = NO

```objc
    NSURL *url = [NSURL URLWithString:@"https://douyin2018.oss-cn-shenzhen.aliyuncs.com/d9f94541f5c85847e51416754589e11e.mp4"];
    CGFloat width = self.view.bounds.size.width;
    CGFloat minWidth = MIN(width, self.view.bounds.size.height);
    FFVideoPlayer *player = [[FFVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, width, width * 0.6)];
    player.portraitReact = CGRectMake(0, 0, minWidth, minWidth * 0.6);
    player.videoURL = url;
    player.parentVC = self;
    [self.view addSubview:player];
```
