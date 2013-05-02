//
//  MonthStress.h
//  StressSensor1
//
//  Created by David Dreher on 02.05.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DayStress;

@interface MonthStress : NSManagedObject

@property (nonatomic, retain) NSNumber * avgHeartRate;
@property (nonatomic, retain) NSNumber * avgSkinResp;
@property (nonatomic, retain) NSNumber * dataPoints;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSSet *days;
@end

@interface MonthStress (CoreDataGeneratedAccessors)

- (void)addDaysObject:(DayStress *)value;
- (void)removeDaysObject:(DayStress *)value;
- (void)addDays:(NSSet *)values;
- (void)removeDays:(NSSet *)values;

@end
