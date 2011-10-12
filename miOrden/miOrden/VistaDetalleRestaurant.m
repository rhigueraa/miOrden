//
//  VistaDetalleRestaurant.m
//  miOrden
//
//  Created by Rodrigo Higuera on 7/13/11.
//  Copyright 2011 ITAM. All rights reserved.
//

#import "VistaDetalleRestaurant.h"
#import "VistaMenu.h"
#import "UIImageView+WebCache.h"
#import "VistaResenias.h"
#import "HotelesAnnotation.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation VistaDetalleRestaurant

@synthesize restaruantImageView;
@synthesize restaruanExtraDetailView;
@synthesize table;
@synthesize pagedView;
@synthesize table2;
@synthesize currentRestaurant;
@synthesize direccion;

#pragma mark - Memory Managment

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
    [restaruanExtraDetailView release];
    [table2 release];
    [restaruantImageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)isRestaurantOpen:(NSDictionary*)restaurant{
    NSString *urlString = [NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/isRestOpen.php?restId=%@",[restaurant valueForKey:@"id"]];
    __block ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setCompletionBlock:^{
        NSString* responseString = [request responseString];
        int isOpen = [responseString intValue];
        open = isOpen;
        [self.table2 reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [request startAsynchronous];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    direccion.text = [currentRestaurant valueForKey:@"address"];
    pagedView.backgroundColor = [UIColor redColor];
    pagedVIew = [[ATPagingView alloc] initWithFrame:pagedView.bounds];
    pagedVIew.delegate = self;
    [pagedView addSubview:pagedVIew];
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(141, 244+1, 38, 36)];
    pageControl.numberOfPages = 3;
    [pageControl addTarget:self action:@selector(pagedControlIndexChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];
    
    //Load image onto image view
    [restaruantImageView setImageWithURL:[NSURL URLWithString:[currentRestaurant valueForKey:@"logo"]] placeholderImage:[UIImage imageNamed:@"placeholder-recipe-44.gif"]];
    restaruantImageView.layer.cornerRadius = 10.0;
    restaruantImageView.layer.masksToBounds = YES;
    restaruantImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    restaruantImageView.layer.borderWidth = 1.0;
    restaruantImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    //review count
    VistaResenias *resenia =[[VistaResenias alloc] initWithStyle:UITableViewStyleGrouped];
    resenia.currentRestaurant = self.currentRestaurant;
    numeroResenias = [resenia.resenias count];
    [resenia release];
    
    //map annotations
    
    if (!theMapView) {
        theMapView = [[MKMapView alloc] initWithFrame:pagedView.bounds];
        theMapView.delegate = self;
       theMapView.userInteractionEnabled = NO;
        theMapView.showsUserLocation = YES;
    }
    NSDictionary *coordenadas = [[NSDictionary alloc] initWithObjectsAndKeys:[currentRestaurant valueForKey:@"lon"],@"longitudKey",
    [currentRestaurant valueForKey:@"lat"],@"latitudKey", nil];
    HotelesAnnotation *ann = [[HotelesAnnotation alloc] initWithHotel:coordenadas];
    ann.title = [currentRestaurant valueForKey:@"name"];
    [theMapView addAnnotation:ann];
    [theMapView setCenterCoordinate:ann.coordinate];
    MKCoordinateRegion region = {ann.coordinate, {0.01f, 0.01f}};
    [theMapView setRegion:region];
    
    [coordenadas release];
    
    /*
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Lista" style:UIBarButtonItemStyleDone target:self action:@selector(didPressBack)];
    self.navigationItem.leftBarButtonItem= backItem;
    [backItem release];
     */
   
}

- (void)didPressBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pagedControlIndexChanged:(UIPageControl*)sender{
    [pagedVIew setCurrentPageIndex:sender.currentPage];
}

- (void)viewWillAppear:(BOOL)animated{
    [pagedVIew reloadData];
    [table deselectRowAtIndexPath:[table indexPathForSelectedRow] animated:YES];
    XMLThreadedParser *parser = [[XMLThreadedParser alloc] init];
    parser.delegate = self;
    
    [parser parseXMLat:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.miorden.com/demo/iphone/reviewlist.php?id=%@",[currentRestaurant valueForKey:@"id"]]] withKey:@"review"];
}

- (void)viewDidUnload
{
    [self setPagedView:nil];
    [table   release];
    [self setRestaruanExtraDetailView:nil];
    [self setTable2:nil];
    [self setRestaruantImageView:nil];
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
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == table) {
        return 40;
    }
    else{
        return 44;
    }
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == table) {
        return 2;
    }
    else{
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell1";
    static NSString *CellIdentifier2 = @"Cell2";
    
    UITableViewCell *cell;
    
    if (tableView == table)
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    
    if (cell == nil) {
        if (tableView == table)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        else
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier2] autorelease];
    }
    else{
        cell.textLabel.textAlignment = UITextAlignmentLeft;
    }
    
    if (tableView == table){
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        if(indexPath.row == 1){
            cell.imageView.image = [UIImage imageNamed:@"estrellitas.png"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d reseñas", numeroResenias];
            
                       
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.textLabel.text = @"Ver menú"; 
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else{
        if(indexPath.row == 0){
            cell.textLabel.text = @"Orden mínima";
            cell.detailTextLabel.text =[NSString stringWithFormat:@"$%d.00",[[currentRestaurant valueForKey:@"deliver_minimum"] intValue]];
        }else if (indexPath.row == 1){
            if (open) {
                cell.imageView.image = [UIImage imageNamed:@"abierto.png"];
            }
            else{
                cell.imageView.image = [UIImage imageNamed:@"cerado.png"];
            }
            if (hours) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [hours valueForKey:@"opening"],[hours valueForKey:@"closing"]];
            }
            //cell.detailTextLabel.text = @"9:00 - 21:00";
        }
        else if(indexPath.row == 2 ){
            cell.textLabel.text = @"Costo de envío";
            if([[currentRestaurant valueForKey:@"tipo_envio"]isEqualToString:@"porcentaje"])
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d.00\%%",[[currentRestaurant valueForKey:@"costo_envio"] intValue]];
            else
                cell.detailTextLabel.text = [NSString stringWithFormat:@"$%d.00",[[currentRestaurant valueForKey:@"costo_envio"] intValue]];
        }
        else{
            cell.textLabel.text = @"Pago";
            NSMutableArray *images = [NSMutableArray array];
            if ([[currentRestaurant valueForKey:@"efectivo1"] intValue]) {
                [images addObject:[UIImage imageNamed:@"cash.png"]];
            }
            if ([[currentRestaurant valueForKey:@"visa1"] intValue]) {
                [images addObject:[UIImage imageNamed:@"visa.png"]];
            }
            if ([[currentRestaurant valueForKey:@"ms1"] intValue]) {
                [images addObject:[UIImage imageNamed:@"mastercard.png"]];
            }
            if ([[currentRestaurant valueForKey:@"am1"] intValue]) {
                [images addObject:[UIImage imageNamed:@"amex.png"]];
            }
            UISegmentedControl *segmetnedPayments = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithArray:images]];
            segmetnedPayments.frame = CGRectMake(0, 0, 200, 38);
            cell.accessoryView = segmetnedPayments;
        }
    }
    
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
        if(indexPath.row == 0){
          VistaMenu *menu = [[VistaMenu alloc] init];
            menu.currentRestaurant = self.currentRestaurant;
          [self.navigationController pushViewController:menu animated:YES];
          [menu release];
        }else{
            VistaResenias *resenia =[[VistaResenias alloc] initWithStyle:UITableViewStyleGrouped];
            resenia.currentRestaurant = self.currentRestaurant;
            [self.navigationController pushViewController:resenia animated:YES];
            [resenia release];
        }
}

#pragma mark - PagedView

- (NSInteger)numberOfPagesInPagingView:(ATPagingView *)pagingView{
    return 3;
}

- (UIView *)viewForPageInPagingView:(ATPagingView *)pagingView atIndex:(NSInteger)index{
    
    switch (index) {
        case 0:
            //Details
            return restaruanExtraDetailView;
            break;
        case 1:
            //Map
            if (!theMapView) {
                theMapView = [[MKMapView alloc] initWithFrame:pagedView.bounds];
                theMapView.showsUserLocation = YES;
                theMapView.delegate = self;
                theMapView.userInteractionEnabled = NO;
            }
            
            return theMapView;
            break;
        case 2:{
            //Notes
            UITextView *detailVIew = [[UITextView alloc] initWithFrame:pagedView.bounds];
            detailVIew.text = [NSString stringWithFormat:@"Descripción:\n%@ \nNotas:\n%@\n",[currentRestaurant valueForKey:@"description"],[currentRestaurant valueForKey:@"special_note"]];
            detailVIew.font = [UIFont systemFontOfSize:17];
            detailVIew.editable = NO;
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
- (MKAnnotationView *)mapView:(MKMapView *)mapView 
            viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *view = nil;
    if(annotation != theMapView.userLocation) {
		HotelesAnnotation *hotAnn = (HotelesAnnotation*)annotation;
		view = [theMapView dequeueReusableAnnotationViewWithIdentifier:@"hotelLoc"];
		if(nil == view) {
			view = [[[MKPinAnnotationView alloc] initWithAnnotation:hotAnn
                                                    reuseIdentifier:@"HotelLoc"] autorelease];
		}
        [(MKPinAnnotationView *)view setAnimatesDrop:YES];
		[view setCanShowCallout:YES];
               
    }
    return view;
}

-(void)parser:(XMLThreadedParser*)parser didParseObject:(NSDictionary*)object{
    
}

-(void)parser:(XMLThreadedParser*)parser didFinishParsing:(NSArray*)array{
    numeroResenias = [[array retain]count];
    NSLog(@"Número de reseñas: %d", numeroResenias);

    [self.table beginUpdates];
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.table endUpdates];
}



@end
