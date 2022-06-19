//
//  C411CellsVC.m
//  cell411
//
//  Created by Milan Agarwal on 22/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411CellsVC.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "C411MyPrivateCellsVC.h"
#import "C411MyPublicCellsVC.h"
#import "C411ExploreCellsVC.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Constants.h"
#import "C411ChatHelper.h"
#import "MAAlertPresenter.h"
#import "C411AppDefaults.h"
#import "C411CreateMyPublicCellVC.h"
#import "C411ColorHelper.h"

#define TAG_TAB_TITLE 101

@interface C411CellsVC ()<ViewPagerDataSource,ViewPagerDelegate>

- (IBAction)barBtnShowCreateCellsOptionTapped:(UIBarButtonItem *)sender;
- (IBAction)barBtnExploreCellsTapped:(UIBarButtonItem *)sender;
@property (nonatomic, readwrite) NSMutableArray *arrJoinedOrPendingCells;
@property (nonatomic, readwrite) NSMutableArray *arrOwnedPublicCells;

@end

@implementation C411CellsVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    self.dataSource = self;
    self.delegate = self;
    
    [self registerForNotifications];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
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
#pragma mark - Property Initializers
//****************************************************

-(NSMutableArray *)arrOwnedPublicCells
{
    if (!_arrOwnedPublicCells) {
        
        __weak typeof(self) weakself = self;
        [self getOwnedPublicCellWithCompletion:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (!error) {
                
                weakself.arrOwnedPublicCells = [NSMutableArray arrayWithArray:objects];
                
                ///Post notification that cell list updated
                [[NSNotificationCenter defaultCenter]postNotificationName:kOwnedPublicCellsListUpdatedNotification object:nil];
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
                
                
            }

            
        }];
        
    }
    return _arrOwnedPublicCells;
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    self.title = NSLocalizedString(@"Cells", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)applyColors {
    ///Set colors of tab labels
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    for (UIView *tabView in self.tabs) {
        UILabel *lblTabTitle = [tabView viewWithTag:TAG_TAB_TITLE];
        if([lblTabTitle isKindOfClass:[UILabel class]]) {
            lblTabTitle.textColor = primaryTextColor;
        }
    }
}


-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(joinPublicCell:) name:kJoinPublicCellNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(leavePublicCell:) name:kLeavePublicCellNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)leavePublicCellWithObject:(PFObject *)publicCellObj
{
    PFUser *joinee = [AppDelegate getLoggedInUser];
    PFRelation *membersRelation = [publicCellObj relationForKey:kPublicCellMembersKey];
    [membersRelation removeObject:joinee];
    ///Decrement the members count
    [publicCellObj incrementKey:kPublicCellTotalMembersKey byAmount:@(-1)];
    UIView *topView = [C411StaticHelper getTopMostController].view;
    ///show hud
    [MBProgressHUD showHUDAddedTo:topView animated:YES];
    
    ///save public cell object
    __weak typeof(self) weakSelf = self;
    
    [publicCellObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (succeeded) {
            
            ///1.remove the corresponding Cell411Alert object from arrJoinedOrPendingCells
            NSInteger cell411AlertObjIndex = -1;
            for (NSInteger index = 0; index < weakSelf.arrJoinedOrPendingCells.count; index++) {
                
                PFObject *cell411Alert = [weakSelf.arrJoinedOrPendingCells objectAtIndex:index];
                NSString *cellObjectId = cell411Alert[kCell411AlertCellIdKey];
                if ([cellObjectId isEqualToString:publicCellObj.objectId]) {
                    ///Found the corresponding Cell411Alert object
                    cell411AlertObjIndex = index;
                    break;
                }
                
                
            }
            
            if (cell411AlertObjIndex != -1) {
                
                ///Get the cell411alert object
                PFObject *cell411Alert = [weakSelf.arrJoinedOrPendingCells objectAtIndex:cell411AlertObjIndex];
                
                ///remove the object from the array
                [weakSelf.arrJoinedOrPendingCells removeObjectAtIndex:cell411AlertObjIndex];
                
                ///Update the Cell411Alert by setting it to LEFT
                cell411Alert[kCell411AlertStatusKey] = kAlertStatusLeft;
                
                ///Save it eventually
                [cell411Alert saveEventually];
            }
            
            
            ///2.Send notification that cell is leaved
            [[NSNotificationCenter defaultCenter]postNotificationName:kPublicCellLeavedNotification object:publicCellObj];
            
            ///3. set isRemoved for the particular cell id to disable chat for this user
            [C411ChatHelper handleUserRemovedFromEntityWithId:publicCellObj.objectId];
            
        }
        else{
            
            if (error) {
                if(![AppDelegate handleParseError:error]){
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                }
            }
            
        }
        
        ///hide hud
        [MBProgressHUD hideHUDForView:topView animated:YES];
        
    }];
    
}

-(void)showCreatePrivateCellPopup
{
    ///show create private cell popup
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:NSLocalizedString(@"Create new Private Cell", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Cell name",nil);
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       ///user canceled to add private cell
                                       
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                       
                                   }];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *txtCellName = alertController.textFields.firstObject;
                                   NSString *strCellName = txtCellName.text;
                                   ///trim the cell name
                                   strCellName = [strCellName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                   [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                       ///Schedule cell addition to next runloop, to avoid present another alert on top of another.
                                       [[C411AppDefaults sharedAppDefaults]addPvtCellWithName:strCellName];
                                       
                                   }];
                                   
                                   ///Dequeue the current Alert Controller and allow other to be visible
                                   [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                   
                               }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    //[self presentViewController:alertController animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

}


-(void)showCreatePublicCellScreen
{
    ///show create Public cell screen
    C411CreateMyPublicCellVC *createMyPublicCellVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411CreateMyPublicCellVC"];
    createMyPublicCellVC.publicCellsDelegate = self;
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    
    [rootNavC pushViewController:createMyPublicCellVC animated:YES];

}


-(void)showExplorePublicCellScreen
{
    ///show create Public cell screen
    C411ExploreCellsVC *exploreCellsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ExploreCellsVC"];
    exploreCellsVC.publicCellsDelegate = self;
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    
    [rootNavC pushViewController:exploreCellsVC animated:YES];
    
}


//****************************************************
#pragma mark - ViewPagerDataSource Methods
//****************************************************

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 2;
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    NSString *strTabTitle = nil;
    
    switch (index) {
//        case 0:
//            strTabTitle = NSLocalizedString(@"EXPLORE CELLS", nil);
//            break;
        case 0:
            strTabTitle = NSLocalizedString(@"MY PUBLIC CELLS", nil);
            break;
        case 1:
            strTabTitle = NSLocalizedString(@"MY PRIVATE CELLS", nil);
            break;
        default:
            break;
    }
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:12.0];
    label.text = strTabTitle;
    label.textAlignment = NSTextAlignmentCenter;
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    label.textColor = primaryTextColor;
    label.tag = TAG_TAB_TITLE;
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    switch (index) {
//        case 0:{
//            
//            C411ExploreCellsVC *exploreCellsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ExploreCellsVC"];
//            exploreCellsVC.publicCellsDelegate = self;
//            return exploreCellsVC;
//            
//        }
        case 0:{
        
            C411MyPublicCellsVC *myPublicCellsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411MyPublicCellsVC"];
            myPublicCellsVC.publicCellsDelegate = self;
            return myPublicCellsVC;
            
        }
        case 1:{
            
            
            C411MyPrivateCellsVC *myPrivateCellsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411MyPrivateCellsVC"];
            return myPrivateCellsVC;
            

            
        }
        default:
            break;
    }
    
    return nil;
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 1.0;
        case ViewPagerOptionTabLocation:
            return 1.0;
        case ViewPagerOptionTabHeight:
            return 49.0;
        case ViewPagerOptionTabOffset:
            return 36.0;
        case ViewPagerOptionTabWidth:
            return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 182.0 : 160.0;
        case ViewPagerOptionFixFormerTabsPositions:
            return 1.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 1.0;
        default:
            return value;
    }
}

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [C411ColorHelper sharedInstance].themeColor;
        case ViewPagerTabsView:
            return [C411ColorHelper sharedInstance].cardColor;
        case ViewPagerContent:
            return [C411ColorHelper sharedInstance].backgroundColor;
        default:
            return color;
    }
}


//****************************************************
#pragma mark - PublicCellsDelegate Methods
//****************************************************


-(void)getPendingOrJoinedPublicCellsWithCompletion:(PFArrayResultBlock)completion
{
    PFQuery *pendingOrJoinedCellsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [pendingOrJoinedCellsQuery whereKey:kCell411AlertIssuedByKey equalTo:[AppDelegate getLoggedInUser]];
    [pendingOrJoinedCellsQuery whereKey:kCell411AlertEntryForKey equalTo:kEntryForCellRequest];
    [pendingOrJoinedCellsQuery whereKey:kCell411AlertStatusKey containedIn:@[kAlertStatusApproved,kAlertStatusPending]];
    __weak typeof(self) weakSelf = self;
    
    ///Find pending or joined public cells in background
    [pendingOrJoinedCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        ///update the array of joined or pending cells
        weakSelf.arrJoinedOrPendingCells = [NSMutableArray arrayWithArray:objects];
        
        ///pass the result back to completion handler
        if (completion != NULL) {
            
            completion(objects,error);
        }
        
    }];
    
}

-(void)addObjectToPendingOrJoinedCellsArray:(PFObject *)cell411Alert
{
    ///Save cell411Alert object in list of joinedOrPendingcells arrays
    [self.arrJoinedOrPendingCells addObject:cell411Alert];
    
    
}


-(void)getOwnedPublicCellWithCompletion:(PFArrayResultBlock)completion
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *getOwnedPublicCellsQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
    [getOwnedPublicCellsQuery whereKey:kPublicCellCreatedByKey equalTo:currentUser];
    __weak typeof(self) weakSelf = self;
    [getOwnedPublicCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        ///update the array of joined or pending cells
        weakSelf.arrOwnedPublicCells = [NSMutableArray arrayWithArray:objects];

        ///pass the result back to completion handler
        if (completion != NULL) {
            
            completion(objects,error);
        }
        
    }];
    
}


-(void)addOwnedPublicCell:(id)cell
{
    if ([C411StaticHelper canUseJsonObject:cell]) {
        ///Add this object to cells array
        [self.arrOwnedPublicCells addObject:cell];
        
        ///Post notification that cell list updated
        [[NSNotificationCenter defaultCenter]postNotificationName:kOwnedPublicCellsListUpdatedNotification object:nil];
        
    }
    
}

-(void)removeOwnedPublicCellAtIndex:(NSUInteger)index
{
    if (index < self.arrOwnedPublicCells.count) {
        
        [self.arrOwnedPublicCells removeObjectAtIndex:index];
    }
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)barBtnShowCreateCellsOptionTapped:(UIBarButtonItem *)sender {
    
    UIAlertController *moreOptionPicker = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    ///1.Add explore public cell action
    UIAlertAction *explorePublicCellAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Explore Cells", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ///Show Explore Public Cell screen
        [weakSelf showExplorePublicCellScreen];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [moreOptionPicker addAction:explorePublicCellAction];

#if IS_CREATE_PUBLIC_CELL_ENABLED
    ///2.Add create public cell action
    UIAlertAction *createPublicCellAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Create Public Cell", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ///Show Create Public Cell screen
        [weakSelf showCreatePublicCellScreen];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [moreOptionPicker addAction:createPublicCellAction];
#endif
    
    ///2.Add create private cell action
    UIAlertAction *createPrivateCellAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Create Private Cell", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ///Show Create Private Cell popup
        [weakSelf showCreatePrivateCellPopup];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [moreOptionPicker addAction:createPrivateCellAction];

    ///Add cancel button action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        ///Do anything to be done on cancel
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [moreOptionPicker addAction:cancelAction];
    
    ///Present action sheet
    //[self presentViewController:mapTypePicker animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:moreOptionPicker];
}

- (IBAction)barBtnExploreCellsTapped:(UIBarButtonItem *)sender {
    
    ///Show Explore Public Cell screen
    [self showExplorePublicCellScreen];

}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)joinPublicCell:(NSNotification *)notif
{
    UIView *topView = [C411StaticHelper getTopMostController].view;
    [MBProgressHUD showHUDAddedTo:topView animated:YES];
    __weak typeof(self) weakSelf = self;
    
    PFObject *oldPublicCellObj = notif.object;
    ///get the latest Public Cell object to see whether it still exist or not
    
    [C411StaticHelper getPublicCellWithObjectId:oldPublicCellObj.objectId andCompletion:^(PFObject *object, NSError *error){
        
        if (!error) {
            
            ///get the refreshed object
            PFObject *publicCellObj = object;
            PFUser *joinee = [AppDelegate getLoggedInUser];
            NSString *strJoineeFullName = [C411StaticHelper getFullNameUsingFirstName:joinee[kUserFirstnameKey] andLastName:joinee[kUserLastnameKey]];
            PFUser *cellOwner = publicCellObj[kPublicCellCreatedByKey];
            NSString *strOwnerId = cellOwner.objectId;
            // NSString *strFullNameCellOwner = [NSString stringWithFormat:@"%@ %@",cellOwner[kUserFirstnameKey],cellOwner[kUserLastnameKey]];
            
            [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:strOwnerId andCompletion:^(SpamStatus status, NSError *error) {
                
                if (status == SpamStatusIsSpammed) {
                    
                    ///Cell owner is spammed by current user, show error message
                    [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Sorry, we cannot send Cell join request to this user on your behalf", nil) onViewController:weakSelf];
                    
                    ///hide hud
                    [MBProgressHUD hideHUDForView:topView animated:YES];
                }
                else{
                    ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to send request
                    if (error) {
                        ///Log the error if any but send the request even if SpamStatus is SpamStatusUnknown
                        NSLog(@"%@",error.localizedDescription);
                        
                    }
                    
                    ///1.Create a Cell411Alert object
                    
                    PFObject *cell411Alert = [PFObject objectWithClassName:kCell411AlertClassNameKey];
                    cell411Alert[kCell411AlertIssuedByKey] = joinee;
                    cell411Alert[kCell411AlertEntryForKey] = kEntryForCellRequest;
                    cell411Alert[kCell411AlertStatusKey] = kAlertStatusPending;
                    NSString *strCellId = publicCellObj.objectId;
                    cell411Alert[kCell411AlertCellIdKey] = strCellId;
                    cell411Alert[kCell411AlertToKey] = cellOwner.username;
                    cell411Alert[kCell411AlertIssuerFirstNameKey] = strJoineeFullName;
                    NSString *strCellName = publicCellObj[kPublicCellNameKey];
                    cell411Alert[kCell411AlertCellNameKey] = strCellName;
                    
                    
                    ///Save in Background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            
                            ///2.An entry has been made successfully on Cell411Alert table regarding the notification and now you can send the notification to the cell owner
                            
                            ///Create Payload data
                            NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                            NSString *strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ has sent you a Cell join request on %@ Cell!",nil),strJoineeFullName,strCellName];
                            
                            dictData[kPayloadAlertKey] = strAlertMsg;
                            dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeCellRequest;
                            dictData[kPayloadUserIdKey] = joinee.objectId;
                            dictData[kPayloadCellRequestObjectIdKey] = cell411Alert.objectId;
                            
                            dictData[kPayloadNameKey] = strJoineeFullName;
                            dictData[kPayloadCellIdKey] = strCellId;
                            dictData[kPayloadCellNameKey] = strCellName;
                            
                            dictData[kPayloadSoundKey] = @"default";///To play default sound
                            dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                            
                            
                            
                            // Create our Installation query
                            PFQuery *pushQuery = [PFInstallation query];
                            [pushQuery whereKey:kInstallationUserKey equalTo:cellOwner];
                            
                            // Send push notification to query
                            PFPush *push = [[PFPush alloc] init];
                            [push setQuery:pushQuery]; // Set our Installation query
                            [push setData:dictData];
                            ///Send Push notification
                            [push sendPushInBackground];
                            
                            ///Show toast
                            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"A Cell join request is sent to the owner of %@ Cell for approval",nil),strCellName];
                            [C411StaticHelper  showAlertWithTitle:nil message:strMessage onViewController:weakSelf];
                            
                            
                            ///Send notification that Cell is joined along with refreshed Public Cell Object
                            NSMutableDictionary *dictUserInfo = [NSMutableDictionary dictionary];
                            [dictUserInfo setObject:publicCellObj forKey:kRefreshedPublicCellKey];
                            [[NSNotificationCenter defaultCenter]postNotificationName:kPublicCellJoinedNotification object:cell411Alert userInfo:dictUserInfo];
                            
                            
                        }
                        else{
                            
                            if (error) {
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                                }
                                
                            }
                            
                        }
                        
                        ///hide hud
                        [MBProgressHUD hideHUDForView:topView animated:YES];
                    }];
                    
                    
                    
                    
                    
                }
                
            }];
        }
        else if (error.code == kPFErrorObjectNotFound){
            
            ///this public cell has been deleted by the owner, send notification to remove it from the list as well
            [[NSNotificationCenter defaultCenter]postNotificationName:kPublicCellDoesNotExistNotification object:oldPublicCellObj.objectId];
            
            ///show the alert
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Oops!!! This Cell no longer exist.", nil) onViewController:weakSelf];
            
            ///hide hud
            [MBProgressHUD hideHUDForView:topView animated:YES];
            
            
        }
        else{
            ///show the error
            NSString *errorString = [error userInfo][@"error"];
            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
            
            ///hide hud
            [MBProgressHUD hideHUDForView:topView animated:YES];
            
        }
    }];
    
    
    
}


-(void)leavePublicCell:(NSNotification *)notif
{
    UIView *topView = [C411StaticHelper getTopMostController].view;
    [MBProgressHUD showHUDAddedTo:topView animated:YES];
    
    PFObject *oldPublicCellObj = notif.object;
    ///get the latest Public Cell object to see whether it still exist or not
    __weak typeof(self) weakSelf = self;
    [C411StaticHelper getPublicCellWithObjectId:oldPublicCellObj.objectId andCompletion:^(PFObject *object, NSError *error){
        
        if (!error) {
            
            ///get the refreshed object
            PFObject *publicCellObj = object;
            
            ///check whether the arrJoinedOrPendingCells has been fetched or not
            if (weakSelf.arrJoinedOrPendingCells != nil) {
                
                ///hide hud
                [MBProgressHUD hideHUDForView:topView animated:YES];
                
                ///already fetched, so execute leaving of cell process
                [weakSelf leavePublicCellWithObject:publicCellObj];
            }
            else{
                
                ///fetch the array arrJoinedOrPendingCells first and then leave the public cell
                [weakSelf getPendingOrJoinedPublicCellsWithCompletion:^(NSArray * objects, NSError * error) {
                    
                    ///hide hud
                    [MBProgressHUD hideHUDForView:topView animated:YES];
                    
                    if (!error) {
                        
                        ///arrJoinedOrPendingCells fetched, so execute leaving of cell process
                        [weakSelf leavePublicCellWithObject:publicCellObj];
                    }
                    else{
                        
                        ///show the error
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                        
                    }
                }];
            }
        }
        else if (error.code == kPFErrorObjectNotFound){
            
            ///this public cell has been deleted by the owner, send notification to remove it from the list as well
            [[NSNotificationCenter defaultCenter]postNotificationName:kPublicCellDoesNotExistNotification object:oldPublicCellObj.objectId];
            
            ///hide hud
            [MBProgressHUD hideHUDForView:topView animated:YES];
            
        }
        else{
            
            ///show the error
            NSString *errorString = [error userInfo][@"error"];
            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
            ///hide hud
            [MBProgressHUD hideHUDForView:topView animated:YES];
        }
    }];
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
    [self setNeedsReloadColors];
}


@end
