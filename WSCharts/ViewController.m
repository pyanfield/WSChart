//
//  ViewController.m
//  WSCharts
//
//  Created by han pyanfield on 12-2-2.
//  Copyright (c) 2012年 pyanfield. All rights reserved.
//

#import "ViewController.h"
#import "WSPieChartView.h"
#import "WSPieChartWithMotionView.h"
#import "WSColumnChartView.h"

@interface ViewController()

//@property (nonatomic, strong) NSMutableDictionary *pieData;
//@property (nonatomic, strong) NSMutableDictionary *pieData2;
//@property (nonatomic, strong) WSPieChartWithMotionView *pieChart;

@property (nonatomic, strong) WSColumnChartView *columnChart;
@property (nonatomic) BOOL flag;

@end

@implementation ViewController

//@synthesize pieData,pieData2,pieChart;
@synthesize columnChart;
@synthesize flag;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    /*
    // demo data for WSPieChartWithMotionView
    pieData = [[NSMutableDictionary alloc] init];
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    pieData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSNumber alloc] initWithFloat:20],@"test1",[[NSNumber alloc] initWithFloat:34],@"test2",[[NSNumber alloc] initWithFloat:55],@"test3",[[NSNumber alloc] initWithFloat:12],@"test4",[[NSNumber alloc] initWithFloat:78],@"test5",[[NSNumber alloc] initWithFloat:110],@"test6",nil];
    colors = [[NSMutableArray alloc] initWithObjects:[UIColor purpleColor],[UIColor blueColor],[UIColor greenColor],[UIColor redColor],[UIColor yellowColor],[UIColor brownColor], nil]; 
    
    pieChart = [[WSPieChartWithMotionView alloc] initWithFrame:CGRectMake(10.0, 10.0, 500.0, 500.0)];
    pieChart.data = pieData;
    pieChart.colors = colors;
    pieChart.touchEnabled = YES;
    //pieChart.showIndicator = YES;
    pieChart.openEnabled = YES;
    pieChart.showShadow = YES;
    pieChart.hasLegends = YES;
    pieChart.backgroundColor = [UIColor blackColor];
    [self.view addSubview:pieChart];
    
    pieData2 = [[NSMutableDictionary alloc] init];
    pieData2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSNumber alloc] initWithFloat:15],@"test5",[[NSNumber alloc] initWithFloat:80],@"test3",[[NSNumber alloc] initWithFloat:5],@"test2",[[NSNumber alloc] initWithFloat:5],@"test1",[[NSNumber alloc] initWithFloat:5],@"test4",[[NSNumber alloc] initWithFloat:5],@"test6",nil];
     */
    /*
    // demo data for WSPieChartView
    WSPieChartView *pieChart = [[WSPieChartView alloc] initWithFrame:CGRectMake(10.0, 10.0, 500.0, 500.0)];
    pieChart.data = pieData;
    pieChart.colors = colors;
    pieChart.touchEnabled = YES;
    pieChart.showIndicator = YES;
    //pieChart.openEnabled = YES;
    [self.view addSubview:pieChart];
     */
    
    // demo data for WSColumnChartView
    columnChart = [[WSColumnChartView alloc] initWithFrame:CGRectMake(10.0, 10.0, 600.0, 400.0)];
    [self.view addSubview:columnChart];
}

- (IBAction)switchData:(id)sender {
    //flag?[pieChart switchData:pieData]:[pieChart switchData:pieData2];
    flag = !flag;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


@end
