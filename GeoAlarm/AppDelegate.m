//
//  AppDelegate.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-18.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "TestFlight.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [TestFlight takeOff:@"0ae9f68014a88c667ae05168224d4fe7_NTc4MTEyMDEyLTAyLTA5IDA5OjM0OjMzLjExMzc4NA"];
	dataManager = [[PersistentDataManager alloc] init];
	UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
	if (localNotification) 
	{
		application.applicationIconBadgeNumber = 0;
        [application cancelLocalNotification:localNotification];
        [application cancelAllLocalNotifications];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"stopAlarmOnIncommingNotification" object: nil userInfo: nil];
    }
	else 
	{
		NSLog(@"Became active without receiving local notification");
	}
	
	// Add the view controller's view to the window and display.
    //[self.window addSubview:viewController.view];
    //[self.window makeKeyAndVisible];
	
	// Override point for customization after application launch.
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	application.applicationIconBadgeNumber = 0;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"stopAlarmOnIncommingNotification" object: nil userInfo: nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"didEnterBackground" object: nil userInfo: nil];
	
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
	//NSLog(@"applicationWillEnterForeground");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"willEnterForeground" object: nil userInfo: nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	//NSLog(@"applicationDidBecomeActive::UIApplicationStateActive");
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
	NSLog(@"AppDelegate:applicationWillTerminate");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillTerminate" object: nil userInfo: nil];
}

-(PersistentDataManager *)dataManagerInstance
{
	return dataManager;
}

@end
