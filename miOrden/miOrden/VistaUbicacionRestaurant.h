//
//  VistaUbicacionRestaurant.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface VistaUbicacionRestaurant : UIViewController<UITableViewDelegate, MKMapViewDelegate> {
    IBOutlet UITableViewController *table;
    IBOutlet MKMapView *mapView;
    
}

@end
