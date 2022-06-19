//
//  C411SpammedUsersListVC.m
//  cell411
//
//  Created by Milan Agarwal on 18/10/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411SpammedUsersListVC.h"
#import "AppDelegate.h"
#import "C411SpammedUserCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ColorHelper.h"

#define BTN_SPAM_INITIAL_TAG    100

@interface C411SpammedUsersListVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblVuSpammedUsers;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLoading;
@property (weak, nonatomic) IBOutlet UIView *vuStickyNote;
@property (weak, nonatomic) IBOutlet UILabel *lblStickyMsg;
@property (nonatomic, strong) NSMutableArray *arrSpammedUsers;

@end

@implementation C411SpammedUsersListVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///Remove top padding of 35 pixel
    self.tblVuSpammedUsers.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    [C411StaticHelper configurePromptView:self.vuStickyNote];
    [self configureViews];
    [self registerForNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)dealloc
{
    self.arrSpammedUsers = nil;
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************


-(NSMutableArray *)arrSpammedUsers
{
    if (!_arrSpammedUsers) {
        __weak typeof(self) weakSelf = self;
       
        ///Show loading screen
        [self.activityLoading startAnimating];
        [[AppDelegate sharedInstance]getUsersSpammedByCurrentUserWithCompletion:^(id result, NSError *error) {
            ///Hide Loading Screen
            [weakSelf.activityLoading stopAnimating];
            if (!error) {
                    
                ///Got members spammed by current user successfully
                ///Iterate the array of spammed members and remove deleted users
                NSMutableArray *arrSpammedUsers = [NSMutableArray array];
                for (PFUser *spammedUser in (NSArray *)result) {
                    if (![C411StaticHelper isUserDeleted:spammedUser]) {
                        [arrSpammedUsers addObject:spammedUser];
                    }
                }
                weakSelf.arrSpammedUsers = arrSpammedUsers;
                if (weakSelf.arrSpammedUsers.count == 0) {
                    
                    ///Show sticky note
                    weakSelf.vuStickyNote.hidden = NO;
                }
                
                [weakSelf.tblVuSpammedUsers reloadData];
                
                }
                else{
                    
                    ///Some error occured
                    [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
                    
                }
                
           
        }];
        
    }
    
    return _arrSpammedUsers;
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    self.title = NSLocalizedString(@"Blocked Users", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)applyColors {
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    self.lblStickyMsg.textColor = [C411ColorHelper sharedInstance].disabledTextColor;
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
#pragma mark - UITableViewDatasource and delegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.arrSpammedUsers.count > 0) {
        
        ///Hide sticky note
        self.vuStickyNote.hidden = YES;
        
    }
    else if (!self.activityLoading.isAnimating){
        
        ///Show sticky note
        self.vuStickyNote.hidden = NO;
        
    }
    return self.arrSpammedUsers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    

    ///Create and Return spammed user cell
    static NSString *spammedUserCellId = @"C411SpammedUserCell";
    C411SpammedUserCell *spammedUserCell = [tableView dequeueReusableCellWithIdentifier:spammedUserCellId];
    
    ///Get spammed user object
    PFUser *spammedUser = [self.arrSpammedUsers objectAtIndex:rowIndex];
    ///Set user name
    spammedUserCell.lblFriendName.text = [C411StaticHelper getFullNameUsingFirstName:spammedUser[kUserFirstnameKey] andLastName:spammedUser[kUserLastnameKey]];
    
//    NSString *strEmail = [C411StaticHelper getEmailFromUser:spammedUser];
//    if (strEmail.length > 0) {
//        ///Grab avatar image and place it here
//        static UIImage *placeHolderImage = nil;
//        if (!placeHolderImage) {
//            
//            placeHolderImage = [UIImage imageNamed:@"logo_small"];
//        }
//        spammedUserCell.imgVuAvatar.email = strEmail;
//        spammedUserCell.imgVuAvatar.placeholder = placeHolderImage;
//        spammedUserCell.imgVuAvatar.defaultGravatar = RFDefaultGravatarUrlSupplied;
//        NSURL *defaultGravatarUrl = [NSURL URLWithString:DEFAULT_GRAVATAR_URL];
//        spammedUserCell.imgVuAvatar.defaultGravatarUrl = defaultGravatarUrl;
//        
//        spammedUserCell.imgVuAvatar.size = spammedUserCell.imgVuAvatar.bounds.size.width * 3;
//        [spammedUserCell.imgVuAvatar load];
//
//    }
    
    ///Grab avatar image and place it here
    static UIImage *placeHolderImage = nil;
    if (!placeHolderImage) {
        
        placeHolderImage = [UIImage imageNamed:@"logo_small"];
    }
    
    ///set the default image first, then fetch the gravatar
    spammedUserCell.imgVuAvatar.image = placeHolderImage;
    [spammedUserCell.imgVuAvatar setAvatarForUser:spammedUser shouldFallbackToGravatar:YES ofSize:spammedUserCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];

    
    ///Set button action to unspam user
    [spammedUserCell.btnUnSpam addTarget:self action:@selector(btnUnSpamTapped:) forControlEvents:UIControlEventTouchUpInside];
    spammedUserCell.btnUnSpam.tag = BTN_SPAM_INITIAL_TAG + rowIndex;
    
    return spammedUserCell;
        
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 52.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    ///Do anything on tap of cell
    
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

-(void)btnUnSpamTapped:(UIButton *)sender
{

    NSUInteger rowIndex = sender.tag - BTN_SPAM_INITIAL_TAG;
    if (rowIndex < self.arrSpammedUsers.count) {
        
        PFUser *userToUnspam = [self.arrSpammedUsers objectAtIndex:rowIndex];
        NSString *strUnspamUserId = userToUnspam.objectId;
        
        ///remove the user object from local array and reload table
        [self.arrSpammedUsers removeObjectAtIndex:rowIndex];
        [self.tblVuSpammedUsers reloadData];
        
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        __weak typeof(self) weakSelf = self;
        
        ///Check whether there is already a SPAM_ADD task available on Parse for this user assigned by current user.
            ///1.If its available that means somehow the user being unspammed has not added current user to his/her spammedBy relation yet. So we have to remove this SPAM_ADD task from Parse table instead of creating a SPAM_REMOVE task on it.
            ///2.If its unavailable then add SPAM_REMOVE task on parse, so that this user can remove current user from his/her spammedBy relation
        PFQuery *getSpamAddTaskQuery = [PFQuery queryWithClassName:kTaskClassNameKey];
        [getSpamAddTaskQuery whereKey:kTaskAssigneeUserIdKey equalTo:currentUser.objectId];
        [getSpamAddTaskQuery whereKey:kTaskUserIdKey equalTo:userToUnspam.objectId];
        [getSpamAddTaskQuery whereKey:kTaskTaskKey equalTo:kTaskSpamAdd];
        [getSpamAddTaskQuery whereKey:kTaskStatusKey equalTo:kTaskStatusPending];
        [getSpamAddTaskQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
            
            if (!error) {
                
                ///condition1. is true, associated SPAM_ADD task is found, remove this task
                ///Remove user to unspam from current user's spamUsers Relation
                PFRelation *spamUserRelation = [currentUser relationForKey:kUserSpamUsersKey];
                [spamUserRelation removeObject:userToUnspam];
                [currentUser saveEventually];

                ///Remove this task from Parse
                PFObject *spamAddTask = (PFObject *)object;
                [spamAddTask deleteEventually];
                
                ///post notification to observers
                [[NSNotificationCenter defaultCenter]postNotificationName:kUserUnblockedNotification object:strUnspamUserId];
                
            }
            else if (error.code == kPFErrorObjectNotFound)
            {
                ///condition2. is true, associated SPAM_ADD task is found, remove this task
                
                ///Remove user to unspam from current user's spamUsers Relation
                PFRelation *spamUserRelation = [currentUser relationForKey:kUserSpamUsersKey];
                [spamUserRelation removeObject:userToUnspam];
                [currentUser saveEventually];
                
                ///create a SPAM_REMOVE task so that userToUnspam can remove current user from his/her spammedBy relation
                PFObject *unSpamTask = [PFObject objectWithClassName:kTaskClassNameKey];
                unSpamTask[kTaskAssigneeUserIdKey] = currentUser.objectId;
                unSpamTask[kTaskUserIdKey] = userToUnspam.objectId;
                unSpamTask[kTaskTaskKey] = kTaskSpamRemove;
                unSpamTask[kTaskStatusKey] = kTaskStatusPending;
                [unSpamTask saveEventually];

                ///post notification to observers
                [[NSNotificationCenter defaultCenter]postNotificationName:kUserUnblockedNotification object:strUnspamUserId];
                
            }
            else {
                ///error occured while checking status
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                
                ///Insert the user back to array of spammed users and reload tableview
                [weakSelf reinsertUserToSpamUsersList:userToUnspam];
            }
            
            
            
        }];

        
    }
}


-(void)reinsertUserToSpamUsersList:(PFUser *)spammedUser
{
    [self.arrSpammedUsers addObject:spammedUser];
    [self.tblVuSpammedUsers reloadData];
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
