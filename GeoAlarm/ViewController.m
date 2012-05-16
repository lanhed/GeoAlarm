//
//  ViewController.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-18.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "ViewController.h"
#import "Location.h"
#import "LocationService.h"
#import "SearchResultsViewController.h"
#import "MapViewController.h"
#import "AlarmController.h"
#import "LocationViewController.h"
#import <objc/runtime.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation ViewController
@synthesize mapDestinationButton;
@synthesize progressSymbol, favoritesTableView, favorites;
//, filteredListContent;


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[progressSymbol stopAnimating];
	selectedRadius = DEFAULT_ALARM_RADIUS;
	NSLog(@"viewDidLoad");
	delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//filteredListContent = [NSMutableArray arrayWithCapacity:[favorites count]];
	
	
	AudioSessionInitialize(NULL, NULL, NULL, NULL);
	
	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
	
	if (setCategoryError) 
	{
		NSLog(@"handle the error condition");
		/* handle the error condition */ 
	}
	
	OSStatus propertySetError = 0;
	UInt32 allowMixing = true;
	
	propertySetError = AudioSessionSetProperty (kAudioSessionProperty_OtherMixableAudioShouldDuck,sizeof (allowMixing), &allowMixing);
	if (propertySetError) // error:gick inte
	{
		NSLog(@"handle propertySetError");
	}
}

- (void)createNotificationMessage:(NSString *) notificationString
{
	UILocalNotification * localNotif = [[UILocalNotification alloc] init];
	if (localNotif == nil)
		return;
	
	localNotif.alertBody = [NSString stringWithFormat:@"%@",notificationString];
	localNotif.alertAction = @"GeoAlarm alertAction";
	
	localNotif.soundName = UILocalNotificationDefaultSoundName;
	
	[[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
}



#pragma mark - CLLocationManagerDelegate methods


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	[self createNotificationMessage:[NSString stringWithFormat:@"locationManager:didEnterRegion %@",region.identifier]];
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	[self createNotificationMessage:[NSString stringWithFormat:@"locationManager:didExitRegion %@",region.identifier]];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
	[self createNotificationMessage:[NSString stringWithFormat:@"locationManager:didStartMonitoringForRegion %@",region.identifier]];
}

#pragma mark - segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	UIBarButtonItem * backButton;
	if ([segue.identifier isEqualToString:@"search"]) 
	{
		/*
		här borde jag kolla var man är och returnera resultat från olika publika apier beroende på var man befinner sig.
		 
		Kanske hellre kan göras i LocationService.
		*/
		
		NSArray * searchResult = sender;
		
		SearchResultsViewController * destinationController = [segue destinationViewController];
		destinationController.searchResult = searchResult;
		destinationController.selectedRadius = selectedRadius;
		
		backButton = [[UIBarButtonItem alloc] initWithTitle:@"Tillbaka" style:UIBarButtonItemStyleBordered target:nil action:nil];
	}
	else if ([segue.identifier isEqualToString:@"map"])
	{
		MapViewController * destinationController = [segue destinationViewController];
		destinationController.currentDestination = selectedLocation;
		
		backButton = [[UIBarButtonItem alloc] initWithTitle:@"Avbryt" style:UIBarButtonItemStyleBordered target:nil action:nil];
	}
	else if ([segue.identifier isEqualToString:@"location"])
	{
		backButton = [[UIBarButtonItem alloc] initWithTitle:@"Avbryt" style:UIBarButtonItemStyleBordered target:nil action:nil];
	}
	
	[[self navigationItem] setBackBarButtonItem:backButton];
}

#pragma mark - UITableViewDelegate methods


- (NSInteger)numberOfSections
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Sparade destinationer";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    // create the parent view that will hold header Label
    
	// If you want to align the header text as centered
	// headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    UIView * customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    
    if ([favorites count] == 0)
    {
        headerLabel.lineBreakMode = UILineBreakModeWordWrap;
        headerLabel.numberOfLines = 2;
        headerLabel.font = [UIFont systemFontOfSize:16];
        headerLabel.text = @"Inga sparade destinationer att visa ännu.";
    }
    else
    {
        headerLabel.font = [UIFont boldSystemFontOfSize:16];
        headerLabel.text = @"Sparade destinationer";
    }
	[customView addSubview:headerLabel];
    
	return customView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellIdentifier";
	
	// Dequeue or create a cell of the appropriate type.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	Location * loc = nil;
    loc = [favorites objectAtIndex:indexPath.row];
	cell.textLabel.text = loc.locationName;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedLocation = [favorites objectAtIndex:indexPath.row];
	[self performSegueWithIdentifier:@"map" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == favoritesTableView)
	{
		if (editingStyle == UITableViewCellEditingStyleDelete)
		{
			Location * loc = [[delegate.dataManagerInstance favorites] objectAtIndex:indexPath.row];
			favorites = [delegate.dataManagerInstance deleteFavoriteWithId:loc.locationId];
			
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadData];
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return @"Ta bort";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarCancelButtonClicked");
	favorites = [delegate.dataManagerInstance favorites];
	[favoritesTableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	// gör sökning med LocationService
	LocationService * service = [[LocationService alloc] init];
	NSString * escapedUrlString = [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	// vid resultathändelse, visa resultaten i favoritesTableView
	NSArray * result = [service search:escapedUrlString];
	
	// TODO: visa loader
	[progressSymbol startAnimating];
    [searchBar resignFirstResponder];
	
	[self performSegueWithIdentifier:@"search" sender:result];
	
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:YES animated:YES];
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:NO animated:YES];
	return YES;
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
	//[self setFilteredListContent:nil];
	[self setFavorites:nil];
    [self setFavoritesTableView:nil];
	[self setProgressSymbol:nil];
    [self setMapDestinationButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSIndexPath * selection = [favoritesTableView indexPathForSelectedRow];
	if (selection != nil)
	{
		[favoritesTableView deselectRowAtIndexPath:selection animated:YES];
	}
	
	favorites = [delegate.dataManagerInstance favorites];
	[favoritesTableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[progressSymbol stopAnimating];
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification" object: nil userInfo: nil];
	
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - rotation methods
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    switch (toInterfaceOrientation) 
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            [mapDestinationButton setBackgroundImage:[UIImage imageNamed:@"MapLocationViewDefaultBackgroundImage.png"] forState:UIControlStateNormal];
            [mapDestinationButton setBackgroundImage:[UIImage imageNamed:@"MapLocationViewHighlightedBackgroundImage.png"] forState:UIControlStateHighlighted];
            break;
        case UIDeviceOrientationLandscapeRight:
        case UIDeviceOrientationLandscapeLeft:
            [mapDestinationButton setBackgroundImage:[UIImage imageNamed:@"MapLocationViewLandscapeDefaultBackgroundImage.png"] forState:UIControlStateNormal];
            [mapDestinationButton setBackgroundImage:[UIImage imageNamed:@"MapLocationViewLandscapeHighlightedBackgroundImage.png"] forState:UIControlStateHighlighted];
            break;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	/*
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
	 */
	return YES;
}

- (IBAction)test:(id)sender {
}
@end
