//
//  C411ChatVC.m
//  cell411
//
//  Created by Milan Agarwal on 02/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ChatVC.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import <JSQMessagesViewController/JSQSystemSoundPlayer+JSQMessages.h>
#import "DateHelper.h"
#import <Parse/Parse.h>
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411ChatManager.h"
#import "MAAlertPresenter.h"
#import "C411MuteChatRoomPopup.h"
#import "AppDelegate.h"
#import "C411ChatHelper.h"
#import "C411AlertNotificationPayload.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411LocationManager.h"
#import <OpenInGoogleMaps/OpenInGoogleMapsController.h>
#import "UIImage+ResizeAdditions.h"
#import "MAJSQAsyncPhotoMediaItem.h"
#import "C411ViewPhotoVC.h"
#import "MATimestampFormatter.h"
#import "C411ChatRoomSettings.h"
#import "JSQMessagesInputToolbar+SafeArea.h"
#import "C411ColorHelper.h"

#define K_MESSAGES_PER_PAGE 25 // A macro defining the numbers in one request

@import Firebase;
@import Photos;

@interface C411ChatVC ()<JSQMessagesCollectionViewDataSource,
JSQMessagesCollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuStickyNote;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuStickyNote;
@property (weak, nonatomic) IBOutlet UILabel *lblStickyNote;
- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender;
- (IBAction)barBtnShowMoreOptionsTapped:(UIBarButtonItem *)sender;

@property (nonatomic, strong) FIRDatabaseReference *fireDBRef;
@property (nonatomic, strong) FIRStorageReference *fireImgStorageRef;
@property (nonatomic, assign) FIRDatabaseHandle newMsgRefHandle;
@property (nonatomic, strong) NSMutableArray *arrMessages;

@property (nonatomic, strong) NSString *strLastMsgKey;
@property (nonatomic, strong) NSString *strRecentMsgKey;
@property (nonatomic, assign, getter=didObserverAttached) BOOL observerAttached;
@property (nonatomic, assign, getter=shouldShareLocationOnUpdate) BOOL shareLocationOnUpdate;
@property (nonatomic, weak) MBProgressHUD *locationRetrievalProgressHud;
@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImg;
@property (nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImg;

@end

@implementation C411ChatVC

#if CHAT_ENABLED
//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ///post notification that it's being displayed
    [[NSNotificationCenter defaultCenter]postNotificationName:kDidOpenedChatVCNotification object:nil];

    // Do any additional setup after loading the view.
    [self configureViews];
    
    if ([C411ChatHelper isUserRemovedFromEntityWithId:self.strEntityId]) {
        
        ///User is removed so hide the message box
        [self hideChatInputbox];
    
    }
    
    if([[FIRAuth auth]currentUser]){
        [self loadEarlierMessages];
    }
    else{
        ///Authenticate to Firebase first
        __weak typeof(self) weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [AppDelegate logUserToFirebaseWithCompletion:^(id result, NSError *error) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            FIRUser *user = ((FIRAuthDataResult *)result).user;
            if(!error && user){
                [weakSelf loadEarlierMessages];
            }
            else{
                ///hide chat input box
                [weakSelf hideChatInputbox];
                if(error) {
                    ///show error
                    [AppDelegate showToastOnView:nil withMessage:error.localizedDescription];
                }
            }
        }];
    }
    
    ///insert the entity id in the list of openend chats entity ids
    //#M#[[C411ChatManager sharedInstance]chatRoomOpenedWithEntityId:self.strEntityId];
    
    ///reset the unread message counter for this chat
    [C411ChatHelper resetUnreadMsgCounterForChatRoomWithEntityId:self.strEntityId];
    
    [self registerForNotifications];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ///Unhide the navigation bar
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self unregisterFromNotifications];
    [self deattachObservers];
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

-(FIRDatabaseReference *)fireDBRef
{
    if (!_fireDBRef) {
        
        _fireDBRef = [[FIRDatabase database]referenceWithPath:CHAT_ROOT_NODE];
    }
    
    return _fireDBRef;
}

-(FIRStorageReference *)fireImgStorageRef
{
    if (!_fireImgStorageRef) {
        
        FIRStorageReference *storageRef = [[FIRStorage storage]reference];
        _fireImgStorageRef = [storageRef child:[NSString stringWithFormat:@"%@/%@",CHAT_ROOT_NODE,IMG_ROOT_NODE]];

    }
    
    return _fireImgStorageRef;
}

-(NSMutableArray *)arrMessages
{
    if (!_arrMessages) {
        
        _arrMessages = [NSMutableArray array];
    }
    
    return _arrMessages;
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    self.senderDisplayName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
    self.senderId = currentUser.objectId;
    
    ///remove avatar from message
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.inputToolbar.contentView.leftBarButtonItemWidth = 0;
    ///Set custom text box placeholder text
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"New Message", nil);
    
    ///Set custom title for send button and update it's frame
    NSString *sendTitle = NSLocalizedString(@"Send", nil);
    UIButton *sendButton = self.inputToolbar.contentView.rightBarButtonItem;
    [sendButton setTitle:sendTitle forState:UIControlStateNormal];
    CGFloat maxHeight = 32.0f;
    CGRect sendTitleRect = [sendTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:@{ NSFontAttributeName : sendButton.titleLabel.font }
                                                   context:nil];
    sendButton.frame = CGRectMake(0.0f,
                                  0.0f,
                                  CGRectGetWidth(CGRectIntegral(sendTitleRect)),
                                  maxHeight);
    
    self.inputToolbar.contentView.rightBarButtonItem = sendButton;
    
    ///Show title
    NSString *strTitle = self.strEntityName;
    if (self.entityType == ChatEntityTypeAlert) {
    NSString *strAlertName = [C411StaticHelper getLocalizedAlertTypeStringFromString:strTitle];

        strTitle = [NSString stringWithFormat:NSLocalizedString(@"%@ Alert", nil),strAlertName];
    }
    self.title = strTitle;
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    ///Add bg image to collection view
    UIImageView *imgVuBg = [[UIImageView alloc]initWithImage:[C411ColorHelper sharedInstance].imgChatBG];
    imgVuBg.contentMode = UIViewContentModeScaleAspectFill;
    imgVuBg.clipsToBounds = YES;
    self.collectionView.backgroundView = imgVuBg;
    
    ///Add sticky note to collection view
    UIView *collectionSuperView = self.collectionView.superview;
    [collectionSuperView addSubview:self.vuStickyNote];

    // Center Vertically
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.vuStickyNote
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:collectionSuperView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:-100];
    [collectionSuperView addConstraint:centerYConstraint];

    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.vuStickyNote attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:collectionSuperView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [collectionSuperView addConstraint:leadingConstraint];

    
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.vuStickyNote attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:collectionSuperView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [collectionSuperView addConstraint:trailingConstraint];
    
    [self applyColors];
}

-(void)applyColors {
    ///Set background color
    UIColor *backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    self.view.backgroundColor = backgroundColor;
    
    ///Set BG IMage
    ((UIImageView *)self.collectionView.backgroundView).image = [C411ColorHelper sharedInstance].imgChatBG;
    
    self.inputToolbar.barTintColor = backgroundColor;
    self.inputToolbar.tintColor = [C411ColorHelper sharedInstance].themeColor;
    
    ///Set disabled text color
    self.lblStickyNote.textColor = [C411ColorHelper sharedInstance].disabledTextColor;
    
    ///Set hint icon color
    self.imgVuStickyNote.tintColor = [C411ColorHelper sharedInstance].hintIconColor;
    
}

-(void)registerForNotifications
{

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didUserRemovedFromCell:) name:kRecivedAlertForUserRemovedFromCellNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];

}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

-(void)deattachObservers
{
    ///Deattach new message listener
    if (self.didObserverAttached && self.newMsgRefHandle) {
        
        NSString *strChatMsgPath = [C411ChatHelper getChatMessagePathForEntityType:self.entityType andEntityId:self.strEntityId];
        FIRDatabaseReference *chatMsgRef = [self.fireDBRef child:strChatMsgPath];
        [chatMsgRef removeObserverWithHandle:self.newMsgRefHandle];

    }
    
}

-(void)hideChatInputbox
{
    self.inputToolbar.hidden = YES;
}

-(void)shareLocation
{
    [self sendMessage:nil withType:kChatMsgTypeLoc additionalData:nil];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
}

-(void)sendMessage:(NSString *)strMsg withType:(NSString *)strMsgType additionalData:(id)additionalData
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strSenderFirstName = currentUser[kUserFirstnameKey];
    NSString *strSenderLastName = currentUser[kUserLastnameKey];
    
    ///create a message dictionary
    NSMutableDictionary *dictMessage = [NSMutableDictionary dictionary];
    [dictMessage setObject:strMsgType forKey:kChatMsgTypeKey];
    [dictMessage setObject:strSenderFirstName forKey:kChatSenderFirstNameKey];
    [dictMessage setObject:(strSenderLastName.length > 0) ? strSenderLastName : @"" forKey:kChatSenderLastNameKey];
    [dictMessage setObject:self.senderId forKey:kChatSenderIdKey];
    [dictMessage setObject:[FIRServerValue timestamp] forKey:kChatTimeKey];
    
    ///get the current location of user and pass it along with message
    CLLocation *userLocation = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES];
    [dictMessage setObject:@(userLocation.coordinate.latitude) forKey:kChatLatKey];
    [dictMessage setObject:@(userLocation.coordinate.longitude) forKey:kChatLongKey];

    ///get msg type
    ChatMsgType msgType = [C411ChatHelper getChatMsgTypeFromString:strMsgType];
    
    if (msgType == ChatMsgTypeText) {
        
        strMsg = (strMsg.length > 0) ? strMsg : @"";
        [dictMessage setObject:strMsg forKey:kChatMsgKey];

    }
    else if (msgType == ChatMsgTypeLoc) {
        
        strMsg = [NSString stringWithFormat:@"https://www.google.com/maps/place//@%lf,%lf,16z/",userLocation.coordinate.latitude,userLocation.coordinate.longitude];
        [dictMessage setObject:strMsg forKey:kChatMsgKey];
        
    }
    else if (msgType == ChatMsgTypeImg) {
        
        strMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"Image (Download the latest version via %@ to view this image)", nil),DOWNLOAD_APP_URL];
        [dictMessage setObject:strMsg forKey:kChatMsgKey];
        
        if (additionalData) {
            ///Append image download url
            NSString *downloadUrlString = [(NSURL *)additionalData absoluteString];
            if (downloadUrlString.length > 0) {
                
                [dictMessage setObject:downloadUrlString forKey:kChatImageUrlKey];
            }
            
        }
        
    }
    else{
        
        ///Unidentified msg type
        NSLog(@"Unidentified msg type");
        return;
    }
    
    
    [self sendMessage:dictMessage];
}


-(void)sendMessage:(NSDictionary *)dictMessage
{
    
    ///Create a message node
    NSString *strChatMsgPath = [C411ChatHelper getChatMessagePathForEntityType:self.entityType andEntityId:self.strEntityId];
    NSString *strNotifMsgPath = [C411ChatHelper getChatNotificationPathForEntityType:self.entityType andEntityId:self.strEntityId];
    
    NSString *strMessageKey = [[self.fireDBRef child:strChatMsgPath] childByAutoId].key;
    
    NSDictionary *dictNotifMessage = @{kChatNotificationMessageKey:dictMessage,
                                       self.senderId:[FIRServerValue timestamp]};
    
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",strChatMsgPath,strMessageKey]:dictMessage,
                                   [NSString stringWithFormat:@"/%@/%@",strNotifMsgPath,strMessageKey]:dictNotifMessage};
    
    ///Make a dictionary of Params for sendMessage cloud code
    NSMutableDictionary *dictParams = [dictMessage mutableCopy];
    double msgTimeInMillis = [[NSDate date] timeIntervalSince1970] * 1000;
    dictParams[kPayloadChatTimeKey] = @(msgTimeInMillis);
    dictParams[kPayloadChatEntityObjectIdKey] = self.strEntityId;
    dictParams[kPayloadChatEntityNameKey] = self.strEntityName;
    dictParams[kPayloadChatEntityTypeKey] = [C411ChatHelper getChatEntityTypeStringFromType:self.entityType];
    __weak typeof(self) weakSelf = self;
    
    [self.fireDBRef updateChildValues:childUpdates withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if (error) {
            
            NSLog(@"error: %@",error.localizedDescription);
        }
        else{
            
            NSLog(@"Success: Path: %@",ref);
            
            ///Call the cloud code for sending notification
            [C411StaticHelper sendChatMessage:dictParams andCompletion:^(id  _Nullable object, NSError * _Nullable error) {
                
                if (error) {
                    
                    NSLog(@"error sending msg notification: %@",error.localizedDescription);
                }
                else{
                    
                    NSLog(@"Message notification sent successfully");
                }
                
            }];
            
            ///append entity created at time as well as it's not required to send on cloud message
            dictParams[kPayloadChatEntityCreatedAtKey] = @(weakSelf.entityCreatedAtInMillis);

            ///Update the Chat Room data in recent chats
            [C411ChatHelper updateChatRoomWithEntityObjectId:weakSelf.strEntityId withMessageData:dictParams isIncoming:NO];
        }
    }];
    
}

-(void)addMessageWithDetails:(NSDictionary *)dictMsgDetails
{
    NSString *strMsg = dictMsgDetails[kChatMsgKey];
    NSString *senderName = [NSString stringWithFormat:@"%@ %@",dictMsgDetails[kChatSenderFirstNameKey],dictMsgDetails[kChatSenderLastNameKey]];
    NSString *strSenderId = dictMsgDetails[kChatSenderIdKey];
    NSTimeInterval msgTime = [dictMsgDetails[kChatTimeKey]doubleValue]/1000;
    //NSTimeInterval msgTime = [[NSDate date]timeIntervalSince1970];
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:msgTime];
    NSString *strMsgType = dictMsgDetails[kChatMsgTypeKey];
    ChatMsgType msgType = [C411ChatHelper getChatMsgTypeFromString:strMsgType];
    
    JSQMessage *message = nil;
    if (msgType == ChatMsgTypeLoc) {
        
        ///Get lat, long from message
        CLLocationDegrees latitude = [dictMsgDetails[kChatLatKey]doubleValue];
        CLLocationDegrees longitude = [dictMsgDetails[kChatLongKey]doubleValue];
        CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
       
        ///Make a location media object
        JSQLocationMediaItem *locMediaItem = [[JSQLocationMediaItem alloc]init];
        
        ///Set mask
        if ([strSenderId isEqualToString:self.senderId]) {
            
            ///Message is outgoing
            locMediaItem.appliesMediaViewMaskAsOutgoing = YES;
            
        }
        else{
           
            ///Message is incoming
            locMediaItem.appliesMediaViewMaskAsOutgoing = NO;
            
        }
        __weak typeof(self) weakSelf = self;
        [locMediaItem setLocation:location withCompletionHandler:^{
            
            weakSelf.automaticallyScrollsToMostRecentMessage = NO;
            [weakSelf finishReceivingMessage];
            weakSelf.automaticallyScrollsToMostRecentMessage = YES;
            
            
        }];
        
        
        ///Make a message object with location media
        message = [[JSQMessage alloc]initWithSenderId:strSenderId senderDisplayName:senderName date:msgDate media:locMediaItem];
        
    }
    else if (msgType == ChatMsgTypeImg) {
        
        ///Get lat, long from message
        NSString *strImageUrl = dictMsgDetails[kChatImageUrlKey];
        NSURL *imageUrl = [NSURL URLWithString:strImageUrl];
        
        ///Make a photo media object
        MAJSQAsyncPhotoMediaItem *photoMediaItem = [[MAJSQAsyncPhotoMediaItem alloc]initWithUrl:imageUrl];
        
        ///Set mask
        if ([strSenderId isEqualToString:self.senderId]) {
            
            ///Message is outgoing
            photoMediaItem.appliesMediaViewMaskAsOutgoing = YES;
            
        }
        else{
            
            ///Message is incoming
            photoMediaItem.appliesMediaViewMaskAsOutgoing = NO;
            
        }

        ///Make a message object with photo media
        message = [[JSQMessage alloc]initWithSenderId:strSenderId senderDisplayName:senderName date:msgDate media:photoMediaItem];
        
    }
    else{
        
        message = [[JSQMessage alloc]initWithSenderId:strSenderId senderDisplayName:senderName date:msgDate text:strMsg];
    }
    
    [self.arrMessages addObject:message];
}

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [self sendMessage:text withType:kChatMsgTypeText additionalData:nil];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
    
}

-(void)observeEntityMessages
{
    NSString *strChatMsgPath = [C411ChatHelper getChatMessagePathForEntityType:self.entityType andEntityId:self.strEntityId];
    FIRDatabaseReference *chatMsgRef = [self.fireDBRef child:strChatMsgPath];
    self.strRecentMsgKey = self.strRecentMsgKey ? self.strRecentMsgKey : @"";
    FIRDatabaseQuery *msgQuery = [[chatMsgRef queryOrderedByKey]queryStartingAtValue:self.strRecentMsgKey];
    __weak typeof(self) weakSelf = self;
    self.newMsgRefHandle = [msgQuery observeEventType:FIRDataEventTypeChildAdded andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot * _Nonnull snapshot, NSString * _Nullable prevKey) {
        
        if (!weakSelf.didObserverAttached) {
            
            weakSelf.observerAttached = YES;
            if ([snapshot.key isEqualToString:weakSelf.strRecentMsgKey]) {
                return ;
            }
        }
        
        if(weakSelf.vuStickyNote.hidden == NO){
            ///Hide the sticky note
            weakSelf.vuStickyNote.hidden = YES;
        }
        
        NSDictionary *dictMsgData = snapshot.value;
        [weakSelf addMessageWithDetails:dictMsgData];
        [weakSelf finishReceivingMessage];
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        
        if (error) {
            
            NSLog(@"error: %@",error.localizedDescription);
        }
        else{
            
            NSLog(@"Success");
        }
        
    }];
}

-(JSQMessage *)getMessageWithDetails:(NSDictionary *)dictMsgDetails
{
    NSString *strMsg = dictMsgDetails[kChatMsgKey];
    NSString *senderName = [C411StaticHelper getFullNameUsingFirstName:dictMsgDetails[kChatSenderFirstNameKey] andLastName:dictMsgDetails[kChatSenderLastNameKey]];
    NSString *strSenderId = dictMsgDetails[kChatSenderIdKey];
    NSTimeInterval msgTime = [dictMsgDetails[kChatTimeKey]doubleValue]/1000;
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:msgTime];
    
    NSString *strMsgType = dictMsgDetails[kChatMsgTypeKey];
    ChatMsgType msgType = [C411ChatHelper getChatMsgTypeFromString:strMsgType];
    
    JSQMessage *message = nil;
    if (msgType == ChatMsgTypeLoc) {
        
        ///Get lat, long from message
        CLLocationDegrees latitude = [dictMsgDetails[kChatLatKey]doubleValue];
        CLLocationDegrees longitude = [dictMsgDetails[kChatLongKey]doubleValue];
        CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        
        ///Make a location media object
        JSQLocationMediaItem *locMediaItem = [[JSQLocationMediaItem alloc]init];
        
        ///Set mask
        if ([strSenderId isEqualToString:self.senderId]) {
            
            ///Message is outgoing
            locMediaItem.appliesMediaViewMaskAsOutgoing = YES;
            
        }
        else{
            
            ///Message is incoming
            locMediaItem.appliesMediaViewMaskAsOutgoing = NO;
            
        }

        __weak typeof(self) weakSelf = self;
        [locMediaItem setLocation:location withCompletionHandler:^{
            
            weakSelf.automaticallyScrollsToMostRecentMessage = NO;
            [weakSelf finishReceivingMessage];
            weakSelf.automaticallyScrollsToMostRecentMessage = YES;
            
            
        }];
        
        ///Make a message object with location media
        message = [[JSQMessage alloc]initWithSenderId:strSenderId senderDisplayName:senderName date:msgDate media:locMediaItem];
        
    }
    else if (msgType == ChatMsgTypeImg) {
        
        ///Get lat, long from message
        NSString *strImageUrl = dictMsgDetails[kChatImageUrlKey];
        NSURL *imageUrl = [NSURL URLWithString:strImageUrl];
        
        ///Make a photo media object
        MAJSQAsyncPhotoMediaItem *photoMediaItem = [[MAJSQAsyncPhotoMediaItem alloc]initWithUrl:imageUrl];
        
        ///Set mask
        if ([strSenderId isEqualToString:self.senderId]) {
            
            ///Message is outgoing
            photoMediaItem.appliesMediaViewMaskAsOutgoing = YES;
            
        }
        else{
            
            ///Message is incoming
            photoMediaItem.appliesMediaViewMaskAsOutgoing = NO;
            
        }

        ///Make a message object with photo media
        message = [[JSQMessage alloc]initWithSenderId:strSenderId senderDisplayName:senderName date:msgDate media:photoMediaItem];
        
    }
    else{
        
        message = [[JSQMessage alloc]initWithSenderId:strSenderId senderDisplayName:senderName date:msgDate text:strMsg];
    }

    return message;
}

-(void)loadEarlierMessages
{
    ///show the progress hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ///hide the load earlier message button
    self.showLoadEarlierMessagesHeader = NO;
    
    NSString *strChatMsgPath = [C411ChatHelper getChatMessagePathForEntityType:self.entityType andEntityId:self.strEntityId];
    FIRDatabaseReference *chatMsgRef = [self.fireDBRef child:strChatMsgPath];
    __weak typeof(self) weakSelf = self;
    
    if (!self.strLastMsgKey){
        // Loading messages first time
        [[[chatMsgRef queryOrderedByKey] queryLimitedToLast:K_MESSAGES_PER_PAGE] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.exists) {
                
                for (FIRDataSnapshot *child in snapshot.children) {
                    
                    NSMutableDictionary *dictMsgData = [child.value mutableCopy];
                    [weakSelf.arrMessages addObject:[weakSelf getMessageWithDetails:dictMsgData]];
                    
                }
                
                weakSelf.strLastMsgKey = [[snapshot.children.allObjects firstObject] key];
                weakSelf.strRecentMsgKey = [[snapshot.children.allObjects lastObject] key];
                // NSLog(@"%@", messages);
                //[weakSelf finishReceivingMessage];
                
                ///Listen for child added event
                //[weakSelf observeEntityMessages];

                if (snapshot.childrenCount == K_MESSAGES_PER_PAGE) {
                    
                    ///show the load earlier message header as there could be more earlier messages
                    weakSelf.showLoadEarlierMessagesHeader = YES;
                }
                
            }
            
            if ([C411ChatHelper isUserRemovedFromEntityWithId:weakSelf.strEntityId]) {
                
                ///reload the chat table view
                [weakSelf finishReceivingMessage];

                ///Listen for child added event
                [weakSelf observeEntityMessages];

                ///stop the porgress hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }
            else{
                
                ///Check from server to make sure whether user is removed or cell is deleted or not
                [weakSelf handleCanUserSendMessageWithCompletion:^(BOOL canSend, NSError * _Nullable error) {
                    
                    if (canSend) {
                        
                        if (weakSelf.arrMessages.count == 0) {
                            
                            ///show sticky note if there is no message yet
                            if (self.entityType == ChatEntityTypeAlert) {
                                
                                weakSelf.lblStickyNote.text = NSLocalizedString(@"There are currently no messages related to this alert", nil);
                                weakSelf.vuStickyNote.hidden = NO;
                                
                            }
                            else if (self.entityType == ChatEntityTypePublicCell) {
                                
                                weakSelf.lblStickyNote.text = NSLocalizedString(@"No messages appear in this Cell", nil);
                                weakSelf.vuStickyNote.hidden = NO;
                                
                            }
                            NSLog(@"SHOW STICKY NOTE");
                            
                        }
                        
                    }
                    else{
                        
                        ///User cannot send message
                        [weakSelf hideChatInputbox];
                        

                    }
                    
                    ///reload the chat table view
                    [weakSelf finishReceivingMessage];

                    ///Listen for child added event
                    [weakSelf observeEntityMessages];

                    ///stop the porgress hud
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

                    
                }];
            }

            
        }];
    }
    else {
        // Paging started
        [[[[chatMsgRef queryOrderedByKey] queryLimitedToLast:K_MESSAGES_PER_PAGE + 1] queryEndingAtValue:self.strLastMsgKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            if (snapshot.exists) {
                
                NSInteger count = 0;
                NSMutableArray *arrNewPage = [NSMutableArray array];
                for (FIRDataSnapshot *child in snapshot.children) {
                    
                    // Ignore last object because this is duplicate of last page
                    if (count == snapshot.childrenCount - 1) {
                        break;
                    }
                    
                    count += 1;
                    NSMutableDictionary *dictMsgData = [child.value mutableCopy];
                    [arrNewPage addObject:[self getMessageWithDetails:dictMsgData]];
                }
                
                self.strLastMsgKey = [[snapshot.children.allObjects firstObject] key];
                
                // Insert new messages at top of old array
                NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, [arrNewPage count])];
                [self.arrMessages insertObjects:arrNewPage atIndexes:indexes];
                //NSLog(@"%@", messages);
                self.automaticallyScrollsToMostRecentMessage = NO;
                [self finishReceivingMessage];
                
                self.automaticallyScrollsToMostRecentMessage = YES;
                
                if (snapshot.childrenCount == (K_MESSAGES_PER_PAGE + 1)) {
                    
                    ///show the load earlier message header as there could be more earlier messages
                    weakSelf.showLoadEarlierMessagesHeader = YES;
                }

            }
            
            ///stop the porgress hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

            
        }];
    }
}


-(void)handleCanUserSendMessageWithCompletion:(PFBooleanResultBlock)completion
{
    
    if (self.entityType == ChatEntityTypePublicCell) {
        
        ///Validate whether a public cell exist or not and he is the member of it, if not user cannot send message
        PFQuery *getPublicCellQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
        [getPublicCellQuery whereKey:@"objectId" equalTo:self.strEntityId];
        [getPublicCellQuery whereKey:kPublicCellMembersKey equalTo:[AppDelegate getLoggedInUser]];
        
        ///fetch only one key to optimise it
        [getPublicCellQuery selectKeys:@[kPublicCellNameKey]];
        
        __weak typeof(self) weakSelf = self;
        [getPublicCellQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            if (!error && object) {
                
                ///public cell exist and user is the member of that cell
                if (completion != NULL) {
                    completion(YES,error);
                }
                

            }
            else if(error.code == kPFErrorObjectNotFound){
                
                ///Either public cell no longer exist or user is not member of this cell
                ///set isRemoved for the particular cell id to disable chat for this user
                [C411ChatHelper handleUserRemovedFromEntityWithId:weakSelf.strEntityId];

                if (completion != NULL) {
                    completion(NO,error);
                }
            }
            else{
            
                ///Some other error occured while retrieving so ignore it for now
                NSLog(@"Error validating member->%@",error);
                if (completion != NULL) {
                    completion(YES,error);
                }
            }
            
        }];
        
    }
    else if(self.entityType == ChatEntityTypeAlert){
    
        if (completion != NULL) {

            ///Check whether it is expired or not
            BOOL isChatExpired = ![C411ChatHelper canChatOnAlertIssuedAt:self.entityCreatedAtInMillis];

            if (isChatExpired) {
                ///user cannot send message if chat is expired
                 completion(NO,nil);
            }
            else{
                 ///user can send message
                 completion(YES,nil);
            }
            
        }
        
        
    }
    else{
        
        ///Any other entity
        if (completion != NULL) {
            completion(NO,nil);
        }

    
    }
    
    
    
}

-(void)showShareLocationPrompt
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Share Location", nil) message:NSLocalizedString(@"Are you sure you want to share your current location?", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        ///Do anything required on NO action
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

    }];
    
    [alertController addAction:noAction];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ///Do anything required on Yes action
        if([[C411LocationManager sharedInstance]isLocationAccessAllowed]){
            
            ///Check if current location is updated or not, if not then wait for location update before sharing the location
            if([[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:NO]){
                ///Current location is available, share location
                [weakSelf shareLocation];
            }
            else{
                ///Current location is not available, so wait for location update to share location
                [weakSelf shareLocationOnUpdate];
            }
        }
        else{
            ///Location access is denied, show enable location popup
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [[C411LocationManager sharedInstance]showEnableLocationPopupWithCustomMessagePrefix:nil cancelActionHandler:^(id action, NSInteger actionIndex, id customObject) {
                    ///Show cannot send alert toast
                    [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Cannot share current location.", nil)];
                } andSettingsActionHandler:^(id action, NSInteger actionIndex, id customObject) {
                    
                    [weakSelf shareLocationOnUpdate];
                }];
            }];
        }
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];

    [alertController addAction:yesAction];

    //[self presentViewController:alertController animated:YES completion:NULL];
    
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

}

-(void)showShareImagePrompt
{
    ///Show photo picker selection action sheet
    UIAlertController *photoPickerType = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    ///Add Camera action
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [weakSelf showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera animated:YES];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [photoPickerType addAction:cameraAction];
    
    ///Add Gallery action
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Gallery", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [weakSelf showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary animated:YES];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [photoPickerType addAction:galleryAction];
    
    ///Add cancel button action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        ///Do anything to be done on cancel
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [photoPickerType addAction:cancelAction];
    
    ///Present action sheet
    //[self presentViewController:photoPickerType animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:photoPickerType];

}

-(void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType animated:(BOOL)animated
{
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc] init];
    
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    __weak typeof(self) weakSelf = self;
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        
        [weakSelf presentViewController:imagePickerController animated:animated completion:nil];
    }];
    
}

-(void)uploadPhotoWithData:(NSData *)photoData
{
 
    ///Generate a random Image name by creating a temporary child
    NSString *strChatMsgPath = [C411ChatHelper getChatMessagePathForEntityType:self.entityType andEntityId:self.strEntityId];
    NSString *strRandomKey = [[self.fireDBRef child:strChatMsgPath] childByAutoId].key;
    NSString *strImgName = [NSString stringWithFormat:@"%@.png",strRandomKey];
    
    // Create a reference to the file you want to upload
    FIRStorageReference *imageRef = [self.fireImgStorageRef child:strImgName];
    
    
    ///Create the metadata for the file
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/jpeg";
    
    ///Create custom metadata
    NSMutableDictionary *dictCustomMetadata = [NSMutableDictionary dictionary];
    ///get the current location of user
    CLLocation *userLocation = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES];
    [dictCustomMetadata setObject:@(userLocation.coordinate.latitude) forKey:kChatLatKey];
    [dictCustomMetadata setObject:@(userLocation.coordinate.longitude) forKey:kChatLongKey];
    [dictCustomMetadata setObject:self.senderId forKey:kPayloadUserIdKey];
    dictCustomMetadata[@"entityId"] = self.strEntityId;
    dictCustomMetadata[kPayloadChatEntityNameKey] = self.strEntityName;
    dictCustomMetadata[kPayloadChatEntityTypeKey] = [C411ChatHelper getChatEntityTypeStringFromType:self.entityType];
    
    ///Put custom metadata
    metadata.customMetadata = dictCustomMetadata;
    
    
    ///Show Progress hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self) weakSelf = self;
    

    FIRStorageUploadTask *uploadTask = [imageRef putData:photoData
                                                 metadata:metadata
                                               completion:^(FIRStorageMetadata *metadata, NSError *error) {
                                                   
                                                   if (error != nil) {
                                                       // Uh-oh, an error occurred!
                                                       ///Hide Progress hud
                                                       [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                                                       
                                                       [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"An error occurred, please try again.", nil)];

                                                   } else {
//                                                       // Metadata contains file metadata such as size, content-type, and download URL.
//                                                       NSURL *downloadURL = metadata.downloadURL;
                                                       
                                                       ///Fetch the download url
                                                       [imageRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                                                           ///Hide Progress hud
                                                           [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                                                           
                                                           if(error) {
                                                               [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"An error occurred, please try again.", nil)];
                                                               return;
                                                           }
                                                           
                                                           ///Send the message
                                                           [weakSelf sendMessage:nil withType:kChatMsgTypeImg additionalData:URL];
                                                           
                                                       }];
                                                      
                                                       
                                                    
                                                   }
                                               }];

    
}

-(void)shareLocationOnUpdate
{
    ///Show progress hud to let user wait until his/her location is retrieved
    self.locationRetrievalProgressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.locationRetrievalProgressHud.labelText = NSLocalizedString(@"Retrieving Location", nil);
    self.locationRetrievalProgressHud.removeFromSuperViewOnHide = YES;
    
    ///Set ivar to send alert on location update
    self.shareLocationOnUpdate = YES;
    
    ///Add location updated observer to send out the alert
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(locationManagerDidUpdateLocation:) name:kLocationUpdatedNotification object:nil];
    
    ///Add observer for app coming to foreground
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cell411AppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

//****************************************************
#pragma mark - UIImagePickerControllerDelegate
//****************************************************

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    ///Get selected image if image is picked or clicked
    UIImage *selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizedImage = [selectedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(self.view.bounds.size.width * 2, self.view.bounds.size.height * 2) interpolationQuality:kCGInterpolationHigh];
    
    ///Compress the image
    float compressionQuality = 0.7;
    NSData *photoData = UIImageJPEGRepresentation(resizedImage, compressionQuality);
    resizedImage = [UIImage imageWithData:photoData];
    
    //self.photoImage = resizedImage;
    //    self.photoData = UIImagePNGRepresentation(resizedImage);
    BOOL showError = NO;
    
    if (photoData) {
        
        [self uploadPhotoWithData:photoData];
    }
    else{
        ///Unable to make PNG data from captured pic
        showError = YES;
    }
    
    
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (showError) {
            ///Show uploading error
            [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Uploading failed, please try again.", nil)];
        }
        
    }];
}

//****************************************************
#pragma mark - JSQMessagesCollectionViewDataSource Methods
//****************************************************

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.arrMessages[indexPath.item];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrMessages.count;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.arrMessages[indexPath.item];
    JSQMessagesBubbleImageFactory *msgBubbleImgFactory = [[JSQMessagesBubbleImageFactory alloc]init];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        
        ///Return outgoing bubble image
        //static JSQMessagesBubbleImage *outgoingBubbleImg = nil;
        if (!self.outgoingBubbleImg) {
            
            //outgoingBubbleImg = [msgBubbleImgFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
           self.outgoingBubbleImg = [msgBubbleImgFactory outgoingMessagesBubbleImageWithColor:[C411ColorHelper sharedInstance].themeColor];
        }
        
        return self.outgoingBubbleImg;
    }
    else{
        
        ///Return incoming bubble image
        //static JSQMessagesBubbleImage *incomingBubbleImg = nil;
        if (!self.incomingBubbleImg) {
            
            self.incomingBubbleImg = [msgBubbleImgFactory incomingMessagesBubbleImageWithColor:[C411ColorHelper sharedInstance].cardColor];
            
        }
        
        return self.incomingBubbleImg;
        
    }
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return nil;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = self.arrMessages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        
        
        cell.textView.textColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
        
    }
    else{
        
        cell.textView.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
        
    }
    
    return cell;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath{
    
    JSQMessage *message = self.arrMessages[indexPath.item];
    
    if (indexPath.item > 0) {
        
        ///get previous message
        JSQMessage *prevMsg = self.arrMessages[indexPath.item - 1];
        if ([DateHelper daysBetweenDate:prevMsg.date andDate:message.date] == 0) {
            
            return nil;
        }
        
        
    }
    NSDictionary *dictAttr = @{NSForegroundColorAttributeName : [C411ColorHelper sharedInstance].primaryTextColor};
//    return [[NSAttributedString alloc]initWithString:[[JSQMessagesTimestampFormatter sharedFormatter]relativeDateForDate:message.date] attributes:dictAttr];
    NSLocale *locale = nil;
#if APP_RO112
    
    locale = [NSLocale localeWithLocaleIdentifier:@"ro_RO"];
    
#endif
    return [[NSAttributedString alloc]initWithString:[[MATimestampFormatter sharedFormatterWithLocale:locale]relativeDateForDate:message.date] attributes:dictAttr];

    
}
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.arrMessages[indexPath.item];
    NSDictionary *dictAttr = @{NSForegroundColorAttributeName : [C411ColorHelper sharedInstance].secondaryTextColor};

    if ([message.senderId isEqualToString:self.senderId]) {
        
        
        return nil;
        
    }
    else if (message.isMediaMessage
                 && [message.media isKindOfClass:[JSQLocationMediaItem class]]) {
        
        NSAttributedString *strNameWithLoc = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:NSLocalizedString(@"%@ is at this location", nil),message.senderDisplayName] attributes:dictAttr];

        return strNameWithLoc;
    }
    else{
        /*
         uncomment it to show sender name only at the first message if there are consequent multiple message from the same sender
        NSAttributedString *senderName = nil;
        if (indexPath.item > 0) {
            
            ///get previous message sender id
            JSQMessage *prevMsg = self.arrMessages[indexPath.item - 1];
            NSString *strPreviousMsgSenderId = prevMsg.senderId;
            
            if (![message.senderId isEqualToString:strPreviousMsgSenderId]) {
                senderName = [[NSAttributedString alloc]initWithString:message.senderDisplayName];
            }
            
            
        }
        else{
            
            senderName = [[NSAttributedString alloc]initWithString:message.senderDisplayName];
        }
        */
        
        NSAttributedString *senderName = [[NSAttributedString alloc]initWithString:message.senderDisplayName attributes:dictAttr];
        return senderName;
        
    }
    
    
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.arrMessages[indexPath.item];
    NSDictionary *dictAttr = @{NSForegroundColorAttributeName : [C411ColorHelper sharedInstance].secondaryTextColor};

//    NSString *strMsgTime = [[JSQMessagesTimestampFormatter sharedFormatter]timeForDate:message.date];
    NSLocale *locale = nil;
#if APP_RO112
    
    locale = [NSLocale localeWithLocaleIdentifier:@"ro_RO"];
    
#endif
    NSString *strMsgTime = [[MATimestampFormatter sharedFormatterWithLocale:locale]timeForDate:message.date];
    return [[NSAttributedString alloc]initWithString:strMsgTime attributes:dictAttr];
    
}


-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message = self.arrMessages[indexPath.item];
    if (message.isMediaMessage){
        
        if ([message.media isKindOfClass:[JSQLocationMediaItem class]]) {
            
            JSQLocationMediaItem *locationMedia = (JSQLocationMediaItem *)message.media;
            
            GoogleMapDefinition *mapDefinition = [[GoogleMapDefinition alloc]init];
            NSString *strQueryString = [NSString stringWithFormat:@"%lf,%lf",locationMedia.coordinate.latitude,locationMedia.coordinate.longitude];
            mapDefinition.queryString = strQueryString;
            mapDefinition.zoomLevel = 16.0f;
            BOOL isOpened = [[OpenInGoogleMapsController sharedInstance] openMap:mapDefinition];
            
            if(!isOpened){
                
                ///Get the cross-platform maps url to open
                NSDictionary *dictParams = @{kGoogleMapsQueryKey : strQueryString};
                NSURL *searchUrl = [C411StaticHelper getGoogleMapsSearchUrlForAllPlatforms:dictParams];
                
                if([[UIApplication sharedApplication]canOpenURL:searchUrl]){
                    
                    [[UIApplication sharedApplication]openURL:searchUrl];
                    
                }
                
            }
            
        }
        else if ([message.media isKindOfClass:[MAJSQAsyncPhotoMediaItem class]]){
            MAJSQAsyncPhotoMediaItem *asyncPhotoMedia = (MAJSQAsyncPhotoMediaItem *)message.media;
            C411ViewPhotoVC *viewPhotoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
            viewPhotoVC.imgPhoto = [(UIImageView *)[asyncPhotoMedia mediaView] image];
            [self.navigationController pushViewController:viewPhotoVC animated:YES];
            
        }
    }
    
    
}

//****************************************************
#pragma mark - JSQMessagesCollectionViewDelegateFlowLayout Methods
//****************************************************


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
    
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath{
    
    JSQMessage *message = self.arrMessages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        
        
        return 0.0f;
        
    }
    else if (message.isMediaMessage
             && [message.media isKindOfClass:[JSQLocationMediaItem class]]) {
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else{
        /*
        uncomment it to show sender name only at the first message if there are consequent multiple message from the same sender

        if (indexPath.item > 0) {
            
            ///get previous message sender name
            JSQMessage *prevMsg = self.arrMessages[indexPath.item - 1];
            NSString *strPreviousMsgSenderId = prevMsg.senderId;
            
            if ([message.senderId isEqualToString:strPreviousMsgSenderId]) {
                return 0.0f;
                
            }
            
            
        }
        */
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;

    }
    
    
}
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath{
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
    
}

-(void)collectionView:(JSQMessagesCollectionView *)collectionView header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    [self loadEarlierMessages];
    
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender {

    ///remove the entity id from the list of openend chats entity ids
    //#M#[[C411ChatManager sharedInstance]chatRoomClosedWithEntityId:self.strEntityId];
    
    ///reset the unread message counter for this chat
    [C411ChatHelper resetUnreadMsgCounterForChatRoomWithEntityId:self.strEntityId];

    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kDidClosedChatVCNotification object:nil];

}

- (IBAction)barBtnShowMoreOptionsTapped:(UIBarButtonItem *)sender {
    
    UIAlertController *moreOptionPicker = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    ///1.Add mute/unmute action
    BOOL isChatRoomMuted = [C411ChatHelper isChatRoomWithEntityIdMuted:self.strEntityId];
    NSString *strMuteUnmuteActionName = isChatRoomMuted ? NSLocalizedString(@"Unmute", nil) : NSLocalizedString(@"Mute", nil);
    UIAlertAction *muteAction = [UIAlertAction actionWithTitle:strMuteUnmuteActionName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (isChatRoomMuted) {
            
            ///Unmute it
            [C411ChatHelper unmuteChatRoomWithEntityId:weakSelf.strEntityId];
        }
        else{
            
            ///Remove the keyboard if there
            [weakSelf.view endEditing:YES];
            
            ///Create and save chat room settings if it doesn't exist
            C411ChatRoomSettings *chatRoomSettings = [C411ChatHelper getChatRoomSettingsWithId:self.strEntityId];
            if(!chatRoomSettings){
                ///Create chat room settings with default settings
                chatRoomSettings = [[C411ChatRoomSettings alloc]initWithEntityId:self.strEntityId entityName:self.strEntityName andEntityType:self.entityType];
                [C411ChatHelper insertChatRoomSetting:chatRoomSettings];
            }

            ///Show mute setting popup
            C411MuteChatRoomPopup *vuMuteChatRoomPopup = [[[NSBundle mainBundle] loadNibNamed:@"C411MuteChatRoomPopup" owner:weakSelf options:nil] lastObject];
            vuMuteChatRoomPopup.strEntityId = weakSelf.strEntityId;
            UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
            ///Set view frame
            vuMuteChatRoomPopup.frame = rootVC.view.bounds;
            ///add view
            [rootVC.view addSubview:vuMuteChatRoomPopup];
            [rootVC.view bringSubviewToFront:vuMuteChatRoomPopup];

        }
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [moreOptionPicker addAction:muteAction];
    
    ///Add share location action
    UIAlertAction *shareLocationAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share Location", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (weakSelf.inputToolbar.hidden
            || [C411ChatHelper isUserRemovedFromEntityWithId:weakSelf.strEntityId]){
            
            ///this chat is expired, location cannot be shared
            
            [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Chat expired, can't share location", nil)];
            
        }
        else{
            
            ///Chat is not yet expired show share location confirmation dialog
            [weakSelf showShareLocationPrompt];

        }

        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    [moreOptionPicker addAction:shareLocationAction];

    
    ///Add share Image action
    UIAlertAction *shareImageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share Image", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (weakSelf.inputToolbar.hidden
            || [C411ChatHelper isUserRemovedFromEntityWithId:weakSelf.strEntityId]){
            
            ///this chat is expired, image cannot be shared
            
            [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Chat expired, can't share image", nil)];
            
        }
        else{
            
            ///Chat is not yet expired show share Image popup
            [weakSelf showShareImagePrompt];
            
        }
        
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    [moreOptionPicker addAction:shareImageAction];

    
    
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



//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)didUserRemovedFromCell:(NSNotification *)notif
{
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload && [alertPayload.strCellId isEqualToString:self.strEntityId]) {
        
        ///Hide input toolbar so that user cannot send any message to this Room
        [self hideChatInputbox];
        
        
    }
}

-(void)locationManagerDidUpdateLocation:(NSNotification *)notif
{
    if(self.shouldShareLocationOnUpdate){
        ///Set this flag to no to avoid sending multile alerts
        self.shareLocationOnUpdate = NO;
        
        ///remove the notification observer
        [[NSNotificationCenter defaultCenter]removeObserver:self name:kLocationUpdatedNotification object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        
        ///Remove the progress hud
        [self.locationRetrievalProgressHud hide:YES];
        self.locationRetrievalProgressHud = nil;
        
        ///send the alert now
        [self shareLocation];
        
    }
}

-(void)cell411AppWillEnterForeground:(NSNotification *)notif
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.shouldShareLocationOnUpdate
            && (![[C411LocationManager sharedInstance] isLocationAccessAllowed])) {
            ///Reset the alert sending flag
            weakSelf.shareLocationOnUpdate = NO;
            
            ///remove the notification observer
            [[NSNotificationCenter defaultCenter]removeObserver:weakSelf name:kLocationUpdatedNotification object:nil];
            [[NSNotificationCenter defaultCenter]removeObserver:weakSelf name:UIApplicationWillEnterForegroundNotification object:nil];
            
            ///Remove the progress hud
            [weakSelf.locationRetrievalProgressHud hide:YES];
            weakSelf.locationRetrievalProgressHud = nil;
            
            ///Show cannot send alert toast
            [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Cannot share location.", nil)];
        }
        
    });
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
    self.automaticallyScrollsToMostRecentMessage = NO;
    [self finishReceivingMessage];
    self.automaticallyScrollsToMostRecentMessage = YES;
    
    self.outgoingBubbleImg = nil;
    self.incomingBubbleImg = nil;
}

#endif

@end
