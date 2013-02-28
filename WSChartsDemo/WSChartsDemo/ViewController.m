//
//  ViewController.m
//  WSChartsDemo
//
//  Created by Weishuai Han on 2/28/13.
//  Copyright (c) 2013 pyanfield. All rights reserved.
//

#import "ViewController.h"
#import "WSPieChartView.h"
#import "WSPieChartWithMotionView.h"
#import "WSColumnChartView.h"
#import "WSLineChartView.h"
#import "WSAreaChartView.h"
#import "WSScatterChartView.h"
#import "WSChartObject.h"
#import "WSComboChartView.h"
#import "WSBarChartView.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableDictionary *pieData;
@property (nonatomic, strong) NSMutableDictionary *pieData2;
@property (nonatomic, strong) WSPieChartWithMotionView *pieChart;
@property (nonatomic, strong) UIView *chartView;
@property (nonatomic) BOOL flag;

@end

@implementation ViewController
@synthesize switchBtn;
@synthesize tabBar;
@synthesize pieData,pieData2,pieChart;
@synthesize chartView;
@synthesize flag;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [switchBtn setHidden:true];
    self.chartView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:self.chartView atIndex:0];
    self.tabBar.delegate = self;
    self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];
    [self createPieChart];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([[self.chartView subviews] count]>0) {
        for (UIView *v in [self.chartView subviews]) {
            [v removeFromSuperview];
        }
    }
    [switchBtn setHidden:true];
    if([item.title isEqualToString:@"Pie Chart"]) [self createPieChart];
    if([item.title isEqualToString:@"Area Chart"]) [self createAreaChart];
    if([item.title isEqualToString:@"Bar Chart"]) [self createBarChart];
    if([item.title isEqualToString:@"Line Chart"]) [self createLineChart];
    if([item.title isEqualToString:@"Column Chart"]) [self createColumnChart];
    if([item.title isEqualToString:@"Scatter Chart"]) [self createScatterChart];
    if([item.title isEqualToString:@"Combo Chart"]) [self createComboChart];
}


- (void)createPieChart
{
    [switchBtn setHidden:false];
    // demo data for WSPieChartWithMotionView
    pieData = [[NSMutableDictionary alloc] init];
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    pieData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSNumber alloc] initWithFloat:20],@"test1",[[NSNumber alloc] initWithFloat:34],@"test2",[[NSNumber alloc] initWithFloat:55],@"test3",[[NSNumber alloc] initWithFloat:12],@"test4",[[NSNumber alloc] initWithFloat:78],@"test5",[[NSNumber alloc] initWithFloat:110],@"test6",nil];
    colors = [[NSMutableArray alloc] initWithObjects:[UIColor purpleColor],[UIColor blueColor],[UIColor greenColor],[UIColor redColor],[UIColor yellowColor],[UIColor brownColor], nil];
    
    pieChart = [[WSPieChartWithMotionView alloc] initWithFrame:CGRectMake(10.0, 50.0, 600.0, 600.0)];
    pieChart.data = pieData;
    pieChart.colors = colors;
    pieChart.touchEnabled = YES;
    pieChart.openEnabled = YES;
    pieChart.showShadow = YES;
    pieChart.hasLegends = YES;
    pieChart.backgroundColor = [UIColor blackColor];
    [self.chartView addSubview:pieChart];
    
    pieData2 = [[NSMutableDictionary alloc] init];
    pieData2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSNumber alloc] initWithFloat:15],@"test5",[[NSNumber alloc] initWithFloat:80],@"test3",[[NSNumber alloc] initWithFloat:5],@"test2",[[NSNumber alloc] initWithFloat:5],@"test1",[[NSNumber alloc] initWithFloat:5],@"test4",[[NSNumber alloc] initWithFloat:5],@"test6",nil];
}

- (void)createAreaChart
{
    WSAreaChartView *areaChart  = [[WSAreaChartView alloc] initWithFrame:CGRectMake(10.0, 50.0, 800.0, 400.0)];
    NSMutableArray *arr = [self createDemoDatas:30];
    NSDictionary *colorDict = [self createColorDict];
    areaChart.rowWidth = 20.0;
    areaChart.title = @"Pyanfield's Area Chart";
    areaChart.showZeroValueOnYAxis = YES;
    [areaChart drawChart:arr withColor:colorDict];
    areaChart.backgroundColor = [UIColor blackColor];
    [self.chartView addSubview:areaChart];
}

- (void)createBarChart
{
    WSBarChartView *barChart = [[WSBarChartView alloc] initWithFrame:CGRectMake(10.0, 50.0, 600.0, 600.0)];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<3; i++) {
        WSChartObject *lfcObj = [[WSChartObject alloc] init];
        lfcObj.name = @"Liverpool";
        lfcObj.yValue = [NSString stringWithFormat:@"%d",i];
        lfcObj.xValue = [NSNumber numberWithFloat:arc4random() % 500];
        WSChartObject *chObj = [[WSChartObject alloc] init];
        chObj.name = @"Chelsea";
        chObj.yValue = [NSString stringWithFormat:@"%d",i];
        chObj.xValue = [NSNumber numberWithFloat:(int)(arc4random() % 500) - 140];
        WSChartObject *muObj = [[WSChartObject alloc] init];
        muObj.name = @"MU";
        muObj.yValue = [NSString stringWithFormat:@"%d",i];
        muObj.xValue = [NSNumber numberWithFloat:(int)(arc4random() % 300) - 30];
        WSChartObject *mcObj = [[WSChartObject alloc] init];
        mcObj.name = @"ManCity";
        mcObj.yValue = [NSString stringWithFormat:@"%d",i];
        mcObj.xValue = [NSNumber numberWithFloat:(int)(arc4random() % 400) - 150];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:lfcObj,@"Liverpool",
                              muObj,@"MU",
                              chObj,@"Chelsea",
                              mcObj,@"ManCity",nil];
        [arr addObject:data];
    }
    NSDictionary *colorDict = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor redColor],@"Liverpool",
                               [UIColor purpleColor],@"MU",
                               [UIColor greenColor],@"Chelsea",
                               [UIColor orangeColor],@"ManCity", nil];
    barChart.rowHeight = 20.0;
    barChart.rowDistance = 10.0;
    barChart.title = @"Test the Bar Chart";
    barChart.showZeroValueOnYAxis = YES;
    [barChart drawChart:arr withColor:colorDict];
    barChart.backgroundColor = [UIColor blackColor];
    [self.chartView addSubview:barChart];
}

- (void)createColumnChart
{
    WSColumnChartView *columnChart = [[WSColumnChartView alloc] initWithFrame:CGRectMake(10.0, 50.0, 800.0, 400.0)];
    NSMutableArray *arr = [self createDemoDatas:5];
    
    NSDictionary *colorDict = [self createColorDict];
    columnChart.rowWidth = 20.0;
    columnChart.title = @"Test the Column Chart";
    columnChart.showZeroValueOnYAxis = YES;
    [columnChart drawChart:arr withColor:colorDict];
    columnChart.backgroundColor = [UIColor blackColor];
    [self.chartView addSubview:columnChart];
}

- (void)createLineChart
{
    WSLineChartView *lineChart = [[WSLineChartView alloc] initWithFrame:CGRectMake(10.0, 50.0, 800.0, 400.0)];
    NSMutableArray *arr = [self createDemoDatas:30];
    NSDictionary *colorDict = [self createColorDict];
    
    lineChart.xAxisName = @"Year";
    lineChart.rowWidth = 20.0;
    lineChart.title = @"Pyanfield's Line Chart";
    lineChart.showZeroValueOnYAxis = YES;
    [lineChart drawChart:arr withColor:colorDict];
    lineChart.backgroundColor = [UIColor blackColor];
    [self.chartView addSubview:lineChart];
}

- (void)createScatterChart
{
    WSScatterChartView *scatterChart  = [[WSScatterChartView alloc] initWithFrame:CGRectMake(10.0, 50.0, 800.0, 400.0)];
    NSMutableArray *arr = [self createDemoDatas:8];
    NSDictionary *colorDict = [self createColorDict];
    scatterChart.title = @"Pyanfield's Scatter Chart";
    scatterChart.showZeroValueOnYAxis = YES;
    scatterChart.yAxisName = @"Y Axis";
    scatterChart.xAxisName = @"X Axis";
    [scatterChart drawChart:arr withColor:colorDict];
    scatterChart.backgroundColor = [UIColor blackColor];
    [self.chartView addSubview:scatterChart];
}

- (void)createComboChart
{
    WSComboChartView *comboChart = [[WSComboChartView alloc] initWithFrame:CGRectMake(10.0, 50.0, 800.0, 400.0)];
    NSMutableArray *arr = [self createDemoDatas:5];
    NSDictionary *colorDict = [self createColorDict];
    comboChart.rowWidth = 20.0;
    comboChart.rowDistance = 5.0;
    comboChart.title = @"Pyanfield's Combo Chart";
    comboChart.showZeroValueOnYAxis = YES;
    comboChart.lineKeyName = @"Average";
    [comboChart drawChart:arr withColor:colorDict];
    comboChart.backgroundColor = [UIColor blackColor];
    [self.chartView addSubview:comboChart];
}

- (NSMutableArray*)createDemoDatas:(int)count
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<count; i++) {
        WSChartObject *lfcObj = [[WSChartObject alloc] init];
        lfcObj.name = @"Liverpool";
        lfcObj.xValue = [NSString stringWithFormat:@"%d",i];
        lfcObj.yValue = [NSNumber numberWithFloat: arc4random() % 400];
        WSChartObject *chObj = [[WSChartObject alloc] init];
        chObj.name = @"Chelsea";
        chObj.xValue = [NSString stringWithFormat:@"%d",i];
        chObj.yValue = [NSNumber numberWithFloat:(int)(arc4random() % 400) - 140];
        WSChartObject *muObj = [[WSChartObject alloc] init];
        muObj.name = @"MU";
        muObj.xValue = [NSString stringWithFormat:@"%d",i];
        muObj.yValue = [NSNumber numberWithFloat:(int)(arc4random() % 200) - 30];
        WSChartObject *mcObj = [[WSChartObject alloc] init];
        mcObj.name = @"ManCity";
        mcObj.xValue = [NSString stringWithFormat:@"%d",i];
        mcObj.yValue = [NSNumber numberWithFloat:(int)(arc4random() % 100) - 150];
        
        WSChartObject *avgObj = [[WSChartObject alloc] init];
        avgObj.name = @"Average";
        avgObj.xValue = [NSString stringWithFormat:@"%d",i];
        avgObj.yValue = [NSNumber numberWithFloat:([lfcObj.yValue floatValue] + [chObj.yValue floatValue] + [muObj.yValue floatValue] + [muObj.yValue floatValue])/4.0];
        
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:lfcObj,@"Liverpool",
                              muObj,@"MU",
                              chObj,@"Chelsea",
                              mcObj,@"ManCity",
                              avgObj,@"Average",nil];
        [arr addObject:data];
    }
    return arr;
}

- (NSDictionary*)createColorDict
{
    NSDictionary *colorDict = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor redColor],@"Liverpool",
                               [UIColor purpleColor],@"MU",
                               [UIColor greenColor],@"Chelsea",
                               [UIColor orangeColor],@"ManCity",
                               [UIColor blueColor],@"Average", nil];
    return colorDict;
}

- (IBAction)switchData:(id)sender {
    flag?[pieChart switchData:pieData]:[pieChart switchData:pieData2];
    flag = !flag;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)viewDidUnload {
    [self setPieData2:nil];
    [self setPieData:nil];
    [self setPieChart:nil];
    [self setChartView:nil];
    [self setTabBar:nil];
    [self setSwitchBtn:nil];
    [super viewDidUnload];
}


@end
