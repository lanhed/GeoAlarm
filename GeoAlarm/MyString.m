//
//  MyString.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-02-03.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "MyString.h"

@implementation MyString

@synthesize myString;

- (id)initWithCoder:(NSCoder *)decoder
{
	NSLog(@"initWithCoder");
	myString = [decoder decodeObjectForKey:@"name"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	NSLog(@"encodeWithCoder");
	[encoder encodeObject:myString forKey:@"name"];
}


@end
