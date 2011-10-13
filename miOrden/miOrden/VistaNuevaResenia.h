//
//  VistaNuevaResenia.h
//  miOrden
//
//  Created by Rodrigo Higuera on 8/14/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"
#import "XMLThreadedParser.h"
@interface VistaNuevaResenia : UITableViewController<SCTableViewModelDelegate, XMLThreadedParserDelegate>{
    SCTableViewModel *tableModel;
    NSMutableDictionary *currentRestaurant;
}
@property(nonatomic,retain) NSMutableDictionary *currentRestaurant;


@end