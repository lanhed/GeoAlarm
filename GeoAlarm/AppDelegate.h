//
//  AppDelegate.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-18.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PersistentDataManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
	PersistentDataManager * dataManager;
}

@property (strong, nonatomic) UIWindow *window;

-(PersistentDataManager *)dataManagerInstance;

@end
