//
//  MinuteStress.h
//  StressSensor1
//
//  Created by David Dreher on 19.04.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MinuteStress : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * skinResp;
@property (nonatomic, retain) NSNumber * heartRate;
@property (nonatomic, retain) NSManagedObject *day;

@end
