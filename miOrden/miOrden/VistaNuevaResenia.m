//
//  VistaNuevaResenia.m
//  miOrden
//
//  Created by Rodrigo Higuera on 8/14/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaNuevaResenia.h"


@implementation VistaNuevaResenia
@synthesize currentRestaurant;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)enviar{
    XMLThreadedParser *parser = [[XMLThreadedParser alloc]init];
    parser.delegate = self;
    NSString *cadena = [NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/addreview.php?title=%@&description=%@&user_id=%@&rest_id=%@%22,@%22Review",[tableModel.modelKeyValues valueForKey:@"tituloKey"],[tableModel.modelKeyValues valueForKey:@"descripcionKey"],[[NSUserDefaults standardUserDefaults]valueForKey:@"userIdKey"],[currentRestaurant valueForKey:@"id"]];
    cadena = [cadena stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSLog(@"%@",cadena);
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
    SCTableViewSection *section = [[SCTableViewSection alloc] initWithHeaderTitle:@"Introducir los Datos"];
    
    SCTextFieldCell *titulo = [[SCTextFieldCell alloc]initWithText:@"Título" withPlaceholder:@"escribe un título" withBoundKey:@"tituloKey" withTextFieldTextValue:nil];
    SCTextFieldCell *descripcion  = [[SCTextFieldCell alloc]initWithText:@"Descripción" withPlaceholder:@"escribe tus comentarios" withBoundKey:@"descripcionKey" withTextFieldTextValue:nil];
    
    UIBarButtonItem *enviar = [[UIBarButtonItem alloc] initWithTitle:@"Enviar" style:UIBarButtonItemStyleBordered target:self action:@selector(enviar)];
    self.navigationItem.rightBarButtonItem = enviar;
    
    [section addCell:titulo];
    [section addCell:descripcion];
    [tableModel addSection:section];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

-(void)parser:(XMLThreadedParser*)parser didParseObject:(NSDictionary*)object{
    
}



-(void)parser:(XMLThreadedParser*)parser didFinishParsing:(NSArray*)array{
    
}

@end
