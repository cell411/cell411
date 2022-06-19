//
//  C411RecentChatCell.m
//  cell411
//
//  Created by Milan Agarwal on 09/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411RecentChatCell.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "C411ChatRoom.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "C411ColorHelper.h"


@implementation C411RecentChatCell

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


-(void)dealloc
{
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    ///Make circular views
    [C411StaticHelper makeCircularView:self.imgVuChatEntity];
    [C411StaticHelper makeCircularView:self.vuUnreadMsgCountBase];
    [C411StaticHelper makeCircularView:self.imgVuAlertType];
    self.imgVuAlertType.layer.borderWidth = 2.0f;
    [self applyColors];
}

-(void)applyColors
{
    ///Set Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblEntityName.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblLastMsgTimestamp.textColor = secondaryTextColor;
    self.lblLastMessage.textColor = secondaryTextColor;
    
    self.vuUnreadMsgCountBase.backgroundColor = [C411ColorHelper sharedInstance].secondaryColor;
    self.imgVuAlertType.layer.borderColor = [UIColor whiteColor].CGColor;
    ///set unread msg count label color as white
    self.lblUnreadMsgCount.textColor = [UIColor whiteColor];
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)updateDetailsUsingChatRoom:(C411ChatRoom *)chatRoom
{
    ///set image and title
    if (chatRoom.entityType == ChatEntityTypeAlert) {
        
        self.imgVuChatEntity.image = [UIImage imageNamed:@"logo"];
        
        self.imgVuAlertType.image = [C411StaticHelper getAlertTypeSmallImageForAlertType:chatRoom.strEntityName];
        self.imgVuAlertType.hidden = NO;
        
        NSString *strAlertName = [C411StaticHelper getLocalizedAlertTypeStringFromString:chatRoom.strEntityName];
        
        self.lblEntityName.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Alert", nil),strAlertName];

    }
    else{
        self.imgVuChatEntity.image = [UIImage imageNamed:@"ic_placeholder_small_cell"];

        self.imgVuAlertType.hidden = YES;
        self.lblEntityName.text = chatRoom.strEntityName;

    }

    NSString *strLastMsg = chatRoom.strLastMsg;
    
    if (chatRoom.lastMsgType == ChatMsgTypeLoc) {
        ///If message type is loc then replace last message with hard coded text Location
        strLastMsg = NSLocalizedString(@"Location", nil);
    }
    else if (chatRoom.lastMsgType == ChatMsgTypeImg) {
        ///If message type is img then replace last message with hard coded text Image (Tap to view)
        strLastMsg = NSLocalizedString(@"Image(Tap to view)", nil);
    }

    NSString *strMsgSenderPrefix = nil;
    if ([chatRoom.strLastMsgSenderId isEqualToString:[AppDelegate getLoggedInUser].objectId]) {
        
        ///Last Message is sent by current user
        strMsgSenderPrefix = NSLocalizedString(@"You", nil);
    }
    else{
        ///Last Message is sent by someone else
        strMsgSenderPrefix = chatRoom.strLastMsgSenderFirstName;
        
    }
    
    self.lblLastMessage.text = [NSString stringWithFormat:@"%@:%@",strMsgSenderPrefix,strLastMsg];
    
    self.lblLastMsgTimestamp.text = [C411StaticHelper getFormattedTimeFromDate:chatRoom.lastMsgTimestamp withFormat:TimeStampFormatDateOrTime];
    
    if (chatRoom.unreadMsgCount > 0) {
        
        ///Set and show the unread counter
        self.lblUnreadMsgCount.text = [NSString localizedStringWithFormat:@"%d",(int)chatRoom.unreadMsgCount];
        self.vuUnreadMsgCountBase.hidden = NO;
        
        ///Change the color of timestamp to secondary
        self.lblLastMsgTimestamp.textColor = self.vuUnreadMsgCountBase.backgroundColor;
    }
    else{
        
        ///Hide the counter and unset it
        self.vuUnreadMsgCountBase.hidden = YES;
        self.lblUnreadMsgCount.text = [NSString localizedStringWithFormat:@"%d",0];
        
        ///Change the color of timestamp back to secondaryTextColor
        self.lblLastMsgTimestamp.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
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
