//
//  NSString+AccentCorrection.m
//  miOrden
//
//  Created by Sebastian Barrios on 8/10/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "NSString+AccentCorrection.h"

@implementation NSString (NSString_AccentCorrection)

- (NSString*)fixAccents{
    
    NSString *mutString = [self copy];
    
    NSLog(@"String before: %@", mutString);
    
    mutString = [mutString stringByReplacingOccurrencesOfString:@"\\u00e1" withString:@"á"];
    
    mutString = [mutString stringByReplacingOccurrencesOfString: @"\\u00e9" withString:@"é"];
    
    mutString = [mutString stringByReplacingOccurrencesOfString: @"\\u00ed" withString:@"í"];
    
    mutString = [mutString stringByReplacingOccurrencesOfString: @"\\u00d3" withString:@"ó"];
    
    mutString = [mutString stringByReplacingOccurrencesOfString: @"\\u00fa" withString:@"ú"];
    
    mutString = [mutString stringByReplacingOccurrencesOfString: @"\\u00c3" withString:@""];
    
    mutString = [mutString stringByReplacingOccurrencesOfString: @"\\U00e1" withString:@"á"];
    
    mutString = [mutString stringByReplacingOccurrencesOfString: @"\\U00e9" withString:@"é"];
    
    mutString = [mutString stringByReplacingOccurrencesOfString: @"\\U00ed" withString:@"í"];
    
    mutString = [mutString stringByReplacingOccurrencesOfString: @"\\U00d3" withString:@"ó"];
    
    mutString = [mutString stringByReplacingOccurrencesOfString: @"\\U00fa" withString:@"ú"];
    
    NSLog(@"String after: %@", mutString);
    
    return mutString;
}

@end
