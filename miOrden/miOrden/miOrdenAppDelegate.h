//
//  miOrdenAppDelegate.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface miOrdenAppDelegate : NSObject <UIApplicationDelegate> {
    NSString *userID;
    UITabBarController *tabController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSString *userID;
@end
