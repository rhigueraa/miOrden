//
//  VistaUnoOrden.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaUnoOrden.h"
#import "VistaListaRestaurants.h"

@implementation VistaUnoOrden
@synthesize table, control;

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
    [direcciones release];
    [zonas release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void) segmentAction:(UISegmentedControl*)segmented{

    [self.table beginUpdates];
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.table endUpdates];
}




#pragma mark - View lifecycle
- (void)addSegmented{
	[control addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addSegmented];
    
    XMLThreadedParser *parser = [[XMLThreadedParser alloc] init];
    parser.delegate = self;
    parser.tagg = [NSNumber numberWithInt:1];
    [parser parseXMLat:[NSURL URLWithString:@"http://www.miorden.com/demo/iphone/zones.php"]  withKey:@"zone"];
    
    
        
    direcciones = [[NSArray alloc] init];
   
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)parser:(XMLThreadedParser*)parser didParseObject:(NSDictionary*)object{
    
}


-(void)parser:(XMLThreadedParser*)parser didFinishParsing:(NSArray*)array{
    switch ([parser.tagg intValue]) {
        case 1:
            zonas = [array retain];
            break;
        case 2:
            direcciones = [array retain];
            break;
        default:
            break;
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    XMLThreadedParser *parser2 = [[XMLThreadedParser alloc]init];
    parser2.delegate = self;
    parser2.tagg = [NSNumber numberWithInt:2];
    NSString *cadena = [NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/locationlist.php?user_id=%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"userIdKey"]];
    [parser2   parseXMLat:[NSURL URLWithString:cadena] withKey:@"location"];
    
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

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(control.selectedSegmentIndex == 0){
        return @"Direcciones";
    }
    else{
        return @"Zonas";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(control.selectedSegmentIndex == 0) return [direcciones count];
    else return [zonas count];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(control.selectedSegmentIndex == 0){
        return 100.0;
    }else{
        return 50.0;
    }
        
}
//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // Configure the cell...
    if(control.selectedSegmentIndex == 0){
        cell.textLabel.text = [[direcciones objectAtIndex:indexPath.row] valueForKey:@"title_loc"];
        NSString *cadena = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",[[direcciones objectAtIndex:indexPath.row] valueForKey:@"address"],[[direcciones objectAtIndex:indexPath.row] valueForKey:@"colony"],[[direcciones objectAtIndex:indexPath.row] valueForKey:@"delegation"],[[direcciones objectAtIndex:indexPath.row] valueForKey:@"state"],[[direcciones objectAtIndex:indexPath.row] valueForKey:@"telephone"]];
        cell.detailTextLabel.numberOfLines = 5;
        cell.detailTextLabel.text = cadena;   
        
    }else{
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = [[zonas objectAtIndex:indexPath.row] valueForKey:@"title"];
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VistaListaRestaurants *lista = [[VistaListaRestaurants alloc] initWithStyle:UITableViewStylePlain];
    lista.title = @"Restaurants";
    if(control.selectedSegmentIndex == 0)
        lista.laDir = [direcciones objectAtIndex:indexPath.row];
    else{
        lista.laDir = [zonas objectAtIndex:indexPath.row];
        lista.zonaID = [[zonas objectAtIndex:indexPath.row] valueForKey:@"zone_id"];

}
    [self.navigationController pushViewController:lista animated:YES];
    [lista release];
}

@end
