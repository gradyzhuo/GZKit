//
//  FMLiveBlurView.h
//  FMKit
//
//  Created by 卓俊諺 on 2013/8/20.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <QuartzCore/CADisplayLink.h>

@interface GZBlurView : UIView


@property (nonatomic) CGFloat blurRadius;
@property (nonatomic) CGFloat saturationDeltaFactor;
@property (nonatomic, strong) UIColor *maskColor;

@property (nonatomic, getter = isLiving) BOOL living;

- (BOOL) isLiving;
- (void) refresh;

@end
