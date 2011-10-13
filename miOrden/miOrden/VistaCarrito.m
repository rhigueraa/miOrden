//
//  VistaCarrito.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/15/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaCarrito.h"
#import "VistaFormaCheckOut.h"


static NSString *nameKey = @"title";
static NSString *priceKey = @"user_price";

@implementation VistaCarrito

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        carrito = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"carritoProducts"] retain];
        [self updateBadge];
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

-(void)comprar{
    VistaFormaCheckOut *check = [[VistaFormaCheckOut alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:check animated:YES];
    [check release];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    carrito = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"carritoProducts"] retain];
    self.title = @"Carrito";
    UIBarButtonItem *comprar = [[UIBarButtonItem alloc] initWithTitle:@"Ordenar" style:UIBarButtonItemStyleBordered target:self action:@selector(comprar)];
    self.navigationItem.rightBarButtonItem = comprar;
    [comprar release];

    [self updateBadge];
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
    carrito = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"carritoProducts"] retain];
    [self.tableView reloadData];
    
    currentRestaurant = [[[NSUserDefaults standardUserDefaults] valueForKey:@"currentRestaurant"] retain];
    
    NSLog(@"Carrito is: %@",carrito);
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [carrito count];
    }
    else{
        return 3;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //Items
    if (indexPath.section == 0) {
        cell.textLabel.text = [[carrito objectAtIndex:indexPath.row] objectForKey:nameKey];
        NSString *detailText;
        if ([[[carrito objectAtIndex:indexPath.row] objectForKey:@"extrasPrice"] floatValue]>0) {
            detailText = [NSString stringWithFormat:@"$%@ + $%.2f",[[carrito objectAtIndex:indexPath.row] objectForKey:priceKey],[[[carrito objectAtIndex:indexPath.row] objectForKey:@"extrasPrice"] floatValue]];
        }
        else{
            detailText = [NSString stringWithFormat:@"$%@",[[carrito objectAtIndex:indexPath.row] objectForKey:priceKey]];
        }
        cell.detailTextLabel.text = detailText;
    }
    else{
        //Resumen
        switch (indexPath.row) {
            case 0:
                //Sub total
                cell.textLabel.text = @"Sub Total";
                float tot = 0;
                for (NSDictionary* item in carrito) {
                    tot+=[[item objectForKey:@"extrasPrice"] floatValue];
                    tot+=[[item objectForKey:priceKey] floatValue];
                }
                cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.2f",tot];
                break;
            case 1:
                //envío
                cell.textLabel.text = @"Envío";
                if([[currentRestaurant valueForKey:@"tipo_envio"]isEqualToString:@"porcentaje"]){
                    float tot = 0;
                    for (NSDictionary* item in carrito) {
                        tot+=[[item objectForKey:@"extrasPrice"] floatValue];
                        tot+=[[item objectForKey:priceKey] floatValue];
                    }   
                    float costoEnvioTotal = tot*([[currentRestaurant valueForKey:@"costo_envio"] intValue]/100);
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%d.00",costoEnvioTotal];
                }
                else
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%d.00",[[currentRestaurant valueForKey:@"costo_envio"] intValue]];
                break;
            case 2:
                //Total
                cell.textLabel.text = @"Total";
                float costoEnvioTotal;
                float totalI;
                totalI = 0;
                for (NSDictionary* item in carrito) {
                    totalI+=[[item objectForKey:@"extrasPrice"] floatValue];
                    totalI+=[[item objectForKey:priceKey] floatValue];
                }   
                if([[currentRestaurant valueForKey:@"tipo_envio"]isEqualToString:@"porcentaje"]){
                    costoEnvioTotal = totalI*([[currentRestaurant valueForKey:@"costo_envio"] intValue]/100);
                }
                else
                    costoEnvioTotal = [[currentRestaurant valueForKey:@"costo_envio"] intValue];
                
                cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.2f",costoEnvioTotal+totalI];
                
                break;
            default:
                break;
        }
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updateBadge{
    float tot = 0;
    for (NSDictionary* item in carrito) {
        tot+=[[item objectForKey:@"extrasPrice"] floatValue];
        tot+=[[item objectForKey:priceKey] floatValue];
    }
    if (tot>0) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"$%.2f",tot];
    }
    else{
        self.tabBarItem.badgeValue = nil;
    }
}

@end
