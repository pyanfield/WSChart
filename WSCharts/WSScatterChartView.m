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

#import "WSScatterChartView.h"

#define Y_MARKS_COUNT 5
#define X_MARKS_COUNT 5
#define FRONT_LINE_COLOR [UIColor whiteColor]
#define BACK_LINE_COLOR [UIColor grayColor]
#define COORDINATE_BOTTOM_GAP 100.0
#define COORDINATE_TOP_GAP 50.0
#define COORDINATE_LEFT_GAP 80.0
#define TITLE_FONT_SIZE 22
#define RADIUS 5.0

#pragma mark - WSScatterLayer

@interface WSScatterLayer : CAShapeLayer

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *radiusArr;
/*
 Can set the circle's radius.
 */
@property (nonatomic) BOOL enableChangeRadius;

@end



@implementation WSScatterLayer

@synthesize color = _color;
@synthesize points = _points;
@synthesize radiusArr = _radiusArr;
@synthesize enableChangeRadius = _enableChangeRadius;

- (id)init
{
    return [super init];
}

- (void)drawInContext:(CGContextRef)ctx
{
    int count = [self.points count];
    if (self.enableChangeRadius) {
        for (int i=0; i<count; i++) {
            CGPoint point = [[self.points objectAtIndex:i] CGPointValue];
            CGMutablePathRef path = CGPathCreateMutable();
            CGFloat r = [[self.radiusArr objectAtIndex:i] floatValue];
            CGRect rect = CGRectMake(point.x-r, point.y-r, 2*r, 2*r);
            CGPathAddEllipseInRect(path, NULL, rect);
            UIColor *fillColor = CreateAlphaColor(self.color, 0.5);
            CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathFill);
            CGPathRelease(path);
        }
    }else{
        for (int i=0; i<count; i++) {
            CGPoint point = [[self.points objectAtIndex:i] CGPointValue];
            CGMutablePathRef path = CGPathCreateMutable();
            CGRect rect = CGRectMake(point.x-RADIUS, point.y-RADIUS, 2*RADIUS, 2*RADIUS);
            CGPathAddEllipseInRect(path, NULL, rect);
            UIColor *fillColor = CreateAlphaColor(self.color, 0.5);
            CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathFill);
            CGPathRelease(path);
        }
    }
}

@end

#pragma mark - WSScatterChartView


@interface WSScatterChartView()

@property (nonatomic) CGFloat maxYValue;
@property (nonatomic) CGFloat minYValue;
@property (nonatomic) CGFloat maxXValue;
@property (nonatomic) CGFloat minXValue;

@end


@implementation WSScatterChartView

@synthesize maxXValue = _maxXValue;
@synthesize minXValue = _minXValue;
@synthesize maxYValue = _maxYValue;
@synthesize minYValue = _minYValue;
@synthesize coordinateOriginalPoint = _coordinateOriginalPoint;
@synthesize xAxisLength = _xAxisLength;
@synthesize chartLayer = _chartLayer;
@synthesize xyAxesLayer = _xyAxesLayer;
//@synthesize xAxisKey = _xAxisKey;
@synthesize title = _title;
//@synthesize rowWidth = _rowWidth;
@synthesize titleLayer = _titleLayer;
@synthesize legendLayer = _legendLayer;
@synthesize yAxisLength = _yAxisLength;
@synthesize yMarksCount = _yMarksCount;
@synthesize zeroPoint = _zeroPoint;
@synthesize showZeroValueAtYAxis = _showZeroValueAtYAxis;
@synthesize xMarksCount = _xMarksCount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.title = @"WSScatterChart";
        self.maxXValue = CGFLOAT_MAX*(-1.0);
        self.minXValue = CGFLOAT_MAX;
        self.maxYValue = CGFLOAT_MAX*(-1.0);
        self.minYValue = CGFLOAT_MAX;
        
        // Initialization code
        self.coordinateOriginalPoint = CGPointMake(frame.origin.x + COORDINATE_LEFT_GAP, frame.size.height - COORDINATE_BOTTOM_GAP);
        self.zeroPoint = CGPointMake(frame.origin.x + COORDINATE_LEFT_GAP, frame.size.height - COORDINATE_BOTTOM_GAP);
        //self.rowWidth = 20.0;
        self.chartLayer = [CALayer layer];
        self.xyAxesLayer = [[WSCoordinateLayer alloc] init];
        self.titleLayer = [CATextLayer layer];
        self.legendLayer = [CALayer layer];
        self.chartLayer.frame = frame;
        self.xyAxesLayer.frame = frame;
        self.yAxisLength = self.frame.size.height - COORDINATE_BOTTOM_GAP - COORDINATE_TOP_GAP;
        self.xAxisLength = self.frame.size.width - 2*COORDINATE_LEFT_GAP;
        self.yMarksCount = Y_MARKS_COUNT;
        self.xMarksCount = X_MARKS_COUNT;
        self.showZeroValueAtYAxis = NO;
    }
    return self;
}

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    // get the max and min value from user datas
    NSArray *datas = [arr copy];
    NSDictionary *colorDict = [dict copy];
    
    int length = [datas count];
    for (int i=0; i<length; i++) {
        NSDictionary *data = [datas objectAtIndex:i];
        [data enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
            WSChartObject *chartObj = (WSChartObject*)obj;
            self.maxYValue = self.maxYValue > chartObj.yValue ? self.maxYValue : chartObj.yValue;
            self.minYValue = self.minYValue < chartObj.yValue ? self.minYValue : chartObj.yValue;
            self.maxXValue = self.maxXValue > [chartObj.xValue floatValue] ? self.maxXValue : [chartObj.xValue floatValue];
            self.minXValue = self.minXValue < [chartObj.xValue floatValue] ? self.minXValue : [chartObj.xValue floatValue];
            
            NSLog(@"%f || %f",[chartObj.xValue floatValue],chartObj.yValue);
        }];
    }
    
    //store the marks' value that displayed on y axis
    NSMutableArray *yMarkTitles = [[NSMutableArray alloc] init];
    /*
     propotion: to convert the user data value to y axis' value.
     minValue, maxValue : which will be displayed as max and min value on y axis.
     correction : if the cross point bwteen y and x axis is not zero. should re-calculate the value that displayed on coordinate
     */
    float minY, maxY,offsetY,propotionY,correctionY;
    minY = CalculateAxisExtremePointValue(self.minYValue, NO);
    maxY = CalculateAxisExtremePointValue(self.maxYValue, YES);
    
    if (self.minYValue >= 0.0 && self.maxYValue > 0.0) {
        if (self.showZeroValueAtYAxis) minY = 0.0;
        offsetY = maxY - minY;
        propotionY = self.yAxisLength/offsetY;
        self.zeroPoint = CGPointMake(self.zeroPoint.x, self.coordinateOriginalPoint.y);
        yMarkTitles = CalculateValuesBetweenMinAndMax(minY, maxY, self.yMarksCount);
        correctionY = minY;
    }else if (self.minYValue < 0.0 && self.maxYValue >= 0.0){
        float bigDis = fabsf(minY)>fabsf(maxY)?fabsf(minY):fabsf(maxY);
        float markDis = bigDis/Y_MARKS_COUNT;
        float smallDis = fabsf(minY)<fabsf(maxY)?fabsf(minY):fabsf(maxY);
        int smallMarkCount = (int)ceilf(smallDis/markDis);
        self.yMarksCount = Y_MARKS_COUNT+smallMarkCount;
        offsetY = markDis*(float)self.yMarksCount;
        propotionY = self.yAxisLength/offsetY;
        if (fabsf(minY)<=fabsf(maxY)) {
            self.zeroPoint = CGPointMake(self.zeroPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength*smallMarkCount/self.yMarksCount);
            yMarkTitles = CalculateValuesBetweenMinAndMax(-markDis*smallMarkCount, maxY, self.yMarksCount);
        }else{
            self.zeroPoint = CGPointMake(self.zeroPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength*Y_MARKS_COUNT/self.yMarksCount);
            yMarkTitles = CalculateValuesBetweenMinAndMax(minY, markDis*smallMarkCount, self.yMarksCount);
        }
        correctionY = 0.0;
    }else if (self.minYValue < 0.0 && self.maxYValue <= 0.0){
        if (self.showZeroValueAtYAxis) maxY = 0.0;
        offsetY = maxY - minY;
        propotionY = self.yAxisLength/offsetY;
        self.zeroPoint = CGPointMake(self.zeroPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength);
        yMarkTitles = CalculateValuesBetweenMinAndMax(minY, maxY, self.yMarksCount);
        correctionY = maxY;
    }
    
    
    //store the marks' value that displayed on x axis
    NSMutableArray *xMarkTitles = [[NSMutableArray alloc] init];
    
    float minX, maxX,offsetX,propotionX,correctionX;
    minX = CalculateAxisExtremePointValue(self.minXValue, NO);
    maxX = CalculateAxisExtremePointValue(self.maxXValue, YES);
    
    if (self.minXValue >= 0.0 && self.maxXValue > 0.0) {
        if (self.showZeroValueAtYAxis) minX = 0.0;
        offsetX = maxX - minX;
        propotionX = self.xAxisLength/offsetX;
        self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x, self.zeroPoint.y);
        xMarkTitles = CalculateValuesBetweenMinAndMax(minX, maxX, self.yMarksCount);
        correctionX = minX;
    }else if (self.minXValue < 0.0 && self.maxXValue >= 0.0){
        float bigDis = fabsf(minX)>fabsf(maxX)?fabsf(minX):fabsf(maxX);
        float markDis = bigDis/X_MARKS_COUNT;
        float smallDis = fabsf(minX)<fabsf(maxX)?fabsf(minX):fabsf(maxX);
        int smallMarkCount = (int)ceilf(smallDis/markDis);
        self.xMarksCount = X_MARKS_COUNT+smallMarkCount;
        offsetX = markDis*(float)self.xMarksCount;
        propotionX = self.xAxisLength/offsetX;
        if (fabsf(minX)<=fabsf(maxX)) {
            self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x+self.xAxisLength*smallMarkCount/self.xMarksCount, self.zeroPoint.y);
            xMarkTitles = CalculateValuesBetweenMinAndMax(-markDis*smallMarkCount, maxX, self.xMarksCount);
        }else{
            self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x+self.xAxisLength*X_MARKS_COUNT/self.xMarksCount, self.zeroPoint.y);
            xMarkTitles = CalculateValuesBetweenMinAndMax(minX, markDis*smallMarkCount, self.xMarksCount);
        }
        correctionX = 0.0;
    }else if (self.minXValue < 0.0 && self.maxXValue <= 0.0){
        if (self.showZeroValueAtYAxis) maxX = 0.0;
        offsetX = maxX - minX;
        propotionX = self.xAxisLength/offsetX;
        self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x+self.xAxisLength, self.zeroPoint.y);
        xMarkTitles = CalculateValuesBetweenMinAndMax(minX, maxX, self.xMarksCount);
        correctionX = maxX;
    }
    
    // draw chart layer
    //yValue = ([obj floatValue]-correction)*propotion;
    [self createChartLayerWithDatas:datas colors:colorDict yCorrection:correctionY yPropotion:propotionY xCorrection:correctionX xPropotion:propotionX];
    // draw coordinate first
    [self createCoordinateLayerWithYTitles:yMarkTitles XTitles:xMarkTitles];
    
    // add the title layer
    self.titleLayer.string = self.title;
    self.titleLayer.fontSize = TITLE_FONT_SIZE;
    UIFont *helveticated = [UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE];
    CGSize size = [self.title sizeWithFont:helveticated];
    self.titleLayer.frame = CGRectMake(COORDINATE_LEFT_GAP/2, COORDINATE_TOP_GAP/2, size.width, size.height);
    
    // add the lengedn layer
    __block int flag = 0;
    __block float legendWidth = 0.0;
    [colorDict enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
        WSLegendLayer *layer = [[WSLegendLayer alloc] initWithColor:obj andTitle:key];
        layer.position  = CGPointMake(0.0, 20.0*flag);
        [layer setNeedsDisplay];
        [self.legendLayer addSublayer:layer];
        flag++;
        legendWidth = legendWidth > layer.frame.size.width ? legendWidth : layer.frame.size.width;
    }];
    self.legendLayer.frame = CGRectMake(self.bounds.size.width - legendWidth - COORDINATE_LEFT_GAP, 20.0, legendWidth, self.frame.size.height);
    
    // carefully about the adding order
    [self manageAllLayersOrder];
}

- (void)createChartLayerWithDatas:(NSArray *)datas colors:(NSDictionary *)colorDict yCorrection:(CGFloat)correctionY yPropotion:(CGFloat)propotionY xCorrection:(CGFloat)correctionX xPropotion:(CGFloat)propotionX
{
    NSArray *legendNames = [colorDict allKeys];
    for (int j=0; j<[legendNames count]; j++) {
        NSString *legendName = [legendNames objectAtIndex:j];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        WSScatterLayer *layer = [[WSScatterLayer alloc] init];
        layer.color = [colorDict valueForKey:legendName];
        for (int i=0; i<[datas count]; i++) {
            NSDictionary *data = [datas objectAtIndex:i];
            WSChartObject *chartObj = [data valueForKey:legendName];
            CGFloat yValue = self.zeroPoint.y - (chartObj.yValue - correctionY) * propotionY;
            CGFloat xValue = self.zeroPoint.x + ([chartObj.xValue floatValue] - correctionX) * propotionX;
            CGPoint point = CGPointMake(xValue, yValue);
            [points addObject:[NSValue valueWithCGPoint:point]];
        }
        layer.points = [points copy];
        layer.frame = self.bounds;
        [layer setNeedsDisplay];
        [self.chartLayer addSublayer:layer];
    }
}

- (void)createCoordinateLayerWithYTitles:(NSMutableArray *)yMarkTitles XTitles:(NSMutableArray *)xMarkTitles
{
    self.xyAxesLayer.yMarkTitles = yMarkTitles;
    self.xyAxesLayer.xMarkDistance = self.xAxisLength/self.xMarksCount;
    self.xyAxesLayer.xMarkTitles = xMarkTitles;
    self.xyAxesLayer.zeroPoint = self.zeroPoint;
    self.xyAxesLayer.yMarksCount = self.yMarksCount;
    self.xyAxesLayer.yAxisLength = self.yAxisLength;
    self.xyAxesLayer.xAxisLength = self.xAxisLength;
    self.xyAxesLayer.originalPoint = self.coordinateOriginalPoint;
    self.xyAxesLayer.xMarkTitlePosition = WSAtPoint;
    
//    self.xyAxesLayer.showBorder = YES;
//    self.xyAxesLayer.showTopRightBorder = YES;
//    self.xyAxesLayer.showBottomLeftBorder = YES;
//    self.xyAxesLayer.showXAxisSubline = YES;
//    self.xyAxesLayer.showYAxisSubline = YES;
    [self.xyAxesLayer setNeedsDisplay];
}

- (void)manageAllLayersOrder
{
    [self.layer addSublayer:self.titleLayer];
    [self.layer addSublayer:self.legendLayer];
    [self.layer addSublayer:self.chartLayer];
    [self.layer addSublayer:self.xyAxesLayer];
}

@end
