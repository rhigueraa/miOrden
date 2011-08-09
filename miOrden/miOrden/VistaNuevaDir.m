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
    
    SCSelectionCell *colonias = [SCSelectionCell cellWithText:@"Colonia" withBoundKey:@"coloniaKey" withSelectedIndexValue:nil withItems:[NSArray arrayWithObjects:@"Hidalgo",@"Colonia 2",@"Colonia 3", nil]];
     
    
    [section addCell:nombre];
    [section addCell:estados];
    [section addCell:delegacion];
    [section addCell:colonias];
 
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
    parser2.tagg = [NSNumber numberWithInt:2];
    NSString *cadena;
    NSString *estadoName;
    switch (indexPath.row) {
        case 1:
            estadoName = [estadosArr objectAtIndex:[[tableViewModel.modelKeyValues valueForKey:@"estadoKey"]intValue]];
            cadena = [NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/delegacion.php?estado=%@",
            estadoName];
            [parser2 parseXMLat:[NSURL URLWithString:cadena] withKey:@"delegacion"];
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
            NSLog(@"Arreglo: %@",array);
            //estadosArr = [[NSMutableArray array] retain];
            for (NSDictionary *estado in array) {
                NSString *normalString = [estado objectForKey:@"text"];
                NSLog(@"Normal String: %@",normalString);
                NSData *stringData = [[estado objectForKey:@"text"] dataUsingEncoding: NSUnicodeStringEncoding allowLossyConversion: YES];
                NSString *cleanString = [[[NSString alloc] initWithData: stringData encoding: NSUnicodeStringEncoding] autorelease];
                NSLog(@"Clean String: %@",cleanString);
                [estadosArr addObject:cleanString];
            }
            
            [self.tableView reloadData];
            break;
        case 2:
            [array retain];
            delegacionesArr = [NSMutableArray array];
            for (NSDictionary *delegacion in array) {
                [delegacionesArr addObject:[delegacion objectForKey:@"text"]];
            }
            NSLog(@"%@",delegacionesArr);
            [self.tableView reloadData];
            break;
        default:
            break;
    }
    
    
}

@end
