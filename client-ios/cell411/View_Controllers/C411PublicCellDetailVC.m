//
//  C411PublicCellDetailVC.m
//  cell411
//
//  Created by Milan Agarwal on 02/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411PublicCellDetailVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "C411PublicCellBasicDetailCell.h"
#import "C411PublicCellMemberCell.h"
#import "C411RequestVerificationVC.h"
#import "Constants.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "C411AppDefaults.h"
#import "MAAlertPresenter.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "UIButton+FAB.h"
#import "C411ChatVC.h"
#import "C411Enums.h"
#import "C411UserProfilePopup.h"
#import "C411ViewPhotoVC.h"
#import "C411MyProfileVC.h"
#import "C411CreateMyPublicCellVC.h"
#import "C411ColorHelper.h"

#define PAGE_LIMIT  10

#define TOTAL_SECTIONS  2
#define TABLE_SEC_INDEX_CELL_BASIC_DETAILS      0
#define TABLE_SEC_INDEX_CELL_MEMBERS            1

#define TABLE_SEC_HEIGHT_CELL_BASIC_DETAILS     200.0f
#define TABLE_SEC_HEIGHT_CELL_MEMBERS     52.0f


@interface C411PublicCellDetailVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblVuPublicCellDetails;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnRightItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barBtnMoreOptions;
@property (weak, nonatomic) IBOutlet UIButton *btnShowChatVCFAB;


//- (IBAction)barBtnJoinLeaveOrVerifyTapped:(UIBarButtonItem *)sender;
- (IBAction)btnShowChatVCFABTapped:(UIButton *)sender;
- (IBAction)barBtnMoreOptionsTapped:(UIBarButtonItem *)sender;


@property (nonatomic, strong) NSMutableArray *arrCellMembers;
@property (nonatomic, assign) BOOL noMoreData;

/*OLD implementation of verification request handling
@property (nonatomic, strong) PFObject *verificationReqObj;
@property (nonatomic, assign,getter=isRequestingVerificationObject) BOOL requestingVerificationObject;
@property (nonatomic, assign,getter=isErrorRequestingVerificationObject) BOOL errorRequestingVerificationObject;
*/

@end

@implementation C411PublicCellDetailVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    [self setupViews];
    [self fetchPublicCellMembers];
    [self registerForNotifications];

/*OLD implementation of verification request handling
    if (self.isOwner) {
        
        [self fetchVerificationRequestObject];
        
     }
*/
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self unregisterFromNotifications];
    self.publicCellObj = nil;
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
    self.barBtnMoreOptions = nil;
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(NSMutableArray *)arrCellMembers
{
    if (!_arrCellMembers) {
        _arrCellMembers = [NSMutableArray array];
    }
    
    return _arrCellMembers;
}

-(void)setCellMembershipStatus:(CellMembershipStatus)cellMembershipStatus
{
    if (_cellMembershipStatus != cellMembershipStatus) {
        
        _cellMembershipStatus = cellMembershipStatus;
        ///reload the tableview to show correct header data
        [self.tblVuPublicCellDetails reloadData];

        [self setupViews];
        
    }
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    self.title = self.publicCellObj[kPublicCellNameKey];
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
#if CHAT_ENABLED
    [self.btnShowChatVCFAB makeFloatingActionButton];
#else
    self.btnShowChatVCFAB.hidden = YES;
#endif

    [self applyColors];
}

-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
#if CHAT_ENABLED
    ///Set secondary color
    UIColor *fabSelectedColor = [C411ColorHelper sharedInstance].fabSelectedColor;
    self.btnShowChatVCFAB.backgroundColor = fabSelectedColor;
    self.btnShowChatVCFAB.layer.shadowColor = [C411ColorHelper sharedInstance].fabShadowColor.CGColor;
    self.btnShowChatVCFAB.tintColor = [C411ColorHelper sharedInstance].fabSelectedTintColor;
#endif
    
}


-(void)setupViews
{

#if CHAT_ENABLED
    if ((self.isOwner)
        ||(self.cellMembershipStatus == CellMembershipStatusIsAMember)) {
        ///Current user is part of this cell, so show the chat button
        self.btnShowChatVCFAB.hidden = NO;
    }
    else{
        
        ///Current user is not the part of this cell, so hide the chat button
        self.btnShowChatVCFAB.hidden = YES;
        
    }
#endif
    
    
    if ((self.cellMembershipStatus == CellMembershipStatusUnknown)
        ||(self.cellMembershipStatus == CellMembershipStatusPendingApproval)) {
        
        ///There is no need to show the more options button for this case
        self.navigationItem.rightBarButtonItem = nil;
        
    }
    else{
        
        ///Show More options button
        if (!self.navigationItem.rightBarButtonItem) {
            
            self.navigationItem.rightBarButtonItem = self.barBtnMoreOptions;
        }
    }
    
}


-(void)fetchPublicCellMembers
{
    
    ///Make a new query
    PFRelation *publicCellMembersRelation = [self.publicCellObj relationForKey:kPublicCellMembersKey];
    PFQuery *fetchPublicCellMembersQuery = [publicCellMembersRelation query];
    fetchPublicCellMembersQuery.skip = self.arrCellMembers.count;
    fetchPublicCellMembersQuery.limit = PAGE_LIMIT;
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [fetchPublicCellMembersQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
        
        
        if (!error) {
            
            [weakSelf.arrCellMembers addObjectsFromArray:objects];
            
            if (objects.count < PAGE_LIMIT) {
                
                self.noMoreData = YES;
            }
            else{
                
                self.noMoreData = NO;
            }
            
            [weakSelf.tblVuPublicCellDetails reloadData];
            
        }
        else {
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
            }
            
            
        }
        
        
        ///Hide hud
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
    }];
    
}

/*OLD implementation of verification request handling
-(void)fetchVerificationRequestObject
{
    ///Get the verification Request Object for this cell if available
    self.requestingVerificationObject = YES;
    
    PFQuery *fetchVerificatioReqQuery = [PFQuery queryWithClassName:kVerificationRequestClassNameKey];
    [fetchVerificatioReqQuery whereKey:kVerificationRequestCellKey equalTo:self.publicCellObj];
    __weak typeof(self) weakSelf = self;
    [fetchVerificatioReqQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (!error) {
            ///save the verification object
            weakSelf.verificationReqObj = object;
        }
        else if (error.code == kPFErrorObjectNotFound){
            ///Object not available, that means verification is not requested till now
            
        }
        else{
            
            ///Log error and save it in iVar
            weakSelf.errorRequestingVerificationObject = YES;
            if(![AppDelegate handleParseError:error]){
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"#error fetching cell411alert :%@",errorString);
            }
            
        }
        
        ///update the busy flag
        weakSelf.requestingVerificationObject = NO;
        
        
        
    }];
    
    
}
*/


-(void)showRequestVerificationPopup
{
    
    ///Show popup for verification request
    C411RequestVerificationVC *requestVerificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411RequestVerificationVC"];
    requestVerificationVC.myPublicCellObj = self.publicCellObj;
    [self presentViewController:requestVerificationVC animated:YES completion:NULL];
    
/*OLD implementation of verification request handling
    if (self.isRequestingVerificationObject) {
        
        ///Show toast to wait, as we are still fetching verificationRequest Object
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Please wait", nil)];
    }
    else if (self.isErrorRequestingVerificationObject){
        
        ///Show toast to try again later, as we encoutered some error fetching the verificationRequest Object
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Error occurred: Try again later.", nil)];
    }
    else{
        
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        NSString *strEmail = [C411StaticHelper getEmailFromUser:currentUser];
        strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (strEmail.length > 0) {
            ///Show popup for verification request
            C411RequestVerificationVC *requestVerificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411RequestVerificationVC"];
            requestVerificationVC.myPublicCellObj = self.publicCellObj;
            requestVerificationVC.verificationReqObj = self.verificationReqObj;
            [self presentViewController:requestVerificationVC animated:YES completion:NULL];
            
        }
        else{
            
            ///Show update email popup
            __weak typeof(self) weakSelf = self;
            
            [[C411AppDefaults sharedAppDefaults]showUpdateEmailPopupForUser:currentUser fromViewController:self withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                
                ///Perform operation only if succeeded, error display is already handled
                if (succeeded) {
                    
                    ///Show popup for verification request
                    C411RequestVerificationVC *requestVerificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411RequestVerificationVC"];
                    requestVerificationVC.myPublicCellObj = weakSelf.publicCellObj;
                    requestVerificationVC.verificationReqObj = weakSelf.verificationReqObj;
                    [weakSelf presentViewController:requestVerificationVC animated:YES completion:NULL];

                    
                }
                
            }];
            
        }

        
        
    }
 */
    
}

-(void)showEditCellScreen
{
    if (self.isOwner) {
        
        ///show create Public cell screen in edit mode for the owner
        C411CreateMyPublicCellVC *createMyPublicCellVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411CreateMyPublicCellVC"];
        createMyPublicCellVC.inEditMode = YES;
        createMyPublicCellVC.publicCellObj = self.publicCellObj;
        createMyPublicCellVC.publicCellsDelegate = self.publicCellsDelegate;
        [self.navigationController pushViewController:createMyPublicCellVC animated:YES];

    }

}


-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publicCellJoined:) name:kPublicCellJoinedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publicCellLeaved:) name:kPublicCellLeavedNotification object:nil];
    
/*OLD implementation of verification request handling

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(verificationRequestSent:) name:kPublicCellVerificationRequestSentNotification object:nil];
*/
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publicCellDoesNotExist:) name:kPublicCellDoesNotExistNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publicCellUpdated:) name:kPublicCellUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)refreshCellMembersList
{
    
    ///clear the members data
    self.arrCellMembers = nil;
    self.noMoreData = NO;
    
    ///fetch the members list again
    [self fetchPublicCellMembers];
    
    
}

-(void)addTapGestureOnImageView:(UIView *)imgVu
{
    ///Enable user interaction to listen tap event
    imgVu.userInteractionEnabled = YES;
    
    ///remove old tap gestures first
    for (UIGestureRecognizer *gestureRecognizer in imgVu.gestureRecognizers) {
        
        if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            
            [imgVu removeGestureRecognizer:gestureRecognizer];
        }
        
    }
    
    ///Add tap gesture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgVuAvatarTapped:)];
    [imgVu addGestureRecognizer:tapRecognizer];
}

-(void)showProfileOfUser:(PFUser *)cellMember
{
    ///Show user profile popup
    C411UserProfilePopup *vuUserProfilePopup = [[[NSBundle mainBundle] loadNibNamed:@"C411UserProfilePopup" owner:self options:nil] lastObject];
    vuUserProfilePopup.user = cellMember;
    UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
    ///Set view frame
    vuUserProfilePopup.frame = rootVC.view.bounds;
    ///add view
    [rootVC.view addSubview:vuUserProfilePopup];
    [rootVC.view bringSubviewToFront:vuUserProfilePopup];

}

-(void)removeUserFromMyCellAtIndex:(NSInteger)rowIndex
{
    
    if (rowIndex < self.arrCellMembers.count) {
        
        PFUser *cellMember = [self.arrCellMembers objectAtIndex:rowIndex];
        NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Are you sure you want to remove %@ from this Cell?",nil),[C411StaticHelper getFullNameUsingFirstName:cellMember[kUserFirstnameKey] andLastName:cellMember[kUserLastnameKey]]];
        
        UIAlertController *confirmRemovalAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            ///user said No, do nothing
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
            
        }];
        
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ///User opted to remove the user
            
            //retrieve the Cell411Alert object
            PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [getCell411AlertQuery whereKey:kCell411AlertIssuedByKey equalTo:cellMember];
            [getCell411AlertQuery whereKey:kCell411AlertEntryForKey equalTo:kEntryForCellRequest];
            [getCell411AlertQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusApproved];
            [getCell411AlertQuery whereKey:kCell411AlertCellIdKey equalTo:self.publicCellObj.objectId];
            [getCell411AlertQuery selectKeys:@[kCell411AlertStatusKey]];
            
            ///show hud
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            __weak typeof(self) weakSelf = self;
            
            [getCell411AlertQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                
                if (!error) {
                    
                    ///Update the Status as REMOVED and save it eventually
                    PFObject *cell411Alert = object;
                    cell411Alert[kCell411AlertStatusKey] = kAlertStatusRemoved;
                    [cell411Alert saveEventually];
                    
                    ///remove member from relation
                    PFRelation *membersRelation = [weakSelf.publicCellObj relationForKey:kPublicCellMembersKey];
                    [membersRelation removeObject:cellMember];
                    
                    ///Decrement the members count
                    [weakSelf.publicCellObj incrementKey:kPublicCellTotalMembersKey byAmount:@(-1)];
                    
                    [weakSelf.publicCellObj saveEventually];
                    
                    ///remove the member from the local array and reload the data
                    [weakSelf.arrCellMembers removeObjectAtIndex:rowIndex];
                    [weakSelf.tblVuPublicCellDetails reloadData];
                    
                    ///notify observers
                    [[NSNotificationCenter defaultCenter]postNotificationName:kPublicCellUserRemovedNotification object:nil];
                    
                    ///Send push notification to the user who is removed from the cell
                    ///Create Payload data
                    NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                    NSString *strCellName = weakSelf.publicCellObj[kPublicCellNameKey];
                    dictData[kPayloadAlertKey] = [NSString localizedStringWithFormat:NSLocalizedString(@"You were removed from Cell %@ by the owner",nil),strCellName];
                    PFUser *currentUser = [AppDelegate getLoggedInUser];
                    dictData[kPayloadUserIdKey] = currentUser.objectId;
                    NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
                    dictData[kPayloadNameKey] = strUserFullName;
                    dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeCellRemoved;
                    dictData[kPayloadSoundKey] = @"default";///To play default sound
                    dictData[kPayloadCellIdKey] = weakSelf.publicCellObj.objectId;
                    dictData[kPayloadCellNameKey] = strCellName;
                    dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                    
                    // Create our Installation query
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:kInstallationUserKey equalTo:cellMember];
                    
                    // Send push notification to query
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery]; // Set our Installation query
                    [push setData:dictData];
                    [push sendPushInBackground];
                    
                    
                }
                else if (error.code == kPFErrorObjectNotFound){
                    
                }
                else{
                    
                    if(![AppDelegate handleParseError:error]){
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                    }
                }
                
                ///hide hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
            }];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
            
        }];
        
        [confirmRemovalAlert addAction:noAction];
        [confirmRemovalAlert addAction:yesAction];
        //[self presentViewController:confirmRemovalAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmRemovalAlert];
        
    }
    
    
}

-(void)applyColorOnHeaderview:(UIView *)headerView forSection:(NSInteger)section {
    headerView.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    UILabel *lblSectionTitle = (UILabel *)[headerView viewWithTag:101];
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    lblSectionTitle.textColor = primaryTextColor;
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnShowChatVCFABTapped:(UIButton *)sender {
    
    C411ChatVC *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ChatVC"];
    chatVC.entityType = ChatEntityTypePublicCell;
    chatVC.strEntityId = self.publicCellObj.objectId;
    chatVC.strEntityName = self.publicCellObj[kPublicCellNameKey];
    chatVC.entityCreatedAtInMillis = [self.publicCellObj.createdAt timeIntervalSince1970] * 1000;
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:chatVC animated:YES];
}

- (IBAction)barBtnMoreOptionsTapped:(UIBarButtonItem *)sender {
    
    ///show action sheet with options to Request verification and edit this cell if current user is owner of this cell, Leave this Cell if current user is member of this cell, Join this Cell if current user is not the member of this cell and his request is not pending approval
    if ((self.cellMembershipStatus != CellMembershipStatusUnknown)
        &&(self.cellMembershipStatus != CellMembershipStatusPendingApproval)) {
        
        UIAlertController *moreOptionPicker = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        __weak typeof(self) weakSelf = self;
        
        if (self.isOwner) {
            
            ///1. Add options for request verification
            UIAlertAction *requestVerificationAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Request verification", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                ///This cell is owned by current user, he tapped on a Request Verification button, show the popup
                [weakSelf showRequestVerificationPopup];

                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];
                
            }];
            
            [moreOptionPicker addAction:requestVerificationAction];

            
            ///2. Add options for Edit this cell
            UIAlertAction *editCellAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Edit Cell", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                ///This cell is owned by current user, he tapped on Edit Cell button, open edit cell screen
                [weakSelf showEditCellScreen];
                
                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];
                
            }];
            
            [moreOptionPicker addAction:editCellAction];

            
        }
        else if (self.cellMembershipStatus == CellMembershipStatusIsAMember){
            
            ///Add option to leave this Cell
           UIAlertAction *leaveCellAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Leave this Cell", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
               ///user is the member of this cell and wants to leave this Cell
               [[NSNotificationCenter defaultCenter]postNotificationName:kLeavePublicCellNotification object:weakSelf.publicCellObj];
               
                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];
                
            }];
            
            [moreOptionPicker addAction:leaveCellAction];

        }
        else if (self.cellMembershipStatus == CellMembershipStatusNotAMember){
            
            ///Add option to join this Cell
            UIAlertAction *joinCellAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Join this Cell", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                ///user is not the member of this cell and wants to join this Cell
                [[NSNotificationCenter defaultCenter]postNotificationName:kJoinPublicCellNotification object:weakSelf.publicCellObj];

                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];
                
            }];
            
            [moreOptionPicker addAction:joinCellAction];

        }
        
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
    
}

/*
- (IBAction)barBtnJoinLeaveOrVerifyTapped:(UIBarButtonItem *)sender {
    
    if (self.isOwner) {
        ///This cell is owned by current user, he tapped on a Request Verification button, show the popup
        [self showRequestVerificationPopup];
    }
    else{
        ///This cell is owned by someone else
        if ([self.strBarBtnRightTitle.lowercaseString isEqualToString:NSLocalizedString(@"join this Cell", nil)]) {
            
            ///user is not the member of this cell and wants to join this Cell
            [[NSNotificationCenter defaultCenter]postNotificationName:kJoinPublicCellNotification object:self.publicCellObj];
            
            
        }
        else if ([self.strBarBtnRightTitle.lowercaseString isEqualToString:NSLocalizedString(@"leave this Cell", nil)]) {
            
            ///user is the member of this cell and wants to leave this Cell
            [[NSNotificationCenter defaultCenter]postNotificationName:kLeavePublicCellNotification object:self.publicCellObj];
            
        }
    }
    
}


-(void)removeUserFromMyCell:(UIButton *)sender
{
    
    NSInteger rowIndex = sender.tag;
    if (rowIndex < self.arrCellMembers.count) {
        
        PFUser *cellMember = [self.arrCellMembers objectAtIndex:rowIndex];
        NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Are you sure you want to remove %@ from this Cell?",nil),[C411StaticHelper getFullNameUsingFirstName:cellMember[kUserFirstnameKey] andLastName:cellMember[kUserLastnameKey]]];
        
        UIAlertController *confirmRemovalAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            ///user said No, do nothing
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ///User opted to remove the user
            
            //retrieve the Cell411Alert object
                PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
                [getCell411AlertQuery whereKey:kCell411AlertIssuedByKey equalTo:cellMember];
                [getCell411AlertQuery whereKey:kCell411AlertEntryForKey equalTo:kEntryForCellRequest];
                [getCell411AlertQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusApproved];
                [getCell411AlertQuery whereKey:kCell411AlertCellIdKey equalTo:self.publicCellObj.objectId];
                [getCell411AlertQuery selectKeys:@[kCell411AlertStatusKey]];
                
                ///show hud
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                __weak typeof(self) weakSelf = self;
                
                [getCell411AlertQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                    
                    if (!error) {
                        
                        ///Update the Status as REMOVED and save it eventually
                        PFObject *cell411Alert = object;
                        cell411Alert[kCell411AlertStatusKey] = kAlertStatusRemoved;
                        [cell411Alert saveEventually];
                        
                        ///remove member from relation
                        PFRelation *membersRelation = [weakSelf.publicCellObj relationForKey:kPublicCellMembersKey];
                        [membersRelation removeObject:cellMember];
                        
                        ///Decrement the members count
                        [weakSelf.publicCellObj incrementKey:kPublicCellTotalMembersKey byAmount:@(-1)];
                        
                        [weakSelf.publicCellObj saveEventually];
                        
                        ///remove the member from the local array and reload the data
                        [weakSelf.arrCellMembers removeObjectAtIndex:rowIndex];
                        [weakSelf.tblVuPublicCellDetails reloadData];
                        
                        ///notify observers
                        [[NSNotificationCenter defaultCenter]postNotificationName:kPublicCellUserRemovedNotification object:nil];
                        
                        ///Send push notification to the user who is removed from the cell
                        ///Create Payload data
                        NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                        NSString *strCellName = weakSelf.publicCellObj[kPublicCellNameKey];
                        dictData[kPayloadAlertKey] = [NSString localizedStringWithFormat:NSLocalizedString(@"You were removed from Cell %@ by the owner",nil),strCellName];
                        PFUser *currentUser = [AppDelegate getLoggedInUser];
                        dictData[kPayloadUserIdKey] = currentUser.objectId;
                        NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
                        dictData[kPayloadNameKey] = strUserFullName;
                        dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeCellRemoved;
                        dictData[kPayloadSoundKey] = @"default";///To play default sound
                        dictData[kPayloadCellIdKey] = weakSelf.publicCellObj.objectId;
                        dictData[kPayloadCellNameKey] = strCellName;
                        dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                        
                        // Create our Installation query
                        PFQuery *pushQuery = [PFInstallation query];
                        [pushQuery whereKey:kInstallationUserKey equalTo:cellMember];
                        
                        // Send push notification to query
                        PFPush *push = [[PFPush alloc] init];
                        [push setQuery:pushQuery]; // Set our Installation query
                        [push setData:dictData];
                        [push sendPushInBackground];

                        
                    }
                    else if (error.code == kPFErrorObjectNotFound){
                        
                    }
                    else{
                        
                        if(![AppDelegate handleParseError:error]){
                            ///show error
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                        }
                    }
                    
                    ///hide hud
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                }];
                
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        [confirmRemovalAlert addAction:noAction];
        [confirmRemovalAlert addAction:yesAction];
        //[self presentViewController:confirmRemovalAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmRemovalAlert];

    }
    
    
}
*/

- (void)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    
    UIImageView *imgVuAvatar = (UIImageView *) sender.view;
    NSInteger rowIndex = imgVuAvatar.tag;
    if (rowIndex < self.arrCellMembers.count) {
        ///Get friend object
        PFUser *cellMember = [self.arrCellMembers objectAtIndex:rowIndex];
        if (![C411StaticHelper isUserDeleted:cellMember]) {
            ///Show photo VC to view photo alert
            UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
            C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
            viewPhotoVC.user = cellMember;
            [navRoot pushViewController:viewPhotoVC animated:YES];
        }
    }
}


//****************************************************
#pragma mark - UITableViewDataSource and Delegate Methods
//****************************************************

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ((velocity.y>0) && (!self.noMoreData)) {
        CGSize contentSize = scrollView.contentSize;
        CGSize scrollVSize  = scrollView.bounds.size;
        
        float downloadTriggerPointFromBottom = scrollVSize.height + 100;
        float downloadTriggerPoint              = contentSize.height - downloadTriggerPointFromBottom;
        
        if (targetContentOffset->y>=downloadTriggerPoint) {
            {
                [self fetchPublicCellMembers];
            }
            
        }
        
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TOTAL_SECTIONS;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TABLE_SEC_INDEX_CELL_BASIC_DETAILS) {
        
        return 1;
    }
    else if(section == TABLE_SEC_INDEX_CELL_MEMBERS){
        
        if([C411AppDefaults canShowSecurityGuardOption]){
        
            return self.arrCellMembers.count + 1;

        }
        else{
        
            return self.arrCellMembers.count;

        }

    }
    else{
        
        return 0;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    NSInteger secIndex = indexPath.section;
    if (secIndex == TABLE_SEC_INDEX_CELL_BASIC_DETAILS) {
        
        ///Create and Return cell
        static NSString *detailCellId = @"C411PublicCellBasicDetailCell";
        C411PublicCellBasicDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:detailCellId];
        [self tableView:tableView configureDetailCell:detailCell atIndexPath:indexPath];
        
        return detailCell;
        
    }
    else if (secIndex == TABLE_SEC_INDEX_CELL_MEMBERS) {
        
        ///Create and Return cell
        static NSString *memberCellId = @"C411PublicCellMemberCell";
        C411PublicCellMemberCell *memberCell = [tableView dequeueReusableCellWithIdentifier:memberCellId];

        if([C411AppDefaults canShowSecurityGuardOption]){
            
            if (rowIndex == 0) {
                memberCell.lblMemberName.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ Call Centre",nil),LOCALIZED_APP_NAME];
                //            memberCell.btnRemoveMember.hidden = YES;
                memberCell.lblLocation.hidden = YES;
                return memberCell;
            }
            else{
                //            memberCell.btnRemoveMember.hidden = NO;
                memberCell.lblLocation.hidden = NO;
                rowIndex--;
            }

        }
        

        if (rowIndex < self.arrCellMembers.count) {
            
            
            ///Get member object
            PFUser *cellMember = [self.arrCellMembers objectAtIndex:rowIndex];
            ///Set Member name
            memberCell.lblMemberName.text = [C411StaticHelper getFullNameUsingFirstName:cellMember[kUserFirstnameKey] andLastName:cellMember[kUserLastnameKey]];
//            NSString *strEmail = [C411StaticHelper getEmailFromUser:cellMember];
//            if (strEmail.length > 0) {
//                ///Grab avatar image and place it here
//                static UIImage *placeHolderImage = nil;
//                if (!placeHolderImage) {
//                    
//                    placeHolderImage = [UIImage imageNamed:@"logo_small"];
//                }
//                memberCell.imgVuAvatar.email = strEmail;
//                memberCell.imgVuAvatar.placeholder = placeHolderImage;
//                memberCell.imgVuAvatar.defaultGravatar = RFDefaultGravatarUrlSupplied;
//                NSURL *defaultGravatarUrl = [NSURL URLWithString:DEFAULT_GRAVATAR_URL];
//                memberCell.imgVuAvatar.defaultGravatarUrl = defaultGravatarUrl;
//                
//                memberCell.imgVuAvatar.size = memberCell.imgVuAvatar.bounds.size.width * 3;
//                [memberCell.imgVuAvatar load];
//
//            }
            
            ///Grab avatar image and place it here
            static UIImage *placeHolderImage = nil;
            if (!placeHolderImage) {
                
                placeHolderImage = [UIImage imageNamed:@"logo_small"];
            }
            
            ///Set tap gesture on image view
            memberCell.imgVuAvatar.tag = rowIndex;
            [self addTapGestureOnImageView:memberCell.imgVuAvatar];

            ///set the default image first, then fetch the gravatar
            memberCell.imgVuAvatar.image = placeHolderImage;
            if ([C411StaticHelper isUserDeleted:cellMember]) {
                ///Grey out the name
                memberCell.lblMemberName.textColor = [C411ColorHelper sharedInstance].deletedUserTextColor;
            }
            else{
                ///Set primary text color
                memberCell.lblMemberName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
                ///Show profile pic
                [memberCell.imgVuAvatar setAvatarForUser:cellMember shouldFallbackToGravatar:YES ofSize:memberCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
            }


            ///set location
            PFGeoPoint *cellGeoTag = cellMember[kUserLocationKey];
            [memberCell updateLocationUsingCoordinate:CLLocationCoordinate2DMake(cellGeoTag.latitude, cellGeoTag.longitude)];

/*
            ///update remove button
            NSString *currentUserObjectId = [AppDelegate getLoggedInUser].objectId;
            if (self.isOwner && ![cellMember.objectId isEqualToString:currentUserObjectId]) {
                
                memberCell.btnRemoveMember.hidden = NO;
                memberCell.btnRemoveMember.tag = rowIndex;
                [memberCell.btnRemoveMember addTarget:self action:@selector(removeUserFromMyCell:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                
                memberCell.btnRemoveMember.hidden = YES;
            }
*/
            
        }
        return memberCell;

        
    }

    
    
    return nil;
    
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secIndex = indexPath.section;
    if (secIndex == TABLE_SEC_INDEX_CELL_BASIC_DETAILS) {
        
        return TABLE_SEC_HEIGHT_CELL_BASIC_DETAILS;
    }
    else{
        
        return TABLE_SEC_HEIGHT_CELL_MEMBERS;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secIndex = indexPath.section;
    if (secIndex == TABLE_SEC_INDEX_CELL_BASIC_DETAILS) {
        
        return [self tableView:tableView heightForDetailCellAtIndexPath:indexPath];
    }
    else{
        
        return TABLE_SEC_HEIGHT_CELL_MEMBERS;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    NSInteger secIndex = indexPath.section;
    if (secIndex == TABLE_SEC_INDEX_CELL_MEMBERS) {
        if([C411AppDefaults canShowSecurityGuardOption]){
            if (rowIndex == 0) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }
            else{
                rowIndex--;
            }
        }
        if (rowIndex < self.arrCellMembers.count) {
            ///Get member object
            PFUser *cellMember = [self.arrCellMembers objectAtIndex:rowIndex];
            NSString *currentUserObjectId = [AppDelegate getLoggedInUser].objectId;
            if ([cellMember.objectId isEqualToString:currentUserObjectId]) {
                ///show My profile for current user
                C411MyProfileVC *myProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411MyProfileVC"];
                [self.navigationController pushViewController:myProfileVC animated:YES];
            }
            else{
                if (self.isOwner) {
                    ///show action sheet with options to Remove member, View Profile
                    NSString *strMemberName = [C411StaticHelper getFullNameUsingFirstName:cellMember[kUserFirstnameKey] andLastName:cellMember[kUserLastnameKey]];
                    UIAlertController *moreOptionPicker = [UIAlertController alertControllerWithTitle:strMemberName message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                    
                    __weak typeof(self) weakSelf = self;
                    if (![C411StaticHelper isUserDeleted:cellMember]) {
                        ///1.View Profile action
                        UIAlertAction *viewProfileAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"View Profile", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                            
                            ///Show Profile of selected member
                            [weakSelf showProfileOfUser:cellMember];
                            
                            ///Dequeue the current Alert Controller and allow other to be visible
                            [[MAAlertPresenter sharedPresenter]dequeueAlert];
                            
                        }];
                        [moreOptionPicker addAction:viewProfileAction];
                    }
                    
                    ///Add share location action
                    UIAlertAction *removeMemberAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Remove Member", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [weakSelf removeUserFromMyCellAtIndex:rowIndex];
                        
                        
                        ///Dequeue the current Alert Controller and allow other to be visible
                        [[MAAlertPresenter sharedPresenter]dequeueAlert];
                        
                    }];
                    [moreOptionPicker addAction:removeMemberAction];
                    
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
                else{
                    if (![C411StaticHelper isUserDeleted:cellMember]) {
                        ///Show Profile of selected member
                        [self showProfileOfUser:cellMember];
                    }
                }
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (section == TABLE_SEC_INDEX_CELL_MEMBERS) {
        
        UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"PublicCellDetailSectionHeader" owner:self options:nil] lastObject];
        
        ///Get the title
        NSString *strSecTitle = nil;
        if (self.isOwner) {
            ///This cell is owned by current user
            strSecTitle = NSLocalizedString(@"You are the owner of this Cell", nil);
        }
        else{
            ///This cell is owned by someone else
            if (self.cellMembershipStatus == CellMembershipStatusNotAMember) {
                
                ///user is not the member of this cell
                strSecTitle = NSLocalizedString(@"You are not a member of this Cell", nil);
                
            }
            else if (self.cellMembershipStatus == CellMembershipStatusIsAMember) {
                
                ///user is the member of this cell
                strSecTitle = NSLocalizedString(@"You are a member of this Cell", nil);
                
            }
            else if(self.cellMembershipStatus == CellMembershipStatusPendingApproval){
                
                ///user is not the member of this cell, but his request is pending
                strSecTitle = NSLocalizedString(@"Your request has been sent to the owner of this Cell for approval", nil);
                
            }
            
            
        }

        
        UILabel *lblSectionTitle = (UILabel *)[headerView viewWithTag:101];
            lblSectionTitle.text = strSecTitle;
        [self applyColorOnHeaderview:headerView forSection:section];
         return headerView;

    }
    else{
        
        return nil;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == TABLE_SEC_INDEX_CELL_MEMBERS) {
        return 32.0f;
        
    }
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == TABLE_SEC_INDEX_CELL_MEMBERS) {
        return 32.0f;
    }
    return CGFLOAT_MIN;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == TABLE_SEC_INDEX_CELL_MEMBERS) {
       
        return self.noMoreData ? NSLocalizedString(@"No more Cells to load", nil) : nil;

    }
    
    return nil;
}

//****************************************************
#pragma mark - tableView:cellForRowAtIndexPath Helper Methods
//****************************************************

-(void)tableView:(UITableView *)tableView configureDetailCell:(C411PublicCellBasicDetailCell *)detailCell atIndexPath:(NSIndexPath *)indexPath
{
 
    detailCell.lblCellName.text = self.publicCellObj[kPublicCellNameKey];
    PublicCellCategory cellCategory = [C411StaticHelper getPublicCellCategoryFromPublicCell:self.publicCellObj];
    detailCell.lblCategory.text = [C411StaticHelper getLocalizedPublicCellCategory:cellCategory];
    
    NSString *strDescription = self.publicCellObj[kPublicCellDescriptionKey];
    if (strDescription.length > 0) {
        
        detailCell.lblDescription.text = strDescription;
        
    }
    else{
        
        detailCell.lblDescription.text = NSLocalizedString(@"N/A", nil);
        
    }
    NSString *strCellCity = self.publicCellObj[kPublicCellCityKey];
    if(strCellCity.length > 0){
        detailCell.lblLocation.text = strCellCity;
    }
    else{
        PFGeoPoint *cellGeoTag = self.publicCellObj[kPublicCellGeoTagKey];
        [detailCell updateLocationUsingCoordinate:CLLocationCoordinate2DMake(cellGeoTag.latitude, cellGeoTag.longitude)];
    }
    
    
}

//****************************************************
#pragma mark - tableView:heightForRowAtIndexPath Helper Methods
//****************************************************

-(CGFloat)tableView:(UITableView *)tableView heightForDetailCellAtIndexPath:(NSIndexPath *)indexPath
{
    
    ///Create a static cell for each reuse identifier
    static C411PublicCellBasicDetailCell *detailCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        detailCell = [tableView dequeueReusableCellWithIdentifier:@"C411PublicCellBasicDetailCell"];
        
    });
    
    
    ///Configure cell
    [self tableView:tableView configureDetailCell:detailCell atIndexPath:indexPath];
    
    ///Calculate height
    return [self tableView:tableView calculateHeightForConfiguredSizingCell:detailCell withMinHeight:TABLE_SEC_HEIGHT_CELL_BASIC_DETAILS];
    
}

- (CGFloat)tableView:(UITableView *)tableView calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell withMinHeight:(float)minHeight{
    
    sizingCell.bounds = CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height);
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    float height = size.height + 1.0f; // Add 1.0f for the cell separator height
    
    if (minHeight >= 0) {
       
        height = height < minHeight ? minHeight : height;

    }
    
    return height;
}


//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)publicCellJoined:(NSNotification *)notif
{
    PFObject *refreshedPublicCellObj = [notif.userInfo objectForKey:kRefreshedPublicCellKey];
    if ([refreshedPublicCellObj.objectId isEqualToString:self.publicCellObj.objectId]) {
        
        //self.strBarBtnRightTitle = nil;
        self.cellMembershipStatus = CellMembershipStatusPendingApproval;
        ///replace the public cell object with the new refreshed one
        self.publicCellObj = refreshedPublicCellObj;
        //[self setupViews];
        [self refreshCellMembersList];

        
    }
    
}

-(void)publicCellLeaved:(NSNotification *)notif
{
    PFObject *refreshedPublicCellObject = notif.object;
    if ([refreshedPublicCellObject.objectId isEqualToString:self.publicCellObj.objectId]) {

        //self.strBarBtnRightTitle = NSLocalizedString(@"Join this Cell", nil);
        self.cellMembershipStatus = CellMembershipStatusNotAMember;
        
        self.publicCellObj = refreshedPublicCellObject;
        //[self setupViews];
        [self refreshCellMembersList];

    }
    

}

/*OLD implementation of verification request handling
-(void)verificationRequestSent:(NSNotification *)notif
{
    ///update the verification request object
    self.verificationReqObj = notif.object;
}
*/

-(void)publicCellDoesNotExist:(NSNotification *)notif
{
    
    NSString *strDeletedPublicCellObjId = notif.object;
    if ([self.publicCellObj.objectId isEqualToString:strDeletedPublicCellObjId]) {
        ///clear the public cell object
        self.publicCellObj = nil;
        
        ///pop the view controller
        [self.navigationController popViewControllerAnimated:YES];
        
    }

}

-(void)publicCellUpdated:(NSNotification *)notif
{
    ///Public cell is updated so reload the tableview to reflect the change
    [self.tblVuPublicCellDetails reloadData];
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
    UIView *sectionHeaderView = [self.tblVuPublicCellDetails headerViewForSection:TABLE_SEC_INDEX_CELL_MEMBERS];
    [self applyColorOnHeaderview:sectionHeaderView forSection:TABLE_SEC_INDEX_CELL_MEMBERS];
}

@end
