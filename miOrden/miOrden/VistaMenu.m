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
    [_tabBar release];
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
    
    self.title = @"Menú";
    
    XMLThreadedParser *catParser = [[XMLThreadedParser alloc] init];
    catParser.delegate = self;
    catParser.tagg = [NSNumber numberWithInt:0];
    [catParser parseXMLat:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/categories.php?restaurant_id=%@",[currentRestaurant valueForKey:@"id"]]] withKey:@"category"];
    
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    
    _tabBar = [[[JSScrollableTabBar alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width, 44) andStyle:JSScrollableTabBarStyleBlack] autorelease];
	[_tabBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[_tabBar setDelegate:self];
	[self.view addSubview:_tabBar];
    
    theTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, applicationFrame.size.width, self.view.frame.size.height-44) style:UITableViewStylePlain];
    theTable.delegate = self;
    theTable.dataSource = self;
    theTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:theTable];
}

- (void)scrollableTabBar:(JSScrollableTabBar *)tabBar didSelectTabAtIndex:(NSInteger)index
{
	NSLog(@"Selected tab: %d", index);
    XMLThreadedParser *itemParser = [[XMLThreadedParser alloc] init];
    itemParser.delegate = self;
    itemParser.tagg = [NSNumber numberWithInt:1];
    NSString *catId = [[categories objectAtIndex:index] valueForKey:@"category_id"];
    [itemParser parseXMLat:[NSURL URLWithString:[NSString stringWithFormat:@"http://miorden.com/demo/iphone/getRestItems.php?id=%@&category_id=%@",[currentRestaurant valueForKey:@"id"], catId]] withKey:@"item"];
    //NSLog(@"Will parse at: %@", [NSString stringWithFormat:@"http://miorden.com/demo/iphone/getRestItems.php?id=%@&category_id=%@",[currentRestaurant valueForKey:@"id"], catId]);
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [itemList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ItemCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
    }

    cell.textLabel.text = [[itemList objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@",[[itemList objectAtIndex:indexPath.row] valueForKey:@"user_price"]];
    
    return cell;
}

-(void)parser:(XMLThreadedParser*)parser didParseObject:(NSDictionary*)object{
}

-(void)parser:(XMLThreadedParser*)parser didFinishParsing:(NSArray*)array{
    switch ([parser.tagg intValue]) {
        case 0:{
            //Categories
            NSMutableArray *items = [NSMutableArray array];
            for (NSDictionary *dict in array) {
                JSTabItem *item = [[JSTabItem alloc] initWithTitle:[dict valueForKey:@"title"]];
                [items addObject:item];
                [item release];
            }
            [_tabBar setTabItems:items];
            categories = [[array mutableCopy] retain];
        }
            break;
        case 1:
            itemList = [array retain];
            [theTable reloadData];
        default:
            break;
    }
}

@end
