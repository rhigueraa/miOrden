//
//  VistaFormaCheckOut.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/15/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"

@interface VistaFormaCheckOut : UITableViewController <SCTableViewModelDelegate> {
    SCTableViewModel *tableModel;
    NSArray *listaRfc;
}

@end
