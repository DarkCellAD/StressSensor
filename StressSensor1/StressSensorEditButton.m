//
//  StressSensorEditButton.m
//  StressSensor1
//
//  Created by David Dreher on 03.05.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import "StressSensorEditButton.h"

@implementation StressSensorEditButton

-(id)initWithCoder:(NSCoder *)aDecoder
{
    //NSLog(@"Coder");
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self configureButton];
    return self;
}


- (void)configureButton
{
    self.layer.cornerRadius = 10.0f;
    self.backgroundColor = [UIColor lightGrayColor];
    [self setTitleColor:[UIColor scrollViewTexturedBackgroundColor] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}


- (void)selectButton
{
    
}
- (void)deselectButton
{
    self.selected=FALSE;
    self.backgroundColor=[UIColor lightGrayColor];
    
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
