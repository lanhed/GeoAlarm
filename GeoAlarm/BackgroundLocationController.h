//
//  BackgroundLocationController.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-24.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Location.h"

@interface BackgroundLocationController : NSObject <CLLocationManagerDelegate>
{
	CLLocation * destinationLocation;
	NSInteger alarmRadius;
	CLLocationManager * locationManager;
}

@property (strong, nonatomic) CLLocation * destinationLocation;
@property NSInteger alarmRadius;

- (id)initWithDestination:(CLLocation *)destination radius:(NSInteger)radius;

@end
