//
//  AddItemViewController.m
//  Fresh-Chef-Analytics
//
//  Created by jpearl on 7/31/19.
//  Copyright © 2019 julia@ipearl.net. All rights reserved.
//

#import "AddItemViewController.h"
#import "WaitTableViewCell.h"
#import "Helpful_funs.h"
#import "MenuManager.h"
#import "OrderManager.h"
#import "WaiterManager.h"
#import "EditOrderViewController.h"


@interface AddItemViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *ordersTableView;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSArray<OpenOrder *>*>* totalOpenTables;
@property (strong, nonatomic) NSArray<NSString *>* keys;
@property (strong, nonatomic) NSMutableDictionary<NSString *, Waiter *>*tableWaiterDictionary;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray <Dish *>*allDishes;
@property (strong, nonatomic) NSArray <Dish *>*filteredDishes;
@property (strong, nonatomic) NSMutableArray <Dish *>*orderedDishes;
@property (strong, nonatomic) NSMutableArray <NSNumber *>*amounts;
@property (strong, nonatomic) Waiter *waiter;
@property (strong, nonatomic) NSNumber *table;
@property (strong, nonatomic) NSNumber *customerNum;
@property (strong, nonatomic) NSMutableArray <OpenOrder *>* openOrdersFromEdit;
- (IBAction)addToOrder:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.openOrdersFromEdit = [[NSMutableArray alloc] init];
    self.openOrdersFromEdit = [self.delegate getEditableOpenOrders];
    self.waiter = [self.delegate getWaiter];
    self.table = [self.delegate getTable];
    self.customerNum = [self.delegate getCustomerNum];
    self.ordersTableView.delegate = self;
    self.ordersTableView.dataSource = self;
    self.orderedDishes = [[NSMutableArray alloc] init];
    self.amounts = [[NSMutableArray alloc] init];
    [self runDishQuery];
    self.searchBar.delegate = self;
    self.orderedDishes = [[NSMutableArray alloc] init];
    self.amounts = [[NSMutableArray alloc] init];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(runDishQuery) forControlEvents:UIControlEventValueChanged];
    [self.ordersTableView insertSubview:refreshControl atIndex:0];
    self.ordersTableView.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.filteredDishes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WaitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Item"];
    Dish *dish = self.filteredDishes[indexPath.row];
    cell.dish = dish;
    cell.name.text = dish.name;
    cell.type.text = dish.type;
    cell.stepper.dish = dish;
    int index = [[Helpful_funs shared] findAmountIndexwithDishArray:self.orderedDishes withDish:dish];
    if (index == -1){
        cell.stepper.value = 0;
    } else {
        cell.stepper.value = [self.amounts[index] doubleValue];
    }
    cell.dishDescription.text = dish.dishDescription;
    PFFileObject *dishImageFile = (PFFileObject *)dish.image;
    [dishImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if(!error){
            cell.image.image = [UIImage imageWithData:imageData];
        }
    }];
    cell.amount.text = [NSString stringWithFormat:@"%.0f", cell.stepper.value];
    return cell;
}

-(void)runDishQuery{
    NSArray <Dish *>*dishes = [[MenuManager shared] dishes];
    if (dishes.count != 0){
        self.allDishes = dishes;
        self.filteredDishes = dishes;
        [self.ordersTableView reloadData];
        [self.refreshControl endRefreshing];
    }
    else {
        [self.refreshControl endRefreshing];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"name"] containsString:searchText];
        }];
        self.filteredDishes = [self.allDishes filteredArrayUsingPredicate:predicate];
    }
    else {
        self.filteredDishes = self.allDishes;
    }
    [self.ordersTableView reloadData];
}

- (IBAction)stepperChange:(specialStepper *)sender {
    int index = [[Helpful_funs shared] findAmountIndexwithDishArray:self.orderedDishes withDish:sender.dish];
    if (index == -1){
        [self.orderedDishes addObject:sender.dish];
        [self.amounts addObject:[NSNumber numberWithInt:1]];
    } else {
        self.amounts[index] = [NSNumber numberWithDouble:sender.value];
    };
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EditOrderViewController *editVC = [segue destinationViewController];
    NSArray *oldOpenOrders = [[NSArray alloc] init];
    oldOpenOrders = [self.delegate getOldOpenOrders];
    editVC.waiter = self.waiter;
    editVC.editableOpenOrders =  self.openOrdersFromEdit;
    editVC.openOrders = oldOpenOrders;

}




- (IBAction)addToOrder:(UIBarButtonItem *)sender {
    //create new open orders from dish array
    //make an array of openOrders to pass to edit Orders using delegate method
    
    if (self.amounts.count != 0 && (!([[Helpful_funs shared]arrayOfZeros:self.amounts]))){
        for (int i = 0; i < self.amounts.count; i++){
            if (self.amounts[i] != [NSNumber numberWithInt:0]){
                OpenOrder *openOrderNew = [OpenOrder new];
                openOrderNew.dish = self.orderedDishes[i];
                NSLog(@"%@, %@", self.orderedDishes[i].name, self.amounts[i]);
                openOrderNew.amount = self.amounts[i];
                openOrderNew.waiter = self.waiter;
                openOrderNew.restaurant = [PFUser currentUser];
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
                openOrderNew.table = self.table;
                openOrderNew.restaurantId = [PFUser currentUser].objectId;
                openOrderNew.customerNum = self.customerNum;
                [self.openOrdersFromEdit addObject:openOrderNew];
            }
        }
        
        [self performSegueWithIdentifier:@"toEdit" sender:self];
    }
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"toEdit" sender:self];
}
@end