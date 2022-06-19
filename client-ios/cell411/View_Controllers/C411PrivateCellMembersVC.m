//
//  C411PrivateCellMembersVC.m
//  cell411
//
//  Created by Milan Agarwal on 06/11/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411PrivateCellMembersVC.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "C411NAUMemberCell.h"
#import "C411AppMemberCell.h"
#import "C411AppDefaults.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import "MAAlertPresenter.h"
#import "C411NonAppUsersSelectionVC.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ColorHelper.h"

@interface C411PrivateCellMembersVC ()<UITableViewDataSource, UITableViewDelegate, C411PvtCellMembersSelectionVCDelegate, C411NonAppUsersSelectionVCDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblVuCellMembers;
@property (strong, nonatomic) IBOutlet UIView *vuStickyNote;
@property (weak, nonatomic) IBOutlet UILabel *lblStickyNoteTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblStickyNoteSubtitle;
- (IBAction)barBtnAddTapped:(UIBarButtonItem *)sender;


///Members which are user friend and using the app
@property (nonatomic, strong) NSArray *arrCellAppMembers;
///Members which are in user phone contact and not using the app
@property (nonatomic, strong) NSArray *arrCellNauMembers;


@end

@implementation C411PrivateCellMembersVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblVuCellMembers.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    [self configureViews];
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

-(NSArray *)arrCellAppMembers
{
    if(!_arrCellAppMembers){
    
        _arrCellAppMembers = self.myPrivateCell[kCellMembersKey];
    }
    
    return _arrCellAppMembers;
}

-(NSArray *)arrCellNauMembers
{
    if(!_arrCellNauMembers){
        
        _arrCellNauMembers = self.myPrivateCell[kCellNauMembersKey];
    }
    
    return _arrCellNauMembers;
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    self.title = [C411StaticHelper getLocalizedNameForCell:self.myPrivateCell];
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblStickyNoteTitle.textColor = primaryTextColor;
    
    ///Set disabled text color
    self.lblStickyNoteSubtitle.textColor = [C411ColorHelper sharedInstance].disabledTextColor;

}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)showFriendSelectionScreen
{
    ///Show Cell selection VC
    C411PvtCellMembersSelectionVC *pvtCellMembersSelectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411PvtCellMembersSelectionVC"];
    
    pvtCellMembersSelectionVC.myPrivateCell = self.myPrivateCell;
    pvtCellMembersSelectionVC.membersSelectionDelegate = self;
    [self.navigationController pushViewController:pvtCellMembersSelectionVC animated:YES];

}

-(void)showPhoneContactSelectionScreen
{
    //show the contact list selection screen
    C411NonAppUsersSelectionVC *nonAppUserSelectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411NonAppUsersSelectionVC"];
    nonAppUserSelectionVC.delegate = self;
    nonAppUserSelectionVC.myPrivateCell = self.myPrivateCell;
    [self.navigationController pushViewController:nonAppUserSelectionVC animated:YES];

}


///Common method to handle updation of app members and nau members
-(void)updatePrivateCellWithMembers:(NSArray *)arrSelectedMembers forKey:(NSString *)strMemberTypeKey withCompletion:(PFBooleanResultBlock)completion
{
    ///1. Check if members list is updated,this may reduce the numbers of calls made to parse but comes with the cost of performance to iterate heavy arrays, so I am avoiding it for now and just making call to parse each time
    BOOL membersUpdated = YES;
    
    ///2. Update members if list is changed
    if (membersUpdated) {
        
        ///Save this array on parse for members
        NSArray *arrOldMembers = self.myPrivateCell[strMemberTypeKey];
        self.myPrivateCell[strMemberTypeKey] = arrSelectedMembers;
        
        __weak typeof(self) weakSelf = self;
        
        [self.myPrivateCell saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            
            ///Handle common cases here
            if (succeeded) {
                
                ///Do anything after save you want, like post notification to members interested in updated list of members,etc.
                
            }
            else{
                
                if (error) {
                    if(![AppDelegate handleParseError:error]){
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf.view.window.rootViewController];
                    }
                }
                
                ///Revert the cell to have old members
                weakSelf.myPrivateCell[strMemberTypeKey] = arrOldMembers;
                
            }
            
            ///Call the completion block if provided
            if(completion != NULL){
                
                completion(succeeded, error);
            }
            
        }];
        
    }
}

-(void)showStickyNote{
    
    ///Show sticky view
    self.vuStickyNote.hidden = NO;
}

-(void)hideStickyNote{
    
    ///Hide sticky note
    self.vuStickyNote.hidden = YES;
    
}

//***********************************************************
#pragma mark - C411PvtCellMembersSelectionVCDelegate Methods
//***********************************************************

-(void)didSelectMembers:(NSArray *)arrSelectedMembers ForCell:(PFObject *)C411Cell
{
    ///Update the members in cell
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:[AppDelegate sharedInstance].window.rootViewController.view animated:YES];
    [weakSelf updatePrivateCellWithMembers:arrSelectedMembers forKey:kCellMembersKey withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (succeeded) {
            
            ///Update the local array of members
            weakSelf.arrCellAppMembers = arrSelectedMembers;
            
            ///Members updated successfully, reload the tableview
            [weakSelf.tblVuCellMembers reloadData];
            
            ///Pop the  private cell members selection VC
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
        }
        
        ///Remove the progress hud
        [MBProgressHUD hideHUDForView:[AppDelegate sharedInstance].window.rootViewController.view animated:YES];
        
    }];
}


//**********************************************************
#pragma mark - C411NonAppUsersSelectionVCDelegate Methods
//**********************************************************

-(void)nonAppUsersSelectionVC:(C411NonAppUsersSelectionVC *)nonAppUsersSelectionVC didSelectNonAppUsers:(NSArray *)arrNonAppUsers
{
    ///Update the members in cell
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:[AppDelegate sharedInstance].window.rootViewController.view animated:YES];
    [weakSelf updatePrivateCellWithMembers:arrNonAppUsers forKey:kCellNauMembersKey withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (succeeded) {
            
            ///Update the local array of members
            weakSelf.arrCellNauMembers = arrNonAppUsers;
            
            ///Members updated successfully, reload the tableview
            [weakSelf.tblVuCellMembers reloadData];
            
            ///Pop the non app users selection VC
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
        }
        
        ///Remove the progress hud
        [MBProgressHUD hideHUDForView:[AppDelegate sharedInstance].window.rootViewController.view animated:YES];
        
    }];

}

//****************************************************
#pragma mark - UITableViewDatasource and delegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger membersCount = self.arrCellAppMembers.count + self.arrCellNauMembers.count;
    
    if(membersCount == 0){
        
        ///Show sticky note
        [self showStickyNote];
    }
    else{
        
        ///Hide sticky note
        [self hideStickyNote];
        
    }
    
    if([C411AppDefaults canShowSecurityGuardOption]){
        
        ///Add 1 for security guards option
        membersCount+= 1;
        
    }

    
    return membersCount;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellMemberId = @"C411AppMemberCell";
    NSInteger rowIndex = indexPath.row;
    
    static UIImage *placeHolderImage = nil;
    if (!placeHolderImage) {
        placeHolderImage = [UIImage imageNamed:@"logo_small"];
    }
    
    if([C411AppDefaults canShowSecurityGuardOption]){
        
        if (rowIndex == 0) {
            
            ///Create and Return App member cell
             C411AppMemberCell *pvtCellAppMemberCell = [tableView dequeueReusableCellWithIdentifier:cellMemberId];
            pvtCellAppMemberCell.imgVuAvatar.image = placeHolderImage;
            pvtCellAppMemberCell.lblMemberName.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ Call Centre",nil),LOCALIZED_APP_NAME];
            pvtCellAppMemberCell.btnRemove.hidden = YES;
            return pvtCellAppMemberCell;
        }
        else{
            rowIndex--;
        }
    }
    
    if (rowIndex < self.arrCellAppMembers.count) {
        
        ///Show cell members using the app
        C411AppMemberCell *pvtCellAppMemberCell = [tableView dequeueReusableCellWithIdentifier:cellMemberId];

        ///Get friend object
        PFUser *friend = [self.arrCellAppMembers objectAtIndex:rowIndex];
        
        ///Set Friend name
        pvtCellAppMemberCell.lblMemberName.text = [C411StaticHelper getFullNameUsingFirstName:friend[kUserFirstnameKey] andLastName:friend[kUserLastnameKey]];
        pvtCellAppMemberCell.btnRemove.hidden = NO;
        ///Add remove action
        pvtCellAppMemberCell.btnRemove.tag = rowIndex;
        [pvtCellAppMemberCell.btnRemove addTarget:self action:@selector(btnRemoveTapped:) forControlEvents:UIControlEventTouchUpInside];
        ///Grab avatar image and place it here
        ///set the default image first, then fetch the gravatar
        pvtCellAppMemberCell.imgVuAvatar.image = placeHolderImage;
        if ([C411StaticHelper isUserDeleted:friend]) {
            ///Grey out the name
            pvtCellAppMemberCell.lblMemberName.textColor = [C411ColorHelper sharedInstance].deletedUserTextColor;
        }
        else{
            ///Set primary text color
            pvtCellAppMemberCell.lblMemberName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
            ///Show profile pic
            [pvtCellAppMemberCell.imgVuAvatar setAvatarForUser:friend shouldFallbackToGravatar:YES ofSize:pvtCellAppMemberCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
        }
        
        return pvtCellAppMemberCell;
    }
    else{
        ///Create and Return NAU cell
        static NSString *nauCellMemberId = @"C411NAUMemberCell";
        C411NAUMemberCell *pvtCellNauMemberCell = [tableView dequeueReusableCellWithIdentifier:nauCellMemberId];

        ///Get new row index for nau members by decrementing arrCellAppMembers count
        NSInteger nauRowIndex = rowIndex - self.arrCellAppMembers.count;
        
        ///Get NAU Contact object
        NSDictionary *dictNauMember = [self.arrCellNauMembers objectAtIndex:nauRowIndex];
        
        
        ///Set Friend name
        pvtCellNauMemberCell.lblContactName.text = dictNauMember[kCellNauMemberNameKey];
        switch ([dictNauMember[kCellNauMemberTypeKey]intValue]) {
            case kCellNauMemberTypePhone:
                pvtCellNauMemberCell.lblContactEmailOrPhone.text = dictNauMember[kCellNauMemberPhoneKey];
                break;
            case kCellNauMemberTypeEmail:
                pvtCellNauMemberCell.lblContactEmailOrPhone.text = dictNauMember[kCellNauMemberEmailKey];
                break;
                
            default:
                break;
        }

        pvtCellNauMemberCell.btnRemove.hidden = NO;
        ///Add remove action
        pvtCellNauMemberCell.btnRemove.tag = rowIndex;
        [pvtCellNauMemberCell.btnRemove addTarget:self action:@selector(btnRemoveTapped:) forControlEvents:UIControlEventTouchUpInside];
        return pvtCellNauMemberCell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}




//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)barBtnAddTapped:(UIBarButtonItem *)sender {

#if NON_APP_USERS_ENABLED

    UIAlertController *moreOptionPicker = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    ///1.Add add friend to cell action
    UIAlertAction *addFriendToCellAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add friend", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ///Show Friend Selection screen for private cell
        [weakSelf showFriendSelectionScreen];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [moreOptionPicker addAction:addFriendToCellAction];
    
    ///2.Add add from phone contact action
    UIAlertAction *addPhoneContactToCellAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add from phone contact", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ///Show Phone contact selection screen for private cell
        [weakSelf showPhoneContactSelectionScreen];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [moreOptionPicker addAction:addPhoneContactToCellAction];
    
    
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
#else
    
    ///Show Friend Selection screen for private cell
    [self showFriendSelectionScreen];
    
#endif
}

-(void)btnRemoveTapped:(UIButton *)sender
{
    ///Get the index position of the member to be removed
    NSInteger rowIndex = sender.tag;
    NSString *strMemberName = nil;
    
    
    if (rowIndex < self.arrCellAppMembers.count) {
        
        PFUser *userFriend = [self.arrCellAppMembers objectAtIndex:rowIndex];
        strMemberName = [C411StaticHelper getFullNameUsingFirstName:userFriend[kUserFirstnameKey] andLastName:userFriend[kUserLastnameKey]];
        
    }
    else{
        
        ///Get new row index for nau members by decrementing arrCellAppMembers count
        NSInteger nauRowIndex = rowIndex - self.arrCellAppMembers.count;
        if(nauRowIndex < self.arrCellNauMembers.count){
        
            ///Get the member name
            NSDictionary *dictNauMember = [self.arrCellNauMembers objectAtIndex:nauRowIndex];
            strMemberName = dictNauMember[kCellNauMemberNameKey];

        }
        else{
            
            ///Index out of bounds
            return;
        }
        
    }
    
    NSString *strMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"Are you sure you want to remove %@ from the Cell?", nil),strMemberName];

    ///Show confirmation Dialog
    UIAlertController *confirmDeletionAlert = [UIAlertController alertControllerWithTitle:nil message:strMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        ///user said No, do nothing
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ///User opted to remove the member
        BOOL isDeletingAppMember = NO;
        NSMutableArray *arrUpdatedMembers = nil;
        NSString *strMemberTypeKey = nil;
        if (rowIndex < self.arrCellAppMembers.count) {
            
            isDeletingAppMember = YES;
            
            ///Make a mutable copy of the array
            arrUpdatedMembers = [self.arrCellAppMembers mutableCopy];
            
            ///Remove the member element
            [arrUpdatedMembers removeObjectAtIndex:rowIndex];
            
            ///set the key for updation
            strMemberTypeKey = kCellMembersKey;

        }
        else{
            
            ///Get new row index for nau members by decrementing arrCellAppMembers count
            NSInteger nauRowIndex = rowIndex - self.arrCellAppMembers.count;
            if(nauRowIndex < self.arrCellNauMembers.count){
                
                ///Make a mutable copy of the array
                arrUpdatedMembers = [self.arrCellNauMembers mutableCopy];
                
                ///Remove the member element
                [arrUpdatedMembers removeObjectAtIndex:nauRowIndex];
                
                ///set the key for updation
                strMemberTypeKey = kCellNauMembersKey;
            }
            
            
        }
        
        ///Update the private cell with member if it's available
        if(arrUpdatedMembers && strMemberTypeKey){
            
            __weak typeof(self) weakSelf = self;
            [MBProgressHUD showHUDAddedTo:[AppDelegate sharedInstance].window.rootViewController.view animated:YES];
            [weakSelf updatePrivateCellWithMembers:arrUpdatedMembers forKey:strMemberTypeKey withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (succeeded) {
                    
                    ///Update the local array of members
                    if(isDeletingAppMember){
                    
                        weakSelf.arrCellAppMembers = arrUpdatedMembers;
                        
                    }
                    else{
                    
                        weakSelf.arrCellNauMembers = arrUpdatedMembers;
                        
                    }
                    
                    ///Members updated successfully, reload the tableview
                    [weakSelf.tblVuCellMembers reloadData];
                    
                    
                }
                
                ///Remove the progress hud
                [MBProgressHUD hideHUDForView:[AppDelegate sharedInstance].window.rootViewController.view animated:YES];
                
            }];


        }
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [confirmDeletionAlert addAction:noAction];
    [confirmDeletionAlert addAction:yesAction];
    //[self presentViewController:confirmDeletionAlert animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmDeletionAlert];

}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
