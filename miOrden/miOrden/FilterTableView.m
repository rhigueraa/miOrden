//
//  FilterTableView.m
//  miOrden
//
//  Created by Sebastian Barrios on 9/12/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "FilterTableView.h"

@implementation FilterTableView

@synthesize delegate;

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
    
    tableModel = [SCTableViewModel tableViewModelWithTableView:self.tableView withViewController:self];
    
    SCTableViewSection *section = [SCTableViewSection sectionWithHeaderTitle:@"Filtros"];
    
    [tableModel addSection:section];
}


@end
