//
//  VistaNuevaDir.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaNuevaDir.h"


@implementation VistaNuevaDir

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
    [tableModel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

 
-(void) guardar{
    UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"Exito" message:@"Dirección guardada" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
    [alerta show];
    [alerta release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Nueva Dirección";
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Guardar" style:UIBarButtonItemStyleBordered target:self action:@selector(guardar)];
    self.navigationItem.rightBarButtonItem = save;
    
    tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
    SCTableViewSection *section = [[SCTableViewSection alloc] initWithHeaderTitle:@"Introducir los Datos"];
    
    SCTextFieldCell *nombre = [[SCTextFieldCell alloc] initWithText:@"Nombre" withPlaceholder:@"introduzca un nickname" withBoundKey:@"nameKey" withTextFieldTextValue:nil];
    
    SCDictionaryDefinition *direccion = [[SCDictionaryDefinition alloc] initWithDictionaryKeyNames:[NSArray arrayWithObjects:@"Estado",@"Delegación",@"Colonia",@"Calle",@"Número", nil]];
    
    SCPropertyDefinition *estado = [direccion propertyDefinitionWithName:@"Estado"];
    estado.type = SCPropertyTypeSelection;
    estado.attributes = [SCSelectionAttributes attributesWithItems:[NSArray arrayWithObjects:@"estado1",@"estado2", nil] allowMultipleSelection:NO allowNoSelection:NO];
    estado.title = @"Estado";
    
    SCPropertyDefinition *delegacion = [direccion propertyDefinitionWithName:@"Delegación"];
    delegacion.type = SCPropertyTypeSelection;
    delegacion.attributes = [SCSelectionAttributes attributesWithItems:[NSArray arrayWithObjects:@"dele 1",@"dele 2", nil] allowMultipleSelection:NO allowNoSelection:NO];
    estado.title = @"Delegación";
    
    SCPropertyDefinition *colonia = [direccion propertyDefinitionWithName:@"Colonia"];
    colonia.type = SCPropertyTypeSelection;
    colonia.attributes = [SCSelectionAttributes attributesWithItems:[NSArray arrayWithObjects:@"colonia 1",@"colonia 2", nil] allowMultipleSelection:NO allowNoSelection:NO];
    colonia.title = @"Colonia";
    
    
    [direccion propertyDefinitionWithName:@"Calle"].type = SCPropertyTypeTextField;
    [direccion propertyDefinitionWithName:@"Número"].type = SCPropertyTypeTextField;
    
    
    [section addCell:nombre];
 
    [tableModel addSection:section];
    
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
