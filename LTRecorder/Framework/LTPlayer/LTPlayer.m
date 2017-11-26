//
//  LTPlayer.m
//  LTRecorder
//
//  Created by xhb_iOS on 2017/11/24.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "LTPlayer.h"

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

@end
