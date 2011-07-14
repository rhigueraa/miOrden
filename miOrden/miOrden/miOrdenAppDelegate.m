//
//  miOrdenAppDelegate.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "miOrdenAppDelegate.h"
#import "VistaInicioSesion.h"

#import "VistaUnoOrden.h"
@implementation miOrdenAppDelegate


@synthesize window=_window;

- (void)addAsTabBar{
    UITabBarController *tabController = [[UITabBarController alloc] init];
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    VistaInicioSesion  *inicio = [[VistaInicioSesion alloc] initWithStyle:UITableViewStyleGrouped];
    inicio.title = @"Perfil";
    //reservacionesVC.tabBarItem.image = [UIImage imageNamed:@"73-radar.png"];
    [viewControllers addObject:inicio];
    [inicio release];
    
    VistaUnoOrden *orden = [[VistaUnoOrden alloc] initWithStyle:UITableViewStyleGrouped];
    orden.title = @"Nueva Orden";
    //serviciosVC.tabBarItem.image = [UIImage imageNamed:@"112-group.png"];
    [viewControllers addObject:orden];
    [orden release];
    
    NSMutableArray *navegadores = [NSMutableArray array];
    
    UINavigationController *navCont;
    
    for (UIViewController *vc in viewControllers) {
        navCont = [[UINavigationController alloc] initWithRootViewController:vc];
        //navCont.navigationBar.tintColor = [UIColor colorWithRed:4/255.0 green:81/255.0 blue:150/255.0 alpha:1.0];
        [navegadores addObject:navCont];
    }
    
    tabController.viewControllers = [NSArray arrayWithArray:navegadores];
    
    [self.window setRootViewController:tabController];
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self addAsTabBar];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
