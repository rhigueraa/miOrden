//
//  VistaFormaCheckOut.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/15/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaFormaCheckOut.h"
#import "VistaUnoOrden.h"
@implementation VistaFormaCheckOut

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
    [listaRfc release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)send{
    UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"Alerta" message:@"Tu pedido va en camino, 5 minutos para confirmación" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    [alerta show];
    [alerta release];
    VistaUnoOrden *orden = [[VistaUnoOrden alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController pushViewController:orden animated:YES];
    
    [orden release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    listaRfc = [[NSArray alloc] initWithObjects:@"RFC1", @"RFC2",@"RFC3", nil];
    self.title = @"Check-Out";
    UIBarButtonItem *enviar = [[UIBarButtonItem alloc] initWithTitle:@"Enviar" style:UIBarButtonItemStyleBordered target:self action:@selector(send)];
    self.navigationItem.rightBarButtonItem = enviar;
    tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
    SCTableViewSection *section = [SCTableViewSection sectionWithHeaderTitle:@"Datos del Registro"];
    [tableModel addSection:section];
    
    SCNumericTextFieldCell *personas = [[SCNumericTextFieldCell alloc] initWithText:@"Personas" withPlaceholder:@"# de Personas" withBoundKey:@"personasKey" withTextFieldTextValue:nil];
    NSArray *temp = [[NSArray alloc] initWithObjects:@"Inmediato",@"Futuro", nil];
    SCSegmentedCell *tipo = [[SCSegmentedCell alloc] initWithText:@"Envío" withBoundKey:@"envioKey" withSelectedSegmentIndexValue:[NSNumber numberWithInt:-1] withSegmentTitlesArray:temp];
    [temp release];
    SCDateCell *fecha =  [[SCDateCell alloc] initWithText:@"Fecha" withBoundKey:@"fechaKey" withDateValue:nil];
    SCTableViewCell *tipoPago =[[SCTableViewCell alloc] initWithText:@"Pago" withBoundKey:@"tipoPagoKey" withValue:nil];
    UISegmentedControl *segmetnedPayments = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"cash.png"],[UIImage imageNamed:@"visa.png"],[UIImage imageNamed:@"mastercard.png"],[UIImage imageNamed:@"amex.png"], nil]];
    segmetnedPayments.frame = CGRectMake(0, 0, 200, 38);
    tipoPago.accessoryView = segmetnedPayments;
    SCNumericTextFieldCell *cambio = [[SCNumericTextFieldCell alloc] initWithText:@"Cambio de" withPlaceholder:@"billete del que desea cambio" withBoundKey:@"cambioKey" withTextFieldTextValue:nil];
    SCTextFieldCell *comentario = [[SCTextFieldCell alloc] initWithText:@"Comentario" withPlaceholder:@"introduzca un comentario" withBoundKey:@"comentarioKey" withTextFieldTextValue:nil];
    SCTableViewCell *favs = [[SCTableViewCell alloc] initWithText:@"¿Favoritos?" withBoundKey:@"favoritosKey" withValue:nil];
    favs.accessoryType = UITableViewCellAccessoryCheckmark;
    favs.selectionStyle = UITableViewCellSelectionStyleNone;
    SCTextFieldCell *nombre = [[SCTextFieldCell alloc] initWithText:@"Nombre" withPlaceholder:@"introduzca el nombre" withBoundKey:@"nombreKey" withTextFieldTextValue:nil];
    SCSelectionCell *factura = [[SCSelectionCell alloc] initWithText:@"Factura" withBoundKey:@"facturaKey" withSelectedIndexValue:[NSNumber numberWithInt:-1] withItems:listaRfc];    
    [section addCell:personas];
    [section addCell:tipo];
    [section addCell:fecha];
    [section addCell:tipoPago];
    [section addCell:cambio];
    [section addCell:comentario];
    [section addCell:favs];
    [section addCell:nombre];
    [section addCell:factura];
    
    
    
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

- (void)tableViewModel:(SCTableViewModel *)tableViewModel didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 5){
        UITableViewCell *cell = [tableViewModel cellAtIndexPath:indexPath];
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
            [[tableViewModel cellAtIndexPath:indexPath]setAccessoryType:UITableViewCellAccessoryNone];
        else
            [[tableViewModel cellAtIndexPath:indexPath]setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    
    
}

@end
