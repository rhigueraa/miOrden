/*
 *  SCTableViewController.m
 *  Sensible TableView
 *  Version: 2.1 beta
 *
 *
 *	THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY UNITED STATES 
 *	INTELLECTUAL PROPERTY LAW AND INTERNATIONAL TREATIES. UNAUTHORIZED REPRODUCTION OR 
 *	DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES. YOU SHALL NOT DEVELOP NOR
 *	MAKE AVAILABLE ANY WORK THAT COMPETES WITH A SENSIBLE COCOA PRODUCT DERIVED FROM THIS 
 *	SOURCE CODE. THIS SOURCE CODE MAY NOT BE RESOLD OR REDISTRIBUTED ON A STAND ALONE BASIS.
 *
 *	USAGE OF THIS SOURCE CODE IS BOUND BY THE LICENSE AGREEMENT PROVIDED WITH THE 
 *	DOWNLOADED PRODUCT.
 *
 *  Copyright 2010-2011 Sensible Cocoa. All rights reserved.
 *
 *
 *	This notice may not be removed from this file.
 *
 */


#import "SCTableViewController.h"
#import "SCTableViewModel.h"
#import "SCGlobals.h"





@implementation SCTableViewController

@synthesize tableViewModel;
@synthesize ownerViewController;
@synthesize delegate;
@synthesize navigationBarType;
@synthesize addButton;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize buttonsToolbar;
@synthesize cancelButtonTapped;
@synthesize doneButtonTapped;
@synthesize state;


- (id)initWithStyle:(UITableViewStyle)style 
{
    if ((self = [super initWithStyle:style])) 
	{
		toolbarAdded = FALSE;
		
		tableViewModel = [[SCTableViewModel alloc] initWithTableView:self.tableView 
												  withViewController:self];
		delegate = nil;
		navigationBarType = SCNavigationBarTypeNone;
		navigationBar = nil;
		addButton = nil;
		cancelButton = nil;
		doneButton = nil;
		
		// Create the toolbar that will hold the Add and Edit buttons
		buttonsToolbar = [[SCTransparentToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 44.01)];
		
		cancelButtonTapped = FALSE;
		doneButtonTapped = FALSE;
		
		state = SCViewControllerStateNew;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style withNavigationBarType:(SCNavigationBarType)type
{
	[self initWithStyle:style];
	
	self.navigationBarType = type;
	
	return self;
}

- (void)awakeFromNib
{
	toolbarAdded = FALSE;
	
	tableViewModel = [[SCTableViewModel alloc] initWithTableView:self.tableView 
											  withViewController:self];
	ownerViewController = nil;
	delegate = nil;
	navigationBarType = SCNavigationBarTypeNone;
	navigationBar = nil;
	addButton = nil;
	cancelButton = nil;
	doneButton = nil;
	cancelButtonTapped = FALSE;
	doneButtonTapped = FALSE;
}
 
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Check that tableViewModel's modeledTableView is the same as self.tableView (a discrepency could
	// occur when a low memory warning is issued and self.tableView is released).
	if(self.tableViewModel)
	{
		if(self.tableViewModel.modeledTableView != self.tableView
		   || self.tableViewModel.modeledTableView.dataSource != self.tableViewModel
		   || self.tableViewModel.modeledTableView.delegate != self.tableViewModel)
		{
			[self.tableViewModel replaceModeledTableViewWith:self.tableView];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.tableViewModel.commitButton = self.doneButton;
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewControllerDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewControllerDidAppear:)])
	{
		[self.delegate tableViewControllerDidAppear:self];
	}
	
	state = SCViewControllerStateActive;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	if(state != SCViewControllerStateDismissed)
		state = SCViewControllerStateInactive;
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewControllerDelegate)]
	   && [self.delegate respondsToSelector:
		   @selector(tableViewControllerDidDisappear:cancelButtonTapped:doneButtonTapped:)])
	{
		[self.delegate tableViewControllerDidDisappear:self
									cancelButtonTapped:self.cancelButtonTapped
									  doneButtonTapped:self.doneButtonTapped];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    // Inherit owner's background
    SCTableViewModel *ownerModel = [[SCModelCenter sharedModelCenter] modelForViewController:self.ownerViewController];
    if(self.tableView.style!=UITableViewStylePlain && ownerModel.modeledTableView.style!=UITableViewStylePlain)
    {
        self.tableView.backgroundColor = ownerModel.modeledTableView.backgroundColor;
    }
    
	if(self.navigationBarType==SCNavigationBarTypeAddEditRight && !toolbarAdded)
	{
		// Set the toolbar style to the correct style & tint color
		buttonsToolbar.barStyle = self.navigationController.navigationBar.barStyle;
        buttonsToolbar.tintColor = self.navigationController.navigationBar.tintColor;
		
		// create an array of the buttons
		NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];
		[buttons addObject:self.addButton];
		UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
								   target:nil
								   action:nil];
		[buttons addObject:spacer];
		[spacer release];
		[buttons addObject:self.editButton];
		
		// put the buttons in the toolbar
		[buttonsToolbar setItems:buttons animated:NO];
		[buttons release];
		
		// place the toolbar into the navigation bar
		UIBarButtonItem *toolbarButton = [[UIBarButtonItem alloc] initWithCustomView:buttonsToolbar];
		self.navigationItem.rightBarButtonItem = toolbarButton;
		[toolbarButton release];
		
		toolbarAdded = TRUE;
	}
	   
	cancelButtonTapped = FALSE;
	doneButtonTapped = FALSE;
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewControllerDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewControllerWillAppear:)])
	{
		[self.delegate tableViewControllerWillAppear:self];
	}
	
	if(state != SCViewControllerStateNew)
		state = SCViewControllerStateActive;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if(self.navigationController)
	{
		if([self.navigationController.viewControllers indexOfObject:self] == NSNotFound)
		{
			// self has been popped from the navigation controller
			state = SCViewControllerStateDismissed;
		}
	}
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewControllerDelegate)]
	   && [self.delegate respondsToSelector:
		   @selector(tableViewControllerWillDisappear:cancelButtonTapped:doneButtonTapped:)])
	{
		[self.delegate tableViewControllerWillDisappear:self
									 cancelButtonTapped:self.cancelButtonTapped
									   doneButtonTapped:self.doneButtonTapped];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [self.ownerViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)dealloc 
{
    [tableViewModel release];
	[navigationBar release];
	[addButton release];
	[cancelButton release];
	[doneButton release];
	[buttonsToolbar release];
	[super dealloc];
}

- (void)setNavigationBarType:(SCNavigationBarType)barType
{
	navigationBarType = barType;
	
	// Reset buttons
	[addButton release];
	addButton = nil;
	[cancelButton release];
	cancelButton = nil;
	[doneButton release];
	doneButton = nil;
    
    // Setup self.editButton
    self.editButton.target = self;
    self.editButton.action = @selector(editButtonAction);
	
	if(self.navigationItem && navigationBarType!=SCNavigationBarTypeNone)
	{
		UIBarButtonItem *tempAddButton = [[UIBarButtonItem alloc] 
										  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
										  target:nil 
										  action:nil];
		UIBarButtonItem *tempCancelButton = [[UIBarButtonItem alloc] 
											 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
											 target:self 
											 action:@selector(cancelButtonAction)];
		UIBarButtonItem *tempDoneButton = [[UIBarButtonItem alloc] 
										   initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
										   target:self 
										   action:@selector(doneButtonAction)];
		
		UINavigationItem *navItem = self.navigationItem;
		
		switch (navigationBarType)
		{
			case SCNavigationBarTypeAddLeft:
				navItem.leftBarButtonItem = tempAddButton;
				addButton = [tempAddButton retain];
				break;
			case SCNavigationBarTypeAddRight:
				navItem.rightBarButtonItem = tempAddButton;
				addButton = [tempAddButton retain];
				break;
			case SCNavigationBarTypeEditLeft:
				navItem.leftBarButtonItem = self.editButton;
				break;
			case SCNavigationBarTypeEditRight:
				navItem.rightBarButtonItem = self.editButton;
                cancelButton = [tempCancelButton retain];
                cancelButton.action = @selector(editingModeCancelButtonAction);
				break;
			case SCNavigationBarTypeAddRightEditLeft:
				navItem.rightBarButtonItem = tempAddButton;
				addButton = [tempAddButton retain];
				navItem.leftBarButtonItem = self.editButton;
				break;
			case SCNavigationBarTypeAddLeftEditRight:
				navItem.leftBarButtonItem = tempAddButton;
				addButton = [tempAddButton retain];
				navItem.rightBarButtonItem = self.editButton;
				break;
			case SCNavigationBarTypeDoneLeft:
				navItem.leftBarButtonItem = tempDoneButton;
				doneButton = [tempDoneButton retain];
				break;
			case SCNavigationBarTypeDoneRight:
				navItem.rightBarButtonItem = tempDoneButton;
				doneButton = [tempDoneButton retain];
				break;
			case SCNavigationBarTypeDoneLeftCancelRight:
				navItem.leftBarButtonItem = tempDoneButton;
				doneButton = [tempDoneButton retain];
				navItem.rightBarButtonItem = tempCancelButton;
				cancelButton = [tempCancelButton retain];
				break;
			case SCNavigationBarTypeDoneRightCancelLeft:
				navItem.rightBarButtonItem = tempDoneButton;
				doneButton = [tempDoneButton retain];
				navItem.leftBarButtonItem = tempCancelButton;
				cancelButton = [tempCancelButton retain];
				break;
			case SCNavigationBarTypeAddEditRight:
			{
				addButton = [tempAddButton retain];
				addButton.style = UIBarButtonItemStyleBordered;
				
				// Add the toolbar later (on viewWillAppear) when the toolbar style can be determined
			}
				break;

			default:
				break;
		}
		
		[tempAddButton release];
		[tempCancelButton release];
		[tempDoneButton release];
	}
}

- (UIBarButtonItem *)editButton
{
	return [self editButtonItem];
}

- (void)cancelButtonAction
{
	[self dismissWithCancelValue:TRUE doneValue:FALSE];
}

- (void)doneButtonAction
{
	[self dismissWithCancelValue:FALSE doneValue:TRUE];
}

- (void)editButtonAction
{
    BOOL editing = !self.tableView.editing;
    
    if(self.navigationBarType == SCNavigationBarTypeEditRight)
    {
        if(editing)
        {
            [self.navigationItem setHidesBackButton:TRUE animated:FALSE];
            
            SCTableViewSection *section = nil;
            if(self.tableViewModel.sectionCount)
                section = [self.tableViewModel sectionAtIndex:0];
            if(![section isKindOfClass:[SCArrayOfItemsSection class]])
                self.navigationItem.leftBarButtonItem = self.cancelButton;
        }
        else
        {
            for(NSInteger i=0; i<self.tableViewModel.sectionCount; i++)
            {
                SCTableViewSection *section = [self.tableViewModel sectionAtIndex:i];
                [section commitCellChanges];
            }
            
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setHidesBackButton:FALSE animated:FALSE];
        }
    }
    
    [self.tableViewModel setModeledTableViewEditing:editing animated:TRUE];
}

- (void)editingModeCancelButtonAction
{
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:FALSE animated:FALSE];
    
    for(NSInteger i=0; i<self.tableViewModel.sectionCount; i++)
    {
        SCTableViewSection *section = [self.tableViewModel sectionAtIndex:i];
        [section reloadBoundValues];
    }
    [self.tableViewModel setModeledTableViewEditing:FALSE animated:TRUE];
}

- (void)dismissWithCancelValue:(BOOL)cancelValue doneValue:(BOOL)doneValue
{
	cancelButtonTapped = cancelValue;
	doneButtonTapped = doneValue;
	
	state = SCViewControllerStateDismissed;
	
	if(self.navigationController)
	{
		// check if self is the rootViewController
		if([self.navigationController.viewControllers objectAtIndex:0] == self)
		{
			[self dismissModalViewControllerAnimated:YES];
		}
		else
			[self.navigationController popViewControllerAnimated:YES];
	}
	else
		[self dismissModalViewControllerAnimated:YES];
}




@end

