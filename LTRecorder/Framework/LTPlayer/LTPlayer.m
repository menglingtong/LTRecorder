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

+ (LTPlayer *)player
{
    return [LTPlayer new];
}

@end
