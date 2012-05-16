//
//  LocationService.h
//  SearchTable
//
//  Created by Johan Månsson on 2012-01-18.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

struct WGS84Coord {
	float latitude;
	float longitude;
};
typedef struct WGS84Coord WGS84Coord;
WGS84Coord WGS84CoordMake(float latitude, float longitude);

@interface LocationService : NSObject <NSXMLParserDelegate>
{
	NSMutableArray * result;
	BOOL isStartPoint;
	Location * currentLocation;
	NSMutableString * currentProperty;
	
	NSInteger gridCoordX;
	NSInteger gridCoordY;
}

-(NSArray *)search:(NSString *)searchStr;
-(WGS84Coord)convertRT90ToWGS84:(NSInteger)coordX coordY:(NSInteger)coordY;
-(float)sinh:(double)value;
-(float)cosh:(double)value;
-(float)atanh:(double)value;
@end
