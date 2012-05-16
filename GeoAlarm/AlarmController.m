//
//  AlarmController.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-24.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "AlarmController.h"
#import <AudioToolbox/AudioServices.h>

@implementation AlarmController

@synthesize secondDebugText, locationManager, regionToMonitor, alarmRadius, destinationLocation;

- (void)viewDidLoad
{
	NSLog(@"viewDidLoad with radius: %i %f %f",alarmRadius,destinationLocation.coordinate.latitude, destinationLocation.coordinate.longitude);
	secondDebugText.text = @"";
	
	[[self locationManager] setDesiredAccuracy:kCLLocationAccuracyBest];
	[[self locationManager] setDistanceFilter:kCLDistanceFilterNone];
	
	coord = CLLocationCoordinate2DMake(destinationLocation.coordinate.latitude, destinationLocation.coordinate.longitude);
	regionToMonitor = [[CLRegion alloc] initCircularRegionWithCenter:coord radius:alarmRadius identifier:@"secondDestination"];
	[[self locationManager] startMonitoringForRegion:regionToMonitor];
	
	[[self locationManager] startUpdatingLocation];
	
	CLLocation * loc = [[self locationManager] location];
	NSString * str = [NSString stringWithFormat:@"2nd locationManager started, lat: %f, long: %f", loc.coordinate.latitude, loc.coordinate.longitude];
	[self setTextViewText:str];
	[self sendNotification:str];
	
    [super viewDidLoad];
}

- (void)viewDidUnload
{
	[self setSecondDebugText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	locationManager = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[self locationManager] stopMonitoringForRegion:regionToMonitor];
	regionToMonitor = nil;
	locationManager = nil;
}

- (CLLocationManager *)locationManager 
{
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
	
	return locationManager;
}




#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	//CLLocation * destinationLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
	CLLocationDistance meters = [newLocation distanceFromLocation:destinationLocation];
	[self setTextViewText:[NSString stringWithFormat:@"didUpdateLocation %i m", (int)meters]];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	[self setTextViewText:[NSString stringWithFormat:@"didEnterRegion %@",region.identifier]];
	[self sendNotification:[NSString stringWithFormat:@"didEnterRegion %@",region.identifier]];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	[self setTextViewText:[NSString stringWithFormat:@"didExitRegion %@",region.identifier]];
	[self sendNotification:[NSString stringWithFormat:@"didExitRegion %@",region.identifier]];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
	[self setTextViewText:[NSString stringWithFormat:@"didStartMonitoringForRegion %@",region.identifier]];
	[self sendNotification:[NSString stringWithFormat:@"didStartMonitoringForRegion %@",region.identifier]];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
	[self setTextViewText:[NSString stringWithFormat:@"monitoringDidFailForRegion:withError %@",error]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[self setTextViewText:[NSString stringWithFormat:@"didFailWithError %@",error]];
}

- (void)setTextViewText:(NSString *)text
{
	secondDebugText.text = [NSString stringWithFormat:@"%@\n%@", secondDebugText.text, text];
	NSLog(@"%@",text);
}

- (void)sendNotification:(NSString *)text
{
	UILocalNotification * localNotif = [[UILocalNotification alloc] init];
	if (localNotif == nil)
		return;
	
	localNotif.alertBody = [NSString stringWithFormat:@"%@",text];
	localNotif.alertAction = @"GeoAlarm alertAction";
	
	localNotif.soundName = UILocalNotificationDefaultSoundName;	
	[[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
}









- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


@end
