//
//  LocationViewAnnotation.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-31.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "LocationViewAnnotation.h"

@implementation LocationViewAnnotation

@synthesize latitude, longitude, subtitle, title;

- (id)initWithLatitude:(CLLocationDegrees) lat longitude:(CLLocationDegrees) lng {
	[self setLatitude:lat];
	[self setLongitude:lng];
	
	return self;
}

- (CLLocationCoordinate2D) coordinate 
{	
	CLLocationCoordinate2D coord = { latitude, longitude };
	return coord;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
	[self setLatitude:newCoordinate.latitude];
	[self setLongitude:newCoordinate.longitude];
}

@end
