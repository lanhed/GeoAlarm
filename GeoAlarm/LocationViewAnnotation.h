//
//  LocationViewAnnotation.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-31.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationViewAnnotation : NSObject <MKAnnotation> 
{
	float latitude;
    float longitude;
}

@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;

- (id) initWithLatitude:(CLLocationDegrees) lat longitude:(CLLocationDegrees) lng;

@end
