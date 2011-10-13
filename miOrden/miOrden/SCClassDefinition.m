/*
 *  SCClassDefinition.m
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

#import "SCClassDefinition.h"
#import "SCGlobals.h"
#import <objc/runtime.h>

@implementation SCPropertyDefinition

@synthesize ownerClassDefinition;
@synthesize dataType;
@synthesize dataReadOnly;
@synthesize name;
@synthesize title;
@synthesize type;
@synthesize attributes;
@synthesize editingModeType;
@synthesize editingModeAttributes;
@synthesize required;
@synthesize autoValidate;
@synthesize existsInNormalMode;
@synthesize existsInEditingMode;
@synthesize existsInCreationMode;
@synthesize existsInDetailMode;

+ (id)definitionWithName:(NSString *)propertyName
{
	return SC_Autorelease([[[self class] alloc] initWithName:propertyName]);
}

+ (id)definitionWithName:(NSString *)propertyName 
				   title:(NSString *)propertyTitle
					type:(SCPropertyType)propertyType
{
	return SC_Autorelease([[[self class] alloc] initWithName:propertyName title:propertyTitle type:propertyType]);
}

- (id)initWithName:(NSString *)propertyName
{
	return [self initWithName:propertyName title:nil type:SCPropertyTypeAutoDetect];
}

- (id)initWithName:(NSString *)propertyName 
			 title:(NSString *)propertyTitle
			  type:(SCPropertyType)propertyType
{
	if( (self=[super init]) )
	{
		ownerClassDefinition = nil;
		
		dataType = SCPropertyDataTypeOther;
		dataReadOnly = FALSE;
		
		name = [propertyName copy];
		self.title = propertyTitle;
		self.type = propertyType;
		self.attributes = nil;
		self.editingModeType = SCPropertyTypeUndefined;
		self.editingModeAttributes = nil;
		self.required = FALSE;
		self.autoValidate = TRUE;
        self.existsInNormalMode = TRUE;
        self.existsInEditingMode = TRUE;
        self.existsInCreationMode = TRUE;
        self.existsInDetailMode = TRUE;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[name release];
	[title release];
	[attributes release];
	[editingModeAttributes release];
	
	[super dealloc];
}
#endif

@end






@implementation SCCustomPropertyDefinition

@synthesize uiElement;
@synthesize uiElementClass;
@synthesize uiElementNibName;
@synthesize objectBindings;

+ (id)definitionWithName:(NSString *)propertyName 
		   withuiElement:(NSObject *)element
	  withObjectBindings:(NSDictionary *)bindings
{
	return SC_Autorelease([[[self class] alloc] initWithName:propertyName withuiElement:element withObjectBindings:bindings]);
}

+ (id)definitionWithName:(NSString *)propertyName 
      withuiElementClass:(Class)elementClass
	  withObjectBindings:(NSDictionary *)bindings
{
	return SC_Autorelease([[[self class] alloc] initWithName:propertyName withuiElementClass:elementClass withObjectBindings:bindings]);
}

+ (id)definitionWithName:(NSString *)propertyName 
	withuiElementNibName:(NSString *)elementNibName
	  withObjectBindings:(NSDictionary *)bindings
{
	return SC_Autorelease([[[self class] alloc] initWithName:propertyName withuiElementNibName:elementNibName withObjectBindings:bindings]);
}

//overrides superclass
- (id)initWithName:(NSString *)propertyName
{
    if( (self = [super initWithName:propertyName]) )
    {
        uiElement = nil;
        uiElementNibName = nil;
    }
    
    return self;
}

- (id)initWithName:(NSString *)propertyName 
	 withuiElement:(NSObject *)element
withObjectBindings:(NSDictionary *)bindings
{
	self = [self initWithName:propertyName withuiElementClass:[element class] withObjectBindings:bindings];
	
	return self;
}

- (id)initWithName:(NSString *)propertyName 
	 withuiElementClass:(Class)elementClass
withObjectBindings:(NSDictionary *)bindings
{
	if( (self = [self initWithName:propertyName]) )
	{
		uiElementClass = elementClass;
		self.objectBindings = bindings;
	}
	
	return self;
}

- (id)initWithName:(NSString *)propertyName 
	withuiElementNibName:(NSString *)elementNibName
	withObjectBindings:(NSDictionary *)bindings
{
	if( (self = [self initWithName:propertyName]) )
	{
		self.uiElementNibName = elementNibName;
		self.objectBindings = bindings;
	}
	
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[uiElement release];
    [uiElementNibName release];
	[objectBindings release];
	
	[super dealloc];
}
#endif

@end







@implementation SCPropertyGroup

@synthesize headerTitle;
@synthesize footerTitle;


+ (id)groupWithHeaderTitle:(NSString *)groupHeaderTitle withFooterTitle:(NSString *)groupFooterTitle
         withPropertyNames:(NSArray *)propertyNames
{
    return SC_Autorelease([[[self class] alloc] initWithHeaderTitle:groupHeaderTitle withFooterTitle:groupFooterTitle withPropertyNames:propertyNames]);
}

- (id)init
{
	if( (self=[super init]) )
	{
		headerTitle = nil;
        footerTitle = nil;
        propertyDefinitionNames = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)groupHeaderTitle withFooterTitle:(NSString *)groupFooterTitle
       withPropertyNames:(NSArray *)propertyNames
{
    if( (self=[self init]) )
	{
		self.headerTitle = groupHeaderTitle;
        self.footerTitle = groupFooterTitle;
        [propertyDefinitionNames addObjectsFromArray:propertyNames];
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
    [propertyDefinitionNames release];
    
    [super dealloc];
}
#endif

- (NSInteger)propertyNameCount
{
    return [propertyDefinitionNames count];
}

- (void)addPropertyName:(NSString *)propertyName
{
    [propertyDefinitionNames addObject:propertyName];
}

- (void)insertPropertyName:(NSString *)propertyName atIndex:(NSInteger)index
{
    [propertyDefinitionNames insertObject:propertyName atIndex:index];
}

- (NSString *)propertyNameAtIndex:(NSInteger)index
{
    return [propertyDefinitionNames objectAtIndex:index];
}

- (void)removePropertyNameAtIndex:(NSInteger)index
{
    [propertyDefinitionNames removeObjectAtIndex:index];
}

- (void)removeAllPropertyNames
{
    [propertyDefinitionNames removeAllObjects];
}

- (BOOL)containsPropertyName:(NSString *)propertyName
{
    return [propertyDefinitionNames containsObject:propertyName];
}


@end




@implementation SCPropertyGroupArray

- (id)init
{
	if( (self=[super init]) )
	{
		propertyGroups = [[NSMutableArray alloc] init];
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
    [propertyGroups release];
    
    [super dealloc];
}
#endif

- (NSInteger)groupCount
{
    return [propertyGroups count];
}

- (void)addGroup:(SCPropertyGroup *)group
{
    [propertyGroups addObject:group];
}

- (void)insertGroup:(SCPropertyGroup *)group atIndex:(NSInteger)index
{
    [propertyGroups insertObject:group atIndex:index];
}

- (SCPropertyGroup *)groupAtIndex:(NSInteger)index
{
    return [propertyGroups objectAtIndex:index];
}

- (void)removeGroupAtIndex:(NSInteger)index
{
    [propertyGroups removeObjectAtIndex:index];
}

- (void)removeAllGroups
{
    [propertyGroups removeAllObjects];
}

@end






@interface SCClassDefinition ()

- (NSString *)getUserFriendlyPropertyTitleFromName:(NSString *)propertyName;

@end


@implementation SCClassDefinition

@synthesize cls;

#ifdef _COREDATADEFINES_H
@synthesize entity;
@synthesize managedObjectContext;
#endif

@synthesize requireEditingModeToEditPropertyValues;
@synthesize keyPropertyName;
@synthesize titlePropertyName;
@synthesize titlePropertyNameDelimiter;
@synthesize descriptionPropertyName;
@synthesize orderAttributeName;
@synthesize uiElementDelegate;
@synthesize defaultPropertyGroup;
@synthesize propertyGroups;


+ (id) definitionWithClass:(Class)_cls autoGeneratePropertyDefinitions:(BOOL)autoGenerate
{
	return SC_Autorelease([[[self class] alloc] initWithClass:_cls autoGeneratePropertyDefinitions:autoGenerate]);
}

+ (id) definitionWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
{
	return SC_Autorelease([[[self class] alloc] initWithClass:_cls withPropertyNames:propertyNames]);
}

+ (id) definitionWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
		 withPropertyTitles:(NSArray *)propertyTitles
{
	return SC_Autorelease([[[self class] alloc] initWithClass:_cls withPropertyNames:propertyNames withPropertyTitles:propertyTitles]);
}

+ (id)definitionWithClass:(Class)_cls withPropertyGroups:(SCPropertyGroupArray *)groups
{
    return SC_Autorelease([[[self class] alloc] initWithClass:_cls withPropertyGroups:groups]);
}


#ifdef _COREDATADEFINES_H
+ (id)definitionWithEntityName:(NSString *)entityName 
	  withManagedObjectContext:(NSManagedObjectContext *)context
		autoGeneratePropertyDefinitions:(BOOL)autoGenerate
{
	return SC_Autorelease([[[self class] alloc] initWithEntityName:entityName
							withManagedObjectContext:context
					 autoGeneratePropertyDefinitions:autoGenerate]);
}

+ (id)definitionWithEntityName:(NSString *)entityName 
	  withManagedObjectContext:(NSManagedObjectContext *)context
			 withPropertyNames:(NSArray *)propertyNames
{
	return SC_Autorelease([[[self class] alloc] initWithEntityName:entityName
							withManagedObjectContext:context
								   withPropertyNames:propertyNames]);
}

+ (id)definitionWithEntityName:(NSString *)entityName
	  withManagedObjectContext:(NSManagedObjectContext *)context
			 withPropertyNames:(NSArray *)propertyNames
			withPropertyTitles:(NSArray *)propertyTitles
{
	return SC_Autorelease([[[self class] alloc] initWithEntityName:entityName
							withManagedObjectContext:context
								   withPropertyNames:propertyNames
								  withPropertyTitles:propertyTitles]);
}

+ (id)definitionWithEntityName:(NSString *)entityName 
	  withManagedObjectContext:(NSManagedObjectContext *)context
            withPropertyGroups:(SCPropertyGroupArray *)groups
{
    return SC_Autorelease([[[self class] alloc] initWithEntityName:entityName
							withManagedObjectContext:context
                                  withPropertyGroups:groups]);
}
#endif

+ (SCPropertyDataType)propertyDataTypeForPropertyWithName:(NSString *)propertyName inObject:(NSObject *)object
{
	SCPropertyDataType dataType = SCPropertyDataTypeOther;
	
#ifdef _COREDATADEFINES_H
	if([object isKindOfClass:[NSManagedObject class]])
	{
		NSEntityDescription *entity = [(NSManagedObject *)object entity];
		NSPropertyDescription *propertyDescription = [[entity propertiesByName] valueForKey:propertyName];
		
		if(propertyDescription)
		{
			if([propertyDescription isKindOfClass:[NSAttributeDescription class]])
			{
				NSAttributeDescription *attribute = (NSAttributeDescription *)propertyDescription;
				switch ([attribute attributeType]) 
				{
					case NSInteger16AttributeType:
					case NSInteger32AttributeType:
					case NSInteger64AttributeType:
						dataType = SCPropertyDataTypeNSNumber;
						break;
						
					case NSDecimalAttributeType:
					case NSDoubleAttributeType:
					case NSFloatAttributeType:
						dataType = SCPropertyDataTypeNSNumber;
						break;
						
					case NSStringAttributeType:
						dataType = SCPropertyDataTypeNSString;
						break;
						
					case NSBooleanAttributeType:
						dataType = SCPropertyDataTypeNSNumber;
						break;
						
					case NSDateAttributeType:
						dataType = SCPropertyDataTypeNSDate;
						break;
						
					case NSTransformableAttributeType:
						dataType = SCPropertyDataTypeTransformable;
						break;
						
					default:
						dataType = SCPropertyDataTypeOther;
						break;
				}
			}
		}
	}
	else
	{
#endif
		objc_property_t property = class_getProperty([object class], [propertyName UTF8String]);
		if(!property)
			return SCPropertyDataTypeOther;
		NSArray *attributesArray = [[NSString stringWithUTF8String: property_getAttributes(property)] 
									componentsSeparatedByString:@","];
		NSSet *attributesSet = [NSSet setWithArray:attributesArray];
		
		if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
										  [NSString stringWithUTF8String:class_getName([NSString class])]]])
			dataType = SCPropertyDataTypeNSString;
		else
			if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
											  [NSString stringWithUTF8String:class_getName([NSNumber class])]]])
				dataType = SCPropertyDataTypeNSNumber;
			else
				if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
												  [NSString stringWithUTF8String:class_getName([NSDate class])]]])
					dataType = SCPropertyDataTypeNSDate;
				else
					if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
													  [NSString stringWithUTF8String:class_getName([NSMutableSet class])]]])
						dataType = SCPropertyDataTypeNSMutableSet;
					else
						if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
														  [NSString stringWithUTF8String:class_getName([NSMutableArray class])]]])
							dataType = SCPropertyDataTypeNSMutableArray;
#ifdef _COREDATADEFINES_H
	}
#endif
	
	return dataType;
}


- (id) init
{
	if( (self = [super init]) )
	{
#ifdef _COREDATADEFINES_H		
		entity = nil;
		managedObjectContext = nil;
#endif		
		
		propertyDefinitions = [[NSMutableArray alloc] init];
        requireEditingModeToEditPropertyValues = FALSE;
		keyPropertyName = nil;
		titlePropertyName = nil;
		titlePropertyNameDelimiter = @" ";
		descriptionPropertyName = nil;
		orderAttributeName = nil;
		uiElementDelegate = nil;
        
        defaultPropertyGroup = [[SCPropertyGroup alloc] init];
        propertyGroups = [[SCPropertyGroupArray alloc] init];
	}
	return self;
}

- (id) initWithClass:(Class)_cls autoGeneratePropertyDefinitions:(BOOL)autoGenerate
{
	if( (self=[self init]) )
	{
		cls = _cls;
		
		if(autoGenerate)
		{
			unsigned int count = 0;
			objc_property_t *properties = class_copyPropertyList(self.cls, &count);
			for (unsigned int i = 0; i < count; i++ )
			{	
				NSString *propertyName = [NSString stringWithUTF8String: property_getName(properties[i])];
				[self addPropertyDefinitionWithName:propertyName 
											  title:[self getUserFriendlyPropertyTitleFromName:propertyName] 
											   type:SCPropertyTypeAutoDetect];
			}
			free(properties);
		}
		
		// Set self.titlePropertyName to the first property
		if(self.propertyDefinitionCount)
			self.titlePropertyName = [self propertyDefinitionAtIndex:0].name;
	}
	
	return self;
}

- (id) initWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
{
	return [self initWithClass:_cls withPropertyNames:propertyNames withPropertyTitles:nil];
}

- (id) initWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
   withPropertyTitles:(NSArray *)propertyTitles
{
	if( (self=[self initWithClass:_cls autoGeneratePropertyDefinitions:NO]) )
	{
		for(int i=0; i<propertyNames.count; i++)
		{
			NSString *propertyName = [propertyNames objectAtIndex:i];
			NSString *propertyTitle;
			if(i < propertyTitles.count)
				propertyTitle = [propertyTitles objectAtIndex:i];
			else
				propertyTitle = [self getUserFriendlyPropertyTitleFromName:propertyName];
			[self addPropertyDefinitionWithName:propertyName
										  title:propertyTitle
										   type:SCPropertyTypeAutoDetect];
		}
		
		// Set self.titlePropertyName to the first property
		if(self.propertyDefinitionCount)
			self.titlePropertyName = [self propertyDefinitionAtIndex:0].name;
		
		self.descriptionPropertyName = nil;
	}
	
	return self;
}

- (id)initWithClass:(Class)_cls withPropertyGroups:(SCPropertyGroupArray *)groups
{
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
    for(NSInteger i=0; i<groups.groupCount; i++)
    {
        SCPropertyGroup *propertyGroup = [groups groupAtIndex:i];
        for(NSInteger j=0; j<propertyGroup.propertyNameCount; j++)
            [propertyNames addObject:[propertyGroup propertyNameAtIndex:j]];
    }
    
    if( (self=[self initWithClass:_cls withPropertyNames:propertyNames]) )
    {
        for(NSInteger i=0; i<groups.groupCount; i++)
        {
            [self.propertyGroups addGroup:[groups groupAtIndex:i]];
        }
    }
    SC_Release(propertyNames);
    
    return self;
}

#ifdef _COREDATADEFINES_H
- (id)initWithEntityName:(NSString *)entityName 
	withManagedObjectContext:(NSManagedObjectContext *)context
		autoGeneratePropertyDefinitions:(BOOL)autoGenerate
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName
														 inManagedObjectContext:context];
	
	if(!autoGenerate)
	{
		self = [self init];
		managedObjectContext = SC_Retain(context);
		entity = SC_Retain(entityDescription);
		return self;
	}
	//else
	
	NSMutableArray *propertyNames = [NSMutableArray arrayWithCapacity:entityDescription.properties.count];
	for(NSPropertyDescription *propertyDescription in entityDescription.properties)
	{
		[propertyNames addObject:[propertyDescription name]];
	}
	return [self initWithEntityName:entityName withManagedObjectContext:context
				  withPropertyNames:propertyNames];
}

- (id)initWithEntityName:(NSString *)entityName 
withManagedObjectContext:(NSManagedObjectContext *)context
	   withPropertyNames:(NSArray *)propertyNames
{
	return [self initWithEntityName:entityName withManagedObjectContext:context
				  withPropertyNames:propertyNames withPropertyTitles:nil];
}

- (id)initWithEntityName:(NSString *)entityName
withManagedObjectContext:(NSManagedObjectContext *)context
	   withPropertyNames:(NSArray *)propertyNames
	  withPropertyTitles:(NSArray *)propertyTitles
{
	if( (self = [self init]) )
	{
		managedObjectContext = SC_Retain(context);
		entity = SC_Retain([NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext]);
		
		for(int i=0; i<propertyNames.count; i++)
		{
			NSString *propertyName = [propertyNames objectAtIndex:i];
			NSString *propertyTitle;
			if(i < propertyTitles.count)
				propertyTitle = [propertyTitles objectAtIndex:i];
			else
				propertyTitle = [self getUserFriendlyPropertyTitleFromName:propertyName];
			NSPropertyDescription *propertyDescription = 
				[[self.entity propertiesByName] valueForKey:propertyName];
			
			if(propertyDescription)
			{
				SCPropertyDefinition *propertyDef = [SCPropertyDefinition 
													 definitionWithName:propertyName
													 title:propertyTitle
													 type:SCPropertyTypeUndefined];
				propertyDef.required = ![propertyDescription isOptional];
				
				if([propertyDescription isKindOfClass:[NSAttributeDescription class]])
				{
					NSAttributeDescription *attribute = (NSAttributeDescription *)propertyDescription;
					switch ([attribute attributeType]) 
					{
						case NSInteger16AttributeType:
						case NSInteger32AttributeType:
						case NSInteger64AttributeType:
							propertyDef.dataType = SCPropertyDataTypeNSNumber;
							propertyDef.type = SCPropertyTypeNumericTextField;
							propertyDef.attributes = [SCNumericTextFieldAttributes 
													  attributesWithMinimumValue:nil 
													  maximumValue:nil 
													  allowFloatValue:FALSE];
							break;

						case NSDecimalAttributeType:
						case NSDoubleAttributeType:
						case NSFloatAttributeType:
							propertyDef.dataType = SCPropertyDataTypeNSNumber;
							propertyDef.type = SCPropertyTypeNumericTextField;
							break;
							
						case NSStringAttributeType:
							propertyDef.dataType = SCPropertyDataTypeNSString;
							propertyDef.type = SCPropertyTypeTextField;
							break;
							
						case NSBooleanAttributeType:
							propertyDef.dataType = SCPropertyDataTypeNSNumber;
							propertyDef.type = SCPropertyTypeSwitch;
							break;

						case NSDateAttributeType:
							propertyDef.dataType = SCPropertyDataTypeNSDate;
							propertyDef.type = SCPropertyTypeDate;
							break;
							
					
						default:
							propertyDef.type = SCPropertyTypeNone;
							break;
					}
				}
				else
					if([propertyDescription isKindOfClass:[NSRelationshipDescription class]])
					{
						NSRelationshipDescription *relationship = (NSRelationshipDescription *)propertyDescription;
						
						if([relationship isToMany])
						{
							propertyDef.dataType = SCPropertyDataTypeNSMutableSet;
							propertyDef.type = SCPropertyTypeArrayOfObjects;
						}
						else
						{
							propertyDef.dataType = SCPropertyDataTypeNSObject;
							propertyDef.type = SCPropertyTypeObject;
						}
					}
				else
					if([propertyDescription isKindOfClass:[NSFetchedPropertyDescription class]])
					{
						propertyDef.dataType = SCPropertyDataTypeNSMutableSet;
						propertyDef.type = SCPropertyTypeArrayOfObjects;
						propertyDef.attributes = [SCArrayOfObjectsAttributes 
												  attributesWithObjectClassDefinition:nil
												  allowAddingItems:NO
												  allowDeletingItems:NO
												  allowMovingItems:NO];
					}
				
				[self addPropertyDefinition:propertyDef];
			}
		}
		
		// Set self.keyPropertyName & self.titlePropertyName to the first property
		if(self.propertyDefinitionCount)
		{
			self.keyPropertyName = [self propertyDefinitionAtIndex:0].name;
			self.titlePropertyName = [self propertyDefinitionAtIndex:0].name;
		}
	}
	
	return self;
}

- (id)initWithEntityName:(NSString *)entityName 
withManagedObjectContext:(NSManagedObjectContext *)context
      withPropertyGroups:(SCPropertyGroupArray *)groups
{
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
    for(NSInteger i=0; i<groups.groupCount; i++)
    {
        SCPropertyGroup *propertyGroup = [groups groupAtIndex:i];
        for(NSInteger j=0; j<propertyGroup.propertyNameCount; j++)
            [propertyNames addObject:[propertyGroup propertyNameAtIndex:j]];
    }
    
    if( (self=[self initWithEntityName:entityName withManagedObjectContext:context withPropertyNames:propertyNames]) )
    {
        for(NSInteger i=0; i<groups.groupCount; i++)
        {
            [self.propertyGroups addGroup:[groups groupAtIndex:i]];
        }
    }
    SC_Release(propertyNames);
    
    return self;
}

#endif

#ifndef ARC_ENABLED
- (void)dealloc
{
#ifdef _COREDATADEFINES_H	
	[managedObjectContext release];
	[entity release];
#endif
	
	[propertyDefinitions release];
	[keyPropertyName release];
	[titlePropertyName release];
	[titlePropertyNameDelimiter release];
	[descriptionPropertyName release];
	[orderAttributeName release];
    
    [defaultPropertyGroup release];
    [propertyGroups release];
	
	[super dealloc];
}
#endif
- (NSString *)getUserFriendlyPropertyTitleFromName:(NSString *)propertyName
{
	NSMutableString *UFName = SC_Autorelease([[NSMutableString alloc] init]);
	
	if(![propertyName length])
		return UFName;
	
	// Capitalize & append the 1st character
	[UFName appendString:[[propertyName substringToIndex:1] uppercaseString]];
	
	// Leave a space for every capital letter
	NSCharacterSet *uppercaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
	for(int i=1; i<[propertyName length]; i++)
	{
		unichar chr = [propertyName characterAtIndex:i];
		if([uppercaseSet characterIsMember:chr])
			[UFName appendString:[NSString stringWithFormat:@" %c", chr]];
		else
			[UFName appendString:[NSString stringWithFormat:@"%c", chr]];
	}
	
	return UFName;
}

- (NSString *)className
{
#ifdef _COREDATADEFINES_H	
	if(self.entity)
		return [self.entity name];
#endif
	//else
	return [NSString stringWithFormat:@"%s", class_getName(self.cls)];
}

- (void)setKeyPropertyName:(NSString *)propertyName
{
	if([self isValidPropertyName:propertyName])
	{
		SC_Release(keyPropertyName);
		keyPropertyName = [propertyName copy];
	}
}

- (NSUInteger)propertyDefinitionCount
{
	return propertyDefinitions.count;
}

- (BOOL)addPropertyDefinitionWithName:(NSString *)propertyName 
								title:(NSString *)propertyTitle
								 type:(SCPropertyType)propertyType
{
	SCPropertyDefinition *propertyDefinition = 
	[[SCPropertyDefinition alloc] initWithName:propertyName 
										 title:propertyTitle 
										  type:propertyType];
	BOOL success = [self addPropertyDefinition:propertyDefinition];
	SC_Release(propertyDefinition);
	
	return success;
}

- (BOOL)addPropertyDefinition:(SCPropertyDefinition *)propertyDefinition
{
	NSInteger index = self.propertyDefinitionCount;
	
	return [self insertPropertyDefinition:propertyDefinition atIndex:index];
}

- (BOOL)insertPropertyDefinition:(SCPropertyDefinition *)propertyDefinition
						 atIndex:(NSInteger)index
{
	if([propertyDefinition isKindOfClass:[SCCustomPropertyDefinition class]])
	{
		[propertyDefinitions insertObject:propertyDefinition atIndex:index];
		propertyDefinition.ownerClassDefinition = self;
		return TRUE;
	}
	//else
	if([self isValidPropertyName:propertyDefinition.name])
	{
		BOOL coreDataDefinition = FALSE;
#ifdef _COREDATADEFINES_H
		if(self.entity)
			coreDataDefinition = TRUE;
#endif
		if(!coreDataDefinition)
		{
			// Set property's dataType & dataReadOnly properties
			objc_property_t property = class_getProperty(self.cls, [propertyDefinition.name UTF8String]);
			if(!property)
				return FALSE;
			NSArray *attributesArray = [[NSString stringWithUTF8String: property_getAttributes(property)] 
										componentsSeparatedByString:@","];
			NSSet *attributesSet = [NSSet setWithArray:attributesArray];
			
			propertyDefinition.dataReadOnly = [attributesSet containsObject:@"R"];
			
			if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
											  [NSString stringWithUTF8String:class_getName([NSString class])]]])
				propertyDefinition.dataType = SCPropertyDataTypeNSString;
			else
				if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
												  [NSString stringWithUTF8String:class_getName([NSNumber class])]]])
					propertyDefinition.dataType = SCPropertyDataTypeNSNumber;
				else
					if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
													  [NSString stringWithUTF8String:class_getName([NSDate class])]]])
						propertyDefinition.dataType = SCPropertyDataTypeNSDate;
					else
						if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
														  [NSString stringWithUTF8String:class_getName([NSMutableSet class])]]])
							propertyDefinition.dataType = SCPropertyDataTypeNSMutableSet;
						else
							if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
															  [NSString stringWithUTF8String:class_getName([NSMutableArray class])]]])
								propertyDefinition.dataType = SCPropertyDataTypeNSMutableArray;
		}
		
		[propertyDefinitions insertObject:propertyDefinition atIndex:index];
		propertyDefinition.ownerClassDefinition = self;
		return TRUE;
	}
	//else
	return FALSE;
}

- (void)removePropertyDefinitionAtIndex:(NSUInteger)index
{
	[propertyDefinitions removeObjectAtIndex:index];
}

- (void)removePropertyDefinitionWithName:(NSString *)propertyName
{
	NSUInteger index = [self indexOfPropertyDefinitionWithName:propertyName];
	if(index != NSNotFound)
		[propertyDefinitions removeObjectAtIndex:index];
}

- (SCPropertyDefinition *)propertyDefinitionAtIndex:(NSUInteger)index
{
	return [propertyDefinitions objectAtIndex:index];
}

- (SCPropertyDefinition *)propertyDefinitionWithName:(NSString *)propertyName
{
	NSUInteger index = [self indexOfPropertyDefinitionWithName:propertyName];
	if(index != NSNotFound)
		return [propertyDefinitions objectAtIndex:index];
	//else
	return nil;
}

- (NSUInteger)indexOfPropertyDefinitionWithName:(NSString *)propertyName
{
	for(NSUInteger i=0; i<propertyDefinitions.count; i++)
	{
		SCPropertyDefinition *propertyDefinition = [propertyDefinitions objectAtIndex:i];
		if([propertyDefinition.name isEqualToString:propertyName])
			return i;
	}
	return NSNotFound;
}

- (BOOL)isValidPropertyName:(NSString *)propertyName
{
	BOOL propertyValid = FALSE;

#ifdef _COREDATADEFINES_H	
	if(self.entity)
	{
		propertyValid = ([[self.entity propertiesByName] valueForKey:propertyName] != nil);
	}
	else
	{
#endif		
		objc_property_t property = class_getProperty(self.cls, [propertyName UTF8String]);
		
		if(property)
		{
			// Property must be an NSObject decendant to be allowed
			NSArray *attributesArray = [[NSString stringWithUTF8String: property_getAttributes(property)] 
										componentsSeparatedByString:@","];
			NSString *classAttribute = [attributesArray objectAtIndex:0];
			NSRange classStringRange = [classAttribute rangeOfString:@"T@\""];
			if(classStringRange.location != NSNotFound)
			{
				propertyValid = TRUE;
			}
		}
#ifdef _COREDATADEFINES_H		
	}
#endif	
	
	return propertyValid;
}

- (NSString *)titleValueForObject:(NSObject *)object
{
	return [SCHelper stringValueForPropertyName:self.titlePropertyName inObject:object
				   separateValuesUsingDelimiter:self.titlePropertyNameDelimiter];
}

- (void)generateDefaultPropertyGroupProperties
{
    [self.defaultPropertyGroup removeAllPropertyNames];
    for(SCPropertyDefinition *propertyDef in propertyDefinitions)
    {
        BOOL propertyHasGroup = FALSE;
        for(NSInteger i=0; i<propertyGroups.groupCount; i++)
        {
            SCPropertyGroup *propertyGroup = [propertyGroups groupAtIndex:i];
            if([propertyGroup containsPropertyName:propertyDef.name])
            {
                propertyHasGroup = TRUE;
                break;
            }
        }
        if(!propertyHasGroup)
            [self.defaultPropertyGroup addPropertyName:propertyDef.name];
    }
}

@end






@implementation SCDictionaryDefinition

+ (id)definitionWithDictionaryKeyNames:(NSArray *)keyNames
{
	return SC_Autorelease([[[self class] alloc] initWithDictionaryKeyNames:keyNames]);
}

+ (id)definitionWithDictionaryKeyNames:(NSArray *)keyNames
						 withKeyTitles:(NSArray *)keyTitles
{
	return SC_Autorelease([[[self class] alloc] initWithDictionaryKeyNames:keyNames withKeyTitles:keyTitles]);
}

- (id)initWithDictionaryKeyNames:(NSArray *)keyNames
{
	return [self initWithDictionaryKeyNames:keyNames withKeyTitles:nil];
}

- (id)initWithDictionaryKeyNames:(NSArray *)keyNames
				   withKeyTitles:(NSArray *)keyTitles
{
	if( (self=[self init]) )
	{
		for(int i=0; i<keyNames.count; i++)
		{
			NSString *keyName = [keyNames objectAtIndex:i];
			NSString *keyTitle;
			if(i < keyTitles.count)
				keyTitle = [keyTitles objectAtIndex:i];
			else
				keyTitle = [self getUserFriendlyPropertyTitleFromName:keyName];
			[self addPropertyDefinitionWithName:keyName
										  title:keyTitle
										   type:SCPropertyTypeTextField];
		}
		
		// Set self.titlePropertyName to the first property
		if(self.propertyDefinitionCount)
			self.titlePropertyName = [self propertyDefinitionAtIndex:0].name;
	}
	return self;
}

// override superclass
- (BOOL)isValidPropertyName:(NSString *)propertyName
{
	return TRUE;	// Should accept any key name as a valid property name
}

// override superclass
- (BOOL)addPropertyDefinition:(SCPropertyDefinition *)propertyDefinition
{
	propertyDefinition.dataType = SCPropertyDataTypeDictionaryItem;
	[propertyDefinitions addObject:propertyDefinition];
	
	return TRUE;
}

// override superclass
- (NSString *)className
{
	return @"__NSCFDictionary";
}

@end


