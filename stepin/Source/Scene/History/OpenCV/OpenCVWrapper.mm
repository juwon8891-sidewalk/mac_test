//
//  OpenCVWrapper.m
//  stepin
//
//  Created by 김경현 on 2023/04/24.
//

#import "opencvWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <onnxruntime.h>
#import "onnxruntime_cxx_api.h"

static double HUMAN_THRESHOLD = 200;
static double CLOTH_THRESHOLD = 100;
static double HAIR_THRESHOLD = 50;


@implementation OpenCVWrapper : NSObject

ORTSession *session;
double cRed;
double cGreen;
double cBlue;

cv::Mat targetImageMat;

- (NSMutableData *) uiImageToData:(UIImage *)uiImage red:(double)red green:(double)green blue:(double)blue {
    cRed = red * 255;
    cGreen = green * 255;
    cBlue = blue * 255;
    cv::Mat mat = cv::Mat();
    UIImageToMat(uiImage, mat);

    cv::cvtColor(mat, mat, cv::COLOR_BGRA2BGR);

    targetImageMat = mat.clone();
    mat.convertTo(mat, CV_32FC3, 1 / 255.0);


    // Mat 데이터를 NSData로 변환
    NSMutableData *data = [NSMutableData dataWithBytes:mat.data length:mat.total() * mat.elemSize()];
    mat.release();
    return data;
}



- (UIImage *)CreateNeonImage:(int)index humanData:(NSMutableData *)humanData clothData:(NSMutableData *)clothData hairData:(NSMutableData *)hairData {
    cv::Mat human = cv::Mat(1280, 720, CV_32FC1, [humanData mutableBytes]);
    human.convertTo(human, CV_8UC1, 255.0);
    cv::threshold(human, human, HUMAN_THRESHOLD, 255, cv::THRESH_BINARY);
    
//    std::vector<float> clothVector = convertDataToVector(clothData);
    cv::Mat clothMat = cv::Mat(1280, 720, CV_32FC1, [clothData mutableBytes]);
    clothMat.convertTo(clothMat, CV_8UC1, 255);
    cv::threshold(clothMat, clothMat, CLOTH_THRESHOLD, 255, cv::THRESH_BINARY);
    cv::bitwise_and(human, clothMat, clothMat);
    
    
//    std::vector<float> hairVector = convertDataToVector(hairData);
    cv::Mat hairMat = cv::Mat(1280, 720, CV_32FC1, [hairData mutableBytes]);
    hairMat.convertTo(hairMat, CV_8UC1, 255.0);
    cv::threshold(hairMat, hairMat, HAIR_THRESHOLD, 255, cv::THRESH_BINARY);
    cv::bitwise_and(human, hairMat, hairMat);
    

    cv::Mat skin = cv::Mat(1280, 720, CV_8UC1);
    cv::subtract(human, clothMat, skin);
    
    
    cv::Mat mask = human.clone();
    cv::cvtColor(mask, mask, cv::COLOR_GRAY2RGB);
    mask.convertTo(mask, CV_8UC3, 255);
    
    targetImageMat.convertTo(targetImageMat, CV_8UC3);
    cv::bitwise_and(targetImageMat, mask, targetImageMat);

    // Canny
    cv::Mat gray = cv::Mat();
    cv::cvtColor(targetImageMat, gray, cv::COLOR_RGB2GRAY);
    cv::Mat grayFiltered = cv::Mat();
    cv::bilateralFilter(gray, grayFiltered, 7, 10.0, 10.0);

    cv::Mat canny = cv::Mat();
    cv::Canny(grayFiltered, canny, 60.0, 120.0);

    cv::bitwise_or(clothMat, hairMat, clothMat);
    cv::bitwise_and(canny, clothMat, canny);

    std::vector<std::vector<cv::Point>> main_contours;
    cv::findContours(canny, main_contours, cv::RETR_LIST, cv::CHAIN_APPROX_TC89_KCOS);

    std::vector<std::vector<cv::Point>> edge_contours;
    cv::findContours(human, edge_contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_TC89_KCOS);

    cv::Mat merge = cv::Mat(1280, 720, CV_8UC1);
    cv::drawContours(merge, main_contours, -1, 255.0, 1, cv::LINE_AA);
    cv::drawContours(merge, edge_contours, -1, 255.0, 1, cv::LINE_AA);
    cv::threshold(merge, merge, 200.0, 255.0, cv::THRESH_BINARY);

    std::vector<std::vector<cv::Point>> all_contours;
    cv::findContours(merge, all_contours, cv::RETR_LIST, cv::CHAIN_APPROX_TC89_KCOS);

    cv::Mat result = cv::Mat::zeros(1280, 720, CV_8UC3);
    cv::drawContours(result, all_contours, -1, cv::Scalar(cRed, cGreen, cBlue), 8, cv::LINE_AA);
    cv::GaussianBlur(result, result, cv::Size(61.0, 61.0), 10.0, 10.0);
    cv::drawContours(result, all_contours, -1, cv::Scalar(255, 255, 255), 3, cv::LINE_AA);

    UIImage *resultImage = MatToUIImage(result);
    
    human.release();
    clothMat.release();
    hairMat.release();
    skin.release();
    
    gray.release();
    grayFiltered.release();
    canny.release();
    merge.release();
    result.release();
    targetImageMat.release();
    
    all_contours.clear();
    main_contours.clear();
    edge_contours.clear();
    
    return resultImage;
}
@end
