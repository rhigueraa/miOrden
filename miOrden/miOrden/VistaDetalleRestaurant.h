//
//  VistaDetalleRestaurant.h
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VistaDetalleRestaurant : UIViewController<UITableViewDelegate> {
    UITableView  *table;
    IBOutlet UIImage *image;
    IBOutlet UITextView *text;
   
}


-(IBAction) enviarPressed: (UIButton *) sender;
@property(nonatomic,retain) IBOutlet UITableView *table;

@end
