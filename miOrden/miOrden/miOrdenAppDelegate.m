//
//  miOrdenAppDelegate.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "miOrdenAppDelegate.h"
#import "VistaInicioSesion.h"
#import "VistaCuentaPerfil.h"
#import "CustomActionNavigationController.h"
#import "VistaUnoOrden.h"
#import "VistaCarrito.h"
#import "JSONKit.h"

@implementation miOrdenAppDelegate


@synthesize window=_window;
@synthesize userID;

- (void)updateCartbadge{
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSArray *carrito = [[NSUserDefaults standardUserDefaults] arrayForKey:@"carritoProducts"];
    
    float tot = 0;
    for (NSDictionary* item in carrito) {
        tot+=[[item objectForKey:@"extrasPrice"] floatValue];
        tot+=[[item objectForKey:@"user_price"] floatValue];
    }
    UIViewController *cart= [[tabController viewControllers] objectAtIndex:2];
    
    if (tot>0) {
        cart.tabBarItem.badgeValue = [NSString stringWithFormat:@"$%.2f",tot];
    }
    else{
        cart.tabBarItem.badgeValue = nil;
    }
    
}

- (void)addAsTabBar{
   tabController = [[UITabBarController alloc] init];
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    VistaUnoOrden *orden = [[VistaUnoOrden alloc] initWithNibName:@"VistaUnoOrden" bundle:nil];
    orden.title = @"Nueva Orden";
    orden.tabBarItem.title = @"Buscar";
    orden.tabBarItem.image = [UIImage imageNamed:@"06-magnify.png"];
    [viewControllers addObject:orden];
    [orden release];
    
    VistaCuentaPerfil  *cuenta = [[VistaCuentaPerfil alloc] initWithStyle:UITableViewStyleGrouped];
    cuenta.title = @"Perfil";
    cuenta.tabBarItem.image = [UIImage imageNamed:@"111-user.png"];
    [viewControllers addObject:cuenta];
    [cuenta release];
    
    
    VistaCarrito *carrito = [[VistaCarrito alloc] initWithStyle:UITableViewStyleGrouped];
    carrito.title = @"Carrito";
    carrito.tabBarItem.image = [UIImage imageNamed:@"80-shopping-cart.png"];
    [viewControllers addObject:carrito];
    [carrito release];
    
    NSMutableArray *navegadores = [NSMutableArray array];
    
    UINavigationController *navCont;
    
    for (UIViewController *vc in viewControllers) {
        if (vc == orden) {
            navCont = [[CustomActionNavigationController alloc] initWithRootViewController:vc];
        }
        else{
            navCont = [[UINavigationController alloc] initWithRootViewController:vc];
        }
        //navCont.navigationBar.tintColor = [UIColor redColor];
        navCont.navigationBar.tintColor = [UIColor colorWithRed:195/255.0 green:1/255.0 blue:20/255.0 alpha:1.0];
        [navegadores addObject:navCont];
    }
    
    tabController.viewControllers = [NSArray arrayWithArray:navegadores];
    [self.window addSubview:tabController.view];
    VistaInicioSesion *inicio = [[VistaInicioSesion alloc] initWithStyle:UITableViewStyleGrouped];
    inicio.title =@"MiOrden";
    UINavigationController *temp = [[UINavigationController alloc] initWithRootViewController:inicio];
    //temp.navigationBar.tintColor = [UIColor redColor];
    temp.navigationBar.tintColor = [UIColor colorWithRed:195/255.0 green:1/255.0 blue:20/255.0 alpha:1.0];
    [tabController presentModalViewController:temp animated:NO];
    [inicio release];
    [temp release];
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"userKey"]){
        [self addAsTabBar];
        [tabController dismissModalViewControllerAnimated:YES];
    }else{
        [self addAsTabBar];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCartbadge) name:@"CartUpdated" object:nil];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
}

@end
