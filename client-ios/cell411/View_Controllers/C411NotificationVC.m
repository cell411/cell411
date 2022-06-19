//
//  C411NotificationVC.m
//  cell411
//
//  Created by Milan Agarwal on 24/04/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411NotificationVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "C411CustomNotificationCell.h"
#import "C411ColorHelper.h"

@interface C411NotificationVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tblVuNotifications;

@property (nonatomic, strong) NSMutableArray *arrNotifications;

@end

@implementation C411NotificationVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///Remove top padding of 35 pixel
    self.tblVuNotifications.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    [self configureViews];
    [self refreshViews];
    [self registerForNotifications];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ///Unhide the navigation bar
    self.navigationController.navigationBarHidden = NO;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    self.title = NSLocalizedString(@"Notifications", nil);
    if (@available(iOS 11, *)) {
        //self.navigationController.navigationBar.prefersLargeTitles = YES;
        ///Above line is commented to disable large title temporarily to fix an issue(Navigation bar background color gets cleared for large titles) until we switch to Xcode 11 having base SDK as iOS 13 for compilation that provides the new UINavigationBarAppearance Class using which we can set same appearance for all scrollEdgeAppearance, standardAppearance and compactAppearance to resolve the issue as provided here: https://stackoverflow.com/a/56696967/3412051
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)applyColors {
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
}

-(void)refreshViews
{
    ///empty tableview
    self.arrNotifications = nil;
    [self.tblVuNotifications reloadData];
    
    //show loading indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ///make a query on cell411alert class to fetch the custom alerts
    PFQuery *fetchCustomAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchCustomAlertsQuery whereKey:kCell411AlertAlertTypeKey equalTo:kAlertTypeCustom];
    
    [fetchCustomAlertsQuery orderByDescending:@"createdAt"];
    fetchCustomAlertsQuery.limit = 1000;
    __weak typeof(self) weakSelf = self;
    
    [fetchCustomAlertsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        ///hide loading screen
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

        if (!error) {
            
            ///Filter out the deleted alerts
            weakSelf.arrNotifications = [NSMutableArray arrayWithArray:objects];
            
            [weakSelf.tblVuNotifications reloadData];
            
            
        }
        else{
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"#error fetching cell411alert :%@",errorString);
            }
            
        }
        
        
    }];
    
    
    
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//****************************************************
#pragma mark - UITableViewDatasource and Delegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.arrNotifications.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    
    static NSString *cellId = @"C411CustomNotificationCell";
    C411CustomNotificationCell *customNotificationCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (rowIndex < self.arrNotifications.count) {
        PFObject *customAlert = [self.arrNotifications objectAtIndex:rowIndex];
        [customNotificationCell setDataUsingObject:customAlert];
    }
    
    return customNotificationCell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    if (rowIndex < self.arrNotifications.count) {
        
        ///Return height of Custom Notification Cell
        ///Create a static cell for each reuse identifier
        static C411CustomNotificationCell *customNotificationCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            customNotificationCell = [tableView dequeueReusableCellWithIdentifier:@"C411CustomNotificationCell"];
            
        });
        
        
        ///Configure cell
        PFObject *customAlert = [self.arrNotifications objectAtIndex:rowIndex];
        [customNotificationCell setDataUsingObject:customAlert];
        
        ///Calculate height
        return [self tableView:tableView calculateHeightForConfiguredSizingCell:customNotificationCell];

    }
    else{
        
        return 0;
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//****************************************************
#pragma mark - tableView:heightForRowAtIndexPath Helper Methods
//****************************************************


- (CGFloat)tableView:(UITableView *)tableView calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height);
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    float height = size.height + 1.0f; // Add 1.0f for the cell separator height
    
    //height = height < MIN_ROW_HEIGHT ? MIN_ROW_HEIGHT : height;
    
    return height;
}

//****************************************************
#pragma mark - Notifications Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


@end
