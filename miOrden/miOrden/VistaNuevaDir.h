//
//  VistaNuevaDir.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"
#import "XMLThreadedParser.h"

@interface VistaNuevaDir : UITableViewController<SCTableViewModelDelegate, XMLThreadedParserDelegate> {
    SCTableViewModel *tableModel;
    NSMutableArray *estadosArr;
    NSMutableArray *delegacionesArr;
    NSMutableArray *coloniasArr;
    NSMutableArray *zonasArr;
    NSMutableDictionary *direccion;
    NSArray *auxZonas;
    NSString *idZona;
    
}
@property(nonatomic,retain) NSMutableDictionary *direccion;
@end
