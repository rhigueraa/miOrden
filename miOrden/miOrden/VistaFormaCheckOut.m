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
    [tableModel release];
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
    listaRfc = [[NSMutableArray alloc] init];
    NSArray *collection = [[NSUserDefaults standardUserDefaults]valueForKey:@"listaRFC"];
    for (NSDictionary *dict in collection) {
        NSString *objrfc = [dict valueForKey:@"rfcKey"];
        [listaRfc addObject:objrfc];
    }
    
    NSLog(@"lista: %@", listaRfc);
    
    
    self.title = @"Check-Out";
    UIBarButtonItem *enviar = [[UIBarButtonItem alloc] initWithTitle:@"Enviar" style:UIBarButtonItemStyleBordered target:self action:@selector(send)];
    self.navigationItem.rightBarButtonItem = enviar;
    tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
    section = [SCTableViewSection sectionWithHeaderTitle:@"Datos del Registro"];
    [tableModel addSection:section];
    
    SCNumericTextFieldCell *personas = [[SCNumericTextFieldCell alloc] initWithText:@"Personas" withPlaceholder:@"¿Para cuántas personas?" withBoundKey:@"personasKey" withTextFieldTextValue:nil];
    NSArray *temp = [[NSArray alloc] initWithObjects:@"Inmediato",@"Futuro", nil];
    tipo = [[SCSegmentedCell alloc] initWithText:@"Envío" withBoundKey:@"envioKey" withSelectedSegmentIndexValue:[NSNumber numberWithInt:-1] withSegmentTitlesArray:temp];
    [temp release];
    
//    SCTableViewCell *tipoPago =[[SCTableViewCell alloc] initWithText:@"Pago" withBoundKey:@"tipoPagoKey" withValue:nil];
//   segmetnedPayments = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"cash.png"],[UIImage imageNamed:@"visa.png"],[UIImage imageNamed:@"mastercard.png"],[UIImage imageNamed:@"amex.png"], nil]];
//    segmetnedPayments.frame = CGRectMake(0, 0, 200, 38);
//    tipoPago.accessoryView = segmetnedPayments;
    
    tipoPago = [[SCSegmentedCell alloc]initWithText:@"Pago" withBoundKey:@"tipoPagoKey" withSelectedSegmentIndexValue:[NSNumber numberWithInt:-1] withSegmentTitlesArray:[NSArray arrayWithObjects:[UIImage imageNamed:@"cash.png"],[UIImage imageNamed:@"visa.png"],[UIImage imageNamed:@"mastercard.png"],[UIImage imageNamed:@"amex.png"], nil]];
    
    
    SCTextFieldCell *comentario = [[SCTextFieldCell alloc] initWithText:@"Observaciones" withPlaceholder:@"La puerta es roja" withBoundKey:@"comentarioKey" withTextFieldTextValue:nil];
    favs = [[SCSwitchCell alloc] initWithText:@"Agregar a Favoritos?" withBoundKey:@"favoritosKey" withSwitchOnValue:[NSNumber numberWithInt:0]];
    
    
    factura = [[SCSwitchCell alloc] initWithText:@"Requieres Factura?" withBoundKey:@"switchFacturaKey" withSwitchOnValue:[NSNumber numberWithInt:0]];
    
    
    
    [section addCell:personas];
    [section addCell:tipo];
   
    [section addCell:tipoPago];
 
    [section addCell:comentario];
    [section addCell:favs];
    
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
- (void)tableViewModel:(SCTableViewModel *)tableViewModel valueChangedForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 3 || indexPath.row ==2){
        if (tipoPago.segmentedControl.selectedSegmentIndex ==  0){
             if([[[section cellAtIndex:2]boundKey]isEqualToString:@"fechaKey"] ){
                 if(![[[section cellAtIndex:4]boundKey]isEqualToString:@"cambioKey"] && ![[[section cellAtIndex:3]boundKey]isEqualToString:@"cambioKey"]){
                 SCSelectionCell *cambio = [[SCSelectionCell alloc] initWithText:@"Cambio" withBoundKey:@"cambioKey" withSelectedIndexValue:[NSNumber numberWithInt:-1] withItems:[NSArray arrayWithObjects:@"$100",@"$200",@"$500",@"$1000", nil]];
            [section insertCell:cambio atIndex:4];
             [self.tableView reloadData];
                 }
             }else{
                 if(![[[section cellAtIndex:4]boundKey]isEqualToString:@"cambioKey"] && ![[[section cellAtIndex:3]boundKey]isEqualToString:@"cambioKey"]){
                  SCSelectionCell *cambio = [[SCSelectionCell alloc] initWithText:@"Cambio" withBoundKey:@"cambioKey" withSelectedIndexValue:[NSNumber numberWithInt:-1] withItems:[NSArray arrayWithObjects:@"$100",@"$200",@"$500",@"$1000", nil]];
                 [section insertCell:cambio atIndex:3];
                 [self.tableView reloadData];
                 }
             }
        }else if(tipoPago.segmentedControl.selectedSegmentIndex !=  0){
            if([[[section cellAtIndex:2]boundKey]isEqualToString:@"fechaKey"]){
                if([[[section cellAtIndex:4]boundKey]isEqualToString:@"cambioKey"]){
                                [section removeCellAtIndex:4];
                                [self.tableView reloadData];
                }
                
            }else{
                 if([[[section cellAtIndex:3]boundKey]isEqualToString:@"cambioKey"]){
                [section removeCellAtIndex:3];
                [self.tableView reloadData];
                 }
                
            }
        }
        
    }else if(indexPath.row == 1){
        if(tipo.segmentedControl.selectedSegmentIndex == 1){
            SCDateCell *fecha =  [[SCDateCell alloc] initWithText:@"Fecha" withBoundKey:@"fechaKey" withDateValue:nil];
            [section insertCell:fecha atIndex:2];
            [self.tableView reloadData];
            
        }else if(tipo.segmentedControl.selectedSegmentIndex == 0){
            if([[[section cellAtIndex:2]boundKey]isEqualToString:@"fechaKey"]){
                [section removeCellAtIndex:2];
                [self.tableView reloadData];
            }
            
        }
    }else if(indexPath.row == 5 || indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 4){
       
        if([[[tableViewModel cellAtIndexPath:indexPath]boundKey]isEqualToString:@"switchFacturaKey"]){
            if(factura.switchControl.on && ![[[section cellAtIndex:section.cellCount-1]boundKey]isEqualToString:@"facturaKey"]){
                SCSelectionCell *rfcs = [[SCSelectionCell alloc]initWithText:@"Selecciona un RFC" withBoundKey:@"facturaKey" withSelectedIndexValue:[NSNumber numberWithInt:-1] withItems:listaRfc];
                [section insertCell:rfcs atIndex:section.cellCount];
                [self.tableView reloadData];
           
            
            }else{
                if([[[section  cellAtIndex:section.cellCount-1]boundKey]isEqualToString:@"facturaKey"]){
                [section removeCellAtIndex:section.cellCount-1];
                [self.tableView reloadData];
                }
              
            }
          
            
        }else if([[[tableViewModel cellAtIndexPath:indexPath]boundKey]isEqualToString:@"favoritosKey"]){
            if(![[[section cellAtIndex:indexPath.row+1]boundKey]isEqualToString:@"nombreFavsKey"]){
            SCTextFieldCell *nombre = [SCTextFieldCell cellWithText:@"Nombre" withPlaceholder:@"para tus Favoritos" withBoundKey:@"nombreFavsKey" withTextFieldTextValue:nil];
            [section insertCell:nombre atIndex:indexPath.row+1];
            [self.tableView reloadData];
            }else{
                [section removeCellAtIndex:indexPath.row+1];
                [self.tableView reloadData];
            }
        }
    }
    
    

}

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
