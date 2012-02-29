//
//  WSColumnChartView.m
//  WSCharts
//
//  Created by han pyanfield on 12-2-21.
//  Copyright (c) 2012年 pyanfield. All rights reserved.
//

#import "WSColumnChartView.h"
#import <QuartzCore/QuartzCore.h>
#import "WSLegendLayer.h"

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
    }else{
        NSLog(@"Not support getHue:saturation:brightness:alpha:");
    }
    
    UIColor *brightColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    UIColor *normalColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness*0.91 alpha:alpha];
    UIColor *darkColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness*0.78 alpha:alpha];
    NSDictionary *colors = [NSDictionary dictionaryWithObjectsAndKeys:brightColor,@"brightColor",normalColor,@"normalColor",darkColor,@"darkColor", nil];
    
    return colors;
}

#pragma mark - WSColumnLayer

#define ANGLE_DEFAULT M_PI/4.0
#define DISTANCE_DEFAULT 15.0

@interface WSColumnLayer:CAShapeLayer

@property (nonatomic) CGPoint xStartPoint;
@property (nonatomic) CGFloat angle;
@property (nonatomic) CGFloat yValue;
@property (nonatomic) CGFloat columnWidth;
@property (nonatomic, strong) UIColor *color;

//- (void)displayColumn;

@end

@implementation WSColumnLayer

@synthesize xStartPoint = _xStartPoint;
@synthesize angle = _angle;
@synthesize yValue = _yValue;
@synthesize columnWidth = _columnWidth;
@synthesize color = _color;

- (id)init
{
    self = [super init];
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    NSDictionary *colors = ConstructBrightAndDarkColors(self.color);
    
    CGPoint topLeftFront = CGPointMake(self.xStartPoint.x, self.xStartPoint.y-self.yValue);
    CGPoint topLeftBack = CreateEndPoint(topLeftFront, ANGLE_DEFAULT,DISTANCE_DEFAULT);
    CGPoint topRightFront = CGPointMake(self.xStartPoint.x+self.columnWidth, self.xStartPoint.y-self.yValue);
    CGPoint topRightBack = CreateEndPoint(topRightFront, ANGLE_DEFAULT, DISTANCE_DEFAULT);
    CGPoint bottomRightBack = CGPointMake(topRightBack.x, topRightBack.y+self.yValue);
    CGPoint bottomRightFront = CGPointMake(topRightFront.x, self.xStartPoint.y);
    
    // front side
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(topLeftFront.x,topLeftFront.y, self.columnWidth, self.yValue));
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

#pragma mark - WSCoordinateLayer

#define Y_MARKS_COUNT 5

@interface WSCoordinateLayer : CAShapeLayer

@property (nonatomic) CGFloat yMaxAxis;
@property (nonatomic) CGPoint originalPoint;
@property (nonatomic) CGFloat xMaxAxis;
@property (nonatomic,strong) NSMutableArray *xMarkTitles;
@property (nonatomic) CGFloat xMarkDistance;

- (void)drawLine:(CGContextRef)ctx isXAxis:(BOOL)x startPoint:(CGPoint)point length:(CGFloat)length isDashLine:(BOOL)dash color:(UIColor*)color;
- (void)drawLine:(CGContextRef)ctx startPoint:(CGPoint)p1 endPoint:(CGPoint)p2 isDashLine:(BOOL)dash color:(UIColor*)color;
- (void)drawText:(CGContextRef)ctx withText:(NSString*)text atPoint:(CGPoint)p1 color:(UIColor*)color;

@end

@implementation WSCoordinateLayer
@synthesize yMaxAxis = _yMaxAxis,originalPoint = _originalPoint,xMaxAxis = _xMaxAxis;
@synthesize xMarkTitles = _xMarkTitles,xMarkDistance = _xMarkDistance;

- (id)init
{
    self = [super init];
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    NSLog(@"draw in context");
    
    // TODO: should change the color according to the background color
    UIColor *frontLineColor = [UIColor whiteColor];
    UIColor *backLineColor = [UIColor grayColor];
    CGPoint backOriginalPoint = CreateEndPoint(self.originalPoint, ANGLE_DEFAULT, DISTANCE_DEFAULT);
    
    // draw front y Axis
    [self drawLine:ctx isXAxis:NO startPoint:self.originalPoint length:self.yMaxAxis isDashLine:NO color:frontLineColor];
    
    // draw front x Axis
    [self drawLine:ctx isXAxis:YES startPoint:self.originalPoint length:self.xMaxAxis isDashLine:NO color:frontLineColor];
    
    // draw back y Axis
    [self drawLine:ctx isXAxis:NO startPoint:backOriginalPoint length:self.yMaxAxis isDashLine:YES color:backLineColor];
    
    // draw back x Axis
    [self drawLine:ctx isXAxis:YES startPoint:backOriginalPoint length:self.xMaxAxis isDashLine:YES color:backLineColor];
    
    // draw bridge line between front and back original point
    [self drawLine:ctx startPoint:self.originalPoint endPoint:backOriginalPoint isDashLine:NO color:backLineColor];
    CGPoint xMaxPoint = CGPointMake(self.originalPoint.x + self.xMaxAxis, self.originalPoint.y);
    CGPoint xMaxPoint2 = CreateEndPoint(xMaxPoint, ANGLE_DEFAULT, DISTANCE_DEFAULT);
    [self drawLine:ctx startPoint:xMaxPoint endPoint:xMaxPoint2 isDashLine:NO color:backLineColor];
    
    //draw assit line 
    CGFloat markLength = self.yMaxAxis/Y_MARKS_COUNT;
    for (int i=1; i<= Y_MARKS_COUNT; i++) {
        CGPoint p1 = CGPointMake(self.originalPoint.x, self.originalPoint.y-markLength*i);
        CGPoint p2 = CreateEndPoint(p1, ANGLE_DEFAULT, DISTANCE_DEFAULT);
        [self drawLine:ctx startPoint:p1 endPoint:p2 isDashLine:NO color:backLineColor];
        [self drawLine:ctx isXAxis:YES startPoint:p2 length:self.xMaxAxis isDashLine:YES color:backLineColor];
        [self drawLine:ctx isXAxis:YES startPoint:p1 length:-6.0 isDashLine:NO color:frontLineColor];
    }
    
    //draw x axis mark and title
    for (int i=0; i<[self.xMarkTitles count]; i++) {
        CGPoint p1 = CGPointMake(self.xMarkDistance*(i+1)+self.originalPoint.x, self.originalPoint.y);
        CGPoint p2 = CGPointMake(p1.x, p1.y+4.0);
        [self drawLine:ctx startPoint:p1 endPoint:p2 isDashLine:NO color:frontLineColor];
        NSString *mark = [NSString stringWithFormat:[self.xMarkTitles objectAtIndex:i]];
        [self drawText:ctx withText:mark atPoint:CGPointMake(p1.x-self.xMarkDistance/2, p1.y) color:frontLineColor];
    }
    
}

- (void)drawText:(CGContextRef)ctx withText:(NSString*)text atPoint:(CGPoint)p1 color:(UIColor*)color
{
    UIGraphicsPushContext(ctx);
    CGContextSetFillColorWithColor(ctx,color.CGColor);
    UIFont *helveticated = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    CGSize size = [text sizeWithFont:helveticated];
    p1 = CGPointMake(p1.x-size.width/2, p1.y);
    [text drawAtPoint:p1 withFont:helveticated];
    UIGraphicsPopContext();
}

- (void)drawLine:(CGContextRef)ctx isXAxis:(BOOL)x startPoint:(CGPoint)point length:(CGFloat)length isDashLine:(BOOL)dash color:(UIColor *)color
{
    CGContextSaveGState(ctx);
    if (dash) {
        CGFloat phase = 2.0;
        const CGFloat pattern[] = {5.0,5.0};
        size_t count = 2;
        CGContextSetLineDash(ctx,phase,pattern,count);
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, point.x, point.y);
    if (x) {
        CGPathAddLineToPoint(path, NULL, point.x+length, point.y);
    }else{
        CGPathAddLineToPoint(path, NULL, point.x, point.y - length);
    }
    
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGPathRelease(path);
    CGContextRestoreGState(ctx);
}

- (void)drawLine:(CGContextRef)ctx startPoint:(CGPoint)p1 endPoint:(CGPoint)p2 isDashLine:(BOOL)dash color:(UIColor *)color
{
    CGContextSaveGState(ctx);
    if (dash) {
        CGFloat phase = 3.0;
        const CGFloat pattern[] = {3.0,3.0};
        size_t count = 2;
        CGContextSetLineDash(ctx,phase,pattern,count);
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, p1.x, p1.y);
    CGPathAddLineToPoint(path, NULL, p2.x, p2.y);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGPathRelease(path);
    CGContextRestoreGState(ctx);
}

@end

#pragma mark - WSColumnChartView

#define COORDINATE_BOTTOM_GAP 100.0
#define COORDINATE_TOP_GAP 50.0
#define COORDINATE_LEFT_GAP 80.0
#define TITLE_FONT_SIZE 22

@interface WSColumnChartView()

@property (nonatomic) CGPoint coordinateOriginalPoint;
@property (nonatomic) CGFloat xMaxAxis;
@property (nonatomic) CGFloat maxColumnValue;
@property (nonatomic) CGFloat minColumnValue;
@property (nonatomic) CGFloat offsetColumnValue;
@property (nonatomic, strong) CALayer *areaLayer;
@property (nonatomic, strong) WSCoordinateLayer *coordinateLayer;
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic, strong) CALayer *legendLayer;

@end

@implementation WSColumnChartView

@synthesize coordinateOriginalPoint = _coordinateOriginalPoint;
@synthesize xMaxAxis = _xMaxAxis;
/* 
 Get the max and min value from column datas.
 */ 
@synthesize maxColumnValue = _maxColumnValue;
@synthesize minColumnValue = _minColumnValue;
@synthesize offsetColumnValue = _offsetColumnValue;
@synthesize areaLayer = _areaLayer;
@synthesize coordinateLayer = _coordinateLayer;
@synthesize xAxisKey = _xAxisKey;
@synthesize title = _title;
@synthesize columnWidth = _columnWidth;
@synthesize titleLayer = _titleLayer;
@synthesize legendLayer = _legendLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.coordinateOriginalPoint = CGPointMake(frame.origin.x + COORDINATE_LEFT_GAP, frame.size.height - COORDINATE_BOTTOM_GAP);
        self.xMaxAxis = 0.0;
        self.maxColumnValue = 0.0;
        self.minColumnValue = CGFLOAT_MAX;
        self.columnWidth = 20.0;
        self.offsetColumnValue = 0.0;
        self.title = @"WSColumnChart";
        self.areaLayer = [CALayer layer];
        self.coordinateLayer = [[WSCoordinateLayer alloc] init];
        self.titleLayer = [CATextLayer layer];
        self.legendLayer = [CALayer layer];
        self.areaLayer.frame = frame;
        self.coordinateLayer.frame = frame;
    }
    return self;
}

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    // draw column area
    NSArray *datas = [arr copy];
    NSDictionary *colorDict = [dict copy];
    NSMutableArray *xValues = [[NSMutableArray alloc] init];
    int length = [datas count];
    for (int i=0; i<length; i++) {
        NSDictionary *data = [datas objectAtIndex:i];
        [xValues addObject:[data valueForKey:self.xAxisKey]];
        __block int flag = 0.0;
        [data enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
            if (![key isEqual:self.xAxisKey]) {
                WSColumnLayer *layer = [[WSColumnLayer alloc] init];
                layer.color = [colorDict valueForKey:key];
                layer.yValue = [obj floatValue];
                layer.columnWidth = self.columnWidth;
                //self.columnWidth*flag+self.coordinateOriginalPoint.x+self.columnWidth*2+i*self.columnWidth*(length+1)
                layer.xStartPoint = CGPointMake(self.columnWidth*(flag+i*(length+1)+1)+self.coordinateOriginalPoint.x, 
                                                self.coordinateOriginalPoint.y);
                layer.frame = self.bounds;
                [layer setNeedsDisplay];
                [self.areaLayer addSublayer:layer];
                
                flag++;
                self.maxColumnValue = self.maxColumnValue > [obj floatValue] ? self.maxColumnValue : [obj floatValue];
                self.minColumnValue = self.minColumnValue < [obj floatValue] ? self.minColumnValue : [obj floatValue];
            }
        }];
    }
    
    self.offsetColumnValue = self.maxColumnValue - self.minColumnValue;
    
    // draw coordinate first
    self.coordinateLayer.xMarkDistance = self.columnWidth*([[datas objectAtIndex:0] count]+1);
    self.coordinateLayer.xMarkTitles = xValues;
    self.coordinateLayer.yMaxAxis = self.frame.size.height - COORDINATE_BOTTOM_GAP - COORDINATE_TOP_GAP;
    self.coordinateLayer.xMaxAxis = self.frame.size.width - 2*COORDINATE_LEFT_GAP;
    self.coordinateLayer.originalPoint = self.coordinateOriginalPoint;
    [self.coordinateLayer setNeedsDisplay];
    
    // add the title layer
    self.titleLayer.string = self.title;
    self.titleLayer.fontSize = TITLE_FONT_SIZE;
    UIFont *helveticated = [UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE];
    CGSize size = [self.title sizeWithFont:helveticated];
    self.titleLayer.frame = CGRectMake(COORDINATE_LEFT_GAP/2, COORDINATE_TOP_GAP/2, size.width, size.height);
    
    // add the lengedn layer
    __block int flag = 0;
    [colorDict enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
        WSLegendLayer *layer = [[WSLegendLayer alloc] initWithColor:obj andTitle:key];
        layer.position  = CGPointMake(20.0, 20.0*flag);
        [layer setNeedsDisplay];
        [self.legendLayer addSublayer:layer];
        flag++;
    }];
    
    [self.layer addSublayer:self.legendLayer];
    [self.layer addSublayer:self.titleLayer];
    [self.layer addSublayer:self.coordinateLayer];
    [self.layer addSublayer:self.areaLayer];
}

@end
