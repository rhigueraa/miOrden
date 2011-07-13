//
//  VistaRegistro.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaRegistro.h"


@implementation VistaRegistro

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

-(void)confirmar{
    UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"Confirmación" message:@"Revisa que todos tus datos sean correctos" delegate:nil cancelButtonTitle:@"Enviar" otherButtonTitles:nil];
    [alerta show];
    [alerta release];
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =@"Resgitro";
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithTitle:@"Registrar" style:UIBarButtonItemStyleBordered target:self action:@selector(confirmar)];
    self.navigationItem.rightBarButtonItem = confirm;
    tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
    SCTableViewSection *section = [SCTableViewSection sectionWithHeaderTitle:@"Datos del Registro"];
    [tableModel addSection:section];
    SCTextFieldCell *nombre = [[SCTextFieldCell alloc] initWithText:@"Nombre" withPlaceholder:@"enter name" withBoundKey:@"nameKey" withTextFieldTextValue:nil];
     SCTextFieldCell *apellido = [[SCTextFieldCell alloc] initWithText:@"Apellido" withPlaceholder:@"enter apellido" withBoundKey:@"lastNameKey" withTextFieldTextValue:nil];
    SCNumericTextFieldCell *celular = [[SCNumericTextFieldCell alloc] initWithText:@"Celular" withPlaceholder:@"enter phone" withBoundKey:@"phoneKey" withTextFieldTextValue:nil];
     SCTextFieldCell *email = [[SCTextFieldCell alloc] initWithText:@"eMail" withPlaceholder:@"enter eMail" withBoundKey:@"emailKey" withTextFieldTextValue:nil];
     SCTextFieldCell *pass = [[SCTextFieldCell alloc] initWithText:@"PassWord" withPlaceholder:@"enter password" withBoundKey:@"passwordKey" withTextFieldTextValue:nil];
    SCDateCell *fechaNacimiento = [[SCDateCell alloc] initWithText:@"Nacimiento" withBoundKey:@"birthKey" withDateValue:nil];
    NSArray *sex = [[NSArray alloc] initWithObjects:@"F",@"M", nil];
    SCSegmentedCell *sexo = [[SCSegmentedCell alloc] initWithText:@"Sexo" withBoundKey:@"sexKey" withSelectedSegmentIndexValue:[NSNumber numberWithInt:-1] withSegmentTitlesArray:sex];
    SCSwitchCell *terminos = [[SCSwitchCell alloc] initWithText:@"Acepto Terminos" withBoundKey:@"terminosKey" withSwitchOnValue:[NSNumber numberWithInt:-1]]; 
     SCSwitchCell *news = [[SCSwitchCell alloc] initWithText:@"NewsLetter" withBoundKey:@"newsKey" withSwitchOnValue:[NSNumber numberWithInt:-1]]; 
                                                                           
    [section addCell:nombre];
    [section addCell:apellido];
    [section addCell:celular];
    [section addCell:email];
    [section addCell:pass];
    [section addCell:fechaNacimiento];
    [section addCell:sexo];
    [section addCell:terminos];
    [section addCell:news];
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
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

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

@end
