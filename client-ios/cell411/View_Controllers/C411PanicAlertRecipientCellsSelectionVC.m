//
//  C411PanicAlertRecipientSelectionVC.m
//  cell411
//
//  Created by Milan Agarwal on 30/08/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411PanicAlertRecipientCellsSelectionVC.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411StaticHelper.h"
#import "C411AppDefaults.h"
#import "C411CellSelectionCell.h"
#import "AppDelegate.h"
#import "C411ColorHelper.h"

@interface C411PanicAlertRecipientCellsSelectionVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblVuCells;

@property (nonatomic, strong) NSArray *arrAvailableCells;

@end

@implementation C411PanicAlertRecipientCellsSelectionVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///Remove top padding of 35 pixel
    self.tblVuCells.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    [self applyColors];
    [self registerForNotifications];
    NSString *strTitle = nil;
    if (self.cellSelectionType == CellSelectionTypePublic) {
        ///Fetch the public cells
        [self fetchPublicCells];
        strTitle = NSLocalizedString(@"Select Public Cells", nil);
    }
    else if (self.cellSelectionType == CellSelectionTypePrivate) {
        ///Try to get the private cells locally if available
        NSArray *arrCells = [C411AppDefaults sharedAppDefaults].arrCells;
        if (arrCells) {
            ///Private cell are available locally
            self.arrAvailableCells = arrCells;
            
        }
        else{
            ///Fetch the private cells
            [self fetchPrivateCells];
            
        }
        strTitle = NSLocalizedString(@"Select Private Cells", nil);
    }
#if NON_APP_USERS_ENABLED
    else if (self.cellSelectionType == CellSelectionTypeNau) {
        ///Try to get the Nau cells locally if available
        NSArray *arrCells = [C411AppDefaults sharedAppDefaults].arrNonAppUserCells;
        if (arrCells) {
            ///Nau cell are available locally
            self.arrAvailableCells = arrCells;
            
        }
        else{
            ///Fetch the Nau cells
            [self fetchNauCells];
            
        }
        strTitle = NSLocalizedString(@"Select Contacts", nil);
    }
#endif
    self.title = strTitle;
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [self unregisterFromNotifications];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//****************************************************
#pragma mark - Overridden Methods
//****************************************************
-(void)mag_viewDidBack {
    [super mag_viewDidBack];
    [self.delegate cellSelectionVCDidTapBack:self];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)applyColors {
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)fetchPrivateCells
{
    ///Show progress hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *getCellsQuery = [PFQuery queryWithClassName:kCellClassNameKey];
    [getCellsQuery whereKey:kCellCreatedByKey equalTo:currentUser];
    [getCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (!error) {
            
            weakSelf.arrAvailableCells = [NSMutableArray arrayWithArray:objects];
            
            ///Reload Table view
            [weakSelf.tblVuCells reloadData];

        }
        else {
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
            }
            
            
        }

        ///Hide the hud
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

    }];

}

#if NON_APP_USERS_ENABLED
-(void)fetchNauCells
{
    ///Show progress hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *getCellsQuery = [PFQuery queryWithClassName:kNonAppUserCellClassNameKey];
    [getCellsQuery whereKey:kNonAppUserCellCreatedByKey equalTo:currentUser];
    [getCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (!error) {
            
            weakSelf.arrAvailableCells = [NSMutableArray arrayWithArray:objects];
            
            ///Reload Table view
            [weakSelf.tblVuCells reloadData];
            
        }
        else {
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
            }
            
            
        }
        
        ///Hide the hud
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
    }];
    
}
#endif



-(void)fetchPublicCells
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakself = self;
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *getPublicCellsQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
    [getPublicCellsQuery whereKey:kPublicCellMembersKey equalTo:currentUser];
    [getPublicCellsQuery whereKey:kPublicCellTotalMembersKey greaterThan:@1];
    [getPublicCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (!error) {
            
            weakself.arrAvailableCells = [NSMutableArray arrayWithArray:objects];
            
            ///Reload Table view
            [weakself.tblVuCells reloadData];
            
            
        }
        else {
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakself];
            }
            
            
        }
        
        ///Hide the hud
        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
        
        
    }];
    
}


-(BOOL)isCellSelectedWithId:(NSString *)strCellId
{
    BOOL isCellSelected = NO;
    
    for (NSDictionary *dictSelectedCell in self.arrSelectedCells) {
        NSString *strSelectedCellId = [dictSelectedCell objectForKey:kPanicAlertRecipientSelectedCellIdKey];
        if ([strCellId isEqualToString:strSelectedCellId]) {
            isCellSelected = YES;
            break;
        }
        
    }
    
    return isCellSelected;
}

-(NSUInteger)selectedIndexOfCellId:(NSString *)strCellId
{
    NSUInteger cellIndex = NSNotFound;
    NSUInteger counter = 0;
    for (NSDictionary *dictSelectedCell in self.arrSelectedCells) {
        NSString *strSelectedCellId = [dictSelectedCell objectForKey:kPanicAlertRecipientSelectedCellIdKey];
        if ([strCellId isEqualToString:strSelectedCellId]) {
            cellIndex = counter;
            break;
        }
        
        counter++;
        
    }
    
    return cellIndex;
}


//****************************************************
#pragma mark - UITableViewDatasource and delegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.arrAvailableCells.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    
 
    ///Create and Return cell
    static NSString *cellSelectionCellId = @"C411CellSelectionCell";
    C411CellSelectionCell *cellSelectionCell = [tableView dequeueReusableCellWithIdentifier:cellSelectionCellId];
    
    ///Get Cell object
    PFObject *cell = [self.arrAvailableCells objectAtIndex:rowIndex];
    
    ///Set Cell name
    if (self.cellSelectionType == CellSelectionTypePublic) {
        
        cellSelectionCell.lblCellName.text = cell[kPublicCellNameKey];
    }
    else if (self.cellSelectionType == CellSelectionTypePrivate) {
        
        cellSelectionCell.lblCellName.text = [C411StaticHelper getLocalizedNameForCell:cell];
    }
#if NON_APP_USERS_ENABLED
    else if (self.cellSelectionType == CellSelectionTypeNau) {
        
        cellSelectionCell.lblCellName.text = cell[kNonAppUserCellNameKey];
    }

#endif
    ///Show tick if cell is already selected
    if ([self isCellSelectedWithId:cell.objectId]) {
        ///show selected
        cellSelectionCell.btnCheckbox.selected = YES;
    }
    else{
        ///show unselected
        cellSelectionCell.btnCheckbox.selected = NO;
    }
    
    return cellSelectionCell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;

    PFObject *cell = [self.arrAvailableCells objectAtIndex:rowIndex];
    
    NSUInteger cellSelectedIndex = [self selectedIndexOfCellId:cell.objectId];
    if (cellSelectedIndex != NSNotFound) {
        
        ///Cell already selected, remove it from selected Cells array
        [self.arrSelectedCells removeObjectAtIndex:cellSelectedIndex];
        
    }
    else{
        
        ///This cell is not currently in the group, add it to the selected cells array
        NSString *strCellName = @"";
        if (self.cellSelectionType == CellSelectionTypePublic) {
            
            strCellName = cell[kPublicCellNameKey];
        }
        else if (self.cellSelectionType == CellSelectionTypePrivate) {
            
            strCellName = [C411StaticHelper getLocalizedNameForCell:cell];
        }
#if NON_APP_USERS_ENABLED
        else if (self.cellSelectionType == CellSelectionTypeNau) {
            
            strCellName = cell[kNonAppUserCellNameKey];
        }
        
#endif
        ///make a dictionary of selected cell
        NSMutableDictionary *dictSelectedCell = [NSMutableDictionary dictionary];
        [dictSelectedCell setObject:strCellName forKey:kPanicAlertRecipientSelectedCellNameKey];
        [dictSelectedCell setObject:cell.objectId forKey:kPanicAlertRecipientSelectedCellIdKey];
        
        [self.arrSelectedCells addObject:dictSelectedCell];
    }
    
    ///Reload table to toggle tick marks
    [self.tblVuCells reloadData];
 
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
