//
//  VistaListaRestaurants.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMLThreadedParser.h"


@interface VistaListaRestaurants : UITableViewController<XMLThreadedParserDelegate> {
    NSString *zonaID;
    NSArray *listaRestaurants; 
    NSDictionary *laDir;
}
@property(assign) NSDictionary *laDir;
@property(nonatomic,retain) NSString *zonaID;
@end
