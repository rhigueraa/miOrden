//
//  VistaCarrito.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/15/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VistaCarrito : UITableViewController {
    IBOutlet UILabel *subtotal;
    IBOutlet UILabel *envio;
    IBOutlet UILabel *total;
    
    NSArray *carrito;
    
    
}



@end
