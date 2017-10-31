//
//  LTRecorder.h
//  LTRecorder
//
//  Created by 孟令通 on 2017/10/31.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LTRecorder : NSObject

@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;

@end
