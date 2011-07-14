//
//  VistaMenu.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/14/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaMenu.h"
#import "VistaListaMenu.h"

@implementation VistaMenu


- (IBAction) tabIndexChanged{
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void) back{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void) addTab{
    UITabBarController *tabController = [[UITabBarController alloc] init];
    NSMutableArray *viewControllers = [NSMutableArray array];
    UIBarButtonItem *atras = [[UIBarButtonItem alloc] initWithTitle:@"Atrás" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    tabController.navigationItem.backBarButtonItem = atras;
    VistaListaMenu  *menu = [[VistaListaMenu alloc] initWithStyle:UITableViewStyleGrouped];
    menu.title = @"menu1";
    //menu.tabBarItem.image = [UIImage imageNamed:@"73-radar.png"];
    [viewControllers addObject:menu];
    [menu release];
    VistaListaMenu  *menu2 = [[VistaListaMenu alloc] initWithStyle:UITableViewStyleGrouped];
    menu2.title = @"menu2";
    //menu.tabBarItem.image = [UIImage imageNamed:@"73-radar.png"];
    [viewControllers addObject:menu2];
    [menu2 release];
    
    NSMutableArray *navegadores = [NSMutableArray array];
    
    UINavigationController *navCont;
    
    for (UIViewController *vc in viewControllers) {
        navCont = [[UINavigationController alloc] initWithRootViewController:vc];
        navCont.navigationBar.tintColor = [UIColor colorWithRed:4/255.0 green:81/255.0 blue:150/255.0 alpha:1.0];
        [navegadores addObject:navCont];
    }
    
    tabController.viewControllers = [NSArray arrayWithArray:navegadores];
    
    [self.navigationController pushViewController:tabController animated:YES];


}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self addTab];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
