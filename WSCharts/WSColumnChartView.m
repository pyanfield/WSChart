/*
 Copyright (C) 2012, pyanfield  - pyanfield@gmail.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "WSColumnChartView.h"

#define ANGLE_DEFAULT M_PI/4.0
#define DISTANCE_DEFAULT 15.0

#pragma mark - WSColumnLayer

@interface WSColumnLayer:CAShapeLayer

@property (nonatomic) CGPoint xStartPoint;
@property (nonatomic) CGFloat yValue;
@property (nonatomic) CGFloat columnWidth;
@property (nonatomic, strong) UIColor *color;

@end

@implementation WSColumnLayer

@synthesize xStartPoint = _xStartPoint;
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
    CGPoint topLeftFront ,topLeftBack,topRightFront,topRightBack , bottomRightBack ,bottomRightFront;
    if (self.yValue>=0.0) {
        topLeftFront = CGPointMake(self.xStartPoint.x, self.xStartPoint.y-self.yValue);
        topLeftBack = CreateEndPoint(topLeftFront, ANGLE_DEFAULT,DISTANCE_DEFAULT);
        topRightFront = CGPointMake(self.xStartPoint.x+self.columnWidth, self.xStartPoint.y-self.yValue);
        topRightBack = CreateEndPoint(topRightFront, ANGLE_DEFAULT, DISTANCE_DEFAULT);
        bottomRightBack = CGPointMake(topRightBack.x, topRightBack.y+self.yValue);
        bottomRightFront = CGPointMake(topRightFront.x, self.xStartPoint.y);
    }else
    {
        topLeftFront = self.xStartPoint;
        topLeftBack = CreateEndPoint(topLeftFront, ANGLE_DEFAULT, DISTANCE_DEFAULT);
        topRightFront = CGPointMake(self.xStartPoint.x+self.columnWidth, self.xStartPoint.y);
        topRightBack = CreateEndPoint(topRightFront, ANGLE_DEFAULT, DISTANCE_DEFAULT);
        bottomRightBack = CGPointMake(topRightBack.x, topRightBack.y-self.yValue);
        bottomRightFront = CGPointMake(topRightFront.x, topLeftFront.y-self.yValue);
    }

    
    // front side
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(topLeftFront.x,topLeftFront.y, self.columnWidth,fabsf(self.yValue)));
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

@property (nonatomic, strong) WSCoordinateLayer *sublineLayer;
@property (nonatomic) int columnNum;

@end

@implementation WSColumnChartView

@synthesize sublineLayer = _sublineLayer;
@synthesize columnNum = _columnNum;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = @"WSColumnChart";
        self.sublineLayer = [[WSCoordinateLayer alloc] init];
        self.sublineLayer.show3DXAxisSubline = YES;
        self.sublineLayer.frame = frame;
    }
    return self;
}

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    self.columnNum = [[arr objectAtIndex:0] count];
    [super drawChart:arr withColor:dict];
}

- (void)createChartLayer
{
    int length = [datas count];
    for (int i=0; i<length; i++) {
        NSDictionary *data = [datas objectAtIndex:i];
        __block int flag = 0.0;
        [data enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
            WSColumnLayer *layer = [[WSColumnLayer alloc] init];
            WSChartObject *chartObj = obj;
            layer.color = [colorDict valueForKey:key];
            layer.yValue = (chartObj.yValue-correctionY)*propotionY;
            layer.columnWidth = self.rowWidth;
            layer.xStartPoint = CGPointMake(self.rowWidth*(flag+i*(length+1)+1)+zeroPoint.x, 
                                            zeroPoint.y);
            layer.frame = self.bounds;
            [layer setNeedsDisplay];
            [chartLayer addSublayer:layer];
            flag++;
        }];
    }
}

- (void)createCoordinateLayer
{
    xyAxesLayer.yMarkTitles = yMarkTitles;
    xyAxesLayer.xMarkDistance = self.rowWidth*(self.columnNum+2);
    xyAxesLayer.xMarkTitles = xMarkTitles;
    xyAxesLayer.zeroPoint = zeroPoint;
    xyAxesLayer.yMarksCount = yMarksCount;
    xyAxesLayer.yAxisLength = yAxisLength;
    xyAxesLayer.xAxisLength = xAxisLength;
    xyAxesLayer.originalPoint = self.coordinateOriginalPoint;
    [xyAxesLayer setNeedsDisplay];
    self.sublineLayer.zeroPoint = zeroPoint;
    self.sublineLayer.yMarksCount = yMarksCount;
    self.sublineLayer.yAxisLength = yAxisLength;
    self.sublineLayer.xAxisLength = xAxisLength;
    self.sublineLayer.originalPoint = self.coordinateOriginalPoint;
    [self.sublineLayer setNeedsDisplay];
}

- (void)manageAllLayersOrder
{
    [self.layer addSublayer:self.sublineLayer];
    [self.layer addSublayer:titleLayer];
    [self.layer addSublayer:legendLayer];
    [self.layer addSublayer:chartLayer];
    [self.layer addSublayer:xyAxesLayer];
}

@end
