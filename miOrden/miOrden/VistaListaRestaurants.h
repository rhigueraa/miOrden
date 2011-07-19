//
//  VistaListaRestaurants.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VistaListaRestaurants : UITableViewController {
    NSArray *listaRestaurants; 
    NSDictionary *laDir;
}
@property(assign) NSDictionary *laDir;
@end
