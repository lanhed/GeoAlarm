//
//  MapViewController.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-20.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "MapViewController.h"
#import "Location.h"
#import "AlarmSettingsViewController.h"
#import "TestFlight.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
#import <CoreLocation/CoreLocation.h>

@implementation MapViewController
@synthesize alarmRadiusLabel;

@synthesize metersLabel, alarmControl, mapView;
@synthesize currentDestination;

#define ALLREADY_IN_REGION 10
#define DID_ENTER_REGION 20
#define DID_EXIT_REGION 30

#pragma mark - AlarmSettingsDelegate methods

-(void)updateAlarmSettings:(NSInteger)selectedRadius
{
	currentDestination.alarmRadius = selectedRadius;
	if ([delegate.dataManagerInstance isFavorite:currentDestination.locationId])
	{
		[delegate.dataManagerInstance updateFavorite:currentDestination];
	}
	alarmRadiusLabel.text = [NSString stringWithFormat:@"Alarmradie: %i meter",currentDestination.alarmRadius];
    
	if (alarmStarted)
	{
		[[self locationManager] stopMonitoringForRegion:regionToMonitor];
		if ((int) meters <= currentDestination.alarmRadius)
		{
			[alarmControl setSelectedSegmentIndex:1];
			[self stopAlarm];
			
			CFBundleRef mainBundle = CFBundleGetMainBundle();
			soundFileURLRef = CFBundleCopyResourceURL(mainBundle, (CFStringRef) @"funk", CFSTR ("caf"), NULL);
			UInt32 soundID;
			AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
			AudioServicesPlaySystemSound(soundID);
			UIActionSheet * alert = [[UIActionSheet alloc] initWithTitle:@"Du är inom radien för alarmet! Alarmet har stängts av." delegate:(id)self cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
			alert.tag = 10;
			[alert showInView:self.view];
			
			return;
		}
		
        [self setRegionToMonitor:[[CLRegion alloc] initCircularRegionWithCenter:currentCoord radius:currentDestination.alarmRadius identifier:@"destination"]];
	}
}

#pragma mark - IBAction handlers
- (IBAction)touchUpInside:(id)sender 
{
	if (sender == alarmControl && [sender selectedSegmentIndex] == 0 && !alarmStarted)
	{
		[self startAlarm];
		
	}
	else if (sender == alarmControl && [sender selectedSegmentIndex] == 1 && alarmStarted)
	{
		[self stopAlarm];
	}
}

#pragma mark - Alarm start/stop methods

- (void)startAlarm
{
	alarmStarted = YES;
    
    [TestFlight passCheckpoint:@"ALARM_STARTED"];
	
	NSMethodSignature *sgn = [self methodSignatureForSelector:@selector(onTick:)];
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature: sgn];
	[inv setTarget: self];
	[inv setSelector:@selector(onTick:)];
	NSTimer * timer = [NSTimer timerWithTimeInterval:2.0 invocation:inv repeats:NO];
	NSRunLoop * runner = [NSRunLoop currentRunLoop];
	[runner addTimer:timer forMode: NSDefaultRunLoopMode];
	
	hasTimer = YES;
	
	[mapView setShowsUserLocation:YES];
	
	// skapa region och starta uppdatering av location
	[[self locationManager] setDesiredAccuracy:kCLLocationAccuracyBest];
	[[self locationManager] setDistanceFilter:kCLDistanceFilterNone];
	
	currentCoord = CLLocationCoordinate2DMake(destinationLocation.coordinate.latitude, destinationLocation.coordinate.longitude);
	[self setRegionToMonitor:[[CLRegion alloc] initCircularRegionWithCenter:currentCoord radius:currentDestination.alarmRadius identifier:@"destination"]];
	[[self locationManager] startUpdatingLocation];
}

- (void)stopAlarm
{
	alarmStarted = NO;
    
    [self stopLocationManagerServices];
    
	[mapView setShowsUserLocation:NO];
	[self centerMapToDestination];
	metersLabel.text = [NSString stringWithFormat:@"Alarm stoppat!"];
	metersLabel.textColor = [UIColor whiteColor];
    
	[soundPlayer stop];
	NSError *activationResult = nil;
	[[AVAudioSession sharedInstance] setActive: NO error: &activationResult];
}

- (void)setRegionToMonitor:(CLRegion *)region
{
    if (regionToMonitor)
    {
        [[self locationManager] stopMonitoringForRegion:regionToMonitor];
    }
    regionToMonitor = region;
    [[self locationManager] startMonitoringForRegion:regionToMonitor];
}

-(void)onTick:(NSTimer *)timer
{
	hasTimer = NO;
    timer = nil;
}

- (void)centerMapToDestination
{
	MKCoordinateRegion region;
	region.center.latitude = currentDestination.latitude;
	region.center.longitude = currentDestination.longitude;
	region.span.latitudeDelta = 0.005f;
	region.span.longitudeDelta = 0.005f;
	
	[mapView setRegion:[mapView regionThatFits:region] animated:YES];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if (!isInBackground)
	{
		meters = [newLocation distanceFromLocation:destinationLocation];
		if ((int) meters > 1000)
		{
			metersLabel.text = [NSString stringWithFormat:@"%.2lf km kvar", meters/1000];
		}
		else
		{
			metersLabel.text = [NSString stringWithFormat:@"%i m kvar", (int) meters];
		}
		
		//NSLog(@"hasTimer: %i, meters %i, radius %i",hasTimer, (int) meters, currentDestination.alarmRadius);
		
		// zooma och centrera kartan
		MKCoordinateRegion region;
		region.center.latitude = (newLocation.coordinate.latitude + currentDestination.latitude) / 2.0;
		region.center.longitude = (newLocation.coordinate.longitude + currentDestination.longitude) / 2.0;
		
		// här hade man kunnat lägga på lite så man får plats med anotations i vyn
		region.span.latitudeDelta = meters / 111319.5;
		region.span.longitudeDelta = 0.0;
	
		[mapView setRegion:[mapView regionThatFits:region] animated:YES];
		
		if (alarmStarted && hasTimer && (int) meters <= currentDestination.alarmRadius)
		{
			[alarmControl setSelectedSegmentIndex:1];
			[self stopAlarm];
			[self playAlarmSoundWithSound:[Sound initWithName:@"funk" soundFileName:@"funk.caf" label:@"Funk"]];
			UIActionSheet * alert = [[UIActionSheet alloc] initWithTitle:@"Du är inom radien för alarmet! Alarmet har stängts av." delegate:(id)self cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
			alert.tag = ALLREADY_IN_REGION;
			[alert showInView:self.view];
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	if (!isInBackground)
	{
		metersLabel.textColor = [UIColor redColor];
		UIActionSheet * alert = [[UIActionSheet alloc] initWithTitle:@"Du är nära din destination nu! Vill du stänga av alarmet?" delegate:(id)self cancelButtonTitle:@"Stäng av" destructiveButtonTitle:@"Nej!" otherButtonTitles:nil, nil];
		alert.tag = DID_ENTER_REGION;
		[alert showInView:self.view];
		
		[self playAlarmSoundWithSound:nil];
        
        [TestFlight passCheckpoint:@"ALARM_STOPPED_ON_ENTER_REGION"];
	}
	else
	{
		[self sendNotification:@"Du är nära din destination nu! Öppna appen för att stänga av alarmet."];
	}
}

/*
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	metersLabel.textColor = [UIColor whiteColor];
	if (!isInBackground)
	{
		UIActionSheet * alert = [[UIActionSheet alloc] initWithTitle:@"Du verkar ha åkt förbi destinationen. Vill du stänga av alarmet?" delegate:(id)self cancelButtonTitle:@"Stäng av" destructiveButtonTitle:@"Nej!" otherButtonTitles:nil, nil];
		alert.tag = DID_EXIT_REGION;
		[alert showInView:self.view];
	}
	else
	{
		[self sendNotification:@"Du verkar ha åkt förbi destinationen. Öppna appen för att stänga av alarmet."];
	}
	
}
 */

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}


- (CLLocationManager *)locationManager 
{
    if (locationManager != nil) 
    {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
    [TestFlight passCheckpoint:@"LOCATION_MANAGER_STARTED"];
	
	return locationManager;
}

-(void)stopLocationManagerServices
{
    if (locationManager != nil)
    {
        /*
        NSArray * regions;
        regions = [[locationManager monitoredRegions] allObjects];
        NSLog(@"regions.lenght: %i",[regions count]);
        for (CLRegion * member in regions) {
            NSLog(@"found member %@",member);
        }
        */
        if (regionToMonitor != nil)
        {
            [[self locationManager] stopMonitoringForRegion:regionToMonitor];
            regionToMonitor = nil;
        }
        /*
        regions = [[locationManager monitoredRegions] allObjects];
        NSLog(@"regions.lenght: %i",[regions count]);
        for (CLRegion * member in regions) {
            NSLog(@"found member %@",member);
        }
        */
        [[self locationManager] stopUpdatingLocation];
        [locationManager setDelegate:nil];
        locationManager=nil;
        
        [TestFlight passCheckpoint:@"LOCATION_MANAGER_STOPPED"];
    }
}

#pragma mark - Notification & debug

- (void)sendNotification:(NSString *)text
{
	UIApplication* app = [UIApplication sharedApplication];
	NSArray * oldNotifications = [app scheduledLocalNotifications];
	
	if ([oldNotifications count] > 0)
		[app cancelAllLocalNotifications];

	//UILocalNotification
	localNotif = [[UILocalNotification alloc] init];
	if (localNotif == nil)
		return;
	
	localNotif.alertBody = [NSString stringWithFormat:@"%@",text];
	localNotif.alertAction = @"Öppna GeoAlarm";
	
	[self playAlarmSoundWithSound:nil];
	[[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
}

- (void)playAlarmSoundWithSound:(Sound *)alarmSound
{
	if (alarmSound == nil)
	{
		alarmSound = [delegate.dataManagerInstance alarmSoundWithName:currentDestination.alarmName];
	}
	
	NSError *activationResult = nil;
	[[AVAudioSession sharedInstance] setActive: YES error: &activationResult];
	
	NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:alarmSound.name ofType:@"caf"]];
    soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFile error:nil];
	[soundPlayer setDelegate:self];
	[soundPlayer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	NSError *activationResult = nil;
	[[AVAudioSession sharedInstance] setActive: NO error: &activationResult];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet.tag == DID_ENTER_REGION || actionSheet.tag == DID_EXIT_REGION)
	{
		if (buttonIndex == 1)
		{
			[alarmControl setSelectedSegmentIndex:1];
			[self stopAlarm];
		}
	}
}


#pragma mark - Background/Foreground mode

-(void)willEnterForeground:(NSNotification *)notification
{
	isInBackground = NO;
}

-(void)enteredBackground:(NSNotification *)notification
{
	isInBackground = YES;
}

-(void)stopAlarmOnIncommingNotification:(NSNotification *)notification
{
    [alarmControl setSelectedSegmentIndex:1];
	[self stopAlarm];
    
    [TestFlight passCheckpoint:@"ALARM_STOPPED_ON_INCOMMING_NOTIFICATION"];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
	NSLog(@"MapViewController:applicationWillTerminate");
    [alarmControl setSelectedSegmentIndex:1];
	[self stopAlarm];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{	
    [super viewDidLoad];
	
	delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	destinationLocation = [[CLLocation alloc] initWithLatitude:currentDestination.latitude longitude:currentDestination.longitude];
	alarmRadiusLabel.text = [NSString stringWithFormat:@"Alarmradie: %i meter",currentDestination.alarmRadius];
	
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(enteredBackground:) 
												 name: UIApplicationDidEnterBackgroundNotification
											   object: nil];
	
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(willEnterForeground:) 
												 name: UIApplicationWillEnterForegroundNotification
											   object: nil];
	
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(stopAlarmOnIncommingNotification:) 
												 name: @"stopAlarmOnIncommingNotification"
											   object: nil];
	
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(applicationWillTerminate:) 
												 name: @"applicationWillTerminate"
											   object: nil];
	
	alarmStarted = NO;
	isInBackground = NO;
	hasTimer = NO;
	isInSettingsView = NO;
	
	mapView.layer.cornerRadius = 10.0;
	mapView.layer.borderColor = [[UIColor blackColor] CGColor];
	mapView.layer.borderWidth = 1;
	
	metersLabel.text = @"";
	
	self.title = currentDestination.locationName;
	
	CLLocationCoordinate2D destinationCoord = CLLocationCoordinate2DMake(currentDestination.latitude, currentDestination.longitude);
	MKPointAnnotation *destinationPointAnnotation = [[MKPointAnnotation alloc] init];
	destinationPointAnnotation.coordinate = destinationCoord;
	destinationPointAnnotation.title = currentDestination.locationName;
	[self.mapView addAnnotation:destinationPointAnnotation];
	
	metersLabel.text = [NSString stringWithFormat:@"Alarm ej startat!"];
	
	[self centerMapToDestination];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"settings"]) 
	{
		isInSettingsView = YES;
		AlarmSettingsViewController * destinationController = [segue destinationViewController];
		[destinationController setLoc:currentDestination];
		destinationController.alarmSettingsDelegate = (id)self;
		destinationController.selectedRadius = currentDestination.alarmRadius;
	}
}

-(void)viewWillAppear:(BOOL)animated
{
	if (isInSettingsView)
	{
		isInSettingsView = NO;
	}
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (!isInSettingsView)
	{
        NSLog(@"%s",__FUNCTION__);
        if (alarmStarted)
        {
            [self stopAlarm];
            alarmStarted = NO;
        }
        [mapView setShowsUserLocation:NO];
        
		[self stopLocationManagerServices];
        
        metersLabel.text = [NSString stringWithFormat:@"Alarm stoppat!"];
        metersLabel.textColor = [UIColor whiteColor];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    NSLog(@"%s",__FUNCTION__);
    
    [self stopLocationManagerServices];
	
	destinationLocation = nil;
	
	[self setAlarmRadiusLabel:nil];
	[self setMapView:nil];
	[self setMetersLabel:nil];
	[self setAlarmControl:nil];
	[self setCurrentDestination:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	CFRelease( soundFileURLRef );
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
