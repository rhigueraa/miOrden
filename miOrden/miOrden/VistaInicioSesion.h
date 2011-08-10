//
//  VistaInicioSesion.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"
#import "XMLThreadedParser.h"

@interface VistaInicioSesion : UITableViewController <SCTableViewModelDelegate, XMLThreadedParserDelegate>{
    NSMutableArray *arregloUserId;
    SCTableViewModel *tableModel;
    NSString *ID;
}
@property (nonatomic,retain) NSString *ID;
@end
