//
//  VistaMenu.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/14/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaMenu.h"


@implementation VistaMenu
@synthesize currentRestaurant;

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
    //TT_RELEASE_SAFELY(_tabBar1);
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


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    /*
    _tabBar1 = [[TTTabStrip alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width, 41)];
    _tabBar1.tabItems = [NSArray arrayWithObjects:
                         [[[TTTabItem alloc] initWithTitle:@"Item 1"] autorelease],
                         [[[TTTabItem alloc] initWithTitle:@"Item 2"] autorelease],
                         [[[TTTabItem alloc] initWithTitle:@"Item 3"] autorelease],
                         [[[TTTabItem alloc] initWithTitle:@"Item 4"] autorelease],
                         [[[TTTabItem alloc] initWithTitle:@"Item 5"] autorelease],
                         [[[TTTabItem alloc] initWithTitle:@"Item 6"] autorelease],
                         [[[TTTabItem alloc] initWithTitle:@"Item 7"] autorelease],
                         [[[TTTabItem alloc] initWithTitle:@"Item 8"] autorelease],
                         [[[TTTabItem alloc] initWithTitle:@"Item 9"] autorelease],
                         [[[TTTabItem alloc] initWithTitle:@"Item 10"] autorelease],
                         nil];
    [self.view addSubview:_tabBar1];
    */
    
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
