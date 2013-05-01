//
//  StressSensorConnectButton.m
//  StressSensor1
//
//  Created by David Dreher on 18.04.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import "StressSensorConnectButton.h"

@implementation StressSensorConnectButton

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"Coder");
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;

    [self configureButton];
    return self;
}


- (void)configureButton
{
    self.layer.cornerRadius = 10.0f;
    [self setTitleColor:[UIColor scrollViewTexturedBackgroundColor] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
