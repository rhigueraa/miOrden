//
//  FilterTableView.h
//  miOrden
//
//  Created by Sebastian Barrios on 9/12/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"

@protocol FilterTableViewDelegate;

@interface FilterTableView : UITableViewController <SCTableViewModelDelegate>{
    SCTableViewModel *tableModel;
    NSArray *foodTypes;
}

@property (nonatomic,assign) id<FilterTableViewDelegate> delegate;
@property (nonatomic, assign) NSMutableArray *cocinas;
@end

@protocol FilterTableViewDelegate <NSObject>

- (void)filterDidFinishWithPredicate:(NSPredicate*)predicate;

@end
