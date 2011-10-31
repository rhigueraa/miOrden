//
//  VistaPerfil.h
//  miOrden
//
//  Created by Rodrigo Higuera on 10/18/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"
#import "XMLThreadedParser.h"

@interface VistaPerfil : UITableViewController<SCTableViewModelDelegate, XMLThreadedParserDelegate>{
    SCTableViewModel *tableModel;
    NSMutableDictionary *datos;
    SCSegmentedCell *sexo;
    SCSwitchCell *terminos;
}


@end
