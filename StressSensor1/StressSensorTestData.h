//
//  StressSensorTestData.h
//  StressSensor1
//
//  Created by David Dreher on 19.04.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StressSensorTestData : NSObject

+(StressSensorTestData*)sharedStore;
-(NSMutableArray*)getDataHeart;
-(NSMutableArray*)getDataGalv;
-(NSNumber*)getMax;
-(NSNumber*)getMin;

@end
