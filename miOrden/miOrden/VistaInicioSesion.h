//
//  VistaInicioSesion.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"

@interface VistaInicioSesion : UITableViewController <SCTableViewModelDelegate>{
    NSMutableDictionary *inicioSesionData;
    SCTableViewModel *tableModel;
}

@end
