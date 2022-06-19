//
//  C411FriendRequestCell.m
//  cell411
//
//  Created by Milan Agarwal on 03/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411FriendRequestCell.h"
#import <Parse/Parse.h>
#import "C411StaticHelper.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ViewPhotoVC.h"
#import "AppDelegate.h"
#import "C411Enums.h"
#import "C411ColorHelper.h"

@implementation C411FriendRequestCell

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
#pragma mark - Public Methods
//****************************************************

-(void)setupCell
{
    if (self.friendRequest) {
        
        PFUser *user = self.friendRequest[kCell411AlertIssuedByKey];
        
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
        
        NSString *strRequestStatus = self.friendRequest[kCell411AlertStatusKey];
        if ([strRequestStatus isEqualToString:kAlertStatusPending]) {
            
            ///show the accept reject button with alpha reset and enabled
            [self showAcceptRejectButtons];
            
            ///hide the action indicator label
            self.lblActionIndicator.hidden = YES;
            
            ///Check if user has any pending action for this request
            NSNumber *pendingActionNum = self.dictPendingActions[self.friendRequest.objectId];
            if (pendingActionNum) {
                
                if ([pendingActionNum integerValue] == FriendRequestActionPendingApproved) {
                    
                    ///Disable both Accept and reject button
                    self.btnAccept.enabled = NO;
                    self.btnReject.enabled = NO;
                    
                    ///lower the alpha of Accept
                    self.btnAccept.alpha = 0.6;
                    
                }
                else if ([pendingActionNum integerValue] == FriendRequestActionPendingDenied) {
                    
                    ///Disable both Accept and reject button
                    self.btnAccept.enabled = NO;
                    self.btnReject.enabled = NO;
                    
                    ///lower the alpha of Reject
                    self.btnReject.alpha = 0.6;
                    
                }
                
            }
            else{
                
                ///user has not initiated any action for this request
                
            }
        }
        else{
            
            ///status is either accepted or rejected, hide the buttons
            [self hideAcceptRejectButtons];
            
            ///set the text on label indicating request is accepted or rejected
            if ([strRequestStatus isEqualToString:kAlertStatusApproved]) {
                
                ///show the request accepted text
                self.lblActionIndicator.text = NSLocalizedString(@"Request Accepted", nil);
                
            }
            else if ([strRequestStatus isEqualToString:kAlertStatusDenied]) {
                
                ///show the request rejected text
                self.lblActionIndicator.text = NSLocalizedString(@"Request Rejected", nil);
                
                
            }
            
            ///Show the action indicator label
            self.lblActionIndicator.hidden = NO;
            
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
    
    ///1.3 border color for unfriend
    self.btnAccept.layer.borderWidth = 2.0;
    self.btnReject.layer.borderWidth = 2.0;

    self.btnAccept.layer.cornerRadius = 3.0;
    self.btnAccept.layer.masksToBounds = YES;
    self.btnReject.layer.cornerRadius = 3.0;
    self.btnReject.layer.masksToBounds = YES;
   
    [self applyColors];
}

-(void)applyColors
{
    ///Set primary text color
    self.lblName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    
    ///Set secondary text color
    self.lblActionIndicator.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    
    ///set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnAccept.layer.borderColor = themeColor.CGColor;
    self.btnReject.layer.borderColor = themeColor.CGColor;
    [self.btnReject setTitleColor:themeColor forState:UIControlStateNormal];
    self.btnAccept.backgroundColor = themeColor;
    
    ///Set primaryBGText Color
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    [self.btnAccept setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    self.btnReject.backgroundColor = primaryBGTextColor;
    
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

-(void)showAcceptRejectButtons
{
    self.btnAccept.hidden = NO;
    self.btnReject.hidden = NO;
    
    ///reset alpha and reeanble the buttons
    self.btnAccept.alpha = 1.0;
    self.btnAccept.enabled = YES;
    self.btnReject.alpha = 1.0;
    self.btnReject.enabled = YES;

}

-(void)hideAcceptRejectButtons
{
    self.btnAccept.hidden = YES;
    self.btnReject.hidden = YES;
    
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (void)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    
    if (self.friendRequest) {
        PFUser *user = self.friendRequest[kCell411AlertIssuedByKey];
        
        ///Show photo VC to view photo alert
        UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
        C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
        viewPhotoVC.user = user;
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
