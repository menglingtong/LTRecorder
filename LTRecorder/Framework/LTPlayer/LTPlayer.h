//
//  LTPlayer.h
//  LTRecorder
//
//  Created by xhb_iOS on 2017/11/24.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

// 播放器的状态
typedef NS_ENUM(NSUInteger, LTPlayerStatus) {
    LTPlayerStatusFailed = 0, // 播放失败
    LTPlayerStatusError,      // 播放出错
    LTPlayerStatusReady,      // 播放器准备好了
    LTPlayerStatusBuffering,  // 缓冲中
    LTPlayerStatusPlaying,    // 播放中
    LTPlayerStatusStopped,    // 停止播放
    LTPlayerStatusPause,      // 暂停播放
    LTPlayerStatusUnknown
};
@protocol LTPlayerDelegate;
@interface LTPlayer : AVPlayer

@property (nonatomic, weak) __nullable id<LTPlayerDelegate> delegate;
@property (nonatomic, assign) LTPlayerStatus ltPlayerStatus;

@end

@protocol LTPlayerDelegate <NSObject>

@optional
- (void)player:(LTPlayer *__nonnull)player didPlay:(CMTime)currentTime;
- (void)player:(LTPlayer *__nonnull)player didChangedPlayerItem:(AVPlayerItem *__nullable)playerItem;
- (void)player:(LTPlayer *__nonnull)player didReachedEndForItem:(AVPlayerItem *__nullable)playerItem;
- (void)player:(LTPlayer *__nonnull)player playerItemStatusDidChanged:(LTPlayerStatus)playerItemStatus error:(NSError *__nullable)error;
- (void)player:(LTPlayer *__nonnull)player didUpdateLoadedTimeRanges:(CMTimeRange)timeRange;

@end
