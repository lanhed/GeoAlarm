//
//  MyString.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-02-03.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyString : NSObject <NSCoding>
{
	NSString * myString;
}

@property (strong, nonatomic) NSString * myString;

@end
