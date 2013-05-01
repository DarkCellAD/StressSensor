//
//  StressSensorTestData.m
//  StressSensor1
//
//  Created by David Dreher on 19.04.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import "StressSensorTestData.h"

@interface StressSensorTestData ()
{
    NSMutableArray* dataArray;
    NSMutableArray* trimmedDataArray;
    NSNumber* min;
    NSNumber* max;
    BOOL firstElement;
}

@end

@implementation StressSensorTestData

static StressSensorTestData* _sharedStore = nil;

//Creating a shared Store method and overwriting alloc and init to prevent multipe instances of this class
+(StressSensorTestData*)sharedStore
{
    @synchronized([StressSensorTestData class]) //to make sure no duplets can be created via multi threading
    {
        if (!_sharedStore)
            [[self alloc] init];
        
        return _sharedStore;
    }
    return nil;
}

+(id)alloc
{
    @synchronized([StressSensorTestData class])
    {
        NSAssert(_sharedStore==nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedStore = [super alloc];
        return _sharedStore;
    }
    return nil;
}

-(id)init
{
    self = [super init];
    if (self !=nil)
    {
        //initialization
        dataArray = [[NSMutableArray alloc] init];
        trimmedDataArray = [[NSMutableArray alloc]init];
        firstElement=YES;
        
    }
    return self;
}

-(NSMutableArray*)getDataArray
{
    //NSLog(@"Hello");
    return dataArray;
}
-(NSNumber*)getMax
{
    return max;
}
-(NSNumber*)getMin
{
    return min;
}

@end
