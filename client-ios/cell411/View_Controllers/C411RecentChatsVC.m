//
//  C411RecentChatsVC.m
//  cell411
//
//  Created by Milan Agarwal on 09/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411RecentChatsVC.h"
#import "C411ChatManager.h"
#import "C411RecentChatCell.h"
#import "C411ChatRoom.h"
#import "C411ChatVC.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "C411ChatHelper.h"
#import "C411StaticHelper.h"
#import "UIButton+FAB.h"
#import "C411ChatEntitiesListVC.h"
#import "MAAlertPresenter.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411RecentChatsVC ()<UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblVuRecentChats;
@property (weak, nonatomic) IBOutlet UIButton *btnShowChatVCFAB;
@property (weak, nonatomic) IBOutlet UIView *vuStickyNote;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuStickyNote;
@property (weak, nonatomic) IBOutlet UILabel *lblStickyNote;
@property (nonatomic, strong) NSArray *arrRecentChats;

@end

@implementation C411RecentChatsVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///Remove top padding of 15 pixel
    //self.tblVuRecentChats.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    [self addGestures];
    [self registerForNotifications];
    [self configureViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshChatList];
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
#pragma mark - Property Initializer
//****************************************************

-(NSArray *)arrRecentChats
{
    if (!_arrRecentChats) {
        
        NSArray *arrUnSortedRecentChats = [C411ChatHelper getRecentChats];
        
        if (arrUnSortedRecentChats.count > 0) {
           
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastMsgTimestamp" ascending:NO];
            _arrRecentChats = [arrUnSortedRecentChats sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        }
       
        
    }
    
    return _arrRecentChats;
    
}


//****************************************************
#pragma mark - Private Methods
//****************************************************
-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newChatMsgArrived:) name:kNewChatMessageArrivedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(unreadMsgCountUpdated:) name:kUnreadMsgCountUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];

}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

-(void)configureViews
{
    self.title = NSLocalizedString(@"Chats", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self.btnShowChatVCFAB makeFloatingActionButton];
    self.btnShowChatVCFAB.hidden = NO;
    [self applyColors];
}

-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    self.btnShowChatVCFAB.backgroundColor = [C411ColorHelper sharedInstance].fabSelectedColor;;
    self.btnShowChatVCFAB.layer.shadowColor = [C411ColorHelper sharedInstance].fabShadowColor.CGColor;
    self.btnShowChatVCFAB.tintColor = [C411ColorHelper sharedInstance].fabSelectedTintColor;
    self.lblStickyNote.textColor = [C411ColorHelper sharedInstance].disabledTextColor;
    self.imgVuStickyNote.tintColor = [C411ColorHelper sharedInstance].hintIconColor;
}


-(void)addGestures
{
    UILongPressGestureRecognizer *deleteGesture = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(handleChatDeletionFromRecentList:)];
    deleteGesture.delegate = self;
    [self.tblVuRecentChats addGestureRecognizer:deleteGesture];
}


-(void)refreshChatList
{
    _arrRecentChats = nil;
    [self.tblVuRecentChats reloadData];

}

//****************************************************
#pragma mark - Gesture Methods
//****************************************************

-(void)handleChatDeletionFromRecentList:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        ///Show delete Cell popup
        CGPoint touchPoint = [gestureRecognizer locationInView:self.tblVuRecentChats];
        
        NSIndexPath *indexPath = [self.tblVuRecentChats indexPathForRowAtPoint:touchPoint];
        if (indexPath != nil &&indexPath.row < self.arrRecentChats.count) {
            NSInteger rowIndex = indexPath.row;
            C411ChatRoom *chatRoom = [self.arrRecentChats objectAtIndex:rowIndex];
            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Are you sure you want to remove %@ from list?",nil),chatRoom.strEntityName];
            UIAlertController *confirmDeletionAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                ///user said No, do nothing
                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];
                
            }];
            
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                ///User opted to remove the chat from list
                ///1.Remove this chat entity
                [C411ChatHelper deleteChatRoomWithEntityObjectId:chatRoom.strEntityId];
                
                ///2.refresh chat list
                [self refreshChatList];
                
                
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

- (IBAction)btnShowChatEntitiesListVCFABTapped:(UIButton *)sender {
    
    C411ChatEntitiesListVC *chatEntitiesListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ChatEntitiesListVC"];
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:chatEntitiesListVC animated:YES];
}


//****************************************************
#pragma mark - UITableViewDatasource and delegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger chatCount = self.arrRecentChats.count;
    if (chatCount == 0) {
        
        self.vuStickyNote.hidden = NO;
    }
    else{
        
        self.vuStickyNote.hidden = YES;
    }
    
    return chatCount;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    static NSString *strCellId = @"C411RecentChatCell";
    C411RecentChatCell *recentChatCell = [tableView dequeueReusableCellWithIdentifier:strCellId];
    if (rowIndex < self.arrRecentChats.count) {
        
        C411ChatRoom *chatRoom = [self.arrRecentChats objectAtIndex:rowIndex];
        [recentChatCell updateDetailsUsingChatRoom:chatRoom];
        
    }
    
    return recentChatCell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;//
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
   
    if (rowIndex < self.arrRecentChats.count) {
        
        C411ChatRoom *chatRoom = [self.arrRecentChats objectAtIndex:rowIndex];
        
        C411ChatVC *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ChatVC"];
        chatVC.entityType = chatRoom.entityType;
        chatVC.strEntityId = chatRoom.strEntityId;
        chatVC.strEntityName = chatRoom.strEntityName;
        chatVC.entityCreatedAtInMillis = chatRoom.entityCreatedAtInMillis;
        UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
        [rootNavC pushViewController:chatVC animated:YES];

        
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)newChatMsgArrived:(NSNotification *)notif
{
    ///Refresh the table view
    [self refreshChatList];
    
}


-(void)unreadMsgCountUpdated:(NSNotification *)notif
{
    ///Refresh the table view
    [self refreshChatList];
    
}

-(void)willEnterForeground:(NSNotification *)notif
{
    ///Refresh the table view
    [self refreshChatList];

}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
