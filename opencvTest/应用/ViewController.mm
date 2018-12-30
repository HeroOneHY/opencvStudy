//
//  ViewController.m
//  应用
//
//  Created by HeroOneHy on 2018/12/30.
//  Copyright © 2018年 HeroOneHy. All rights reserved.
//

#import "ViewController.h"
#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *tImage = [UIImage imageNamed:@"person.jpeg"];
    cv::Mat image = [self cvMatFromUIImage:tImage];
    [self thresold:image];
    UIImage *resImage = [self UIImageFromCVMat:image];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)thresold:(cv::Mat)mat{
    cv::Mat hsv;
    cv::cvtColor(mat, hsv, CV_BGR2HSV);
    std::vector<cv::Mat> chans;
    cv::split(hsv, chans); //0色调1饱和度2亮度
    
    cv::Mat mask1;
    cv::threshold(chans[0], mask1, 10, 255, cv::THRESH_BINARY_INV); //if src>thresh then 0,else maxval
    cv::Mat mask2;
    cv::threshold(chans[0], mask2, 160, 255, cv::THRESH_BINARY); //if src>thresh then maxval,else 0
    cv::Mat hueMask;//色调掩码
    hueMask = mask1|mask2; //两幅图叠加后的色调掩码
    
    cv::threshold(chans[1], mask1, 166, 255, cv::THRESH_BINARY_INV);
    cv::threshold(chans[1], mask2, 25, 255, cv::THRESH_BINARY);
    cv::Mat satMask; //饱和度掩码
    satMask = mask1&mask2; //两幅图相交的饱和度掩码
    
    cv::Mat resultMask = hueMask&satMask;
    cv::Mat detected(mat.size(),CV_8UC3,cv::Scalar(0,0,0));
    mat.copyTo(detected, resultMask); //image.copyTo(imageROI，mask),作用是把mask和image重叠后，把mask中像素值为0的点变为image的对应点的像素，而保留其他点。
     UIImage *resImage = [self UIImageFromCVMat:detected];
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    //bitmapInfo   指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    //     NSLog(@"%d--%d",cvMat.rows,cvMat.cols); //row为高，cols为宽,Mat中的数据名字叫元素，元素个数=row*cols
    //    NSLog(@"通道数：%d",cvMat.channels()); //通道数：4
    //    NSLog(@"一个元素占的字节%zu",cvMat.elemSize()); //channels*一个通道占的bit/8 = 4*8/8
    //    NSLog(@"一个通道占的字节%zu",cvMat.elemSize1()); //一个通道占的字节 1
    //    NSLog(@"元素的一个通道的数据类型%d",cvMat.depth()); //0 将type的预定义值去掉通道信息就是depth值
    //    NSLog(@"元素的总数%zu",cvMat.total()); //287*154
    //     NSLog(@"第一维的长度 %zu",cvMat.step[0]); //第一维的长度 = cols*channels
    //    NSLog(@"第二维的长度 %zu",cvMat.step[1]); //第二维的长度 = channels
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
