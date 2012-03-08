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

#import "WSAreaChartView.h"
#import <QuartzCore/QuartzCore.h>
#import "WSLegendLayer.h"
#import "WSCoordinateLayer.h"
#import "WSGlobalCore.h"

#define Y_MARKS_COUNT 5
#define ANGLE_DEFAULT M_PI/4.0
#define DISTANCE_DEFAULT 15.0
#define FRONT_LINE_COLOR [UIColor whiteColor]
#define BACK_LINE_COLOR [UIColor grayColor]
#define COORDINATE_BOTTOM_GAP 100.0
#define COORDINATE_TOP_GAP 50.0
#define COORDINATE_LEFT_GAP 80.0
#define TITLE_FONT_SIZE 22

#pragma mark - WSAreaLayer

@interface WSAreaLayer:CAShapeLayer

@property (nonatomic, strong) NSArray* points;
@property (nonatomic) CGFloat rowWidth;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) CGPoint originalPoint;

@end

@implementation WSAreaLayer

@synthesize points = _points;
@synthesize rowWidth = _rowWidth;
@synthesize color = _color;
@synthesize originalPoint = _originalPoint;

- (id)init
{
    self = [super init];
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{   
    size_t count = [self.points count];
    CGPoint p[count];
    for (int i=0; i<count; i++) {
        CGPoint point = [[self.points objectAtIndex:i] CGPointValue];
        p[i] = point;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines(path, NULL, p, count);
    CGPoint point = [[self.points lastObject] CGPointValue];
    CGPathAddLineToPoint(path, NULL, point.x, self.originalPoint.y);
    CGPathAddLineToPoint(path, NULL, self.originalPoint.x, self.originalPoint.y);
    CGPathCloseSubpath(path);
    CGContextSetStrokeColorWithColor(ctx, self.color.CGColor);
    CGContextSetLineWidth(ctx, 2.0);
    UIColor *fillColor = CreateAlphaColor(self.color, 0.3);
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    CGPathRelease(path);
}

@end


#pragma mark - WSAreaChartView

@interface WSAreaChartView()

// coordinate view's origianl point , that bottom left of that frame.
@property (nonatomic) CGPoint coordinateOriginalPoint;
// the length of x and y axis
@property (nonatomic) CGFloat xAxisLength;
@property (nonatomic) CGFloat yAxisLength;
// max and min value of user data
@property (nonatomic) float maxAreaValue;
@property (nonatomic) float minAreaValue;
// layers for different part of Area chart view
@property (nonatomic, strong) CALayer *areaLayer;
@property (nonatomic, strong) WSCoordinateLayer *xyAxesLayer;
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic, strong) CALayer *legendLayer;
// mark's count that are on y axis
@property (nonatomic) int yMarksCount;
// the point that display zero user data value on y axis
@property (nonatomic) CGPoint zeroPoint;


- (float)calculateFinalYAxisTitle:(float) value isMax:(BOOL)max;
- (NSMutableArray*)calculateYAxisValuesWithMin:(CGFloat)min andMax:(CGFloat)max;

@end

@implementation WSAreaChartView

@synthesize coordinateOriginalPoint = _coordinateOriginalPoint;
@synthesize xAxisLength = _xAxisLength;
/* 
 Get the max and min value from Area datas.
 */ 
@synthesize maxAreaValue = _maxAreaValue;
@synthesize minAreaValue = _minAreaValue;
@synthesize areaLayer = _areaLayer;
@synthesize xyAxesLayer = _xyAxesLayer;
@synthesize xAxisKey = _xAxisKey;
@synthesize title = _title;
@synthesize rowWidth = _rowWidth;
@synthesize titleLayer = _titleLayer;
@synthesize legendLayer = _legendLayer;
@synthesize yAxisLength = _yAxisLength;
@synthesize yMarksCount = _yMarksCount;
@synthesize zeroPoint = _zeroPoint;
@synthesize showZeroValueAtYAxis = _showZeroValueAtYAxis;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.coordinateOriginalPoint = CGPointMake(frame.origin.x + COORDINATE_LEFT_GAP, frame.size.height - COORDINATE_BOTTOM_GAP);
        self.maxAreaValue= CGFLOAT_MAX*(-1.0);
        self.minAreaValue = CGFLOAT_MAX;
        self.rowWidth = 20.0;
        self.title = @"WSAreaChart";
        self.areaLayer = [CALayer layer];
        self.xyAxesLayer = [[WSCoordinateLayer alloc] init];
        self.titleLayer = [CATextLayer layer];
        self.legendLayer = [CALayer layer];
        self.areaLayer.frame = frame;
        self.xyAxesLayer.frame = frame;
        self.yAxisLength = self.frame.size.height - COORDINATE_BOTTOM_GAP - COORDINATE_TOP_GAP;
        self.xAxisLength = self.frame.size.width - 2*COORDINATE_LEFT_GAP;
        self.yMarksCount = Y_MARKS_COUNT;
        self.showZeroValueAtYAxis = NO;
    }
    return self;
}

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    // get the max and min value from user datas
    NSArray *datas = [arr copy];
    NSDictionary *colorDict = [dict copy];
    NSMutableArray *xValues = [[NSMutableArray alloc] init];
    int length = [datas count];
    for (int i=0; i<length; i++) {
        NSDictionary *data = [datas objectAtIndex:i];
        [xValues addObject:[data valueForKey:self.xAxisKey]];
        [data enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
            if (![key isEqual:self.xAxisKey]) {
                self.maxAreaValue = self.maxAreaValue > [obj floatValue] ? self.maxAreaValue : [obj floatValue];
                self.minAreaValue = self.minAreaValue < [obj floatValue] ? self.minAreaValue : [obj floatValue];
            }
        }];
    }
    //store the marks' value that displayed on y axis
    NSMutableArray *yMarkTitles = [[NSMutableArray alloc] init];
    /*
     propotion: to convert the user data value to y axis' value.
     minValue, maxValue : which will be displayed as max and min value on y axis.
     correction : if the cross point bwteen y and x axis is not zero. should re-calculate the value that displayed on coordinate
     */
    float minValue, maxValue,offsetValue,propotion,correction;
    minValue = [self calculateFinalYAxisTitle:self.minAreaValue isMax:NO];
    maxValue = [self calculateFinalYAxisTitle:self.maxAreaValue isMax:YES];
    
    if (self.minAreaValue >= 0.0 && self.maxAreaValue > 0.0) {
        if (self.showZeroValueAtYAxis) minValue = 0.0;
        offsetValue = maxValue - minValue;
        propotion = self.yAxisLength/offsetValue;
        self.zeroPoint = self.coordinateOriginalPoint;
        yMarkTitles = [self calculateYAxisValuesWithMin:minValue andMax:maxValue];
        correction = minValue;
    }else if (self.minAreaValue < 0.0 && self.maxAreaValue >= 0.0){
        float bigDis = fabsf(minValue)>fabsf(maxValue)?fabsf(minValue):fabsf(maxValue);
        float markDis = bigDis/Y_MARKS_COUNT;
        float smallDis = fabsf(minValue)<fabsf(maxValue)?fabsf(minValue):fabsf(maxValue);
        int smallMarkCount = (int)ceilf(smallDis/markDis);
        self.yMarksCount = Y_MARKS_COUNT+smallMarkCount;
        offsetValue = markDis*(float)self.yMarksCount;
        propotion = self.yAxisLength/offsetValue;
        if (fabsf(minValue)<=fabsf(maxValue)) {
            self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength*smallMarkCount/self.yMarksCount);
            yMarkTitles = [self calculateYAxisValuesWithMin:-markDis*smallMarkCount andMax:maxValue];
        }else{
            self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength*Y_MARKS_COUNT/self.yMarksCount);
            yMarkTitles = [self calculateYAxisValuesWithMin:minValue andMax:markDis*smallMarkCount];
        }
        correction = 0.0;
    }else if (self.minAreaValue < 0.0 && self.maxAreaValue <= 0.0){
        if (self.showZeroValueAtYAxis) maxValue = 0.0;
        offsetValue = maxValue - minValue;
        propotion = self.yAxisLength/offsetValue;
        self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength);
        yMarkTitles = [self calculateYAxisValuesWithMin:minValue andMax:maxValue];
        correction = maxValue;
    }
    
    // draw Area area
    //yValue = ([obj floatValue]-correction)*propotion;
    NSArray *legendNames = [colorDict allKeys];
    for (int j=0; j<[legendNames count]; j++) {
        NSString *legendName = [legendNames objectAtIndex:j];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        WSAreaLayer *layer = [[WSAreaLayer alloc] init];
        layer.color = [colorDict valueForKey:legendName];
        for (int i=0; i<length; i++) {
            NSDictionary *data = [datas objectAtIndex:i];
            
            CGFloat yValue = self.zeroPoint.y - ([[data valueForKey:legendName] floatValue]-correction)*propotion;
            CGPoint point = CGPointMake(self.rowWidth*i+self.zeroPoint.x, yValue);
            [points addObject:[NSValue valueWithCGPoint:point]];
        }
        layer.originalPoint = self.coordinateOriginalPoint;
        layer.points = [points copy];
        layer.frame = self.bounds;
        [layer setNeedsDisplay];
        [self.areaLayer addSublayer:layer];
    }
    // draw coordinate first
    self.xyAxesLayer.yMarkTitles = yMarkTitles;
    self.xyAxesLayer.xMarkDistance = self.rowWidth;
    self.xyAxesLayer.xMarkTitles = xValues;
    self.xyAxesLayer.zeroPoint = self.zeroPoint;
    self.xyAxesLayer.yMarksCount = self.yMarksCount;
    self.xyAxesLayer.yAxisLength = self.yAxisLength;
    self.xyAxesLayer.xAxisLength = self.rowWidth*[xValues count];
    self.xyAxesLayer.originalPoint = self.coordinateOriginalPoint;
    self.xyAxesLayer.xMarkTitlePosition = WSAtPoint;
    [self.xyAxesLayer setNeedsDisplay];
    
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
    [self.layer addSublayer:self.titleLayer];
    [self.layer addSublayer:self.legendLayer];
    [self.layer addSublayer:self.areaLayer];
    [self.layer addSublayer:self.xyAxesLayer];
}
/*
 Calculate the marks' value which should be displayed on y axis. 
 */
- (NSMutableArray*)calculateYAxisValuesWithMin:(CGFloat)min andMax:(CGFloat)max
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSNumber numberWithFloat:min]];
    float offset = (max - min)/self.yMarksCount;
    for (int i=1; i<=self.yMarksCount; i++) {
        [arr addObject:[NSNumber numberWithFloat:(min+offset*i)]];
    }
    return arr;
}
/*
 Calculate the user data's max and min value which should be displayed on y axis.
 */
- (float)calculateFinalYAxisTitle:(float)value isMax:(BOOL)max
{
    if (max) {
        if (value > -100.0 && value <= 0.0) return 0.0;
    }else{
        if (value >= 0.0 && value < 100.0) return 0.0;
    }
    // value = fisrtStr*10^lastStr
    NSNumberFormatter *numFormatter  = [[NSNumberFormatter alloc] init];
    [numFormatter setNumberStyle:NSNumberFormatterScientificStyle];
    NSString *numStr = [numFormatter stringFromNumber:[NSNumber numberWithFloat:value]];
    NSString *e = @"E";
    // also can use [[maxNumStr componentsSeparatedByString:e] lastObject] to get the substring after "e", but slower than using range
    NSRange range = [numStr rangeOfString:e];
    NSString *lastStr = [numStr substringFromIndex:range.location+1];
    NSString *firstStr = [numStr substringToIndex:range.location];
    float finalFirstNum = 0.0;
    if (max) {
        finalFirstNum = ceilf([firstStr floatValue]);
        if (finalFirstNum > ([firstStr floatValue]+0.5)) {
            finalFirstNum = (floorf([firstStr floatValue])+0.5);
        }
        if (finalFirstNum == floorf([firstStr floatValue])) {
            finalFirstNum += 0.5;
        }
    }else{
        finalFirstNum = floorf([firstStr floatValue]);
        if (finalFirstNum < ([firstStr floatValue]-0.5)) {
            finalFirstNum = (ceilf([firstStr floatValue])-0.5);
        }
        if (ceilf([firstStr floatValue]) == finalFirstNum) {
            finalFirstNum -= 0.5;
        }
    }
    NSString *finalStr = [NSString stringWithFormat:@"%fE%@",finalFirstNum,lastStr];
    [numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *finalNum = [numFormatter numberFromString:finalStr];
    return [finalNum floatValue];
}

@end

