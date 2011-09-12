//
//  VistaMenu.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/14/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Three20/Three20.h>
#import "JSScrollableTabBar.h"
#import "XMLThreadedParser.h"
#import "ItemConfigurationView.h"

@interface VistaMenu : UIViewController <JSScrollableTabBarDelegate, UITableViewDelegate, UITableViewDataSource, XMLThreadedParserDelegate, ItemConfigurationDelegate> {
    NSDictionary *currentRestaurant;
    JSScrollableTabBar *_tabBar;
    UITableView *theTable;
    NSMutableArray *categories;
    
    NSArray *itemList;
    
    BOOL shouldAnnimate;
}
@property(assign) NSDictionary *currentRestaurant;
@end
