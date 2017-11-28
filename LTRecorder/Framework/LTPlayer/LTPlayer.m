//
//  LTPlayer.m
//  LTRecorder
//
//  Created by xhb_iOS on 2017/11/24.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "LTPlayer.h"
#import <UIKit/UIKit.h>

@interface LTPlayer ()
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) AVPlayerItem *oldItem;
@end

@implementation LTPlayer

static char* StatusChanged          = "StatusContext";
static char* ItemChanged            = "CurrentItemContext";
static char* PlaybackBufferEmpty    = "PlaybackBufferEmpty";
static char* LoadedTimeRanges       = "LoadedTimeRanges";
static char* PlaybackLikelyToKeepUp = "PlaybackLikelyToKeepUp";

- (instancetype)init
{
    if ([super init]) {
        // 1. 监听currentItem
        [self addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:ItemChanged];
        [self addPlayerTimerObserver];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"currentItem"];
    [self removeObserver];
    [self removePlayerTimerObserver];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    // 监听到 currentItem 已改变
    if (context == ItemChanged) {
        // 2. 初始化所有监听事件
        [self initObserver];
    } else if (context == StatusChanged) { // 播放状态改变
        if (self.status == AVPlayerItemStatusUnknown) {
            self.ltPlayerStatus = LTPlayerStatusUnknown;
        } else if (self.status == AVPlayerItemStatusFailed) {
            self.ltPlayerStatus = LTPlayerStatusError;
        } else if (self.status == AVPlayerItemStatusReadyToPlay) {
            self.ltPlayerStatus = LTPlayerStatusReady;
        }
        [self callStatusDelegate:self.ltPlayerStatus];
    } else if (context == PlaybackBufferEmpty) {
        if (self.currentItem.playbackBufferEmpty) {// 缓冲池数据为空 视频暂停 缓冲ing
            self.ltPlayerStatus = LTPlayerStatusBuffering;
            [self callStatusDelegate:self.ltPlayerStatus];
        }
    } else if (context == LoadedTimeRanges) { // 视频缓冲状态改变
        if ([self.delegate respondsToSelector:@selector(player:didUpdateLoadedTimeRanges:)]) {
            NSArray *array = self.currentItem.loadedTimeRanges;
            CMTimeRange range = [array.firstObject CMTimeRangeValue];
            [self.delegate player:self didUpdateLoadedTimeRanges:range];
        }
    } else if (context == PlaybackLikelyToKeepUp) {
        if (self.currentItem.playbackLikelyToKeepUp && self.ltPlayerStatus == LTPlayerStatusBuffering) {
            self.ltPlayerStatus = LTPlayerStatusReady;
            [self callStatusDelegate:self.ltPlayerStatus];
        }
    }
}

- (void)callStatusDelegate:(LTPlayerStatus)status
{
    if ([self.delegate respondsToSelector:@selector(player:playerItemStatusDidChanged:error:)]) {
        [self.delegate player:self playerItemStatusDidChanged:status error:self.currentItem.error];
    }
}

- (void)addPlayerTimerObserver
{
    if (!self.isSendingPlayerInfo) {
        __weak typeof(self)playerSelf = self;
        _timeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            if ([playerSelf.delegate respondsToSelector:@selector(player:didPlay:)]) {
                [playerSelf.delegate player:playerSelf didPlay:time];
            }
        }];
    }
}

- (void)initObserver
{
    [self removeObserver];
    if (self.currentItem != nil) {
        self.oldItem = self.currentItem;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:self.currentItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround:) name:UIApplicationDidBecomeActiveNotification object:self.currentItem];
        
        [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:StatusChanged];
        [self.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:PlaybackBufferEmpty];
        [self.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:LoadedTimeRanges];
        [self.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:PlaybackLikelyToKeepUp];
        
        if ([self.delegate respondsToSelector:@selector(player:didChangedPlayerItem:)]) {
            [self.delegate player:self didChangedPlayerItem:self.currentItem];
        }
    }
}

- (void)removeObserver
{
    if (_oldItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_oldItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:_oldItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:_oldItem];
        
        [_oldItem removeObserver:self forKeyPath:@"status"];
        [_oldItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_oldItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_oldItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        _oldItem = nil;
    }
}

- (void)removePlayerTimerObserver
{
    if (_timeObserver != nil) {
        [self removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

/**
 * Video did play to the end
 */
- (void)playerDidReachedEnd:(NSNotification *)notification
{
    if (notification.object == self.currentItem) {
        if (_loopEnabled) {
            [self seekToTime:kCMTimeZero];
            if ([self isPlaying]) {
                [self play];
            }
        }
        if ([self.delegate respondsToSelector:@selector(player:didReachedEndForItem:)]) {
            [self.delegate player:self didReachedEndForItem:self.currentItem];
        }
    }
}

/**
 * video did enter background
 */
- (void)appDidEnterBackground:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self pause];
}

/**
 * video did active
 */
- (void)appDidEnterPlayGround:(NSNotification *)notification
{
    [self play];
}

- (BOOL)isSendingPlayerInfo
{
    return _timeObserver != nil;
}
#pragma mark - setup player item
- (void)setItemByStringPath:(NSString *)stringPath
{
    [self setItemByUrl:[NSURL URLWithString:stringPath]];
}

- (void)setItemByUrl:(NSURL *)url
{
    [self setItemByAsset:[AVURLAsset URLAssetWithURL:url options:nil]];
}

- (void)setItemByAsset:(AVAsset *)asset
{
    [self setItem:[AVPlayerItem playerItemWithAsset:asset]];
}

- (void)setItem:(AVPlayerItem *)item
{
    [self replaceCurrentItemWithPlayerItem:item];
}

+ (LTPlayer *)player
{
    return [LTPlayer new];
}

- (BOOL)isPlaying
{
    return self.rate > 0;
}

- (void)setLoopEnabled:(BOOL)loopEnabled
{
    _loopEnabled = loopEnabled;
    self.actionAtItemEnd = loopEnabled ? AVPlayerActionAtItemEndNone : AVPlayerActionAtItemEndPause;
}

@end
