//
//  StressDatapoint.h
//  StressSensor1
//
//  Created by David Dreher on 18.04.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StressDatapoint : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * heartrate;
@property (nonatomic, retain) NSNumber * skinResist;

@end
