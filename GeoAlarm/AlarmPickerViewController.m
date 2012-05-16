//
//  AlarmPickerViewController.m
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-02-01.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "AlarmPickerViewController.h"
#import "Sound.h"
#import "AppDelegate.h"

@implementation AlarmPickerViewController

@synthesize sounds, currentAlarmName, saveSoundDelegate;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//NSLog(@"sounds: %@",[delegate.dataManagerInstance alarmSounds]);
	sounds = [delegate.dataManagerInstance alarmSounds];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	sounds = nil;
	currentAlarmName = nil;
	soundPlayer = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[soundPlayer stop];
	NSError *activationResult = nil;
	[[AVAudioSession sharedInstance] setActive: NO error: &activationResult];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	//NSLog(@"section: %i",section);
    return [sounds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	Sound * sound = [sounds objectAtIndex:indexPath.row];
	if ([sound.name isEqualToString:currentAlarmName])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.textLabel.text = sound.label;
    
    return cell;
}

- (NSInteger)numberOfSections
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Alarmljud";
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Sound * sound = [sounds objectAtIndex:indexPath.row];
	currentAlarmName = sound.name;
	
	[tableView reloadData];	
	NSError *activationResult = nil;
	[[AVAudioSession sharedInstance] setActive: YES error: &activationResult];
	
	NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:currentAlarmName ofType:@"caf"]];
    soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFile error:nil];
	[soundPlayer setDelegate:self];
	[soundPlayer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	NSError *activationResult = nil;
	[[AVAudioSession sharedInstance] setActive: NO error: &activationResult];
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

- (IBAction)saveSound:(id)sender 
{
	if ([self.saveSoundDelegate respondsToSelector:@selector(saveLocationWithAlarmName:)])
	{
		[self.saveSoundDelegate saveLocationWithAlarmName:currentAlarmName];
	}
	[self.navigationController popViewControllerAnimated:YES];
}
@end
