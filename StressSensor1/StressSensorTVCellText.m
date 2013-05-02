//
//  StressSensorTVCellText.m
//  StressSensor1
//
//  Created by David Dreher on 02.05.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import "StressSensorTVCellText.h"

@implementation StressSensorTVCellText

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //_textView.delegate=self;
        _textView.text = @"test";
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// returns the proper height/size for the UITextView based on the string it contains.
// If no string, it assumes a space so that it will always have one line.
- (CGSize)textViewSize:(UITextView*)textView {
    float fudgeFactor = 16.0;
    CGSize tallerSize = CGSizeMake(textView.frame.size.width-fudgeFactor, 9999);
    NSString *testString = @" ";
    if ([textView.text length] > 0) {
        testString = textView.text;
    }
    CGSize stringSize = [testString sizeWithFont:textView.font constrainedToSize:tallerSize lineBreakMode:NSLineBreakByWordWrapping];
    return stringSize;
}

// based on the proper text view size, sets the UITextView's frame
- (void) setTextViewSize:(UITextView*)textView {
    CGSize stringSize = [self textViewSize:textView];
    if (stringSize.height != textView.frame.size.height) {
        [textView setFrame:CGRectMake(textView.frame.origin.x,
                                      textView.frame.origin.y,
                                      textView.frame.size.width,
                                      stringSize.height+10)];  // +10 to allow for the space above the text itself
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
    [self setTextViewSize:textView]; // set proper text view size
    UIView *contentView = textView.superview;
    // (1) the padding above and below the UITextView should each be 6px, so UITextView's
    // height + 12 should equal the height of the UITableViewCell
    // (2) if they are not equal, then update the height of the UITableViewCell
    if ((textView.frame.size.height + 12.0f) != contentView.frame.size.height) {
        [_myTableView beginUpdates];
        [_myTableView endUpdates];
        
        [contentView setFrame:CGRectMake(0,
                                         0,
                                         contentView.frame.size.width,
                                         (textView.frame.size.height+12.0f))];
    }
}


@end
