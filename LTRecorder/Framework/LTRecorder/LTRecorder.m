//
//  LTRecorder.m
//  LTRecorder
//
//  Created by 孟令通 on 2017/10/31.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "LTRecorder.h"
@interface LTRecorder ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioDeviceInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *fileOutPut;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end
@implementation LTRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setupCamera
{
    NSError *error = nil;
    // 1. 初始化 AVCaptureSession
    self.captureSession = [[AVCaptureSession alloc] init];
}

+ (LTRecorder *)recorder
{
    return [LTRecorder new];
}

- (void)captureOutput:(nonnull AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(nonnull NSURL *)outputFileURL fromConnections:(nonnull NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error
{
    
}

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections
{
    
}


@end
