//
//  LocationViewController.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-27.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Location.h"
#import "LocationViewAnnotation.h"

@interface LocationViewController : UIViewController <CLLocationManagerDelegate,UITextFieldDelegate>
{
	CLLocationManager * locationManager;
	LocationViewAnnotation * locationAnnotation;
	Location * savedLocation;
	BOOL hasLocation;
	BOOL doSaveData;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UITextField *locationNameTextField;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *startAlarmButton;

-(CLLocationManager *)locationManager;
-(void)stopLocationManagerServices;
-(NSString *)validatePlacemarkText:(CLPlacemark *)topResult;

-(IBAction)textFieldFinished:(id)sender;
-(IBAction)saveData:(id)sender;

@end
