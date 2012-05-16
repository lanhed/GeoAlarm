//
//  BackgroundLocationController.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-24.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "BackgroundLocationController.h"
#import <AudioToolbox/AudioServices.h>

@implementation BackgroundLocationController

@synthesize destinationLocation, alarmRadius;

- (id)initWithDestination:(CLLocation *)destination radius:(NSInteger)radius
{
	self.destinationLocation = destination;
	self.alarmRadius = radius;
	
	NSLog(@"BackgroundLocationController, %f %f, %i m", destinationLocation.coordinate.latitude, destinationLocation.coordinate.longitude, radius);
	
	if (locationManager == nil)
	{
		locationManager = [[CLLocationManager alloc] init];
		[self->locationManager startUpdatingLocation];
	}
	return [super init];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"BackgroundLocationController::didUpdateToLocation, %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	CLLocationDistance meters = [newLocation distanceFromLocation:destinationLocation];
	if (meters <= alarmRadius)
	{
		// alert notification
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	}
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0)
{
	NSLog(@"locationManager didUpdateHeading");
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status __OSX_AVAILABLE_STARTING(__MAC_10_7,__IPHONE_4_2)
{
	NSLog(@"locationManager didChangeAuthorizationStatus");
}

@end
