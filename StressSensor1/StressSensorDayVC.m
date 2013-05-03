//
//  StressSensorDayVC.m
//  StressSensor1
//
//  Created by David Dreher on 18.04.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import "StressSensorDayVC.h"
#import "MinuteStress.h"
#import "DayStress.h"
#import "StressSensorPopoverTextVC.h"

@interface StressSensorDayVC ()
{
    NSMutableArray *plotData;
    NSPredicate *todayPredicate;
    NSMutableArray *heartData;
    NSMutableArray *datesData;
    NSMutableArray *skinData;
    
    NSTimeInterval oneDay;
    NSTimeInterval xMin;
    NSTimeInterval xMax;
    
    NSUInteger yMinPS;
    NSUInteger yMaxPS;
    NSUInteger yMin;
    NSUInteger yMax;
    NSUInteger yminorIncrement;
    NSUInteger ymajorIncrement;
    
    NSUInteger y2MinPS;
    NSUInteger y2MaxPS;
    NSUInteger y2Min;
    NSUInteger y2Max;
    NSUInteger y2minorIncrement;
    NSUInteger y2majorIncrement;
    
    BOOL firstTableRun;
    
    DayStress *currentDayStress;
    StressSensorTVCellText *prototypeNoteCell;

    


}

@end

@implementation StressSensorDayVC
{
    __weak UIPopoverController *connectPopover;
    __weak UIPopoverController *notePopover;
    __weak StressSensorPopoverTextVC *notePopover2;

}
@synthesize managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    NSLog(@"loaded");
    [super viewDidLoad];
    
    StressSensorAppDelegate *appDelegate = (StressSensorAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    _tableView.delegate=self;
    _tableView.dataSource = self;
    _tableView.layer.cornerRadius = 10.0f;
    firstTableRun=YES;
    _mainPlotView.layer.cornerRadius = 10.0f;
    
    
    oneDay = 24*60*60;
    xMin = 0.0f;
    xMax = oneDay + 0.5*60*60;

    yMinPS=0;
    yMaxPS=220;
    yMin=5;
    yMax=200;
    yminorIncrement = 5;
    ymajorIncrement = 25;
    
    y2MinPS=0;
    y2MaxPS=880;
    y2Min=10;
    y2Max=800;
    y2minorIncrement = 10;
    y2majorIncrement = 100;

    [self setPlotData];
    [self setupCurrentDayStress];
    //[self setupPrototypeNoteCell];
    //prototypeNoteCell = [self pro]

	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnect) name:@"didConnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnect) name:@"didDisconnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOnReceiving) name:@"didReceived" object:nil];
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.connectButton setTitle:@"Connecting" forState:UIControlStateSelected];
    
    [self adjustNoteTextView];
    [self initPlot];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didConnect
{
    self.connectButton.selected=FALSE;
    self.connectButton.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
    [self.connectButton setTitle:@"Connected" forState:UIControlStateNormal];
    [self.spinner stopAnimating];


    
}

- (void)didDisconnect
{
    self.connectButton.selected=FALSE;
    self.connectButton.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.spinner stopAnimating];


}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"notePopover"])
    {
        if (notePopover)
        {
            [notePopover dismissPopoverAnimated:YES];
            return NO;
        }
        else
        {
            return YES;
        }

    }
    else
        return YES;
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"notePopover"])
    {
        notePopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        notePopover.delegate=self;
        notePopover2 = (StressSensorPopoverTextVC*)segue.destinationViewController;
        notePopover2.noteDelegate=self;
        NSLog(@"notes:%@",currentDayStress.notes);
        notePopover2.currentNotes = currentDayStress.notes;
        
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"dismissed");
        

}

- (void)setPlotData
{
    _fetchedResultsController = nil;
    
    NSDate *today=[NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
    [components setHour:0];
    [components setMinute:0];
    NSDate *startDate = [calendar dateFromComponents:components];
    [components setHour:23];
    [components setMinute:59];
    NSDate *endDate = [calendar dateFromComponents:components];
    
    todayPredicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startDate, endDate];
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    

}

#pragma mark -  Core Data management
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
     */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MinuteStress" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Sort using the timeStamp property..
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setPredicate:todayPredicate];
	
    // Use the sectionIdentifier property to group into sections.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
		
	return _fetchedResultsController;
}




#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    //NSLog(@"datapoints: %lu",(unsigned long)[[_fetchedResultsController fetchedObjects] count]);
    return [[_fetchedResultsController fetchedObjects] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    //MinuteStress *currentMinuteStress = [_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathWithIndex:index]];
    MinuteStress *currentMinuteStress = [[_fetchedResultsController fetchedObjects] objectAtIndex:index];
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
        {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:currentMinuteStress.date ];
            NSNumber *timeInSeconds= [NSNumber numberWithInteger:components.hour*60*60+components.minute*60+components.second];
            return timeInSeconds;
            break;
        }
            
        case CPTScatterPlotFieldY:
        {
            if ([(NSString*)plot.identifier isEqualToString:@"HR"])
            {
                return currentMinuteStress.heartRate;
            }
            
            if ([(NSString*)plot.identifier isEqualToString:@"SR"])
            {
                return currentMinuteStress.skinResp;
            }           
            
            break;
        }
    }
    return [NSDecimalNumber zero];}


#pragma mark - Chart behavior
-(void)initPlot
{
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    NSLog(@"done");
}

-(void)configureHost
{
    self.hostView =_plotView;
    self.hostView.allowPinchScaling = NO;
    //self.hostView.backgroundColor = [UIColor clearColor];
    //[self.view addSubview:self.hostView];
}

-(void)configureGraph
{
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = @"Today's Stress";
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:55.0f];
    [graph.plotAreaFrame setPaddingBottom:55.0f];
    // 5 - Enable user interactions for plot space
    //CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    //plotSpace.allowsUserInteraction = NO;
    
    graph.cornerRadius=10.0f;
}

-(void)configurePlots
{
    
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpaceHR = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpaceHR.allowsUserInteraction = NO;
    
    CPTXYPlotSpace *plotSpaceSR = [[CPTXYPlotSpace alloc] init];
    plotSpaceSR.allowsUserInteraction = NO;

    // 2 - Create the two plots
    CPTScatterPlot *heartRatePlot = [[CPTScatterPlot alloc] init];
    heartRatePlot.dataSource = self;
    heartRatePlot.identifier = @"HR";
    
    CPTScatterPlot *skinResponsePlot = [[CPTScatterPlot alloc] init];
    skinResponsePlot.dataSource = self;
    skinResponsePlot.identifier = @"SR";
    
    //aaplPlot.identifier = CPDTickerSymbolAAPL;
    CPTColor *heartRateColor = [CPTColor redColor];
    [graph addPlot:heartRatePlot toPlotSpace:plotSpaceHR];
    
    CPTColor *skinResponseColor = [CPTColor blueColor];
    [graph addPlot:skinResponsePlot toPlotSpace:plotSpaceSR];
    
    
    // 3 - Set up plot space
    
    
    [plotSpaceHR scaleToFitPlots:[NSArray arrayWithObjects:heartRatePlot, nil]];
    [plotSpaceSR scaleToFitPlots:[NSArray arrayWithObjects:skinResponsePlot, nil]];
    

    CPTPlotRange *xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpaceHR.xRange = xRange;
    plotSpaceSR.xRange = xRange;

    CPTPlotRange *yRangeHR = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(yMinPS) length:CPTDecimalFromInt(yMaxPS)];
    plotSpaceHR.yRange = yRangeHR;
    
    CPTPlotRange *yRangeSR = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(y2MinPS) length:CPTDecimalFromInt(y2MaxPS)];
    plotSpaceSR.yRange = yRangeSR;    
    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *heartRateLineStyle = [heartRatePlot.dataLineStyle mutableCopy];
    heartRateLineStyle.lineWidth = 2.5;
    heartRateLineStyle.lineColor = heartRateColor;
    heartRatePlot.dataLineStyle = heartRateLineStyle;
    CPTMutableLineStyle *heartRateSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    heartRateSymbolLineStyle.lineColor = heartRateColor;
    //CPTPlotSymbol *ekgSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    //ekgSymbol.fill = [CPTFill fillWithColor:ekgColor];
    //ekgSymbol.lineStyle = ekgSymbolLineStyle;
    //ekgSymbol.size = CGSizeMake(6.0f, 6.0f);
    //ekgPlot.plotSymbol = ekgSymbol;
    
    CPTMutableLineStyle *skinRespLineStyle = [skinResponsePlot.dataLineStyle mutableCopy];
    skinRespLineStyle.lineWidth = 2.5;
    skinRespLineStyle.lineColor = skinResponseColor;
    skinResponsePlot.dataLineStyle = skinRespLineStyle;
    CPTMutableLineStyle *skinRespSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    skinRespSymbolLineStyle.lineColor = skinResponseColor;

    
    [graph addPlotSpace:plotSpaceSR];
    
}

-(void)configureAxes
{    
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    CPTXYPlotSpace *plotSpaceHR = (CPTXYPlotSpace *) [self.hostView.hostedGraph plotSpaceAtIndex:0];
    CPTXYPlotSpace *plotSpaceSR = (CPTXYPlotSpace *) [self.hostView.hostedGraph plotSpaceAtIndex:1];
    
        
    // 3 - Configure x-axis
    //CPTXYPlotSpace *plotSpaceHR = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    CPTXYAxis *x = axisSet.xAxis;
    x.coordinate = CPTCoordinateX;
    //x.title = @"Hours";
    //x.titleTextStyle = axisTitleStyle;
    //x.titleOffset = 20.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 7.0f;
    x.minorTickLineStyle = axisLineStyle;
    x.minorTickLength = 5.0f;
    x.tickDirection = CPTSignNegative;
    
    x.majorIntervalLength = [[NSDecimalNumber decimalNumberWithString:@"1*60*60"] decimalValue];
    CPTPlotRange *xAxisRange=plotSpaceHR.xRange;
    x.minorTicksPerInterval = 4;
    x.visibleRange=xAxisRange;
    x.orthogonalCoordinateDecimal=CPTDecimalFromString(@"0");
    
    NSMutableSet *xMajorLocations = [NSMutableSet set];
    
    x.labelRotation=M_PI/4;
    NSArray *customTickLocations = [NSArray arrayWithObjects:   [NSDecimalNumber numberWithInt:3*60*60],
                                                                [NSDecimalNumber numberWithInt:6*60*60],
                                                                [NSDecimalNumber numberWithInt:9*60*60],
                                                                [NSDecimalNumber numberWithInt:12*60*60],
                                                                [NSDecimalNumber numberWithInt:15*60*60],
                                                                [NSDecimalNumber numberWithInt:18*60*60],
                                                                [NSDecimalNumber numberWithInt:21*60*60],
                                                                [NSDecimalNumber numberWithInt:24*60*60],nil];
    NSArray *xAxisLabels = [NSArray arrayWithObjects:@"3 AM", @"6 AM", @"9 AM", @"12PM", @"3 PM",@"6 PM",@"9 PM", @"12 AM", nil];
    NSUInteger labelLocation = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    for (NSNumber *tickLocation in customTickLocations)
    {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset = x.labelOffset + x.majorTickLength;
        newLabel.rotation = M_PI/4;
        [customLabels addObject:newLabel];
        [xMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:[tickLocation decimalValue]]];
    }
    x.axisLabels =  [NSSet setWithArray:customLabels];
    x.majorTickLocations=xMajorLocations;
    
    
    

    
    // 4 - Configure y-axis
    CPTXYAxis *y = axisSet.yAxis;
    y.coordinate = CPTCoordinateY;
    y.title = @"Heart Rate";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -50.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 25.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");;
    
    
    
    for (NSInteger j = yMin; j <= yMax; j += yminorIncrement)
    {
        NSUInteger mod = j % ymajorIncrement;
        if (mod == 0)
        {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label)
            {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        }
        else
        {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
    
    
    
    
    
    // 5 - Adding second y-axis
    CPTXYAxis *y2 = (CPTXYAxis *)[[CPTXYAxis alloc] initWithFrame:CGRectZero];
    y2.plotSpace = plotSpaceSR;
    y2.coordinate = CPTCoordinateY;
    y2.title = @"Skin Response";
    y2.titleTextStyle = axisTitleStyle;
    y2.titleOffset = -50.0f;
    y2.axisLineStyle = axisLineStyle;
    y2.majorGridLineStyle = nil;
    y2.labelingPolicy = CPTAxisLabelingPolicyNone;
    y2.labelTextStyle = axisTextStyle;
    y2.labelOffset = 25.0f;
    y2.majorTickLineStyle = axisLineStyle;
    y2.majorTickLength = 4.0f;
    y2.minorTickLength = 2.0f;
    y2.tickDirection = CPTSignPositive;
    
    NSMutableSet *y2Labels = [NSMutableSet set];
    NSMutableSet *y2MajorLocations = [NSMutableSet set];
    NSMutableSet *y2MinorLocations = [NSMutableSet set];
    y2.orthogonalCoordinateDecimal = CPTDecimalFromFloat(24*60*60);
    
    
    for (NSInteger j = y2Min; j <= y2Max; j += y2minorIncrement)
    {
        NSUInteger mod = j % y2majorIncrement;
        if (mod == 0)
        {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y2.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y2.majorTickLength - y2.labelOffset;
            if (label)
            {
                [y2Labels addObject:label];
            }
            [y2MajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        }
        else
        {
            [y2MinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y2.axisLabels = y2Labels;
    y2.majorTickLocations = y2MajorLocations;
    y2.minorTickLocations = y2MinorLocations;

        
    self.hostView.hostedGraph.axisSet.axes = [NSArray arrayWithObjects:x, y, y2, nil];
}


#pragma mark - Buttons

- (IBAction)refreshButtonAction:(id)sender
{
    self.refreshButtonOutlet.backgroundColor=[UIColor whiteColor];
    self.refreshButtonOutlet.selected=TRUE;
    
    [self refreshOnReceiving];
    
    self.refreshButtonOutlet.selected=FALSE;
    self.refreshButtonOutlet.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
    
}

- (IBAction)connectButtonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldConnect" object:sender];
    self.connectButton.backgroundColor=[UIColor whiteColor];
    self.connectButton.selected=TRUE;
    [self.spinner startAnimating];
}

- (IBAction)editButton:(id)sender
{
    [self performSegueWithIdentifier:@"notePopover" sender:sender];
}

- (void)refreshOnReceiving
{
    [self setupCurrentDayStress];
    [_tableView reloadData];
    [self setPlotData];
    [self initPlot];

}



#pragma mark - TableView delegate methods


- (CGFloat)tableView:(UITableView  *)tableView heightForRowAtIndexPath:(NSIndexPath  *)indexPath {
    
    int height;
    if (indexPath.row == 2)
    {
        UIFont * FontSize = [UIFont systemFontOfSize:17.0];
        CGSize textSize = [currentDayStress.notes sizeWithFont:FontSize constrainedToSize:CGSizeMake(320, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        
        return textSize.height+45;
    
    }
    else
    {
        height = 45;
    }
    
    return (CGFloat)height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
        {
            StressSensorTVCellAverages *cell = (StressSensorTVCellAverages*) [_tableView dequeueReusableCellWithIdentifier:@"averages" forIndexPath:indexPath];
            cell.leftLabel.text = @"Average Heartrate";
            cell.rightLabel.text = [NSString stringWithFormat:@"%.1f",[currentDayStress.avgHeartRate floatValue]];
            return cell;
            break;
        }
        case 1:
        {
            StressSensorTVCellAverages *cell = (StressSensorTVCellAverages*) [_tableView dequeueReusableCellWithIdentifier:@"averages" forIndexPath:indexPath];
            cell.leftLabel.text = @"Average Skin Response";
            cell.rightLabel.text = [NSString stringWithFormat:@"%.1f",[currentDayStress.avgSkinResp floatValue]];
            return cell;
            break;
        }
        case 2:
        {
            StressSensorTVCellText *cell = (StressSensorTVCellText*) [_tableView dequeueReusableCellWithIdentifier:@"notes" forIndexPath:indexPath];
            cell.titleLabel.text = @"Notes";
            cell.myTableView = tableView;
            cell.textView.delegate = self;
            cell.textView.text = currentDayStress.notes;
                        
            
            return cell;
            break;
        }
            
        default:
        {
            UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"averages" forIndexPath:indexPath];
            return cell;

            break;
        }
    }
    
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)adjustNoteTextView
{
    StressSensorTVCellText *cell = (StressSensorTVCellText*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    CGRect frame = cell.textView.frame;
    frame.size.height = cell.textView.contentSize.height;
    cell.textView.frame = frame;

}

- (void)setupCurrentDayStress
{
    NSDate *today=[NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
    [components setHour:0];
    [components setMinute:0];
    NSDate *startDate = [calendar dateFromComponents:components];
    [components setHour:23];
    [components setMinute:59];
    NSDate *endDate = [calendar dateFromComponents:components];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startDate, endDate];
    [fetchRequest setPredicate:dayPredicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DayStress" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    NSError *error = nil;
    NSUInteger count = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    
    if (count==0)
    {
        NSEntityDescription *daystressEntity = [NSEntityDescription entityForName:@"DayStress" inManagedObjectContext:managedObjectContext];

        currentDayStress = (DayStress*)[[NSManagedObject alloc] initWithEntity:daystressEntity insertIntoManagedObjectContext:nil];
        
        //DayStressadd.date = [NSDate date];
        currentDayStress.avgHeartRate = [NSNumber numberWithDouble:0];
        currentDayStress.avgSkinResp = [NSNumber numberWithDouble:0];
        currentDayStress.dataPoints = [NSNumber numberWithInt:0];
        currentDayStress.notes =@"No data available";
        
        
    }
    else if (count==1)
    {
        NSError *error2 = nil;
        NSArray * results = [managedObjectContext executeFetchRequest:fetchRequest error:&error2];
        if (error2)
        {
            NSLog(@"Unresolved error %@, %@", error2, [error2 userInfo]);
            abort();
        }
        currentDayStress = [results objectAtIndex:0];
    }
    
    NSLog(@"average Heart: %@",currentDayStress.avgHeartRate );
}

- (void)saveNotes:(NSString *)notes
{
    if (notePopover)
    {
        [notePopover dismissPopoverAnimated:YES];
        notePopover2=nil;
        
        currentDayStress.notes=notes;
        
        StressSensorAppDelegate *appDelegate = (StressSensorAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate saveContext];
        
        [_tableView reloadData];
        [_tableView beginUpdates];
        [_tableView endUpdates];
        [self adjustNoteTextView];

        
    }

    NSLog(@"Save");
}





@end


