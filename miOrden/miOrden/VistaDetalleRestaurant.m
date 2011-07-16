//
//  VistaDetalleRestaurant.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaDetalleRestaurant.h"
#import "VistaUbicacionRestaurant.h"
#import "VistaMenu.h"


@implementation VistaDetalleRestaurant

@synthesize table;
@synthesize pagedView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [pagedView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    pagedVIew = [[ATPagingView alloc] initWithFrame:pagedView.bounds];
    pagedVIew.delegate = self;
    [pagedView addSubview:pagedVIew];
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(141, 223, 38, 36)];
    pageControl.numberOfPages = 3;
    [pageControl addTarget:self action:@selector(pagedControlIndexChanged:) forControlEvents:UIControlEventValueChanged];
    [pagedView addSubview:pageControl];
}

- (void)pagedControlIndexChanged:(UIPageControl*)sender{
    [pagedVIew setCurrentPageIndex:sender.currentPage];
}

- (void)viewWillAppear:(BOOL)animated{
    [pagedVIew reloadData];
}

- (void)viewDidUnload
{
    [self setPagedView:nil];
    [table   release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if(indexPath.row == 0)
        cell.textLabel.text = @"Reseñas";
    else
        cell.textLabel.text = @"Ver menú";
    
    /*
    switch (indexPath.section) {
        case 0:
            if(indexPath.row == 0)
                cell.textLabel.text = @"Orden mínima";
            else if(indexPath.row == 1 )
                cell.textLabel.text = @"Costo de envío";
            else
                cell.textLabel.text = @"Pago";
            break;
        case 1:
            
        default:
            break;
    }
    */
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        if(indexPath.row == 1){
          VistaMenu *menu = [[VistaMenu alloc] init];
          [self.navigationController pushViewController:menu animated:YES];
          [menu release];
        }
}

#pragma mark - PagedView

- (NSInteger)numberOfPagesInPagingView:(ATPagingView *)pagingView{
    return 3;
}

- (UIView *)viewForPageInPagingView:(ATPagingView *)pagingView atIndex:(NSInteger)index{
    
    switch (index) {
        case 0:{
            //Details
            UIView *detailVIew = [[UIView alloc] initWithFrame:pagedView.bounds];
            detailVIew.backgroundColor = [UIColor redColor];
            return detailVIew;
        }
            break;
        case 1:
            //Map
            if (!theMapView) {
                theMapView = [[MKMapView alloc] initWithFrame:pagedView.bounds];
                theMapView.delegate = self;
                theMapView.userInteractionEnabled = NO;
            }
            
            return theMapView;
            break;
        case 2:{
            //Notes
            UIView *detailVIew = [[UIView alloc] initWithFrame:pagedView.bounds];
            detailVIew.backgroundColor = [UIColor redColor];
            return detailVIew;
        }
            
            break;
        default:
            return nil;
            break;
    }
}

- (void)currentPageDidChangeInPagingView:(ATPagingView *)pagingViewS{
    pageControl.currentPage = pagingViewS.currentPageIndex;
}

#pragma mark - MapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    
}


@end
