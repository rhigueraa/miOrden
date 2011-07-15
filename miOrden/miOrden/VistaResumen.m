//
//  VistaResumen.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/14/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaResumen.h"
#import "VistaTicket.h"

@implementation VistaResumen

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
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Resumen de Compra";
    NSDictionary *resumen1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"123",@"NumeroOrdenKey", @"$4567",@"TotalKey",@"domicilio",@"EntregaKey",@"los chilakos",@"RestauranteKey",@"3452345",@"TelefonoKey",@"direccion 1 bla bla1",@"DireccionKey",@"efectivo",@"TipoKey",@"98765",@"telContactoKey",nil];
    resumen = [[NSArray alloc] initWithObjects:resumen1 , nil];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Configure the cell...
    switch (indexPath.row) {
        case 1:
            cell.textLabel.text = @"# Orden";
            cell.detailTextLabel.text = [[resumen objectAtIndex:0]objectForKey:@"NumeroOrdenKey"];
            break;
        case 2:
            cell.textLabel.text = @"Total";
            cell.detailTextLabel.text = [[resumen objectAtIndex:0]objectForKey:@"TotalKey"];
            break;
        case 3:
            cell.textLabel.text = @"Entrega";
            cell.detailTextLabel.text = [[resumen objectAtIndex:0]objectForKey:@"EntregaKey"];
            break;
        case 4:
            cell.textLabel.text = @"Restaurante";
            cell.detailTextLabel.text = [[resumen objectAtIndex:0]objectForKey:@"RestauranteKey"];
            break;
        case 5:
            cell.textLabel.text = @"Teléfono Restaurante";
            cell.detailTextLabel.text = [[resumen objectAtIndex:0]objectForKey:@"TelefonoKey"];
            break;
        case 6:
            cell.textLabel.text = @"Dirección de Entrega";
            cell.detailTextLabel.text = [[resumen objectAtIndex:0]objectForKey:@"DireccionKey"];
            break;
        case 7:
            cell.textLabel.text = @"Tipo de Pago";
            cell.detailTextLabel.text = [[resumen objectAtIndex:0]objectForKey:@"TipoKey"];
            break;
        case 8:
            cell.textLabel.text = @"Teléfono Contacto";
            cell.detailTextLabel.text = [[resumen objectAtIndex:0]objectForKey:@"telContactoKey"];
            break;
        case 9:
            cell.textLabel.text = @"Ver Ticket";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
            
        default:
            break;
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
    if(indexPath.section == 8){
        VistaTicket *ticket = [[VistaTicket alloc]initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:ticket animated:YES];
        [ticket release];
        
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
