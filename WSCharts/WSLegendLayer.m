//
//  WSLegendLayer.m
//  WSCharts
//
//  Created by han pyanfield on 12-2-29.
//  Copyright (c) 2012年 pyanfield. All rights reserved.
//

#import "WSLegendLayer.h"
#import <QuartzCore/QuartzCore.h>

@implementation WSLegendLayer
@synthesize color = _color;
@synthesize title = _title;
@synthesize titleStartPoint = _titleStartPoint, rectStartPoint = _rectStartPoint;
@synthesize font = _font;

- (id)initWithColor:(UIColor *)color andTitle:(NSString *)title
{
    self = [super init];
    if (self != nil) {
        self.color = color;
        self.title = title;
        self.titleStartPoint = CGPointMake(20.0, 0.0);
        self.rectStartPoint = CGPointMake(0.0, 4.0);
        self.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
        CGSize size = [self.title sizeWithFont:self.font];
        self.bounds = CGRectMake(0.0, 0.0, size.width+self.titleStartPoint.x, size.height);
        self.anchorPoint = CGPointMake(0.0, 0.0);
        CGPathRef path = CGPathCreateWithRect(CGRectMake(self.rectStartPoint.x,self.rectStartPoint.y, 15.0, 15.0), NULL);
        self.path = path;
        self.fillColor = self.color.CGColor;
        CFRelease(path);
	}
	return self;
}
/*
 Draw the legend title.
 */
- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    UIGraphicsPushContext(ctx);
    [self.title drawAtPoint:self.titleStartPoint withFont:self.font];
    UIGraphicsPopContext();
}

@end