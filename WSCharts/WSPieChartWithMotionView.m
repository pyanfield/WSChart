//
//  CNPieChartView.m
//  ConciseNote
//
//  Created by han pyanfield on 12-1-18.
//  Copyright (c) 2012年 pyanfield. All rights reserved.
//

#import "WSPieChartWithMotionView.h"
#import <QuartzCore/QuartzCore.h>

#define OPEN_GAP 15.0
#define INDICATOR_RADIUS 120.0
#define INDICATOR_LENGTH 50.0
#define INDICATOR_H_LENGTH 70.0

static float pieRadius = 150.0;

// create the sector path
static CGMutablePathRef CreatePiePathWithCenter(CGPoint center, CGPoint startPoint,CGFloat startAngle, CGFloat angle,CGAffineTransform *transform)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, transform, center.x, center.y);
    CGPathAddLineToPoint(path, transform,startPoint.x,startPoint.y);
    CGPathAddRelativeArc(path, transform, center.x, center.y, pieRadius, startAngle, angle);
    CGPathCloseSubpath(path);
    return path;
}


#pragma mark - WSPieData

@interface WSPieData : NSObject 

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint openedPoint;
@property (nonatomic) CGPoint indicatorPoint;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) BOOL isOpened;
@property (nonatomic) float percent;
@property (nonatomic) int number;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) CALayer *layer;
@property (nonatomic) CGMutablePathRef path;

@end

@implementation WSPieData

@synthesize startPoint = _startPoint;
@synthesize color = _color;
@synthesize percent = _percent;
@synthesize number = _number;
@synthesize name = _name;
@synthesize indicatorPoint = _indicatorPoint;
@synthesize openedPoint = _openedPoint;
@synthesize isOpened = _isOpened;
@synthesize startAngle = _startAngle;
@synthesize layer = _layer;
@synthesize path = _path;

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.layer = [[CALayer alloc] init];
        self.layer.delegate = self;
    }
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    //NSLog(@"draw the layer %f,%f",self.startPoint.x,self.layer.position.x);
    
    CGPoint c = self.layer.position;
    CGMutablePathRef path = CreatePiePathWithCenter(c, self.startPoint, self.startAngle, 2.0*M_PI*self.percent, NULL);   
    CGContextBeginPath(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    CGContextFillPath(ctx);
//    CGContextSetStrokeColorWithColor(ctx, self.color.CGColor);
//    CGContextSetLineWidth(ctx, 2.0);
//    CGContextStrokePath(ctx);
    self.path = path;
    //TODO: should release the 'path'
    //CFRelease(path);
    //CGPathRelease(path);

}

@end

#pragma mark - WSPieChartWithMotionView

@interface WSPieChartWithMotionView()

@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) NSMutableArray *pies;
@property (nonatomic, strong) NSMutableArray *percents;
@property (nonatomic) int currentPressedNum;
@property (nonatomic) BOOL isOpened;
@property (nonatomic, strong) CALayer *pieAreaLayer;


- (CGPoint)calculateOpenedPoint:(int)i withRadius:(float)radius isHalfAngle:(BOOL)isHalf;
//- (CGMutablePathRef)createPiePathWithCenter:(CGPoint)c fromStartPoint:(CGPoint)sp startAngle:(CGFloat)sa withAngle:(CGFloat)pa transform:(CGAffineTransform)t;
- (void)closeAllPieDataIsOpenedAsNO:(int)openedPieNum;
- (void)createIndicators:(int)num;
//- (void)createShadow:(BOOL)opened openedPieNum:(int)i;
- (void)openAnimation:(int)openedPieNum;

@end

@implementation WSPieChartWithMotionView
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
    NSMutableArray* _names = [[NSMutableArray alloc] init];
    NSMutableArray* _startPoints = [[NSMutableArray alloc] init];
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
    CGPoint startArcPoint = CGPointMake(self.center.x,self.center.y);
    NSValue *startArcPointValue = [NSValue valueWithCGPoint:startArcPoint];
    [_startPoints addObject:startArcPointValue];
    float startAngle = -M_PI/2.0f;
    [_startAngles addObject:[NSNumber numberWithFloat:startAngle]];
    for (int i=0; i<length-1; i++) {
        [_startPoints addObject:[NSValue valueWithCGPoint:[self calculateOpenedPoint:i withRadius:pieRadius isHalfAngle:NO]]];

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
        pie.startPoint = [[_startPoints objectAtIndex:i] CGPointValue];
        pie.indicatorPoint = [[_indicatorPoints objectAtIndex:i] CGPointValue];
        pie.openedPoint = [[_openedPoints objectAtIndex:i] CGPointValue];
        pie.number = [[values objectAtIndex:i] floatValue];
        pie.startAngle = [[_startAngles objectAtIndex:i] floatValue];
        pie.isOpened = NO;
        [self.pies addObject:pie];
    }
    
    //[self displayPieChart];
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
//    [self.paths removeAllObjects];
//    
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
//    
//    //set the shadow for pie chart
//    //[self createShadow:self.isOpened openedPieNum:self.currentPressedNum];
//    UIColor *shadowColor = [UIColor colorWithWhite:.5f alpha:.5f];
//    CGContextSetShadowWithColor(context, CGSizeMake(5.0f, 3.0f), 7.0f, [shadowColor CGColor]);
//    CGContextBeginTransparencyLayer (context, NULL);
//    
//    CGPoint center = self.center;
//    int length = [self.pies count];
//    for (int i=0; i<length; i++) {
//        WSPieData *pie = [self.pies objectAtIndex:i];
//        CGAffineTransform transform =  CGAffineTransformMakeTranslation(0.0, 0.0);
//        if (pie.isOpened) {
//            transform = CGAffineTransformMakeTranslation(pie.openedPoint.x-self.center.x,pie.openedPoint.y-self.center.y);
//        }
//        CGMutablePathRef path = [self createPiePathWithCenter:center 
//                                               fromStartPoint:pie.startPoint 
//                                                   startAngle:pie.startAngle 
//                                                    withAngle:2.0*M_PI*pie.percent 
//                                                    transform:transform];
//        [pie.color setFill];
//        //[[UIColor grayColor] setStroke];
//        CGContextAddPath(context, path);
//        CGContextSetLineWidth(context, 1.0);
//        CGContextDrawPath(context,kCGPathFill);//kCGPathFillStroke//kCGPathStroke
//        CGContextClip(context);
//        [self.paths addObject:(__bridge id)path];
//        CGPathRelease(path);
//    }
//    
//    if (self.showIndicator) {
//        [self createIndicators:self.currentPressedNum];
//    }
//    CGContextEndTransparencyLayer(context);
    CGContextRestoreGState(context);
}

- (void)layoutSubviews
{
    NSLog(@"WSPieChartWithMotionView - layoutSubviews");
    int length = [self.pies count];
    for (int i=0; i<length; i++) {
        WSPieData *pie = [self.pies objectAtIndex:i];
        pie.layer.anchorPoint = CGPointMake(0.5, 0.5);
        pie.layer.frame = self.frame;
        [pie.layer setNeedsDisplay];
        [self.pieAreaLayer addSublayer:pie.layer];
    }
}
#pragma mark - Private Methods
- (void)openAnimation:(int)openedPieNum
{
    WSPieData *pie = [self.pies objectAtIndex:openedPieNum];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, pie.layer.position.x, pie.layer.position.y);
    CGPathAddLineToPoint(path, NULL, pie.openedPoint.x, pie.openedPoint.y);
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	animation.path = path;
	animation.duration = 0.5f;
    animation.autoreverses = NO;
	[pie.layer addAnimation:animation forKey:@"open"];
    CGPathRelease(path);
}
//create the shadow just as the API CGContextBeginTransparencyLayer and CGContextEndTransparencyLayer
//- (void)createShadow:(BOOL)opened openedPieNum:(int)i
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//
//    UIColor *shadowColor = [UIColor colorWithWhite:.8f alpha:.5f];
//    CGContextSetShadowWithColor(context, CGSizeMake(5.0f, 3.0f), 7.0f, [shadowColor CGColor]);
//    
//    /*when the pie is opened. draw two sectors. one is opened. another one is the rest part of the circle.
//     if the pie is opened. just draw a circle.
//     */
//    if (opened) {
//        //draw opened sector shadow
//        WSPieData *pie = [self.pies objectAtIndex:i];
//        CGAffineTransform transform =  CGAffineTransformMakeTranslation(pie.openedPoint.x-self.center.x,pie.openedPoint.y-self.center.y);
//        CGMutablePathRef sector = [self createPiePathWithCenter:self.center 
//                                                 fromStartPoint:pie.startPoint 
//                                                     startAngle:pie.startAngle 
//                                                      withAngle:2.0*M_PI*pie.percent 
//                                                      transform:transform];
//        CGContextAddPath(context, sector);
//        CGPathRelease(sector);
//        CGPoint startPoint = CGPointMake(self.center.x,self.center.y);
//        if (i != ([self.pies count]-1)) {
//            startPoint = ((WSPieData*)[self.pies objectAtIndex:i+1]).startPoint;
//        }
//        CGAffineTransform transform2 =  CGAffineTransformMakeTranslation(0.0, 0.0);
//        CGMutablePathRef sector2 = [self createPiePathWithCenter:self.center 
//                                                  fromStartPoint:startPoint 
//                                                      startAngle:pie.startAngle+2.0*M_PI*pie.percent
//                                                       withAngle:2.0*M_PI*(1.0f-pie.percent)
//                                                       transform:transform2];
//        CGContextAddPath(context, sector2);
//        CGPathRelease(sector2);
//    }else
//    {
//        //draw the circle path
//        CGMutablePathRef path = CGPathCreateMutable();
//        CGPathAddEllipseInRect(path, NULL, CGRectMake(self.center.x-pieRadius, self.center.y-pieRadius, 2.0*pieRadius, 2.0*pieRadius));
//        CGContextAddPath(context, path);
//        CGPathRelease(path);
//    }
//    
//    CGContextDrawPath(context, kCGPathFill);
//    CGContextRestoreGState(context);
//}

//// create the sector path
//- (CGMutablePathRef)createPiePathWithCenter:(CGPoint)c fromStartPoint:(CGPoint)sp startAngle:(CGFloat)sa withAngle:(CGFloat)pa transform:(CGAffineTransform)t
//{
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathMoveToPoint(path, &t, c.x, c.y);
//    CGPathAddLineToPoint(path, &t,sp.x,sp.y);
//    CGPathAddRelativeArc(path, &t, c.x, c.y, pieRadius, sa, pa);
//    //CGPathAddLineToPoint(path, &t, c.x, c.y);
//    CGPathCloseSubpath(path);
//    return path;
//}
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
    CGPoint p3 = p2;
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
    
//    for (int i=0; i < [self.pies count]; i++) {
//        CGMutablePathRef path = (__bridge CGMutablePathRef)[self.paths objectAtIndex:i];
//        WSPieData *pie = [self.pies objectAtIndex:i];
//        if (CGPathContainsPoint(path, nil, point, nil)) {
//            if (self.openEnabled) {
//                pie.isOpened = !pie.isOpened;
//                self.isOpened = pie.isOpened?YES:NO;
//                [self closeAllPieDataIsOpenedAsNO:i];
//            }
//            self.currentPressedNum = i;
//            [self setNeedsDisplay];
//        }
//    }
    
    for (int i=0; i<[self.pies count]; i++) {
        WSPieData *pie = [self.pies objectAtIndex:i];

        if (CGPathContainsPoint(pie.path, nil, point, nil))
        {
            NSLog(@"touched - %d",i);
            if (self.openEnabled) {
                [self openAnimation:i];
                pie.isOpened = !pie.isOpened;
                self.isOpened = pie.isOpened?YES:NO;
                [self closeAllPieDataIsOpenedAsNO:i];
            }
        }
    }
}


@end