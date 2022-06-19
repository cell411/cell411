//
//  C411PvtCellMembersSelectionVC.m
//  cell411
//
//  Created by Milan Agarwal on 03/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411PvtCellMembersSelectionVC.h"
#import "C411FriendSelectionCell.h"
#import "ConfigConstants.h"
#import "Constants.h"
#import "C411StaticHelper.h"
#import "C411AppDefaults.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "AppDelegate.h"
#import "C411ColorHelper.h"

@interface C411PvtCellMembersSelectionVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblVuFriends;
-(IBAction)barBtnUpdateTapped:(id)sender;

@property (nonatomic, strong) NSMutableArray *arrFilteredFriends;
@property (nonatomic, strong) NSMutableArray *arrSelectedMembers;


@end

@implementation C411PvtCellMembersSelectionVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///Remove top padding of 35 pixel
    self.tblVuFriends.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
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
#pragma mark - Private Method
//****************************************************

-(void)configureViews
{
    self.title = NSLocalizedString(@"Select Friends", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
}


-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(friendListUpdated:) name:kFriendListUpdatedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cellMembersUpdated:) name:kCellsMembersUpdatedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)reloadData
{
    [self.tblVuFriends reloadData];
    
}

-(BOOL)didCellContainsFriend:(PFUser *)friend
{
    BOOL isFriendExist = NO;
    
    for (PFUser *member in self.arrSelectedMembers) {
        
        if ([member.objectId isEqualToString:friend.objectId]) {
            isFriendExist = YES;
            break;
        }
        
    }
    
    return isFriendExist;
}

-(NSUInteger)selectedIndexOfObject:(PFUser *)friend
{
    NSUInteger friendIndex = NSNotFound;
    NSUInteger counter = 0;
    for (PFUser *member in self.arrSelectedMembers) {
        
        if ([member.objectId isEqualToString:friend.objectId]) {
            friendIndex = counter;
            break;
        }
        
        counter++;
        
    }
    
    return friendIndex;
}

//****************************************************
#pragma mark - Action Methods
//****************************************************
-(IBAction)barBtnUpdateTapped:(id)sender {
    
    if ((self.arrSelectedMembers.count > 0)
        ||(self.myPrivateCell && ([self.myPrivateCell[kCellMembersKey] count] > 0))) {
        ///Call the delegate and pass the members selected, also wait for the delegate to remove this screen as per their way
        [self.membersSelectionDelegate didSelectMembers:self.arrSelectedMembers ForCell:self.myPrivateCell];
    }
    else{
        
        ///Show toast to select at least one user
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Please select at least 1 friend", nil)];
    }

}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(NSMutableArray *)arrFilteredFriends {
    if (!_arrFilteredFriends) {
        NSMutableArray *arrFilteredFriends = [NSMutableArray array];
        ///Iterate friends array and get only non deleted users
        NSArray *arrFriends = [C411AppDefaults sharedAppDefaults].arrFriends;
        for (PFUser *friend in arrFriends) {
            if (![C411StaticHelper isUserDeleted:friend]) {
                [arrFilteredFriends addObject:friend];
            }
        }
        _arrFilteredFriends = arrFilteredFriends;
    }
    return _arrFilteredFriends;
}

-(NSMutableArray *)arrSelectedMembers
{
    
    if (!_arrSelectedMembers) {
        
        _arrSelectedMembers = [NSMutableArray arrayWithArray:self.myPrivateCell[kCellMembersKey]];
        
        
    }
    
    return _arrSelectedMembers;
    
}


//****************************************************
#pragma mark - UITableViewDatasource and delegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    
    if([C411AppDefaults canShowSecurityGuardOption]){
        
        return self.arrFilteredFriends.count + 1;
        
    }
    else{
        
        return self.arrFilteredFriends.count;
        
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    
    
    ///Create and Return friend cell
    static NSString *friendSelectionCellId = @"C411FriendSelectionCell";
    C411FriendSelectionCell *friendSelectionCell = [tableView dequeueReusableCellWithIdentifier:friendSelectionCellId];
    
    
    if([C411AppDefaults canShowSecurityGuardOption]){
        
        if (rowIndex == 0) {
            
            
            friendSelectionCell.lblFriendName.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ Call Centre",nil),LOCALIZED_APP_NAME];
            friendSelectionCell.btnCheckbox.hidden = YES;
            return friendSelectionCell;
        }
        else{
            friendSelectionCell.btnCheckbox.hidden = NO;
            rowIndex--;
        }

    }
    
    ///Get friend object
    PFUser *friend = [self.arrFilteredFriends objectAtIndex:rowIndex];

    ///Set Friend name
    friendSelectionCell.lblFriendName.text = [C411StaticHelper getFullNameUsingFirstName:friend[kUserFirstnameKey] andLastName:friend[kUserLastnameKey]];
    
//    NSString *strEmail = [C411StaticHelper getEmailFromUser:friend];
//    if (strEmail.length > 0) {
//        ///Grab avatar image and place it here
//        static UIImage *placeHolderImage = nil;
//        if (!placeHolderImage) {
//            
//            placeHolderImage = [UIImage imageNamed:@"logo_small"];
//        }
//        friendSelectionCell.imgVuAvatar.email = strEmail;
//        friendSelectionCell.imgVuAvatar.placeholder = placeHolderImage;
//        friendSelectionCell.imgVuAvatar.defaultGravatar = RFDefaultGravatarUrlSupplied;
//        NSURL *defaultGravatarUrl = [NSURL URLWithString:DEFAULT_GRAVATAR_URL];
//        friendSelectionCell.imgVuAvatar.defaultGravatarUrl = defaultGravatarUrl;
//        
//        friendSelectionCell.imgVuAvatar.size = friendSelectionCell.imgVuAvatar.bounds.size.width * 3;
//        [friendSelectionCell.imgVuAvatar load];
//
//    }
    
    ///Grab avatar image and place it here
    static UIImage *placeHolderImage = nil;
    if (!placeHolderImage) {
        
        placeHolderImage = [UIImage imageNamed:@"logo_small"];
    }
    
    ///set the default image first, then fetch the gravatar
    friendSelectionCell.imgVuAvatar.image = placeHolderImage;
    [friendSelectionCell.imgVuAvatar setAvatarForUser:friend shouldFallbackToGravatar:YES ofSize:friendSelectionCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];

    
    ///Show tick if friend is already selected
    if ([self didCellContainsFriend:friend]) {
        ///show selected
        friendSelectionCell.btnCheckbox.selected = YES;
        
    }
    else{
        ///show unselected
        friendSelectionCell.btnCheckbox.selected = NO;
    }
    return friendSelectionCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    
    if([C411AppDefaults canShowSecurityGuardOption]){
       
        if (rowIndex == 0) {
            ///do nothing
            return;
        }
        else{
            ///decrement the row index
            rowIndex--;
        }

    }
    
    PFUser *friend = [self.arrFilteredFriends objectAtIndex:rowIndex];
    
    NSUInteger memberSelectedIndex = [self selectedIndexOfObject:friend];
    if (memberSelectedIndex != NSNotFound) {
        
        ///Member already selected, remove it from selected members array
        [self.arrSelectedMembers removeObjectAtIndex:memberSelectedIndex];
        
    }
    else{
        
        ///This member is not currently in the group, add it to the selected members array
        [self.arrSelectedMembers addObject:friend];
    }
    
    ///Reload table to toggle tick marks
    [self.tblVuFriends reloadData];
    
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)friendListUpdated:(NSNotification *)notif
{
    self.arrFilteredFriends = nil;///reset filtered friends
    [self reloadData];
}

-(void)cellMembersUpdated:(NSNotification *)notif
{
    [self reloadData];
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
