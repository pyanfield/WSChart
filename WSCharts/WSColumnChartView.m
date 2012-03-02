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

#pragma mark - WSCoordinateLayer

#define Y_MARKS_COUNT 5

@interface WSCoordinateLayer : CAShapeLayer

@property (nonatomic) CGFloat yAxisLength;
@property (nonatomic) CGPoint originalPoint;
@property (nonatomic) CGPoint zeroPoint;
@property (nonatomic) CGFloat xAxisLength;
@property (nonatomic,strong) NSMutableArray *xMarkTitles;
@property (nonatomic,strong) NSMutableArray *yMarkTitles;
@property (nonatomic) CGFloat xMarkDistance;
@property (nonatomic) int yMarksCount;


- (void)drawLine:(CGContextRef)ctx isXAxis:(BOOL)x startPoint:(CGPoint)point length:(CGFloat)length isDashLine:(BOOL)dash color:(UIColor*)color;
- (void)drawLine:(CGContextRef)ctx startPoint:(CGPoint)p1 endPoint:(CGPoint)p2 isDashLine:(BOOL)dash color:(UIColor*)color;
- (void)drawText:(CGContextRef)ctx withText:(NSString*)text atPoint:(CGPoint)p1 color:(UIColor*)color alignment:(WSAliment)alignment;

@end

@implementation WSCoordinateLayer
@synthesize yAxisLength = _yAxisLength,originalPoint = _originalPoint,xAxisLength = _xAxisLength;
@synthesize xMarkTitles = _xMarkTitles,xMarkDistance = _xMarkDistance,yMarkTitles = _yMarkTitles,zeroPoint = _zeroPoint;
@synthesize yMarksCount = _yMarksCount;

- (id)init
{
    self = [super init];
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    // TODO: should change the color according to the background color
    UIColor *frontLineColor = [UIColor whiteColor];
    UIColor *backLineColor = [UIColor grayColor];
    CGPoint backOriginalPoint = CreateEndPoint(self.originalPoint, ANGLE_DEFAULT, DISTANCE_DEFAULT);
    CGPoint backZeroPoint = CreateEndPoint(self.zeroPoint, ANGLE_DEFAULT, DISTANCE_DEFAULT);
    
    // draw front y Axis
    [self drawLine:ctx isXAxis:NO startPoint:self.originalPoint length:self.yAxisLength isDashLine:NO color:frontLineColor];
    
    // draw front x Axis
    [self drawLine:ctx isXAxis:YES startPoint:self.zeroPoint length:self.xAxisLength isDashLine:NO color:frontLineColor];
    
    // draw back y Axis
    [self drawLine:ctx isXAxis:NO startPoint:backOriginalPoint length:self.yAxisLength isDashLine:YES color:backLineColor];
    
    // draw back x Axis
    [self drawLine:ctx isXAxis:YES startPoint:backZeroPoint length:self.xAxisLength isDashLine:YES color:backLineColor];
    
    // draw bridge line between front and back original point
    [self drawLine:ctx startPoint:self.zeroPoint endPoint:backZeroPoint isDashLine:NO color:backLineColor];
    CGPoint xMaxPoint = CGPointMake(self.zeroPoint.x + self.xAxisLength, self.zeroPoint.y);
    CGPoint xMaxPoint2 = CreateEndPoint(xMaxPoint, ANGLE_DEFAULT, DISTANCE_DEFAULT);
    [self drawLine:ctx startPoint:xMaxPoint endPoint:xMaxPoint2 isDashLine:NO color:backLineColor];
    
    //draw assit line 
    CGFloat markLength = self.yAxisLength/self.yMarksCount;
    for (int i=0; i<= self.yMarksCount; i++) {
        CGPoint p1 = CGPointMake(self.originalPoint.x, self.originalPoint.y-markLength*i);
        CGPoint p2 = CreateEndPoint(p1, ANGLE_DEFAULT, DISTANCE_DEFAULT);
        [self drawLine:ctx startPoint:p1 endPoint:p2 isDashLine:NO color:backLineColor];
        [self drawLine:ctx isXAxis:YES startPoint:p2 length:self.xAxisLength isDashLine:YES color:backLineColor];
        [self drawLine:ctx isXAxis:YES startPoint:p1 length:-6.0 isDashLine:NO color:frontLineColor];
    }
    
    //draw y axis mark's title
    for (int i=0; i<=self.yMarksCount; i++) {
        CGPoint p1 = CGPointMake(self.originalPoint.x-6.0, self.originalPoint.y-markLength*i);
        NSString *mark = [NSString stringWithFormat:@"%.1f ",[[self.yMarkTitles objectAtIndex:i] floatValue]];
        [self drawText:ctx withText:mark atPoint:p1 color:frontLineColor alignment:WSLeft];
    }
    
    //draw x axis mark and title
    for (int i=0; i<[self.xMarkTitles count]; i++) {
        CGPoint p1 = CGPointMake(self.xMarkDistance*(i+1)+self.originalPoint.x, self.originalPoint.y);
        CGPoint p2 = CGPointMake(p1.x, p1.y+4.0);
        [self drawLine:ctx startPoint:p1 endPoint:p2 isDashLine:NO color:frontLineColor];
        NSString *mark = [NSString stringWithFormat:[self.xMarkTitles objectAtIndex:i]];
        [self drawText:ctx withText:mark atPoint:CGPointMake(p1.x-self.xMarkDistance/2, p1.y) color:frontLineColor alignment:WSTop];
    }
    
}

- (void)drawText:(CGContextRef)ctx withText:(NSString*)text atPoint:(CGPoint)p1 color:(UIColor*)color alignment:(WSAliment)alignment
{
    UIGraphicsPushContext(ctx);
    CGContextSetFillColorWithColor(ctx,color.CGColor);
    UIFont *helveticated = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    CGSize size = [text sizeWithFont:helveticated];
    switch (alignment) {
        case WSTop:
            p1 = CGPointMake(p1.x-size.width/2, p1.y);
            break;
        case WSLeft:
            p1 = CGPointMake(p1.x-size.width, p1.y-size.height/2);
            break;
        default:
            break;
    }
    
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
@property (nonatomic) CGFloat xAxisLength;
@property (nonatomic) float maxColumnValue;
@property (nonatomic) float minColumnValue;
@property (nonatomic) CGFloat offsetColumnValue;
@property (nonatomic, strong) CALayer *areaLayer;
@property (nonatomic, strong) WSCoordinateLayer *coordinateLayer;
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic, strong) CALayer *legendLayer;
@property (nonatomic) CGFloat yAxisLength;
@property (nonatomic) int yMarksCount;
@property (nonatomic) CGPoint zeroPoint;

- (float)calculateFinalYAxisTitle:(float) value isMax:(BOOL)max;
- (NSMutableArray*)calculateYAxisValuesWithMin:(CGFloat)min andMax:(CGFloat)max;

@end

@implementation WSColumnChartView

@synthesize coordinateOriginalPoint = _coordinateOriginalPoint;
@synthesize xAxisLength = _xAxisLength;
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
        self.maxColumnValue = CGFLOAT_MAX*(-1.0);
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
        self.yAxisLength = self.frame.size.height - COORDINATE_BOTTOM_GAP - COORDINATE_TOP_GAP;
        self.xAxisLength = self.frame.size.width - 2*COORDINATE_LEFT_GAP;
        self.yMarksCount = Y_MARKS_COUNT;
        self.showZeroValueAtYAxis = NO;
    }
    return self;
}

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    // calculate the propotion, using this propotion to switch the data value from user data to coordinate y axis value 
    NSArray *datas = [arr copy];
    NSDictionary *colorDict = [dict copy];
    int length = [datas count];
    for (int i=0; i<length; i++) {
        NSDictionary *data = [datas objectAtIndex:i];
        [data enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
            if (![key isEqual:self.xAxisKey]) {
                self.maxColumnValue = self.maxColumnValue > [obj floatValue] ? self.maxColumnValue : [obj floatValue];
                self.minColumnValue = self.minColumnValue < [obj floatValue] ? self.minColumnValue : [obj floatValue];
            }
        }];
    }
    
    NSMutableArray *yMarkTitles = [[NSMutableArray alloc] init];
    float minValue, maxValue,offsetValue,propotion,correction;
    minValue = [self calculateFinalYAxisTitle:self.minColumnValue isMax:NO];
    maxValue = [self calculateFinalYAxisTitle:self.maxColumnValue isMax:YES];
    //NSLog(@"min value:%f, max value:%f",minValue,maxValue);
    
    if (self.minColumnValue >= 0.0 && self.maxColumnValue > 0.0) {
        if (self.showZeroValueAtYAxis) {
            minValue = 0.0;
        }
        offsetValue = maxValue - minValue;
        propotion = self.yAxisLength/offsetValue;
        self.zeroPoint = self.coordinateOriginalPoint;
        yMarkTitles = [self calculateYAxisValuesWithMin:minValue andMax:maxValue];
        correction = minValue;
    }else if (self.minColumnValue < 0.0 && self.maxColumnValue >= 0.0)
    {
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
        }else
        {
            self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength*Y_MARKS_COUNT/self.yMarksCount);
            yMarkTitles = [self calculateYAxisValuesWithMin:minValue andMax:markDis*smallMarkCount];
        }
        correction = 0.0;
    }else if (self.minColumnValue < 0.0 && self.maxColumnValue <= 0.0)
    {
        if (self.showZeroValueAtYAxis) {
            maxValue = 0.0;
        }
        offsetValue = maxValue - minValue;
        propotion = self.yAxisLength/offsetValue;
        self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength);
        yMarkTitles = [self calculateYAxisValuesWithMin:minValue andMax:maxValue];
        correction = maxValue;
    }
    
    
    // draw column area
    NSMutableArray *xValues = [[NSMutableArray alloc] init];
    for (int i=0; i<length; i++) {
        NSDictionary *data = [datas objectAtIndex:i];
        [xValues addObject:[data valueForKey:self.xAxisKey]];
        __block int flag = 0.0;
        [data enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
            if (![key isEqual:self.xAxisKey]) {
                WSColumnLayer *layer = [[WSColumnLayer alloc] init];
                layer.color = [colorDict valueForKey:key];
                layer.yValue = ([obj floatValue]-correction)*propotion;
                layer.columnWidth = self.columnWidth;
                //self.columnWidth*flag+self.coordinateOriginalPoint.x+self.columnWidth*2+i*self.columnWidth*(length+1)
                layer.xStartPoint = CGPointMake(self.columnWidth*(flag+i*(length+1)+1)+self.zeroPoint.x, 
                                                self.zeroPoint.y);
                layer.frame = self.bounds;
                [layer setNeedsDisplay];
                [self.areaLayer addSublayer:layer];
                flag++;
            }
        }];
    }
    
    // draw coordinate first
    self.coordinateLayer.yMarkTitles = yMarkTitles;
    self.coordinateLayer.xMarkDistance = self.columnWidth*([[datas objectAtIndex:0] count]+1);
    self.coordinateLayer.xMarkTitles = xValues;
    self.coordinateLayer.zeroPoint = self.zeroPoint;
    self.coordinateLayer.yMarksCount = self.yMarksCount;
    self.coordinateLayer.yAxisLength = self.yAxisLength;
    self.coordinateLayer.xAxisLength = self.xAxisLength;
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
    
    [self.layer addSublayer:self.coordinateLayer];
    [self.layer addSublayer:self.titleLayer];
    [self.layer addSublayer:self.legendLayer];
    [self.layer addSublayer:self.areaLayer];
}

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
