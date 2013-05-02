//
//  DayStress.h
//  StressSensor1
//
//  Created by David Dreher on 02.05.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MinuteStress, MonthStress;

@interface DayStress : NSManagedObject

@property (nonatomic, retain) NSNumber * avgHeartRate;
@property (nonatomic, retain) NSNumber * avgSkinResp;
@property (nonatomic, retain) NSNumber * dataPoints;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSSet *minutes;
@property (nonatomic, retain) MonthStress *month;
@end

@interface DayStress (CoreDataGeneratedAccessors)

- (void)addMinutesObject:(MinuteStress *)value;
- (void)removeMinutesObject:(MinuteStress *)value;
- (void)addMinutes:(NSSet *)values;
- (void)removeMinutes:(NSSet *)values;

@end
