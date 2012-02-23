//
//  WSColumnChartView.h
//  WSCharts
//
//  Created by han pyanfield on 12-2-21.
//  Copyright (c) 2012年 pyanfield. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSColumnChartView : UIView

- (void)chartData:(NSMutableArray*)datas;

@end



@interface WSColumnItem:NSObject

@property (nonatomic) CGFloat yValue;
@property (nonatomic, strong) NSString *xValue;
@property (nonatomic, strong) NSString *title;

- (void)initColumnItem:(NSString*)title xValue:(NSString*)x yValue:(CGFloat)y;

@end