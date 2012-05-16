//
//  AlarmController.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-24.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AlarmController : UIViewController <CLLocationManagerDelegate>
{
	CLLocationCoordinate2D coord;
	CLRegion * regionToMonitor;
	int alarmRadius;
	CLLocation * destinationLocation;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLRegion * regionToMonitor;
@property (strong, nonatomic) CLLocation * destinationLocation;
@property int alarmRadius;

//IBOutlets
@property (strong, nonatomic) IBOutlet UITextView *secondDebugText;

- (CLLocationManager *)locationManager;
- (void)setTextViewText:(NSString *)text;
- (void)sendNotification:(NSString *)text;

@end
