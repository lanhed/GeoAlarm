//
//  Location.m
//  Test
//
//  Created by Johan Månsson on 2012-01-13.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "Location.h"

@implementation Location

@synthesize locationId, locationName, latitude, longitude, favorite, alarmName, alarmRadius;

+ (id)initWithName:(NSString *)locationName locationId:(NSInteger)locationId latiude:(float)latitude longitude:(float)longitude favorite:(BOOL)favorite alarmName:(NSString *)alarmName alarmRadius:(NSInteger)alarmRadius
{
	Location * loc = [[self alloc] init];
	loc.locationName = locationName;
	loc.locationId = locationId;
	loc.latitude = latitude;
	loc.longitude = longitude;
	loc.favorite = favorite;
	if (alarmName != nil)
	{
		loc.alarmName = alarmName;
	}
	else
	{
		loc.alarmName = @"carhorns";
	}
	
	if (alarmRadius > 0)
	{
		loc.alarmRadius = alarmRadius;
	}
	else
	{
		loc.alarmRadius = DEFAULT_ALARM_RADIUS;
	}
		
	return loc;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	locationId = [decoder decodeIntegerForKey:@"locationId"];
	locationName = [decoder decodeObjectForKey:@"locationName"];
	latitude = [decoder decodeFloatForKey:@"latitude"];
	longitude = [decoder decodeFloatForKey:@"longitude"];
	if ([decoder decodeObjectForKey:@"alarmName"] == nil)
	{
		alarmName = @"carhorns";
	}
	else
	{
		alarmName = [decoder decodeObjectForKey:@"alarmName"];
	}
	
	if ([decoder decodeIntegerForKey:@"alarmRadius"] > 0)
	{
		alarmRadius = [decoder decodeIntegerForKey:@"alarmRadius"];
	}
	else
	{
		alarmRadius = DEFAULT_ALARM_RADIUS;
	}
	favorite = YES;
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInt:locationId forKey:@"locationId"];
	[encoder encodeObject:locationName forKey:@"locationName"];
	[encoder encodeFloat:latitude forKey:@"latitude"];
	[encoder encodeFloat:longitude forKey:@"longitude"];
	[encoder encodeObject:alarmName forKey:@"alarmName"];
	[encoder encodeInt:alarmRadius forKey:@"alarmRadius"];
}

@end
