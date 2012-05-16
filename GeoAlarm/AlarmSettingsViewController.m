//
//  AlarmSettingsViewController.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-02-01.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "AlarmSettingsViewController.h"
#import "Sound.h"

@implementation AlarmSettingsViewController
@synthesize radiusSlider;
@synthesize radiusLabel,selectedRadius, loc, settingsTableView, alarmSettingsDelegate, lastQuestionStep, stepValue;

- (IBAction)radiusSelectorChange:(id)sender 
{
	UISlider * slider = sender;
    float newStep = roundf((slider.value) / self.stepValue);
    
    // Convert "steps" back to the context of the sliders values.
    slider.value = selectedRadius = newStep * self.stepValue;
    
	radiusLabel.text = [NSString stringWithFormat:@"%i m", (int) slider.value];
}

-(void)saveLocationWithAlarmName:(NSString *)alarmName
{
	if (![loc.alarmName isEqualToString:alarmName] || loc.alarmRadius != selectedRadius)
	{
		NSLog(@"saveLocationWithAlarmName: %@, radius: %i",alarmName, selectedRadius);
		loc.alarmRadius = selectedRadius;
		loc.alarmName = alarmName;
		if ([delegate.dataManagerInstance isFavorite:loc.locationId])
		{
			[delegate.dataManagerInstance updateFavorite:loc];
		}
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"sound"]) 
	{
		AlarmPickerViewController * destinationController = [segue destinationViewController];
		destinationController.currentAlarmName = loc.alarmName;
		destinationController.saveSoundDelegate = self;
	}
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [super viewDidLoad];
    
    // Set the step to whatever you want. Make sure the step value makes sense
    //   when compared to the min/max values for the slider. You could take this
    //   example a step further and instead use a variable for the number of
    //   steps you wanted.
    self.stepValue = 50.0f;
    
    // Set the initial value to prevent any weird inconsistencies.
    self.lastQuestionStep = (self.radiusSlider.value) / self.stepValue;
    
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
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
	
	switch (indexPath.row) 
	{
		case 0:
		{
            cell.textLabel.text = @"Spara destination";
			if([delegate.dataManagerInstance isFavorite:loc.locationId])
			{
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			else
			{
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			cell.detailTextLabel.text = @"";
			break;
		}
		case 1:
			cell.textLabel.text = @"Ljud";
			cell.detailTextLabel.text = [delegate.dataManagerInstance alarmSoundWithName:loc.alarmName].label;
			break;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row) 
	{
		case 0:
		{
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			if([delegate.dataManagerInstance isFavorite:loc.locationId])
			{
				// ta bort favorit
				[delegate.dataManagerInstance deleteFavoriteWithId:loc.locationId];
			}
			else
			{
				// spara som favorit
				[delegate.dataManagerInstance saveFavorite:loc];
			}
			[tableView reloadData];
			break;
		}
		
		case 1:
		{
			[self performSegueWithIdentifier:@"sound" sender:[tableView cellForRowAtIndexPath:indexPath]];
			break;
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[alarmSettingsDelegate updateAlarmSettings:selectedRadius];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSIndexPath * selection = [settingsTableView indexPathForSelectedRow];
	if (selection != nil)
	{
		[settingsTableView deselectRowAtIndexPath:selection animated:YES];
	}
	[radiusLabel setText:[NSString stringWithFormat:@"%i m", selectedRadius]];
	[radiusSlider setValue:(float)selectedRadius animated:YES];
	
	[settingsTableView reloadData];
}

- (void)viewDidUnload
{
	[self setRadiusLabel:nil];
	[self setRadiusSlider:nil];
	[super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	settingsTableView = nil;
	loc = nil;
	delegate = nil;
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
