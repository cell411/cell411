//
//  C411AddFriendCell.m
//  cell411
//
//  Created by Milan Agarwal on 03/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411AddFriendCell.h"
#import <Parse/Parse.h>
#import "C411StaticHelper.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ViewPhotoVC.h"
#import "AppDelegate.h"
#import "C411ColorHelper.h"

@implementation C411AddFriendCell

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self configureViews];
    [self registerForNotifications];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc {
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(void)setUser:(PFUser *)user
{
    if (_user != user) {
        
        _user = user;
        
        ///Set Friend name
        self.lblName.text = [C411StaticHelper getFullNameUsingFirstName:user[kUserFirstnameKey] andLastName:user[kUserLastnameKey]];
        
        ///Grab avatar image and place it here
        static UIImage *placeHolderImage = nil;
        if (!placeHolderImage) {
            
            placeHolderImage = [UIImage imageNamed:@"logo"];
        }
        
        ///Set tap gesture on image view
        [self addTapGestureOnImageView:self.imgVuAvatar];
        
        
        ///set the default image first, then fetch the gravatar
        self.imgVuAvatar.image = placeHolderImage;
        [self.imgVuAvatar setAvatarForUser:user shouldFallbackToGravatar:YES ofSize:self.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
        

    }
    
    
}

//****************************************************
#pragma mark - Public Methods
//****************************************************

-(void)setupCell
{
    
    if (self.user) {
        
        ///Set Friend name
        self.lblName.text = [C411StaticHelper getFullNameUsingFirstName:self.user[kUserFirstnameKey] andLastName:self.user[kUserLastnameKey]];
        
        ///Grab avatar image and place it here
        static UIImage *placeHolderImage = nil;
        if (!placeHolderImage) {
            
            placeHolderImage = [UIImage imageNamed:@"logo"];
        }
        
        ///Set tap gesture on image view
        [self addTapGestureOnImageView:self.imgVuAvatar];
        
        
        ///set the default image first, then fetch the gravatar
        self.imgVuAvatar.image = placeHolderImage;
        [self.imgVuAvatar setAvatarForUser:self.user shouldFallbackToGravatar:YES ofSize:self.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];

        ///Set default values for Add Friend button
        [self.btnAddFriend setTitle:NSLocalizedString(@"Add Friend", nil) forState:UIControlStateNormal];
        self.btnAddFriend.enabled = YES;
        self.btnAddFriend.alpha = 1.0;
        
        ///Check if user has sent/sending friend request
        NSNumber *addFRStateNum = self.dictAddFriendRequestState[self.user.objectId];
        if (addFRStateNum) {
            
            if (([addFRStateNum integerValue] == AddFriendRequestStateSending)
                ||([addFRStateNum integerValue] == AddFriendRequestStateReSending)) {
                
                ///Add Friend request is being sent/resent, so disable the button and decrease alpha
                self.btnAddFriend.enabled = NO;
                self.btnAddFriend.alpha = 0.6;
                
                ///Reset the title to resend if it's ReSending
                if([addFRStateNum integerValue] == AddFriendRequestStateReSending){
                    
                    [self.btnAddFriend setTitle:NSLocalizedString(@"Resend", nil) forState:UIControlStateNormal];
                    

                }
                
            }
            else if ([addFRStateNum integerValue] == AddFriendRequestStateSent){
            
                ///Friend Request is sent by user, enable button, remove alpha and show resend option
                self.btnAddFriend.enabled = YES;
                self.btnAddFriend.alpha = 1.0;
                [self.btnAddFriend setTitle:NSLocalizedString(@"Resend", nil) forState:UIControlStateNormal];

                
            }
        }
        else{
            
            ///User has not tried to add this friend yet
            
        }
        
        
    }
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    ///make avatar image circular
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    
    ///1.3 border for unfriend
    self.btnAddFriend.layer.borderWidth = 2.0;
    self.btnAddFriend.layer.cornerRadius = 3.0;
    self.btnAddFriend.layer.masksToBounds = YES;
    
    [self applyColors];
}

-(void)applyColors
{
    ///Set primary text color
    self.lblName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    
    ///set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnAddFriend.layer.borderColor = themeColor.CGColor;
    self.btnAddFriend.backgroundColor = themeColor;
    
    ///Set primaryBGText Color
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    [self.btnAddFriend setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    self.btnAddFriend.tintColor = primaryBGTextColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (void)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    
    if (self.user) {
        
        ///Show photo VC to view photo alert
        UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
        C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
        viewPhotoVC.user = self.user;
        [navRoot pushViewController:viewPhotoVC animated:YES];
        
    }
}

//****************************************************
#pragma mark - Notifications Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
