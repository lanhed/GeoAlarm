//
//  GeoAlarmTests.h
//  GeoAlarmTests
//
//  Created by Johan Månsson on 2012-01-18.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GeoAlarmTests : SenTestCase <CLLocationManagerDelegate>
{
	CLLocationManager * locationManager;
}

@property (nonatomic, retain) CLLocationManager *locationManager;

- (CLLocationManager *)locationManager;
@end
