//
//  VistaMenu.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/14/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaMenu.h"
#import "ItemConfigurationView.h"
#import <QuartzCore/QuartzCore.h>
#import "VistaCarrito.h"

@implementation VistaMenu
@synthesize currentRestaurant;

- (IBAction) tabIndexChanged{
    
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]); 
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
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
	//NSLog(@"Selected tab: %d", index);
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ItemConfigurationView *configView = [[ItemConfigurationView alloc] initWithStyle:UITableViewStyleGrouped];
    configView.delegate = self;
    configView.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    configView.itemId = [[itemList objectAtIndex:indexPath.row] valueForKey:@"id"];
    [self.navigationController pushViewController:configView animated:YES];
}

-(void)parser:(XMLThreadedParser*)parser didParseObject:(NSDictionary*)object{
    
}

- (void)shouldAddToCart:(NSDictionary*)itemConfiguration{
    shouldAnnimate = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray *carrito = [[NSUserDefaults standardUserDefaults] arrayForKey:@"carritoProducts"];
        NSMutableArray *mutCart = [carrito mutableCopy];
        
        NSIndexPath *indexPath = [theTable indexPathForSelectedRow];
        NSMutableDictionary *mutItem = [[itemList objectAtIndex:indexPath.row] mutableCopy];
        
        [mutItem setValuesForKeysWithDictionary:itemConfiguration];
        [mutItem setObject:[currentRestaurant valueForKey:@"id"] forKey:@"idRestaurant"];
        
        NSLog(@"Item is: %@",mutItem);
        
        //Calculate extras cost
        __block float totalItemPrice = 0;
        [[itemConfiguration valueForKey:@"selectedExtras"] enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
            [obj enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
                float price = [[obj valueForKey:@"precio"] floatValue];
                totalItemPrice+=price;
            }];
        }];
        [mutItem setValue:[NSNumber numberWithFloat:totalItemPrice] forKey:@"extrasPrice"];
        
        [mutCart addObject:mutItem];
        
        [[NSUserDefaults standardUserDefaults] setObject:mutCart forKey:@"carritoProducts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

- (void)animateView:(UIView*)view{
    
    view.backgroundColor = [UIColor blueColor];
    [self.view.window addSubview:view];
    
    [UIView animateWithDuration:1.0 animations:^(void) {
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        CGRect frame = view.frame;
        
        frame.origin = CGPointMake(20, 20);
        
        frame = CGRectMake(216+10, 368+40+20, 106, 50);
        
        view.frame = frame;
    }
                     completion:^(BOOL finished) 
     {
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
         [view removeFromSuperview];
         NSIndexPath *path = [theTable indexPathForSelectedRow];
         if (path) {
             [theTable deselectRowAtIndexPath:path animated:YES];
         }
         shouldAnnimate = NO;
         [[NSNotificationCenter defaultCenter] postNotificationName:@"CartUpdated" object:nil];
         //[(VistaCarrito*)[self.tabBarController.viewControllers objectAtIndex:2] updateBadge];
         //[[(UIViewController*)[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem] setBadgeValue:@"$50"];
     }];
}

- (void)viewDidAppear:(BOOL)animated{
    NSIndexPath *path = [theTable indexPathForSelectedRow];
    if (shouldAnnimate) {
        //[theTable deselectRowAtIndexPath:path animated:YES];
        UITableViewCell *cell = [theTable cellForRowAtIndexPath:path];
        
        UIImage *cellImage = [self imageWithView:cell];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:cellImage];
        
        CGRect frame = [theTable rectForRowAtIndexPath:path];
        
        CGPoint yOffset = theTable.contentOffset;
        frame = CGRectMake(frame.origin.x, (frame.origin.y + 45 - yOffset.y), frame.size.width, frame.size.height);
        
        frame.origin.y+=110;
        
        imageView.frame = frame;
        
        [self animateView:imageView];
    }
    else{
        if (path) {
            [theTable deselectRowAtIndexPath:path animated:YES];
        }
    }
}

- (void)forceTabSelection{
    if (categories.count) {
        XMLThreadedParser *itemParser = [[XMLThreadedParser alloc] init];
        itemParser.delegate = self;
        itemParser.tagg = [NSNumber numberWithInt:1];
        NSString *catId = [[categories objectAtIndex:0] valueForKey:@"category_id"];
        [itemParser parseXMLat:[NSURL URLWithString:[NSString stringWithFormat:@"http://miorden.com/demo/iphone/getRestItems.php?id=%@&category_id=%@",[currentRestaurant valueForKey:@"id"], catId]] withKey:@"item"];
    }
}

-(void)parser:(XMLThreadedParser*)parser didFinishParsing:(NSArray*)array{
    switch ([parser.tagg intValue]) {
        case 0:{
            //Categories
            /*
            array = [array sortedArrayUsingComparator:^(id a, id b) {
                NSString *first = [a objectForKey:@"ordering"];
                NSString *second = [b objectForKey:@"ordering"];
                return [first compare:second options:NSNumericSearch];
            }];
             */
            NSMutableArray *items = [NSMutableArray array];
            for (NSDictionary *dict in array) {
                JSTabItem *item = [[JSTabItem alloc] initWithTitle:[dict valueForKey:@"title"]];
                [items addObject:item];
                [item release];
            }
            [_tabBar setTabItems:items];
            categories = [[array mutableCopy] retain];
            [self forceTabSelection];
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
