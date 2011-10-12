//
//  CustomActionNavigationController.m
//  miOrden
//
//  Created by Sebastian Barrios on 9/17/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "CustomActionNavigationController.h"
#import "VistaDetalleRestaurant.h"

@implementation CustomActionNavigationController

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    
    return [super popViewControllerAnimated:animated];
    
	if([[self.viewControllers lastObject] class] == [VistaDetalleRestaurant class]){
       
	} else {
		return [super popViewControllerAnimated:animated];
	}
}

@end
