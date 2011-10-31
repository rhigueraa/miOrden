/*
 *  SCClassDefinition.h
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


#import <Foundation/Foundation.h>
#import "SCPropertyAttributes.h"


@class SCTableViewCell;


typedef enum
{
	SCPropertyDataTypeNSString,
	SCPropertyDataTypeNSNumber,
	SCPropertyDataTypeNSDate,
	SCPropertyDataTypeNSMutableSet,
	SCPropertyDataTypeNSMutableArray,
	SCPropertyDataTypeNSObject,
	SCPropertyDataTypeDictionaryItem,
	SCPropertyDataTypeTransformable,
	SCPropertyDataTypeOther
} SCPropertyDataType;


/** @enum The types of an SCPropertyDefinition */
typedef enum
{
	/** The object bound to the property will detect the best user interface element to generate. */
	SCPropertyTypeAutoDetect,
	/**	The object bound to the property will generate an SCLabelCell interface element */
	SCPropertyTypeLabel,
	/**	The object bound to the property will generate an SCTextViewCell interface element */
	SCPropertyTypeTextView,
	/**	The object bound to the property will generate an SCTextFieldCell interface element */
	SCPropertyTypeTextField,
	/**	The object bound to the property will generate an SCNumericTextFieldCell interface element */
	SCPropertyTypeNumericTextField,
	/**	The object bound to the property will generate an SCSliderCell interface element */
	SCPropertyTypeSlider,
	/**	The object bound to the property will generate an SCSegmentedCell interface element */
	SCPropertyTypeSegmented,
	/**	The object bound to the property will generate an SCSwitchCell interface element */
	SCPropertyTypeSwitch,
	/**	The object bound to the property will generate an SCDateCell interface element */
	SCPropertyTypeDate,
	/**	The object bound to the property will generate an SCImagePickerCell interface element */
	SCPropertyTypeImagePicker,
	/**	The object bound to the property will generate an SCSelectionCell interface element */
	SCPropertyTypeSelection,
	/**	The object bound to the property will generate an SCObjectSelectionCell interface element */
	SCPropertyTypeObjectSelection,
	/**	The object bound to the property will generate an SCObjectCell interface element */
	SCPropertyTypeObject,
	/**	The object bound to the property will generate an SCArrayOfObjectsCell interface element */
	SCPropertyTypeArrayOfObjects,
	/**	The object bound to the property will not generate an interface element */
	SCPropertyTypeNone,
	/**	Undefined property type */
	SCPropertyTypeUndefined
	
} SCPropertyType;

@class SCClassDefinition;
/****************************************************************************************/
/*	class SCPropertyDefinition	*/
/****************************************************************************************/ 
/**	
 This class functions as a property definition for SCClassDefinition. 
 
 Every property definition should set a property type that determines which user interface element
 should be generated for the property. In addition, the generated user interface element
 can be further customized using the property's attributes.
 
 @see SCPropertyType, SCPropertyAttributes, SCClassDefinition.
 */
@interface SCPropertyDefinition : NSObject
{
	__SC_WEAK SCClassDefinition *ownerClassDefinition;
	SCPropertyDataType dataType;
	BOOL dataReadOnly;
	NSString *name;
	NSString *title;
	SCPropertyType type;
	SCPropertyAttributes *attributes;
	SCPropertyType editingModeType;
	SCPropertyAttributes *editingModeAttributes;
	BOOL required;
	BOOL autoValidate;
    BOOL existsInNormalMode;
    BOOL existsInEditingMode;
    BOOL existsInCreationMode;
    BOOL existsInDetailsMode;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/** Allocates and returns an initialized 'SCPropertyDefinition' given a property name.
 *
 *	@param propertyName The name of the property.           
 */
+ (id)definitionWithName:(NSString *)propertyName;

/** Allocates and returns an initialized 'SCPropertyDefinition' given a property name, title, and type.
 *
 *	@param propertyName The name of the property.
 *	@param propertyTitle The title of the property. Property titles are used by user interface elements to generate labels associated with the generated controls.
 *	@param propertyType The property type determines which user interface element will be generated for the property.
 */
+ (id)definitionWithName:(NSString *)propertyName 
				   title:(NSString *)propertyTitle
					type:(SCPropertyType)propertyType;

/** Returns an initialized 'SCPropertyDefinition' given a property name.
 *
 *	@param propertyName The name of the property.
 */
- (id)initWithName:(NSString *)propertyName;

/** Returns an initialized 'SCPropertyDefinition' given a property name, title, and type.
 *
 *	@param propertyName The name of the property.
 *	@param propertyTitle The title of the property. Property titles are used by user interface elements to generate labels associated with the generated controls.
 *	@param propertyType The property type determines which user interface element will be generated for the property.
 */
- (id)initWithName:(NSString *)propertyName 
			 title:(NSString *)propertyTitle
			  type:(SCPropertyType)propertyType;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/** The owner class definition of the property definition. 
 *
 * @warning Important: This property gets set automatically by the framework, you should never set this property manually. 
 */
@property (nonatomic, SC_WEAK) SCClassDefinition *ownerClassDefinition;

/** The name of the property associated with the property definition. */
@property (nonatomic, readonly) NSString *name;

/** 
 The title of the property. Property titles are used by user
 interface elements to generate labels associated with the generated controls.
 */
@property (nonatomic, copy) NSString *title;

/** The type of the property. Property types determines which user interface element will be generated for the property. */
@property (nonatomic, readwrite) SCPropertyType type;

/** 
 The attibutes set associated with the type of the property. Property attributes gives the user the ability
 to further customize the user interface element that will be generated for the given property type. 
 */
@property (nonatomic, SC_STRONG) SCPropertyAttributes *attributes;

/** 
 The type of the property while in editing mode. Property types determines which user interface element will
 be generated for the property while in editing mode. 
 @warning Note: If not set (or set to SCPropertyTypeUndefined), the value set in the "type" property is used in editing mode. 
 */
@property (nonatomic, readwrite) SCPropertyType editingModeType;

/** 
 The attibutes set associated with the editingModetype of the property. Property attributes gives the user the ability
 to further customize the user interface element that will be generated for the given property editingModetype. 
 */
@property (nonatomic, SC_STRONG) SCPropertyAttributes *editingModeAttributes;

/** Set to TRUE if property is a required property. Default: FALSE. */
@property (nonatomic, readwrite) BOOL required;

/** 
 Set to TRUE if the property value should be automatically validated by the user interface element
 before commiting it to the property. If the user chooses to provide custom validation
 using either the cell's SCTableViewCellDelegate, or the model's SCTableViewModelDelegate, they should
 set this property to FALSE. Default: TRUE. 
 */
@property (nonatomic, readwrite) BOOL autoValidate;

/** If set to TRUE, a user interface is generated for the property when the owning control is in Normal Mode, otherwise, no UI is generated in that mode. Default: TRUE. */
@property (nonatomic, readwrite) BOOL existsInNormalMode;

/** If set to TRUE, a user interface is generated for the property when the owning control is in Editing Mode, otherwise, no UI is generated in that mode. Default: TRUE. */
@property (nonatomic, readwrite) BOOL existsInEditingMode;

/** If set to TRUE, a user interface is generated for the property when the UI is generated for a newly created object, otherwise, no UI is generated. Default: TRUE. */
@property (nonatomic, readwrite) BOOL existsInCreationMode;

/** If set to TRUE, a user interface is generated for the property when the UI is generated for an existing object, otherwise, no UI is generated. Default: TRUE. */
@property (nonatomic, readwrite) BOOL existsInDetailMode;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal
//////////////////////////////////////////////////////////////////////////////////////////

/** This property is automatically set by the framework and should never be assigned a value directly. */
@property (nonatomic, readwrite) SCPropertyDataType dataType;

/** This property is automatically set by the framework and should never be assigned a value directly. */
@property (nonatomic, readwrite) BOOL dataReadOnly;

@end





/****************************************************************************************/
/*	class SCCustomPropertyDefinition	*/
/****************************************************************************************/ 
/**	
 This class functions as a property definition for SCClassDefinition that will generate
 a custom user inteface element (e.g.: custom cell). 
 
 'SCCustomPropertyDefinition' does not have
 to represent a property that actually exists in its class (unlike an SCPropertyDefiniton), 
 and is often used in a class definition as a placeholder for custom user 
 interface element generation.
 
 @see SCPropertyDefinition, SCClassDefinition.
 */
@interface  SCCustomPropertyDefinition : SCPropertyDefinition
{
    NSObject *uiElement; //deprecated
    
    __SC_WEAK Class uiElementClass;
    NSString *uiElementNibName;
	NSDictionary *objectBindings;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/** Allocates and returns an initialized 'SCCustomPropertyDefinition' given a property name and a custom user interface element to generate.
 *
 *  @warning Depricated in STV 2.1, use definitionWithName:withuiElementClass:withObjectBindings instead.
 *	@param propertyName The name of the property.
 *	@param element The custom user interface element that will be generated.
 *	@param bindings This dictionary specifies how each of the uiElement's custom controls binds itself to the class definition's properties. Each dictionary key should be the tag string value of one of the uiElement's custom controls, and the value should be the name of the class definition's property that is bound to that control. 
 *	@warning IMPORTANT: All control tags must be greater than zero.
 */
+ (id)definitionWithName:(NSString *)propertyName 
		   withuiElement:(NSObject *)element
	  withObjectBindings:(NSDictionary *)bindings __attribute__((deprecated));

/** Allocates and returns an initialized 'SCCustomPropertyDefinition' given a property name and a class of the  custom user interface element to generate.
 *
 *	@param propertyName The name of the property.
 *	@param elementClass The class of the custom user interface element that will be generated.
 *	@param bindings This dictionary specifies how each of the uiElement's custom controls binds itself to the class definition's properties. Each dictionary key should be the tag string value of one of the uiElement's custom controls, and the value should be the name of the class definition's property that is bound to that control. 
 *	@warning IMPORTANT: All control tags must be greater than zero.
 */
+ (id)definitionWithName:(NSString *)propertyName 
      withuiElementClass:(Class)elementClass
	  withObjectBindings:(NSDictionary *)bindings;

/** Allocates and returns an initialized 'SCCustomPropertyDefinition' given a property name and the name of the nib file containing the custom user interface element to generate.
 *
 *	@param propertyName The name of the property.
 *	@param elementNibName The name of the nib file containing the custom user interface element that will be generated.
 *	@param bindings This dictionary specifies how each of the uiElement's custom controls binds itself to the class definition's properties. Each dictionary key should be the tag string value of one of the uiElement's custom controls, and the value should be the name of the class definition's property that is bound to that control. 
 *	@warning IMPORTANT: All control tags must be greater than zero.
 */
+ (id)definitionWithName:(NSString *)propertyName 
	withuiElementNibName:(NSString *)elementNibName
	  withObjectBindings:(NSDictionary *)bindings;

/** Returns an initialized 'SCCustomPropertyDefinition' given a property name and a custom user interface element to generate.
 *
 *  @warning Depricated in STV 2.1, use initWithName:withuiElementClass:withObjectBindings instead.
 *	@param propertyName The name of the property.
 *	@param element The custom user interface element that will be generated.
 *	@param bindings This dictionary specifies how each of the uiElement's custom controls binds itself to the class definition's properties. Each dictionary key should be the tag string value of one of the uiElement's custom controls, and the value should be the name of the class definition's property that is bound to that control. 
 *	@warning IMPORTANT: All control tags must be greater than zero.
 */
- (id)initWithName:(NSString *)propertyName 
	 withuiElement:(NSObject *)element
withObjectBindings:(NSDictionary *)bindings __attribute__((deprecated));

/** Returns an initialized 'SCCustomPropertyDefinition' given a property name and a class of the  custom user interface element to generate.
 *
 *	@param propertyName The name of the property.
 *	@param elementClass The class of the custom user interface element that will be generated.
 *	@param bindings This dictionary specifies how each of the uiElement's custom controls binds itself to the class definition's properties. Each dictionary key should be the tag string value of one of the uiElement's custom controls, and the value should be the name of the class definition's property that is bound to that control. 
 *	@warning IMPORTANT: All control tags must be greater than zero.
 */
- (id)initWithName:(NSString *)propertyName 
    withuiElementClass:(Class)elementClass
    withObjectBindings:(NSDictionary *)bindings;

/** Returns an initialized 'SCCustomPropertyDefinition' given a property name and the name of the nib file containing the custom user interface element to generate.
 *
 *	@param propertyName The name of the property.
 *	@param elementNibName The name of the nib file containing the custom user interface element that will be generated.
 *	@param bindings This dictionary specifies how each of the uiElement's custom controls binds itself to the class definition's properties. Each dictionary key should be the tag string value of one of the uiElement's custom controls, and the value should be the name of the class definition's property that is bound to that control. 
 *	@warning IMPORTANT: All control tags must be greater than zero.
 */
- (id)initWithName:(NSString *)propertyName 
	withuiElementNibName:(NSString *)elementNibName
	withObjectBindings:(NSDictionary *)bindings;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/** Deprecated in STV 2.1, use uiElementClass instead. */
@property (nonatomic, readonly) NSObject *uiElement __attribute__((deprecated));

/** The class of the custom user interface element the property will generate. 
 *
 *  @warning No need to set this property if uiElementNibName contains a valid value. */
@property (nonatomic, SC_WEAK) Class uiElementClass;

/** The Nib name of the custom user interface element the property will generate. */
@property (nonatomic, copy) NSString *uiElementNibName;

/** 
 This dictionary specifies how each
 of the uiElement's custom controls binds itself to the class definition's properties. 
 Each dictionary key
 should be the tag string value of one of the uiElement's custom controls, and the value should be the 
 name of the class definition's property that is bound to that control. 
 @warning IMPORTANT: All control tags must be greater than zero.
 */
@property (nonatomic, SC_STRONG) NSDictionary *objectBindings;

@end







/****************************************************************************************/
/*	class SCPropertyGroup	*/
/****************************************************************************************/ 
/**	
 This class functions as a way to define a property definition group that is used to generate
 a corresponding user interface element that groups these properties (e.g.: a table view section). 
 
 Property definitions are added to this class using their NSString 'name' property.
 
 @see SCPropertyDefinition, SCClassDefinition.
 */
@interface SCPropertyGroup : NSObject
{
    NSString *headerTitle;
    NSString *footerTitle;
    NSMutableArray *propertyDefinitionNames;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////


/** Allocates and returns an initialized 'SCPropertyGroup' given a header title, a footer title
 *  and an NSArray of property names to be included in the group.
 *
 *	@param sectionHeaderTitle A header title for the group.
 *	@param sectionFooterTitle A footer title for the group.
 */
+ (id)groupWithHeaderTitle:(NSString *)groupHeaderTitle withFooterTitle:(NSString *)groupFooterTitle
         withPropertyNames:(NSArray *)propertyNames;

/** Returns an initialized 'SCPropertyGroup' given a header title, a footer title
 *  and an NSArray of property names to be included in the group.
 *
 *	@param sectionHeaderTitle A header title for the group.
 *	@param sectionFooterTitle A footer title for the group.
 */
- (id)initWithHeaderTitle:(NSString *)groupHeaderTitle withFooterTitle:(NSString *)groupFooterTitle
        withPropertyNames:(NSArray *)propertyNames;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/** The group header title. */
@property (nonatomic, copy) NSString *headerTitle;

/** The group footer title. */
@property (nonatomic, copy) NSString *footerTitle;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Property Names
//////////////////////////////////////////////////////////////////////////////////////////

/** The count of the property names. */
@property (nonatomic, readonly) NSInteger propertyNameCount;

/**	Add the property name to the group. */
- (void)addPropertyName:(NSString *)propertyName;

/**	Add the property name to the group at the given index. */
- (void)insertPropertyName:(NSString *)propertyName atIndex:(NSInteger)index;

/**	Return the property name at the given index. */
- (NSString *)propertyNameAtIndex:(NSInteger)index;

/**	Remove the property name at the given index from the group. */
- (void)removePropertyNameAtIndex:(NSInteger)index;

/**	Remove all property names from the group. */
- (void)removeAllPropertyNames;

/**	Returns TRUE if the property name exists in the group. */
- (BOOL)containsPropertyName:(NSString *)propertyName;

@end



/****************************************************************************************/
/*	class SCPropertyGroupArray	*/
/****************************************************************************************/ 
/**	
 This class functions as an array of SCPropertyGroup objects. 
 
 @warning Note: Instances of this class should only be created internally by the framework.
 
 @see SCPropertyGroup.
 */
@interface SCPropertyGroupArray : NSObject
{
    NSMutableArray *propertyGroups;
}


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Groups
//////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, readonly) NSInteger groupCount;

/**	Add a group to the array. */
- (void)addGroup:(SCPropertyGroup *)group;

/**	Add a group at the given index. */
- (void)insertGroup:(SCPropertyGroup *)group atIndex:(NSInteger)index;

/**	Return group at the given index. */
- (SCPropertyGroup *)groupAtIndex:(NSInteger)index;

/**	Remove group at the given index. */
- (void)removeGroupAtIndex:(NSInteger)index;

/**	Remove all groups. */
- (void)removeAllGroups;

@end







/****************************************************************************************/
/*	class SCClassDefinition	*/
/****************************************************************************************/ 
/**	
 This class functions as a means to further extend the definition of user-defined classes.
 Using class definitions, classes like SCObjectCell and SCObjectSection 
 will be able to better generate user interface elements that truly represent the 
 properties of their bound objects. 
 
 'SCClassDefinition' mainly consists of one or more property definitions of type SCPropertyDefinition.
 Upon creation, 'SCClassDefinition' will (optionally) automatically generate all the
 property definitions for the given class. From there, the user will be able to customize
 the generated property definitions, add new definitions, or remove generated definitions.
 
 @see SCPropertyDefinition.
 */
@interface SCClassDefinition : NSObject 
{
	Class cls;
	
#ifdef _COREDATADEFINES_H
	NSEntityDescription *entity;
	NSManagedObjectContext *managedObjectContext;
#endif
	
	NSMutableArray *propertyDefinitions;
	NSString *keyPropertyName;
	NSString *titlePropertyName;
	NSString *titlePropertyNameDelimiter;
	NSString *descriptionPropertyName;
	NSString *orderAttributeName;
	__SC_WEAK id uiElementDelegate;
    
    SCPropertyGroup *defaultPropertyGroup;
    SCPropertyGroupArray *propertyGroups;
    
    BOOL requireEditingModeToEditPropertyValues;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/** Allocates and returns an initialized 'SCClassDefinition' given a class and the option to auto generate property definitions for the given class.
 
 The method will also generate user friendly property titles from the names of the generated properties. These titles can be modified by the user later as part of the property definition customization.
 
 *	@param _cls A class for which the definition will be extended.
 *	@param autoGenerate If TRUE, 'SCClassDefinition' will automatically generate all the property definitions for the given class. 
 */
+ (id)definitionWithClass:(Class)_cls autoGeneratePropertyDefinitions:(BOOL)autoGenerate;

/** Allocates and returns an initialized 'SCClassDefinition' given a class and an array of the property names to generate property definitions from.
 
 The method will also generate user friendly property titles from the names of 
 the given properties. These titles can be modified by the user later as part of
 the property definition customization.
 
 *	@param _cls A class for which the definition will be extended.
 *	@param propertyNames An array of the names of properties to be generated. All array elements must be of type NSString.
 */
+ (id)definitionWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames;

/** Allocates and returns an initialized 'SCClassDefinition' given a class, an array of
 the property names to generate property definitions from, and array of titles
 for these properties.
 
 *	@param _cls A class for which the definition will be extended.
 *	@param propertyNames An array of the names of properties to be generated. All array elements must be of type NSString.
 *	@param propertyTitles An array of titles to the properties in propertyNames. All array elements must be of type NSString.
 */
+ (id)definitionWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
		withPropertyTitles:(NSArray *)propertyTitles;

/** Allocates and returns an initialized 'SCClassDefinition' given a class and an SCPropertyGroupArray.
 *
 *	@param _cls A class for which the definition will be extended.
 *	@param groups A collection of property groups. 
 */
+ (id)definitionWithClass:(Class)_cls withPropertyGroups:(SCPropertyGroupArray *)groups;

/** Allocates and returns an initialized 'SCClassDefinition' given a class and the option to auto generate property definitions for the given class.
 
 The method will also generate user friendly property titles from the names of 
 the generated properties. These titles can be modified by the user later as part of
 the property definition customization.
 
 *	@param _cls A class for which the definition will be extended.
 *	@param autoGenerate If TRUE, 'SCClassDefinition' will automatically generate all the property definitions for the given class. 
 */
- (id)initWithClass:(Class)_cls autoGeneratePropertyDefinitions:(BOOL)autoGenerate;

/** Allocates and returns an initialized 'SCClassDefinition' given a class and an array of the property names to generate property definitions from.
 
 The method will also generate user friendly property titles from the names of 
 the given properties. These titles can be modified by the user later as part of
 the property definition customization.
 
 *	@param _cls A class for which the definition will be extended.
 *	@param propertyNames An array of the names of properties to be generated. All array elements must be of type NSString.
 */
- (id)initWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames;

/** Allocates and returns an initialized 'SCClassDefinition' given a class, an array of
 the property names to generate property definitions from, and array of titles
 for these properties.
 
 *	@param _cls A class for which the definition will be extended.
 *	@param propertyNames An array of the names of properties to be generated. All array elements must be of type NSString.
 *	@param propertyTitles An array of titles to the properties in propertyNames. All array elements must be of type NSString.
 */
- (id)initWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
  withPropertyTitles:(NSArray *)propertyTitles;

/** Returns an initialized 'SCClassDefinition' given a class and an SCPropertyGroupArray.
 *
 *	@param _cls A class for which the definition will be extended.
 *	@param groups A collection of property groups. 
 */
- (id)initWithClass:(Class)_cls withPropertyGroups:(SCPropertyGroupArray *)groups;


#ifdef _COREDATADEFINES_H

/** Allocates and returns an initialized 'SCClassDefinition' given a Core Data entity name and the option to auto generate property definitions for the given entity's properties.
 
 The method will also generate user friendly property titles from the names of 
 the generated properties. These titles can be modified by the user later as part of
 the property definition customization.
 
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param autoGenerate If TRUE, 'SCClassDefinition' will automatically generate all the property definitions for the given entity's attributes. 
 *	@warning Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
+ (id)definitionWithEntityName:(NSString *)entityName 
	  withManagedObjectContext:(NSManagedObjectContext *)context
	autoGeneratePropertyDefinitions:(BOOL)autoGenerate;

/** Allocates and returns an initialized 'SCClassDefinition' given a Core Data entity name and an array of the property names to generate property definitions for.
 
 The method will also generate user friendly property titles from the names of 
 the given properties. These titles can be modified by the user later as part of
 the property definition customization.
 
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param propertyNames An array of the names of properties to be generated. All array elements must be of type NSString.
 *
 *	@warning Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
+ (id)definitionWithEntityName:(NSString *)entityName 
  withManagedObjectContext:(NSManagedObjectContext *)context
		 withPropertyNames:(NSArray *)propertyNames;

/** Allocates and returns an initialized 'SCClassDefinition' given a Core Data entity name, an array of
 the property names to generate property definitions for, and array of titles
 for these properties.
 
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param propertyNames An array of the names of properties to be generated. All array elements must be of type NSString.
 *	@param propertyTitles An array of titles to the properties in propertyNames. All array elements must be of type NSString.
 *
 *	@warning Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
+ (id)definitionWithEntityName:(NSString *)entityName
	  withManagedObjectContext:(NSManagedObjectContext *)context
			 withPropertyNames:(NSArray *)propertyNames
			withPropertyTitles:(NSArray *)propertyTitles;

/** Allocates and returns an initialized 'SCClassDefinition' given a Core Data entity name and an SCPropertyGroupArray.
 * 
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param groups A collection of property groups. 
 *	@warning Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
+ (id)definitionWithEntityName:(NSString *)entityName 
	  withManagedObjectContext:(NSManagedObjectContext *)context
            withPropertyGroups:(SCPropertyGroupArray *)groups;

/** Returns an initialized 'SCClassDefinition' given a Core Data entity name and the option to auto generate property definitions for the given entity's properties.
 
 The method will also generate user friendly property titles from the names of 
 the generated properties. These titles can be modified by the user later as part of
 the property definition customization.
 
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param autoGenerate If TRUE, 'SCClassDefinition' will automatically generate all the property definitions for the given entity's attributes. 
 *
 *	@warning Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
- (id)initWithEntityName:(NSString *)entityName 
	withManagedObjectContext:(NSManagedObjectContext *)context
	autoGeneratePropertyDefinitions:(BOOL)autoGenerate;

/** Returns an initialized 'SCClassDefinition' given a Core Data entity name and an array of the property names to generate property definitions for.
 
 The method will also generate user friendly property titles from the names of 
 the given properties. These titles can be modified by the user later as part of
 the property definition customization.
 
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param propertyNames An array of the names of properties to be generated. All array elements must be of type NSString.
 *
 *	@warning Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
- (id)initWithEntityName:(NSString *)entityName 
  withManagedObjectContext:(NSManagedObjectContext *)context
		 withPropertyNames:(NSArray *)propertyNames;

/** Returns an initialized 'SCClassDefinition' given a Core Data entity name, an array of
 the property names to generate property definitions for, and array of titles
 for these properties.
 
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param propertyNames An array of the names of properties to be generated. All array elements must be of type NSString.
 *	@param propertyTitles An array of titles to the properties in propertyNames. All array elements must be of type NSString.
 *
 *	@warning Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
- (id)initWithEntityName:(NSString *)entityName
  withManagedObjectContext:(NSManagedObjectContext *)context
		 withPropertyNames:(NSArray *)propertyNames
		withPropertyTitles:(NSArray *)propertyTitles;

/** Returns an initialized 'SCClassDefinition' given a Core Data entity name and an SCPropertyGroupArray.
 * 
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param groups A collection of property groups. 
 *	@warning Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
- (id)initWithEntityName:(NSString *)entityName 
withManagedObjectContext:(NSManagedObjectContext *)context
      withPropertyGroups:(SCPropertyGroupArray *)groups;

#endif


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/** The class associated with the definition. 
 *  @warning Note: Only applicable with class definition is initialized with a class. 
 */
@property (nonatomic, readonly) Class cls;

#ifdef _COREDATADEFINES_H
/** The entity associated with the definition. 
 *  @warning Note: Only applicable when class definition is initialized with an entity name. 
 */
@property (nonatomic, readonly, SC_STRONG) NSEntityDescription *entity;

/** The managed object context of the entity associated with the definition. 
 *  @warning Note: Only applicable when class definition is initialized with an entity name. 
 */
@property (nonatomic, readonly, SC_STRONG) NSManagedObjectContext *managedObjectContext;
#endif

/**	The string name of cls or entity */
@property (nonatomic, readonly) NSString *className;

/** When set to TRUE, the class definition requires the generated user interface elements to be placed in 'Editing Mode' before the user can modify the generated property controls' values. When not in Editing Mode, all the generated property controls will be put in a read-only state. If the table view representing the class definition was automatically generated by the framework, an 'Edit' button will also be automatically added to the navigation bar. Default: FALSE. */
@property (nonatomic, readwrite) BOOL requireEditingModeToEditPropertyValues;

/** The key of the entity associated with the definition. 
  
 The key is usually used when
 a set of entity objects are sorted. By default, 'SCClassDefinition' sets this property to the name of the 
 first property in the entity. 
 @warning Note: Only applicable to Core Data entity class definitions. 
 */
@property (nonatomic, copy) NSString *keyPropertyName;

/**	The name of the entity attribute that will be used to store the display order of its objects. 
 
 Setting this property to a valid attribute name allows for custom re-ordering of the generated
 user interface elements representing the Core Data objects (e.g. custom re-ordering of cells).
 Setting this property overrides the value set for the keyPropertyName property.
 @warning Important: This Core Data attribute must be of integer type. 
 @warning Note: Only applicable to Core Data entity class definitions. 
 */
@property (nonatomic, copy) NSString *orderAttributeName;

/**	The name of the title property for the class or entity. 
 
 Title properties are used in user
 interface elements to display title information based on the value of the property
 named here. By default, 'SCClassDefinition' sets this property to the name of the 
 first property in cls or entity. 
 @warning Note: To have the title set to more than one property value,
 separate the property names by a semi-colon (e.g.: @"firstName;lastName"). When displayed, the
 titles will be separated by the value of the titlePropertyNameDelimiter property. 
 */
@property (nonatomic, copy) NSString *titlePropertyName;

/** The delimiter used to separate the titles specified in titlePropertyName. Default: @" ". */
@property (nonatomic, copy) NSString *titlePropertyNameDelimiter;

/**	The name of the description property for the class or entity. 
 
 Description properties are used in user
 interface elements to display description information based on the value of the property
 named here. 
 */
@property (nonatomic, copy) NSString *descriptionPropertyName;

/** The delegate for the user interface elements that will be generated for the property definitions. */
@property (nonatomic, SC_WEAK) id uiElementDelegate;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Property Definitions
//////////////////////////////////////////////////////////////////////////////////////////

/** The number of property definitions. */
@property (nonatomic, readonly) NSUInteger propertyDefinitionCount;

/** Methods adds a new property definition.
 *	@param propertyName The name of the property.
 *	@param propertyTitle The title of the property. If no value is provided, the method automatically generates a user friendly name for the property.
 *	@param propertyType The property type.
 *	@return Returns TRUE if adding the definition was successful. The main reason for addition failure is if the property name does not match an existing property in cls.
 */
- (BOOL)addPropertyDefinitionWithName:(NSString *)propertyName 
								title:(NSString *)propertyTitle
								 type:(SCPropertyType)propertyType;

/** Methods adds a new property definition.
 *	@param propertyDefinition The property definition to be added.
 *	@return Returns TRUE if adding the definition was successful. The main reason for addition failure is if the property name does not match an existing property in cls (not required if property definition is an SCCustomPropertyDefinition).
 */
- (BOOL)addPropertyDefinition:(SCPropertyDefinition *)propertyDefinition;

/** Methods inserts a new property definition at the given index.
 *	@param propertyDefinition The property definition to be added.
 *	@param index The index to insert the property definition at. Must be less than propertyDefinitionCount.
 *	@return Returns TRUE if inserting the definition was successful. The main reason for insertion failure is if the property name does not match an existing property in cls (not required if property definition is an SCCustomPropertyDefinition).
 */
- (BOOL)insertPropertyDefinition:(SCPropertyDefinition *)propertyDefinition
						 atIndex:(NSInteger)index;

/** Removes the property definition at the given index.
 *	@param index Must be less than the total number of property definitions. 
 */
- (void)removePropertyDefinitionAtIndex:(NSUInteger)index;

/** Removes the property definition with the given name. 
 *	@param propertyName The name of the property to be removed. 
 */
- (void)removePropertyDefinitionWithName:(NSString *)propertyName;

/** Returns the property definition at the given index.
 *	@param index Must be less than the total number of property definitions. 
 */
- (SCPropertyDefinition *)propertyDefinitionAtIndex:(NSUInteger)index;

/** Returns the property definition with the given name. 
 *	@param propertyName The name of the property whose definition to be returned. 
 */
- (SCPropertyDefinition *)propertyDefinitionWithName:(NSString *)propertyName;

/** Returns the index for the property definition with the given name. 
 *	@param propertyName The name of the property whose index to be returned. 
 */
- (NSUInteger)indexOfPropertyDefinitionWithName:(NSString *)propertyName;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Property Definition Groups
//////////////////////////////////////////////////////////////////////////////////////////

/** The default property group. The framework will automatically add any properties not included in any other group to this group. If this group has any properties at the time the user interface is generated, it will be rendered as the first group, ahead of all other groups in propertyGroups. 
 *  @warning Note: The order of the properties automatically added to this group is the same as their order in the class definition.
 *  @warning Important: Since the framework automatically manages the properties included in this group, adding any properties manually will be ignored.
 */
@property (nonatomic, readonly) SCPropertyGroup *defaultPropertyGroup;

/** An array of all property groups in the class definition. Property groups will be rendered to the user interface with the same order specified in this array. */
@property (nonatomic, readonly) SCPropertyGroupArray *propertyGroups;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Methods (should only be used by the framework or when subclassing)
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns the property data type of any property given its name and its object. */
+ (SCPropertyDataType)propertyDataTypeForPropertyWithName:(NSString *)propertyName inObject:(NSObject *)object;

/** Returns TRUE if propertyName is valid. 
 *
 *  A propertyName is valid if it exists within the associated class or entity. 
 *
 *	@param propertyName The name of the property whose validity is to be checked. 
 */
- (BOOL)isValidPropertyName:(NSString *)propertyName;

/** Returns the title string value for the given object. 
 
 The title value is determined
 based on the value of the titlePropertyName property. 
 @warning Note: object must be an instance of the same class or entity defined in the class definition. 
 */
- (NSString *)titleValueForObject:(NSObject *)object;

/** Automatically adds the properties that should be present in defaultPropertyGroup. */
- (void)generateDefaultPropertyGroupProperties;

@end








/****************************************************************************************/
/*	class SCDictionaryDefinition	*/
/****************************************************************************************/ 
/**	
 This class functions as a means to further extend the key definitions of an NSMutableDictionary.
 
 Using dictionary definitions, classes like SCObjectCell and SCObjectSection 
 will be able to better generate user interface elements that truly represent the 
 keys of their bound mutable dictionaries. 
 
 'SCDictionaryDefinition' directly decends from SCClassDefinition.
 
 @see SCPropertyDefinition.
 */
@interface SCDictionaryDefinition : SCClassDefinition
{
}

/** Allocates and returns an initialized 'SCDictionaryDefinition' given the key names of the mutable dictionary to be defined. 
 
 By default, all property definitions generated
 for the given keyNames will have a type of SCPropertyTypeTextField. This can be fully customized
 after initialization.
 
 *	@param keyNames An array of the dictionary key names. All array elements must be of type NSString.
 */
+ (id)definitionWithDictionaryKeyNames:(NSArray *)keyNames;

/** Allocates and returns an initialized 'SCDictionaryDefinition' given the key names and titles of the mutable dictionary to be defined. 
 
 By default, all property definitions generated
 for the given keyNames will have a type of SCPropertyTypeTextField. This can be fully customized
 after initialization.
 
 *	@param keyNames An array of the dictionary key names. All array elements must be of type NSString.
 *	@param keyTitles An array of titles to the keys in keyNames. All array elements must be of type NSString.
 */
+ (id)definitionWithDictionaryKeyNames:(NSArray *)keyNames
	   withKeyTitles:(NSArray *)keyTitles;

/** Returns an initialized 'SCDictionaryDefinition' given the key names of the mutable dictionary to be defined. 
 
 By default, all property definitions generated
 for the given keyNames will have a type of SCPropertyTypeTextField. This can be fully customized
 after initialization.
 
 *	@param keyNames An array of the dictionary key names. All array elements must be of type NSString.
 */
- (id)initWithDictionaryKeyNames:(NSArray *)keyNames;

/** Returns an initialized 'SCDictionaryDefinition' given the key names and titles of the mutable dictionary to be defined. 
 
 By default, all property definitions generated
 for the given keyNames will have a type of SCPropertyTypeTextField. This can be fully customized
 after initialization.
 
 *	@param keyNames An array of the dictionary key names. All array elements must be of type NSString.
 *	@param keyTitles An array of titles to the keys in keyNames. All array elements must be of type NSString.
 */
- (id)initWithDictionaryKeyNames:(NSArray *)keyNames
				   withKeyTitles:(NSArray *)keyTitles;

@end




