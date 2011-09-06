//
//  ItemConfigurationView.m
//  miOrden
//
//  Created by Sebastian Barrios on 9/4/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "ItemConfigurationView.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation ItemConfigurationView
@synthesize itemId;

#pragma mark - View lifecycle

- (NSArray*)extractArrayFromArray:(NSArray*)array usingKey:(NSString*)key{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSDictionary *dic in array) {
        NSString *finalSubString;
        if ([[dic valueForKey:@"precio"] isEqualToString:@"0.00"]) {
            finalSubString = [dic valueForKey:key];
        }
        else{
            finalSubString = [NSString stringWithFormat:@"%@: $%@",[dic valueForKey:key],[dic valueForKey:@"precio"]];
        }
        
        [tempArray addObject:finalSubString];
    }
    
    return [NSArray arrayWithArray:tempArray]; 
}

- (void)configureTableWithExtras:(NSArray*)extras{
    SCTableViewSection *section = [[SCTableViewSection alloc] initWithHeaderTitle:@"Configura tu Pedido"];
    
    SCNumericTextFieldCell *quantityCell = [SCNumericTextFieldCell cellWithText:@"Cantidad" withBoundKey:@"quantityKey" withValue:[NSNumber numberWithInt:1]];
    quantityCell.textField.keyboardType = UIKeyboardTypeNumberPad;
    [section addCell:quantityCell];
    
    //Get Extra things
    for (NSDictionary *extra in extras) {
        NSArray *extras = [self extractArrayFromArray:[extra valueForKey:@"extra_items"] usingKey:@"title"];
        
        SCSelectionCell *cell;
        
        cell = [SCSelectionCell cellWithText:[extra valueForKey:@"title"] withBoundKey:[NSString stringWithFormat:@"%@Key",[extra valueForKey:@"id_extra"]] withSelectedIndexValue:nil withItems:extras];
        
         if ([[extra valueForKey:@"multiple"] isEqualToString:@"1"]) {
             cell.allowMultipleSelection = YES;
             cell.autoDismissDetailView = NO;
         }
         else{
             cell.autoDismissDetailView = YES;
         }
        [section addCell:cell];
    }
    
    SCTextFieldCell *nameCell = [SCTextFieldCell cellWithText:@"Para" withPlaceholder:@"Nombre Comenzal" withBoundKey:@"recipientnameKey" withTextFieldTextValue:nil];
    [section addCell:nameCell];
    
    SCTextViewCell *peticionesEspeciales = [SCTextViewCell cellWithText:@"Peticiones\nEspeciales" withBoundKey:@"specialRequestKey" withValue:nil];
    [section addCell:peticionesEspeciales];
    
    [tableModel addSection:section];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
    
    //XMLThreadedParser *parser = [[XMLThreadedParser alloc] init];
    //parser.delegate = self;
    NSString *urlString = [NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/dish_addon.php?itemid=%@",itemId];
    
    __block ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setCompletionBlock:^(void){
        NSString *resposne = [request responseString];
        
        allExtras = [[resposne objectFromJSONString] retain];
        
        [self configureTableWithExtras:allExtras];
    }];
    [request startAsynchronous];
    
    //[parser parseXMLat:[NSURL URLWithString:urlString] withKey:@"dish-addon"];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"Agregar" style:UIBarButtonItemStyleDone target:self action:@selector(addToCart)];
    self.navigationItem.rightBarButtonItem = add;
    [add release];
}

- (void)tableViewModel:(SCTableViewModel *)tableViewModel didLayoutSubviewsForCell:(SCTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell.textLabel.text isEqualToString:@"Peticiones\nEspeciales"]) {
        //cell.textLabel.layer.borderWidth = 1.0;
        cell.textLabel.numberOfLines = 2;
    }
}

- (void)addToCart{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)parser:(XMLThreadedParser *)parser didParseObject:(NSDictionary *)object{
    
}

- (void)parser:(XMLThreadedParser *)parser didFinishParsing:(NSArray *)array{
    SCTableViewSection *section = [[SCTableViewSection alloc] initWithHeaderTitle:@"Configura tu Pedido"];
    
    SCNumericTextFieldCell *quantityCell = [SCNumericTextFieldCell cellWithText:@"Cantidad" withBoundKey:@"quantityKey" withValue:[NSNumber numberWithInt:1]];
    quantityCell.textField.keyboardType = UIKeyboardTypeNumberPad;
    [section addCell:quantityCell];
    
    //Get Extra things
    for (NSDictionary *extra in array) {
        SCTableViewCell *cell;
        
        cell = [SCSelectionCell cellWithText:[extra valueForKey:@"title"] withBoundKey:nil withSelectedIndexValue:nil withItems:nil];
        /*
        if ([[extra valueForKey:@"multiple"] isEqualToString:@"1"]) {
            cell = [SCSelectionCell cellWithText:[extra valueForKey:@"title"] withBoundKey:nil withSelectedIndexValue:nil withItems:nil];
        }
        else{
            
        }
        */
        [section addCell:cell];
    }
    
    SCTextFieldCell *nameCell = [SCTextFieldCell cellWithText:@"Para" withPlaceholder:@"Nombre Comenzal" withBoundKey:@"recipientnameKey" withTextFieldTextValue:nil];
    [section addCell:nameCell];
    
    SCTextViewCell *peticionesEspeciales = [SCTextViewCell cellWithText:@"Peticiones\nEspeciales" withBoundKey:@"specialRequestKey" withValue:nil];
    [section addCell:peticionesEspeciales];
    
    [tableModel addSection:section];
    
    [self.tableView reloadData];
}


@end
