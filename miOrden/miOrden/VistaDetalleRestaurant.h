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
#import <QuartzCore/QuartzCore.h>

typedef enum {
    restaurantStateOpen,
    restaurantStateClosed,
    restaurantStateUnknown
} RestaurantState;

@interface VistaDetalleRestaurant : UIViewController<UITableViewDelegate, ATPagingViewDelegate, MKMapViewDelegate> {
    RestaurantState currentRestaurantState;
    
    UITableView  *table;
    UIView *pagedView;
    UITableView *table2;
    MKMapView *theMapView;
    ATPagingView *pagedVIew;
    UIPageControl *pageControl;
    UIView *restaruanExtraDetailView;
    UIImageView *restaruantImageView;
    UITextView *direccion;
    NSMutableDictionary *currentRestaurant;
    int numeroResenias;
    
    BOOL open;
    
    NSArray *times;
    NSDictionary *hours;
}
@property (nonatomic, retain) IBOutlet UIImageView *restaruantImageView;
@property (nonatomic, assign) NSMutableDictionary *currentRestaurant;
@property (nonatomic, retain) IBOutlet UIView *restaruanExtraDetailView;
@property(nonatomic,retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIView *pagedView;
@property (nonatomic, retain) IBOutlet UITableView *table2;
@property (nonatomic, retain) IBOutlet UITextView *direccion;

@end
