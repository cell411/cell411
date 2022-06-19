//
//  C411FriendListVC.m
//  cell411
//
//  Created by Milan Agarwal on 29/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411FriendListVC.h"
#import "C411FriendCell.h"
#import "ConfigConstants.h"
#import "Constants.h"
#import "UITableView+RemoveTopPadding.h"
#import <Parse/Parse.h>
#import "C411StaticHelper.h"
#import "C411AppDefaults.h"
#import "FriendsDelegate.h"
#import "C411BarcodeScannerVC.h"
#import "MAAlertPresenter.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "AppDelegate.h"
#import "C411UserProfilePopup.h"
#import "C411ViewPhotoVC.h"
#import "C411ColorHelper.h"

@interface C411FriendListVC ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,C411BarcodeScannerVCDelegate>

@property (nonatomic, assign) id<FriendsDelegate> friendsDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tblVuFriends;
@property (strong, nonatomic) IBOutlet UIView *vuStickyNote;
@property (strong, nonatomic) IBOutlet UILabel *lblStickyNoteText;
@end

@implementation C411FriendListVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///Remove top padding of 35 pixel
    self.tblVuFriends.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);

    self.friendsDelegate = [C411AppDefaults sharedAppDefaults];
    [self registerForNotifications];
    [self addGestures];
    [self applyColors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
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
-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set disabled text color
    self.lblStickyNoteText.textColor = [C411ColorHelper sharedInstance].disabledTextColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(friendListUpdated:) name:kFriendListUpdatedNotification object:nil];
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

-(void)addGestures
{
    UILongPressGestureRecognizer *deleteGesture = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleFriendDeletion:)];
    deleteGesture.delegate = self;
    [self.tblVuFriends addGestureRecognizer:deleteGesture];
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


-(void)showScanQRCodeScreen
{
    C411BarcodeScannerVC *barcodeScannerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411BarcodeScannerVC"];
    barcodeScannerVC.delegate = self;
    [self.navigationController pushViewController:barcodeScannerVC animated:YES];
}

//****************************************************
#pragma mark - Gesture Methods
//****************************************************

-(void)handleFriendDeletion:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        ///Show delete user popup
        CGPoint touchPoint = [gestureRecognizer locationInView:self.tblVuFriends];
        
        NSIndexPath *indexPath = [self.tblVuFriends indexPathForRowAtPoint:touchPoint];
        if (indexPath != nil && indexPath.row < self.friendsDelegate.arrFriends.count) {
            NSInteger rowIndex = indexPath.row;
            PFUser *userFriend = [self.friendsDelegate.arrFriends objectAtIndex:rowIndex];
            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Do you want to remove %@ from your friend list ?",nil),[C411StaticHelper getFullNameUsingFirstName:userFriend[kUserFirstnameKey] andLastName:userFriend[kUserLastnameKey]]];
            UIAlertController *confirmDeletionAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                ///user said No, do nothing
                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];

            }];
            
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                ///user said yes, delete the friend
                PFUser *currentUser = [AppDelegate getLoggedInUser];
                PFRelation *friendsRelation = [currentUser relationForKey:kUserFriendsKey];
                [friendsRelation removeObject:userFriend];
                
                __weak typeof(self) weakSelf = self;
                ///save current user object
                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    
                    if (succeeded) {
                        
                        ///1.Ask friends delegate to remove this friend from its array and post notification when removed to update the friends list
                        [weakSelf.friendsDelegate removeFriendAtIndex:rowIndex];
                        
                        
                        
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
                    
                }];

                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];

                
            }];
            
            [confirmDeletionAlert addAction:noAction];
            [confirmDeletionAlert addAction:yesAction];
            //[self presentViewController:confirmDeletionAlert animated:YES completion:NULL];
            ///Enqueue the alert controller object in the presenter queue to be displayed one by one
            [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmDeletionAlert];

        
        }
        
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged){
        ///Do things required when state changes
        //  NSLog(@"Changed");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        ///Do things required when state ends
        //NSLog(@"Ended");
    }
    
}


//****************************************************
#pragma mark - Action Methods
//****************************************************


- (void)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    
    UIImageView *imgVuAvatar = (UIImageView *) sender.view;
    NSInteger rowIndex = imgVuAvatar.tag;
    if (rowIndex < self.friendsDelegate.arrFriends.count) {
        ///Get friend object
        PFUser *friend = [self.friendsDelegate.arrFriends objectAtIndex:rowIndex];
        if (![C411StaticHelper isUserDeleted:friend]) {
            ///Show photo VC to view photo alert
            UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
            C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
            viewPhotoVC.user = friend;
            [navRoot pushViewController:viewPhotoVC animated:YES];
        }
    }
}


//****************************************************
#pragma mark - C411BarcodeScannerVCDelegate Methods
//****************************************************

-(void)scanner:(C411BarcodeScannerVC *)scanner didScanBarcodesWithResult:(NSArray *)arrBarcodes
{
    scanner.delegate = nil;
    
    ///remove the scanner
    [self.navigationController popViewControllerAnimated:YES];
    
    if (arrBarcodes && arrBarcodes.count > 0) {
        
        [[C411AppDefaults sharedAppDefaults] addFriendWithEmailId:[arrBarcodes lastObject]];
        
    }

}

//****************************************************
#pragma mark - UITableViewDatasource and delegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger friendsCount = self.friendsDelegate.arrFriends.count;
    
    if (friendsCount == 0) {
        
        self.vuStickyNote.hidden = NO;
    }
    else{
        
        self.vuStickyNote.hidden = YES;
    }

    return friendsCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    if (rowIndex < self.friendsDelegate.arrFriends.count) {
        
        ///Create and Return friend cell
        static NSString *friendCellId = @"C411FriendCell";
        C411FriendCell *friendCell = [tableView dequeueReusableCellWithIdentifier:friendCellId];
        ///Get friend object
        PFUser *friend = [self.friendsDelegate.arrFriends objectAtIndex:rowIndex];
        ///Set Friend name
        friendCell.lblFriendName.text = [C411StaticHelper getFullNameUsingFirstName:friend[kUserFirstnameKey] andLastName:friend[kUserLastnameKey]];
        
//        NSString *strEmail = [C411StaticHelper getEmailFromUser:friend];
//        if (strEmail.length > 0) {
//            
//            ///Grab avatar image and place it here
//            static UIImage *placeHolderImage = nil;
//            if (!placeHolderImage) {
//                
//                placeHolderImage = [UIImage imageNamed:@"logo_small"];
//            }
//            friendCell.imgVuAvatar.email = strEmail;
//            friendCell.imgVuAvatar.placeholder = placeHolderImage;
//            friendCell.imgVuAvatar.defaultGravatar = RFDefaultGravatarUrlSupplied;
//            NSURL *defaultGravatarUrl = [NSURL URLWithString:DEFAULT_GRAVATAR_URL];
//            friendCell.imgVuAvatar.defaultGravatarUrl = defaultGravatarUrl;
//            
//            friendCell.imgVuAvatar.size = friendCell.imgVuAvatar.bounds.size.width * 3;
//            [friendCell.imgVuAvatar load];
//
//        }
        
        ///Grab avatar image and place it here
        static UIImage *placeHolderImage = nil;
        if (!placeHolderImage) {
            
            placeHolderImage = [UIImage imageNamed:@"logo_small"];
        }
        
        ///Set tap gesture on image view
        friendCell.imgVuAvatar.tag = rowIndex;
        [self addTapGestureOnImageView:friendCell.imgVuAvatar];
        
        
        ///set the default image first, then fetch the gravatar
        friendCell.imgVuAvatar.image = placeHolderImage;
        if ([C411StaticHelper isUserDeleted:friend]) {
            ///Grey out the name
            friendCell.lblFriendName.textColor = [C411ColorHelper sharedInstance].deletedUserTextColor;
        }
        else{
            ///Set primary text color
            friendCell.lblFriendName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
            ///Show profile pic
            [friendCell.imgVuAvatar setAvatarForUser:friend shouldFallbackToGravatar:YES ofSize:friendCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
        }
        return friendCell;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    if (rowIndex < self.friendsDelegate.arrFriends.count) {
        
        ///Get friend object
        PFUser *friend = [self.friendsDelegate.arrFriends objectAtIndex:rowIndex];
        if (![C411StaticHelper isUserDeleted:friend]) {
            ///Show user profile popup
            C411UserProfilePopup *vuUserProfilePopup = [[[NSBundle mainBundle] loadNibNamed:@"C411UserProfilePopup" owner:self options:nil] lastObject];
            vuUserProfilePopup.user = friend;
            UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
            ///Set view frame
            vuUserProfilePopup.frame = rootVC.view.bounds;
            ///add view
            [rootVC.view addSubview:vuUserProfilePopup];
            [rootVC.view bringSubviewToFront:vuUserProfilePopup];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)friendListUpdated:(NSNotification *)notif
{
    [self reloadData];
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
