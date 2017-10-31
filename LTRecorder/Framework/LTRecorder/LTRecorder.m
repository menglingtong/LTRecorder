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

@end
