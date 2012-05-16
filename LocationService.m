//
//  LocationService.m
//  SearchTable
//
//  Created by Johan Månsson on 2012-01-18.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import "LocationService.h"

WGS84Coord WGS84CoordMake(float longitude, float latitude){
	WGS84Coord coords;
	coords.longitude = longitude;
	coords.latitude = latitude;
	return coords;
}

@implementation LocationService

-(NSArray *)search:(NSString *)searchStr
{
	result = [[NSMutableArray alloc] init];
	isStartPoint = NO;
	
	// gör sökning
	NSString * queryResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.labs.skanetrafiken.se/v2.2/querystation.asp?inpPointfr=%@",searchStr]] encoding:NSUTF8StringEncoding error:nil];
	
	NSData * data=[queryResult dataUsingEncoding:NSUTF8StringEncoding];
	
	NSXMLParser * xmlParser = [[NSXMLParser alloc] initWithData:data];
	[xmlParser setDelegate:self];
	[xmlParser setShouldProcessNamespaces:NO]; // We don't care about namespaces
    [xmlParser setShouldReportNamespacePrefixes:NO]; //
    [xmlParser setShouldResolveExternalEntities:NO]; // We just want data, no other stuff
	
	[xmlParser parse];
	
	// TODO: hantera error
	
	xmlParser = nil;
	data = nil;
	queryResult = nil;
	currentLocation = nil;
	currentProperty = nil;
	
	return result;
}

-(WGS84Coord)convertRT90ToWGS84:(NSInteger)coordX coordY:(NSInteger)coordY
{
	float axis = 6378137.0;
	float flattening = 1.0 / 298.257222101;
	float centralMeridian = 15.0 + 48.0 / 60.0 + 22.624306 / 3600.0;
	float scale = 1.00000561024;
	float falseNorthering = -667.711;
	float falseEasting = 1500064.274;
	
	float e2 = flattening * (2.0 - flattening);
	float n = flattening / (2.0 - flattening);
	float aRoof = axis / (1.0 + n) * (1.0+n*n/4.0 + n*n*n*n/64.0);
	float delta1 = n/2.0 - 2.0*n*n/3.0 + 37.0*n*n*n/96.0 - n*n*n*n/360.0;
	float delta2 = n*n/48.0 + n*n*n/15.0 - 437.0*n*n*n*n/1440.0;
	float delta3 = 17.0*n*n*n/480.0 - 37*n*n*n*n/840.0;
	float delta4 = 4397.0*n*n*n*n/161280.0;
	
	float aStar = e2 + e2*e2 + e2*e2*e2 + e2*e2*e2*e2;
	float bStar = -(7.0*e2*e2 + 17.0*e2*e2*e2 + 30.0*e2*e2*e2*e2) / 6.0;
	float cStar = (224.0*e2*e2*e2+889.0*e2*e2*e2*e2) / 120.0;
	float dStar = -(4279.0*e2*e2*e2*e2) / 1260.0;
	
	// konvertera
	float degToRad = M_PI / 180;
	float lambdaZero = centralMeridian * degToRad;
	float xi = (coordX - falseNorthering) / (scale * aRoof);
	float eta = (coordY - falseEasting) / (scale * aRoof);
	float xiPrim = xi -
		delta1*sin(2.0*xi) * cosh(2.0*eta) -
		delta2*sin(4.0*xi) * cosh(4.0*eta) -
		delta3*sin(6.0*xi) * cosh(6.0*eta) -
		delta4*sin(8.0*xi) * cosh(8.0*eta);
	
	float etaPrim = eta -
		delta1*cos(2.0*xi) * sinh(2.0*eta) -
		delta2*cos(4.0*xi) * sinh(4.0*eta) -
		delta3*cos(6.0*xi) * sinh(6.0*eta) -
		delta4*cos(8.0*xi) * sinh(8.0*eta);
	
	float phiStar = asin(sin(xiPrim) / cosh(etaPrim));
	float deltaLambda = atan(sinh(etaPrim) / cos(xiPrim));
	float lonRadian = lambdaZero + deltaLambda;
	float latRadian = phiStar + sin(phiStar) * cos(phiStar) * (aStar +
															   bStar*pow(sin(phiStar), 2.0) +
															   cStar*pow(sin(phiStar), 4.0) +
															   dStar*pow(sin(phiStar), 6.0));
	// convertera koordinaterna
	float lat = latRadian * 180.0 / M_PI;
	float lon = lonRadian * 180.0 / M_PI;
	
	return WGS84CoordMake(lat, lon);
}
-(float)sinh:(double)value
{
	return 0.5 * (exp(value) - exp(-value));
}
-(float)cosh:(double)value
{
	return 0.5 * (exp(value) + exp(-value));
}
-(float)atanh:(double)value
{
	return 0.5 * log((1.0 + value) / (1.0 - value));
}

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"StartPoints"])
	{
		isStartPoint = YES;
	}
	
	if (isStartPoint)
	{
		if ([elementName isEqualToString:@"Point"])
		{
			currentLocation = [[Location alloc] init];
		} 
		
		if ([elementName isEqualToString:@"Id"] || [elementName isEqualToString:@"Name"] ||[elementName isEqualToString:@"X"] || [elementName isEqualToString:@"Y"])
		{
			currentProperty = [NSMutableString string];
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (currentProperty) {
        [currentProperty appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"StartPoints"])
	{
		isStartPoint = NO;
	}
	
	if (isStartPoint)
	{
		if ([elementName isEqualToString:@"Point"])
		{
			// konverera RT90 koordinater till WGS84 koordinater
			WGS84Coord geodeticLocation = [self convertRT90ToWGS84:gridCoordX coordY:gridCoordY];
			
			// av någon anledning jag inte förstår byter lat och lng plats
			// kompenserar för detta här.
			currentLocation.latitude = geodeticLocation.longitude;
			currentLocation.longitude = geodeticLocation.latitude;
			currentLocation.alarmName = @"carhorns";
			currentLocation.alarmRadius = DEFAULT_ALARM_RADIUS;
			
			[result addObject:currentLocation];
			currentLocation = nil;
		}
		
		if ([elementName isEqualToString:@"Name"])
		{
			currentLocation.locationName = currentProperty;
		}
		else if ([elementName isEqualToString:@"Id"])
		{
			currentLocation.locationId = [currentProperty intValue];			
		}
		else if ([elementName isEqualToString:@"X"])
		{
			gridCoordX = [currentProperty intValue];
		}
		else if ([elementName isEqualToString:@"Y"])
		{
			gridCoordY = [currentProperty intValue];
		}
		
		currentProperty = nil;
	}
	
}

@end