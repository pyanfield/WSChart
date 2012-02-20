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

#import "WSPieChartWithMotionView.h"
#import <QuartzCore/QuartzCore.h>

#define OPEN_GAP 15.0
#define INDICATOR_RADIUS 120.0
#define INDICATOR_LENGTH 50.0
#define INDICATOR_H_LENGTH 70.0
#define SHADOW_COLOR [UIColor colorWithWhite:.8f alpha:.5f]

static float pieRadius = 150.0;

// def the pie's status for the animation
typedef enum{
    Opened,
    OpenOngoing,
    Closed,
    CloseOngoing,
} PieStatus;

// create the sector path
static CGMutablePathRef CreatePiePathWithCenter(CGPoint center, CGFloat radius,CGFloat startAngle, CGFloat angle,CGAffineTransform *transform)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, transform, center.x, center.y);
    CGPathAddRelativeArc(path, transform, center.x, center.y, radius, startAngle, angle);
    CGPathCloseSubpath(path);
    return path;
}
// create shadow for the pie
static void CreateShadowWithContext(CGContextRef ctx, BOOL disable)
{
    if (disable) {
        //UIColor *shadowColor = [UIColor colorWithWhite:.8f alpha:.5f];
        CGContextSetShadowWithColor(ctx, CGSizeMake(5.0f, 3.0f), 7.0f, [SHADOW_COLOR CGColor]);
    }else{
        CGContextSetShadowWithColor(ctx, CGSizeMake(5.0f, 3.0f), 7.0f, NULL);
    }
}


#pragma mark - WSPieData

@interface WSPieItem : NSObject 

@property (nonatomic) CGPoint openedPoint;
@property (nonatomic) CGPoint indicatorPoint;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) PieStatus pieStatus;
@property (nonatomic) float percent;
@property (nonatomic) int number;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) CAShapeLayer *layer;
//@property (nonatomic) CGMutablePathRef path;

- (void)displayPieLayer;

@end

@implementation WSPieItem

@synthesize color = _color;
@synthesize percent = _percent;
@synthesize number = _number;
@synthesize title = _title;
@synthesize indicatorPoint = _indicatorPoint;
@synthesize openedPoint = _openedPoint;
@synthesize center = _center;
@synthesize pieStatus = _pieStatus;
@synthesize startAngle = _startAngle;
@synthesize layer = _layer;
//@synthesize path = _path;

- (id)init
{
    return [super init];
}

- (CAShapeLayer*)layer
{
    if (_layer != nil) {
        return _layer;
    }
    _layer = [CAShapeLayer layer];
    _layer.delegate = self;
    return _layer;
}

- (void)displayPieLayer
{
    //CGPoint c = self.layer.position;
    CGMutablePathRef path = CreatePiePathWithCenter(self.center,pieRadius, self.startAngle, 2.0*M_PI*self.percent, NULL); 
    self.layer.path = path;
    self.layer.fillColor = self.color.CGColor;
    CFRelease(path);
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    if (self.pieStatus == (PieStatus)Closed) {
        CreateShadowWithContext(ctx, NO);
    }else
    {
        CreateShadowWithContext(ctx, YES);
    }
    CGMutablePathRef path = CreatePiePathWithCenter(self.center,pieRadius, self.startAngle, 2.0*M_PI*self.percent, NULL); 
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx,kCGPathFill);
    CFRelease(path);
    CGContextRestoreGState(ctx);
}

- (id <CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
//    if ([event isEqualToString:@"path"]) {
//        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
//        animation.fromValue = [layer valueForKey:event];
//        return animation;
//    }
    return nil;
}
@end


#pragma mark - WSLegendLayer
@interface WSLegendLayer:CAShapeLayer
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *title;
- (id)initWithColor:(UIColor*)color andTitle:(NSString *)title;
@end

@implementation WSLegendLayer
@synthesize color = _color;
@synthesize title = _title;

- (id)initWithColor:(UIColor *)color andTitle:(NSString *)title
{
    self = [super init];
    if (self != nil) {
        self.color = color;
        self.title = title;
        self.bounds = CGRectMake(0.0, 0.0, 70.0, 20.0);
        self.anchorPoint = CGPointMake(0.0, 0.0);
        
        CGPathRef path = CGPathCreateWithRect(CGRectMake(0.0, 4.0, 15.0, 15.0), NULL);
        self.path = path;
        self.fillColor = self.color.CGColor;
        CFRelease(path);
	}
	return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    //draw the Text to CALayer, or can use CATextLayer 
    UIGraphicsPushContext(ctx);
    UIFont *helveticated = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    [self.title drawInRect:CGRectMake(20.0, 0.0, 40.0, 20.0) withFont:helveticated lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    UIGraphicsPopContext();
}

@end
#pragma mark - WSPieChartWithMotionView

@interface WSPieChartWithMotionView()

@property (nonatomic, strong) NSMutableArray *legends;
@property (nonatomic, strong) NSMutableArray *pies;
@property (nonatomic, strong) NSMutableArray *percents;
@property (nonatomic, strong) CALayer *pieAreaLayer;
@property (nonatomic, strong) CALayer *legendAreaLayer;

- (CGPoint)calculateOpenedPoint:(int)i withRadius:(float)radius;
- (void)closeOtherPiesExcept:(int)openedPieNum;
- (void)createShadowForClosedPies;
- (void)openAnimation:(int)openedPieNum;
- (void)closeAnimation:(int)openedPieNum;
- (void)showLegends;

@end

@implementation WSPieChartWithMotionView
@synthesize legends = _legends;
@synthesize touchEnabled = _touchEnabled;
@synthesize pies = _pies;
@synthesize percents = _percents;
@synthesize data = _data;
@synthesize colors = _colors;
@synthesize openEnabled = _openEnabled;
@synthesize showIndicator = _showIndicator;
@synthesize pieAreaLayer = _pieAreaLayer;
@synthesize showShadow = _showShadow;
@synthesize legendAreaLayer = _legendAreaLayer;
@synthesize hasLegends = _hasLegends;

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _pies = [[NSMutableArray alloc] init];
        _legends = [[NSMutableArray alloc] init];
        _percents = [[NSMutableArray alloc] init];
        _pieAreaLayer = [CALayer layer];
        [self.layer addSublayer:_pieAreaLayer];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - WSPieChartWithMotionView's Property
- (void)setData:(NSMutableDictionary *)dict
{
    //NSMutableArray* _indicatorPoints = [[NSMutableArray alloc] init];
    //NSMutableArray* _openedPoints = [[NSMutableArray alloc] init];
    NSMutableArray* _titles = [[NSMutableArray alloc] init];
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
    _titles = [[NSMutableArray alloc] initWithArray:keys];
    
    //calculate the startAngle
    float startAngle = -M_PI/2.0f;
    [_startAngles addObject:[NSNumber numberWithFloat:startAngle]];
    for (int i=0; i<length-1; i++) {
        startAngle += 2.0*M_PI*[[_percents objectAtIndex:i] floatValue];
        [_startAngles addObject:[NSNumber numberWithFloat:startAngle]];
    }
    
    //calculate the openedpoints and indicator points
//    for (int i = 0; i < length; i++) {
//        [_openedPoints addObject:[NSValue valueWithCGPoint:[self calculateOpenedPoint:i withRadius:OPEN_GAP]]];
//        [_indicatorPoints addObject:[NSValue valueWithCGPoint:[self calculateOpenedPoint:i withRadius:INDICATOR_RADIUS]]];
//    }
    
    //using the WSPieData to store the datas
    for (int i = 0; i < length; i++) {
        WSPieItem *pie = [[WSPieItem alloc] init];
        pie.percent = [[_percents objectAtIndex:i] floatValue];
        pie.title = [_titles objectAtIndex:i];
//        pie.indicatorPoint = [[_indicatorPoints objectAtIndex:i] CGPointValue];
//        pie.openedPoint = [[_openedPoints objectAtIndex:i] CGPointValue];
        pie.number = [[values objectAtIndex:i] floatValue];
        pie.startAngle = [[_startAngles objectAtIndex:i] floatValue];
        pie.pieStatus = Closed;
        [self.pies addObject:pie];
    }
    
    //[self displayPieChart];
}

- (void)switchData:(NSMutableDictionary *)dict
{
    NSMutableDictionary *data2 = [dict copy];
    NSArray *values = [data2 allValues];
    NSArray *keys = [data2 allKeys];
    if ([self.pies count] != [values count]) {
        return;
    }
    
    [self.percents removeAllObjects];
    float total = 0;
    int length = [values count];
    for (int i=0; i<length; i++) {
        total += [[values objectAtIndex:i] floatValue];
    }
    for (int i=0; i < length; i++) {
        float percent = [[values objectAtIndex:i] floatValue]/total;
        [self.percents addObject:[[NSNumber alloc] initWithFloat:percent]];
    }
    NSMutableArray *newStartAngles = [[NSMutableArray alloc] init];
    float startAngle = -M_PI/2.0f;
    [newStartAngles addObject:[NSNumber numberWithFloat:startAngle]];
    for (int i=0; i<length-1; i++) {
        startAngle += 2.0*M_PI*[[self.percents objectAtIndex:i] floatValue];
        [newStartAngles addObject:[NSNumber numberWithFloat:startAngle]];
    }
    
    //close all pies before update data
    [self closeOtherPiesExcept:1000];
    
    for (int i=0; i<[self.pies count]; i++) {
        WSPieItem *pie = [self.pies objectAtIndex:i];
        CGFloat offPercent = [[self.percents objectAtIndex:i] floatValue]-pie.percent;
        CGFloat offAngle = [[newStartAngles objectAtIndex:i] floatValue]-pie.startAngle;
        CGPoint rp = [self calculateOpenedPoint:i withRadius:OPEN_GAP];
        pie.openedPoint = CGPointMake(rp.x+pie.center.x, rp.y+pie.center.y);
        
        //transform pie from original data to new data.
        dispatch_queue_t drawQueue = dispatch_queue_create("transform pie", NULL);
        dispatch_async(drawQueue, ^{
            CGFloat progress = 0.0f;
            while (progress <= 1.0f)
            {
                pie.percent +=offPercent*0.02f;
                pie.startAngle +=offAngle*0.02f;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [pie displayPieLayer];
                    //[pie.layer setNeedsDisplay];
                });
                progress += 0.02f;
                if (progress > 1.0f) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[pie.layer setNeedsDisplay];
                        //[self setNeedsDisplay];
                    });
                }
                usleep(5000);
            }
        });
        dispatch_release(drawQueue);
    }
}

- (void)setColors:(NSMutableArray *)colors
{
    for (int i=0; i<[colors count]; i++) {
        WSPieItem *pie = [self.pies objectAtIndex:i];
        pie.color = [colors objectAtIndex:i];
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

- (CALayer*)legendAreaLayer
{
    if (_legendAreaLayer!=nil) {
        return _legendAreaLayer;
    }
    _legendAreaLayer = [[CALayer alloc] init];
    return _legendAreaLayer;
}
#pragma mark - Render UI 

- (void)layoutSubviews
{
    int length = [self.pies count];
    for (int i=0; i<length; i++) {
        WSPieItem *pie = [self.pies objectAtIndex:i];
        pie.layer.anchorPoint = CGPointMake(0.5, 0.5);
        pie.layer.frame = self.frame;
        pie.center = pie.layer.position;
        CGPoint rp = [self calculateOpenedPoint:i withRadius:OPEN_GAP];
        pie.openedPoint = CGPointMake(rp.x+pie.center.x, rp.y+pie.center.y);
        [pie displayPieLayer];
        [self.pieAreaLayer addSublayer:pie.layer];
    }
    
    //test legends
    if (self.hasLegends) {
        [self showLegends];
    }
}
- (void)drawRect:(CGRect)rect
{
    if (self.showShadow) {
        [self createShadowForClosedPies];
    }
}

//create the shadow for the closed pies
- (void)createShadowForClosedPies
{
    UIColor *bgc = self.backgroundColor;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextClearRect(context, self.frame);
    CGContextSetFillColorWithColor(context, bgc.CGColor);
    CGContextFillRect(context, self.frame);
    CreateShadowWithContext(context, YES);
    CGContextBeginTransparencyLayer (context, NULL);
    CGPoint center = CGPointMake(self.center.x+self.frame.origin.x, self.center.y+self.frame.origin.y);
    for (int i=0; i<[self.pies count]; i++) {
        WSPieItem *pie = [self.pies objectAtIndex:i];
        if (pie.pieStatus == (PieStatus)Closed) {
            CGMutablePathRef path = CreatePiePathWithCenter(center, pieRadius, pie.startAngle, pie.percent*2.0*M_PI, NULL);
            CGContextAddPath(context, path);
            CGContextDrawPath(context, kCGPathFill);
            CGPathRelease(path);
        }
    }
    CGContextEndTransparencyLayer(context);
    CGContextRestoreGState(context);
}

- (void)showLegends
{
    int length = [self.pies count];
    for (int i=0; i<length; i++) {
        WSPieItem *pie = [self.pies objectAtIndex:i];
        WSLegendLayer *legend = [[WSLegendLayer alloc] initWithColor:pie.color andTitle:pie.title];
        legend.position = CGPointMake(10.0, 20.0*i+20.0);
        [legend setNeedsDisplay];
        [self.legends addObject:legend];
        
        [self.legendAreaLayer addSublayer:legend];
    }
    
    [self.layer addSublayer:self.legendAreaLayer];
}

#pragma mark - Animation Methods
// open the touched pie
- (void)openAnimation:(int)openedPieNum
{
    WSPieItem *pie = [self.pies objectAtIndex:openedPieNum];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, pie.layer.position.x, pie.layer.position.y);
    CGPathAddLineToPoint(path, NULL, pie.openedPoint.x, pie.openedPoint.y);
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	animation.path = path;
	animation.duration = 0.3f;
    animation.delegate = self;
    [animation setValue:[NSNumber numberWithInt:openedPieNum] forKey:@"openedPieNum"];
    animation.removedOnCompletion = NO;
    //if need to stop at complete position ,must set that position before add animation to the layer.
    pie.layer.position = pie.openedPoint;
	[pie.layer addAnimation:animation forKey:@"open"];
    CGPathRelease(path);
}
// close the target pie
- (void)closeAnimation:(int)openedPieNum
{
    WSPieItem *pie = [self.pies objectAtIndex:openedPieNum];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, pie.layer.position.x, pie.layer.position.y);
    CGPathAddLineToPoint(path, NULL, pie.center.x, pie.center.y);
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	animation.path = path;
	animation.duration = 0.3f;
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    [animation setValue:[NSNumber numberWithInt:openedPieNum] forKey:@"closePieNum"];
    pie.layer.position = pie.center;
	[pie.layer addAnimation:animation forKey:@"close"];
    CGPathRelease(path);
}
- (void)animationDidStart:(CAAnimation *)anim
{
    WSPieItem *pie = [self.pies objectAtIndex:[[anim valueForKey:@"openedPieNum"] intValue]];
    CAShapeLayer *layer = pie.layer;
    //if animation.removeOnCompletion = YES. the [layer animationForKey:@"open"] will return null
    if ([anim isEqual:[layer animationForKey:@"open"]]) {
        //NSLog(@"start > open animation");
        pie.pieStatus = OpenOngoing;
        if (self.showShadow) {
            //redraw the UIView
            [self setNeedsDisplay];
            //redraw the layer of WSPieItem
            [pie.layer setNeedsDisplay];
        }
    }
    
    pie = [self.pies objectAtIndex:[[anim valueForKey:@"closePieNum"] intValue]];
    layer = pie.layer;
    if ([anim isEqual:[layer animationForKey:@"close"]]) {
        //NSLog(@"start > close animation");
        pie.pieStatus = CloseOngoing;
    }
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        WSPieItem *pie = [self.pies objectAtIndex:[[anim valueForKey:@"openedPieNum"] intValue]];
        CAShapeLayer *layer = pie.layer;
        //if animation.removeOnCompletion = YES. the [layer animationForKey:@"open"] will return null
        if ([anim isEqual:[layer animationForKey:@"open"]]) {
            pie.pieStatus = Opened;
            [layer removeAnimationForKey:@"open"];
        }
        
        pie = [self.pies objectAtIndex:[[anim valueForKey:@"closePieNum"] intValue]];
        layer = pie.layer;
        if ([anim isEqual:[layer animationForKey:@"close"]]) {
            pie.pieStatus = Closed;
            if (self.showShadow) {
                [self setNeedsDisplay];
                [pie.layer setNeedsDisplay]; 
            }
            [layer removeAnimationForKey:@"close"];
        }
    }else
    {
        //NSLog(@"removed animation");
    }
}

// check other pie, if its status is opened or openongoing, then need to close it.
- (void)closeOtherPiesExcept:(int)openedPieNum
{
    for (int i=0; i<[self.pies count]; i++) {
        if (i!=openedPieNum) {
            WSPieItem *pie = [self.pies objectAtIndex:i];
            switch (pie.pieStatus) {
                case Opened:
                    [self closeAnimation:i];
                    break;
                case OpenOngoing:
                    [pie.layer removeAllAnimations];
                    [self closeAnimation:i];
                    break;
                case CloseOngoing:
                    break;
                case Closed:
                    break;
                default:
                    break;
            }
        }
    }
}
// calculate the relative value of open point 
- (CGPoint)calculateOpenedPoint:(int)i withRadius:(float)radius
{
    float p = 0.0;
    for (int n=0; n<i; n++) {
        p += [[self.percents objectAtIndex:n] floatValue];
    }
    p += [[self.percents objectAtIndex:i] floatValue]/2.0;
    float x = radius*sinf(p*2*M_PI);
    float y = radius*cosf(p*2*M_PI);
    CGPoint point = CGPointMake(x,-y);
    return point;
}

#pragma mark - Touch Event 
/*
 clicking one
     if [close]         then [open it]
     if [open]          then [close it]
     if [close ongoing] then [stop it][open it]
     if [open ongoing]  then [stop it][close it]
 others
     if [open]          then [close it]
     if [open ongoing]  then [stop][close it]
     if [close]         then ignore
     if [close ongoing] then ignore
 */

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.touchEnabled) return;
    UITouch *t = [touches anyObject];
	CGPoint point = [t locationInView:self];
    CGPoint pieAreaPoint = [self.layer convertPoint:point toLayer:self.pieAreaLayer];
    CGPoint legendAreaPoint = [self.layer convertPoint:point toLayer:self.legendAreaLayer];
    for (int i=0; i<[self.pies count]; i++) {
        WSPieItem *pie = [self.pies objectAtIndex:i];
        CGPoint p = [self.pieAreaLayer convertPoint:pieAreaPoint toLayer:pie.layer];
        BOOL containedLegend = NO;
        if (self.hasLegends) {
            WSLegendLayer *legend = [self.legends objectAtIndex:i];
            CGPoint l = [self.legendAreaLayer convertPoint:legendAreaPoint toLayer:legend];
            containedLegend = CGPathContainsPoint(legend.path, nil, l, nil);
        }
        
        if (CGPathContainsPoint(pie.layer.path, nil, p, nil) || containedLegend)
        {
            if (self.openEnabled) {
                switch (pie.pieStatus) {
                    case Closed:
                        [self openAnimation:i];
                        break;
                    case Opened:
                        [self closeAnimation:i];
                        break;
                    case CloseOngoing:
                        [pie.layer removeAllAnimations];
                        [self openAnimation:i];
                        break;
                    case OpenOngoing:
                        [pie.layer removeAllAnimations];
                        [self closeAnimation:i];
                        break;
                    default:
                        break;
                }
            
            }
            [self closeOtherPiesExcept:i];
        }
    }
}

@end
