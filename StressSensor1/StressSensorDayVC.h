//
//  StressSensorDayVC.h
//  StressSensor1
//
//  Created by David Dreher on 18.04.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StressSensorConnectButton.h"
#import "StressSensorTVCellText.h"
#import "StressSensorTVCellAverages.h"

@interface StressSensorDayVC : UIViewController <UIPopoverControllerDelegate, CPTPlotDataSource, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>


@property (strong, nonatomic) IBOutlet CPTGraphHostingView *plotView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *mainPlotView;

@property (strong, nonatomic) IBOutlet StressSensorConnectButton *connectButton;
@property (strong, nonatomic) IBOutlet StressSensorConnectButton *refreshButtonOutlet;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)refreshButtonAction:(id)sender;
- (IBAction)connectButtonAction:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) CPTGraphHostingView *hostView;





@end
