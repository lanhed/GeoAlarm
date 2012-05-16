//
//  GeoAlarmTests.m
//  GeoAlarmTests
//
//  Created by Johan Månsson on 2012-01-18.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "GeoAlarmTests.h"

@implementation GeoAlarmTests

@synthesize locationManager;

- (void)setUp
{
    [super setUp];
	
    // Set-up code here.
    //[Location initWithName:@"Malmö C" locationId:80100 latiude:55.6087734190321506 longitude:12.999901855621083],
	//[Location initWithName:@"Malmö Konserthuset" locationId:80200 latiude:55.60030875951064 longitude:13.007513614573046],
	//[Location initWithName:@"Bjärred Centrum" locationId:80300 latiude:55.7225793529904 longitude:13.0273830867018], nil]
	
	[[self locationManager] setDesiredAccuracy:kCLLocationAccuracyBest];
	[[self locationManager] setDistanceFilter:kCLDistanceFilterNone];
	
	CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(55.6087734190321506, 12.999901855621083);
	[[self locationManager] startMonitoringForRegion:[[CLRegion alloc] initCircularRegionWithCenter:coord radius:500 identifier:@"destination"]];
	[[self locationManager] startUpdatingLocation];
}

- (void)tearDown
{
    // Tear-down code here.
    
	self.locationManager = nil;
	
    [super tearDown];
}

- (void)testExample
{
	NSLog(@"test");
}

- (CLLocationManager *)locationManager 
{
	
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
	
	return locationManager;
}


#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"locationManager:didUpdateLocation");
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	NSLog(@"locationManager:didEnterRegion%@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
	NSLog(@"locationManager:didStartMonitoringForRegion: %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
	NSLog(@"locationManager:monitoringDidFailForRegion:withError %@",error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"locationManager:didFailWithError %@",error);
}

@end
