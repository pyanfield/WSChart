//
//  WSLegendLayer.h
//  WSCharts
//
//  Created by han pyanfield on 12-2-29.
//  Copyright (c) 2012年 pyanfield. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface WSLegendLayer:CAShapeLayer
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) CGPoint rectStartPoint;
@property (nonatomic) CGPoint titleStartPoint;
@property (nonatomic, strong) UIFont *font;
- (id)initWithColor:(UIColor*)color andTitle:(NSString *)title;
@end