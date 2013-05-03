//
//  StressSensorPopoverTextVC.h
//  StressSensor1
//
//  Created by David Dreher on 02.05.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditNoteDelegate
- (void)saveNotes:(NSString *)notes;
@end

@interface StressSensorPopoverTextVC : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *noteView;
- (IBAction)saveButtonAction:(id)sender;

@property (nonatomic, assign) id noteDelegate;
@property (strong, nonatomic) NSString *currentNotes;

@end
