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
#import "WSLegendLayer.h"
#import "WSGlobalCore.h"
#import "WSChartObject.h"

#define OPEN_GAP 15.0
#define SHADOW_COLOR [UIColor colorWithWhite:.8f alpha:.5f]

static float pieRadius = 150.0;

/* 
 Define the pie's status for tha pie's open and close animation. 
 */
typedef enum{
    Opened,
    OpenOngoing,
    Closed,
    CloseOngoing,
} PieStatus;

/*
 Create the shadow. 
 */
static void CreateShadowWithContext(CGContextRef ctx, BOOL disable)
{
    if (disable) {
        CGContextSetShadowWithColor(ctx, CGSizeMake(5.0f, 3.0f), 7.0f, [SHADOW_COLOR CGColor]);
    }else{
        CGContextSetShadowWithColor(ctx, CGSizeMake(5.0f, 3.0f), 7.0f, NULL);
    }
}


#pragma mark - WSPieData
/*
 Using WSPieItem to store every pie's data.
 */
@interface WSPieItem : NSObject 

@property (nonatomic) CGPoint openedPoint;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) PieStatus pieStatus;
@property (nonatomic) float percent;
@property (nonatomic) CGFloat number;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) CAShapeLayer *layer;

- (void)displayPieLayer;

@end

@implementation WSPieItem

@synthesize color = _color;
@synthesize percent = _percent;
@synthesize number = _number;
@synthesize title = _title;
@synthesize openedPoint = _openedPoint;
@synthesize center = _center;
@synthesize pieStatus = _pieStatus;
@synthesize startAngle = _startAngle;
@synthesize layer = _layer;

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
/*
 Draw the pie sector path in the CAShapeLayer. 
 The "path" property of layer is used for touched event in the WSPieChartWithMotionView.
 */
- (void)displayPieLayer
{
    CGMutablePathRef path = CreatePiePathWithCenter(self.center,pieRadius, self.startAngle, 2.0*M_PI*self.percent, NULL); 
    self.layer.path = path;
    self.layer.fillColor = self.color.CGColor;
    CFRelease(path);
}
/*
 Add a shadow for the layer when the pie's status is not closed. 
 That it can be moved with pie's close and open animation.
 When the status is close, remove the shadow. Using the shadow created by WSPieChartWithMotionView.
 */
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    if (self.pieStatus == (PieStatus)Closed) {
        CreateShadowWithContext(ctx, NO);
        CGContextClearRect(ctx, layer.frame);
    }else
    {
        CreateShadowWithContext(ctx, YES);
        CGMutablePathRef path = CreatePiePathWithCenter(self.center,pieRadius, self.startAngle, 2.0*M_PI*self.percent, NULL); 
        CGContextAddPath(ctx, path);
        CGContextDrawPath(ctx,kCGPathFill);
        CFRelease(path);
    }
    
    CGContextRestoreGState(ctx);
}
@end

#pragma mark - WSPieChartWithMotionView

@interface WSPieChartWithMotionView()

@property (nonatomic, strong) NSMutableArray *legends;
@property (nonatomic, strong) NSMutableArray *pies;
@property (nonatomic, strong) NSMutableArray *percents;
@property (nonatomic, strong) CALayer *pieAreaLayer;
@property (nonatomic, strong) CALayer *legendAreaLayer;
@property (nonatomic) BOOL updateFlag;

- (CGPoint)calculateOpenedPoint:(int)i withRadius:(float)radius;
- (NSMutableArray*)calculateStartAngles;
- (void)transformPies;
- (void)closeOtherPiesExcept:(int)openedPieNum;
- (void)closeAllPiesImmediately;
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
@synthesize openEnabled = _openEnabled;
@synthesize pieAreaLayer = _pieAreaLayer;
@synthesize showShadow = _showShadow;
@synthesize legendAreaLayer = _legendAreaLayer;
@synthesize hasLegends = _hasLegends;
@synthesize updateFlag = _updateFlag;

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _pies = [[NSMutableArray alloc] init];
        _legends = [[NSMutableArray alloc] init];
        _percents = [[NSMutableArray alloc] init];
        _pieAreaLayer = [CALayer layer];
        _updateFlag = NO;
        [self.layer addSublayer:_pieAreaLayer];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - WSBaseChartDelegate

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    // check if this is init chart or update chart data
    if ([self.pies count] != 0 && dict == nil) {
        self.updateFlag = YES;
    }else if([self.pies count] == 0 && dict != nil){
        self.updateFlag = NO;
    }else{
        NSLog(@"Invalide data source!");
    }
    int dataCount = [arr count];
    
    if (self.updateFlag && [self.pies count] != dataCount) {
        //the datas' count should be same as original datas.
        NSLog(@"The new datas' count shoule be same as original datas.");
        return;
    }
    
    float total = 0.0;
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    NSMutableArray *numbers = [[NSMutableArray alloc] init];
    for (int i=0; i<dataCount; i++) {
        WSChartObject *obj = [arr objectAtIndex:i];
        total += obj.pieValue;
        [titles addObject:obj.name];
        [numbers addObject:[NSNumber numberWithFloat:obj.pieValue]];
    }
    if ([self.percents count]>0) {
        [self.percents removeAllObjects];
    }
    for (int i=0; i < dataCount; i++) {
        float percent = [[numbers objectAtIndex:i] floatValue]/total;
        [_percents addObject:[[NSNumber alloc] initWithFloat:percent]];
    }
    NSLog(@">> WSChart: percents %@",self.percents);
    
    if (self.updateFlag) {
        for (int i=0; i<dataCount; i++) {
            WSPieItem *pie = [self.pies objectAtIndex:i];
            NSUInteger index = [titles indexOfObject:(id)pie.title];
            if (index != NSNotFound) {
                pie.number = [[numbers objectAtIndex:index] floatValue];
            }else{
                // the data's name don't match, so return. can't use the transform.
                NSLog(@"The datas' keys don't match with original datas. please make sure keys are matched.");
                return;
            }
        }
        //transform
        [self closeAllPiesImmediately];
        [self transformPies];
    }else{
        NSMutableArray* _startAngles = [self calculateStartAngles];
        NSLog(@">> WSChart: startAngles %@",_startAngles);
        for (int i=0; i<dataCount; i++) {
            WSPieItem *pie = [[WSPieItem alloc] init];
            pie.percent = [[_percents objectAtIndex:i] floatValue];
            pie.title = [titles objectAtIndex:i];
            pie.number = [[numbers objectAtIndex:i] floatValue];
            pie.startAngle = [[_startAngles objectAtIndex:i] floatValue];
            pie.pieStatus = Closed;
            pie.color = [dict valueForKey:pie.title];
            [self.pies addObject:pie];
        }
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
    
    //show legends
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

/*
 Transform the pies according the datas.
 */
- (void)transformPies
{
    NSMutableArray *newStartAngles = [self calculateStartAngles];
    //kernel of transform
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
                });
                progress += 0.02f;
                usleep(5000);
            }
        });
    }
}

/*
 Set all pie items as closed status.Skipping the close animation.
 */
- (void)closeAllPiesImmediately
{
    for (int i=0; i<[self.pies count]; i++) {
        WSPieItem *pie = [self.pies objectAtIndex:i];
        pie.pieStatus = Closed;
        [pie.layer removeAllAnimations];
        pie.layer.position = pie.center;
        [pie.layer setNeedsDisplay];
    }
    //redraw for the shadow.
    [self setNeedsDisplay]; 
}

/*
 Create the shadow for the closed pies.
 */
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
/*
 Create legends for the view.
 */
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
/*
 The animation of open pie.
 */
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
/*
 Close the target pie with animation.
 */
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

/*
 Check other pie,not the touched pie. if its status is "Opened" or "OpenOngoing",need to close it.
 */
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

/*
 Calculate the relative value of opened point.
 */
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

/*
 Calculate the start angle according to percents data.
 */
- (NSMutableArray*)calculateStartAngles
{
    NSMutableArray *angles = [[NSMutableArray alloc] init];
    int length = [self.percents count];
    float startAngle = -M_PI/2.0f;
    [angles addObject:[NSNumber numberWithFloat:startAngle]];
    for (int i=0; i<length-1; i++) {
        startAngle += 2.0*M_PI*[[self.percents objectAtIndex:i] floatValue];
        [angles addObject:[NSNumber numberWithFloat:startAngle]];
    }
    return angles;
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
