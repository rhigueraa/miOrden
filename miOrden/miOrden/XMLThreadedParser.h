//
//  XMLThreadedParser.h
//  iPadConaculta
//
//  Created by Zebas Barrios on 11/13/10.
//  Copyright 2010 Zebas Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"

@protocol XMLThreadedParserDelegate;

@interface XMLThreadedParser : NSObject {

	NSURLConnection* connection;
	NSMutableData* data;
	NSString *searchKey;
	NSNumber* tagg;
	
	id<XMLThreadedParserDelegate> delegate;
}

@property(nonatomic,retain)id<XMLThreadedParserDelegate> delegate;
@property(nonatomic,retain)NSNumber* tagg;

- (void)parseXMLat:(NSURL*)url withKey: (NSString*)key;

- (void)parseXMLData:(NSData*)data withKey: (NSString*)key;

@end

@protocol XMLThreadedParserDelegate <NSObject>

-(void)parser:(XMLThreadedParser*)parser didParseObject:(NSDictionary*)object;
    
@optional

-(void)parser:(XMLThreadedParser*)parser didFinishParsing:(NSArray*)array;

@end