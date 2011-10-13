//
//  VistaCuentaPerfil.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaCuentaPerfil.h"
#import "VistaRegistro.h"
#import "VistaListaDirecciones.h"
#import "VistaListaRFC.h"
#import "VistaInicioSesion.h"
#import "VistaNuevaDir.h"
#import "VistaNuevoRFC.h"


@implementation VistaCuentaPerfil

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
    self.title =@"Mi Cuenta";
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 2;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            if(indexPath.row == 0){
            cell.textLabel.text = @"Direcciones";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else{
                cell.textLabel.text = @"RFC's";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        case 1:
            cell.textLabel.text = @"Ver Perfil";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 2:
            cell.textLabel.text = @"Cerrar Sesión";
            
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
-(void) nuevaDir{
    VistaNuevaDir *nuevaDir = [[VistaNuevaDir alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:nuevaDir animated:YES];
    [nuevaDir release];
}

-(void) nuevoRFC{
    VistaNuevoRFC *nuevoRFC = [[VistaNuevoRFC alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:nuevoRFC animated:YES];
    [nuevoRFC release];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            VistaListaDirecciones *dirs = [[VistaListaDirecciones alloc] initWithStyle:UITableViewStyleGrouped];
            UIBarButtonItem *nueva = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(nuevaDir)];
            dirs.navigationItem.rightBarButtonItem = nueva;
            [self.navigationController pushViewController:dirs animated:YES];
            [dirs release];
        }else{
            VistaListaRFC *rfcs = [[VistaListaRFC alloc] initWithStyle:UITableViewStyleGrouped];
            UIBarButtonItem *nueva = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(nuevoRFC)];
            rfcs.navigationItem.rightBarButtonItem = nueva;

            [self.navigationController pushViewController:rfcs animated:YES];
            [rfcs release];
        }
    }else if(indexPath.section == 1){
        VistaRegistro *datos = [[VistaRegistro alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:datos animated:YES];
        [datos release];
    }else if(indexPath.section == 2){
        UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"Cierre de Sesión" message:@"Ha cerrado sesión" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
        [alerta show];
        [alerta release];
        VistaInicioSesion  *inicio = [[VistaInicioSesion alloc] initWithStyle:UITableViewStyleGrouped];
        inicio.title = @"Iniciar Sesión";
        
        UINavigationController *temp = [[UINavigationController alloc] initWithRootViewController:inicio];
         temp.navigationBar.tintColor = [UIColor colorWithRed:195/255.0 green:1/255.0 blue:20/255.0 alpha:1.0];
        [self presentModalViewController:temp animated:YES];
        [inicio release];
        [temp release];
        
        [[NSUserDefaults standardUserDefaults]setValue:nil forKey:@"userKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
