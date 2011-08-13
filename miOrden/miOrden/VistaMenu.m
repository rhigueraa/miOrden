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
    
    _tabBar = [[[JSScrollableTabBar alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width, 44) style:JSScrollableTabBarStyleBlack] autorelease];
	[_tabBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[_tabBar setDelegate:self];
	[self.view addSubview:_tabBar];
    
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < 25; i++)
	{
		JSTabItem *item = [[JSTabItem alloc] initWithTitle:[NSString stringWithFormat:@"Itema %d", i]];
		[items addObject:item];
		[item release];
	}
	
	[_tabBar setTabItems:items];
    // Do any additional setup after loading the view from its nib.
}

- (void)scrollableTabBar:(JSScrollableTabBar *)tabBar didSelectTabAtIndex:(NSInteger)index
{
	NSLog(@"Selected tab: %d", index);
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
