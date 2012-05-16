//
//  Sound.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-02-01.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "Sound.h"

@implementation Sound

@synthesize soundFileName, name, label;

+(id)initWithName:(NSString *)name soundFileName:(NSString *)soundFileName label:(NSString *)label
{
	Sound * sound = [[self alloc] init];
	sound.name = name;
	sound.soundFileName = soundFileName;
	sound.label = label;
	return sound;
}

@end
