//
//  VistaNuevoRFC.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaNuevoRFC.h"


@implementation VistaNuevoRFC

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

-(void) guardar{
    NSDictionary *nuevoRFC = [[NSDictionary alloc]init];
   

    [nuevoRFC setValue:[tableModel.modelKeyValues valueForKey:@"rfcKey"] forKey:@"rfcKey"];
    [nuevoRFC setValue:[tableModel.modelKeyValues valueForKey:@"razonKey"] forKey:@"razonKey"];
    [nuevoRFC setValue:[tableModel.modelKeyValues valueForKey:@"domicilioKey"] forKey:@"domicilioKey"];
    
    
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"listaRFC"]){
    NSMutableArray *listaRFCS;
    listaRFCS = [[NSUserDefaults standardUserDefaults]valueForKey:@"listaRFC"];
    [listaRFCS addObject:nuevoRFC];
    [[NSUserDefaults standardUserDefaults]setValue:listaRFCS forKey:@"listaRFC"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    }else{
        NSMutableArray *listaRFCS = [[NSMutableArray alloc]initWithObjects:nuevoRFC, nil];
        [[NSUserDefaults standardUserDefaults]setValue:listaRFCS forKey:@"listaRFC"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [listaRFCS release];
        
    }
    
    [nuevoRFC release];
    
    
    UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"Exito" message:@"RFC guardado" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
    [alerta show];
    [alerta release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Nuevo RFC";
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Guardar" style:UIBarButtonItemStyleBordered target:self action:@selector(guardar)];
    self.navigationItem.rightBarButtonItem = save;
    
    tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
    SCTableViewSection *section = [[SCTableViewSection alloc] initWithHeaderTitle:@"Introducir los Datos"];
    
    SCTextFieldCell *nombre = [[SCTextFieldCell alloc] initWithText:@"Razón Social" withPlaceholder:@"introduzca una razón social" withBoundKey:@"razonKey" withTextFieldTextValue:nil];
    SCTextViewCell *domicilio = [[SCTextViewCell alloc] initWithText:@"Domicilio Fiscal" withBoundKey:@"domicilioKey" withTextViewTextValue:nil];
    
    
    SCTextFieldCell *rfc = [[SCTextFieldCell alloc] initWithText:@"RFC" withPlaceholder:@"introduzca el RFC" withBoundKey:@"rfcKey" withTextFieldTextValue:nil];
    [section addCell:nombre];
    [section addCell:domicilio];
    [section addCell:rfc];
    [tableModel addSection:section];
    
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

@end