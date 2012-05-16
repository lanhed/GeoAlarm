//
//  Location.h
//  Test
//
//  Created by Johan Månsson on 2012-01-13.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject <NSCoding>

#define DEFAULT_ALARM_RADIUS 500
#define DEFAULT_ALARM_NAME @"carhorns"

@property (assign, nonatomic) NSInteger locationId;
@property (strong, nonatomic) NSString * locationName;
@property (assign, nonatomic) float latitude;
@property (assign, nonatomic) float longitude;
@property (assign, nonatomic) BOOL favorite;
@property (strong, nonatomic) NSString * alarmName;
@property (assign, nonatomic) NSInteger alarmRadius;

+ (id) initWithName:(NSString *)locationName locationId:(NSInteger)locationId latiude:(float)latitude longitude:(float)longitude favorite:(BOOL)favorite alarmName:(NSString *)alarmName alarmRadius:(NSInteger)alarmRadius;

@end
