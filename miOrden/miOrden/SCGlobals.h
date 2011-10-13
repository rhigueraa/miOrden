/*
 *  SCGlobals.h
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



/* Uncomment the following line if you want to deploy your project to a device that is 
 * running iOS prior to version 3.2. Note: When you do that, it is normal to get several compiler
 * wanrning messages regarding the use of deprecated symbols. */

// #define DEPLOYMENT_OS_PRIOR_TO_3_2



/*
 *	The following defines global Sesible TableView defaults. You are very much discouraged from
 *	modifying the content of these values, mainly for your product to remain forward compatable
 *	with future versions of Sensible TableView. If you think you need to change any of these 
 *	values, please consider either modifying the respective property of the Sensible TableView 
 *	object, or subclassing it.
 */
/**********************************************************************************/
#ifdef DEPLOYMENT_OS_PRIOR_TO_3_2
	#define SC_DefaultCellStyle		UITableViewCellStyleDefault
#else
	#define SC_DefaultCellStyle		UITableViewCellStyleSubtitle
#endif


#define		SC_DefaultMaxTextLabelWidth			200		// Default maximum width of SCTableViewCell textLabel
#define		SC_DefaultControlMargin				10		// Default margin between different controls
#define		SC_DefaultControlHeight				22		// Default control height
#define		SC_DefaultControlIndentation		120		// Default control indentation from table left border
#define		SC_DefaultTextViewFontSize			17		// Default font size of UITextView
#define		SC_DefaultTextFieldHeight			31		// Default height of UITextField
#define		SC_DefaultSegmentedControlHeight	29		// Default height of UISegmentedControl
/**********************************************************************************/






/**********************************************************************************/
/************************** DO NOT EDIT AFTER THIS LINE ***************************/
/**********************************************************************************/




/***************************************/
/* ARC supporting functions and macros */
/***************************************/

#ifndef __has_feature      
#define __has_feature(x) 0 // For compatibility with non-clang compilers.
#endif

#ifndef NS_CONSUMED
#if __has_feature(attribute_ns_consumed)
#define NS_CONSUMED __attribute__((ns_consumed))
#else
#define NS_CONSUMED
#endif
#endif

#if __has_feature(objc_arc)
#define ARC_ENABLED
#endif

#ifdef ARC_ENABLED

#define SC_STRONG           strong
#define __SC_STRONG         __strong
#define __SC_IDCAST         __bridge id
#define __SC_CONSTVOIDCAST  __bridge const void *
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
#define SC_WEAK             unsafe_unretained
#define __SC_WEAK           __unsafe_unretained
#else
#define SC_WEAK             weak
#define __SC_WEAK           __weak
#endif

#else

#define SC_STRONG           retain
#define SC_WEAK             assign
#define __SC_STRONG     
#define __SC_WEAK       
#define __SC_IDCAST         id
#define __SC_CONSTVOIDCAST  const void *

#endif


NS_INLINE id SC_Retain(id obj)
{
#ifdef ARC_ENABLED
    return obj;
#else
    return [obj retain];
#endif
}

NS_INLINE void SC_Release(NS_CONSUMED id obj)
{
#ifdef ARC_ENABLED
    // do nothing
#else
    [obj release];
#endif
}

NS_INLINE id SC_Autorelease(NS_CONSUMED id obj)
{
#ifdef ARC_ENABLED
    return obj;
#else
    return [obj autorelease];
#endif
}

/***************************************/








/** @enum The types of navigation bars used in SCViewController and SCTableViewController. */
typedef enum
{
	/** Navigation bar with no buttons. */
	SCNavigationBarTypeNone,
	/** Navigation bar with an Add button on the left. */
	SCNavigationBarTypeAddLeft,
	/** Navigation bar with an Add button on the right. */
	SCNavigationBarTypeAddRight,
	/** Navigation bar with an Edit button on the left. */
	SCNavigationBarTypeEditLeft,
	/** Navigation bar with an Edit button on the right. */
	SCNavigationBarTypeEditRight,
	/** Navigation bar with an Add button on the right and an Edit button on the left. */
	SCNavigationBarTypeAddRightEditLeft,
	/** Navigation bar with an Add button on the left and an Edit button on the right. */
	SCNavigationBarTypeAddLeftEditRight,
	/** Navigation bar with a Done button on the left. */
	SCNavigationBarTypeDoneLeft,
	/** Navigation bar with a Done button on the right. */
	SCNavigationBarTypeDoneRight,
	/** Navigation bar with a Done button on the left and a Cancel button on the right. */
	SCNavigationBarTypeDoneLeftCancelRight,
	/** Navigation bar with a Done button on the right and a Cancel button on the left. */
	SCNavigationBarTypeDoneRightCancelLeft,
	/** Navigation bar with both an Add and Edit buttons on the right. */
	SCNavigationBarTypeAddEditRight
	
} SCNavigationBarType;


/** @enum The types of SCViewController and SCTableViewController states. */
typedef enum
{
	/** View controller is being displayed for the first time. A view controller remains in this state
	 *	until the viewDidAppear method has been called. */
	SCViewControllerStateNew,
	/** View controller is visible and active. */
	SCViewControllerStateActive,
	/** View controller has disappeared and is inactive. */
	SCViewControllerStateInactive,
	/** View controller has been dismissed (using either the Done or Cancel buttons). */
	SCViewControllerStateDismissed
	
} SCViewControllerState;




@interface UINavigationController (KeyboardDismiss)

- (BOOL)disablesAutomaticKeyboardDismissal;

@end




@class SCClassDefinition;

/* This class defines a set of internal helper methods */
@interface SCHelper : NSObject
{
}

/* Method determines the system version */
+ (double)systemVersion;

/* Method determines if code is being run on an iPad */
+ (BOOL)is_iPad;

/* Method determines if the given view is inside a popover view */
+ (BOOL)isViewInsidePopover:(UIView *)view;

+ (NSObject *)getFirstNodeInNibWithName:(NSString *)nibName;

+ (NSMutableArray *)generateObjectsArrayForEntityClassDefinition:(SCClassDefinition *)classDef
												  usingPredicate:(NSPredicate *)predicate
                                                       ascending:(BOOL)ascending;

/*  Returns the the value for the given property in the given object. 
 *	@param propertyName The name of the property whose value is requested. propertyName can be
 *	given in a key-path format (e.g.: "subObject1.subObject2.subObject3"). More than one property
 *	can be given, separated by ';' (e.g.: "property1;property2;property3").
 *	@param object The owner object of the given property.  
 *	@return Returns the value of the given property. If more than one property name is given
 *	(separated by ';'), the return value is an NSArray. Returns nil if property does not exist
 *	in object (or NSNull if more than one property name is given). */
+ (NSObject *)valueForPropertyName:(NSString *)propertyName inObject:(NSObject *)object;

+ (NSString *)stringValueForPropertyName:(NSString *)propertyName inObject:(NSObject *)object
			separateValuesUsingDelimiter:(NSString *)delimiter;

@end




@class SCTableViewModel;

/* This class defines a tabel view model center.
 * IMPORTANT: This class is usually only used internally by the framework. */
@interface SCModelCenter : NSObject
{
	CFMutableSetRef modelsSet;
}

@property (nonatomic, SC_WEAK) UIViewController *keyboardIssuer;

+ (SCModelCenter *)sharedModelCenter;

- (void)registerModel:(SCTableViewModel *)model;
- (void)unregisterModel:(SCTableViewModel *)model;

- (SCTableViewModel *)modelForViewController:(UIViewController *)viewController;

@end





/* This class implements a transparent toolbar */
@interface SCTransparentToolbar : UIToolbar
@end


