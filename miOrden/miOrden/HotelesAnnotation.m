//
//  HotelesAnnotation.m
//  Hoteles
//
//  Created by Rodrigo Higuera on 7/5/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "HotelesAnnotation.h"
//#import "HotelesViewController.h"


//static NSString* hotelDistanceKey = @"Distancia";
static NSString* latitud = @"latitudKey";
static NSString* longitud = @"longitudKey";

@implementation HotelesAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;

@synthesize hotel = _hotel;
+ (id)annotationWithHotel:(NSDictionary *)hotel {
	return [[[[self class] alloc] initWithHotel:hotel] autorelease];
}

- (id)initWithHotel:(NSDictionary *)hotel{
	self = [super init];
	if(nil != self) {
        CLLocationCoordinate2D coordenadas;
        coordenadas.latitude = [[hotel valueForKey:latitud] floatValue];
        coordenadas.longitude = [[ hotel valueForKey:longitud] floatValue];
        self.coordinate = coordenadas;
        self.hotel = hotel;
	}
	return self;
}

- (void) dealloc {
	self.title = nil;
	self.hotel = nil;
	[super dealloc];
}



@end
