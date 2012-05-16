//
//  PersistentDataManager.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-02-02.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "Sound.h"

@interface PersistentDataManager : NSObject

-(void)saveFavorite:(Location *)location;
-(void)updateFavorite:(Location *)location;
-(NSArray *)deleteFavoriteWithId:(NSInteger)locationId;
-(NSArray *)favorites;
-(BOOL)isFavorite:(NSInteger)locationId;

-(NSArray *)alarmSounds;
-(Sound *)alarmSoundWithName:(NSString *)name;

@end
