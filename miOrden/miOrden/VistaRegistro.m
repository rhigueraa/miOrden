//
//  VistaRegistro.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaRegistro.h"
#import "VistaTerminos.h"


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
    [tableModel release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)confirmar{
     datos = [[NSMutableDictionary alloc] init];
     [datos setValue:[tableModel.modelKeyValues valueForKey:@"nameKey"] forKey:@"nameKey"];
     [datos setValue:[tableModel.modelKeyValues valueForKey:@"lastNameKey"] forKey:@"lastNameKey"];
     [datos setValue:[tableModel.modelKeyValues valueForKey:@"emailKey"] forKey:@"emailKey"];
     [datos setValue:[tableModel.modelKeyValues valueForKey:@"confirmaEmailKey"] forKey:@"confirmaEmailKey"];
     [datos setValue:[tableModel.modelKeyValues valueForKey:@"passwordKey"] forKey:@"passwordKey"];
     [datos setValue:[tableModel.modelKeyValues valueForKey:@"confirmaPasswordKey"] forKey:@"confirmaPasswordKey"];
     [datos setValue:[tableModel.modelKeyValues valueForKey:@"birthKey"] forKey:@"birthKey"];
    
    if([[sexo segmentedControl]selectedSegmentIndex] == 0){
        [datos setValue:@"Mujer" forKey:@"genderKey"];
    }else{
        [datos setValue:@"Hombre" forKey:@"genderKey"];
    }
    
     [datos setValue:[tableModel.modelKeyValues valueForKey:@"terminosKey"] forKey:@"terminosKey"];
     [datos setValue:[tableModel.modelKeyValues valueForKey:@"newsKey"] forKey:@"newsKey"];
    
//    NSString *email = [datos valueForKey:@"emailKey"];
//    NSString *confirmaEmail = [datos valueForKey:@"confirmaEmailKey"];
//    NSString *password = [datos valueForKey:@"passwordKey"];
//    NSString *confirmaPassword = [datos valueForKey:@"confirmaPasswordKey"];
    
    NSDateFormatter *fecha = [[NSDateFormatter alloc]init];
    fecha.timeStyle = NSDateFormatterNoStyle;
    [fecha setDateFormat:@"yyyy-MM-dd"];
    NSDate *fechaa = [datos valueForKey:@"birthKey"];
    NSString *fechaFinal = [fecha stringFromDate:fechaa];

    
    NSString *cadena = [NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/register.php?password=%@&email=%@&name=%@&surname=%@&dob=%@&gender=%@&newsletter=%@", [datos valueForKey:@"passwordKey"], [datos valueForKey:@"emailKey"], [datos valueForKey:@"nameKey"], [datos valueForKey:@"lastNameKey"],fechaFinal, [datos valueForKey:@"genderKey"], [datos valueForKey:@"newsKey"]];
    
    BOOL flag;
    for (NSString *key in datos) {
        if([datos valueForKey:key])
            flag = YES;
        else
            flag = NO;
    }
      
   
    if([[datos valueForKey:@"emailKey"]isEqualToString:[datos valueForKey:@"confirmaEmailKey"]] && [[datos valueForKey:@"passwordKey"]isEqualToString:[datos valueForKey:@"confirmaPasswordKey"]] && [[datos valueForKey:@"terminosKey"]isEqual:[NSNumber numberWithInt:1]] && flag){
        XMLThreadedParser *parser = [[XMLThreadedParser alloc]init];
        parser.delegate = self;
        
        cadena = [cadena stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSLog(@"cadena: %@", cadena);
        [parser   parseXMLat:[NSURL URLWithString:cadena ] withKey:@""];
      
        
    }else{
        UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Revisa que todos tus datos sean correctos" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
        [alerta show];
        [alerta release];
       

    }
       
    
    
    
    
    
    
    
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
     SCTextFieldCell *email = [[SCTextFieldCell alloc] initWithText:@"Email" withPlaceholder:@"escribe tu Email" withBoundKey:@"emailKey" withTextFieldTextValue:nil];
    SCTextFieldCell *confirmaEmail = [[SCTextFieldCell alloc] initWithText:@"Email" withPlaceholder:@"Confirma tu Email" withBoundKey:@"confirmaEmailKey" withTextFieldTextValue:nil];
     SCTextFieldCell *pass = [[SCTextFieldCell alloc] initWithText:@"Contraseña" withPlaceholder:@"enter password" withBoundKey:@"passwordKey" withTextFieldTextValue:nil];
    SCTextFieldCell *confirmaPass = [[SCTextFieldCell alloc] initWithText:@"Contraseña" withPlaceholder:@"Confirma tu Pass" withBoundKey:@"confirmaPasswordKey" withTextFieldTextValue:nil];
    
    pass.textField.secureTextEntry = YES;
    confirmaPass.textField.secureTextEntry = YES;
    
    SCDateCell *fechaNacimiento = [[SCDateCell alloc] initWithText:@"Nacimiento" withBoundKey:@"birthKey" withDateValue:nil];
    fechaNacimiento.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    [fechaNacimiento.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    fechaNacimiento.datePicker.datePickerMode = UIDatePickerModeDate;
    
    NSArray *sex = [[NSArray alloc] initWithObjects:@"M",@"H", nil];
    sexo = [[SCSegmentedCell alloc] initWithText:@"Sexo" withBoundKey:@"sexKey" withSelectedSegmentIndexValue:[NSNumber numberWithInt:-1] withSegmentTitlesArray:sex];
    terminos = [[SCSwitchCell alloc] initWithText:@"Acepto Terminos" withBoundKey:@"terminosKey" withSwitchOnValue:[NSNumber numberWithInt:1]]; 
     SCSwitchCell *news = [[SCSwitchCell alloc] initWithText:@"NewsLetter" withBoundKey:@"newsKey" withSwitchOnValue:[NSNumber numberWithInt:1]]; 
                                                                           
    [section addCell:nombre];
    [section addCell:apellido];
   
    [section addCell:email];
    [section addCell:confirmaEmail];
    [section addCell:pass];
    [section addCell:confirmaPass];
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

- (void)tableViewModel:(SCTableViewModel *)tableViewModel didSelectRowAtIndexPath:(NSIndexPath *)indexPath{   
    if(indexPath.section == 0 && indexPath.row == 8){
        VistaTerminos *terms = [[VistaTerminos alloc]init];
        [self.navigationController pushViewController:terms animated:YES];
        [terms release];
        
    }
}
-(void)parser:(XMLThreadedParser*)parser didParseObject:(NSDictionary*)object{
    
}



-(void)parser:(XMLThreadedParser*)parser didFinishParsing:(NSArray*)array{
    
}

@end
