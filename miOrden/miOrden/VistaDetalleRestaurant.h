//
//  VistaDetalleRestaurant.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATPagingView.h"
#import <MapKit/MapKit.h>

@interface VistaDetalleRestaurant : UIViewController<UITableViewDelegate, ATPagingViewDelegate, MKMapViewDelegate> {
    UITableView  *table;
    UIView *pagedView;
    MKMapView *theMapView;
    ATPagingView *pagedVIew;
    UIPageControl *pageControl;
}

@property(nonatomic,retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIView *pagedView;

@end
