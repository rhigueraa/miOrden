//
//  FilterTableView.m
//  miOrden
//
//  Created by Sebastian Barrios on 9/12/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "FilterTableView.h"

@implementation FilterTableView

@synthesize delegate, cocinas;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    foodTypes = [[NSArray arrayWithObjects:@"Pizza",@"Japonesa",@"Italiana", nil] retain];
    
    tableModel = [[SCTableViewModel tableViewModelWithTableView:self.tableView withViewController:self] retain];
    
    SCTableViewSection *section = [SCTableViewSection sectionWithHeaderTitle:@"Filtros"];
    
    SCSelectionCell *foodTypeCell = [SCSelectionCell cellWithText:@"Cocina" withBoundKey:@"foodTypeKey" withSelectedIndexValue:nil withItems:cocinas];
    foodTypeCell.allowMultipleSelection = YES;
    
    [section addCell:foodTypeCell];
    
    [tableModel addSection:section];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didFinishFilter)];
    self.navigationItem.rightBarButtonItem = doneItem;
    [doneItem release];
}

- (void)didFinishFilter{
    SCSelectionCell *cell = (SCSelectionCell*)[tableModel cellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSMutableSet *selectedItems = cell.selectedItemsIndexes;
    
    NSMutableArray *mutArray = [NSMutableArray array];
    
    [selectedItems enumerateObjectsUsingBlock:^(id object, BOOL *STOP){
        int index = [object intValue];
        NSString *foodName = [cocinas objectAtIndex:index];
        NSPredicate *subPredicate = [NSPredicate predicateWithFormat:@"self.rest_type = %@",foodName];
        [mutArray addObject:subPredicate];
    }];
    
    /*
     NSString *finalComponents = [mutArray componentsJoinedByString:@" OR "];
     
     NSString *finalPredicate = [NSString stringWithFormat:@"self.rest_type = %@", finalComponents];
     
     NSLog(@"Predicate is: %@", finalPredicate);
     */
    NSPredicate *filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:mutArray];
    
    [self.delegate filterDidFinishWithPredicate:filterPredicate];
}

- (void)tableViewModel:(SCTableViewModel *)tableViewModel valueChangedForRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
