/*
 *  SCTableViewSection.m
 *  Sensible TableView
 *  Version: 2.1.7
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

#import "SCTableViewSection.h"
#import "SCTableViewModel.h"
#import "SCGlobals.h"
#import <objc/runtime.h>




@implementation SCTableViewSection

@synthesize ownerTableViewModel;
@synthesize boundObject;
@synthesize boundPropertyName;
@synthesize boundKey;
@synthesize commitCellChangesLive;
@synthesize headerTitle;
@synthesize headerHeight;
@synthesize headerView;
@synthesize footerTitle;
@synthesize footerHeight;
@synthesize footerView;
@synthesize cellsImageViews;

+ (id)section
{
	return SC_Autorelease([[[self class] alloc] init]);
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle]);
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle 
			 withFooterTitle:(NSString *)sectionFooterTitle
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
									  withFooterTitle:sectionFooterTitle]);
}

- (id)init
{
	if( (self=[super init]) )
	{
		ownerTableViewModel = nil;
		boundObject = nil;
		boundPropertyName = nil;
		boundKey = nil;
		initialValue = nil;
		commitCellChangesLive = TRUE;
		coreDataBound = FALSE;
		headerTitle = nil;
		headerHeight = 0;	// This will set the default header height
		headerView = nil;
		footerTitle = nil;
		footerHeight = 0;	// This will set the default footer height
		footerView = nil;
		cellsImageViews = nil;
		
		cells = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
{
	if( (self=[self init]) )
	{
		self.headerTitle = sectionHeaderTitle;
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle 
		  withFooterTitle:(NSString *)sectionFooterTitle
{
	if( (self=[self init]) )
	{
		self.headerTitle = sectionHeaderTitle;
		self.footerTitle = sectionFooterTitle;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[boundObject release];
	[boundPropertyName release];
	[boundKey release];
	[initialValue release];
	[headerTitle release];
	[headerView release];
	[footerTitle release];
	[footerView release];
	[cellsImageViews release];
	[cells release];
	[super dealloc];
}
#endif

- (NSComparisonResult)compare:(SCTableViewSection *)section
{
	if(!self.headerTitle)
		return NSOrderedAscending;
	
	if(!section.headerTitle)
		return NSOrderedDescending;
	
	return [self.headerTitle compare:section.headerTitle];
}

- (void)setBoundValue:(id)value
{
	if(self.boundObject && self.boundPropertyName)
	{
		[self.boundObject setValue:value forKey:self.boundPropertyName];
	}
	else
		if(self.boundKey)
		{
			if(self.ownerTableViewModel)
			{
				[self.ownerTableViewModel.modelKeyValues setValue:value forKey:self.boundKey];
			}
			else
			{
				SC_Release(initialValue);
				initialValue = SC_Retain(value);
			}
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
		if(self.ownerTableViewModel)
		{
			NSObject *val = [self.ownerTableViewModel.modelKeyValues valueForKey:self.boundKey];
			if(!val && initialValue)
			{
				// set cellValue to initialValue
				[self.ownerTableViewModel.modelKeyValues setValue:initialValue forKey:self.boundKey];
				val = initialValue;
				SC_Release(initialValue);
				initialValue = nil;
			}
			return val;
		}
		//else
		return initialValue;
	}
	//else
	return nil;
}

- (void)setAttributesTo:(SCPropertyAttributes *)attributes
{
    // Does nothing, should be overridden by subclasses
}

- (void)setCommitCellChangesLive:(BOOL)commit
{
	commitCellChangesLive = commit;
	
	for(SCTableViewCell *cell in cells)
		cell.commitChangesLive = commit;
}

- (NSUInteger)cellCount
{
	return cells.count;
}

- (void)addCell:(SCTableViewCell *)cell
{
	cell.ownerTableViewModel = self.ownerTableViewModel;
	cell.commitChangesLive = self.commitCellChangesLive;
	[cells addObject:cell];
}

- (void)insertCell:(SCTableViewCell *)cell atIndex:(NSUInteger)index
{
	cell.ownerTableViewModel = self.ownerTableViewModel;
	cell.commitChangesLive = self.commitCellChangesLive;
	[cells insertObject:cell atIndex:index];
}

- (SCTableViewCell *)cellAtIndex:(NSUInteger)index
{
	if(index < self.cellCount)
		return [cells objectAtIndex:index];
	//else
	return nil;
}

- (void)removeCellAtIndex:(NSUInteger)index
{
	// Check if the cell to be removed is the current active cell
	SCTableViewCell *cell = [cells objectAtIndex:index];
    [cell resignFirstResponder];
    if (self.ownerTableViewModel.activeCell == cell)
	{
        self.ownerTableViewModel.activeCell = nil;
    }
	
	[cells removeObjectAtIndex:index];
}

- (void)removeAllCells
{
    [cells removeAllObjects];
}

- (NSUInteger)indexForCell:(SCTableViewCell *)cell
{
	return [cells indexOfObjectIdenticalTo:cell];
}

- (BOOL)valuesAreValid
{
	for(SCTableViewCell *cell in cells)
		if(!cell.valueIsValid)
			return FALSE;
	
	return TRUE;
}

- (void)commitCellChanges
{
	for(SCTableViewCell *cell in cells)
		[cell commitChanges];
}

- (void)reloadBoundValues
{
	for(SCTableViewCell *cell in cells)
		[cell reloadBoundValue];
}

- (void)editingModeWillChange
{
    // Do nothing. Should be overridden by subclasses.
}

- (void)editingModeDidChange
{
    // Do nothing. Should be overridden by subclasses.
}

@end





@interface SCObjectSection ()

- (SCTableViewCell *)getCellForPropertyWithDefinition:(SCPropertyDefinition *)propertyDefinition
									  withBoundObject:(NSObject *)_boundObject 
                                        inEditingMode:(BOOL)editing;

- (void)setEditableStateForCell:(SCTableViewCell *)cell withPropertyDefinition:(SCPropertyDefinition *)propertyDefinition inEditingMode:(BOOL)editing;

@end


@implementation SCObjectSection

@synthesize boundObjectClassDefinition;
@synthesize propertyGroup;

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
									  withBoundObject:object]);
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object
		 withClassDefinition:(SCClassDefinition *)classDefinition
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
									  withBoundObject:object
								  withClassDefinition:classDefinition]);
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object
		 withClassDefinition:(SCClassDefinition *)classDefinition
          usingPropertyGroup:(SCPropertyGroup *)group
{
    return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
									  withBoundObject:object
								  withClassDefinition:classDefinition
                                   usingPropertyGroup:group]);
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object
{
	return [self initWithHeaderTitle:sectionHeaderTitle withBoundObject:object 
				 withClassDefinition:nil];
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object
	  withClassDefinition:(SCClassDefinition *)classDefinition
{
    SCPropertyGroup *group = nil;
    
    if(!classDefinition && !coreDataBound)
        classDefinition = [SCClassDefinition definitionWithClass:[object class] autoGeneratePropertyDefinitions:YES];
    
    if(classDefinition)
    {
        [classDefinition generateDefaultPropertyGroupProperties];
        group = classDefinition.defaultPropertyGroup;
    }
    
    return [self initWithHeaderTitle:sectionHeaderTitle withBoundObject:object withClassDefinition:classDefinition usingPropertyGroup:group];
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object
	  withClassDefinition:(SCClassDefinition *)classDefinition
       usingPropertyGroup:(SCPropertyGroup *)group
{
	self = [self initWithHeaderTitle:sectionHeaderTitle];
	
	if(!object)
		return self;
	
	boundObject = SC_Retain(object);
    self.propertyGroup = group;
    
    if(self.propertyGroup)
    {
        if(!sectionHeaderTitle)
            self.headerTitle = propertyGroup.headerTitle;
        self.footerTitle = propertyGroup.footerTitle;
    }
	
#ifdef _COREDATADEFINES_H	
	if([boundObject isKindOfClass:[NSManagedObject class]])
		coreDataBound = TRUE;
#endif	

	if(!classDefinition)
	{
#ifdef _COREDATADEFINES_H	
		if([self.boundObject isKindOfClass:[NSManagedObject class]])
		{
			NSManagedObject *managedObj = (NSManagedObject *)self.boundObject;
			classDefinition = [SCClassDefinition definitionWithEntityName:[[managedObj entity] name]
												 withManagedObjectContext:[managedObj managedObjectContext]
										  autoGeneratePropertyDefinitions:YES];
		}
		else
		{
#endif			
			classDefinition = [SCClassDefinition definitionWithClass:[object class] 
									 autoGeneratePropertyDefinitions:YES];
#ifdef _COREDATADEFINES_H				
		}
#endif							   
	}
    
	self.boundObjectClassDefinition = classDefinition;
    
	[self generateCellsForEditingState:self.ownerTableViewModel.modeledTableView.editing];
	
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[boundObjectClassDefinition release];
	
	[super dealloc];
}
#endif

//overrides superclass
- (void)setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCObjectAttributes class]])
		return;
	
	SCObjectAttributes *objectAttributes = (SCObjectAttributes *)attributes;
	SCClassDefinition *objectClassDef = 
	[objectAttributes.classDefinitions valueForKey:[NSString stringWithFormat:@"%s",
                                                    class_getName([self.boundObject class])]];
	if(objectClassDef)
		self.boundObjectClassDefinition = objectClassDef;
}

// Override super class method
- (void)editingModeWillChange
{
    [super editingModeWillChange];
    
    BOOL oldEditing = self.ownerTableViewModel.modeledTableView.editing;
    BOOL newEditing = !oldEditing;
    NSInteger sectionIndex = [self.ownerTableViewModel indexForSection:self];
    NSInteger oldCellCursor = 0;
    for(NSInteger i=0; i<self.propertyGroup.propertyNameCount; i++)
	{
        SCPropertyDefinition *propertyDefinition = [self.boundObjectClassDefinition propertyDefinitionWithName:[self.propertyGroup propertyNameAtIndex:i]];
        
        SCTableViewCell *oldCell = [self getCellForPropertyWithDefinition:propertyDefinition withBoundObject:self.boundObject inEditingMode:oldEditing];
        SCTableViewCell *newCell = [self getCellForPropertyWithDefinition:propertyDefinition withBoundObject:self.boundObject inEditingMode:newEditing];
        newCell.tag = i;
            
        if(!oldCell && !newCell)
            continue;
        
        if(!oldCell)
        {
            // Insert new cell
            [self insertCell:newCell atIndex:oldCellCursor];
            [self.ownerTableViewModel.modeledTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:oldCellCursor inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
            
            oldCellCursor++;
            continue;
        }
        
        NSIndexPath *oldCellIndexPath = [self.ownerTableViewModel.modeledTableView indexPathForCell:[self cellAtIndex:oldCellCursor]];
        
        if(!newCell)
        {
            // Remove old cell
            [self removeCellAtIndex:oldCellCursor];
            [self.ownerTableViewModel.modeledTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:oldCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            continue;
        }
        
        // Both oldCell and newCell exist
        if(![oldCell isKindOfClass:[newCell class]] || propertyDefinition.editingModeAttributes)
        {
            //Replace old cell with new cell
            [self removeCellAtIndex:oldCellCursor];
            [self insertCell:newCell atIndex:oldCellCursor];
            [self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:oldCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else
        {
            [self setEditableStateForCell:[self cellAtIndex:oldCellCursor] withPropertyDefinition:propertyDefinition inEditingMode:newEditing];
        }
        
        oldCellCursor++;
    }
}

- (void)generateCellsForEditingState:(BOOL)editing
{
    [self removeAllCells];
    
    // Generate cells based on the classDefinition's propertyGroup
	for(NSInteger i=0; i<self.propertyGroup.propertyNameCount; i++)
	{
		SCPropertyDefinition *propertyDefinition = [self.boundObjectClassDefinition propertyDefinitionWithName:[self.propertyGroup propertyNameAtIndex:i]];
		SCTableViewCell *cell = [self getCellForPropertyWithDefinition:propertyDefinition
													   withBoundObject:self.boundObject inEditingMode:editing];
		if(cell)
		{
			cell.tag = i;
			[self addCell:cell];
		}
	}
}

- (void)setEditableStateForCell:(SCTableViewCell *)cell withPropertyDefinition:(SCPropertyDefinition *)propertyDefinition inEditingMode:(BOOL)editing
{
    BOOL editable = TRUE;
    if(propertyDefinition.ownerClassDefinition.requireEditingModeToEditPropertyValues && !editing)
        editable = FALSE;
    
    cell.enabled = editable;
}

- (SCTableViewCell *)getCellForPropertyWithDefinition:(SCPropertyDefinition *)propertyDefinition
									  withBoundObject:(NSObject *)_boundObject
                                        inEditingMode:(BOOL)editing
{
	if(!editing && !propertyDefinition.existsInNormalMode)
        return nil;
    
    if(editing && !propertyDefinition.existsInEditingMode)
        return nil;
    
    SCTableViewCell *cell = nil;
	
	if([propertyDefinition isKindOfClass:[SCCustomPropertyDefinition class]])
	{
		SCCustomPropertyDefinition *customPropertyDef = (SCCustomPropertyDefinition *)propertyDefinition;
        
        NSObject *uiElement;
        if(customPropertyDef.uiElementNibName)
        {
            uiElement = [SCHelper getFirstNodeInNibWithName:customPropertyDef.uiElementNibName];
        }
        else 
        {
            uiElement = SC_Autorelease([[customPropertyDef.uiElementClass alloc] init]);
        }
        SCControlCell *controlCell = nil;        
        if([uiElement isKindOfClass:[SCControlCell class]])
            controlCell = (SCControlCell *)uiElement;
                 
		if(controlCell)
		{
            [controlCell setBoundObject:_boundObject];
			[controlCell.objectBindings addEntriesFromDictionary:customPropertyDef.objectBindings];
			[controlCell configureCustomControls];
			controlCell.textLabel.text = customPropertyDef.title;
			if(controlCell.frame.size.height)
				controlCell.height = controlCell.frame.size.height;
			
			cell = controlCell;
		}
	}
	else
	{
		SCPropertyDataType propertyDataType = propertyDefinition.dataType;
		BOOL readOnlyProperty = propertyDefinition.dataReadOnly;
		NSString *propertyName = propertyDefinition.name;
		NSString *propertyTitle = propertyDefinition.title;
		SCPropertyType propertyType = propertyDefinition.type;
        if(editing && propertyDefinition.editingModeType!=SCPropertyTypeUndefined)
        {
            propertyType = propertyDefinition.editingModeType;
        }
		
		if(propertyType == SCPropertyTypeAutoDetect)
		{
			// Auto detect property type
			if(propertyDataType == SCPropertyDataTypeNSString)
			{
				if(readOnlyProperty)
					propertyType = SCPropertyTypeLabel;
				else
					propertyType = SCPropertyTypeTextField;
			}
			else
				if(propertyDataType == SCPropertyDataTypeNSNumber)
				{
					if(readOnlyProperty)
						propertyType = SCPropertyTypeLabel;
					else
						propertyType = SCPropertyTypeNumericTextField;
				}
				else
					if(propertyDataType == SCPropertyDataTypeNSDate)
					{
						if(readOnlyProperty)
							propertyType = SCPropertyTypeLabel;
						else
							propertyType = SCPropertyTypeDate;
					}
					else
					{
						// Can't auto detect
						return nil;
					}
		}
		
		switch (propertyType)
		{
			case SCPropertyTypeLabel:
				if(propertyDataType==SCPropertyDataTypeNSString || propertyDataType==SCPropertyDataTypeNSNumber
				   || propertyDataType==SCPropertyDataTypeDictionaryItem
				   || propertyDataType==SCPropertyDataTypeTransformable)
				{
					cell = [SCLabelCell cellWithText:propertyTitle 
									 withBoundObject:_boundObject withLabelTextPropertyName:propertyName];
				}
				break;
			case SCPropertyTypeTextView:
				if(propertyDataType==SCPropertyDataTypeNSString || propertyDataType==SCPropertyDataTypeDictionaryItem
				   || propertyDataType==SCPropertyDataTypeTransformable)
				{
					cell = [SCTextViewCell cellWithText:propertyTitle
										withBoundObject:_boundObject withTextViewTextPropertyName:propertyName];
					if(readOnlyProperty)
					{
						// Override attributes (if exist)
						if([propertyDefinition.attributes isKindOfClass:[SCTextViewAttributes class]])
						{
							((SCTextViewAttributes *)propertyDefinition.attributes).editable = FALSE;
						}
						else
							((SCTextViewCell *)cell).textView.editable = FALSE;
					}
				}
				break;
			case SCPropertyTypeTextField:
				if(!readOnlyProperty && 
				   (propertyDataType==SCPropertyDataTypeNSString || propertyDataType==SCPropertyDataTypeDictionaryItem
					|| propertyDataType==SCPropertyDataTypeTransformable))
				{
					cell = [SCTextFieldCell cellWithText:propertyTitle withPlaceholder:nil
										 withBoundObject:_boundObject withTextFieldTextPropertyName:propertyName];
				}
				break;
			case SCPropertyTypeNumericTextField:
				if(!readOnlyProperty && 
				   (propertyDataType==SCPropertyDataTypeNSNumber || propertyDataType==SCPropertyDataTypeDictionaryItem
					|| propertyDataType==SCPropertyDataTypeTransformable))
				{
					cell = [SCNumericTextFieldCell cellWithText:propertyTitle withPlaceholder:nil
												withBoundObject:_boundObject withTextFieldTextPropertyName:propertyName];
				}
				break;
			case SCPropertyTypeSlider:
				if(!readOnlyProperty && 
				   (propertyDataType==SCPropertyDataTypeNSNumber || propertyDataType==SCPropertyDataTypeDictionaryItem
					|| propertyDataType==SCPropertyDataTypeTransformable))
				{
					cell = [SCSliderCell cellWithText:propertyTitle
									  withBoundObject:_boundObject withSliderValuePropertyName:propertyName];
				}
				break;
			case SCPropertyTypeSegmented:
				if(!readOnlyProperty && 
				   (propertyDataType==SCPropertyDataTypeNSNumber || propertyDataType==SCPropertyDataTypeDictionaryItem
					|| propertyDataType==SCPropertyDataTypeTransformable))
				{
					cell = [SCSegmentedCell cellWithText:propertyTitle 
										 withBoundObject:_boundObject 
					withSelectedSegmentIndexPropertyName:propertyName
								  withSegmentTitlesArray:nil];
				}
				break;
			case SCPropertyTypeSwitch:
				if(!readOnlyProperty && 
				   (propertyDataType==SCPropertyDataTypeNSNumber || propertyDataType==SCPropertyDataTypeDictionaryItem
					|| propertyDataType==SCPropertyDataTypeTransformable))
				{
					cell = [SCSwitchCell cellWithText:propertyTitle 
									  withBoundObject:_boundObject withSwitchOnPropertyName:propertyName];
				}
				break;
			case SCPropertyTypeDate:
				if(!readOnlyProperty && 
				   (propertyDataType==SCPropertyDataTypeNSDate || propertyDataType==SCPropertyDataTypeDictionaryItem
					|| propertyDataType==SCPropertyDataTypeTransformable))
				{
					cell = [SCDateCell cellWithText:propertyTitle 
									withBoundObject:_boundObject withDatePropertyName:propertyName];
				}
				break;
			case SCPropertyTypeImagePicker:
				if(!readOnlyProperty && 
				   (propertyDataType==SCPropertyDataTypeNSString || propertyDataType==SCPropertyDataTypeDictionaryItem
					|| propertyDataType==SCPropertyDataTypeTransformable))
				{
					cell = [SCImagePickerCell cellWithText:propertyTitle 
										   withBoundObject:_boundObject withImageNamePropertyName:propertyName];
				}
				break;
			case SCPropertyTypeSelection:
				if(!readOnlyProperty && propertyDataType==SCPropertyDataTypeNSNumber)
				{
					cell = [SCSelectionCell cellWithText:propertyTitle 
										 withBoundObject:_boundObject withSelectedIndexPropertyName:propertyName
											   withItems:nil];
				}
				else
					if(!readOnlyProperty && (propertyDataType==SCPropertyDataTypeNSString || propertyDataType==SCPropertyDataTypeDictionaryItem) )
					{
						cell = [SCSelectionCell cellWithText:propertyTitle 
											 withBoundObject:_boundObject withSelectionStringPropertyName:propertyName
												   withItems:nil];
					}
					else
						if(propertyDataType==SCPropertyDataTypeNSMutableSet)
						{
							cell = [SCSelectionCell cellWithText:propertyTitle 
												 withBoundObject:_boundObject withSelectedIndexesPropertyName:propertyName
													   withItems:nil allowMultipleSelection:FALSE];
						}
				break;
			case SCPropertyTypeObjectSelection:
				cell = [SCObjectSelectionCell cellWithText:propertyTitle
										   withBoundObject:_boundObject
							withSelectedObjectPropertyName:propertyName
												 withItems:nil
                                   withItemsClassDefintion:nil];
				break;
			case SCPropertyTypeObject:
			{
				NSObject *object = [SCHelper valueForPropertyName:propertyName inObject:_boundObject];
				
#ifdef _COREDATADEFINES_H			
				if(!object && coreDataBound)
				{
					// create a new object
					NSManagedObject *managedObj = (NSManagedObject *)_boundObject;
					NSRelationshipDescription *objReleationship = 
					[[[managedObj entity] relationshipsByName] valueForKey:propertyName];
					if(objReleationship)
					{
						object = [NSEntityDescription 
								  insertNewObjectForEntityForName:[[objReleationship destinationEntity] name]
								  inManagedObjectContext:propertyDefinition.ownerClassDefinition.managedObjectContext];
						[_boundObject setValue:object forKey:propertyName];
					}
				}
#endif			
				
				if(!object)
					break;
				
				SCClassDefinition *objClassDef = nil;
				if([propertyDefinition.attributes isKindOfClass:[SCObjectAttributes class]])
				{
					NSArray *classDefinitions = [[(SCObjectAttributes *)propertyDefinition.attributes 
												  classDefinitions] allValues];
					if(classDefinitions.count)
						objClassDef = [classDefinitions objectAtIndex:0];
				}
				
				// If "object" has only a single object-type property, flatten out
				// the hierarchy by directly exposing the cell for this property
				SCPropertyDefinition *objPropertyDef = nil;
				if(objClassDef.propertyDefinitionCount==1)
					objPropertyDef = [objClassDef propertyDefinitionAtIndex:0];
				if(objPropertyDef && 
				   (objPropertyDef.type==SCPropertyTypeObject || objPropertyDef.type==SCPropertyTypeArrayOfObjects) )
				{
					// Get the cell via recursion
					cell = [self getCellForPropertyWithDefinition:objPropertyDef withBoundObject:object inEditingMode:editing];
				}
				else
				{
					cell = [SCObjectCell cellWithBoundObject:object withClassDefinition:objClassDef];
					if(propertyDefinition.title)
						((SCObjectCell *)cell).boundObjectTitleText = propertyDefinition.title;
					
					// Technically, boundPropertyName is not applicable to SCObjectCell, however
					// it is set here so that [self cellForPropertyName] would work 
					cell.boundPropertyName = propertyName;
				}
			}
				break;
				
			case SCPropertyTypeArrayOfObjects:
			{
				NSMutableArray *objectsArray = [_boundObject valueForKey:propertyName];
				if(!objectsArray)
					break;
				
				if(coreDataBound)
				{
					SCClassDefinition *entityClassDef = nil;
					if([propertyDefinition.attributes isKindOfClass:[SCArrayOfObjectsAttributes class]])
					{
						NSArray *classDefinitions = [[(SCArrayOfObjectsAttributes *)propertyDefinition.attributes 
													  classDefinitions] allValues];
						if(classDefinitions.count)
							entityClassDef = [classDefinitions objectAtIndex:0];
					}
					
					if([[_boundObject valueForKey:propertyName] isKindOfClass:[NSMutableSet class]])
					{
						cell = [SCArrayOfObjectsCell cellWithItemsSet:[_boundObject mutableSetValueForKey:propertyName]
												  withClassDefinition:entityClassDef];
					}
					else
						if([[_boundObject valueForKey:propertyName] isKindOfClass:[NSArray class]])
						{
							cell = [SCArrayOfObjectsCell cellWithItems:[_boundObject valueForKey:propertyName]
												   withClassDefinition:entityClassDef];
						}
				}
				else
				{
					cell = [SCArrayOfObjectsCell cellWithItems:objectsArray
										   withClassDefinition:nil];
				}
				
				if(propertyDefinition.title)
					((SCArrayOfObjectsCell *)cell).boundObjectTitleText = propertyDefinition.title;
				
				// Technically, boundPropertyName is not applicable to SCArrayOfObjectsCell, however
				// it is set here so that [self cellForPropertyName] would work 
				cell.boundPropertyName = propertyName;
			}
				break;
				
			default:
				cell = nil;
				break;
		}
	}
	
	if(cell)
	{
        [self setEditableStateForCell:cell withPropertyDefinition:propertyDefinition inEditingMode:editing];
		cell.delegate = propertyDefinition.ownerClassDefinition.uiElementDelegate;
		cell.valueRequired = propertyDefinition.required;
		cell.autoValidateValue = propertyDefinition.autoValidate;
        
        SCPropertyAttributes *propertyAttributes = propertyDefinition.attributes;
        if(editing && propertyDefinition.editingModeType!=SCPropertyTypeUndefined)
        {
            propertyAttributes = propertyDefinition.editingModeAttributes;
        }
		[cell setAttributesTo:propertyAttributes];
	}
		
	return cell;
}

- (SCTableViewCell *)cellForPropertyName:(NSString *)propertyName
{
	for(SCTableViewCell *cell in cells)
	{
		if([cell.boundPropertyName isEqualToString:propertyName])
			return cell;
	}
	return nil;
}

@end







@interface SCArrayOfItemsSection ()

- (SCTableViewCell *)unconfiguredCellAtIndex:(NSUInteger)index;
- (BOOL)addNewItemCellExists;
- (BOOL)addNewItemCellExistsForEditingMode:(BOOL)editing;
- (SCTableViewModel *)getCustomDetailModelForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)callDelegateForDidInsertRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)callDelegateForDidRemoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)callDelegateForCoreDataObjectsLoaded;

@end



@implementation SCArrayOfItemsSection

@synthesize items;
@synthesize itemsAccessoryType;
@synthesize allowAddingItems;
@synthesize allowDeletingItems;
@synthesize allowMovingItems;
@synthesize allowEditDetailView;
@synthesize allowRowSelection;
@synthesize autoSelectNewItemCell;
@synthesize detailViewNavigationBarType;
@synthesize detailViewModal;
#ifdef __IPHONE_3_2
@synthesize detailViewModalPresentationStyle;
#endif
@synthesize detailTableViewStyle;
@synthesize detailViewHidesBottomBar;
@synthesize cellIdentifier;
@synthesize addButtonItem;
@synthesize enableCellHeightCaching;
@synthesize placeholderCell;
@synthesize addNewItemCell;
@synthesize addNewItemCellExistsInNormalMode;
@synthesize addNewItemCellExistsInEditingMode;
@synthesize selectedCellIndexPath;

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				   withItems:(NSMutableArray *)sectionItems
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
											withItems:sectionItems]);
}


- (id)init
{
	if( (self=[super init]) )
	{
		tempCustomDetailModel = nil;
        activeDetailModel = nil;
		cellReuseIdentifiers = [[NSMutableArray alloc] init];
		items = nil;
		itemsAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		allowAddingItems = TRUE;
		allowDeletingItems = TRUE;
		allowMovingItems = TRUE;
		allowEditDetailView = TRUE;
		allowRowSelection = TRUE;
		autoSelectNewItemCell = FALSE;
        detailViewNavigationBarType = SCNavigationBarTypeDoneRightCancelLeft;
		detailViewModal = FALSE;
#ifdef __IPHONE_3_2
		detailViewModalPresentationStyle = UIModalPresentationFullScreen;
#endif
		
		detailTableViewStyle = UITableViewStyleGrouped;
		detailViewHidesBottomBar = TRUE;
		
		// set the cellIndentifier to a simple unique string
		cellIdentifier = [[NSString alloc] initWithFormat:@"%@", [NSDate date]];
		
		selectedCellIndexPath = nil;
		addButtonItem = nil;
		tempItem = nil;
        
        enableCellHeightCaching = TRUE;
        cachedCellHeight = 0;
        
        placeholderCell = nil;
        addNewItemCell = nil;
        addNewItemCellExistsInNormalMode = TRUE;
        addNewItemCellExistsInEditingMode = TRUE;
	}
	
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
				withItems:(NSMutableArray *)sectionItems
{
	if( (self=[self initWithHeaderTitle:sectionHeaderTitle]) )
	{
		self.items = sectionItems;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
    [tempCustomDetailModel release];
	[cellReuseIdentifiers release];
	[items release];
	[selectedCellIndexPath release];
	[addButtonItem release];
	[tempItem release];
	[cellIdentifier release];
    [placeholderCell release];
    [addNewItemCell release];
    
	[super dealloc];
}
#endif

- (BOOL)addNewItemCellExists
{
    return [self addNewItemCellExistsForEditingMode: (self.ownerTableViewModel.modeledTableView.editing && self.ownerTableViewModel.viewController.editing)];
}

- (BOOL)addNewItemCellExistsForEditingMode:(BOOL)editing
{
    return self.addNewItemCell && ( (!editing && self.addNewItemCellExistsInNormalMode) || (editing && self.addNewItemCellExistsInEditingMode) );
}

- (void)setPlaceholderCell:(SCTableViewCell *)_placeholderCell
{
    SC_Release(placeholderCell);
    placeholderCell = SC_Retain(_placeholderCell);
    
    placeholderCell.ownerTableViewModel = self.ownerTableViewModel;
    placeholderCell.selectable = FALSE;
    placeholderCell.movable = FALSE;
    placeholderCell.editable = self.addNewItemCell!=nil;
    placeholderCell.cellEditingStyle = UITableViewCellEditingStyleNone;
    placeholderCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setAddNewItemCell:(SCTableViewCell *)_addNewItemCell
{
    SC_Release(addNewItemCell);
    addNewItemCell = SC_Retain(_addNewItemCell);
    
    addNewItemCell.ownerTableViewModel = self.ownerTableViewModel;
    addNewItemCell.movable = FALSE;
    addNewItemCell.editable = TRUE;
    addNewItemCell.cellEditingStyle = UITableViewCellEditingStyleInsert;
    addNewItemCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    placeholderCell.editable = addNewItemCell!=nil;
}

- (void)callDelegateForCoreDataObjectsLoaded
{
    if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:coreDataObjectsLoadedForSectionAtIndex:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
                   coreDataObjectsLoadedForSectionAtIndex:[self.ownerTableViewModel indexForSection:self]];
	}
}

- (void)setAddButtonItem:(UIBarButtonItem *)barButtonItem
{
	SC_Release(addButtonItem);
	addButtonItem = SC_Retain(barButtonItem);
	
	addButtonItem.target = self;
	addButtonItem.action = @selector(didTapAddButtonItem);
}

// override superclass method
- (void)editingModeWillChange
{
    if(!self.addNewItemCell || (self.addNewItemCellExistsInNormalMode==self.addNewItemCellExistsInEditingMode))
        return;
    
    NSInteger sectionIndex = [self.ownerTableViewModel indexForSection:self];
    if([self addNewItemCellExists])
    {
        [self.ownerTableViewModel.modeledTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.cellCount-1 inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationTop];
    }
    else
    {
        [self.ownerTableViewModel.modeledTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.cellCount inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationTop];
    }
}

// override superclass method
- (NSUInteger)cellCount
{
    NSInteger count = items.count;
    
    if(!count && self.placeholderCell)
        count = 1;
    
    if([self addNewItemCellExists])
        count++;
    
	return count;
}

// override superclass method
- (SCTableViewCell *)unconfiguredCellAtIndex:(NSUInteger)index;
{
    if(index==0 && self.items.count==0 && self.placeholderCell)
        return self.placeholderCell;
    
    if([self addNewItemCellExists] && index==(self.cellCount-1))
        return self.addNewItemCell;
    
    if(self.items.count == 0)
        return nil;
	
	// Check if the user provides custom identifiers for cells
	NSString *cellId = nil;
	if([self.ownerTableViewModel.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.ownerTableViewModel.dataSource respondsToSelector:@selector(tableViewModel:customReuseIdentifierForRowAtIndexPath:)])
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index 
													inSection:[self.ownerTableViewModel indexForSection:self]];
		cellId = [self.ownerTableViewModel.dataSource tableViewModel:self.ownerTableViewModel
							  customReuseIdentifierForRowAtIndexPath:indexPath];
	}
	if(!cellId)
	{
		cellId = self.cellIdentifier;
	}
	
	SCTableViewCell *cell = (SCTableViewCell *)[self.ownerTableViewModel.modeledTableView 
                                                dequeueReusableCellWithIdentifier:cellId];
	
    if(cell == nil) 
	{
		// Check if the user provides their own custom cell
		if([self.ownerTableViewModel.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
		   && [self.ownerTableViewModel.dataSource respondsToSelector:@selector(tableViewModel:customCellForRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index 
														inSection:[self.ownerTableViewModel indexForSection:self]];
			cell = [self.ownerTableViewModel.dataSource tableViewModel:self.ownerTableViewModel
										   customCellForRowAtIndexPath:indexPath];
			if(cell)
				cell.customCell = TRUE;
		}
		
		if(!cell)
			cell = [self createCellAtIndex:index];
		
		cell.reuseId = cellId;
    }
    
    [self setPropertiesForCell:cell withIndex:index];
    
    return cell;
}

// override superclass method
- (SCTableViewCell *)cellAtIndex:(NSUInteger)index
{
    SCTableViewCell *cell = [self unconfiguredCellAtIndex:index];
	
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(willConfigureCell:)])
	{
		[cell.delegate willConfigureCell:cell];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:willConfigureCell:forRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index 
														inSection:[self.ownerTableViewModel indexForSection:self]];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel willConfigureCell:cell 
											forRowAtIndexPath:indexPath];
		}
    
    return cell;
}

// override superclass method
- (NSUInteger)indexForCell:(SCTableViewCell *)cell
{
	NSIndexPath *indexPath = [self.ownerTableViewModel.modeledTableView indexPathForCell:cell];
	if(indexPath.section == [self.ownerTableViewModel indexForSection:self])
		return indexPath.row;
	return NSNotFound;
}

// override superclass method
- (void)reloadBoundValues
{
    [self.ownerTableViewModel clearLastReturnedCellData];
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0;
    if(cachedCellHeight == 0)
    {
        SCTableViewCell *cell = [self cellAtIndex:indexPath.row];
        
        cellHeight = cell.height;
        if(self.enableCellHeightCaching)
            cachedCellHeight = cellHeight;
    }
    else
        cellHeight = cachedCellHeight;
    
    return cellHeight;
}

- (SCTableViewCell *)createCellAtIndex:(NSUInteger)index
{
	SCTableViewCell *cell = SC_Autorelease([[SCTableViewCell alloc] initWithStyle:SC_DefaultCellStyle 
										  reuseIdentifier:self.cellIdentifier]);
	cell.ownerTableViewModel = self.ownerTableViewModel;
	
	return cell;
}

- (void)setPropertiesForCell:(SCTableViewCell *)cell withIndex:(NSUInteger)index
{
	cell.beingReused = TRUE;
	cell.ownerTableViewModel = self.ownerTableViewModel;
	if(!cell.boundObject)
		cell.boundObject = [self.items objectAtIndex:index];
	if(!cell.customCell)
	{
		cell.textLabel.text = [self textForCellAtIndex:index];
		cell.detailTextLabel.text = [self detailTextForCellAtIndex:index];
	}
	cell.editable = (self.allowDeletingItems || self.allowMovingItems);
    if(self.allowDeletingItems)
        cell.cellEditingStyle = UITableViewCellEditingStyleDelete;
    else
        cell.cellEditingStyle = UITableViewCellEditingStyleNone;
    cell.movable = self.allowMovingItems;
	if(self.allowRowSelection)
	{
		cell.accessoryType = self.itemsAccessoryType;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
}

- (NSString *)textForCellAtIndex:(NSUInteger)index
{
	return [NSString stringWithFormat:@"Item: %i", index];
}

- (NSString *)detailTextForCellAtIndex:(NSUInteger)index
{
	return nil;
}

- (void)tempDetailModelModified
{
	[self commitDetailModelChanges:tempCustomDetailModel];
}

- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel
{
	//will be overridden in subclasses
}

- (SCTableViewModel *)getCustomDetailModelForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewModel *detailModel = nil;
	if([self.ownerTableViewModel.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.ownerTableViewModel.dataSource 
		   respondsToSelector:@selector(tableViewModel:customDetailTableViewModelForRowAtIndexPath:)])
	{
		detailModel = [self.ownerTableViewModel.dataSource tableViewModel:self.ownerTableViewModel
							  customDetailTableViewModelForRowAtIndexPath:indexPath];
	}
	return detailModel;
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    if([self addNewItemCellExists] && indexPath.row==(self.cellCount-1))
    {
        [self dispatchAddNewItemEvent];
        return;
    }
        
	self.selectedCellIndexPath = indexPath;
	
    if(self.allowEditDetailView)
        [self dispatchSelectRowAtIndexPathEvent:indexPath];
}

- (void)dispatchSelectRowAtIndexPathEvent:(NSIndexPath *)indexPath
{
    SCTableViewCell *selectedCell = (SCTableViewCell *)[self.ownerTableViewModel.modeledTableView cellForRowAtIndexPath:indexPath];
    if(self.addNewItemCell && self.addNewItemCell==selectedCell)
    {
        [self dispatchAddNewItemEvent];
        return;
    }
    
	self.selectedCellIndexPath = indexPath;
	
	// Check for custom detail table view model
	SCTableViewModel *detailTableViewModel = [self getCustomDetailModelForRowAtIndexPath:indexPath];
	if(detailTableViewModel)
	{
		SC_Release(tempCustomDetailModel);
		tempCustomDetailModel = [[SCTableViewModel alloc] initWithTableView:detailTableViewModel.modeledTableView
												   withViewController:detailTableViewModel.viewController];
		tempCustomDetailModel.dataSource = detailTableViewModel.dataSource;
		tempCustomDetailModel.delegate = detailTableViewModel.delegate;
		tempCustomDetailModel.masterModel = self.ownerTableViewModel;
		[tempCustomDetailModel setTargetForModelModifiedEvent:self action:@selector(tempDetailModelModified)];
		[self buildDetailTableModel:tempCustomDetailModel	
							forItem:[self.items objectAtIndex:indexPath.row]];
		for(int i=0; i<tempCustomDetailModel.sectionCount; i++)
        {
            [tempCustomDetailModel sectionAtIndex:i].commitCellChangesLive = TRUE;
        }
        
        if([selectedCell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
           && [selectedCell.delegate respondsToSelector:@selector(detailViewWillAppearForCell:withDetailTableViewModel:)])
        {
            [selectedCell.delegate detailViewWillAppearForCell:selectedCell withDetailTableViewModel:tempCustomDetailModel];
        }
        else
            if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
               && [self.ownerTableViewModel.delegate 
                   respondsToSelector:@selector(tableViewModel:detailViewWillAppearForRowAtIndexPath:withDetailTableViewModel:)])
            {
                [self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel 
                            detailViewWillAppearForRowAtIndexPath:indexPath 
                                         withDetailTableViewModel:tempCustomDetailModel];
            }
        
		[detailTableViewModel.modeledTableView reloadData];
        
        activeDetailModel = detailTableViewModel;
		
		return;
	}
    
    NSObject *item = [self.items objectAtIndex:indexPath.row];
	
	UINavigationController *navController = self.ownerTableViewModel.viewController.navigationController;
	
	SCNavigationBarType navBarType = [self getDetailViewNavigationBarTypeForItem:item];
	SCTableViewController *detailViewController = [[SCTableViewController alloc] 
												   initWithStyle:self.detailTableViewStyle
												   withNavigationBarType:navBarType];
    [self.ownerTableViewModel configureDetailModel:detailViewController.tableViewModel];
    activeDetailModel = detailViewController.tableViewModel;
	detailViewController.ownerViewController = self.ownerTableViewModel.viewController;
	detailViewController.delegate = self;
    detailViewController.title = 
	[self.ownerTableViewModel.modeledTableView cellForRowAtIndexPath:indexPath].textLabel.text;
	detailViewController.hidesBottomBarWhenPushed = self.detailViewHidesBottomBar;
#ifdef __IPHONE_3_2	
	if([SCHelper is_iPad])
		detailViewController.contentSizeForViewInPopover = 
		self.ownerTableViewModel.viewController.contentSizeForViewInPopover;
#endif	
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:detailModelCreatedForRowAtIndexPath:detailTableViewModel:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					  detailModelCreatedForRowAtIndexPath:indexPath
									 detailTableViewModel:detailViewController.tableViewModel];
	}
	
	[self buildDetailTableModel:detailViewController.tableViewModel	
						forItem:item];
	
	SCTableViewCell *cell = (SCTableViewCell *)[self.ownerTableViewModel.modeledTableView cellForRowAtIndexPath:indexPath];
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(detailViewWillAppearForCell:withDetailTableViewModel:)])
	{
		[cell.delegate detailViewWillAppearForCell:cell withDetailTableViewModel:detailViewController.tableViewModel];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewWillAppearForRowAtIndexPath:withDetailTableViewModel:)])
		{
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel 
						detailViewWillAppearForRowAtIndexPath:indexPath 
									 withDetailTableViewModel:detailViewController.tableViewModel];
		}
	
	BOOL inPopover = [SCHelper isViewInsidePopover:self.ownerTableViewModel.viewController.view];
	if(navController && !self.detailViewModal)
	{
		if(inPopover)
			detailViewController.modalInPopover = TRUE;
		[navController pushViewController:detailViewController animated:TRUE];
	}
	else
	{
		UINavigationController *detailNavController = [[UINavigationController alloc] 
													   initWithRootViewController:detailViewController];
		if(navController)
		{
            detailNavController.view.backgroundColor = navController.view.backgroundColor;
			UIBarStyle barStyle = navController.navigationBar.barStyle;
			if(!inPopover)
				detailNavController.navigationBar.barStyle = barStyle;
			else  
				detailNavController.navigationBar.barStyle = UIBarStyleBlack;
            detailNavController.navigationBar.tintColor = navController.navigationBar.tintColor;
		}
#ifdef __IPHONE_3_2
		if([SCHelper is_iPad])
		{
			detailNavController.contentSizeForViewInPopover = detailViewController.contentSizeForViewInPopover;
			detailNavController.modalPresentationStyle = self.detailViewModalPresentationStyle;
		}
#endif
		[self.ownerTableViewModel.viewController presentModalViewController:detailNavController
																   animated:TRUE];
		SC_Release(detailNavController);
	}
	
	SC_Release(detailViewController);
}

- (void)didTapAddButtonItem
{
	if(!self.allowAddingItems)
		return;
	
	[self dispatchAddNewItemEvent];
}

- (void)dispatchAddNewItemEvent
{
	self.selectedCellIndexPath = nil;
	
	SC_Release(tempItem);
	tempItem = SC_Retain([self createNewItem]);
	if(!tempItem)
		return;
	
	NSUInteger index = [ownerTableViewModel indexForSection:self];
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:itemCreatedForSectionAtIndex:item:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
							 itemCreatedForSectionAtIndex:index
													 item:tempItem];
	}
	
	if(self.ownerTableViewModel.activeCell.autoResignFirstResponder)
		[self.ownerTableViewModel.activeCell resignFirstResponder];
	
	SCTableViewController *detailViewController = [[SCTableViewController alloc] 
												   initWithStyle:self.detailTableViewStyle
												   withNavigationBarType:self.detailViewNavigationBarType];
    [self.ownerTableViewModel configureDetailModel:detailViewController.tableViewModel];
    activeDetailModel = detailViewController.tableViewModel;
	detailViewController.ownerViewController = self.ownerTableViewModel.viewController;
	detailViewController.delegate = self;
    detailViewController.hidesBottomBarWhenPushed = self.detailViewHidesBottomBar;
#ifdef __IPHONE_3_2	
	if([SCHelper is_iPad])
		detailViewController.contentSizeForViewInPopover = 
			self.ownerTableViewModel.viewController.contentSizeForViewInPopover;
#endif	
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:detailModelCreatedForSectionAtIndex:detailTableViewModel:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					  detailModelCreatedForSectionAtIndex:index
									 detailTableViewModel:detailViewController.tableViewModel];
	}
	
	[self buildDetailTableModel:detailViewController.tableViewModel
						forItem:tempItem];
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:detailViewWillAppearForSectionAtIndex:withDetailTableViewModel:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					detailViewWillAppearForSectionAtIndex:index
								 withDetailTableViewModel:detailViewController.tableViewModel];
	}
	
	BOOL inPopover = [SCHelper isViewInsidePopover:self.ownerTableViewModel.viewController.view];
	
	if(inPopover && self.detailViewModalPresentationStyle==UIModalPresentationCurrentContext
	   && self.ownerTableViewModel.viewController.navigationController)
	{
		// The detail view is pushed instead of presented modally because of a popover bug
		detailViewController.modalInPopover = TRUE;
		[self.ownerTableViewModel.viewController.navigationController
			pushViewController:detailViewController animated:YES];
	}
	else
	{
		UINavigationController *detailNavController = [[UINavigationController alloc] 
													   initWithRootViewController:detailViewController];
		if(self.ownerTableViewModel.viewController.navigationController)
		{
            detailNavController.view.backgroundColor = self.ownerTableViewModel.viewController.navigationController.view.backgroundColor;
			UIBarStyle barStyle = self.ownerTableViewModel.viewController.navigationController.navigationBar.barStyle;
			if(!inPopover)
				detailNavController.navigationBar.barStyle = barStyle;
			else  
				detailNavController.navigationBar.barStyle = UIBarStyleBlack;
            detailNavController.navigationBar.tintColor = self.ownerTableViewModel.viewController.navigationController.navigationBar.tintColor;
		}
#ifdef __IPHONE_3_2
		if([SCHelper is_iPad])
		{
			detailNavController.contentSizeForViewInPopover = detailViewController.contentSizeForViewInPopover;
			detailNavController.modalPresentationStyle = self.detailViewModalPresentationStyle;
		}
#endif
		[self.ownerTableViewModel.viewController presentModalViewController:detailNavController
																   animated:TRUE];
		SC_Release(detailNavController);
	}
	SC_Release(detailViewController);
}

- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
		forCellAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleInsert)
    {
        [self dispatchAddNewItemEvent];
        return;
    }

    
	BOOL shouldRemove = TRUE;
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate respondsToSelector:@selector(tableViewModel:willRemoveRowAtIndexPath:)])
	{
		shouldRemove = [self.ownerTableViewModel.delegate 
						tableViewModel:self.ownerTableViewModel willRemoveRowAtIndexPath:indexPath];
	}
	if(!shouldRemove)
		return;
	
	[self dispatchRemoveRowAtIndexPathEvent:indexPath];
}

- (void)dispatchRemoveRowAtIndexPathEvent:(NSIndexPath *)indexPath
{	
    [self.ownerTableViewModel clearLastReturnedCellData];
    
	if( (self.selectedCellIndexPath.section==indexPath.section &&  self.selectedCellIndexPath.row==indexPath.row) && tempCustomDetailModel)
	{
		UITableView *detailTableView = tempCustomDetailModel.modeledTableView;
		SC_Release(tempCustomDetailModel);
		tempCustomDetailModel = nil;
		detailTableView.dataSource = nil;
		detailTableView.delegate = nil;
		[detailTableView reloadData];
	}
	
	[self.items removeObjectAtIndex:indexPath.row];
    
    UITableViewRowAnimation deleteAnimation = UITableViewRowAnimationRight;
    if(self.items.count==0 && self.placeholderCell)
        deleteAnimation = UITableViewRowAnimationNone;
    [self.ownerTableViewModel.modeledTableView beginUpdates];
	NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
	[self.ownerTableViewModel.modeledTableView deleteRowsAtIndexPaths:indexPaths 
													 withRowAnimation:deleteAnimation];
    if(self.items.count==0 && self.placeholderCell)
        [self.ownerTableViewModel.modeledTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.ownerTableViewModel.modeledTableView endUpdates];
	
	
	// Allow some time for table view animations to finish
    [self performSelector:@selector(callDelegateForDidRemoveRowAtIndexPath:) withObject:indexPath afterDelay:0.2f];
}

- (void)callDelegateForDidRemoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate respondsToSelector:@selector(tableViewModel:didRemoveRowAtIndexPath:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel didRemoveRowAtIndexPath:indexPath];
	}
}

- (void)callDelegateForDidInsertRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate respondsToSelector:@selector(tableViewModel:didInsertRowAtIndexPath:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel didInsertRowAtIndexPath:indexPath];
	}
}

- (NSIndexPath *)targetIndexPathForMoveFromCellAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedIndexPath
{
    if(sourceIndexPath.section != proposedIndexPath.section)
        return sourceIndexPath;
    
    if([self addNewItemCellExists] && proposedIndexPath.row==(self.cellCount-1))
        return [NSIndexPath indexPathForRow:proposedIndexPath.row-1 inSection:proposedIndexPath.section];
    
    return proposedIndexPath;
}

- (void)moveCellAtIndexPath:(NSIndexPath *)fromIndexPath 
				toIndexPath:(NSIndexPath *)toIndexPath
{
	if(fromIndexPath.section==toIndexPath.section && fromIndexPath.row==toIndexPath.row)
		return;
	
	id item = SC_Retain([self.items objectAtIndex:fromIndexPath.row]);
	[self.items removeObjectAtIndex:fromIndexPath.row];
	
	if(fromIndexPath.section == toIndexPath.section)
	{
		[self.items insertObject:item atIndex:toIndexPath.row];
	}
	else
	{
		SCTableViewSection *toSection = [self.ownerTableViewModel sectionAtIndex:toIndexPath.section];
		if([toSection isKindOfClass:[SCArrayOfItemsSection class]])
			[[(SCArrayOfItemsSection *)toSection items] insertObject:item atIndex:toIndexPath.row];
	}
	
	SC_Release(item);
}

- (NSObject *)createNewItem
{
	// If supported, have datasource create the new item
	if([self.ownerTableViewModel.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.ownerTableViewModel.dataSource 
		   respondsToSelector:@selector(tableViewModel:newItemForArrayOfItemsSectionAtIndex:)])
	{
		return [self.ownerTableViewModel.dataSource tableViewModel:self.ownerTableViewModel
							  newItemForArrayOfItemsSectionAtIndex:[self.ownerTableViewModel indexForSection:self]];
	}
	
	// Else use a class from the first item in items
	if(!self.items.count)
		return nil;
	
	return SC_Autorelease([[[[self.items objectAtIndex:0] class] alloc] init]);
}

- (void)buildDetailTableModel:(SCTableViewModel *)detailTableModel forItem:(NSObject *)item
{
	// Does nothing, override in subclasses
}

- (SCNavigationBarType)getDetailViewNavigationBarTypeForItem:(NSObject *)item
{
    return self.detailViewNavigationBarType;
}

- (void)addNewItem:(NSObject *)newItem
{
	// Does nothing, override in subclasses
}

- (void)itemModified:(NSObject *)item
{
	// Does nothing, override in subclasses
}

#pragma mark -
#pragma mark SCTableViewControllerDelegate methods

// Should be overridden by subclasses
- (void)tableViewControllerWillDisappear:(SCTableViewController *)tableViewController
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if(tableViewController.state != SCViewControllerStateDismissed)
		return;
	
    if(self.selectedCellIndexPath)
    {
        SCTableViewCell *selectedCell = (SCTableViewCell *)[self.ownerTableViewModel.modeledTableView cellForRowAtIndexPath:self.selectedCellIndexPath];
        if([selectedCell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
           && [selectedCell.delegate respondsToSelector:@selector(detailViewWillDisappearForCell:)])
        {
            [selectedCell.delegate detailViewWillDisappearForCell:selectedCell];
        }
        else
            if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
               && [self.ownerTableViewModel.delegate 
                   respondsToSelector:@selector(tableViewModel:detailViewWillDisappearForRowAtIndexPath:)])
            {
                [self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
                         detailViewWillDisappearForRowAtIndexPath:self.selectedCellIndexPath];
            }
    }
    else
    {
        if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
           && [self.ownerTableViewModel.delegate 
               respondsToSelector:@selector(tableViewModel:detailViewWillDisappearForSectionAtIndex:)])
        {
            NSUInteger index = [ownerTableViewModel indexForSection:self];
            [self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
                     detailViewWillDisappearForSectionAtIndex:index];
        }
    }
}

- (void)tableViewControllerDidDisappear:(SCTableViewController *)tableViewController 
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if(tableViewController.state != SCViewControllerStateDismissed)
		return;
    
    activeDetailModel = nil;
	
	if(self.selectedCellIndexPath)
    {
        SCTableViewCell *selectedCell = (SCTableViewCell *)[self.ownerTableViewModel.modeledTableView cellForRowAtIndexPath:self.selectedCellIndexPath];
        if([selectedCell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
           && [selectedCell.delegate respondsToSelector:@selector(detailViewDidDisappearForCell:)])
        {
            [selectedCell.delegate detailViewDidDisappearForCell:selectedCell];
        }
        else
            if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
               && [self.ownerTableViewModel.delegate 
                   respondsToSelector:@selector(tableViewModel:detailViewDidDisappearForRowAtIndexPath:)])
            {
               [self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
                         detailViewDidDisappearForRowAtIndexPath:self.selectedCellIndexPath];
            }
    }
    else
    {
        if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
           && [self.ownerTableViewModel.delegate 
               respondsToSelector:@selector(tableViewModel:detailViewDidDisappearForSectionAtIndex:)])
        {
            NSUInteger index = [ownerTableViewModel indexForSection:self];
            [self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
                     detailViewDidDisappearForSectionAtIndex:index];
        }
    }
}


@end







@implementation SCArrayOfStringsSection


// override superclass method
- (NSString *)textForCellAtIndex:(NSUInteger)index
{
	id item = [self.items objectAtIndex:index];
	if([item isKindOfClass:[NSString class]])
		return (NSString *)item;
	//else
	return [super textForCellAtIndex:index];
}

// override superclass method
- (NSObject *)createNewItem
{
	return [NSString string];
}

// override superclass method
- (void)buildDetailTableModel:(SCTableViewModel *)detailTableModel forItem:(NSObject *)item
{
	SCTableViewSection *section = [[SCTableViewSection alloc] init];
	SCTextFieldCell *textFieldCell = [[SCTextFieldCell alloc] initWithText:nil];
	textFieldCell.textField.text = (NSString *)item;
	[section addCell:textFieldCell];
	SC_Release(textFieldCell);
	[detailTableModel addSection:section];
	SC_Release(section);
}

// override superclass method
- (void)addNewItem:(NSObject *)newItem
{
	[self.ownerTableViewModel clearLastReturnedCellData];
    
    [items addObject:newItem];
	
	NSUInteger sectionIndex = [self.ownerTableViewModel indexForSection:self];
	NSIndexPath *newRowIndexPath = [NSIndexPath indexPathForRow:items.count-1 inSection:sectionIndex];
	NSArray *indexPaths = [NSArray arrayWithObject:newRowIndexPath];
    
    [self.ownerTableViewModel.modeledTableView beginUpdates];
    if(self.items.count==1 && self.placeholderCell)
        [self.ownerTableViewModel.modeledTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
	[self.ownerTableViewModel.modeledTableView insertRowsAtIndexPaths:indexPaths
													 withRowAnimation:UITableViewRowAnimationBottom];
    [self.ownerTableViewModel.modeledTableView endUpdates];
	
     [self.ownerTableViewModel.modeledTableView scrollToRowAtIndexPath:newRowIndexPath 
													 atScrollPosition:UITableViewScrollPositionNone
															 animated:YES];
	
	[self.ownerTableViewModel.modeledTableView selectRowAtIndexPath:newRowIndexPath animated:TRUE 
													 scrollPosition:UITableViewScrollPositionNone];
	if(!self.autoSelectNewItemCell && !tempCustomDetailModel)
		[self.ownerTableViewModel.modeledTableView deselectRowAtIndexPath:newRowIndexPath animated:TRUE];
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:itemAddedForSectionAtIndexPath:item:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						   itemAddedForSectionAtIndexPath:newRowIndexPath
													 item:newItem];
	}
    
    // Allow some time for table view animations to finish
    [self performSelector:@selector(callDelegateForDidInsertRowAtIndexPath:) withObject:newRowIndexPath afterDelay:0.2f];
}

// override superclass method
- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel
{
	NSIndexPath *textFieldCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	SCTextFieldCell *textFieldCell = (SCTextFieldCell *)[detailModel cellAtIndexPath:textFieldCellIndexPath];
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:itemEditedForSectionAtIndexPath:item:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						  itemEditedForSectionAtIndexPath:textFieldCellIndexPath
													 item:[self.items objectAtIndex:textFieldCellIndexPath.row]];
	}
	
	NSString *oldString = [items objectAtIndex:self.selectedCellIndexPath.row];
	NSString *newString = textFieldCell.textField.text;
	if(![oldString isEqualToString:newString])
	{
		[items replaceObjectAtIndex:self.selectedCellIndexPath.row withObject:newString];
	}
	
	if(tempCustomDetailModel) // a custom detail view is defined
	{
		NSArray *indexPaths = [NSArray arrayWithObject:self.selectedCellIndexPath];
		[self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:indexPaths
														 withRowAnimation:UITableViewRowAnimationNone];
		if(tempCustomDetailModel)
		{
			[self.ownerTableViewModel.modeledTableView selectRowAtIndexPath:self.selectedCellIndexPath animated:NO 
															 scrollPosition:UITableViewScrollPositionNone];
		}
	}
}

// override superclass method
- (void)tableViewControllerWillDisappear:(SCTableViewController *)tableViewController
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if(tableViewController.state != SCViewControllerStateDismissed)
		return;
	
	if(cancelTapped)
	{
		SC_Release(tempItem);
		tempItem = nil;
        
        // call the delegates
        [super tableViewControllerWillDisappear:tableViewController cancelButtonTapped:cancelTapped doneButtonTapped:doneTapped];
        
		return;
	}
	
	NSIndexPath *textFieldCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	SCTextFieldCell *textFieldCell = (SCTextFieldCell *)[tableViewController.tableViewModel
														 cellAtIndexPath:textFieldCellIndexPath];
	
	if(self.selectedCellIndexPath)
	{
		[self commitDetailModelChanges:tableViewController.tableViewModel];
	}
	else
	{
		// New item added
		if([self.ownerTableViewModel isKindOfClass:[SCArrayOfItemsModel class]])
		{
			// Have model handle the item addition
			[(SCArrayOfItemsModel *)self.ownerTableViewModel addNewItem:textFieldCell.textField.text];
		}
		else
		{
			[self addNewItem:textFieldCell.textField.text];
		}
	}
	
	SC_Release(tempItem);
	tempItem = nil;	
	
	NSUInteger sectionIndex = [self.ownerTableViewModel indexForSection:self];
	[self.ownerTableViewModel valueChangedForSectionAtIndex:sectionIndex];
    
    
    // call the delegates
    [super tableViewControllerWillDisappear:tableViewController cancelButtonTapped:cancelTapped doneButtonTapped:doneTapped];
}

//override superclass
- (void)tableViewControllerDidDisappear:(SCTableViewController *)tableViewController 
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if(tableViewController.state != SCViewControllerStateDismissed)
		return;
	
	[super tableViewControllerDidDisappear:tableViewController cancelButtonTapped:cancelTapped
						  doneButtonTapped:doneTapped];
	
	if(self.selectedCellIndexPath)
	{
		NSArray *indexPaths = [NSArray arrayWithObject:self.selectedCellIndexPath];
		[self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:indexPaths
														 withRowAnimation:UITableViewRowAnimationNone];
		
		if(tempCustomDetailModel)
		{
			[self.ownerTableViewModel.modeledTableView selectRowAtIndexPath:self.selectedCellIndexPath animated:NO 
															 scrollPosition:UITableViewScrollPositionNone];
		}
	}
    
    
    // call the delegates
    [super tableViewControllerDidDisappear:tableViewController cancelButtonTapped:cancelTapped doneButtonTapped:doneTapped];
}

@end









@interface SCArrayOfObjectsSection ()

- (SCClassDefinition *)getClassDefinitionForObject:(NSObject *)object;

- (void)generateItemsArrayFromItemsSet;
- (SCClassDefinition *)firstClassDefinition;  // Returns the 1st classdef in classDefinitions

#ifdef _COREDATADEFINES_H
- (void)registerWithManagedObjectContextNotifications;
- (void)willSaveContext;
- (void)deleteCoreDataTempObject;
#endif

@end


@implementation SCArrayOfObjectsSection

@synthesize itemsPredicate;
@synthesize itemsClassDefinitions;
@synthesize itemsSet;
@synthesize sortItemsSetAscending;


+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				   withItems:(NSMutableArray *)sectionItems
		 withClassDefinition:(SCClassDefinition *)classDefinition
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
											withItems:sectionItems
								  withClassDefinition:classDefinition]);
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				withItemsSet:(NSMutableSet *)sectionItemsSet
		 withClassDefinition:(SCClassDefinition *)classDefinition
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
										 withItemsSet:sectionItemsSet
								  withClassDefinition:classDefinition]);
}

#ifdef _COREDATADEFINES_H
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
   withEntityClassDefinition:(SCClassDefinition *)classDefinition
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
							withEntityClassDefinition:classDefinition]);
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
   withEntityClassDefinition:(SCClassDefinition *)classDefinition
			  usingPredicate:(NSPredicate *)predicate
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
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
	}
	
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
				withItems:(NSMutableArray *)sectionItems
	  withClassDefinition:(SCClassDefinition *)classDefinition
{
	if( (self=[super initWithHeaderTitle:sectionHeaderTitle withItems:sectionItems]) )
	{
#ifdef _COREDATADEFINES_H
		if(!classDefinition && [sectionItems count])
		{
			if([[sectionItems objectAtIndex:0] isKindOfClass:[NSManagedObject class]])
			{
				NSManagedObject *managedObj = (NSManagedObject *)[sectionItems objectAtIndex:0];
				classDefinition = [SCClassDefinition definitionWithEntityName:[[managedObj entity] name]
													 withManagedObjectContext:[managedObj managedObjectContext]
											  autoGeneratePropertyDefinitions:YES];
			}
		}
#endif
		
		if(classDefinition)
		{
#ifdef _COREDATADEFINES_H			
			if(classDefinition.entity)
			{
				coreDataBound = TRUE;
				[self registerWithManagedObjectContextNotifications];
				
				if(!classDefinition.orderAttributeName)
					allowMovingItems = FALSE; 
			}
#endif			
			
			[self.itemsClassDefinitions setValue:classDefinition forKey:classDefinition.className];
		}
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withItemsSet:(NSMutableSet *)sectionItemsSet
	  withClassDefinition:(SCClassDefinition *)classDefinition
{
	if( (self=[super initWithHeaderTitle:sectionHeaderTitle withItems:nil]) )
	{
#ifdef _COREDATADEFINES_H
		if(!classDefinition && [sectionItemsSet count])
		{
			if([[sectionItemsSet anyObject] isKindOfClass:[NSManagedObject class]])
			{
				NSManagedObject *managedObj = (NSManagedObject *)[sectionItemsSet anyObject];
				classDefinition = [SCClassDefinition definitionWithEntityName:[[managedObj entity] name]
													 withManagedObjectContext:[managedObj managedObjectContext]
											  autoGeneratePropertyDefinitions:YES];
			}
		}
#endif		
		
		if(classDefinition)
		{
#ifdef _COREDATADEFINES_H			
			if(classDefinition.entity)
			{
				coreDataBound = TRUE;
				[self registerWithManagedObjectContextNotifications];
				
				if(!classDefinition.orderAttributeName)
					allowMovingItems = FALSE;
			}
#endif			
			
			[self.itemsClassDefinitions setValue:classDefinition forKey:classDefinition.className];
			
			self.itemsSet = sectionItemsSet;	// setter also generates items array
		}
	}
	return self;
}

#ifdef _COREDATADEFINES_H
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
	withEntityClassDefinition:(SCClassDefinition *)classDefinition
{
	return [self initWithHeaderTitle:sectionHeaderTitle withEntityClassDefinition:classDefinition
					  usingPredicate:nil];
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
withEntityClassDefinition:(SCClassDefinition *)classDefinition
		   usingPredicate:(NSPredicate *)predicate
{
	// Create the sectionItems array
	NSMutableArray *sectionItems = [SCHelper generateObjectsArrayForEntityClassDefinition:classDefinition
																		   usingPredicate:predicate ascending:YES];
	
    self = [self initWithHeaderTitle:sectionHeaderTitle withItems:sectionItems withClassDefinition:classDefinition];
    self.itemsPredicate = predicate;
    [self callDelegateForCoreDataObjectsLoaded];
    
    return self;
}
#endif

- (void)dealloc
{
	if(coreDataBound)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
    
#ifndef ARC_ENABLED    
    [itemsPredicate release];
	[itemsClassDefinitions release];
	[itemsSet release];
	
	[super dealloc];
#endif
}

//overrides superclass
- (void)setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCArrayOfObjectsAttributes class]])
		return;
	
	SCArrayOfObjectsAttributes *objectsArrayAttributes = (SCArrayOfObjectsAttributes *)attributes;
	[self.itemsClassDefinitions addEntriesFromDictionary:objectsArrayAttributes.classDefinitions];
	self.allowAddingItems = objectsArrayAttributes.allowAddingItems;
	self.allowDeletingItems = objectsArrayAttributes.allowDeletingItems;
	self.allowMovingItems = objectsArrayAttributes.allowMovingItems;
	self.allowEditDetailView = objectsArrayAttributes.allowEditingItems;
    if([objectsArrayAttributes.placeholderuiElement isKindOfClass:[SCTableViewCell class]])
        self.placeholderCell = (SCTableViewCell *)objectsArrayAttributes.placeholderuiElement;
    if([objectsArrayAttributes.addNewObjectuiElement isKindOfClass:[SCTableViewCell class]])
        self.addNewItemCell = (SCTableViewCell *)objectsArrayAttributes.addNewObjectuiElement;
    self.addNewItemCellExistsInNormalMode = objectsArrayAttributes.addNewObjectuiElementExistsInNormalMode;
    self.addNewItemCellExistsInEditingMode = objectsArrayAttributes.addNewObjectuiElementExistsInEditingMode;
}

// override superclass method
- (void)reloadBoundValues
{
    [super reloadBoundValues];
    
#ifdef _COREDATADEFINES_H
	SCClassDefinition *classDef = [self firstClassDefinition];
	if(classDef.entity)
    {
        self.items = [SCHelper generateObjectsArrayForEntityClassDefinition:classDef usingPredicate:self.itemsPredicate ascending:self.sortItemsSetAscending];
        [self callDelegateForCoreDataObjectsLoaded];
    }
		
#endif
}

// override superclass method
- (NSString *)textForCellAtIndex:(NSUInteger)index
{
	id object = [self.items objectAtIndex:index];
	SCClassDefinition *objectClassDef = [self getClassDefinitionForObject:object];
	
	if(objectClassDef.titlePropertyName)
	{
		return [objectClassDef titleValueForObject:object];
	}
	
	//else
	return nil;
}

// override superclass method
- (NSString *)detailTextForCellAtIndex:(NSUInteger)index
{
	id object = [self.items objectAtIndex:index];
	SCClassDefinition *objectClassDef = [self getClassDefinitionForObject:object];
	
	return [SCHelper stringValueForPropertyName:objectClassDef.descriptionPropertyName inObject:object
				   separateValuesUsingDelimiter:@" "];
}

// override superclass method
- (void)setPropertiesForCell:(SCTableViewCell *)cell withIndex:(NSUInteger)index
{	
	[super setPropertiesForCell:cell withIndex:index];
	
    id object = [self.items objectAtIndex:index];
    SCClassDefinition *objectClassDef = [self getClassDefinitionForObject:object];
	cell.boundObject = object;
    if(objectClassDef.uiElementDelegate)
        cell.delegate = objectClassDef.uiElementDelegate;
}

// override superclass method
- (void)moveCellAtIndexPath:(NSIndexPath *)fromIndexPath 
				toIndexPath:(NSIndexPath *)toIndexPath
{
	if(fromIndexPath.section==toIndexPath.section && fromIndexPath.row==toIndexPath.row)
		return;
	
	[super moveCellAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
	
	SCClassDefinition *classDef = [self firstClassDefinition];
	if(classDef && classDef.orderAttributeName && [classDef isValidPropertyName:classDef.orderAttributeName]
	   && fromIndexPath.section==toIndexPath.section)
	{
		// Update order for all objects in range
		NSInteger lowerRange;
		NSInteger upperRange;
		if(fromIndexPath.row < toIndexPath.row)
		{
			lowerRange = fromIndexPath.row;
			upperRange = toIndexPath.row;
		}
		else
		{
			lowerRange = toIndexPath.row;
			upperRange = fromIndexPath.row;
		}
		for(int i=lowerRange; i<=upperRange; i++)
		{
			NSObject *object = [self.items objectAtIndex:i];
			NSNumber *order = [[NSNumber alloc] initWithInt:i];
			[object setValue:order forKey:classDef.orderAttributeName];
			SC_Release(order);
		}
	}
}

// override superclass method
- (NSObject *)createNewItem
{
	NSObject *obj = nil;
	
	if(coreDataBound)
	{
#ifdef _COREDATADEFINES_H
		SCClassDefinition *classDef = [self firstClassDefinition];
		NSEntityDescription *entity = [classDef entity];
		if(entity)
		{
			obj = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                inManagedObjectContext:classDef.managedObjectContext];
			
			if(self.itemsSet)
				[self.itemsSet addObject:obj];
		}
#endif
	}
	else
	{
		obj = [super createNewItem];
		if(!obj)
		{
			// Use a class from itemsClassDefinitions
			SCClassDefinition *classDef = [self firstClassDefinition];
			if(classDef)
            {
                if([classDef isKindOfClass:[SCDictionaryDefinition class]])
                {
                    obj = [NSMutableDictionary dictionary];
                }
                else
                {
                    obj = SC_Autorelease([[classDef.cls alloc] init]);
                }
            }
		}
	}
	
	return obj;
}

// override superclass method
- (void)buildDetailTableModel:(SCTableViewModel *)detailTableModel forItem:(NSObject *)item
{
    BOOL newObject;
    if(self.selectedCellIndexPath)
        newObject = FALSE;
    else
        newObject = TRUE;
	[detailTableModel generateSectionsForObject:item usingClassDefinition:[self getClassDefinitionForObject:item] newObject:newObject];
    
    for(NSInteger i=0; i<detailTableModel.sectionCount; i++)
    {
        SCTableViewSection *section = [detailTableModel sectionAtIndex:i];
        
        section.commitCellChangesLive = FALSE;
        for(int j=0; j<section.cellCount; j++)
        {
            SCTableViewCell *cell = [section cellAtIndex:j];
            cell.detailViewHidesBottomBar = self.detailViewHidesBottomBar;
        }
    }
}

// override superclass method
- (SCNavigationBarType)getDetailViewNavigationBarTypeForItem:(NSObject *)item
{
    if([self getClassDefinitionForObject:item].requireEditingModeToEditPropertyValues)
        return SCNavigationBarTypeEditRight;
    //else
    return self.detailViewNavigationBarType;
}

// override superclass method
- (void)addNewItem:(NSObject *)newItem
{
	[items addObject:newItem];
	
	SCClassDefinition *classDef = [self firstClassDefinition];
    if(classDef)
    {
        if(coreDataBound)
        {
            if(classDef.orderAttributeName && [classDef isValidPropertyName:classDef.orderAttributeName])
            {
                // Set the order attribute for the new item
                int order;
                if(items.count == 1) // only item
                {
                    order = 0;
                }
                else
                {
                    NSObject *prevObject = [items objectAtIndex:items.count-2];
                    order = [(NSNumber *)[prevObject valueForKey:classDef.orderAttributeName] intValue];
                    order++;
                }
                [newItem setValue:[NSNumber numberWithInt:order] forKey:classDef.orderAttributeName];
            }
            else
            {
                if(self.itemsPredicate)
                {
                    [self reloadBoundValues];
                }
                else
                {
                    // Sort the items array (if key is sortable)
                    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] 
                                                    initWithKey:classDef.keyPropertyName
                                                    ascending:self.sortItemsSetAscending];
                    @try 
                    {
                        [items sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
                    }
                    @catch (NSException * e) 
                    {
                        // do nothing (do not sort)
                    }
                    @finally 
                    {
                        SC_Release(descriptor);
                    }
                }
            }
        }
    }
	
	NSUInteger sectionIndex = [self.ownerTableViewModel indexForSection:self];
	NSUInteger newItemIndex = [items indexOfObjectIdenticalTo:newItem];
	
	NSIndexPath *newRowIndexPath = [NSIndexPath indexPathForRow:newItemIndex inSection:sectionIndex];
	NSArray *indexPaths = [NSArray arrayWithObject:newRowIndexPath];
    
    [self.ownerTableViewModel clearLastReturnedCellData];
	[self.ownerTableViewModel.modeledTableView beginUpdates];
    if(self.items.count==1 && self.placeholderCell)
        [self.ownerTableViewModel.modeledTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
	[self.ownerTableViewModel.modeledTableView insertRowsAtIndexPaths:indexPaths
													 withRowAnimation:UITableViewRowAnimationBottom];
    [self.ownerTableViewModel.modeledTableView endUpdates];
    
	[self.ownerTableViewModel.modeledTableView scrollToRowAtIndexPath:newRowIndexPath 
													 atScrollPosition:UITableViewScrollPositionNone
															 animated:YES];
	
	[self.ownerTableViewModel.modeledTableView selectRowAtIndexPath:newRowIndexPath animated:TRUE 
													 scrollPosition:UITableViewScrollPositionNone];
	if(!self.autoSelectNewItemCell && !tempCustomDetailModel)
		[self.ownerTableViewModel.modeledTableView deselectRowAtIndexPath:newRowIndexPath animated:TRUE];
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:itemAddedForSectionAtIndexPath:item:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						   itemAddedForSectionAtIndexPath:newRowIndexPath
													 item:newItem];
	}
    
    // Check for custom detail table view model for the newly added item
	SCTableViewModel *detailTableViewModel = [self getCustomDetailModelForRowAtIndexPath:newRowIndexPath];
	if(detailTableViewModel)
	{
		[self didSelectCellAtIndexPath:newRowIndexPath];
	}
	
	// Allow some time for table view animations to finish
    [self performSelector:@selector(callDelegateForDidInsertRowAtIndexPath:) withObject:newRowIndexPath afterDelay:0.2f];
}

// override superclass method
- (void)dispatchRemoveRowAtIndexPathEvent:(NSIndexPath *)indexPath
{
	if(coreDataBound)
	{
#ifdef _COREDATADEFINES_H
		SCClassDefinition *classDef = [self firstClassDefinition];
		NSObject *obj = SC_Retain([self.items objectAtIndex:indexPath.row]);
		
		[super dispatchRemoveRowAtIndexPathEvent:indexPath];
		
		if(self.itemsSet)
			[self.itemsSet removeObject:obj];
		else
			[classDef.managedObjectContext deleteObject:(NSManagedObject *)obj];
        
        SC_Release(obj);
#endif		
	}
	else
		[super dispatchRemoveRowAtIndexPathEvent:indexPath];
}

// override superclass method
- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel
{
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:itemEditedForSectionAtIndexPath:item:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						  itemEditedForSectionAtIndexPath:self.selectedCellIndexPath
													 item:[self.items objectAtIndex:self.selectedCellIndexPath.row]];
	}
	
	if(tempCustomDetailModel) // a custom detail view is defined
	{
		NSArray *indexPaths = [NSArray arrayWithObject:self.selectedCellIndexPath];
		[self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:indexPaths
														 withRowAnimation:UITableViewRowAnimationNone];
		if(tempCustomDetailModel)
		{
			[self.ownerTableViewModel.modeledTableView selectRowAtIndexPath:self.selectedCellIndexPath animated:NO 
															 scrollPosition:UITableViewScrollPositionNone];
		}
	}
}

// override superclass method
- (void)tableViewControllerWillDisappear:(SCTableViewController *)tableViewController
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if(tableViewController.state != SCViewControllerStateDismissed)
		return;
    
	if(cancelTapped)
	{
		if(coreDataBound)
		{
#ifdef _COREDATADEFINES_H			
			if([tempItem isKindOfClass:[NSManagedObject class]])
				[self deleteCoreDataTempObject];
#endif			
		}
		else
			SC_Release(tempItem);
		tempItem = nil;
        
        // call the delegates
        [super tableViewControllerWillDisappear:tableViewController cancelButtonTapped:cancelTapped doneButtonTapped:doneTapped];
        
		return;
	}
	
		
	// Check if tempItem is nil, which would happen if the application enters the background
	// and then comes back to the foreground.
	if(tempItem==nil && !self.selectedCellIndexPath)
	{
		for(int i=0; i<tableViewController.tableViewModel.sectionCount; i++)
		{
			SCTableViewSection *section = [tableViewController.tableViewModel sectionAtIndex:i];
			if(section.boundObject && [section isKindOfClass:[SCObjectSection class]])
			{
				tempItem = SC_Retain(section.boundObject);
				break;
			}
			
		}
		if(!tempItem)
			return;
		
#ifdef _COREDATADEFINES_H
		if([tempItem isKindOfClass:[NSManagedObject class]])
		{
			[[self firstClassDefinition].managedObjectContext insertObject:(NSManagedObject *)tempItem];
		}
#endif
	}

	//looping to include any custom user added sections too
	for(int i=0; i<tableViewController.tableViewModel.sectionCount; i++)
	{
		SCTableViewSection *section = [tableViewController.tableViewModel sectionAtIndex:i];
        [section commitCellChanges];
	}
	
	NSUInteger sectionIndex = [self.ownerTableViewModel indexForSection:self];
	if(self.selectedCellIndexPath)
	{
		[self commitDetailModelChanges:tableViewController.tableViewModel];
	}
	else	// newly added item
	{
		// Must release tempItem here in case user needs to do a [managedObjectContext save:] operation
		// in itemAddedForSectionAtIndexPath or didInsertRowAtIndexPath (see registerWithManagedObjectContextNotifications)
		NSObject *newItem = tempItem;
		tempItem = nil;
		
		if([self.ownerTableViewModel isKindOfClass:[SCArrayOfItemsModel class]])
		{
			// Have model handle the item addition
			[(SCArrayOfItemsModel *)self.ownerTableViewModel addNewItem:newItem];
		}
		else
		{
			[self addNewItem:newItem];
		}
		
		SC_Release(newItem);
	}
	
	SC_Release(tempItem);
	tempItem = nil;
	
	[self.ownerTableViewModel valueChangedForSectionAtIndex:sectionIndex];
    
    
    // call the delegates
    [super tableViewControllerWillDisappear:tableViewController cancelButtonTapped:cancelTapped doneButtonTapped:doneTapped];
}

//override superclass
- (void)tableViewControllerWillAppear:(SCTableViewController *)tableViewController
{
    if(!self.selectedCellIndexPath)  // newly added item
    {
        if(tempItem)
        {
            if([self getClassDefinitionForObject:tempItem].requireEditingModeToEditPropertyValues)
                [tableViewController.tableViewModel setModeledTableViewEditing:TRUE animated:NO];
        }
    }
}

//override superclass
- (void)tableViewControllerDidAppear:(SCTableViewController *)tableViewController
{
    SCTableViewCell *firstCell = [tableViewController.tableViewModel cellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if(!firstCell.valueIsValid)
        [firstCell becomeFirstResponder];
}

//override superclass
- (void)tableViewControllerDidDisappear:(SCTableViewController *)tableViewController 
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if(tableViewController.state != SCViewControllerStateDismissed)
		return;
	
	[super tableViewControllerDidDisappear:tableViewController cancelButtonTapped:cancelTapped
						  doneButtonTapped:doneTapped];
	
	if(self.selectedCellIndexPath)
	{
		[self.ownerTableViewModel.modeledTableView 
		   reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedCellIndexPath]
				withRowAnimation:UITableViewRowAnimationNone];
		
		// Check if the owner model is an SCArrayOfItemsModel
		if([self.ownerTableViewModel isKindOfClass:[SCArrayOfItemsModel class]])
		{
			// Have model handle the item modification
			[(SCArrayOfItemsModel *)self.ownerTableViewModel 
				itemModified:[self.items objectAtIndex:self.selectedCellIndexPath.row]
					inSection:self];
		}
		else 
		{
			[self itemModified:[self.items objectAtIndex:self.selectedCellIndexPath.row]];
		}
	}
    
    
    // call the delegates
    [super tableViewControllerDidDisappear:tableViewController cancelButtonTapped:cancelTapped doneButtonTapped:doneTapped];
}

// overrides superclass
- (void)itemModified:(NSObject *)item
{
	SCClassDefinition *classDef = [self firstClassDefinition];
	if(coreDataBound && classDef && !classDef.orderAttributeName)
	{
		// Sort the items array (if key is sortable)
		NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] 
										initWithKey:classDef.keyPropertyName
										ascending:self.sortItemsSetAscending];
		@try 
		{
			[items sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		}
		@catch (NSException * e) 
		{
			// do nothing (do not sort)
		}
		@finally 
		{
			SC_Release(descriptor);
		}
	}
	NSUInteger oldObjectIndex = self.selectedCellIndexPath.row;
	NSUInteger modifiedObjectIndex = [items indexOfObjectIdenticalTo:item];
	
	if(modifiedObjectIndex != oldObjectIndex)
	{
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:modifiedObjectIndex 
													   inSection:self.selectedCellIndexPath.section];
        [self.ownerTableViewModel clearLastReturnedCellData];
		[self.ownerTableViewModel.modeledTableView beginUpdates];
		[self.ownerTableViewModel.modeledTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedCellIndexPath]
														 withRowAnimation:UITableViewRowAnimationLeft];
		[self.ownerTableViewModel.modeledTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
														 withRowAnimation:UITableViewRowAnimationLeft];
		[self.ownerTableViewModel.modeledTableView endUpdates];
		
		// update selectedCellIndexPath
		self.selectedCellIndexPath = newIndexPath;
	}
	
	if(tempCustomDetailModel)
	{
		[self.ownerTableViewModel.modeledTableView selectRowAtIndexPath:self.selectedCellIndexPath animated:NO 
														 scrollPosition:UITableViewScrollPositionNone];
	}
}

-(void)setItemsSet:(NSMutableSet *)set
{
	SC_Release(itemsSet);
	itemsSet = SC_Retain(set);
	
	[self generateItemsArrayFromItemsSet];
    if(coreDataBound)
        [self callDelegateForCoreDataObjectsLoaded];
}

-(void)setSortItemsSetAscending:(BOOL)ascending
{
	sortItemsSetAscending = ascending;
    
    if(itemsSet)
        [self generateItemsArrayFromItemsSet];
    else
    {
        [self reloadBoundValues];
    }
}

- (SCClassDefinition *)getClassDefinitionForObject:(NSObject *)object
{
	SCClassDefinition *objectClassDef = nil;
	
	if(coreDataBound)
	{
#ifdef _COREDATADEFINES_H		
		NSManagedObject *managedObj = (NSManagedObject *)object;
		objectClassDef = [self.itemsClassDefinitions 
						  valueForKey:[[managedObj entity] name]];
		if(!objectClassDef)
			objectClassDef = [SCClassDefinition definitionWithEntityName:[[managedObj entity] name]
												withManagedObjectContext:[managedObj managedObjectContext]
										 autoGeneratePropertyDefinitions:YES];
#endif		
	}
	else
	{
		objectClassDef = [self.itemsClassDefinitions valueForKey:[NSString stringWithFormat:@"%s",
												 class_getName([object class])]];
		if(!objectClassDef)
			objectClassDef = [SCClassDefinition definitionWithClass:[object class]
									autoGeneratePropertyDefinitions:YES];
	}
	
	return objectClassDef;
}

- (void)generateItemsArrayFromItemsSet
{
	if(!self.itemsSet)
	{
		self.items = nil;
		return;
	}
	
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[self.itemsSet allObjects]]; 
	SCClassDefinition *classDef = [self firstClassDefinition];
    if(classDef)
    {
        NSString *key;
        if(classDef.orderAttributeName)
            key = classDef.orderAttributeName;
        else
            key = classDef.keyPropertyName;
     
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] 
                                        initWithKey:key
                                        ascending:self.sortItemsSetAscending];
        [sortedArray sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        SC_Release(descriptor);
    }
	
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


#ifdef _COREDATADEFINES_H
- (void)registerWithManagedObjectContextNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(willSaveContext) 
												 name:NSManagedObjectContextWillSaveNotification 
											   object:nil];
}

- (void)willSaveContext
{
    if(tempItem && activeDetailModel)
    {
        // commit pending values into tempItem
        for(int i=0; i<activeDetailModel.sectionCount; i++)
        {
            SCTableViewSection *section = [activeDetailModel sectionAtIndex:i];
            if([section isKindOfClass:[SCObjectSection class]])
                [(SCObjectSection *)section commitCellChanges];
        }
        
        // delete tempItem if not valid, otherwise leave it
        if(![(NSManagedObject *)tempItem validateForInsert:nil])
            [self deleteCoreDataTempObject];
    }
}

- (void)deleteCoreDataTempObject
{
	if([tempItem isKindOfClass:[NSManagedObject class]])
	{
		[[self firstClassDefinition].managedObjectContext deleteObject:(NSManagedObject *)tempItem];
		
		tempItem = nil;
	}
}
#endif

@end








@interface SCSelectionSection ()

- (void)buildSelectedItemsIndexesFromString:(NSString *)string;
- (NSString *)buildStringFromSelectedItemsIndexes;

- (void)deselectLastSelectedRow;
- (void)dismissViewController;

@end



@implementation SCSelectionSection

@synthesize allowMultipleSelection;
@synthesize allowNoSelection;
@synthesize maximumSelections;
@synthesize autoDismissViewController;

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object 
				withSelectedIndexPropertyName:(NSString *)propertyName 
				   withItems:(NSArray *)sectionItems
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
									  withBoundObject:object withSelectedIndexPropertyName:propertyName 
											withItems:sectionItems]);
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object withSelectedIndexesPropertyName:(NSString *)propertyName 
				   withItems:(NSArray *)sectionItems allowMultipleSelection:(BOOL)multipleSelection
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
									  withBoundObject:object withSelectedIndexesPropertyName:propertyName 
											withItems:sectionItems 
								allowMultipleSelection:multipleSelection]);
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object 
				withSelectionStringPropertyName:(NSString *)propertyName 
				   withItems:(NSArray *)sectionItems
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
									  withBoundObject:object 
					  withSelectionStringPropertyName:propertyName 
											withItems:sectionItems]);
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				withBoundKey:(NSString *)key 
	  withSelectedIndexValue:(NSNumber *)selectedIndexValue 
				   withItems:(NSArray *)sectionItems
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
										 withBoundKey:key withSelectedIndexValue:selectedIndexValue 
											withItems:sectionItems]);
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
					 withBoundKey:(NSString *)key withSelectedIndexesValue:(NSMutableSet *)selectedIndexesValue 
				   withItems:(NSArray *)sectionItems allowMultipleSelection:(BOOL)multipleSelection
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
											  withBoundKey:key withSelectedIndexesValue:selectedIndexesValue 
											withItems:sectionItems 
								allowMultipleSelection:multipleSelection]);
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				withBoundKey:(NSString *)key 
	withSelectionStringValue:(NSString *)selectionStringValue 
				   withItems:(NSArray *)sectionItems
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
										 withBoundKey:key withSelectionStringValue:selectionStringValue
											withItems:sectionItems]);
}

- (id)init
{
	if( (self=[super init]) )
	{
		boundToNSNumber = FALSE;
		boundToNSString = FALSE;
		lastSelectedRowIndexPath = nil;
		itemsAccessoryType = UITableViewCellAccessoryCheckmark;
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

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object 
			withSelectedIndexPropertyName:(NSString *)propertyName 
				withItems:(NSArray *)sectionItems
{
	if([self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]])
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

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object withSelectedIndexesPropertyName:(NSString *)propertyName 
				withItems:(NSArray *)sectionItems allowMultipleSelection:(BOOL)multipleSelection
{
	if([self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]])
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

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object 
			withSelectionStringPropertyName:(NSString *)propertyName 
				withItems:(NSArray *)sectionItems
{
	if([self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]])
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

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundKey:(NSString *)key 
   withSelectedIndexValue:(NSNumber *)selectedIndexValue 
				withItems:(NSArray *)sectionItems
{
	if( (self=[self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]]) )
	{
		boundKey = [key copy];
		self.boundValue = selectedIndexValue;
		boundToNSNumber = TRUE;
		allowMultipleSelection = FALSE;
		
		[self reloadBoundValues];
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundKey:(NSString *)key withSelectedIndexesValue:(NSMutableSet *)selectedIndexesValue 
				withItems:(NSArray *)sectionItems allowMultipleSelection:(BOOL)multipleSelection
{
	if( (self=[self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]]) )
	{
		boundKey = [key copy];
		self.boundValue = selectedIndexesValue;
		allowMultipleSelection = multipleSelection;
		
		[self reloadBoundValues];
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundKey:(NSString *)key 
 withSelectionStringValue:(NSString *)selectionStringValue 
				withItems:(NSArray *)sectionItems
{
	if( (self=[self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]]) )
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
	[_selectedItemsIndexes release];
	[lastSelectedRowIndexPath release];
	[super dealloc];
}
#endif

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

//overrides superclass
- (void)setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCSelectionAttributes class]])
		return;
	
	SCSelectionAttributes *selectionAttributes = (SCSelectionAttributes *)attributes;
	if(selectionAttributes.items)
		self.items = [NSMutableArray arrayWithArray:selectionAttributes.items];
	self.allowMultipleSelection = selectionAttributes.allowMultipleSelection;
	self.allowNoSelection = selectionAttributes.allowNoSelection;
	self.maximumSelections = selectionAttributes.maximumSelections;
	self.allowAddingItems = selectionAttributes.allowAddingItems;
    self.allowDeletingItems = selectionAttributes.allowDeletingItems;
    self.allowMovingItems = selectionAttributes.allowMovingItems;
    self.allowEditDetailView = selectionAttributes.allowEditingItems;
    self.autoDismissViewController = selectionAttributes.autoDismissDetailView;
    if([selectionAttributes.placeholderuiElement isKindOfClass:[SCTableViewCell class]])
        self.placeholderCell = (SCTableViewCell *)selectionAttributes.placeholderuiElement;
    if([selectionAttributes.addNewObjectuiElement isKindOfClass:[SCTableViewCell class]])
        self.addNewItemCell = (SCTableViewCell *)selectionAttributes.addNewObjectuiElement;
}

// override superclass method
- (SCTableViewCell *)cellAtIndex:(NSUInteger)index
{
	SCTableViewCell *cell = [super cellAtIndex:index];
	
	if([self.selectedItemsIndexes containsObject:[NSNumber numberWithInt:index]])
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
	
	return cell;
}

- (void)deselectLastSelectedRow
{
	[self.ownerTableViewModel.modeledTableView deselectRowAtIndexPath:lastSelectedRowIndexPath
															 animated:YES];
}

// override superclass method
- (void)dispatchRemoveRowAtIndexPathEvent:(NSIndexPath *)indexPath
{
    [super dispatchRemoveRowAtIndexPathEvent:indexPath];
    
    //deselect removed row
    NSNumber *itemIndex = [NSNumber numberWithInt:indexPath.row];
    [self.selectedItemsIndexes removeObject:itemIndex];
    if(boundToNSNumber)
        self.boundValue = self.selectedItemIndex;
    else
        if(boundToNSString)
            self.boundValue = [self buildStringFromSelectedItemsIndexes];
}

- (void)moveCellAtIndexPath:(NSIndexPath *)fromIndexPath 
				toIndexPath:(NSIndexPath *)toIndexPath
{
    [super moveCellAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    
    // Update the selectedItemsIndexes with the new index value
    NSNumber *oldItemIndex = [NSNumber numberWithInt:fromIndexPath.row];
    NSNumber *newItemIndex = [NSNumber numberWithInt:toIndexPath.row];
    [self.selectedItemsIndexes removeObject:oldItemIndex];
    [self.selectedItemsIndexes addObject:newItemIndex];
    if(boundToNSNumber)
        self.boundValue = self.selectedItemIndex;
    else
        if(boundToNSString)
            self.boundValue = [self buildStringFromSelectedItemsIndexes];
}

// override superclass method
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCellIndexPath = indexPath;
	
    [self dispatchSelectRowAtIndexPathEvent:indexPath];
}

// override superclass method
- (void)dispatchSelectRowAtIndexPathEvent:(NSIndexPath *)indexPath
{	
    if([self addNewItemCellExists] && indexPath.row==(self.cellCount-1))
    {
        [self dispatchAddNewItemEvent];
        return;
    }
    
    if(self.allowEditDetailView && self.ownerTableViewModel.modeledTableView.editing)
    {
        [super dispatchSelectRowAtIndexPathEvent:indexPath];
        return;
    }
    
	UITableView *tableView = self.ownerTableViewModel.modeledTableView;
	NSNumber *itemIndex = [NSNumber numberWithInt:indexPath.row];
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
		[self.ownerTableViewModel valueChangedForSectionAtIndex:indexPath.section];
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
		//uncheck old cell
		NSUInteger oldRowIndex =  [(NSNumber *)[self.selectedItemsIndexes anyObject] intValue];
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldRowIndex inSection:indexPath.section];
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
	
	[self.ownerTableViewModel valueChangedForSectionAtIndex:indexPath.section];
	
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
	if([self.ownerTableViewModel.viewController isKindOfClass:[SCTableViewController class]])
	{
		[(SCTableViewController *)self.ownerTableViewModel.viewController 
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










@interface SCObjectSelectionSection ()

- (NSMutableSet *)boundMutableSet;
- (void)deselectLastSelectedRow;
- (void)dismissViewController;

- (void)selectedItemsIndexesModified;

@end



@implementation SCObjectSelectionSection

@synthesize selectedItemsIndexes;
@synthesize allowMultipleSelection;
@synthesize allowNoSelection;
@synthesize maximumSelections;
@synthesize autoDismissViewController;
@synthesize intermediateEntityClassDefinition;


+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
             withBoundObject:(NSObject *)object withSelectedObjectPropertyName:(NSString *)propertyName
                   withItems:(NSArray *)sectionItems withItemsClassDefintion:(SCClassDefinition *)classDefinition
{
	return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
									  withBoundObject:object withSelectedObjectPropertyName:propertyName 
											withItems:sectionItems withItemsClassDefintion:classDefinition]);
}

- (id)init
{
	if( (self=[super init]) )
	{
		lastSelectedRowIndexPath = nil;
		itemsAccessoryType = UITableViewCellAccessoryCheckmark;
		allowAddingItems = FALSE;
		allowDeletingItems = FALSE;
		allowMovingItems = FALSE;
		allowEditDetailView = FALSE;
		
		allowMultipleSelection = FALSE;
		allowNoSelection = FALSE;
		maximumSelections = 0;
		autoDismissViewController = FALSE;
		selectedItemsIndexes = [[NSMutableSet alloc] init];
	}
	
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
          withBoundObject:(NSObject *)object withSelectedObjectPropertyName:(NSString *)propertyName
                withItems:(NSArray *)sectionItems withItemsClassDefintion:(SCClassDefinition *)classDefinition
{
	if([self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]])
    {
        boundObject = SC_Retain(object);
#ifdef _COREDATADEFINES_H	
        if([boundObject isKindOfClass:[NSManagedObject class]])
            coreDataBound = TRUE;
#endif
        
        // Only bind property name if property exists
		BOOL propertyExists;
		@try { [SCHelper valueForPropertyName:propertyName inObject:self.boundObject]; propertyExists = TRUE; }
		@catch (NSException *exception) { propertyExists = FALSE; }
		if(propertyExists)
			boundPropertyName = [propertyName copy];
        
        if(classDefinition)
            [self.itemsClassDefinitions setValue:classDefinition forKey:classDefinition.className];
        
        if([self.boundValue isKindOfClass:[NSMutableSet class]])
            allowMultipleSelection = TRUE;
        else
            allowMultipleSelection = FALSE;
        
        // Synchronize selectedItemsIndexes
        [self reloadBoundValues];
    }
    return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
    [selectedItemsIndexes release];
	[lastSelectedRowIndexPath release];
	[super dealloc];
}
#endif

- (NSMutableSet *)boundMutableSet
{
    if(!coreDataBound)
        return (NSMutableSet *)self.boundValue;
    
    NSMutableSet *set = nil;

#ifdef _COREDATADEFINES_H	
    set = [(NSManagedObject *)self.boundObject mutableSetValueForKey:self.boundPropertyName];
#endif	
    
    return set;
}

- (void)selectedItemsIndexesModified
{
    if(self.commitCellChangesLive)
        [self commitCellChanges];
}

//overrides superclass
- (void)setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCObjectSelectionAttributes class]])
		return;
	
	SCObjectSelectionAttributes *objectSelectionAttributes = (SCObjectSelectionAttributes *)attributes;
    
#ifdef _COREDATADEFINES_H	
	if(objectSelectionAttributes.itemsEntityClassDefinition.entity)
	{
		self.items = [SCHelper generateObjectsArrayForEntityClassDefinition:objectSelectionAttributes.itemsEntityClassDefinition
															 usingPredicate:objectSelectionAttributes.itemsPredicate ascending:YES];
	}
#endif	
    if(objectSelectionAttributes.itemsEntityClassDefinition)
        [self.itemsClassDefinitions setValue:objectSelectionAttributes.itemsEntityClassDefinition forKey:objectSelectionAttributes.itemsEntityClassDefinition.className];
    self.intermediateEntityClassDefinition = objectSelectionAttributes.intermediateEntityClassDefinition;
    
    self.allowMultipleSelection = objectSelectionAttributes.allowMultipleSelection;
	self.allowNoSelection = objectSelectionAttributes.allowNoSelection;
	self.maximumSelections = objectSelectionAttributes.maximumSelections;
	self.allowAddingItems = objectSelectionAttributes.allowAddingItems;
    self.allowDeletingItems = objectSelectionAttributes.allowDeletingItems;
    self.allowMovingItems = objectSelectionAttributes.allowMovingItems;
    self.allowEditDetailView = objectSelectionAttributes.allowEditingItems;
    self.autoDismissViewController = objectSelectionAttributes.autoDismissDetailView;
    if([objectSelectionAttributes.placeholderuiElement isKindOfClass:[SCTableViewCell class]])
        self.placeholderCell = (SCTableViewCell *)objectSelectionAttributes.placeholderuiElement;
    if([objectSelectionAttributes.addNewObjectuiElement isKindOfClass:[SCTableViewCell class]])
        self.addNewItemCell = (SCTableViewCell *)objectSelectionAttributes.addNewObjectuiElement;
    
    // Synchronize selectedItemsIndexes
    [self reloadBoundValues];
}

// override superclass method
- (void)reloadBoundValues
{
    [super reloadBoundValues];
    
    // Synchronize selectedItemsIndexes
    [self.selectedItemsIndexes removeAllObjects];
    if(self.allowMultipleSelection)
    {
        NSMutableSet *boundSet = [self boundMutableSet];  //optimize
        for(NSObject *obj in boundSet)
        {
            int index = [self.items indexOfObjectIdenticalTo:obj];
            if(index != NSNotFound)
                [self.selectedItemsIndexes addObject:[NSNumber numberWithInt:index]];
        }
    }
    else
    {
        NSObject *selectedObject = [SCHelper valueForPropertyName:self.boundPropertyName inObject:self.boundObject];
        int index = [self.items indexOfObjectIdenticalTo:selectedObject];
        if(index != NSNotFound)
            [self.selectedItemsIndexes addObject:[NSNumber numberWithInt:index]];
    }
}

- (void)commitCellChanges
{
    [super commitCellChanges];
    
    if(self.allowMultipleSelection)
    {
        NSMutableSet *boundValueSet = [self boundMutableSet];
        [boundValueSet removeAllObjects];
        for(NSNumber *index in self.selectedItemsIndexes)
        {
            [boundValueSet addObject:[self.items objectAtIndex:[index intValue]]];
        }
    }
	else
	{
		NSObject *selectedObject = nil;
		int index = [self.selectedItemIndex intValue];
		if(index >= 0)
			selectedObject = [self.items objectAtIndex:index];
		
		self.boundValue = selectedObject;
	}
}

// override superclass method
- (SCTableViewCell *)cellAtIndex:(NSUInteger)index
{
	SCTableViewCell *cell = [super cellAtIndex:index];
	
	if([self.selectedItemsIndexes containsObject:[NSNumber numberWithInt:index]])
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
	
	return cell;
}

- (void)deselectLastSelectedRow
{
	[self.ownerTableViewModel.modeledTableView deselectRowAtIndexPath:lastSelectedRowIndexPath
															 animated:YES];
}

// override superclass method
- (void)dispatchRemoveRowAtIndexPathEvent:(NSIndexPath *)indexPath
{
    [super dispatchRemoveRowAtIndexPathEvent:indexPath];
    
    //deselect removed row
    NSNumber *itemIndex = [NSNumber numberWithInt:indexPath.row];
    [self.selectedItemsIndexes removeObject:itemIndex];
    [self selectedItemsIndexesModified];
}

// override superclass method
- (void)moveCellAtIndexPath:(NSIndexPath *)fromIndexPath 
				toIndexPath:(NSIndexPath *)toIndexPath
{
    [super moveCellAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    
    // Update the selectedItemsIndexes with the new index value
    NSNumber *oldItemIndex = [NSNumber numberWithInt:fromIndexPath.row];
    NSNumber *newItemIndex = [NSNumber numberWithInt:toIndexPath.row];
    [self.selectedItemsIndexes removeObject:oldItemIndex];
    [self.selectedItemsIndexes addObject:newItemIndex];
    [self selectedItemsIndexesModified];
}

// override superclass method
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCellIndexPath = indexPath;
	
    [self dispatchSelectRowAtIndexPathEvent:indexPath];
}

// override superclass method
- (void)dispatchSelectRowAtIndexPathEvent:(NSIndexPath *)indexPath
{	
    if([self addNewItemCellExists] && indexPath.row==(self.cellCount-1))
    {
        [self dispatchAddNewItemEvent];
        return;
    }
    
    if(self.allowEditDetailView && self.ownerTableViewModel.modeledTableView.editing)
    {
        [super dispatchSelectRowAtIndexPathEvent:indexPath];
        return;
    }
    
	UITableView *tableView = self.ownerTableViewModel.modeledTableView;
	NSNumber *itemIndex = [NSNumber numberWithInt:indexPath.row];
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
        [self selectedItemsIndexesModified];
		
		selectedCell.accessoryType = UITableViewCellAccessoryNone;
		selectedCell.textLabel.textColor = [UIColor blackColor];
		[self.ownerTableViewModel valueChangedForSectionAtIndex:indexPath.section];
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
		//uncheck old cell
		NSUInteger oldRowIndex =  [(NSNumber *)[self.selectedItemsIndexes anyObject] intValue];
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldRowIndex inSection:indexPath.section];
		[self.selectedItemsIndexes removeAllObjects];
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
		oldCell.textLabel.textColor = [UIColor blackColor];
	}
	
	//check selected cell
	[self.selectedItemsIndexes addObject:itemIndex];
	[self selectedItemsIndexesModified];
    
	selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
	selectedCell.textLabel.textColor = [UIColor colorWithRed:50.0f/255 green:79.0f/255 blue:133.0f/255 alpha:1];
	
	[self.ownerTableViewModel valueChangedForSectionAtIndex:indexPath.section];
	
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
	if([self.ownerTableViewModel.viewController isKindOfClass:[SCTableViewController class]])
	{
		[(SCTableViewController *)self.ownerTableViewModel.viewController 
		 dismissWithCancelValue:FALSE doneValue:TRUE];
	}
}

- (void)setSelectedItemIndex:(NSNumber *)number
{
	NSNumber *num = [number copy];
	
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








