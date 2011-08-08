//
//  VistaResenias.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/18/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMLThreadedParser.h"

@interface VistaResenias : UITableViewController<XMLThreadedParserDelegate>{
    NSMutableArray *resenias;
    NSMutableDictionary *currentRestaurant;
}
@property(assign) NSMutableDictionary *currentRestaurant;
@property(assign) NSMutableArray *resenias;
@end
