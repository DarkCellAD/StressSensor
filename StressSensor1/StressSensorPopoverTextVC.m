//
//  StressSensorPopoverTextVC.m
//  StressSensor1
//
//  Created by David Dreher on 02.05.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import "StressSensorPopoverTextVC.h"

@interface StressSensorPopoverTextVC ()

@end

@implementation StressSensorPopoverTextVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _noteView.layer.cornerRadius = 10.0f;
    	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    _noteView.text = _currentNotes;
    NSLog(@"%@",_currentNotes);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonAction:(id)sender
{
    NSLog(@"should save");
    if([_noteDelegate respondsToSelector:@selector(saveNotes:)])
    {
        //send the delegate function with the amount entered by the user
        [_noteDelegate  saveNotes:_noteView.text];
    }
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
