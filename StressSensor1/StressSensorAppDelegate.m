//
//  StressSensorAppDelegate.m
//  StressSensor1
//
//  Created by David Dreher on 15.04.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import "StressSensorAppDelegate.h"
#import "MinuteStress.h"
#import "DayStress.h"
#import "MonthStress.h"


@implementation StressSensorAppDelegate
{
    BOOL databaseExisting;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    databaseExisting=NO;
    [self managedObjectContext];
    
    bleShield = [[BLE alloc] init];
    [bleShield controlSetup:1];
    bleShield.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BLEShieldScan) name:@"shouldConnect" object:nil];
        
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}





#pragma mark - Bluetooth Core delegate methods
-(void) bleDidReceiveData:(unsigned char *) data length:(int) length
{
    NSLog(@"receiving ....");
    
    //NSLog(@"Length: %d", length);
    
    // parse data, all commands are in 3-byte
    UInt16 BPM;
    UInt16 SRR;
    
    for (int i = 0; i < length; i+=3)
    {
        //NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
        if (data[i] == 0x0A)
        {
            BPM = data[i+2] | data[i+1] << 8;
            //NSLog(@"Heart: %hu",BPM);
        }
        else if (data[i] == 0x0B)
        {
            
            SRR = data[i+2] | data[i+1] << 8;
            //NSLog(@"Skin: %hu",SRR);
        }
    }
    

    

    
//    NSData *d = [NSData dataWithBytes:data length:length];
//    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",s);
//    NSArray *dataInput = [s componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    
//    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
//    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
//    NSNumber *heartRate = [f numberFromString:[dataInput objectAtIndex:0] ];
//    NSNumber *skinResp = [f numberFromString:[dataInput objectAtIndex:1] ];
    NSNumber *heartRate = [NSNumber numberWithUnsignedShort:BPM] ;
    NSNumber *skinResp = [NSNumber numberWithUnsignedShort:SRR];
    NSLog(@"heart: %@     skin: %@",heartRate, skinResp);
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    MinuteStress *newMinuteStress = [NSEntityDescription insertNewObjectForEntityForName:@"MinuteStress" inManagedObjectContext:context];
    newMinuteStress.date = [NSDate date];
    newMinuteStress.heartRate = heartRate;
    newMinuteStress.skinResp = skinResp;
    
    
    // Looking for Day entity
    DayStress *DayStressadd=nil;
    NSDate *today=[NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
    [components setHour:0];
    [components setMinute:0];
    NSDate *startDate = [calendar dateFromComponents:components];
    [components setHour:23];
    [components setMinute:59];
    NSDate *endDate = [calendar dateFromComponents:components];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startDate, endDate];
    [fetchRequest setPredicate:todayPredicate];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DayStress" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
    
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    
    
    
    if (count==0)
    {
        DayStressadd = [NSEntityDescription insertNewObjectForEntityForName:@"DayStress" inManagedObjectContext:context];
        DayStressadd.date = [NSDate date];
        DayStressadd.avgHeartRate = heartRate;
        DayStressadd.avgSkinResp = skinResp;
        DayStressadd.dataPoints = [NSNumber numberWithInt:1];
        
        newMinuteStress.day = DayStressadd;
        NSMutableSet *minutes = [DayStressadd mutableSetValueForKey:@"minutes"];
        [minutes addObject:newMinuteStress];
        
    }
    else if (count==1)
    {
        NSError *error2 = nil;
        NSArray * results = [context executeFetchRequest:fetchRequest error:&error2];
        if (error2)
        {
            NSLog(@"Unresolved error %@, %@", error2, [error2 userInfo]);
            abort();
        }
        DayStressadd = [results objectAtIndex:0];
        double newHR = [heartRate doubleValue];
        double newSR = [skinResp doubleValue];
        double oldAvgHR = [DayStressadd.avgHeartRate doubleValue];
        double oldAvgSR = [DayStressadd.avgSkinResp doubleValue];
        NSInteger oldDatapoints = [DayStressadd.dataPoints integerValue];
        
        DayStressadd.avgHeartRate = [NSNumber numberWithDouble:((oldAvgHR*(double)oldDatapoints+newHR)/((double)oldDatapoints+1))];
        DayStressadd.avgSkinResp = [NSNumber numberWithDouble:((oldAvgSR*(double)oldDatapoints+newSR)/((double)oldDatapoints+1))];
        DayStressadd.dataPoints = [NSNumber numberWithInteger:(oldDatapoints +1)];
        
        newMinuteStress.day = DayStressadd;
        NSMutableSet *minutes = [DayStressadd mutableSetValueForKey:@"minutes"];
        [minutes addObject:newMinuteStress];

    }
    else
    {
        if (error)
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    }
    
    //Looking for month entity
    components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
    [components setHour:0];
    [components setMinute:0];
    [components setDay:1];
    startDate = [calendar dateFromComponents:components];
    [components setHour:23];
    [components setMinute:59];
    // set last of month
    [components setMonth:[components month]+1];
    [components setDay:0];
    endDate = [calendar dateFromComponents:components];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    todayPredicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startDate, endDate];
    [fetchRequest setPredicate:todayPredicate];
	entity = [NSEntityDescription entityForName:@"MonthStress" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
    
    
    error = nil;
    count = [context countForFetchRequest:fetchRequest error:&error];
    
    
    
    if (count==0)
    {
        MonthStress *MonthStressAdd = [NSEntityDescription insertNewObjectForEntityForName:@"MonthStress" inManagedObjectContext:context];
        MonthStressAdd.date = [NSDate date];
        MonthStressAdd.avgHeartRate = DayStressadd.avgHeartRate;
        MonthStressAdd.avgSkinResp = DayStressadd.avgSkinResp;
        MonthStressAdd.dataPoints = [NSNumber numberWithInt:1];
        
        DayStressadd.month = MonthStressAdd;
        NSMutableSet *days = [MonthStressAdd mutableSetValueForKey:@"days"];
        [days addObject:DayStressadd];
        
    }
    else if (count==1)
    {
        NSError *error2 = nil;
        NSArray * results = [context executeFetchRequest:fetchRequest error:&error2];
        if (error2)
        {
            NSLog(@"Unresolved error %@, %@", error2, [error2 userInfo]);
            abort();
        }
        MonthStress *MonthStressAdd = [results objectAtIndex:0];
        double newHR = [DayStressadd.avgHeartRate doubleValue];
        double newSR = [DayStressadd.avgSkinResp doubleValue];
        double oldAvgHR = [MonthStressAdd.avgHeartRate doubleValue];
        double oldAvgSR = [MonthStressAdd.avgSkinResp doubleValue];
        NSInteger oldDatapoints = [MonthStressAdd.dataPoints integerValue];
        
        MonthStressAdd.avgHeartRate = [NSNumber numberWithDouble:((oldAvgHR*(double)oldDatapoints+newHR)/((double)oldDatapoints+1))];
        MonthStressAdd.avgSkinResp = [NSNumber numberWithDouble:((oldAvgSR*(double)oldDatapoints+newSR)/((double)oldDatapoints+1))];
        MonthStressAdd.dataPoints = [NSNumber numberWithInteger:(oldDatapoints +1)];
        
        DayStressadd.month = MonthStressAdd;
        NSMutableSet *days = [MonthStressAdd mutableSetValueForKey:@"days"];
        [days addObject:DayStressadd];
        
    }
    else
    {
        if (error)
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }

    

    [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceived" object:self];
    [self saveContext];
     

}

- (void) bleDidDisconnect
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didDisconnect" object:self];
}

-(void) bleDidConnect
{
    NSLog(@"didConnect called");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didConnect" object:self];
}


-(void)BLEShieldScan
{
    NSLog(@"Scan");
    if (bleShield.activePeripheral)
        if(bleShield.activePeripheral.isConnected)
        {
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
            return;
        }
    
    if (bleShield.peripherals)
        bleShield.peripherals = nil;
    
    [bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
}

-(void) connectionTimer:(NSTimer *)timer
{
    if(bleShield.peripherals.count > 0)
    {
        [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:0]];
    }
    else
    {
        [self bleDidDisconnect];
    }
}


-(void) bleDidUpdateRSSI:(NSNumber *)rssi
{
   NSLog(@"RSSI: %@", rssi.stringValue);
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StressDatabase" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.

 - (NSPersistentStoreCoordinator *)persistentStoreCoordinator
 {
     if (_persistentStoreCoordinator != nil) {
         return _persistentStoreCoordinator;
     }
     
     NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Stress.sqlite"];
     
     NSError *error = nil;
     _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
     if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
         
         
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
     }
     
     return _persistentStoreCoordinator;
 }
 



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}




@end
