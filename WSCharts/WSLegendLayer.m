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
/*
 Draw the legend title.
 */
- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    //draw the Text to CALayer, or can use CATextLayer 
    UIGraphicsPushContext(ctx);
    UIFont *helveticated = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    CGSize size = [self.title sizeWithFont:helveticated];
    [self.title drawAtPoint:CGPointMake(20.0, 0.0) withFont:helveticated];
    self.bounds = CGRectMake(0.0, 0.0, size.width+20.0, size.height);
    UIGraphicsPopContext();
}

@end