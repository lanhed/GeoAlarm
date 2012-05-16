//
//  Sound.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-02-01.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sound : NSObject
{
	NSString * soundFileName;
	NSString * name;
	NSString * label;
}

@property (strong, nonatomic) NSString * soundFileName;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * label;

+(id)initWithName:(NSString *)name soundFileName:(NSString *)soundFileName label:(NSString *)label;

@end
