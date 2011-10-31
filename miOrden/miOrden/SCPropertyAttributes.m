/*
 *  SCPropertyAttributes.m
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

#import "SCPropertyAttributes.h"
#import "SCClassDefinition.h"


@implementation SCPropertyAttributes

@synthesize imageView;
@synthesize imageViewArray;
@synthesize expandContentInCurrentView;

- (id)init
{
	if( (self = [super init]) )
	{
		imageView = nil;
		imageViewArray = nil;
        expandContentInCurrentView = FALSE;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[imageView release];
	[imageViewArray release];
	
	[super dealloc];
}
#endif

@end







@implementation SCTextViewAttributes

@synthesize minimumHeight;
@synthesize maximumHeight;
@synthesize autoResize;
@synthesize editable;


+ (id)attributesWithMinimumHeight:(CGFloat)minHeight maximumHeight:(CGFloat)maxHeight
					   autoResize:(BOOL)_autoResize editable:(BOOL)_editable
{
	return SC_Autorelease([[[self class] alloc] initWithMinimumHeight:minHeight maximumHeight:maxHeight 
											 autoResize:_autoResize editable:_editable]);
}

- (id)init
{
	if( (self = [super init]) )
	{
		minimumHeight = FLT_MIN;		// will be ignored
		maximumHeight = FLT_MIN;		// will be ignored
		autoResize = TRUE;
		editable = TRUE;
	}
	return self;
}

- (id)initWithMinimumHeight:(CGFloat)minHeight maximumHeight:(CGFloat)maxHeight
				 autoResize:(BOOL)_autoResize editable:(BOOL)_editable
{
	if( (self=[self init]) )
	{
		self.minimumHeight = minHeight;
		self.maximumHeight = maxHeight;
		self.autoResize = _autoResize;
		self.editable = _editable;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[super dealloc];
}
#endif

@end







@implementation SCTextFieldAttributes

@synthesize placeholder;
@synthesize secureTextEntry;
@synthesize autocorrectionType;
@synthesize autocapitalizationType;

+ (id)attributesWithPlaceholder:(NSString *)_placeholder
{
	return SC_Autorelease([[[self class] alloc] initWithPlaceholder:_placeholder]);
}

+ (id)attributesWithPlaceholder:(NSString *)_placeholder secureTextEntry:(BOOL)secure autocorrectionType:(UITextAutocorrectionType)autocorrection autocapitalizationType:(UITextAutocapitalizationType)autocapitalization
{
    return SC_Autorelease([[[self class] alloc] initWithPlaceholder:_placeholder secureTextEntry:secure autocorrectionType:autocorrection autocapitalizationType:autocapitalization]);
}

- (id)init
{
	if( (self = [super init]) )
	{
		placeholder = nil;		// will be ignored
        secureTextEntry = FALSE;
        autocorrectionType = UITextAutocorrectionTypeDefault;
        autocapitalizationType = UITextAutocapitalizationTypeSentences;
	}
	return self;
}

- (id)initWithPlaceholder:(NSString *)_placeholder
{
	if( (self=[self init]) )
	{
		self.placeholder = _placeholder;
	}
	return self;
}

- (id)initWithPlaceholder:(NSString *)_placeholder secureTextEntry:(BOOL)secure autocorrectionType:(UITextAutocorrectionType)autocorrection autocapitalizationType:(UITextAutocapitalizationType)autocapitalization
{
    if( (self=[self init]) )
	{
		self.placeholder = _placeholder;
        self.secureTextEntry = secure;
        self.autocorrectionType = autocorrection;
        self.autocapitalizationType = autocapitalization;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[placeholder release];
	[super dealloc];
}
#endif

@end







@implementation SCNumericTextFieldAttributes

@synthesize minimumValue;
@synthesize maximumValue;
@synthesize allowFloatValue;
@synthesize numberFormatter;

+ (id)attributesWithMinimumValue:(NSNumber *)minValue maximumValue:(NSNumber *)maxValue
				 allowFloatValue:(BOOL)allowFloat
{
	return SC_Autorelease([[[self class] alloc] initWithMinimumValue:minValue maximumValue:maxValue 
									   allowFloatValue:allowFloat]);
}

+ (id)attributesWithMinimumValue:(NSNumber *)minValue maximumValue:(NSNumber *)maxValue
				 allowFloatValue:(BOOL)allowFloat placeholder:(NSString *)_placeholder
{
	return SC_Autorelease([[[self class] alloc] initWithMinimumValue:minValue maximumValue:maxValue 
									   allowFloatValue:allowFloat
										   placeholder:_placeholder]);
}

- (id)init
{
	if( (self = [super init]) )
	{
		minimumValue = nil;		// will be ignored
		maximumValue = nil;		// will be ignored
		allowFloatValue = TRUE;
        
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	}
	return self;
}

- (id)initWithMinimumValue:(NSNumber *)minValue maximumValue:(NSNumber *)maxValue
		   allowFloatValue:(BOOL)allowFloat
{
	if( (self=[self init]) )
	{
		self.maximumValue = maxValue;
		self.minimumValue = minValue;
		self.allowFloatValue = allowFloat;
	}
	return self;
}

- (id)initWithMinimumValue:(NSNumber *)minValue maximumValue:(NSNumber *)maxValue
		   allowFloatValue:(BOOL)allowFloat placeholder:(NSString *)_placeholder
{
	if( (self=[self initWithPlaceholder:_placeholder]) )
	{
		self.maximumValue = maxValue;
		self.minimumValue = minValue;
		self.allowFloatValue = allowFloat;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[minimumValue release];
	[maximumValue release];
    [numberFormatter release];
    
	[super dealloc];
}
#endif

@end







@implementation SCSliderAttributes

@synthesize minimumValue;
@synthesize maximumValue;

+ (id)attributesWithMinimumValue:(float)minValue maximumValue:(float)maxValue
{
	return SC_Autorelease([[[self class] alloc] initWithMinimumValue:minValue maximumValue:maxValue]);
}

- (id)init
{
	if( (self = [super init]) )
	{
		minimumValue = FLT_MIN;		// will be ignored
		maximumValue = FLT_MIN;		// will be ignored
	}
	return self;
}

- (id)initWithMinimumValue:(float)minValue maximumValue:(float)maxValue
{
	if( (self=[self init]) )
	{
		self.minimumValue = minValue;
		self.maximumValue = maxValue;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[super dealloc];
}
#endif

@end







@implementation SCSegmentedAttributes

@synthesize segmentTitlesArray;

+ (id)attributesWithSegmentTitlesArray:(NSArray *)titles
{
	return SC_Autorelease([[[self class] alloc] initWithSegmentTitlesArray:titles]);
}

- (id)init
{
	if( (self = [super init]) )
	{
		segmentTitlesArray = nil;		// will be ignored
	}
	return self;
}

- (id)initWithSegmentTitlesArray:(NSArray *)titles
{
	if( (self=[self init]) )
	{
		self.segmentTitlesArray = titles;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[segmentTitlesArray release];
	[super dealloc];
}
#endif

@end







@implementation SCDateAttributes

@synthesize dateFormatter;
@synthesize datePickerMode;
@synthesize displayDatePickerInDetailView;

+ (id)attributesWithDateFormatter:(NSDateFormatter *)formatter
{
	return SC_Autorelease([[[self class] alloc] initWithDateFormatter:formatter]);
}

+ (id)attributesWithDateFormatter:(NSDateFormatter *)formatter
				   datePickerMode:(UIDatePickerMode)mode
	displayDatePickerInDetailView:(BOOL)inDetailView
{
	return SC_Autorelease([[[self class] alloc] initWithDateFormatter:formatter
										 datePickerMode:mode
						  displayDatePickerInDetailView:inDetailView]);
}

- (id)init
{
	if( (self = [super init]) )
	{
		dateFormatter = nil;		// will be ignored
		datePickerMode = UIDatePickerModeDateAndTime;
		displayDatePickerInDetailView = FALSE;
	}
	return self;
}

- (id)initWithDateFormatter:(NSDateFormatter *)formatter
{
	if( (self=[self init]) )
	{
		self.dateFormatter = formatter;
	}
	return self;
}

- (id)initWithDateFormatter:(NSDateFormatter *)formatter
			 datePickerMode:(UIDatePickerMode)mode
	displayDatePickerInDetailView:(BOOL)inDetailView
{
	if( (self=[self init]) )
	{
		self.dateFormatter = formatter;
		self.datePickerMode = mode;
		self.displayDatePickerInDetailView = inDetailView;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[dateFormatter release];
	[super dealloc];
}
#endif

@end







@implementation SCSelectionAttributes

@synthesize items;
@synthesize allowMultipleSelection;
@synthesize allowNoSelection;
@synthesize maximumSelections;
@synthesize autoDismissDetailView;
@synthesize hideDetailViewNavigationBar;
@synthesize allowAddingItems;
@synthesize allowDeletingItems;
@synthesize allowMovingItems;
@synthesize allowEditingItems;
@synthesize addNewObjectuiElement;
@synthesize placeholderuiElement;

+ (id)attributesWithItems:(NSArray *)_items allowMultipleSelection:(BOOL)allowMultipleSel
		 allowNoSelection:(BOOL)allowNoSel
{
	return SC_Autorelease([[[self class] alloc] initWithItems:_items allowMultipleSelection:allowMultipleSel
							   allowNoSelection:allowNoSel]);
}

+ (id)attributesWithItems:(NSArray *)_items allowMultipleSelection:(BOOL)allowMultipleSel
		 allowNoSelection:(BOOL)allowNoSel autoDismissDetailView:(BOOL)autoDismiss
			hideDetailViewNavigationBar:(BOOL)hideNavBar
{
	return SC_Autorelease([[[self class] alloc] initWithItems:_items allowMultipleSelection:allowMultipleSel
							   allowNoSelection:allowNoSel 
						  autoDismissDetailView:autoDismiss
					hideDetailViewNavigationBar:hideNavBar]);
}

- (id)init
{
	if( (self = [super init]) )
	{
		items = nil;		// will be ignored
		allowMultipleSelection = FALSE;
		allowNoSelection = FALSE;
		maximumSelections = 0;
		autoDismissDetailView = FALSE;
		hideDetailViewNavigationBar = FALSE;
        
        allowAddingItems = FALSE;
		allowDeletingItems = FALSE;
		allowMovingItems = FALSE;
		allowEditingItems = FALSE;
        
        addNewObjectuiElement = nil;
        placeholderuiElement = nil;
	}
	return self;
}

- (id)initWithItems:(NSArray *)_items allowMultipleSelection:(BOOL)allowMultipleSel
   allowNoSelection:(BOOL)allowNoSel
{
	if( (self=[self init]) )
	{
		self.items = _items;
		self.allowMultipleSelection = allowMultipleSel;
		self.allowNoSelection = allowNoSel;
	}
	return self;
}

- (id)initWithItems:(NSArray *)_items allowMultipleSelection:(BOOL)allowMultipleSel
   allowNoSelection:(BOOL)allowNoSel autoDismissDetailView:(BOOL)autoDismiss
		hideDetailViewNavigationBar:(BOOL)hideNavBar
{
	if( (self=[self init]) )
	{
		self.items = _items;
		self.allowMultipleSelection = allowMultipleSel;
		self.allowNoSelection = allowNoSel;
		self.autoDismissDetailView = autoDismiss;
		self.hideDetailViewNavigationBar = hideNavBar;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[items release];
    [addNewObjectuiElement release];
    [placeholderuiElement release];
    
	[super dealloc];
}
#endif

@end






@implementation SCObjectSelectionAttributes

@synthesize itemsEntityClassDefinition;
@synthesize intermediateEntityClassDefinition;
@synthesize itemsPredicate;

+ (id)attributesWithItemsEntityClassDefinition:(SCClassDefinition *)classDefinition 
                        allowMultipleSelection:(BOOL)allowMultipleSel
							  allowNoSelection:(BOOL)allowNoSel
{
	return SC_Autorelease([[[self class] alloc] initWithItemsEntityClassDefinition:classDefinition
                                              allowMultipleSelection:allowMultipleSel
													allowNoSelection:allowNoSel]);
}

+ (id)attributesWithItemsEntityClassDefinition:(SCClassDefinition *)classDefinition 
					withItemsTitlePropertyName:(NSString *)titlePropertyName
						allowMultipleSelection:(BOOL)allowMultipleSel
							  allowNoSelection:(BOOL)allowNoSel
{
	return SC_Autorelease([[[self class] alloc] initWithItemsEntityClassDefinition:classDefinition
										  withItemsTitlePropertyName:titlePropertyName
											  allowMultipleSelection:allowMultipleSel
													allowNoSelection:allowNoSel]);
}

- (id)init
{
	if( (self = [super init]) )
	{
		itemsEntityClassDefinition = nil;
        intermediateEntityClassDefinition = nil;
		
		itemsPredicate = nil;
	}
	return self;
}

- (id)initWithItemsEntityClassDefinition:(SCClassDefinition *)classDefinition 
                  allowMultipleSelection:(BOOL)allowMultipleSel
						allowNoSelection:(BOOL)allowNoSel
{
	if( (self=[self init]) )
	{
		self.itemsEntityClassDefinition = classDefinition;
		self.allowMultipleSelection = allowMultipleSel;
		self.allowNoSelection = allowNoSel;
	}
	return self;
}

- (id)initWithItemsEntityClassDefinition:(SCClassDefinition *)classDefinition 
			  withItemsTitlePropertyName:(NSString *)titlePropertyName
				  allowMultipleSelection:(BOOL)allowMultipleSel
						allowNoSelection:(BOOL)allowNoSel
{
	if( (self=[self init]) )
	{
		classDefinition.titlePropertyName = titlePropertyName;
        self.itemsEntityClassDefinition = classDefinition;
		self.allowMultipleSelection = allowMultipleSel;
		self.allowNoSelection = allowNoSel;
	}
	return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[itemsEntityClassDefinition release];
    [intermediateEntityClassDefinition release];
	[itemsPredicate release];

	[super dealloc];
}
#endif

@end







@implementation SCObjectAttributes

@synthesize classDefinitions;

+ (id)attributesWithObjectClassDefinition:(SCClassDefinition *)classDefinition
{
	return SC_Autorelease([[[self class] alloc] initWithObjectClassDefinition:classDefinition]);
}

+ (id)attributesWithObjectClassDefinition:(SCClassDefinition *)classDefinition expandContentInCurrentView:(BOOL)expandContent
{
    return SC_Autorelease([[[self class] alloc] initWithObjectClassDefinition:classDefinition expandContentInCurrentView:expandContent]);
}

- (id)init
{
	if( (self = [super init]) )
	{
		classDefinitions = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)initWithObjectClassDefinition:(SCClassDefinition *)classDefinition
{
	if( (self=[self init]) )
	{
		if(classDefinition)
			[self.classDefinitions setValue:classDefinition forKey:classDefinition.className];
	}
	return self;
}

- (id)initWithObjectClassDefinition:(SCClassDefinition *)classDefinition expandContentInCurrentView:(BOOL)expandContent
{
    if( (self=[self initWithObjectClassDefinition:classDefinition]) )
    {
        self.expandContentInCurrentView = expandContent;
    }
    return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
	[classDefinitions release];
	[super dealloc];
}
#endif

@end








@implementation SCArrayOfObjectsAttributes

@synthesize allowAddingItems;
@synthesize allowDeletingItems;
@synthesize allowMovingItems;
@synthesize allowEditingItems;
@synthesize placeholderuiElement;
@synthesize addNewObjectuiElement;
@synthesize addNewObjectuiElementExistsInNormalMode;
@synthesize addNewObjectuiElementExistsInEditingMode;


+ (id)attributesWithObjectClassDefinition:(SCClassDefinition *)classDefinition
						 allowAddingItems:(BOOL)allowAdding allowDeletingItems:(BOOL)allowDeleting
						 allowMovingItems:(BOOL)allowMoving
{
	return SC_Autorelease([[[self class] alloc] initWithObjectClassDefinition:classDefinition
											   allowAddingItems:allowAdding
											 allowDeletingItems:allowDeleting
											   allowMovingItems:allowMoving]);
}

+ (id)attributesWithObjectClassDefinition:(SCClassDefinition *)classDefinition
						 allowAddingItems:(BOOL)allowAdding allowDeletingItems:(BOOL)allowDeleting allowMovingItems:(BOOL)allowMoving 
               expandContentInCurrentView:(BOOL)expandContent 
                     placeholderuiElement:(NSObject *)placeholderUI
                    addNewObjectuiElement:(NSObject *)newObjectUI
  addNewObjectuiElementExistsInNormalMode:(BOOL)existsInNormalMode 
 addNewObjectuiElementExistsInEditingMode:(BOOL)existsInEditingMode
{
    return SC_Autorelease([[[self class] alloc] initWithObjectClassDefinition:classDefinition
											   allowAddingItems:allowAdding
											 allowDeletingItems:allowDeleting
											   allowMovingItems:allowMoving 
                                     expandContentInCurrentView:expandContent
                                           placeholderuiElement:placeholderUI
                                          addNewObjectuiElement:newObjectUI 
                        addNewObjectuiElementExistsInNormalMode:existsInNormalMode 
                       addNewObjectuiElementExistsInEditingMode:existsInEditingMode]); 
}

- (id)init
{
	if( (self = [super init]) )
	{
		allowAddingItems = TRUE;
		allowDeletingItems = TRUE;
		allowMovingItems = TRUE;
		allowEditingItems = TRUE;
        placeholderuiElement = nil;
        addNewObjectuiElement = nil;
        addNewObjectuiElementExistsInNormalMode = TRUE;
        addNewObjectuiElementExistsInEditingMode = TRUE;
	}
	return self;
}

- (id)initWithObjectClassDefinition:(SCClassDefinition *)classDefinition
				   allowAddingItems:(BOOL)allowAdding allowDeletingItems:(BOOL)allowDeleting
				   allowMovingItems:(BOOL)allowMoving
{
	if( (self=[self initWithObjectClassDefinition:classDefinition]) )
	{
		allowAddingItems = allowAdding;
		allowDeletingItems = allowDeleting;
		allowMovingItems = allowMoving;
	}
	return self;
}

- (id)initWithObjectClassDefinition:(SCClassDefinition *)classDefinition
                   allowAddingItems:(BOOL)allowAdding allowDeletingItems:(BOOL)allowDeleting allowMovingItems:(BOOL)allowMoving  
         expandContentInCurrentView:(BOOL)expandContent
               placeholderuiElement:(NSObject *)placeholderUI
              addNewObjectuiElement:(NSObject *)newObjectUI
addNewObjectuiElementExistsInNormalMode:(BOOL)existsInNormalMode 
addNewObjectuiElementExistsInEditingMode:(BOOL)existsInEditingMode
{
    if( (self=[self initWithObjectClassDefinition:classDefinition allowAddingItems:allowAdding allowDeletingItems:allowDeleting allowMovingItems:allowMoving]) )
    {
        self.expandContentInCurrentView = expandContent;
        self.placeholderuiElement = placeholderUI;
        self.addNewObjectuiElement = newObjectUI;
        self.addNewObjectuiElementExistsInNormalMode = existsInNormalMode;
        self.addNewObjectuiElementExistsInEditingMode = existsInEditingMode;
    }
    return self;
}

#ifndef ARC_ENABLED
- (void)dealloc
{
    [placeholderuiElement release];
    [addNewObjectuiElement release];
    
    [super dealloc];
}
#endif

@end






