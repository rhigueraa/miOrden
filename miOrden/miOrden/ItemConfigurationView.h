//
//  ItemConfigurationView.h
//  miOrden
//
//  Created by Sebastian Barrios on 9/4/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"
#import "XMLThreadedParser.h"

@protocol ItemConfigurationDelegate;

@interface ItemConfigurationView : UITableViewController <SCTableViewModelDelegate, XMLThreadedParserDelegate>{
    SCTableViewModel *tableModel;
    
    NSArray *allExtras;
}

@property(nonatomic, retain) NSString *itemId;
@property(nonatomic, assign) id<ItemConfigurationDelegate> delegate;

@end

@protocol ItemConfigurationDelegate <NSObject>

-(void)shouldAddToCart;

@end
