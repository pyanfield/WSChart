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

static NSDictionary* ConstructBrightAndDarkColors(UIColor *color)
{
    /*
     CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
     
     if (![color respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
     [color getRed:&red green:&green blue:&blue alpha:&alpha];
     NSLog(@"red: %f, green: %f, blue: %f, alpha: %f",red,green,blue,alpha);
     }
     */
    
    CGFloat hue = 0.0, saturation = 0.0 , brightness = 0.0, alpha = 0.0;
    if ([color respondsToSelector:@selector(getHue:saturation:brightness:alpha:)]) {
        [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        //NSLog(@"hub: %f, saturation: %f, brigntness: %f, alpha: %f",hue,saturation,brightness,alpha);
    }
    
    UIColor *brightColor = [UIColor colorWithHue:hue saturation:saturation+0.1 brightness:brightness+0.1 alpha:alpha];
    UIColor *darkColor = [UIColor colorWithHue:hue saturation:saturation-0.2 brightness:brightness-0.2 alpha:alpha];
    NSDictionary *colors = [NSDictionary dictionaryWithObjectsAndKeys:brightColor,@"brightColor",color,@"normalColor",darkColor,@"darkColor", nil];
    
    return colors;
}

#pragma mark - WSColumnItem
@interface WSColumnItem()
@end

@implementation WSColumnItem

@synthesize xValue = _xValue;
@synthesize yValue = _yValue;
@synthesize title = _title;
@synthesize color = _color;

- (void)initColumnItem:(NSString *)title xValue:(NSString *)x yValue:(CGFloat)y color:(UIColor*)color
{
    self.title = title;
    self.xValue = x;
    self.yValue = y;
    self.color = color;
}

@end

#pragma mark - WSColumnLayer

@interface WSColumnLayer:CAShapeLayer

@property (nonatomic) CGPoint xStartPoint;
@property (nonatomic) CGFloat angle;
@property (nonatomic) CGFloat yValue;
@property (nonatomic) CGFloat cWidth;
@property (nonatomic, strong) UIColor *color;

//- (void)displayColumn;

@end

@implementation WSColumnLayer

@synthesize xStartPoint = _xStartPoint;
@synthesize angle = _angle;
@synthesize yValue = _yValue;
@synthesize cWidth = _cWidth;
@synthesize color = _color;

- (id)init
{
    self = [super init];
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    NSDictionary *colors = ConstructBrightAndDarkColors(self.color);
    
    CGPoint topLeftFront = CGPointMake(self.xStartPoint.x-self.cWidth/2.0, self.xStartPoint.y-self.yValue);
    CGPoint topLeftBack = CreateEndPoint(topLeftFront, ANGLE_DEFAULT,DISTANCE_DEFAULT);
    CGPoint topRightFront = CGPointMake(self.xStartPoint.x+self.cWidth/2.0, self.xStartPoint.y-self.yValue);
    CGPoint topRightBack = CreateEndPoint(topRightFront, ANGLE_DEFAULT, DISTANCE_DEFAULT);
    CGPoint bottomRightBack = CGPointMake(topRightBack.x, topRightBack.y+self.yValue);
    CGPoint bottomRightFront = CGPointMake(topRightFront.x, self.xStartPoint.y);
    
    // front side
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(topLeftFront.x,topLeftFront.y, self.cWidth, self.yValue));
    UIColor *normalColor = [colors objectForKey:@"normalColor"];
    CGContextSetFillColorWithColor(ctx, normalColor.CGColor);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathFill);
    CGPathRelease(path);

    
    // top side
    CGMutablePathRef topPath = CGPathCreateMutable();
    CGPathMoveToPoint(topPath, NULL, topLeftFront.x,topLeftFront.y);
    CGPathAddLineToPoint(topPath, NULL, topLeftBack.x,topLeftBack.y);
    CGPathAddLineToPoint(topPath, NULL, topRightBack.x, topRightBack.y);
    CGPathAddLineToPoint(topPath, NULL,topRightFront.x,topRightFront.y);
    CGPathCloseSubpath(topPath);
    UIColor *brightColor = [colors objectForKey:@"brightColor"];
    CGContextSetFillColorWithColor(ctx, brightColor.CGColor);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextAddPath(ctx, topPath);
    CGContextDrawPath(ctx, kCGPathFill);
    CGPathRelease(topPath);
    
    // right side
    CGMutablePathRef rightPath = CGPathCreateMutable();
    CGPathMoveToPoint(rightPath, NULL, topRightBack.x,topRightBack.y);
    CGPathAddLineToPoint(rightPath, NULL, bottomRightBack.x, bottomRightBack.y);
    CGPathAddLineToPoint(rightPath, NULL, bottomRightFront.x, bottomRightFront.y);
    CGPathAddLineToPoint(rightPath, NULL, topRightFront.x, topRightFront.y);
    CGPathCloseSubpath(rightPath);
    UIColor *darkColor = [colors objectForKey:@"darkColor"];
    CGContextSetFillColorWithColor(ctx, darkColor.CGColor);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextAddPath(ctx, rightPath);
    CGContextDrawPath(ctx, kCGPathFill);
    CGPathRelease(rightPath);
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
        layer.color = item.color;
        layer.yValue = item.yValue;
        layer.cWidth = 20.0;
        layer.xStartPoint = CGPointMake(50.0*i+80.0, 350.0);
        layer.frame = self.bounds;
        [layer setNeedsDisplay];
        [self.layer addSublayer:layer];
    }
}
@end
