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
    
    self = [self stringByReplacingOccurrencesOfString: @"\\u00e1" withString:@"á"];
    
    self = [self stringByReplacingOccurrencesOfString: @"\\u00e9" withString:@"é"];
    
    self = [self stringByReplacingOccurrencesOfString: @"\\u00e1" withString:@"í"];
    
    self = [self stringByReplacingOccurrencesOfString: @"\\u00e9" withString:@"ó"];
    
    self = [self stringByReplacingOccurrencesOfString: @"\\u00e1" withString:@"ú"];
    
    return self;
}

@end
