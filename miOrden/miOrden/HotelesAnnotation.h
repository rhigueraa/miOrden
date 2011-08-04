//
//  HotelesAnnotation.h
//  Hoteles
//
//  Created by Rodrigo Higuera on 7/5/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HotelesAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D _coordinate;
	NSString *_title;

	NSDictionary *_hotel;
    
}

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;

@property(assign) NSDictionary *hotel;

+ (id)annotationWithHotel:(NSDictionary *)hotel;
- (id)initWithHotel:(NSDictionary *)hotel;

@end