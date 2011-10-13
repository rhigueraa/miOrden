/*
 *  SCTableViewModel.m
 *  Sensible TableView
 *  Version: 2.1.6
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

#import <objc/message.h>
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
@synthesize autoAssignDataSourceForDetailModels;
@synthesize autoAssignDelegateForDetailModels;
@synthesize previousActiveCell;
@synthesize activeCell;
@synthesize modelKeyValues;
@synthesize commitButton;
@synthesize swipeToDeleteActive;


+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
{
	return SC_Autorelease([[[self class] alloc] initWithTableView:_modeledTableView
								 withViewController:_viewController]);
}

- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
{
	if( (self=[self init]) )
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
        
        autoAssignDataSourceForDetailModels = FALSE;
        autoAssignDelegateForDetailModels = FALSE;
        
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
        swipeToDeleteActive = FALSE;
		
		// Register with the shared model center
		[[SCModelCenter sharedModelCenter] registerModel:self];
	}
	
	return self;
}

- (void)dealloc
{
	// Unregister from the shared model center
	[[SCModelCenter sharedModelCenter] unregisterModel:self];
#ifndef ARC_ENABLED	
	[editButtonItem release];
	[sectionIndexTitles release];
	[sections release];
	[modelKeyValues release];
	[commitButton release];

	[super dealloc];
#endif
}

- (void)configureDetailModel:(SCTableViewModel *)detailModel
{
    detailModel.tag = self.tag + 1;
    detailModel.autoAssignDataSourceForDetailModels = self.autoAssignDataSourceForDetailModels;
    detailModel.autoAssignDelegateForDetailModels = self.autoAssignDelegateForDetailModels;
    if(self.autoAssignDataSourceForDetailModels)
        detailModel.dataSource = self.dataSource;
    if(self.autoAssignDelegateForDetailModels)
        detailModel.delegate = self.delegate;
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
	[previousActiveCell didDeselectCell];
    
    // make sure it's a static cell, otherwise it could be released by UITableView and should not be referenced
	if(!cell.beingReused)
        activeCell = cell;
    else
        activeCell = nil;
	
	NSIndexPath *indexPath = [self indexPathForCell:activeCell];
	[self.modeledTableView scrollToRowAtIndexPath:indexPath
								 atScrollPosition:UITableViewScrollPositionNone
										 animated:YES];
}

- (void)setCommitButton:(UIBarButtonItem *)button
{
	SC_Release(commitButton);
	commitButton = SC_Retain(button);
	
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
	SC_Release(editButtonItem);
	editButtonItem = SC_Retain(barButtonItem);
	
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
        objc_msgSend(target, action);
}

- (void)valueChangedForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(!indexPath)
		return;
	
	SCTableViewCell *cell = (SCTableViewCell *)[self.modeledTableView cellForRowAtIndexPath:indexPath];
	if(cell != self.activeCell)
	{
		if(self.activeCell.autoResignFirstResponder)
			[self.activeCell resignFirstResponder];
		self.activeCell = cell;
	}
	
	if(target)
        objc_msgSend(target, action);
	
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
	
	[self setModeledTableViewEditing:editing animated:TRUE];
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
    
    NSInteger sectionIndex = [sections indexOfObjectIdenticalTo:section];
    if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModel:didAddSectionAtIndex:)])
	{
		[self.delegate tableViewModel:self didAddSectionAtIndex:sectionIndex];
	}
}

- (void)insertSection:(SCTableViewSection *)section atIndex:(NSUInteger)index
{
	section.ownerTableViewModel = self;
	if(![section isKindOfClass:[SCArrayOfItemsSection class]])
	{
		for(int i=0; i<section.cellCount; i++)
			[section cellAtIndex:i].ownerTableViewModel = self;
	}
	[sections insertObject:section atIndex:index];
    
    if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModel:didAddSectionAtIndex:)])
	{
		[self.delegate tableViewModel:self didAddSectionAtIndex:index];
	}
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
    
    if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModel:didRemoveSectionAtIndex:)])
	{
		[self.delegate tableViewModel:self didRemoveSectionAtIndex:index];
	}
}

- (void)removeAllSections
{
    self.activeCell = nil;
    previousActiveCell = nil;
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
                SC_Release(objectSection);
                
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
        SC_Release(objectSection);
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
            NSObject *object = [SCHelper valueForPropertyName:propertyDef.name inObject:_boundObject];
            
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
            
            section = objectsSection;
        }
            break;
            
        case SCPropertyTypeSelection:
            if(propertyDef.dataType == SCPropertyDataTypeNSNumber)
            {
                section = [SCSelectionSection sectionWithHeaderTitle:nil withBoundObject:_boundObject withSelectedIndexPropertyName:propertyDef.name  withItems:nil];
            }
            else
                if(propertyDef.dataType == SCPropertyDataTypeNSString)
                {
                    section = [SCSelectionSection sectionWithHeaderTitle:nil withBoundObject:_boundObject withSelectionStringPropertyName:propertyDef.name withItems:nil];
                }
                else
                    if(propertyDef.dataType == SCPropertyDataTypeNSMutableSet)
                    {
                        section = [SCSelectionSection sectionWithHeaderTitle:nil withBoundObject:_boundObject withSelectedIndexesPropertyName:propertyDef.name withItems:nil allowMultipleSelection:FALSE];
                    }
            break;
        case SCPropertyTypeObjectSelection:
            section = [SCObjectSelectionSection sectionWithHeaderTitle:nil withBoundObject:_boundObject withSelectedObjectPropertyName:propertyDef.name withItems:nil withItemsClassDefintion:nil];
            break;
            
        default:
            section = nil;
    }
    
    if(section)
        [section setAttributesTo:propertyDef.attributes];
    
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
    
    if(self.swipeToDeleteActive)
    {
        [self.modeledTableView setEditing:NO animated:animate];
        swipeToDeleteActive = FALSE;
        return;
    }
    
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

- (NSIndexPath *)indexPathForCellAfterCell:(SCTableViewCell *)cell rewindIfLastCell:(BOOL)rewind
{
    if(self.sectionCount==1 && [self sectionAtIndex:0].cellCount==1)
		return nil;		// only one cell in model
	
	NSIndexPath *indexPath = [self indexPathForCell:cell];
	SCTableViewSection *cellSection = [self sectionAtIndex:indexPath.section];
	if(indexPath.row+1 < cellSection.cellCount)
		return [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
	
	if(indexPath.section+1 < self.sectionCount)
		return [NSIndexPath indexPathForRow:0 inSection:indexPath.section+1];
	
	if(!rewind)
		return nil;
	
	return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (SCTableViewCell *)cellAfterCell:(SCTableViewCell *)cell rewindIfLastCell:(BOOL)rewind
{
	NSIndexPath *nextCellIndexPath = [self indexPathForCellAfterCell:cell rewindIfLastCell:rewind];
    
    if(!nextCellIndexPath)
        return nil;
    //else
    return (SCTableViewCell *)[self.modeledTableView cellForRowAtIndexPath:nextCellIndexPath];
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
    BOOL movable = [self cellAtIndexPath:indexPath].movable;
	return movable;
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
	if(height==0 && scSection.headerTitle)
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
	if(height==0 && scSection.footerTitle)
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
	
	SCTableViewCell *cell = (SCTableViewCell *)[self.modeledTableView cellForRowAtIndexPath:indexPath];
	
	if(!cell.selectable || !cell.enabled)
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
	SCTableViewCell *cell = (SCTableViewCell *)[self.modeledTableView cellForRowAtIndexPath:indexPath];
    
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
	SCTableViewCell *cell = (SCTableViewCell *)[self.modeledTableView cellForRowAtIndexPath:indexPath];
	[cell willDeselectCell];
	
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *cell = (SCTableViewCell *)[self.modeledTableView cellForRowAtIndexPath:indexPath];
	
	[cell didDeselectCell];
}

- (void)tableView:(UITableView *)tableView 
					accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *cell = (SCTableViewCell *)[self.modeledTableView cellForRowAtIndexPath:indexPath];
	
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

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    swipeToDeleteActive = TRUE;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    swipeToDeleteActive = FALSE;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView cellForRowAtIndexPath:indexPath].shouldIndentWhileEditing;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
       && [self.delegate respondsToSelector:@selector(tableViewModelDidScroll:)])
    {
        [self.delegate tableViewModelDidScroll:self];  
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModel:lazyLoadCell:forRowAtIndexPath:)])
		{
            NSArray *visiblePaths = [self.modeledTableView indexPathsForVisibleRows];
            for(NSIndexPath *indexPath in visiblePaths)
            {
                SCTableViewCell *cell = (SCTableViewCell *)[self.modeledTableView cellForRowAtIndexPath:indexPath];
                [self.delegate tableViewModel:self lazyLoadCell:cell forRowAtIndexPath:indexPath];  
            }
		}
    }
    
    if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
       && [self.delegate respondsToSelector:@selector(tableViewModelDidEndDragging:willDecelerate:)])
    {
        [self.delegate tableViewModelDidEndDragging:self willDecelerate:decelerate];  
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
            SCTableViewCell *cell = (SCTableViewCell *)[self.modeledTableView cellForRowAtIndexPath:indexPath];
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
    
    UIView *tableView;
    if([self.modeledTableView.superview isKindOfClass:[UIScrollView class]])
        tableView = self.modeledTableView.superview;
    else
        tableView = self.modeledTableView;
	
    NSTimeInterval animationDuration;
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	UIViewAnimationCurve animationCurve;
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	
	// Determine how much overlap exists between modeledTableView and the keyboard
    CGRect tableFrame = tableView.frame;
    UIView *superView;
#ifdef __IPHONE_4_0
    superView = keyWindow.rootViewController.view;
#else
    superView = [keyWindow.subviews objectAtIndex:0];
#endif
    CGPoint convertedTableOrigin = [tableView.superview convertPoint:tableFrame.origin toView:superView];
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
		tableView.frame = tableFrame;
		[UIView commitAnimations];
#else
		[UIView animateWithDuration:animationDuration delay:delay 
							options:UIViewAnimationOptionBeginFromCurrentState 
						 animations:^{ tableView.frame = tableFrame; } 
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
		tableView.frame = tableFrame;
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
    
    UIView *tableView;
    if([self.modeledTableView.superview isKindOfClass:[UIScrollView class]])
        tableView = self.modeledTableView.superview;
    else
        tableView = self.modeledTableView;
	
    NSTimeInterval animationDuration;
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	
	CGRect tableFrame = tableView.frame; 
	tableFrame.size.height += keyboardOverlap;
	
	if(keyboardHeight)
		animationDuration = animationDuration * keyboardOverlap/keyboardHeight;
	
#ifdef __IPHONE_4_0
#ifdef DEPLOYMENT_OS_PRIOR_TO_3_2
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:animationDuration];
	tableView.frame = tableFrame;
	[UIView commitAnimations];
#else
	[UIView animateWithDuration:animationDuration delay:0 
						options:UIViewAnimationOptionBeginFromCurrentState 
					 animations:^{ tableView.frame = tableFrame; } 
					 completion:nil];
#endif
#else
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    tableView.frame = tableFrame;
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
	if( (self=[self initWithTableView:_modeledTableView withViewController:_viewController]) )
	{
		self.items = _items;  // setter will generate sections
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[tempSection release];
	[items release];
	[addButtonItem release];
	[filteredArray release];
	[searchBar release];
	
	[super dealloc];
}
#endif

//override superclass
- (void)reloadBoundValues
{
	if(filteredArray)
    {
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    }
    else
    {
        [self generateSections];
    }
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
	
    if(!sectionHeader)
        return 0;
	
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
	SC_Release(searchBar);
	searchBar = SC_Retain(sbar);
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
	SC_Release(items);
	items = SC_Retain(array);
	
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
	SC_Release(addButtonItem);
	addButtonItem = SC_Retain(barButtonItem);
	
	addButtonItem.target = self;
	addButtonItem.action = @selector(didTapAddButtonItem);
}

- (void)didTapAddButtonItem
{
    if(self.allowAddingItems)
        [self dispatchAddNewItemEvent];
}

- (void)dispatchAddNewItemEvent
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
			tempSection = SC_Retain([self createSectionWithHeaderTitle:nil]);
			tempSection.ownerTableViewModel = self;
			[self setPropertiesForSection:tempSection];
		}
		section = tempSection;
	}
	
	[section dispatchAddNewItemEvent];
}

- (void)dispatchSelectRowAtIndexPathEvent:(NSIndexPath *)indexPath
{
    [(SCArrayOfItemsSection *)[self sectionAtIndex:indexPath.section] dispatchSelectRowAtIndexPathEvent:indexPath];
}

- (void)dispatchRemoveRowAtIndexPathEvent:(NSIndexPath *)indexPath
{
    [(SCArrayOfItemsSection *)[self sectionAtIndex:indexPath.section] dispatchRemoveRowAtIndexPathEvent:indexPath];
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
        section.selectedCellIndexPath = nil;
		if(section.items.count)
		{
			[self.modeledTableView 
			 deleteRowsAtIndexPaths:[NSArray arrayWithObject:oldIndexPath] 
			 withRowAnimation:UITableViewRowAnimationRight];
		}
		else
		{
#ifndef ARC_ENABLED
            // Retain and autorelease section since this method was originally called by it.
            // This gives the calling method a chance to exit.
            [[section retain] autorelease];
#endif
			[self removeSectionAtIndex:oldSectionIndex];
            section.ownerTableViewModel = nil;
            
			[self.modeledTableView deleteSections:[NSIndexSet indexSetWithIndex:oldSectionIndex]
								 withRowAnimation:UITableViewRowAnimationRight];
		}
		
		SC_Retain(item);
		[self.items removeObjectIdenticalTo:item];
		// add the item from scratch
		[self addNewItem:item];
		SC_Release(item);
	}
}

// Overrides superclass
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	forRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCArrayOfItemsSection *section = (SCArrayOfItemsSection *)[self sectionAtIndex:indexPath.section];
    NSObject *item = [section.items objectAtIndex:indexPath.row];
    
    // remove the item from the items array
    [self.items removeObjectIdenticalTo:item];
    
    // Have the respective section remove the item
	[super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
	
	// Remove the section if empty
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

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if(self.lockCellSelection)
        return FALSE;
    
    BOOL shouldBegin = TRUE;
    
    if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModelSearchBarShouldBeginEditing:)])
	{
		shouldBegin = [self.delegate tableViewModelSearchBarShouldBeginEditing:self];
	}
    
    if(shouldBegin)
        [SCModelCenter sharedModelCenter].keyboardIssuer = self.viewController;
        
    return shouldBegin;
}

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
	
	SC_Release(filteredArray);
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
		
	SC_Release(filteredArray);
	filteredArray = SC_Retain(resultsArray);
	
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
	return SC_Autorelease([[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
										  withItems:_items 
								withClassDefinition:classDefinition]);
}

+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
					 withItemsSet:(NSMutableSet *)_itemsSet
			  withClassDefinition:(SCClassDefinition *)classDefinition
{
	return SC_Autorelease([[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
									   withItemsSet:_itemsSet 
								withClassDefinition:classDefinition]);
}

#ifdef _COREDATADEFINES_H
+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
		withEntityClassDefinition:(SCClassDefinition *)classDefinition
{
	return SC_Autorelease([[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
						  withEntityClassDefinition:classDefinition]);
}

+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
		withEntityClassDefinition:(SCClassDefinition *)classDefinition
				   usingPredicate:(NSPredicate *)predicate
{
	return SC_Autorelease([[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
						  withEntityClassDefinition:classDefinition
									 usingPredicate:predicate]);
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
	if( (self=[self initWithTableView:_modeledTableView withViewController:_viewController]) )
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
	if( (self=[self initWithTableView:_modeledTableView withViewController:_viewController]) )
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
																		   usingPredicate:self.itemsPredicate ascending:YES];
	
	self = [self initWithTableView:_modeledTableView withViewController:_viewController
                         withItems:sectionItems
               withClassDefinition:classDefinition];
    [self callCoreDataObjectsLoadedDelegate];
    
    return self;
}
#endif

#ifndef ARC_ENABLED
- (void)dealloc
{
	[itemsPredicate release];
	[itemsClassDefinitions release];
	[itemsSet release];
	[searchPropertyName release];
		
	[super dealloc];
}
#endif

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
        self.items = [SCHelper generateObjectsArrayForEntityClassDefinition:classDef usingPredicate:self.itemsPredicate ascending:self.sortItemsSetAscending];
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
	SC_Release(itemsSet);
	itemsSet = SC_Retain(set);
	
	[self generateItemsArrayFromItemsSet];
}

-(void)setSortItemsSetAscending:(BOOL)ascending
{
	sortItemsSetAscending = ascending;
    if(self.itemsSet)
        [self generateItemsArrayFromItemsSet];
    else
        [self reloadBoundValues];
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
	SC_Release(descriptor);
	
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
	
	SC_Release(filteredArray);
	filteredArray = SC_Retain(resultsArray);
	
	[self generateSections];
	[self.modeledTableView reloadData];
}

@end













@interface SCSelectionModel ()

- (NSInteger)itemIndexForCell:(SCTableViewCell *)cell;
- (NSInteger)itemIndexForCellAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItemIndex:(NSInteger)itemIndex;
- (void)buildSelectedItemsIndexesFromString:(NSString *)string;
- (NSString *)buildStringFromSelectedItemsIndexes;

- (void)deselectLastSelectedRow;
- (void)dismissViewController;

@end



@implementation SCSelectionModel

@synthesize boundObject;
@synthesize boundPropertyName;
@synthesize boundKey;
@synthesize allowMultipleSelection;
@synthesize allowNoSelection;
@synthesize maximumSelections;
@synthesize autoDismissViewController;


- (id)init
{
	if( (self=[super init]) )
	{
        boundObject = nil;
		boundPropertyName = nil;
		boundKey = nil;
        
		boundToNSNumber = FALSE;
		boundToNSString = FALSE;
		lastSelectedRowIndexPath = nil;
		allowAddingItems = FALSE;
		allowDeletingItems = FALSE;
		allowMovingItems = FALSE;
		allowEditDetailView = FALSE;
		
		allowMultipleSelection = FALSE;
		allowNoSelection = FALSE;
		maximumSelections = 0;
		autoDismissViewController = FALSE;
		_selectedItemsIndexes = [[NSMutableSet alloc] init];
	}
	
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
     withViewController:(UIViewController *)_viewController
        withBoundObject:(NSObject *)object 
withSelectedIndexPropertyName:(NSString *)propertyName 
              withItems:(NSArray *)sectionItems
{
	if([self initWithTableView:_modeledTableView withViewController:_viewController withItems:[NSMutableArray arrayWithArray:sectionItems]])
	{
		boundObject = SC_Retain(object);
		
		// Only bind property name if property exists
		BOOL propertyExists;
		@try { [SCHelper valueForPropertyName:propertyName inObject:self.boundObject]; propertyExists = TRUE; }
        @catch (NSException *exception) { propertyExists = FALSE; }
		if(propertyExists)
			boundPropertyName = [propertyName copy];
		
		boundToNSNumber = TRUE;
		allowMultipleSelection = FALSE;
		
		[self reloadBoundValues];
	}
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
     withViewController:(UIViewController *)_viewController
        withBoundObject:(NSObject *)object 
withSelectedIndexesPropertyName:(NSString *)propertyName 
              withItems:(NSArray *)sectionItems 
 allowMultipleSelection:(BOOL)multipleSelection
{
	if([self initWithTableView:_modeledTableView withViewController:_viewController withItems:[NSMutableArray arrayWithArray:sectionItems]])
	{
		boundObject = SC_Retain(object);
		
		// Only bind property name if property exists
		BOOL propertyExists;
		@try { [SCHelper valueForPropertyName:propertyName inObject:self.boundObject]; propertyExists = TRUE; }
		@catch (NSException *exception) { propertyExists = FALSE; }
		if(propertyExists)
			boundPropertyName = [propertyName copy];
		
		allowMultipleSelection = multipleSelection;
		
		[self reloadBoundValues];
	}
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
     withViewController:(UIViewController *)_viewController
        withBoundObject:(NSObject *)object 
withSelectionStringPropertyName:(NSString *)propertyName 
              withItems:(NSArray *)sectionItems
{
	if([self initWithTableView:_modeledTableView withViewController:_viewController withItems:[NSMutableArray arrayWithArray:sectionItems]])
	{
		boundObject = SC_Retain(object);
		
		// Only bind property name if property exists
		BOOL propertyExists;
		@try { [SCHelper valueForPropertyName:propertyName inObject:self.boundObject]; propertyExists = TRUE; }
		@catch (NSException *exception) { propertyExists = FALSE; }
		if(propertyExists)
			boundPropertyName = [propertyName copy];
		
		boundToNSString = TRUE;
		
		[self reloadBoundValues];
	}
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
     withViewController:(UIViewController *)_viewController
           withBoundKey:(NSString *)key 
 withSelectedIndexValue:(NSNumber *)selectedIndexValue 
              withItems:(NSArray *)sectionItems
{
	if( (self=[self initWithTableView:_modeledTableView withViewController:_viewController withItems:[NSMutableArray arrayWithArray:sectionItems]]) )
	{
		boundKey = [key copy];
		self.boundValue = selectedIndexValue;
		boundToNSNumber = TRUE;
		allowMultipleSelection = FALSE;
		
		[self reloadBoundValues];
	}
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
     withViewController:(UIViewController *)_viewController
           withBoundKey:(NSString *)key 
withSelectedIndexesValue:(NSMutableSet *)selectedIndexesValue 
              withItems:(NSArray *)sectionItems 
 allowMultipleSelection:(BOOL)multipleSelection
{
	if( (self=[self initWithTableView:_modeledTableView withViewController:_viewController withItems:[NSMutableArray arrayWithArray:sectionItems]]) )
	{
		boundKey = [key copy];
		self.boundValue = selectedIndexesValue;
		allowMultipleSelection = multipleSelection;
		
		[self reloadBoundValues];
	}
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
     withViewController:(UIViewController *)_viewController
           withBoundKey:(NSString *)key 
withSelectionStringValue:(NSString *)selectionStringValue 
              withItems:(NSArray *)sectionItems
{
	if( (self=[self initWithTableView:_modeledTableView withViewController:_viewController withItems:[NSMutableArray arrayWithArray:sectionItems]]) )
	{
		boundKey = [key copy];
		self.boundValue = selectionStringValue;
		
		boundToNSString = TRUE;
		
		[self reloadBoundValues];
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
    [boundObject release];
	[boundPropertyName release];
	[boundKey release];
	[_selectedItemsIndexes release];
	[lastSelectedRowIndexPath release];
	[super dealloc];
}
#endif

- (void)setBoundValue:(id)value
{
	if(self.boundObject && self.boundPropertyName)
	{
		[self.boundObject setValue:value forKey:self.boundPropertyName];
	}
	else
		if(self.boundKey)
		{
			[self.modelKeyValues setValue:value forKey:self.boundKey];
		}
}

- (NSObject *)boundValue
{
	if(self.boundObject && self.boundPropertyName)
	{
		return [SCHelper valueForPropertyName:self.boundPropertyName inObject:self.boundObject];
	}
	//else
	if(self.boundKey)
	{
		NSObject *val = [self.modelKeyValues valueForKey:self.boundKey];
        return val;
	}
	//else
	return nil;
}

- (NSInteger)itemIndexForCell:(SCTableViewCell *)cell
{
    return [self.items indexOfObject:cell.textLabel.text];
}

- (NSInteger)itemIndexForCellAtIndexPath:(NSIndexPath *)indexPath
{
    SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
    return [self itemIndexForCell:cell];
}

- (NSIndexPath *)indexPathForItemIndex:(NSInteger)itemIndex
{
    for(NSInteger i=0; i<self.sectionCount; i++)
    {
        SCTableViewSection *section = [self sectionAtIndex:i];
        for(NSInteger j=0; j<section.cellCount; j++)
        {
            SCTableViewCell *cell = [section cellAtIndex:j];
            if([self.items indexOfObject:cell.textLabel.text] == itemIndex)
                return [NSIndexPath indexPathForRow:j inSection:i];
        }
    }
    return nil;
}

- (void)buildSelectedItemsIndexesFromString:(NSString *)string
{
	NSArray *selectionStrings = [string componentsSeparatedByString:@";"];
	
	[self.selectedItemsIndexes removeAllObjects];
	for(NSString *selectionString in selectionStrings)
	{
		int index = [self.items indexOfObject:selectionString];
		if(index != NSNotFound)
			[self.selectedItemsIndexes addObject:[NSNumber numberWithInt:index]];
	}
}

- (NSString *)buildStringFromSelectedItemsIndexes
{
	NSMutableArray *selectionStrings = [NSMutableArray arrayWithCapacity:[self.selectedItemsIndexes count]];
	for(NSNumber *index in self.selectedItemsIndexes)
	{
		[selectionStrings addObject:[self.items objectAtIndex:[index intValue]]];
	}
	
	return [selectionStrings componentsJoinedByString:@";"];
}

// override superclass
- (void)setItems:(NSMutableArray *)_items
{
    [super setItems:_items];
    
    [self reloadBoundValues];
}

// override superclass
- (void)reloadBoundValues
{
    [super reloadBoundValues];
    
    if(boundToNSNumber)
    {
        if(self.boundValue)
			[self.selectedItemsIndexes addObject:self.boundValue];
		
		if((self.boundObject || self.boundKey) && !self.boundValue)
			self.boundValue = [NSNumber numberWithInt:-1];
    }
    else
        if(boundToNSString)
        {
            if([self.boundValue isKindOfClass:[NSString class]] && self.items)
            {
                [self buildSelectedItemsIndexesFromString:(NSString *)self.boundValue];
            }
        }
        else
        {
            if((self.boundObject || self.boundKey) && !self.boundValue)
                self.boundValue = [NSMutableSet set];   //Empty set
        }
}

// override superclass method
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([self.selectedItemsIndexes containsObject:[NSNumber numberWithInt:[self itemIndexForCellAtIndexPath:indexPath]]])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textLabel.textColor = [UIColor colorWithRed:50.0f/255 green:79.0f/255 blue:133.0f/255 alpha:1];
	}
	else
	{
        cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textColor = [UIColor blackColor];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void)deselectLastSelectedRow
{
	[self.modeledTableView deselectRowAtIndexPath:lastSelectedRowIndexPath animated:YES];
}

// override superclass method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    NSNumber *itemIndex = [NSNumber numberWithInt:[self itemIndexForCellAtIndexPath:indexPath]];
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	
	SC_Release(lastSelectedRowIndexPath);
	lastSelectedRowIndexPath = SC_Retain(indexPath);
	
	if([self.selectedItemsIndexes containsObject:itemIndex])
	{
		if(!self.allowNoSelection && self.selectedItemsIndexes.count==1)
		{
			[self performSelector:@selector(deselectLastSelectedRow) withObject:nil afterDelay:0.05];
			
			if(self.autoDismissViewController)
				[self performSelector:@selector(dismissViewController) withObject:nil afterDelay:0.4];
			return;
		}
		
		//uncheck cell and exit method
		[self.selectedItemsIndexes removeObject:itemIndex];
		if(boundToNSNumber)
			self.boundValue = self.selectedItemIndex;
		else
			if(boundToNSString)
				self.boundValue = [self buildStringFromSelectedItemsIndexes];
		selectedCell.accessoryType = UITableViewCellAccessoryNone;
		selectedCell.textLabel.textColor = [UIColor blackColor];
		[self valueChangedForSectionAtIndex:indexPath.section];
		[self performSelector:@selector(deselectLastSelectedRow) withObject:nil afterDelay:0.05];
		return;
	}
	
	// Make sure not to exceed maximumSelections
	if(self.allowMultipleSelection && self.maximumSelections!=0 && self.selectedItemsIndexes.count==self.maximumSelections)
	{
		[self performSelector:@selector(deselectLastSelectedRow) withObject:nil afterDelay:0.05];
		
		if(self.autoDismissViewController)
			[self performSelector:@selector(dismissViewController) withObject:nil afterDelay:0.4];
		return;
	}
	
	if(!self.allowMultipleSelection && self.selectedItemsIndexes.count)
	{
		NSIndexPath *oldIndexPath = [self indexPathForItemIndex:[(NSNumber *)[self.selectedItemsIndexes anyObject] intValue]];
        [self.selectedItemsIndexes removeAllObjects];
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
		oldCell.textLabel.textColor = [UIColor blackColor];
	}
	
	//check selected cell
	[self.selectedItemsIndexes addObject:itemIndex];
	if(boundToNSNumber)
		self.boundValue = self.selectedItemIndex;
	else
		if(boundToNSString)
			self.boundValue = [self buildStringFromSelectedItemsIndexes];
	selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
	selectedCell.textLabel.textColor = [UIColor colorWithRed:50.0f/255 green:79.0f/255 blue:133.0f/255 alpha:1];
	
	[self valueChangedForSectionAtIndex:indexPath.section];
	
	[self performSelector:@selector(deselectLastSelectedRow) withObject:nil afterDelay:0.1];
	
	if(self.autoDismissViewController)
	{
		if(!self.allowMultipleSelection || self.maximumSelections==0 
		   || self.maximumSelections==self.selectedItemsIndexes.count || self.items.count==self.selectedItemsIndexes.count)
			[self performSelector:@selector(dismissViewController) withObject:nil afterDelay:0.4];
	}
    
}

- (void)dismissViewController
{
	if([self.viewController isKindOfClass:[SCTableViewController class]])
	{
		[(SCTableViewController *)self.viewController 
		 dismissWithCancelValue:FALSE doneValue:TRUE];
	}
}

- (NSMutableSet *)selectedItemsIndexes
{
	if( (self.boundObject || self.boundKey) && !(boundToNSNumber || boundToNSString))
		return (NSMutableSet *)self.boundValue;
	//else
	return _selectedItemsIndexes;
}

- (void)setSelectedItemIndex:(NSNumber *)number
{
	NSNumber *num = [number copy];
	
	if(boundToNSNumber)
		self.boundValue = num;
	
	[self.selectedItemsIndexes removeAllObjects];
	if([number intValue] >= 0)
		[self.selectedItemsIndexes addObject:num];
	
	SC_Release(num);
}

- (NSNumber *)selectedItemIndex
{
	NSNumber *index = [self.selectedItemsIndexes anyObject];
	
	if(index)
		return index;
	//else
	return [NSNumber numberWithInt:-1];
}

@end



