//
//  ViewController.m
//  像素操作
//
//  Created by HeroOneHy on 2018/12/28.
//  Copyright © 2018年 HeroOneHy. All rights reserved.
//

#import "ViewController.h"
#include <opencv2/core/core.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *tImage = [UIImage imageNamed:@"test.png"];
    cv::Mat mat = [self cvMatFromUIImage:tImage];
    std::vector<cv::Mat> planes;
    cv::split(mat, planes);
  //  cv::Mat chMat = planes[3]; //bgra
    cv::Mat  r = planes[0];
    cv::Mat  g = planes[1];
    cv::Mat  b = planes[2];
     cv::Mat a = planes[3];
   // std::cout<<a<<std::endl; //打印alpha通道
    
    cv::Mat resMat;
    cv::Mat imageA0 = cv::Mat(mat.size(),mat.depth(),cv::Scalar(0));
    std::vector<cv::Mat> src;
    src.push_back(r);
     src.push_back(imageA0);
     src.push_back(imageA0);
     src.push_back(a);
    cv::merge(src,resMat);
    UIImage *resImage =  [self UIImageFromCVMat:resMat];
 //   [self test2];
}
- (void)test{
    cv::Mat rgb(3,4,CV_8UC4, cv::Scalar(255,0,0,255) ); //创建一个3*4的rgb图片并打印出来
   //  UIImage *resImage =  [self UIImageFromCVMat:rgb];
    std::cout<<"rgb"<<rgb<<std::endl;
}
- (void)test2{
    cv::Mat rgb( 3, 4, CV_8UC3, cv::Scalar(1,2,3,4) );
    cv::vector<cv::Mat> channels;
    split(rgb,channels);
    cv::Mat r = channels.at(0);          //从vector中读数据用vector::at()
    cv::Mat g = channels.at(1);
    cv::Mat b = channels.at(2);
    std::cout<<"RGB="<<std::endl<<rgb<<std::endl;
    std::cout<<"r="<<std::endl<<r<<std::endl;
    std::cout<<"g="<<std::endl<<g<<std::endl;
    std::cout<<"b="<<std::endl<<b<<std::endl;
    
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
