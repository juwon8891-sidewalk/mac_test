//
//  OpenCVWrapper.h
//  stepin
//
//  Created by 김경현 on 2023/04/24.
//

#ifdef __cplusplus
#undef NO
#undef YES
#import <opencv2/opencv.hpp>
#endif

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <onnxruntime.h>


NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

- (NSMutableData *) uiImageToData:(UIImage *)uiImage red:(double)red green:(double)green blue:(double)blue;
- (UIImage *) CreateNeonImage:(int)index humanData:(NSMutableData *)humanData clothData:(NSMutableData *)clothData hairData:(NSMutableData *)hairData;
@end

NS_ASSUME_NONNULL_END
