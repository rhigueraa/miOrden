//
//  VistaNuevaDir.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaNuevaDir.h"
#import "NSString+AccentCorrection.h"

@implementation VistaNuevaDir
@synthesize direccion;
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
    [zonasArr release];
    [estadosArr release];
    [coloniasArr release];
    [delegacionesArr release];
    [direccion release];
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

 

- (void)viewDidLoad
{
    [super viewDidLoad];
    direccion  = [[NSMutableDictionary alloc] init];
    estadosArr = [[NSMutableArray alloc] init];
    delegacionesArr = [[NSMutableArray alloc] init];
    coloniasArr = [[NSMutableArray alloc] init];
    zonasArr = [[NSMutableArray alloc] init];

    XMLThreadedParser *parser = [[XMLThreadedParser alloc] init];
    parser.delegate = self;
    parser.tagg = [NSNumber numberWithInt:1];
    [parser parseXMLat:[NSURL URLWithString:@"http://www.miorden.com/demo/iphone/estado.php"] withKey:@"estado"];
    XMLThreadedParser *parser4 = [[XMLThreadedParser alloc] init];
    parser4.delegate = self;
    parser4.tagg = [NSNumber numberWithInt:4];
    [parser4 parseXMLat:[NSURL URLWithString:@"http://www.miorden.com/demo/iphone/zones.php"] withKey:@"zone"];
        
    
    self.title = @"Nueva Dirección";
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Guardar" style:UIBarButtonItemStyleBordered target:self action:@selector(guardar)];
    self.navigationItem.rightBarButtonItem = save;
    
    tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
    SCTableViewSection *section = [[SCTableViewSection alloc] initWithHeaderTitle:@"Introducir los Datos"];
    
    SCTextFieldCell *nombre = [[SCTextFieldCell alloc] initWithText:@"Nombre" withPlaceholder:@"introduzca un nickname" withBoundKey:@"nameKey" withTextFieldTextValue:nil];
    
    SCSelectionCell *estados = [SCSelectionCell cellWithText:@"Estado" withBoundKey:@"estadoKey" withSelectedIndexValue:nil withItems:estadosArr];
    
    SCSelectionCell *delegacion = [SCSelectionCell cellWithText:@"Delegacion" withBoundKey:@"delegacionKey" withSelectedIndexValue:nil withItems:delegacionesArr];
    
    SCSelectionCell *colonias = [SCSelectionCell cellWithText:@"Colonia" withBoundKey:@"coloniaKey" withSelectedIndexValue:nil withItems:coloniasArr];
     
    SCTextFieldCell *calle = [[SCTextFieldCell alloc]initWithText:@"Calle" withPlaceholder:@"calle" withBoundKey:@"calleKey" withTextFieldTextValue:nil];
    SCTextFieldCell *calleCer = [[SCTextFieldCell alloc]initWithText:@"Entre la calle" withPlaceholder:@"calle" withBoundKey:@"calleCercana" withTextFieldTextValue:nil];
    SCTextFieldCell *numExt = [[SCTextFieldCell alloc]initWithText:@"Número" withPlaceholder:@"exterior" withBoundKey:@"numExtKey" withTextFieldTextValue:nil];
    SCTextFieldCell *numInt = [[SCTextFieldCell alloc]initWithText:@"Número" withPlaceholder:@"interior" withBoundKey:@"numIntKey" withTextFieldTextValue:nil];
    SCNumericTextFieldCell *telefono = [[SCNumericTextFieldCell alloc]initWithText:@"Teléfono" withPlaceholder:@"teléfono" withBoundKey:@"telefonoKey" withTextFieldTextValue:nil];
    
    SCSelectionCell *zonas = [SCSelectionCell cellWithText:@"Zona" withBoundKey:@"zonaKey" withSelectedIndexValue:nil withItems:zonasArr];
    
    
    
    [section addCell:nombre];
    [section addCell:estados];
    [section addCell:delegacion];
    [section addCell:colonias];
    [section addCell:calle];
    [section  addCell:calleCer];
    [section addCell:numExt];
    [section  addCell:numInt];
    [section addCell:zonas];
    [section addCell:telefono];
 
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
-(void)parser:(XMLThreadedParser*)parser didParseObject:(NSDictionary*)object{
    
}

-(void) tableViewModel:(SCTableViewModel *)tableViewModel valueChangedForRowAtIndexPath:(NSIndexPath *)indexPath{
    XMLThreadedParser *parser2 = [[XMLThreadedParser alloc] init];
    parser2.delegate = self;
    
    NSString *cadena;
    NSString *estadoName, *delegacionName;
    switch (indexPath.row) {
        case 1:
            parser2.tagg = [NSNumber numberWithInt:2];
            estadoName = [estadosArr objectAtIndex:[[tableViewModel.modelKeyValues valueForKey:@"estadoKey"]intValue]];
            cadena = [NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/delegacion.php?estado=%@",
            estadoName];
            cadena = [cadena stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            [parser2 parseXMLat:[NSURL URLWithString:cadena] withKey:@"delegacion"];
            NSLog(@"%@",cadena);
        break;
        case 2:
            parser2.tagg = [NSNumber numberWithInt:3];
            delegacionName = [delegacionesArr objectAtIndex:[[tableViewModel.modelKeyValues valueForKey:@"delegacionKey"]intValue]];
            estadoName = [estadosArr objectAtIndex:[[tableViewModel.modelKeyValues valueForKey:@"estadoKey"]intValue]];
            cadena = [NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/colonia.php?estado=%@&delegacion=%@",estadoName,
                      delegacionName];
            cadena = [cadena stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            [parser2 parseXMLat:[NSURL URLWithString:cadena] withKey:@"colonia"];
             NSLog(@"%@",cadena);
            break;
        default:
            break;
    }
}



-(void)parser:(XMLThreadedParser*)parser didFinishParsing:(NSArray*)array{
    switch (parser.tagg.intValue) {
        case 1:
            [array retain];
            [estadosArr removeAllObjects];
            for (NSDictionary *estado in array) {
                [estadosArr addObject:[estado objectForKey:@"text"]];
            }
            
            [self.tableView reloadData];
            break;
        case 2:
            [array retain];
           
            [delegacionesArr removeAllObjects];
            for (NSDictionary *delegacion in array) {
                [delegacionesArr addObject:[[delegacion objectForKey:@"text"] fixAccents]];
            }
            [self.tableView reloadData];
        case 3:
            [array retain];
           
            [coloniasArr removeAllObjects];
            for (NSDictionary *colonia in array) {
                [coloniasArr addObject:[[colonia objectForKey:@"text"] fixAccents]];
            }
            [self.tableView reloadData];
            break;
        case 4:
            [array retain];
            [zonasArr removeAllObjects];
            for (NSDictionary *zonas in array) {
                [zonasArr addObject:[zonas objectForKey:@"title"]];
            }
            
            [self.tableView reloadData];
            break;
        case 5:
            [array retain];
            if([[array objectAtIndex:0]valueForKey:@"text"]){
                UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"Exito" message:@"La dirección ha sido agregada" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alerta show];
                [alerta release  ];
                
            }else{
                UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No se ha podido agregar la dirección" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alerta show];
                [alerta release  ];
            }
            break;
            
        default:
            break;
    }
    
    
}

-(void) guardar{
    [direccion setValue:[estadosArr objectAtIndex:[[tableModel.modelKeyValues valueForKey:@"estadoKey"]intValue]] forKey:@"estado"];
    [direccion setValue:[delegacionesArr objectAtIndex:[[tableModel.modelKeyValues valueForKey:@"delegacionKey"]intValue]] forKey:@"delegacion"];
    [direccion setValue:[coloniasArr objectAtIndex:[[tableModel.modelKeyValues valueForKey:@"coloniaKey"]intValue]] forKey:@"colonia"];
    [direccion setValue:[zonasArr objectAtIndex:[[tableModel.modelKeyValues valueForKey:@"zonaKey"]intValue]] forKey:@"zona"];
    [direccion setValue:[tableModel.modelKeyValues valueForKey:@"calleKey"] forKey:@"calle"];
    [direccion setValue:[tableModel.modelKeyValues valueForKey:@"calleCercana"] forKey:@"calleCercana"];
    [direccion setValue:[tableModel.modelKeyValues valueForKey:@"numExtKey"] forKey:@"numExtKey"];
    [direccion setValue:[tableModel.modelKeyValues valueForKey:@"numIntKey"] forKey:@"numIntKey"];
    [direccion setValue:[tableModel.modelKeyValues valueForKey:@"telefonoKey"] forKey:@"telefonoKey"];
    [direccion setValue:[tableModel.modelKeyValues valueForKey:@"nameKey"] forKey:@"nombreKey"];
   
    XMLThreadedParser *parser3 = [[XMLThreadedParser alloc]init];
    parser3.delegate = self;
    parser3.tagg = [NSNumber numberWithInt:5];
    NSString *cadena;
    NSString *nombre = [direccion valueForKey:@"nombreKey"];
    NSString *estado = [direccion valueForKey:@"estado"];
    NSString *delegacion = [direccion valueForKey:@"delegacion"];
    NSString *colonia = [direccion valueForKey:@"colonia"];
    NSString *calle = [direccion valueForKey:@"calle"];
    NSString *calleCerca = [direccion valueForKey:@"calleCercana"];
    NSString *numExt = [direccion valueForKey:@"numExtKey"];
    NSString *numInt = [direccion valueForKey:@"numIntKey"];
    NSString *telefono = [direccion valueForKey:@"telefonoKey"];
    NSString *zona = [direccion valueForKey:@"zona"];
    NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userIdKey"];
    
    
    
    cadena = [NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/locations.php?title_loc=%@&state=%@&delegation=%@&colony=%@&address=%@&zone=%@&the_street=%@&telephone=%@&user_id=%@&exterior=%@&interior=%@", nombre,estado,delegacion,colonia,calle,zona,calleCerca,telefono,userId,numExt,numInt]; 
    cadena = [cadena stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [parser3 parseXMLat:[NSURL URLWithString:cadena ] withKey:@"status"];
    
    NSLog(@"%@",cadena);
    }


@end
