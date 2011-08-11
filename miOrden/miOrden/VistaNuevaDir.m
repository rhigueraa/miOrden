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
    direccion  = [[NSMutableArray alloc] init];
    
    XMLThreadedParser *parser = [[XMLThreadedParser alloc] init];
    parser.delegate = self;
    parser.tagg = [NSNumber numberWithInt:1];
    [parser parseXMLat:[NSURL URLWithString:@"http://www.miorden.com/demo/iphone/estado.php"] withKey:@"estado"];
    estadosArr = [[NSMutableArray alloc] init];
    delegacionesArr = [[NSMutableArray alloc] init];
    coloniasArr = [[NSMutableArray alloc] init];
    
    
    self.title = @"Nueva Dirección";
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Guardar" style:UIBarButtonItemStyleBordered target:self action:@selector(guardar)];
    self.navigationItem.rightBarButtonItem = save;
    
    tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
    SCTableViewSection *section = [[SCTableViewSection alloc] initWithHeaderTitle:@"Introducir los Datos"];
    
    SCTextFieldCell *nombre = [[SCTextFieldCell alloc] initWithText:@"Nombre" withPlaceholder:@"introduzca un nickname" withBoundKey:@"nameKey" withTextFieldTextValue:nil];
    
    SCSelectionCell *estados = [SCSelectionCell cellWithText:@"Estado" withBoundKey:@"estadoKey" withSelectedIndexValue:nil withItems:estadosArr];
    
    SCSelectionCell *delegacion = [SCSelectionCell cellWithText:@"Delegacion" withBoundKey:@"delegacionKey" withSelectedIndexValue:nil withItems:delegacionesArr];
    
    SCSelectionCell *colonias = [SCSelectionCell cellWithText:@"Colonia" withBoundKey:@"coloniaKey" withSelectedIndexValue:nil withItems:coloniasArr];
     
    SCTextFieldCell *calle = [[SCTextFieldCell alloc]initWithText:@"Detalles" withPlaceholder:@"calle y número" withBoundKey:@"calleKey" withTextFieldTextValue:nil];
    
    
    [section addCell:nombre];
    [section addCell:estados];
    [section addCell:delegacion];
    [section addCell:colonias];
    [section addCell:calle];
 
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
            
            NSLog(@"EStados: %@", array);
            
            for (NSDictionary *estado in array) {
                [estadosArr addObject:[[estado objectForKey:@"text"] fixAccents]];
               
            }
            
            [self.tableView reloadData];
            break;
        case 2:
            [array retain];
           
            [delegacionesArr removeAllObjects];
            for (NSDictionary *delegacion in array) {
                [delegacionesArr addObject:[[delegacion objectForKey:@"text"] fixAccents]];
            }
        case 3:
            [array retain];
           
            [coloniasArr removeAllObjects];
            for (NSDictionary *colonia in array) {
                [coloniasArr addObject:[[colonia objectForKey:@"text"] fixAccents]];
            }
            break;
            
            [self.tableView reloadData];
            break;
        default:
            break;
    }
    
    
}

-(void) guardar{
    [direccion setValue:[estadosArr objectAtIndex:[[tableModel.modelKeyValues valueForKey:@"estadoKey"]intValue]] forKey:@"estado"];
    [direccion setValue:[delegacionesArr objectAtIndex:[[tableModel.modelKeyValues valueForKey:@"delegacionKey"]intValue]] forKey:@"delegacion"];
    [direccion setValue:[coloniasArr objectAtIndex:[[tableModel.modelKeyValues valueForKey:@"coloniaKey"]intValue]] forKey:@"colonia"];
    [direccion setValue:[tableModel.modelKeyValues valueForKey:@"calleKey"] forKey:@"calle"];
   // NSLog(@"%@",[estadosArr objectAtIndex:[[tableModel.modelKeyValues valueForKey:@"estadoKey"]intValue]]);
    
   // NSString *dirFinal = [NSString stringWithFormat:@"%@ %@ %@ %@",[direccion valueForKey:@"calle"],[direccion valueForKey:@"colonia"],[direccion valueForKey:@"delegacion"],[direccion valueForKey:@"estado"]];
    
    UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"Exito" message:@"mensaje" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
    [alerta show];
    [alerta release];
}

@end
