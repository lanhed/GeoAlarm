//
//  PersistentDataManager.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-02-02.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "PersistentDataManager.h"
#import "TestFlight.h"

@implementation PersistentDataManager

#pragma mark - favorites

-(void)saveFavorite:(Location *)location
{
	NSMutableArray * favoritesList = [NSMutableArray arrayWithArray:[self favorites]];
	[favoritesList addObject:location];
	
	//NSLog(@"Location.alarmName: %@", location.alarmName);
	//NSLog(@"PersistentDataManager::Save favorite: %@, lat: %f, lng: %f",location.locationName, location.latitude, location.longitude);
	
	NSString * archivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Favorites.archive"];
	NSMutableData * data = [NSMutableData data];
	NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	// Customize archiver here
	[archiver encodeObject:favoritesList forKey:@"favorites"];
	[archiver finishEncoding];
	
	BOOL result = [data writeToFile:archivePath atomically:YES];
	if (!result)
	{
		NSLog(@"PersistentDataManager::gick inte att spara");
	}
    
    [TestFlight passCheckpoint:@"DESTINATION_SAVED"];
}

-(void)updateFavorite:(Location *)location
{
	NSArray * favoritesList = [self favorites];
	NSMutableArray * list = [[NSMutableArray alloc] initWithCapacity:[favoritesList count]];
	for (Location * loc in favoritesList) 
	{
		if (loc.locationId != location.locationId)
		{
			[list addObject:loc];
		}
		else
		{
			[list addObject:location];
		}
	}
	
	NSString * archivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Favorites.archive"];
	NSMutableData * data = [NSMutableData data];
	NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	// Customize archiver here
	[archiver encodeObject:list forKey:@"favorites"];
	[archiver finishEncoding];
	
	BOOL result = [data writeToFile:archivePath atomically:YES];
	if (!result)
	{
		NSLog(@"PersistentDataManager::gick inte att spara");
	}
}

-(NSArray *)favorites
{
	NSString *archivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Favorites.archive"];
	NSData *data = [NSData dataWithContentsOfFile:archivePath];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	// Customize unarchiver here
	NSArray * list = [unarchiver decodeObjectForKey:@"favorites"];
	[unarchiver finishDecoding];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"locationName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedList = [list sortedArrayUsingDescriptors:sortDescriptors];
	
	return sortedList;
}

-(NSArray *)deleteFavoriteWithId:(NSInteger)locationId
{
	NSArray * favoritesList = [self favorites];
	NSMutableArray * list = [[NSMutableArray alloc] init];
	for (Location * loc in favoritesList) 
	{
		if (loc.locationId != locationId)
		{
			[list addObject:loc];
		}
	}
	NSString * archivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Favorites.archive"];
	NSMutableData * data = [NSMutableData data];
	NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	// Customize archiver here
	[archiver encodeObject:list forKey:@"favorites"];
	[archiver finishEncoding];
	
	BOOL result = [data writeToFile:archivePath atomically:YES];
	if (!result)
	{
		NSLog(@"PersistentDataManager::gick inte att spara");
	}
	
	return list;
}

-(BOOL)isFavorite:(NSInteger)locationId
{
	for (Location * loc in [self favorites]) 
	{
		if (loc.locationId == locationId)
		{
			return YES;
		}
	}
	
	return NO;
}

#pragma mark - alarm sound methods

-(NSArray *)alarmSounds
{
	NSMutableArray * templist = [[NSMutableArray alloc] init];
	
	Sound * machinegun = [Sound initWithName:@"machinegun" soundFileName:@"machinegun.caf" label:@"Maskingevär"];
	[templist addObject:machinegun];
	
	Sound * carhorns = [Sound initWithName:@"carhorns" soundFileName:@"carhorns.caf" label:@"Biltutor"];
	[templist addObject:carhorns];
	
	Sound * crash = [Sound initWithName:@"crash" soundFileName:@"crash.caf" label:@"Krash"];
	[templist addObject:crash];
	
	Sound * digital = [Sound initWithName:@"digitalalarm" soundFileName:@"digitalalarm.caf" label:@"Digitalt alarm"];
	[templist addObject:digital];
	
	NSArray * list = [[NSArray alloc] initWithArray:templist];
	templist = nil;
	
	return list;
}

-(Sound *)alarmSoundWithName:(NSString *)name
{
	for (Sound * sound in [self alarmSounds]) 
	{
		if ([sound.name isEqualToString:name])
		{
			return sound;
		}
	}
	return nil;
}

@end
