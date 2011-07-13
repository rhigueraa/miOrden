/*
 *  SCTableViewModel.m
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


#import "SCTableViewModel.h"



@interface SCTableViewModel ()

- (void)addSectionForObject:(NSObject *)object withClassDefinition:(SCClassDefinition *)classDef usingGroup:(SCPropertyGroup *)group newObject:(BOOL)newObject;
- (SCTableViewSection *)getSectionForPropertyDefinition:(SCPropertyDefinition *)propertyDef withBoundObject:(NSObject *)object;

- (void)tableAnimationEnded:(NSString*)animationID finished:(NSNumber *)finished contextInfo:(void *)context;

@end




@implementation SCTableViewModel

@synthesize masterModel;
@synthesize modeledTableView;
@synthesize viewController;
@synthesize dataSource;
@synthesize delegate;
@synthesize editButtonItem;
@synthesize autoResizeForKeyboard;
@synthesize sectionIndexTitles;
@synthesize autoGenerateSectionIndexTitles;
@synthesize autoSortSections;
@synthesize hideSectionHeaderTitles;
@synthesize lockCellSelection;
@synthesize tag;
@synthesize previousActiveCell;
@synthesize activeCell;
@synthesize modelKeyValues;
@synthesize commitButton;


+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
{
	return [[[[self class] alloc] initWithTableView:_modeledTableView
								 withViewController:_viewController] autorelease];
}

- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
{
	if([self init])
	{
		target = nil;
		action = nil;
		masterModel = nil;
		
		modeledTableView = _modeledTableView;
		viewController = _viewController;
		dataSource = _viewController;
		delegate = _viewController;
		modeledTableView.dataSource = self;
		modeledTableView.delegate = self;
        modeledTableView.allowsSelectionDuringEditing = TRUE;
		
		editButtonItem = nil;
		sectionIndexTitles = nil;
		autoGenerateSectionIndexTitles = FALSE;
		autoSortSections = FALSE;
		hideSectionHeaderTitles = FALSE;
		lockCellSelection = FALSE;
		tag = 0;
		sections = [[NSMutableArray alloc] init];
		previousActiveCell = nil;
		activeCell = nil;
		
		modelKeyValues = [[NSMutableDictionary alloc] init];
		
		commitButton = nil;
		
		keyboardShown = FALSE;
		keyboardOverlap = 0;
		if([self.viewController isKindOfClass:[UITableViewController class]])
			self.autoResizeForKeyboard = FALSE;
		else
			self.autoResizeForKeyboard = TRUE;
		
		// Register with the shared model center
		[[SCModelCenter sharedModelCenter] registerModel:self];
	}
	
	return self;
}

- (void)dealloc
{
	// Unregister from the shared model center
	[[SCModelCenter sharedModelCenter] unregisterModel:self];
	
	[editButtonItem release];
	[sectionIndexTitles release];
	[sections release];
	[modelKeyValues release];
	[commitButton release];

	[super dealloc];
}

- (NSArray *)sectionIndexTitles
{
	if(!self.autoGenerateSectionIndexTitles)
		return sectionIndexTitles;
	
	// Generate sectionIndexTitles
	NSMutableArray *titles = [NSMutableArray arrayWithCapacity:self.sectionCount];
	for(SCTableViewSection *section in sections)
		if([section.headerTitle length])
		{
			// Add first letter of the header title to section titles
			[titles addObject:[section.headerTitle substringToIndex:1]];
		}
	return titles;
}

- (void)setAutoSortSections:(BOOL)autoSort
{
	autoSortSections = autoSort;
	if(autoSort)
		[sections sortUsingSelector:@selector(compare:)];
}

- (void)setActiveCell:(SCTableViewCell *)cell
{
	if(activeCell == cell)
		return;
	
	previousActiveCell = activeCell;
	[previousActiveCell willDeselectCell];
	if(previousActiveCell.selected)
		[self.modeledTableView deselectRowAtIndexPath:[self indexPathForCell:previousActiveCell] animated:NO];
	
	activeCell = cell;
	
	NSIndexPath *indexPath = [self indexPathForCell:activeCell];
	[self.modeledTableView scrollToRowAtIndexPath:indexPath
								 atScrollPosition:UITableViewScrollPositionNone
										 animated:YES];
}

- (void)setCommitButton:(UIBarButtonItem *)button
{
	[commitButton release];
	commitButton = [button retain];
	
	commitButton.enabled = self.valuesAreValid;
}

- (NSIndexPath *)activeCellIndexPath
{
	return [self indexPathForCell:self.activeCell];
}

- (void)setAutoResizeForKeyboard:(BOOL)handleDidShow
{
	if([self.viewController isKindOfClass:[UITableViewController class]])
		autoResizeForKeyboard = FALSE;
	else
		autoResizeForKeyboard = handleDidShow;
}

- (void)setEditButtonItem:(UIBarButtonItem *)barButtonItem
{
	[editButtonItem release];
	editButtonItem = [barButtonItem retain];
	
	editButtonItem.target = self;
	editButtonItem.action = @selector(didTapEditButtonItem);
}

- (void)valueChangedForSectionAtIndex:(NSUInteger)index
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModel:valueChangedForSectionAtIndex:)])
	{
		[self.delegate tableViewModel:self valueChangedForSectionAtIndex:index];
	}
	
	if(target)
		[target performSelector:action];
}

- (void)valueChangedForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(!indexPath)
		return;
	
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	if(cell != self.activeCell)
	{
		if(self.activeCell.autoResignFirstResponder)
			[self.activeCell resignFirstResponder];
		if(!cell.beingReused)  // make sure it's a static cell, otherwise it could be deleted by UITableViewController and should not be referenced
			self.activeCell = cell;
		else
			self.activeCell = nil;
	}
	
	if(target)
		[target performSelector:action];
	
	if(self.commitButton)
		self.commitButton.enabled = self.valuesAreValid;
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModel:valueChangedForRowAtIndexPath:)])
	{
		[self.delegate tableViewModel:self valueChangedForRowAtIndexPath:indexPath];
	}
}

- (void)setTargetForModelModifiedEvent:(id)_target action:(SEL)_action
{
	target = _target;
	action = _action;
}

- (void)didTapEditButtonItem
{	
	BOOL editing = !self.modeledTableView.editing;		// toggle editing state
	
	if(editing)
	{
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModelWillBeginEditing:)])
		{
			[self.delegate tableViewModelWillBeginEditing:self];
		}
	}
	else
	{
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModelWillEndEditing:)])
		{
			[self.delegate tableViewModelWillEndEditing:self];
		}
	}
	
    [self setModeledTableViewEditing:editing animated:TRUE];
	
	if(editing)
	{
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModelDidBeginEditing:)])
		{
			[self.delegate tableViewModelDidBeginEditing:self];
		}
	}
	else
	{
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModelDidEndEditing:)])
		{
			[self.delegate tableViewModelDidEndEditing:self];
		}
	}
}

- (void)replaceModeledTableViewWith:(UITableView *)tableView
{
	modeledTableView = tableView;
	modeledTableView.dataSource = self;
	modeledTableView.delegate = self;
}

- (NSUInteger)sectionCount
{
	return sections.count;
}

- (void)addSection:(SCTableViewSection *)section
{
	section.ownerTableViewModel = self;
	if(![section isKindOfClass:[SCArrayOfItemsSection class]])
	{
		for(int i=0; i<section.cellCount; i++)
			[section cellAtIndex:i].ownerTableViewModel = self;
	}
	[sections addObject:section];
	
	if([self.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.dataSource respondsToSelector:@selector(tableViewModel:sortSections:)])
	{
		[self.dataSource tableViewModel:self sortSections:sections];
	}
	else 
		if(self.autoSortSections)
			[sections sortUsingSelector:@selector(compare:)];
}

- (void)insertSection:(SCTableViewSection *)section atIndex:(NSUInteger)index
{
	section.ownerTableViewModel = self;
	for(int i=0; i<section.cellCount; i++)
		[section cellAtIndex:i].ownerTableViewModel = self;
	[sections insertObject:section atIndex:index];
}

- (SCTableViewSection *)sectionAtIndex:(NSUInteger)index
{
	if(index < self.sectionCount)
		return [sections objectAtIndex:index];
	//else
	return nil;
}

- (SCTableViewSection *)sectionWithHeaderTitle:(NSString *)title
{
	for(SCTableViewSection *section in sections)
		if(title)
		{
			if([section.headerTitle isEqualToString:title])
				return section;
		}
		else
		{
			if(!section.headerTitle)
				return section;
		}
		
	
	return nil;
}

- (NSUInteger)indexForSection:(SCTableViewSection *)section
{
	return [sections indexOfObjectIdenticalTo:section];
}

- (void)removeSectionAtIndex:(NSUInteger)index
{
	[sections removeObjectAtIndex:index];
}

- (void)removeAllSections
{
	[sections removeAllObjects];
}

- (void)generateSectionsForObject:(NSObject *)object usingClassDefinition:(SCClassDefinition *)classDef newObject:(BOOL)newObject
{
    [classDef generateDefaultPropertyGroupProperties];
    
    [self addSectionForObject:object withClassDefinition:classDef usingGroup:classDef.defaultPropertyGroup newObject:newObject];
        
    for(NSInteger i=0; i<classDef.propertyGroups.groupCount; i++)
    {
        SCPropertyGroup *propertyGroup = [classDef.propertyGroups groupAtIndex:i];
        [self addSectionForObject:object withClassDefinition:classDef usingGroup:propertyGroup newObject:newObject];
    }
}

- (void)addSectionForObject:(NSObject *)object withClassDefinition:(SCClassDefinition *)classDef usingGroup:(SCPropertyGroup *)group newObject:(BOOL)newObject
{
    NSInteger propertyNameCount = group.propertyNameCount;
    if(!propertyNameCount)
        return;
    
    SCPropertyGroup *subGroup = [SCPropertyGroup groupWithHeaderTitle:group.headerTitle withFooterTitle:group.footerTitle withPropertyNames:nil];
    for(NSInteger i=0; i<propertyNameCount; i++)
    {
        NSString *propertyName = [group propertyNameAtIndex:i];
        SCPropertyDefinition *propertyDef = [classDef propertyDefinitionWithName:propertyName];
        
        if( (newObject && !propertyDef.existsInCreationMode) || (!newObject && !propertyDef.existsInDetailMode) )
            continue;
        
        if(!propertyDef.attributes.expandContentInCurrentView)
        {
            [subGroup addPropertyName:propertyName];
            continue;
        }
        else
        {
            if(subGroup.propertyNameCount)
            {
                SCObjectSection *objectSection = [[SCObjectSection alloc] initWithHeaderTitle:nil withBoundObject:object withClassDefinition:classDef usingPropertyGroup:subGroup];
                [self addSection:objectSection];
                [objectSection release];
                
                [subGroup removeAllPropertyNames];
            }
            
            SCTableViewSection *section = [self getSectionForPropertyDefinition:propertyDef withBoundObject:object];
            if(section)
            {
                section.headerTitle = group.headerTitle;
                section.footerTitle = group.footerTitle;
                [self addSection:section];
            }
        }
    }
    
    if(subGroup.propertyNameCount)
    {
        SCObjectSection *objectSection = [[SCObjectSection alloc] initWithHeaderTitle:nil withBoundObject:object withClassDefinition:classDef usingPropertyGroup:subGroup];
        [self addSection:objectSection];
        [objectSection release];
    }
}

- (SCTableViewSection *)getSectionForPropertyDefinition:(SCPropertyDefinition *)propertyDef withBoundObject:(NSObject *)_boundObject
{
    SCTableViewSection *section = nil;
    
    BOOL coreDataBound = FALSE;
#ifdef _COREDATADEFINES_H	
	if([_boundObject isKindOfClass:[NSManagedObject class]])
		coreDataBound = TRUE;
#endif
    
    switch (propertyDef.type)
    {
        case SCPropertyTypeObject:
        {
            NSObject *object = [_boundObject valueForKey:propertyDef.name];
            
#ifdef _COREDATADEFINES_H			
            if(!object && coreDataBound)
            {
                // create a new object
                NSManagedObject *managedObj = (NSManagedObject *)_boundObject;
                NSRelationshipDescription *objReleationship = [[[managedObj entity] relationshipsByName] valueForKey:propertyDef.name];
                if(objReleationship)
                {
                    object = [NSEntityDescription 
                              insertNewObjectForEntityForName:[[objReleationship destinationEntity] name]
                              inManagedObjectContext:propertyDef.ownerClassDefinition.managedObjectContext];
                    [_boundObject setValue:object forKey:propertyDef.name];
                }
            }
#endif			
            
            if(!object)
                break;
            
            SCClassDefinition *objClassDef = nil;
            if([propertyDef.attributes isKindOfClass:[SCObjectAttributes class]])
            {
                NSArray *classDefinitions = [[(SCObjectAttributes *)propertyDef.attributes 
                                              classDefinitions] allValues];
                if(classDefinitions.count)
                    objClassDef = [classDefinitions objectAtIndex:0];
            }
            
            section = [SCObjectSection sectionWithHeaderTitle:nil withBoundObject:object withClassDefinition:objClassDef];
        }
            break;
            
        case SCPropertyTypeArrayOfObjects:
        {
            NSMutableArray *objectsArray = [_boundObject valueForKey:propertyDef.name];
            if(!objectsArray)
                break;
            
            SCClassDefinition *classDef = nil;
            NSArray *classDefinitions = nil;
            SCArrayOfObjectsSection *objectsSection = nil;
            SCArrayOfObjectsAttributes *objectsAttributes = nil;
            if([propertyDef.attributes isKindOfClass:[SCArrayOfObjectsAttributes class]])
            {
                objectsAttributes = (SCArrayOfObjectsAttributes *)propertyDef.attributes;
                classDefinitions = [objectsAttributes.classDefinitions allValues];
                if(classDefinitions.count)
                    classDef = [classDefinitions objectAtIndex:0];
            }
            
            if(coreDataBound)
            {
                if([[_boundObject valueForKey:propertyDef.name] isKindOfClass:[NSMutableSet class]])
                {
                    objectsSection = [SCArrayOfObjectsSection sectionWithHeaderTitle:nil withItemsSet:[_boundObject mutableSetValueForKey:propertyDef.name] withClassDefinition:classDef]; 
                }
                else
                    if([[_boundObject valueForKey:propertyDef.name] isKindOfClass:[NSArray class]])
                    {
                        objectsSection = [SCArrayOfObjectsSection sectionWithHeaderTitle:nil withItems:[_boundObject valueForKey:propertyDef.name] withClassDefinition:classDef];
                    }
            }
            else
            {
                objectsSection = [SCArrayOfObjectsSection sectionWithHeaderTitle:nil withItems:objectsArray withClassDefinition:classDef];
            }
            
            if(objectsSection)
            {
                [objectsSection.itemsClassDefinitions addEntriesFromDictionary:objectsAttributes.classDefinitions];
                objectsSection.allowAddingItems = objectsAttributes.allowAddingItems;
                objectsSection.allowDeletingItems = objectsAttributes.allowDeletingItems;
                objectsSection.allowMovingItems = objectsAttributes.allowMovingItems;
                objectsSection.allowEditDetailView = objectsAttributes.allowEditingItems;
                objectsSection.allowRowSelection = objectsAttributes.allowEditingItems;
                if([objectsAttributes.placeholderuiElement isKindOfClass:[SCTableViewCell class]])
                    objectsSection.placeholderCell = (SCTableViewCell *)objectsAttributes.placeholderuiElement;
                if([objectsAttributes.addNewObjectuiElement isKindOfClass:[SCTableViewCell class]])
                {
                    objectsSection.addNewItemCell = (SCTableViewCell *)objectsAttributes.addNewObjectuiElement;
                    objectsSection.addNewItemCellExistsInNormalMode = objectsAttributes.addNewObjectuiElementExistsInNormalMode;
                    objectsSection.addNewItemCellExistsInEditingMode = objectsAttributes.addNewObjectuiElementExistsInEditingMode;
                }
            }
            
            section = objectsSection;
        }
            break;
            
        default:
            section = nil;
    }
    
    return  section;
}

- (void)clear
{
	[self removeAllSections];
	[modelKeyValues removeAllObjects];
	activeCell = nil;
}

- (void)setModeledTableViewEditing:(BOOL)editing animated:(BOOL)animate
{
    if(editing == self.modeledTableView.editing)
        return;
    
    [self.modeledTableView beginUpdates];
    
    // Update sections to reflect new state
    for(SCTableViewSection *section in sections)
        [section editingModeWillChange];
    
    // Set editing mode
    [self.viewController setEditing:editing animated:animate];
	[self.modeledTableView setEditing:editing animated:animate];
    
    [self.modeledTableView endUpdates];
    
    // Notify section that editing mode has changed
    for(SCTableViewSection *section in sections)
        [section editingModeDidChange];
}

- (SCTableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
	return [[self sectionAtIndex:indexPath.section] cellAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForCell:(SCTableViewCell *)cell
{
	for(int i=0; i<self.sectionCount; i++)
	{
		NSUInteger index = [[self sectionAtIndex:i] indexForCell:cell];
		if(index == NSNotFound)
			continue;
		return [NSIndexPath indexPathForRow:index inSection:i];
	}
	return nil;
}

- (SCTableViewCell *)cellAfterCell:(SCTableViewCell *)cell rewindIfLastCell:(BOOL)rewind
{
	if(self.sectionCount==1 && [self sectionAtIndex:0].cellCount==1)
		return nil;		// only one cell in model
	
	NSIndexPath *indexPath = [self indexPathForCell:cell];
	SCTableViewSection *cellSection = [self sectionAtIndex:indexPath.section];
	if(indexPath.row+1 < cellSection.cellCount)
		return [cellSection cellAtIndex:indexPath.row+1];
	
	if(indexPath.section+1 < self.sectionCount)
		return [[self sectionAtIndex:indexPath.section+1] cellAtIndex:0];
	
	if(!rewind)
		return nil;
	
	return [[self sectionAtIndex:0] cellAtIndex:0];
}

- (BOOL)valuesAreValid
{
	for(SCTableViewSection *section in sections)
		if(!section.valuesAreValid)
			return FALSE;
	
	return TRUE;
}

- (void)reloadBoundValues
{
	for(SCTableViewSection *section in sections)
		[section reloadBoundValues];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return self.sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self sectionAtIndex:section].cellCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(self.hideSectionHeaderTitles)
		return nil;
	//else
	return [self sectionAtIndex:section].headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return [self sectionAtIndex:section].footerTitle;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if(index < self.sectionCount)
		return index;
	//else return the last section index
	return self.sectionCount-1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self cellAtIndexPath:indexPath].editable;  
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self cellAtIndexPath:indexPath].movable;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return [self cellAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
											forRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewSection *section = [self sectionAtIndex:indexPath.section];
	if([section isKindOfClass:[SCArrayOfItemsSection class]])
		[(SCArrayOfItemsSection *)section commitEditingStyle:editingStyle 
											forCellAtIndexPath:indexPath];
	
	if([self.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.dataSource respondsToSelector:@selector(tableViewModel:commitEditingStyle:forRowAtIndexPath:)])
	{
		[self.dataSource tableViewModel:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
													toIndexPath:(NSIndexPath *)toIndexPath
{
	SCTableViewSection *section = [self sectionAtIndex:fromIndexPath.section];
	if([section isKindOfClass:[SCArrayOfItemsSection class]])
		[(SCArrayOfItemsSection *)section moveCellAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
	
	if([self.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.dataSource respondsToSelector:@selector(tableViewModel:moveRowAtIndexPath:toIndexPath:)])
	{
		[self.dataSource tableViewModel:self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
	}
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCTableViewSection *section = [self sectionAtIndex:indexPath.section];
    if([section isKindOfClass:[SCArrayOfItemsSection class]])
        return [(SCArrayOfItemsSection *)section heightForCellAtIndexPath:indexPath];
    
    
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(willConfigureCell:)])
	{
		[cell.delegate willConfigureCell:cell];
	}
	else
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate 
			   respondsToSelector:@selector(tableViewModel:willConfigureCell:forRowAtIndexPath:)])
		{
			[self.delegate tableViewModel:self willConfigureCell:cell forRowAtIndexPath:indexPath];
		}
	
	CGFloat cellHeight = cell.height;
	// Check if the cell has an image in its section and resize accordingly
	if([section.cellsImageViews count] > indexPath.row)
	{
		UIImageView *imageView = [section.cellsImageViews objectAtIndex:indexPath.row];
		if([imageView isKindOfClass:[UIImageView class]])
		{
			if(cellHeight < imageView.image.size.height)
				cellHeight = imageView.image.size.height;
		}
	}
	
	return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	SCTableViewSection *scSection = [self sectionAtIndex:section];
	CGFloat height = scSection.headerHeight;
	UIFont *headerFont = nil;
	if(height == 0)
	{
		switch (tableView.style)
		{
			case UITableViewStylePlain:
				height = 22;
				headerFont = [UIFont boldSystemFontOfSize:17];
				break;
			case UITableViewStyleGrouped:
				height = 46;
				headerFont = [UIFont boldSystemFontOfSize:22];
				break;
		}
	}
	
	// Check that height is greater than the headerTitle text height
	CGSize constraintSize = CGSizeMake(self.modeledTableView.frame.size.width, 
									   self.modeledTableView.frame.size.height);
	CGFloat textHeight = 0;
	if(scSection.headerTitle)
	{
		textHeight = [scSection.headerTitle sizeWithFont:headerFont
									   constrainedToSize:constraintSize
										   lineBreakMode:UILineBreakModeWordWrap].height;
	}
	
	if(height < textHeight)
		height = textHeight;
	
	if(scSection.headerView)
		height = scSection.headerView.frame.size.height;
	
	return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	SCTableViewSection *scSection = [self sectionAtIndex:section];
	CGFloat height = scSection.footerHeight;
	UIFont *footerFont = nil;
	if(height == 0)
	{
		switch (tableView.style)
		{
			case UITableViewStylePlain:
				height = 22;
				footerFont = [UIFont boldSystemFontOfSize:17];
				break;
			case UITableViewStyleGrouped:
				height = 22;
				footerFont = [UIFont boldSystemFontOfSize:19];
				break;
		}
	}
	
	// Check that height is greater than the footerTitle text height
	CGSize constraintSize = CGSizeMake(self.modeledTableView.frame.size.width, 
									   self.modeledTableView.frame.size.height);
	CGFloat textHeight = 0;
	if(scSection.footerTitle)
	{
		textHeight = [scSection.footerTitle sizeWithFont:footerFont
									   constrainedToSize:constraintSize
										   lineBreakMode:UILineBreakModeWordWrap].height;
	}
	
	if(height < textHeight)
		height = textHeight;
	
	if(scSection.footerView)
		height = scSection.footerView.frame.size.height;
	
	return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return [self sectionAtIndex:section].headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return [self sectionAtIndex:section].footerView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self cellAtIndexPath:indexPath].cellEditingStyle;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *scCell = (SCTableViewCell *)cell;
	[scCell willDisplay];
	
	// Check if the cell has an image in its section
	SCTableViewSection *section = [self sectionAtIndex:indexPath.section];
	if([section.cellsImageViews count] > indexPath.row)
	{
		UIImageView *imageView = [section.cellsImageViews objectAtIndex:indexPath.row];
		if([imageView isKindOfClass:[UIImageView class]])
			scCell.imageView.image = imageView.image;
	}
	
	if([scCell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [scCell.delegate respondsToSelector:@selector(willDisplayCell:)])
	{
		[scCell.delegate willDisplayCell:scCell];
	}
	else
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate 
			   respondsToSelector:@selector(tableViewModel:willDisplayCell:forRowAtIndexPath:)])
		{
			[self.delegate tableViewModel:self willDisplayCell:scCell forRowAtIndexPath:indexPath];
		}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.lockCellSelection)
		return nil;
	
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	
	if(!cell.selectable)
		return nil;
	
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(willSelectCell:)])
	{
		[cell.delegate willSelectCell:cell];
	}
	else	
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModel:willSelectRowAtIndexPath:)])
		{
			[self.delegate tableViewModel:self willSelectRowAtIndexPath:indexPath];
		}
	
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
    
    if(!cell.enabled)
        return;
    
	if(cell != self.activeCell)
	{
		if(self.activeCell.autoResignFirstResponder)
			[self.activeCell resignFirstResponder];
		if(!cell.beingReused)  // make sure it's a static cell, otherwise it could be deleted by UITableViewController and should not be referenced
			self.activeCell = cell;
		else
			self.activeCell = nil;
	}
	[activeCell didSelectCell];
	
	SCTableViewSection *section = [self sectionAtIndex:indexPath.section];
	if([section isKindOfClass:[SCSelectionSection class]])
		[(SCSelectionSection *)section didSelectCellAtIndexPath:indexPath];
	
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(didSelectCell:)])
	{
		[cell.delegate didSelectCell:cell];
	}
	else	
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModel:didSelectRowAtIndexPath:)])
		{
			[self.delegate tableViewModel:self didSelectRowAtIndexPath:indexPath];
		}
		else
		{
			if([section isKindOfClass:[SCArrayOfItemsSection class]] 
			   && ![section isKindOfClass:[SCSelectionSection class]])
				[(SCArrayOfItemsSection *)section didSelectCellAtIndexPath:indexPath];
		}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	[cell willDeselectCell];
	
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(didDeselectCell:)])
	{
		[cell.delegate didDeselectCell:cell];
	}
	else	
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModel:didDeselectRowAtIndexPath:)])
		{
			[self.delegate tableViewModel:self didDeselectRowAtIndexPath:indexPath];
		}
}

- (void)tableView:(UITableView *)tableView 
					accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(accessoryButtonTappedForCell:)])
	{
		[cell.delegate accessoryButtonTappedForCell:cell];
	}
	else
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate 
			   respondsToSelector:@selector(tableViewModel:accessoryButtonTappedForRowWithIndexPath:)])
		{
			[self.delegate tableViewModel:self accessoryButtonTappedForRowWithIndexPath:indexPath];
		}
		else
		{
			[self tableView:tableView didSelectRowAtIndexPath:indexPath];
		}
}

- (NSString *)tableView:(UITableView *)tableView 
	titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *deleteTitle;
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate 
		   respondsToSelector:@selector(tableViewModel:titleForDeleteConfirmationButtonForRowAtIndexPath:)])
	{
		deleteTitle = [self.delegate tableViewModel:self titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
	}
	else
	{
		deleteTitle = NSLocalizedString(@"Delete", @"Delete Button Title");
	}
	
	return deleteTitle;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSIndexPath *indexPath = proposedDestinationIndexPath;
    
    SCTableViewSection *section = [self sectionAtIndex:sourceIndexPath.section];
	if([section isKindOfClass:[SCArrayOfItemsSection class]])
		indexPath = [(SCArrayOfItemsSection *)section targetIndexPathForMoveFromCellAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
    
    return indexPath;
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate 
			   respondsToSelector:@selector(tableViewModel:lazyLoadCell:forRowAtIndexPath:)])
		{
            NSArray *visiblePaths = [self.modeledTableView indexPathsForVisibleRows];
            for(NSIndexPath *indexPath in visiblePaths)
            {
                SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
                [self.delegate tableViewModel:self lazyLoadCell:cell forRowAtIndexPath:indexPath];  
            }
		}
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
       && [self.delegate 
           respondsToSelector:@selector(tableViewModel:lazyLoadCell:forRowAtIndexPath:)])
    {
        NSArray *visiblePaths = [self.modeledTableView indexPathsForVisibleRows];
        for(NSIndexPath *indexPath in visiblePaths)
        {
            SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
            [self.delegate tableViewModel:self lazyLoadCell:cell forRowAtIndexPath:indexPath];  
        }
    }
}

#pragma mark -
#pragma mark Keyboard methods

- (void)keyboardWillShow:(NSNotification *)aNotification
{
	if(!self.autoResizeForKeyboard || keyboardShown) 
		return;
	
	keyboardShown = YES;
	
	// Get the size & animation details of the keyboard
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect keyWindowFrame = keyWindow.frame;
	NSDictionary* userInfo = [aNotification userInfo];
#ifdef __IPHONE_3_2
#ifdef DEPLOYMENT_OS_PRIOR_TO_3_2
	CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;
#else
	CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
#endif
#else
	CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size; 
#endif
    CGFloat keyWindowHeight;
	CGFloat keyboardHeight;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if(orientation==UIInterfaceOrientationPortrait || orientation==UIInterfaceOrientationPortraitUpsideDown)
	{
        keyWindowHeight = keyWindowFrame.size.height;
		keyboardHeight = keyboardSize.height;
	}
	else
	{
        keyWindowHeight = keyWindowFrame.size.width;
		keyboardHeight = keyboardSize.width;
	}
	
    NSTimeInterval animationDuration;
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	UIViewAnimationCurve animationCurve;
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	
	// Determine how much overlap exists between modeledTableView and the keyboard
    CGRect tableFrame = self.modeledTableView.frame;
    CGPoint convertedTableOrigin = [self.modeledTableView.superview convertPoint:tableFrame.origin 
                                                                          toView:[keyWindow.subviews objectAtIndex:0]];
	CGFloat tableLowerYCoord = convertedTableOrigin.y + tableFrame.size.height;
	CGFloat keyboardUpperYCoord = keyWindowHeight - keyboardHeight;
	keyboardOverlap = tableLowerYCoord - keyboardUpperYCoord;
	
	if(keyboardOverlap < 0)
		keyboardOverlap = 0;
	
	if(keyboardOverlap != 0)
	{
		tableFrame.size.height -= keyboardOverlap;
		
		NSTimeInterval delay = 0;
		if(keyboardHeight)
		{
			delay = (1 - keyboardOverlap/keyboardHeight)*animationDuration;
			animationDuration = animationDuration * keyboardOverlap/keyboardHeight;
		}
		
#ifdef __IPHONE_4_0
#ifdef DEPLOYMENT_OS_PRIOR_TO_3_2
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(tableAnimationEnded:finished:contextInfo:)];
		[UIView setAnimationDelay:delay];
		[UIView setAnimationDuration:animationDuration];
		[UIView setAnimationCurve:animationCurve];
		self.modeledTableView.frame = tableFrame;
		[UIView commitAnimations];
#else
		[UIView animateWithDuration:animationDuration delay:delay 
							options:UIViewAnimationOptionBeginFromCurrentState 
						 animations:^{ self.modeledTableView.frame = tableFrame; } 
						 completion:^(BOOL finished){ [self tableAnimationEnded:nil finished:nil contextInfo:nil]; }];
#endif
#else
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(tableAnimationEnded:finished:contextInfo:)];
		[UIView setAnimationDelay:delay];
		[UIView setAnimationDuration:animationDuration];
		[UIView setAnimationCurve:animationCurve];
		self.modeledTableView.frame = tableFrame;
		[UIView commitAnimations];
#endif
	}
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
	if(!self.autoResizeForKeyboard || !keyboardShown)
		return;
	
	keyboardShown = NO;
	
	if(keyboardOverlap == 0)
		return;
	
	// Get the size & animation details of the keyboard
	NSDictionary* userInfo = [aNotification userInfo];
#ifdef __IPHONE_3_2
#ifdef DEPLOYMENT_OS_PRIOR_TO_3_2
	CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;
#else
	CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
#endif
#else
	CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size; 
#endif
	CGFloat keyboardHeight;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if(orientation==UIInterfaceOrientationPortrait || orientation==UIInterfaceOrientationPortraitUpsideDown)
	{
		keyboardHeight = keyboardSize.height;
	}
	else
	{
		keyboardHeight = keyboardSize.width;
	}
	
    NSTimeInterval animationDuration;
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	
	CGRect tableFrame = self.modeledTableView.frame; 
	tableFrame.size.height += keyboardOverlap;
	
	if(keyboardHeight)
		animationDuration = animationDuration * keyboardOverlap/keyboardHeight;
	
#ifdef __IPHONE_4_0
#ifdef DEPLOYMENT_OS_PRIOR_TO_3_2
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:animationDuration];
	self.modeledTableView.frame = tableFrame;
	[UIView commitAnimations];
#else
	[UIView animateWithDuration:animationDuration delay:0 
						options:UIViewAnimationOptionBeginFromCurrentState 
					 animations:^{ self.modeledTableView.frame = tableFrame; } 
					 completion:nil];
#endif
#else
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    self.modeledTableView.frame = tableFrame;
    [UIView commitAnimations];
#endif
}

- (void) tableAnimationEnded:(NSString*)animationID finished:(NSNumber *)finished contextInfo:(void *)context
{
	// Scroll to the active cell
	if(self.activeCell)
	{
		NSIndexPath *indexPath = [self indexPathForCell:self.activeCell];
		[self.modeledTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone
											 animated:YES];
	}
}


@end







@interface SCArrayOfItemsModel ()

- (void)generateSections;
- (NSString *)getHeaderTitleForItemAtIndex:(NSUInteger)index;

@end



@implementation SCArrayOfItemsModel

@synthesize items;
@synthesize itemsAccessoryType;
@synthesize allowAddingItems;
@synthesize allowDeletingItems;
@synthesize allowMovingItems;
@synthesize allowEditDetailView;
@synthesize allowRowSelection;
@synthesize autoSelectNewItemCell;
@synthesize detailViewModal;
#ifdef __IPHONE_3_2
@synthesize detailViewModalPresentationStyle;
#endif
@synthesize detailTableViewStyle;
@synthesize detailViewHidesBottomBar;
@synthesize addButtonItem;
@synthesize searchBar;


- (id)init
{
	if( (self=[super init]) )
	{
		tempSection = nil;
		items = nil;
		itemsAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		allowAddingItems = TRUE;
		allowDeletingItems = TRUE;
		allowMovingItems = FALSE;
		allowEditDetailView = TRUE;
		allowRowSelection = TRUE;
		autoSelectNewItemCell = FALSE;
		detailViewModal = FALSE;
#ifdef __IPHONE_3_2
		detailViewModalPresentationStyle = UIModalPresentationFullScreen;
#endif
		
		detailTableViewStyle = UITableViewStyleGrouped;
		detailViewHidesBottomBar = TRUE;
		addButtonItem = nil;
		
		filteredArray = nil;
		searchBar = nil;
	}
	
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
			  withItems:(NSMutableArray *)_items
{
	if([self initWithTableView:_modeledTableView withViewController:_viewController])
	{
		self.items = _items;  // setter will generate sections
	}
	return self;
}

- (void)dealloc
{
	[tempSection release];
	[items release];
	[addButtonItem release];
	[filteredArray release];
	[searchBar release];
	
	[super dealloc];
}

//override superclass
- (void)reloadBoundValues
{
	[self generateSections];
}

- (void)generateSections
{
	[self removeAllSections];
	
	NSArray *itemsArray;
	if(filteredArray)
		itemsArray = filteredArray;
	else
		itemsArray = self.items;
	
	BOOL respondsToSectionGenerated = FALSE;
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModel:sectionGenerated:atIndex:)])
	{
		respondsToSectionGenerated = TRUE;
	}
	
	for(int i=0; i<itemsArray.count; i++)
	{
		NSString *headerTitle = [self getHeaderTitleForItemAtIndex:i];
		SCArrayOfItemsSection *section = (SCArrayOfItemsSection *)[self sectionWithHeaderTitle:headerTitle];
		if(!section)
		{
			section = [self createSectionWithHeaderTitle:headerTitle];
			if(!section)
				continue;
			[self setPropertiesForSection:section];
			[self addSection:section];
			
			if(respondsToSectionGenerated)
				[self.delegate tableViewModel:self sectionGenerated:section atIndex:i];
		}
		[section.items addObject:[itemsArray objectAtIndex:i]];
	}
}

- (NSString *)getHeaderTitleForItemAtIndex:(NSUInteger)index
{
	NSArray *itemsArray;
	if(filteredArray)
		itemsArray = filteredArray;
	else
		itemsArray = self.items;
	
	NSString *headerTitleName = nil;
	if([self.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.dataSource respondsToSelector:@selector(tableViewModel:sectionHeaderTitleForItem:AtIndex:)])
	{
		headerTitleName = [self.dataSource tableViewModel:self sectionHeaderTitleForItem:[itemsArray objectAtIndex:index]
												  AtIndex:index];
	}
	
	return headerTitleName;
}

- (NSUInteger)getSectionIndexForItem:(NSObject *)item
{
	NSUInteger itemIndex = [self.items indexOfObjectIdenticalTo:item];
	NSString *sectionHeader = [self getHeaderTitleForItemAtIndex:itemIndex];
	
	NSUInteger sectionIndex = NSNotFound;
	for(NSUInteger i=0; i<self.sectionCount; i++)
		if([[self sectionAtIndex:i].headerTitle isEqualToString:sectionHeader])
		   {
			   sectionIndex = i;
			   break;
		   }
	
	return sectionIndex;
}

- (SCArrayOfItemsSection *)createSectionWithHeaderTitle:(NSString *)title
{
	return nil;  // method must be overridden by subclasses
}

- (void)setSearchBar:(UISearchBar *)sbar
{
	[searchBar release];
	searchBar = [sbar retain];
	searchBar.delegate = self;
}

- (void)setPropertiesForSection:(SCArrayOfItemsSection *)section
{
	section.itemsAccessoryType = self.itemsAccessoryType;
	section.allowAddingItems = self.allowAddingItems;
	section.allowDeletingItems = self.allowDeletingItems;
	section.allowMovingItems = self.allowMovingItems;
	section.allowEditDetailView = self.allowEditDetailView;
	section.allowRowSelection = self.allowRowSelection;
	section.autoSelectNewItemCell = self.autoSelectNewItemCell;
	section.detailViewModal = self.detailViewModal;
#ifdef __IPHONE_3_2
	section.detailViewModalPresentationStyle = self.detailViewModalPresentationStyle;
#endif
	section.detailTableViewStyle = self.detailTableViewStyle;
	section.detailViewHidesBottomBar = self.detailViewHidesBottomBar;
}

- (void)setItems:(NSMutableArray *)array
{
	[items release];
	items = [array retain];
	
	[self generateSections];
}

// override superclass
- (void)setAutoSortSections:(BOOL)autoSort
{
	[super setAutoSortSections:autoSort];
	
	if(autoSort)
		[self generateSections];
}

// override superclass
- (void)setItemsAccessoryType:(UITableViewCellAccessoryType)type
{
	itemsAccessoryType = type;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).itemsAccessoryType = type;
}

// override superclass
- (void)setAllowAddingItems:(BOOL)allow
{
	allowAddingItems = allow;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).allowAddingItems = allow;
}

// override superclass
- (void)setAllowDeletingItems:(BOOL)allow
{
	allowDeletingItems = allow;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).allowDeletingItems = allow;
}

// override superclass
- (void)setAllowMovingItems:(BOOL)allow
{
	allowMovingItems = allow;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).allowMovingItems = allow;
}

// override superclass
- (void)setAllowEditDetailView:(BOOL)allow
{
	allowEditDetailView = allow;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).allowEditDetailView = allow;
}

// override superclass
- (void)setAllowRowSelection:(BOOL)allow
{
	allowRowSelection = allow;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).allowRowSelection = allow;
}

// override superclass
- (void)setAutoSelectNewItemCell:(BOOL)allow
{
	autoSelectNewItemCell = allow;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).autoSelectNewItemCell = allow;
}

// override superclass
- (void)setDetailViewModal:(BOOL)modal
{
	detailViewModal = modal;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).detailViewModal = modal;
}

#ifdef __IPHONE_3_2
// override superclass
- (void)setDetailViewModalPresentationStyle:(UIModalPresentationStyle)style
{
	detailViewModalPresentationStyle = style;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).detailViewModalPresentationStyle = style;
}
#endif

// override superclass
- (void)setDetailTableViewStyle:(UITableViewStyle)style
{
	detailTableViewStyle = style;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).detailTableViewStyle = style;
}

// override superclass
- (void)setDetailViewHidesBottomBar:(BOOL)hides
{
	detailViewHidesBottomBar = hides;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).detailViewHidesBottomBar = hides;
}

- (void)setAddButtonItem:(UIBarButtonItem *)barButtonItem
{
	[addButtonItem release];
	addButtonItem = [barButtonItem retain];
	
	addButtonItem.target = self;
	addButtonItem.action = @selector(didTapAddButtonItem);
}

- (void)didTapAddButtonItem
{
	// Game plan: delegate presenting the add detail view to SCArrayOfItemsSection
	
	//cancel any search in progress
	if([self.searchBar.text length])
		self.searchBar.text = nil;
	
	SCArrayOfItemsSection *section;
	if(self.sectionCount)
	{
		section = (SCArrayOfItemsSection *)[self sectionAtIndex:0];
	}
	else
	{
		if(!tempSection)
		{
			tempSection = [[self createSectionWithHeaderTitle:nil] retain];
			tempSection.ownerTableViewModel = self;
			[self setPropertiesForSection:tempSection];
		}
		section = tempSection;
	}
	
	[section didTapAddButtonItem];
}

- (void)addNewItem:(NSObject *)newItem
{
	[self.items addObject:newItem];
	NSUInteger itemIndex = self.items.count-1;
	
	NSString *headerTitle = [self getHeaderTitleForItemAtIndex:itemIndex];
	SCArrayOfItemsSection *section = (SCArrayOfItemsSection *)[self sectionWithHeaderTitle:headerTitle];
	if(!section)
	{
		// Add new section
		section = [self createSectionWithHeaderTitle:headerTitle];
		[self setPropertiesForSection:section];
		[self addSection:section];
		NSUInteger sectionIndex = [self indexForSection:section];
		
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModel:sectionGenerated:atIndex:)])
		{
			[self.delegate tableViewModel:self sectionGenerated:section atIndex:sectionIndex];
		}
		
		[self.modeledTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] 
							 withRowAnimation:UITableViewRowAnimationLeft];
		if(self.autoGenerateSectionIndexTitles)
		{
			[self.modeledTableView reloadData]; // reloadSectionIndexTitles not working!
		}
	}
	
	[section addNewItem:newItem];
}

- (void)itemModified:(NSObject *)item inSection:(SCArrayOfItemsSection *)section
{
	NSUInteger oldSectionIndex = [self indexForSection:section];
	NSUInteger newSectionIndex = [self getSectionIndexForItem:item];
	
	if(oldSectionIndex == newSectionIndex)
	{
		[section itemModified:item];
	}
	else
	{
		// remove item from old section
		NSIndexPath *oldIndexPath = 
		[NSIndexPath indexPathForRow:[section.items indexOfObjectIdenticalTo:item]
						   inSection:oldSectionIndex];
		[section.items removeObjectAtIndex:oldIndexPath.row];
		if(section.items.count)
		{
			[self.modeledTableView 
			 deleteRowsAtIndexPaths:[NSArray arrayWithObject:oldIndexPath] 
			 withRowAnimation:UITableViewRowAnimationRight];
		}
		else
		{
			[self removeSectionAtIndex:oldSectionIndex];
			[self.modeledTableView deleteSections:[NSIndexSet indexSetWithIndex:oldSectionIndex]
								 withRowAnimation:UITableViewRowAnimationRight];
		}
		
		[item retain];
		[self.items removeObjectIdenticalTo:item];
		// add the item from scratch
		[self addNewItem:item];
		[item release];
	}
}

// Overrides superclass
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
	
	// Remove the section if empty
	SCArrayOfItemsSection *section = (SCArrayOfItemsSection *)[self sectionAtIndex:indexPath.section];
	if(!section.items.count)
	{
		[self removeSectionAtIndex:indexPath.section];
		[self.modeledTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
							 withRowAnimation:UITableViewRowAnimationRight];
		if(self.autoGenerateSectionIndexTitles)
		{
			[self.modeledTableView reloadData]; // reloadSectionIndexTitles not working!
		}
	}
}


#pragma mark -
#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)sBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModel:searchBarSelectedScopeButtonIndexDidChange:)])
	{
		[self.delegate tableViewModel:self searchBarSelectedScopeButtonIndexDidChange:selectedScope];
	}
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)sBar
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModelSearchBarBookmarkButtonClicked:)])
	{
		[self.delegate tableViewModelSearchBarBookmarkButtonClicked:self];
	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sBar
{
	[self.searchBar resignFirstResponder];
	self.searchBar.text = nil;
	
	[filteredArray release];
	filteredArray = nil;
	[self generateSections];
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModelSearchBarCancelButtonClicked:)])
	{
		[self.delegate tableViewModelSearchBarCancelButtonClicked:self];
	}
	
	[self.modeledTableView reloadData];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)sBar
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModelSearchBarResultsListButtonClicked:)])
	{
		[self.delegate tableViewModelSearchBarResultsListButtonClicked:self];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sBar
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModelSearchBarSearchButtonClicked:)])
	{
		[self.delegate tableViewModelSearchBarSearchButtonClicked:self];
	}
}

@end







@implementation SCArrayOfStringsModel

- (SCArrayOfItemsSection *)createSectionWithHeaderTitle:(NSString *)title
{
	return [SCArrayOfStringsSection sectionWithHeaderTitle:title withItems:[NSMutableArray array]];
}


#pragma mark -
#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)sbar textDidChange:(NSString *)searchText
{
	NSArray *resultsArray = nil;
	
	if([sbar.text length])
	{
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", sbar.text];
		resultsArray = [self.items filteredArrayUsingPredicate:predicate];
		
		// Check for custom results
		NSArray *customResultsArray;
		if([self.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
		   && [self.dataSource respondsToSelector:@selector(tableViewModel:customSearchResultForSearchText:autoSearchResults:)])
		{
			customResultsArray = [self.dataSource tableViewModel:self customSearchResultForSearchText:searchText
											   autoSearchResults:resultsArray];
			if(customResultsArray)
				resultsArray = customResultsArray;
		}
	}
		
	[filteredArray release];
	filteredArray = [resultsArray retain];
	
	[self generateSections];
	[self.modeledTableView reloadData];
}

@end








@interface SCArrayOfObjectsModel ()

- (void)generateItemsArrayFromItemsSet;
- (SCClassDefinition *)firstClassDefinition;  // Returns the 1st classdef in classDefinitions
- (void)callCoreDataObjectsLoadedDelegate;

@end



@implementation SCArrayOfObjectsModel

@synthesize itemsPredicate;
@synthesize itemsClassDefinitions;
@synthesize itemsSet;
@synthesize sortItemsSetAscending;
@synthesize searchPropertyName;


+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
						withItems:(NSMutableArray *)_items
			  withClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
										  withItems:_items 
								withClassDefinition:classDefinition] autorelease];
}

+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
					 withItemsSet:(NSMutableSet *)_itemsSet
			  withClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
									   withItemsSet:_itemsSet 
								withClassDefinition:classDefinition] autorelease];
}

#ifdef _COREDATADEFINES_H
+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
		withEntityClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
						  withEntityClassDefinition:classDefinition] autorelease];
}

+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
		withEntityClassDefinition:(SCClassDefinition *)classDefinition
				   usingPredicate:(NSPredicate *)predicate
{
	return [[[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
						  withEntityClassDefinition:classDefinition
									 usingPredicate:predicate] autorelease];
}
#endif

- (id)init
{
	if( (self=[super init]) )
	{
		itemsPredicate = nil;
		itemsClassDefinitions = [[NSMutableDictionary alloc] init];
		
		itemsSet = nil;
		sortItemsSetAscending = TRUE;
		searchPropertyName = nil;
	}
	
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
			  withItems:(NSMutableArray *)_items
	withClassDefinition:(SCClassDefinition *)classDefinition
{
	if([self initWithTableView:_modeledTableView withViewController:_viewController])
	{		
		if(classDefinition)
		{
			[self.itemsClassDefinitions setValue:classDefinition forKey:classDefinition.className];
		}
		self.items = _items;  // setter will generate sections
	}
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
		   withItemsSet:(NSMutableSet *)_itemsSet
	withClassDefinition:(SCClassDefinition *)classDefinition
{
	if([self initWithTableView:_modeledTableView withViewController:_viewController])
	{	
		if(classDefinition)
		{
			[self.itemsClassDefinitions setValue:classDefinition forKey:classDefinition.className];
			self.itemsSet = _itemsSet;	// setter also generates items array
		}
	}
	return self;
}

#ifdef _COREDATADEFINES_H
- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
	withEntityClassDefinition:(SCClassDefinition *)classDefinition
{
	return [self initWithTableView:_modeledTableView withViewController:_viewController
				withEntityClassDefinition:classDefinition usingPredicate:nil];
}

- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
withEntityClassDefinition:(SCClassDefinition *)classDefinition
		 usingPredicate:(NSPredicate *)predicate
{
	if(predicate)
		self.itemsPredicate = predicate;
	
	// Create the sectionItems array
	NSMutableArray *sectionItems = [SCHelper generateObjectsArrayForEntityClassDefinition:classDefinition
																		   usingPredicate:self.itemsPredicate];
	
	[self initWithTableView:_modeledTableView withViewController:_viewController
                  withItems:sectionItems
        withClassDefinition:classDefinition];
    [self callCoreDataObjectsLoadedDelegate];
    
    return self;
}
#endif

- (void)dealloc
{
	[itemsPredicate release];
	[itemsClassDefinitions release];
	[itemsSet release];
	[searchPropertyName release];
		
	[super dealloc];
}

- (void)callCoreDataObjectsLoadedDelegate
{
    if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate 
		   respondsToSelector:@selector(tableViewModelCoreDataObjectsLoaded:)])
	{
		[self.delegate tableViewModelCoreDataObjectsLoaded:self];
	}
}

//override superclass
- (void)reloadBoundValues
{
#ifdef _COREDATADEFINES_H
	SCClassDefinition *classDef = [self firstClassDefinition];
	if(classDef.entity)
    {
        self.items = [SCHelper generateObjectsArrayForEntityClassDefinition:classDef usingPredicate:self.itemsPredicate];
        [self callCoreDataObjectsLoadedDelegate];
    }
		
#endif
	
	[super reloadBoundValues];
}

// override superclass method
- (SCArrayOfItemsSection *)createSectionWithHeaderTitle:(NSString *)title
{
	return [SCArrayOfObjectsSection sectionWithHeaderTitle:title withItems:[NSMutableArray array] 
									   withClassDefinition:[self firstClassDefinition]];
}

// override superclass method
- (void)setPropertiesForSection:(SCArrayOfItemsSection *)section
{
	[super setPropertiesForSection:section];
	
	if([section isKindOfClass:[SCArrayOfObjectsSection class]])
	{
		[[(SCArrayOfObjectsSection *)section itemsClassDefinitions] 
		 addEntriesFromDictionary:self.itemsClassDefinitions];
	}
}

-(void)setItemsSet:(NSMutableSet *)set
{
	[itemsSet release];
	itemsSet = [set retain];
	
	[self generateItemsArrayFromItemsSet];
}

-(void)setSortItemsSetAscending:(BOOL)ascending
{
	sortItemsSetAscending = ascending;
	[self generateItemsArrayFromItemsSet];
}

- (void)generateItemsArrayFromItemsSet
{
	if(!self.itemsSet)
	{
		self.items = nil;
		return;
	}
	
	SCClassDefinition *classDef = [self firstClassDefinition];
	NSString *key;
	if(classDef.orderAttributeName)
		key = classDef.orderAttributeName;
	else
		key = classDef.keyPropertyName;
	NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[self.itemsSet allObjects]]; 
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] 
									initWithKey:key
									ascending:self.sortItemsSetAscending];
	[sortedArray sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	[descriptor release];
	
	self.items = sortedArray;
}

- (SCClassDefinition *)firstClassDefinition
{
	SCClassDefinition *classDef = nil;
	if([self.itemsClassDefinitions count])
	{
		classDef = [self.itemsClassDefinitions 
					valueForKey:[[self.itemsClassDefinitions allKeys] objectAtIndex:0]];
	}
	
	return classDef;
}

#pragma mark -
#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)sbar textDidChange:(NSString *)searchText
{
	NSArray *resultsArray = nil;
	
	if([sbar.text length])
	{
		SCClassDefinition *objClassDef = [self firstClassDefinition];
		
		if(!self.searchPropertyName)
			self.searchPropertyName = objClassDef.titlePropertyName;
		
		NSArray *searchProperties;
		if([self.searchPropertyName isEqualToString:@"*"])
		{
			searchProperties = [NSMutableArray arrayWithCapacity:objClassDef.propertyDefinitionCount];
			for(int i=0; i<objClassDef.propertyDefinitionCount; i++)
				[(NSMutableArray *)searchProperties addObject:[objClassDef propertyDefinitionAtIndex:i].name];
		}
		else
		{
			searchProperties = [self.searchPropertyName componentsSeparatedByString:@";"];
		}

		NSMutableString *predicateFormat = [NSMutableString string];
		for(int i=0; i<searchProperties.count; i++)
		{
			NSString *property = [searchProperties objectAtIndex:i];
			if(i==0)
				[predicateFormat appendFormat:@"%@ contains[c] '%@'", property, sbar.text];
			else
				[predicateFormat appendFormat:@" OR %@ contains[c] '%@'", property, sbar.text];
		}
		NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
		
		@try 
		{
			resultsArray = [self.items filteredArrayUsingPredicate:predicate];
		}
		@catch (NSException * e) 
		{
			// handle any unexpected property-name behavior gracefully
			resultsArray = [NSArray array]; //empty array
		}
		
		// Check for custom results
		NSArray *customResultsArray;
		if([self.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
		   && [self.dataSource respondsToSelector:@selector(tableViewModel:customSearchResultForSearchText:autoSearchResults:)])
		{
			customResultsArray = [self.dataSource tableViewModel:self customSearchResultForSearchText:searchText
											   autoSearchResults:resultsArray];
			if(customResultsArray)
				resultsArray = customResultsArray;
		}
	}
	
	[filteredArray release];
	filteredArray = [resultsArray retain];
	
	[self generateSections];
	[self.modeledTableView reloadData];
}

@end



