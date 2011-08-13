//
//  VistaMenu.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/14/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Three20/Three20.h>

@interface VistaMenu : UIViewController {
    NSDictionary *currentRestaurant;
    //TTTabBar* _tabBar1;
}
@property(assign) NSDictionary *currentRestaurant;
@end
