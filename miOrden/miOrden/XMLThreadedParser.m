//
//  XMLThreadedParser.m
//  iPadConaculta
//
//  Created by Zebas Barrios on 11/13/10.
//  Copyright 2010 Zebas Studios. All rights reserved.
//

#import "XMLThreadedParser.h"


@implementation XMLThreadedParser
@synthesize delegate,tagg;

-(void)parse{
	// Initialize the blogEntries MutableArray that we declared in the header
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];	
    
    // Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the
    // object that actually grabs and processes the RSS data
 
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithData:data encoding:NSISOLatin1StringEncoding options:0 error:nil] autorelease];
	
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
	
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:[NSString stringWithFormat:@"//%@",searchKey] error:nil];
	
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
		
        // Create a temporary MutableDictionary to store the items fields in, which will eventually end up in blogEntries
        NSMutableDictionary *blogItem = [[[NSMutableDictionary alloc] init] autorelease];
		
        // Create a counter variable as type "int"
        int counter;
		
        // Loop through the children of the current  node
        for(counter = 0; counter < [resultElement childCount]; counter++) {
			
            // Add each field to the blogItem Dictionary with the node name as key and node value as the value
            [blogItem setObject:[[resultElement childAtIndex:counter] stringValue] forKey:[[resultElement childAtIndex:counter] name]];
        }
		
        // Add the blogItem to the global blogEntries Array so that the view can access it.
		[delegate parser:self didParseObject:[blogItem copy]];
        [result addObject:[blogItem copy]];
    }
    if ([delegate respondsToSelector:@selector(parser: didFinishParsing:)]) {
        [delegate parser:self didFinishParsing:result];
    }
}

- (void)parseXMLat:(NSURL*)url withKey: (NSString*)key{
	
	searchKey=key;
	
	if (connection!=nil) { [connection release]; } //in case we are downloading a 2nd image
	if (data!=nil) { [data release]; }
	
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //notice how delegate set to self objec
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)parseXMLData:(NSData*)dataA withKey: (NSString*)key{
    searchKey=key;
    data = [dataA mutableCopy];
    [self parse];
}

//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; } 
	[data appendData:incrementalData];
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	[self parse];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error de Conexión" message:@"Es necesario estar coenctado a una red para descargar la información." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NoInternetNotification" object:nil];
	
}
	

-(void)dealloc{
	[connection cancel]; //in case the URL is still downloading
	[connection release];
	[data release]; 
    [super dealloc];
}

@end
