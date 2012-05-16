//
//  MapViewController.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-20.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "Location.h"
#import "Sound.h"
#import "AlarmSettingsViewController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate, UIActionSheetDelegate, AlarmSettingsDelegate,AVAudioPlayerDelegate>
{
	AppDelegate * delegate;
	
	CLLocationManager * locationManager;
	CLRegion * regionToMonitor;
	CLLocation * destinationLocation;
    
	Location * currentDestination;
	CLLocationCoordinate2D currentCoord;
	CLLocationDistance meters;
	
	UILocalNotification * localNotif;
	AVAudioPlayer * soundPlayer;
	
	CFURLRef soundFileURLRef;
	
	BOOL alarmStarted;
	BOOL isInBackground;
	BOOL hasTimer;
	BOOL isInSettingsView;
}


@property (strong, nonatomic) Location * currentDestination;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *metersLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *alarmControl;
@property (strong, nonatomic) IBOutlet UILabel *alarmRadiusLabel;

-(IBAction)touchUpInside:(id)sender;
-(void)startAlarm;
-(void)stopAlarm;
-(void)setRegionToMonitor:(CLRegion *)regionToMonitor;
-(void)playAlarmSoundWithSound:(Sound *)sound;

-(CLLocationManager *)locationManager;
-(void)stopLocationManagerServices;
-(void)sendNotification:(NSString *)text;
-(void)centerMapToDestination;

-(void)willEnterForeground:(NSNotification *)notification;
-(void)enteredBackground:(NSNotification *)notification;
-(void)stopAlarmOnIncommingNotification:(NSNotification *)notification;
-(void)applicationWillTerminate:(NSNotification *)notification;

- (void)onTick:(NSTimer *)timer;

@end
