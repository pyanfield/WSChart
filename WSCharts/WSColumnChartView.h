//
//  WSColumnChartView.h
//  WSCharts
//
//  Created by han pyanfield on 12-2-21.
//  Copyright (c) 2012年 pyanfield. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSColumnChartView : UIView

@property (nonatomic, strong) NSString *xAxisKey;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) CGFloat columnWidth;

- (void)drawChart:(NSArray*)arr withColor:(NSDictionary*)dict;
@end