//
//  ViewController.m
//  opencvTest
//
//  Created by HeroOneHy on 2018/12/23.
//  Copyright © 2018年 HeroOneHy. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>

@interface ViewController ()<CvVideoCameraDelegate>
{
    UIImageView*cameraView;
    
    CvVideoCamera*videoCamera;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    cameraView = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    [self.view addSubview:cameraView];
    
    videoCamera = [[CvVideoCamera alloc] initWithParentView:cameraView];
    
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    
    videoCamera.defaultFPS = 30;
    
    videoCamera.grayscaleMode = NO;
    
    videoCamera.delegate = self;
    

    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [videoCamera start];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [videoCamera stop];
    
}
- (void)processImage:(cv::Mat&)image {
    
    //在这儿我们将要添加图形处理的代码
    
    cv::Mat image_copy;
    
    //首先将图片由RGBA转成GRAY
    
    cv::cvtColor(image, image_copy,cv::COLOR_BGR2GRAY);
    
    //反转图片
    
    cv::bitwise_not(image_copy, image_copy);
    
    //将处理后的图片赋值给image，用来显示
    
    cv::cvtColor(image_copy, image,cv::COLOR_GRAY2BGR);
    
}

@end
