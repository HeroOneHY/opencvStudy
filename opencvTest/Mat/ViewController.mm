//
//  ViewController.m
//  Mat
//
//  Created by HeroOneHy on 2018/12/23.
//  Copyright © 2018年 HeroOneHy. All rights reserved.
//

#import "ViewController.h"
#include <opencv2/core/core.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
//#include <opencv2/imgcodecs/ios.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*  *imread()
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"];
    const char * cpath = [path cStringUsingEncoding:NSUTF8StringEncoding];
    cv::Mat image;
    image = cv::imread(cpath,CV_LOAD_IMAGE_ANYCOLOR);
    NSLog(@"%d--%d",image.rows,image.cols); //row为高，cols为宽
    if(image.empty()){
        NSLog(@"kong");
    }
    UIImage *uiImage = MatToUIImage(image);
    */
    UIImage *tImage = [UIImage imageNamed:@"test.png"];
    cv::Mat mat = [self cvMatFromUIImage:tImage];
    colorReduce(mat);
  //  cv::Mat gray_image;
 //   cv::cvtColor(mat, gray_image, CV_BGRA2GRAY); //opencv的颜色空间以BGR为主。
    printf("kskksk%d",129%64);
    uchar *data = mat.data;
    for(int i=0;i<10;i++){
        printf("data:%d\n",data[i]);
        data[i] = data[i];
    }
//    NSLog(@"%d--%d",gray_image.rows,gray_image.cols); //row为高，cols为宽,Mat中的数据名字叫元素，元素个数=row*cols
//    NSLog(@"通道数：%d",gray_image.channels());
//     NSLog(@"第一维的长度 %zu",gray_image.step[0]);
    UIImage *resultImage = [self UIImageFromCVMat:mat];
   
    // Do any additional setup after loading the view, typically from a nib.
}

void colorReduce(cv::Mat image, int div = 16)
{
    int m = image.rows;
    int n = image.cols*image.channels();
    for (int i = 0; i < m; ++i)
    {
        uchar *row = image.ptr<uchar>(i);
        for (int j = 0; j < n; ++j)
            row[j] = row[j]/div*div + div/2; //当dev=64时，row[j]/div*div + div/2  div为常数，row[j]/div取值0～3，所以共有4种像素
      //  data[i] = data[i] - data[i] % div + div / 2; 相似
    }
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