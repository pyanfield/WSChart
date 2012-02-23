//
//  WSColumnChartView.m
//  WSCharts
//
//  Created by han pyanfield on 12-2-21.
//  Copyright (c) 2012年 pyanfield. All rights reserved.
//

#import "WSColumnChartView.h"
#import <QuartzCore/QuartzCore.h>

#define ANGLE_DEFAULT M_PI/4.0
#define DISTANCE_DEFAULT 15.0

static CGMutablePathRef CreatePiePathWithCenter(CGPoint center, CGFloat radius,CGFloat startAngle, CGFloat angle,CGAffineTransform *transform)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, transform, center.x, center.y);
    CGPathAddRelativeArc(path, transform, center.x, center.y, radius, startAngle, angle);
    CGPathCloseSubpath(path);
    return path;
}

static CGPoint CreateEndPoint(CGPoint startPoint,CGFloat angle,CGFloat distance)
{
    float x = distance*sinf(angle);
    float y = distance*cosf(angle);
    CGPoint point = CGPointMake(startPoint.x+x,startPoint.y-y);
    return point;
}

#pragma mark - WSColumnItem
@interface WSColumnItem()
@end

@implementation WSColumnItem

@synthesize xValue = _xValue;
@synthesize yValue = _yValue;
@synthesize title = _title;

- (void)initColumnItem:(NSString *)title xValue:(NSString *)x yValue:(CGFloat)y
{
    self.title = title;
    self.xValue = x;
    self.yValue = y;
}

@end

#pragma mark - WSColumnLayer

@interface WSColumnLayer:CAShapeLayer

@property (nonatomic) CGPoint xStartPoint;
@property (nonatomic) CGFloat angle;
@property (nonatomic) CGFloat yValue;
@property (nonatomic) CGFloat cWidth;

//- (void)displayColumn;

@end

@implementation WSColumnLayer

@synthesize xStartPoint = _xStartPoint;
@synthesize angle = _angle;
@synthesize yValue = _yValue;
@synthesize cWidth = _cWidth;

- (id)init
{
    self = [super init];
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint topLeftFront = CGPointMake(self.xStartPoint.x-self.cWidth/2.0, self.xStartPoint.y-self.yValue);
    CGPoint topLeftBack = CreateEndPoint(topLeftFront, ANGLE_DEFAULT,DISTANCE_DEFAULT);
    CGPoint topRightFront = CGPointMake(self.xStartPoint.x+self.cWidth/2.0, self.xStartPoint.y-self.yValue);
    CGPoint topRightBack = CreateEndPoint(topRightFront, ANGLE_DEFAULT, DISTANCE_DEFAULT);
    CGPoint bottomRightBack = CGPointMake(topRightBack.x, topRightBack.y+self.yValue);
    CGPoint bottomRightFront = CGPointMake(topRightFront.x, self.xStartPoint.y);
    
    // front side
    CGPathAddRect(path, NULL, CGRectMake(topLeftFront.x,topLeftFront.y, self.cWidth, self.yValue));
    
    // top side
    CGPathMoveToPoint(path, NULL, topLeftFront.x,topLeftFront.y);
    CGPathAddLineToPoint(path, NULL, topLeftBack.x,topLeftBack.y);
    CGPathAddLineToPoint(path, NULL, topRightBack.x, topRightBack.y);
    CGPathAddLineToPoint(path, NULL,topRightFront.x,topRightFront.y);
    
    // right side
    CGPathMoveToPoint(path, NULL, topRightBack.x,topRightBack.y);
    CGPathAddLineToPoint(path, NULL, bottomRightBack.x, bottomRightBack.y);
    CGPathAddLineToPoint(path, NULL, bottomRightFront.x, bottomRightFront.y);
    
    UIColor *lineColor = [UIColor purpleColor];
    CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGPathRelease(path);
}

@end


#pragma mark - WSColumnChartView
@interface WSColumnChartView()

@end

@implementation WSColumnChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)chartData:(NSMutableArray *)datas
{
    NSArray *arr = [datas copy];
    for (int i=0; i<[arr count]; i++) {
        WSColumnItem *item = [arr objectAtIndex:i];
        
        WSColumnLayer *layer = [[WSColumnLayer alloc] init];
        layer.yValue = item.yValue;
        layer.cWidth = 20.0;
        layer.xStartPoint = CGPointMake(50.0*i+80.0, 350.0);
        layer.frame = self.bounds;
        [layer setNeedsDisplay];
        [self.layer addSublayer:layer];
    }
}
@end
