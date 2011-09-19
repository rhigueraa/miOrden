//
//  VistaListaRestaurants.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaListaRestaurants.h"
#import "VistaDetalleRestaurant.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation VistaListaRestaurants
@synthesize laDir, zonaID;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [listaRestaurants release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


-(void)parser:(XMLThreadedParser*)parser didParseObject:(NSDictionary*)object{
    //NSLog(@"Did parse: %@", object);
}



-(void)parser:(XMLThreadedParser*)parser didFinishParsing:(NSArray*)array{
    listaRestaurants = [array retain];
    filteredRestaurants = [[NSMutableArray alloc] initWithArray:listaRestaurants];
    
    cocinas = [[NSMutableArray alloc] initWithCapacity:[array count]];
    [listaRestaurants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if (![cocinas containsObject:[obj valueForKey:@"rest_type"]]) {
            [cocinas addObject:[obj valueForKey:@"rest_type"]];
        }
        
    }];
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)filter:(UIBarButtonItem*)sender{
    
    //NSLog(@"Restaurants are: %@", filteredRestaurants);
    
    FilterTableView *filterTable = [[FilterTableView alloc] initWithStyle:UITableViewStyleGrouped];
    filterTable.delegate = self;
    filterTable.title = @"Filtro";
    filterTable.cocinas = cocinas;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:filterTable];
    navController.navigationBar.tintColor = [UIColor colorWithRed:195/255.0 green:1/255.0 blue:20/255.0 alpha:1.0];
    
    [self presentModalViewController:navController animated:YES];
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = @"Restaurants";
    XMLThreadedParser *parser = [[XMLThreadedParser alloc] init];
    parser.delegate = self;
    if(self.zonaID == nil)
        [parser parseXMLat:[NSURL URLWithString:@"http://www.miorden.com/demo/iphone/restaurantlist.php"] withKey:@"restaurant"];
    else{
        /*
        NSString *URLString = [NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/restaurantListByZone.php?zone=%@",zonaID];
        NSLog(@"Will parse URL: %@",URLString);
        __block ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
        [request setCompletionBlock:^(void){
            NSString *resposne = [request responseString];
            listaRestaurants = [[resposne objectFromJSONString] retain];
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }];
        [request startAsynchronous];
         */
        if ([self.zonaID isEqualToString:@""]) {
            [parser parseXMLat:[NSURL URLWithString:@"http://www.miorden.com/demo/iphone/restaurantlist.php"] withKey:@"restaurant"];
        }
        NSLog(@"String is: %@",[NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/restaurantlist.php?zone=%@",zonaID]);
        [parser parseXMLat:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/restaurantlist.php?zone=%@",zonaID]] withKey:@"restaurant"];
        
        UIBarButtonItem *filter = [[UIBarButtonItem alloc] initWithTitle:@"Filtro" style:UIBarButtonItemStyleDone target:self action:@selector(filter:)];
        self.navigationItem.rightBarButtonItem = filter;
        [filter release];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filteredRestaurants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.imageView.layer.cornerRadius = 10.0;
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.imageView.layer.borderWidth = 1.0;
    }
    
    // Configure the cell...
    NSDictionary *rest = [filteredRestaurants objectAtIndex:indexPath.row];
    cell.textLabel.text = [rest objectForKey:@"name"];
    
    NSString *logoURL = [rest objectForKey:@"logo"];
    
    NSRange range = [logoURL rangeOfString:@"http://www.miorden.com/res/thumbs/"];
    
    if (!range.length>0) {
        logoURL = [NSString stringWithFormat:@"http://www.miorden.com/res/thumbs/%@",logoURL];
    }
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:logoURL] placeholderImage:[UIImage imageNamed:@"placeholder-recipe-44.gif"]];
    //cell.imageView.contentMode = UIViewContentModeCenter;
    return cell;
}

- (void)filterDidFinishWithPredicate:(NSPredicate *)predicate{
    
    filteredRestaurants = [[NSMutableArray alloc] initWithArray:listaRestaurants];
    [filteredRestaurants filterUsingPredicate:predicate];
    
    [self dismissModalViewControllerAnimated:YES];
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *carrito = [[NSUserDefaults standardUserDefaults] arrayForKey:@"carritoProducts"];
    BOOL imediatePush= YES;
    for (NSDictionary* dict in carrito) {
        NSString *cartRestaurant = [dict valueForKey:@"idRestaurant"];
        NSString *listRestaurant = [[filteredRestaurants objectAtIndex:indexPath.row] valueForKey:@"id"];
        if (![cartRestaurant isEqualToString:listRestaurant]) {
            imediatePush = NO;
            
        }
        break;
    }
    if (imediatePush) {
        VistaDetalleRestaurant *detalle = [[VistaDetalleRestaurant alloc] init];
        detalle.title = [[[tableView cellForRowAtIndexPath:indexPath]textLabel]text];
        detalle.currentRestaurant = [filteredRestaurants objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detalle animated:YES];
        [detalle release];
    }else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Atención" message:@"Selecionar un restaurant diferente al de la orden acutal borrará todos los productos que estan actualmente en el carrito." delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Continuar", nil];
        [alertView show];
        [alertView release];
    }
    
}

- (void)emptyCart{
    [[NSUserDefaults standardUserDefaults] setValue:[NSArray array] forKey:@"carritoProducts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (buttonIndex == 1) {
        //Empty cart
        [self emptyCart];
        if (indexPath) {
            VistaDetalleRestaurant *detalle = [[VistaDetalleRestaurant alloc] init];
            detalle.title = [[[self.tableView cellForRowAtIndexPath:indexPath]textLabel]text];
            detalle.currentRestaurant = [filteredRestaurants objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:detalle animated:YES];
            [detalle release];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
