//
//  DayStress.h
//  StressSensor1
//
//  Created by David Dreher on 19.04.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MinuteStress;

@interface DayStress : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * avgHeartRate;
@property (nonatomic, retain) NSNumber * avgSkinResp;
@property (nonatomic, retain) NSNumber * dataPoints;
@property (nonatomic, retain) NSSet *minutes;
@property (nonatomic, retain) NSManagedObject *month;
@end

@interface DayStress (CoreDataGeneratedAccessors)

- (void)addMinutesObject:(MinuteStress *)value;
- (void)removeMinutesObject:(MinuteStress *)value;
- (void)addMinutes:(NSSet *)values;
- (void)removeMinutes:(NSSet *)values;

@end
