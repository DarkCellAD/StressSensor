//
//  StressSensorTVCellText.h
//  StressSensor1
//
//  Created by David Dreher on 02.05.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StressSensorTVCellText : UITableViewCell <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) UITableView *myTableView;


- (void) setTextViewSize:(UITextView*)textView;
- (CGSize)textViewSize:(UITextView*)textView;

@end
