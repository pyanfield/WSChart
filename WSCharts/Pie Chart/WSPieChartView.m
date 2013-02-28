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

#import "WSPieChartView.h"
#import <QuartzCore/QuartzCore.h>

#define OPEN_GAP 15.0
#define INDICATOR_RADIUS 120.0
#define INDICATOR_LENGTH 50.0
#define INDICATOR_H_LENGTH 70.0

static float pieRadius = 150.0;

#pragma mark - WSPieData

@interface WSPieData : NSObject 

@property (nonatomic) CGPoint openedPoint;
@property (nonatomic) CGPoint indicatorPoint;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) BOOL isOpened;
@property (nonatomic) float percent;
@property (nonatomic) int number;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *name;

@end

@implementation WSPieData

@synthesize color = _color;
@synthesize percent = _percent;
@synthesize number = _number;
@synthesize name = _name;
@synthesize indicatorPoint = _indicatorPoint;
@synthesize openedPoint = _openedPoint;
@synthesize isOpened = _isOpened;
@synthesize startAngle = _startAngle;

@end

#pragma mark - WSPieChartView

@interface WSPieChartView()

@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) NSMutableArray *pies;
@property (nonatomic, strong) NSMutableArray *percents;
@property (nonatomic) int currentPressedNum;
@property (nonatomic) BOOL isOpened;
@property (nonatomic, strong) CALayer *pieAreaLayer;


- (CGPoint)calculateOpenedPoint:(int)i withRadius:(float)radius isHalfAngle:(BOOL)isHalf;
- (CGMutablePathRef)newPiePathWithCenter:(CGPoint)c withRadius:(CGFloat)r startAngle:(CGFloat)sa withAngle:(CGFloat)pa transform:(CGAffineTransform)t;
- (void)closeAllPieDataIsOpenedAsNO:(int)openedPieNum;
- (void)createIndicators:(int)num;
- (void)createShadow:(BOOL)opened openedPieNum:(int)i;

@end

@implementation WSPieChartView
@synthesize paths = _paths;
@synthesize touchEnabled = _touchEnabled;
@synthesize pies = _pies;
@synthesize percents = _percents;
@synthesize data = _data;
@synthesize colors = _colors;
@synthesize openEnabled = _openEnabled;
@synthesize showIndicator = _showIndicator;
@synthesize currentPressedNum = _currentPressedNum;
@synthesize isOpened = _isOpened;
@synthesize pieAreaLayer = _pieAreaLayer;

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _pies = [[NSMutableArray alloc] init];
        _paths = [[NSMutableArray alloc] init];
        _percents = [[NSMutableArray alloc] init];
        self.clearsContextBeforeDrawing = YES;
        _pieAreaLayer = [CALayer layer];
        [self.layer addSublayer:_pieAreaLayer];
        //self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setData:(NSMutableDictionary *)dict
{
    NSMutableArray* _indicatorPoints = [[NSMutableArray alloc] init];
    NSMutableArray* _openedPoints = [[NSMutableArray alloc] init];
    NSMutableArray* _names;
    NSMutableArray* _startAngles = [[NSMutableArray alloc] init];
    
    NSArray *values = [dict allValues];
    NSArray *keys = [dict allKeys];
    float total = 0;
    int length = [values count];
    
    for (int i=0; i<length; i++) {
        total += [[values objectAtIndex:i] floatValue];
    }
    
    for (int i=0; i < length; i++) {
        float percent = [[values objectAtIndex:i] floatValue]/total;
        [_percents addObject:[[NSNumber alloc] initWithFloat:percent]];
    }
    
    //get the labels text
    _names = [[NSMutableArray alloc] initWithArray:keys];
    
    //calculate the startpoints and startAngle
    float startAngle = -M_PI/2.0f;
    [_startAngles addObject:[NSNumber numberWithFloat:startAngle]];
    for (int i=0; i<length-1; i++) {
        startAngle += 2.0*M_PI*[[_percents objectAtIndex:i] floatValue];
        [_startAngles addObject:[NSNumber numberWithFloat:startAngle]];
    }
    
    //calculate the openedpoints and indicator points
    for (int i = 0; i < length; i++) {
        [_openedPoints addObject:[NSValue valueWithCGPoint:[self calculateOpenedPoint:i withRadius:OPEN_GAP isHalfAngle:YES]]];
        [_indicatorPoints addObject:[NSValue valueWithCGPoint:[self calculateOpenedPoint:i withRadius:INDICATOR_RADIUS isHalfAngle:YES]]];
    }
    
    //using the WSPieData to store the datas
    for (int i = 0; i < length; i++) {
        WSPieData *pie = [[WSPieData alloc] init];
        pie.percent = [[_percents objectAtIndex:i] floatValue];
        pie.name = [_names objectAtIndex:i];
        pie.indicatorPoint = [[_indicatorPoints objectAtIndex:i] CGPointValue];
        pie.openedPoint = [[_openedPoints objectAtIndex:i] CGPointValue];
        pie.number = [[values objectAtIndex:i] floatValue];
        pie.startAngle = [[_startAngles objectAtIndex:i] floatValue];
        pie.isOpened = NO;
        [self.pies addObject:pie];
    }
}

- (void)setColors:(NSMutableArray *)colors
{
    for (int i=0; i<[colors count]; i++) {
        WSPieData *pie = [self.pies objectAtIndex:i];
        pie.color = [colors objectAtIndex:i];
    }
}

- (void)setShowIndicator:(BOOL)showIndicator
{
    _showIndicator = showIndicator;
    if (_showIndicator) {
        _openEnabled = NO;
    }
}

- (void)setOpenEnabled:(BOOL)openEnabled
{
    _openEnabled = openEnabled;
    if (_openEnabled) {
        _showIndicator = NO;
    }
}

- (void)setTouchEnabled:(BOOL)touchEnabled
{
    _touchEnabled = touchEnabled;
    if (_touchEnabled) {
        _showIndicator = NO;
        _openEnabled = NO;
    }
}

- (void)drawRect:(CGRect)rect
{
    [self.paths removeAllObjects];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    /*
     TODO: why
     1.why commenting below line. can set background color in method of initWithFrame: as self.backgroundColor = [UIColor whiteColor];
     but the pie chart drawing confused when openedEnabled.
     2. using below code, but can't use self.backgroundColor to set the color.
     */
    CGContextClearRect(context, rect);
    //set the background color of pie chart
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    
    //set the shadow for pie chart
    //[self createShadow:self.isOpened openedPieNum:self.currentPressedNum];
    UIColor *shadowColor = [UIColor colorWithWhite:.5f alpha:.5f];
    CGContextSetShadowWithColor(context, CGSizeMake(5.0f, 3.0f), 7.0f, [shadowColor CGColor]);
    CGContextBeginTransparencyLayer (context, NULL);
    
    CGPoint center = self.center;
    int length = [self.pies count];
    for (int i=0; i<length; i++) {
        WSPieData *pie = [self.pies objectAtIndex:i];
        CGAffineTransform transform =  CGAffineTransformMakeTranslation(0.0, 0.0);
        if (pie.isOpened) {
            transform = CGAffineTransformMakeTranslation(pie.openedPoint.x-self.center.x,pie.openedPoint.y-self.center.y);
        }
        CGMutablePathRef path = [self newPiePathWithCenter:center 
                                                   withRadius:pieRadius 
                                                   startAngle:pie.startAngle 
                                                    withAngle:2.0*M_PI*pie.percent 
                                                    transform:transform];
        [pie.color setFill];
        //[[UIColor grayColor] setStroke];
        CGContextAddPath(context, path);
        CGContextSetLineWidth(context, 1.0);
        CGContextDrawPath(context,kCGPathFill);//kCGPathFillStroke//kCGPathStroke
        CGContextClip(context);
        [self.paths addObject:(__bridge id)path];
        CGPathRelease(path);
    }
    
    if (self.showIndicator) {
        [self createIndicators:self.currentPressedNum];
    }
    CGContextEndTransparencyLayer(context);
    CGContextRestoreGState(context);
}
#pragma mark - Private Methods
//create the shadow just as the API CGContextBeginTransparencyLayer and CGContextEndTransparencyLayer
- (void)createShadow:(BOOL)opened openedPieNum:(int)i
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    UIColor *shadowColor = [UIColor colorWithWhite:.8f alpha:.5f];
    CGContextSetShadowWithColor(context, CGSizeMake(5.0f, 3.0f), 7.0f, [shadowColor CGColor]);
    
    /*when the pie is opened. draw two sectors. one is opened. another one is the rest part of the circle.
     if the pie is opened. just draw a circle.
     */
    if (opened) {
        //draw opened sector shadow
        WSPieData *pie = [self.pies objectAtIndex:i];
        CGAffineTransform transform =  CGAffineTransformMakeTranslation(pie.openedPoint.x-self.center.x,pie.openedPoint.y-self.center.y);
        CGMutablePathRef sector = [self newPiePathWithCenter:self.center 
                                                     withRadius:pieRadius
                                                     startAngle:pie.startAngle 
                                                      withAngle:2.0*M_PI*pie.percent 
                                                      transform:transform];
        CGContextAddPath(context, sector);
        CGPathRelease(sector);
        CGAffineTransform transform2 =  CGAffineTransformMakeTranslation(0.0, 0.0);
        CGMutablePathRef sector2 = [self newPiePathWithCenter:self.center 
                                                      withRadius:pieRadius
                                                      startAngle:pie.startAngle+2.0*M_PI*pie.percent
                                                       withAngle:2.0*M_PI*(1.0f-pie.percent)
                                                       transform:transform2];
        CGContextAddPath(context, sector2);
        CGPathRelease(sector2);
    }else
    {
        //draw the circle path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddEllipseInRect(path, NULL, CGRectMake(self.center.x-pieRadius, self.center.y-pieRadius, 2.0*pieRadius, 2.0*pieRadius));
        CGContextAddPath(context, path);
        CGPathRelease(path);
    }
    
    CGContextDrawPath(context, kCGPathFill);
    CGContextRestoreGState(context);
}

// create the sector path
- (CGMutablePathRef)newPiePathWithCenter:(CGPoint)c withRadius:(CGFloat)r startAngle:(CGFloat)sa withAngle:(CGFloat)pa transform:(CGAffineTransform)t
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, &t, c.x, c.y);
    CGPathAddRelativeArc(path, &t, c.x, c.y, r, sa, pa);
    CGPathCloseSubpath(path);
    return path;
}
// calculate the point should be when you open a pie chart
- (CGPoint)calculateOpenedPoint:(int)i withRadius:(float)radius isHalfAngle:(BOOL)isHalf
{
    float p = 0.0;
    for (int n=0; n<i; n++) {
        p += [[self.percents objectAtIndex:n] floatValue];
    }
    if (isHalf) {
        p += [[self.percents objectAtIndex:i] floatValue]/2.0;
    }else
    {
        p += [[self.percents objectAtIndex:i] floatValue];
    }
    float x = radius*sinf(p*2*M_PI);
    float y = radius*cosf(p*2*M_PI);
    CGPoint point = CGPointMake(self.center.x+x,self.center.y-y);
    return point;
}
// close all pieData's isOpened as NO except the pressed one 
- (void)closeAllPieDataIsOpenedAsNO:(int)openedPieNum
{
    for (int n=0; n<[self.pies count]; n++) {
        if (n!=openedPieNum) {
            WSPieData *pie = [self.pies objectAtIndex:n];
            pie.isOpened = NO;
        }
    }
}

- (void)createIndicators:(int)num
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    WSPieData *pie = [self.pies objectAtIndex:num];
    
    //set font
    UIColor *fontColor = [UIColor colorWithRed:0.5 green:0.0 blue:0.5 alpha:1.0];
    [fontColor set];
    UIFont *helveticated = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    NSString *info = [NSString stringWithFormat:@"%@   %@%.1f",pie.name,@"%",pie.percent*100];
    
    CGPoint p1 = pie.indicatorPoint;
    CGPoint p2 = [self calculateOpenedPoint:num withRadius:(INDICATOR_LENGTH+INDICATOR_RADIUS) isHalfAngle:YES];
    CGPoint p3;
    if (p1.x>self.center.x) {
        p3 = CGPointMake(p2.x+INDICATOR_H_LENGTH, p2.y);
        [info drawAtPoint:CGPointMake(p2.x, p2.y-20.0) withFont:helveticated];
    }else{
        p3 = CGPointMake(p2.x-INDICATOR_H_LENGTH, p2.y);
        [info drawAtPoint:CGPointMake(p3.x, p2.y-20.0) withFont:helveticated];
    }
    
    //draw the line
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(p1.x-1.5,p1.y-1.5, 3.0, 3.0));
    CGPathMoveToPoint(path,NULL, p1.x, p1.y);
    CGPathAddLineToPoint(path, NULL,p2.x,p2.y);
    CGPathMoveToPoint(path, NULL,p2.x,+p2.y);
    CGPathAddLineToPoint(path, NULL,p3.x,p3.y);
    
    UIColor *c = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6f];
    [c setStroke];
    [c setFill];
    
    //add shadow
    UIColor *shadowColor = [UIColor colorWithWhite:.5f alpha:.5f];
    CGContextSetShadowWithColor(context, CGSizeMake(5.0f, 3.0f), 7.0f, [shadowColor CGColor]);
    
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, 2.0);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPathRelease(path);
    
    CGContextRestoreGState(context);
}

#pragma mark - Touch Event 

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.touchEnabled) return;
    UITouch *t = [touches anyObject];
	CGPoint point = [t locationInView:self];
    
    for (int i=0; i < [self.pies count]; i++) {
        CGMutablePathRef path = (__bridge CGMutablePathRef)[self.paths objectAtIndex:i];
        WSPieData *pie = [self.pies objectAtIndex:i];
        if (CGPathContainsPoint(path, nil, point, nil)) {
            if (self.openEnabled) {
                pie.isOpened = !pie.isOpened;
                self.isOpened = pie.isOpened?YES:NO;
                [self closeAllPieDataIsOpenedAsNO:i];
            }
            self.currentPressedNum = i;
            [self setNeedsDisplay];
        }
    }
    
}


@end
