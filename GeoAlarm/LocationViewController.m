//
//  LocationViewController.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-27.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "LocationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "MapViewController.h"
#import "AppDelegate.h"
#import "PersistentDataManager.h"
#import "TestFlight.h"

@implementation LocationViewController
@synthesize startAlarmButton;
@synthesize locationLabel,locationNameTextField,saveButton,mapView,locationManager;

#pragma mark - mapViewDelegate methods

- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id ) annotation 
{
	MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
	customPinView.animatesDrop = NO;
	customPinView.draggable = YES;
	return customPinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
	[[self locationManager] stopUpdatingLocation];
	if (newState == MKAnnotationViewDragStateEnding)
	{
		CLLocationCoordinate2D coordinate = [annotationView.annotation coordinate];
		savedLocation.latitude = coordinate.latitude;
		savedLocation.longitude = coordinate.longitude;
		[locationLabel setText:[NSString stringWithFormat:@"lat: %f, lon: %f",savedLocation.latitude, savedLocation.longitude]];
		
		CLLocation * pinLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
		CLGeocoder * geocoder = [[CLGeocoder alloc] init];
		[geocoder reverseGeocodeLocation:pinLocation completionHandler:^(NSArray *placemarks, NSError *error) 
		 {
			 if (error)
			 {
				 NSLog(@"Geocode failed with error: %@", error);
				 [locationLabel setText:@""];
				 UIActionSheet * alert = [[UIActionSheet alloc] initWithTitle:@"Kunde inte hitta adressen." delegate:(id)self cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
				 [alert showInView:self.view];
				 
				 return;
			 }
			 
			 if(placemarks && placemarks.count > 0)
			 {
				 savedLocation.locationName = locationNameTextField.text = [self validatePlacemarkText:[placemarks objectAtIndex:0]];
			 }
		 }];
	}
		
}

#pragma mark - interactions

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    [self.mapView removeAnnotation:locationAnnotation];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];       
	[[self locationManager] stopUpdatingLocation];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    savedLocation.latitude = coordinate.latitude;
    savedLocation.longitude = coordinate.longitude;
    [locationLabel setText:[NSString stringWithFormat:@"lat: %f, lon: %f",savedLocation.latitude, savedLocation.longitude]];
    
    CLLocation * pinLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:pinLocation completionHandler:^(NSArray *placemarks, NSError *error) 
     {
         if (error)
         {
             NSLog(@"Geocode failed with error: %@", error);
             [locationLabel setText:@""];
             UIActionSheet * alert = [[UIActionSheet alloc] initWithTitle:@"Kunde inte hitta adressen." delegate:(id)self cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
             [alert showInView:self.view];
             
             return;
         }
         
         if(placemarks && placemarks.count > 0)
         {
             savedLocation.locationName = locationNameTextField.text = [self validatePlacemarkText:[placemarks objectAtIndex:0]];
         }
     }];
    
    locationAnnotation = [[LocationViewAnnotation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self.mapView addAnnotation:locationAnnotation];
}

- (IBAction)saveData:(id)sender 
{
	doSaveData = YES;
	if ([locationNameTextField.text length] > 0)
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		UIActionSheet * alert = [[UIActionSheet alloc] initWithTitle:@"Du måste ange ett namn på platsen för att kunna spara." delegate:(id)self cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
		[alert showInView:self.view];
	}
}

#pragma mark - CLLocationManager

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
        [[self locationManager] stopUpdatingLocation];
        [self setLocationManager:nil];
        
        [TestFlight passCheckpoint:@"LOCATION_MANAGER_STOPPED"];
    }

}

- (NSString *)validatePlacemarkText:(CLPlacemark *)topResult
{
	NSString * result = [NSString stringWithFormat:@"%@ %@ %@",
						 [topResult thoroughfare], 
						 [topResult subThoroughfare],
						 [topResult locality]];
	
	if ([topResult subThoroughfare] == NULL)
	{
		result = [NSString stringWithFormat:@"%@ %@", [topResult thoroughfare], [topResult locality]];
	}
	
	if ([topResult thoroughfare] == NULL)
	{
		result = [NSString stringWithFormat:@"Okänd adress, %@",[topResult locality]];
	}
	
	return result;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{
	if(!hasLocation)
	{
		hasLocation = YES;
		
		CLLocationCoordinate2D coordinate = [newLocation coordinate];
		savedLocation.latitude=coordinate.latitude;
		savedLocation.longitude=coordinate.longitude;
		
		if (locationAnnotation == nil)
		{
			locationAnnotation = [[LocationViewAnnotation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
			[self.mapView addAnnotation:locationAnnotation];
			
			MKCoordinateRegion region;
			region.center.latitude = coordinate.latitude;
			region.center.longitude = coordinate.longitude;
			region.span.latitudeDelta = 0.005f;
			region.span.longitudeDelta = 0.005f;
			[mapView setRegion:[mapView regionThatFits:region] animated:NO];
		}
		else
		{
			[locationAnnotation setCoordinate:coordinate];
			
			MKCoordinateRegion region;
			region.center.latitude = coordinate.latitude;
			region.center.longitude = coordinate.longitude;
			region.span.latitudeDelta = 0.005f;
			region.span.longitudeDelta = 0.005f;
			[mapView setRegion:[mapView regionThatFits:region] animated:NO];
		}
		
		CLGeocoder * geocoder = [[CLGeocoder alloc] init];
		[geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) 
		 {
			 if (error)
			 {
				 NSLog(@"LocationViewController::Geocode failed with error: %@", error);
				 [locationLabel setText:@""];
				 
				 return;
			 }
			 
			 if(placemarks && placemarks.count > 0)
			 {
				 savedLocation.locationName = locationNameTextField.text = [self validatePlacemarkText:[placemarks objectAtIndex:0]];
			 }
		 }];
		
		
		[locationLabel setText:[NSString stringWithFormat:@"lat: %f, lon: %f",newLocation.coordinate.latitude, newLocation.coordinate.longitude]];
		
	}
	
    saveButton.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error 
{
	[locationLabel setText:@"Kunde inte hitta din position."];
	savedLocation.locationName = locationNameTextField.text = @"";
    saveButton.enabled = NO;
}


#pragma mark - UITextFieldDelgate methods

- (IBAction)textFieldFinished:(id)sender
{
	savedLocation.locationName = locationNameTextField.text;
	[sender resignFirstResponder];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	locationNameTextField.delegate = self;
	[self.locationNameTextField addTarget:self
                                   action:@selector(textFieldFinished:)
                         forControlEvents:UIControlEventEditingDidEndOnExit];
	
	mapView.layer.cornerRadius = 10.0;
	mapView.layer.borderColor = [[UIColor blackColor] CGColor];
	mapView.layer.borderWidth = 1;
	
	doSaveData = NO;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //user needs to press for 0.5 seconds
    [self.mapView addGestureRecognizer:lpgr];
	
	savedLocation = [[Location alloc] init];
	savedLocation.locationId = abs(arc4random());
	savedLocation.alarmRadius = DEFAULT_ALARM_RADIUS;
    savedLocation.alarmName = DEFAULT_ALARM_NAME;
	
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self locationManager];
	[self.locationManager startUpdatingLocation];
    
    [super viewDidAppear:animated];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	MapViewController * destinationController = [segue destinationViewController];
	destinationController.currentDestination = savedLocation;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopLocationManagerServices];
	hasLocation = NO;
    
	if (doSaveData) 
	{
		AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[delegate.dataManagerInstance saveFavorite:savedLocation];
	}
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self stopLocationManagerServices];
    
	[self setLocationNameTextField:nil];
	[self setMapView:nil];
	[self setLocationLabel:nil];
	[self setSaveButton:nil];
	[self setStartAlarmButton:nil];
    
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
