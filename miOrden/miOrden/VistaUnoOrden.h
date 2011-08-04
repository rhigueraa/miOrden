//
//  VistaUnoOrden.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMLThreadedParser.h"

@interface VistaUnoOrden : UITableViewController<XMLThreadedParserDelegate> {
    
    NSArray *direcciones;
    NSArray *zonas;
       
}


@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UISegmentedControl *control;

@end
