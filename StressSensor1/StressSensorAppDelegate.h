//
//  StressSensorAppDelegate.h
//  StressSensor1
//
//  Created by David Dreher on 15.04.13.
//  Copyright (c) 2013 edu.ASU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import <AudioToolbox/AudioServices.h>

@interface StressSensorAppDelegate : UIResponder <UIApplicationDelegate, BLEDelegate>
{
    BLE *bleShield;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(void)BLEShieldScan;



@end
