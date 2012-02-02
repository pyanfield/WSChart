//
//  CNPieChartView.h
//  ConciseNote
//
//  Created by han pyanfield on 12-1-18.
//  Copyright (c) 2012年 pyanfield. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSPieChartView : UIView

@property (nonatomic) BOOL touchEnabled;
@property (nonatomic) BOOL showIndicator;
@property (nonatomic) BOOL openEnabled;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSMutableArray *colors;

@end
