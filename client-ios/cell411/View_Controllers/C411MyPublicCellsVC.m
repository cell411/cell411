//
//  C411MyPublicCellsVC.m
//  cell411
//
//  Created by Milan Agarwal on 29/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411MyPublicCellsVC.h"
#import "C411MyPublicCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411OtherPublicCell.h"
#import "Constants.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "C411CreateMyPublicCellVC.h"
#import "C411PublicCellDetailVC.h"
#import "MAAlertPresenter.h"
#import "AppDelegate.h"
#import "C411ChatVC.h"
#import "C411ColorHelper.h"

#define PAGE_LIMIT  10

#define TOTAL_SECTIONS  2
#define TABLE_SEC_INDEX_OWNED_CELLS     0
#define TABLE_SEC_INDEX_JOINED_CELLS    1


@interface C411MyPublicCellsVC ()<UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UITableView *tblVuMyPublicCells;

//@property (nonatomic, strong) NSMutableArray *arrOwnedPublicCells;
@property (nonatomic, strong) NSMutableArray *arrJoinedPublicCells;
@property (nonatomic, assign) BOOL noMoreData;
@property (nonatomic, assign) BOOL canRefresh;


@end

@implementation C411MyPublicCellsVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerForNotifications];
    //[self fetchMyPublicCells];
    [self addGestures];
    
    ///set can refresh to Yes initially
    self.canRefresh = YES;
    
    ///Add pull to refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tblVuMyPublicCells addSubview:refreshControl];
    [self applyColors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self unregisterFromNotifications];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.canRefresh) {
        
        [self fetchMyPublicCells];
   }
    else{
        ///Update it to YES for next time refresh
        self.canRefresh = YES;
    }
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
#pragma mark - Property initializers
//****************************************************

-(NSMutableArray *)arrJoinedPublicCells
{
    if (!_arrJoinedPublicCells) {
        
        _arrJoinedPublicCells = [NSMutableArray array];
    }
    
    return _arrJoinedPublicCells;
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    ///Set secondary text color
    self.lblDescription.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
}

-(void)applyColorOnHeaderview:(UIView *)headerView forSection:(NSInteger)section {
    headerView.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    UILabel *lblSectionName = (UILabel *)[headerView viewWithTag:101];
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    lblSectionName.textColor = primaryTextColor;
    
    UIView *vuSeparator = (UIView *)[headerView viewWithTag:102];
    vuSeparator.backgroundColor = [C411ColorHelper sharedInstance].separatorColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myOwnedPublicCellsListUpdated:) name:kOwnedPublicCellsListUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userRemovedFromCell:) name:kPublicCellUserRemovedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publicCellLeaved:) name:kPublicCellLeavedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publicCellDoesNotExist:) name:kPublicCellDoesNotExistNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshPublicCellsListing:) name:kRefreshPublicCellListingNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publicCellUpdated:) name:kPublicCellUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}



-(void)fetchMyPublicCells
{
//    ///clear the old data
//    self.noMoreData = NO;
//    self.arrOwnedPublicCells = nil;
//    self.arrJoinedPublicCells = nil;
//    [self.tblVuMyPublicCells reloadData];

    __weak typeof(self) weakself = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ///Fetch owned public cell first
    [self.publicCellsDelegate getOwnedPublicCellWithCompletion:^(NSArray * objects, NSError * error){
        
        
        if (!error) {
            
            ///Fetch joined Public Cell
            [weakself fetchJoinedPublicCellWithCompletion:^(NSArray * objects, NSError * error){
                
                if (!error) {
                    
                    ///Joined cells fetched
                    [weakself.arrJoinedPublicCells addObjectsFromArray:objects];
                    
                    if (objects.count < PAGE_LIMIT) {
                        
                        self.noMoreData = YES;
                    }
                    else{
                        
                        self.noMoreData = NO;
                    }
                    
                    
                }
                else {
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakself];
                    
                    
                    
                }
                
                ///hide hud
                [MBProgressHUD hideHUDForView:weakself.view animated:YES];
                [weakself.tblVuMyPublicCells reloadData];
                
            }];
            
            
        }
        else {
            
            ///show error
            NSString *errorString = [error userInfo][@"error"];
            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakself];
            
            ///hide hud
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            
        }
        
        
        
        
    }];
    
}


-(void)fetchJoinedPublicCellWithCompletion:(PFArrayResultBlock)completion
{
    ///Make a new query
    PFQuery *fetchJoinedPublicCellsQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
    [fetchJoinedPublicCellsQuery whereKey:kPublicCellMembersKey equalTo:[AppDelegate getLoggedInUser]];
    [fetchJoinedPublicCellsQuery whereKey:kPublicCellCreatedByKey notEqualTo:[AppDelegate getLoggedInUser]];
    [fetchJoinedPublicCellsQuery includeKey:kPublicCellCreatedByKey];
    fetchJoinedPublicCellsQuery.skip = self.arrJoinedPublicCells.count;
    fetchJoinedPublicCellsQuery.limit = PAGE_LIMIT;
    [fetchJoinedPublicCellsQuery orderByDescending:kPublicCellTotalMembersKey];
    
    [fetchJoinedPublicCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        
        
        if (completion != NULL) {
            
            completion(objects,error);
        }
        
    }];
    
}

-(void)fetchMoreJoinedPublicCells
{
    __weak typeof(self) weakself = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ///Fetch joined Public Cell
    [weakself fetchJoinedPublicCellWithCompletion:^(NSArray * objects, NSError * error){
        
        if (!error) {
            
            ///Joined cells fetched
            [weakself.arrJoinedPublicCells addObjectsFromArray:objects];
            
            if (objects.count < PAGE_LIMIT) {
                
                self.noMoreData = YES;
            }
            else{
                
                self.noMoreData = NO;
            }
            
            [weakself.tblVuMyPublicCells reloadData];
        }
        else {
            
            ///show error
            NSString *errorString = [error userInfo][@"error"];
            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakself];
            
            
            
        }
        
        ///hide hud
        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
        
    }];
    
}

-(void)removeJoinedPublicCellWithObjectId:(NSString *)strDeletedPublicCellObjId
{
    NSInteger publicCellObjectIndex = -1;
    for (NSInteger index = 0; index < self.arrJoinedPublicCells.count; index++) {
        
        PFObject *publicCell = [self.arrJoinedPublicCells objectAtIndex:index];
        
        if ([publicCell.objectId isEqualToString:strDeletedPublicCellObjId]) {
            ///found the corresponding deleted public cell
            publicCellObjectIndex = index;
            break;
            
        }
        
    }
    
    if (publicCellObjectIndex != -1 && publicCellObjectIndex < self.arrJoinedPublicCells.count) {
        
        ///refresh the object
        [self.arrJoinedPublicCells removeObjectAtIndex:publicCellObjectIndex];
        
    }
}

-(void)addGestures
{
    UILongPressGestureRecognizer *deleteGesture = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(handleOwnedCellDeletion:)];
    deleteGesture.delegate = self;
    [self.tblVuMyPublicCells addGestureRecognizer:deleteGesture];
}

-(void)showChatVCForPublicCell:(PFObject *)publicCellObj
{
    C411ChatVC *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ChatVC"];
    chatVC.entityType = ChatEntityTypePublicCell;
    chatVC.strEntityId = publicCellObj.objectId;
    chatVC.strEntityName = publicCellObj[kPublicCellNameKey];
    chatVC.entityCreatedAtInMillis = [publicCellObj.createdAt timeIntervalSince1970] * 1000;
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:chatVC animated:YES];

}

//****************************************************
#pragma mark - Gesture Methods
//****************************************************

-(void)handleOwnedCellDeletion:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        ///Show delete Cell popup
        CGPoint touchPoint = [gestureRecognizer locationInView:self.tblVuMyPublicCells];
        
        NSIndexPath *indexPath = [self.tblVuMyPublicCells indexPathForRowAtPoint:touchPoint];
        if (indexPath != nil &&indexPath.section == TABLE_SEC_INDEX_OWNED_CELLS &&indexPath.row < self.publicCellsDelegate.arrOwnedPublicCells.count) {
            NSInteger rowIndex = indexPath.row;
            PFObject *myPublicCell = [self.publicCellsDelegate.arrOwnedPublicCells objectAtIndex:rowIndex];
            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Are you sure you want to delete %@ Public Cell?",nil),myPublicCell[kPublicCellNameKey]];
            UIAlertController *confirmDeletionAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                ///user said No, do nothing
                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];

            }];
            
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                ///User opted to remove the cell
                
                __weak typeof(self) weakSelf = self;
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [myPublicCell deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    
                    if (succeeded) {
                        
                        ///1.Remove this cell from its array
                        [weakSelf.publicCellsDelegate removeOwnedPublicCellAtIndex:rowIndex];
                        
                        ///2.reload tableview
                        [weakSelf.tblVuMyPublicCells reloadData];

#if (!DEBUG && (APP_CELL411 || APP_IER))
                        ///Maintaining backward compatibilty with old versions for Cell 411 and iER Prod
                        ///3. remove the corresponding verification object as well if exist, so fetch the corresponding verification request object
                        PFQuery *fetchVerificatioReqQuery = [PFQuery queryWithClassName:kVerificationRequestClassNameKey];
                        [fetchVerificatioReqQuery whereKey:kVerificationRequestCellKey equalTo:myPublicCell];
                        __weak typeof(self) weakSelf = self;
                        [fetchVerificatioReqQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                            
                            if (!error) {
                                ///delete the verification object
                                
                                PFObject *verificationRequestObj = object;
                                
                                [verificationRequestObj deleteEventually];
                                
                            }
                            else if (error.code == kPFErrorObjectNotFound){
                                ///Object not available, that means verification is not requested till now
                                
                            }
                            else{
                                
                                if(![AppDelegate handleParseError:error]){
                                    ///Log error and save it in iVar
                                    NSString *errorString = [error userInfo][@"error"];
                                    NSLog(@"#error fetching cell411alert :%@",errorString);
                                }
                                
                                
                            }
                            
                            
                            ///remove hud
                            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                            
                            
                        }];
                        
#else
                        ///remove hud
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
#endif
                        
                    }
                    else{
                        
                        if (error) {
                            if(![AppDelegate handleParseError:error]){
                                ///show error
                                NSString *errorString = [error userInfo][@"error"];
                                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                            }
                        }
                        
                        ///remove hud
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
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
#pragma mark - UITableViewDatasource and delegate Methods
//****************************************************

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ((velocity.y>0) && (!self.noMoreData)) {
        CGSize contentSize = scrollView.contentSize;
        CGSize scrollVSize  = scrollView.bounds.size;
        
        float downloadTriggerPointFromBottom = scrollVSize.height + 100;
        float downloadTriggerPoint              = contentSize.height - downloadTriggerPointFromBottom;
        
        if (targetContentOffset->y>=downloadTriggerPoint) {
            [self fetchMoreJoinedPublicCells];
            
        }
        
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TOTAL_SECTIONS;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TABLE_SEC_INDEX_OWNED_CELLS) {
        
        return self.publicCellsDelegate.arrOwnedPublicCells.count;
    }
    else if (section == TABLE_SEC_INDEX_JOINED_CELLS){
        
        return self.arrJoinedPublicCells.count;
    }
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    NSInteger secIndex = indexPath.section;
    
    if (secIndex == TABLE_SEC_INDEX_OWNED_CELLS) {
        
        if (rowIndex < self.publicCellsDelegate.arrOwnedPublicCells.count) {
            
            ///Create and Return cell
            static NSString *publicCellId = @"C411MyPublicCell";
            C411MyPublicCell *myPublicCell = [tableView dequeueReusableCellWithIdentifier:publicCellId];
            
            ///Get Cell object
            PFObject *publicCellObject = [self.publicCellsDelegate.arrOwnedPublicCells objectAtIndex:rowIndex];
            
            ///Set Cell name
            myPublicCell.lblCellName.text = publicCellObject[kPublicCellNameKey];
            
            ///Set Cell Image
            
            ///Set verified Image
/*OLD implementation of verification request handling
            BOOL isVerified = [publicCellObject[kPublicCellIsVerifiedKey]boolValue];
*/
            BOOL isVerified = [publicCellObject[kPublicCellVerificationStatusKey]integerValue] == CellVerificationStatusApproved;
            
            if (isVerified) {
                
                ///Set verified image
                static UIImage *imgVerified = nil;
                if (!imgVerified) {
                    imgVerified = [UIImage imageNamed:@"ic_verified"];
                }
                
                myPublicCell.imgVuVerified.image = imgVerified;
                myPublicCell.imgVuVerified.layer.borderWidth = 2.0;

            }
            else{
                
                ///Remove verified image
                myPublicCell.imgVuVerified.image = nil;
                myPublicCell.imgVuVerified.layer.borderWidth = 0;
                

            }
            
#if CHAT_ENABLED
            ///set target on chat button
            myPublicCell.btnChat.tag = rowIndex;
            [myPublicCell.btnChat addTarget:self action:@selector(btnMyPublicCellChatTapped:) forControlEvents:UIControlEventTouchUpInside];
#else
            myPublicCell.btnChat.hidden = YES;
#endif
            return myPublicCell;
            
        }
        
    }
    else if (secIndex == TABLE_SEC_INDEX_JOINED_CELLS){
        
        ///Create and Return cell
        static NSString *publicCellId = @"C411OtherPublicCell";
        C411OtherPublicCell *otherPublicCell = [tableView dequeueReusableCellWithIdentifier:publicCellId];
        
        if (rowIndex < self.arrJoinedPublicCells.count) {
            
            
            ///Get Cell object
            PFObject *publicCellObject = [self.arrJoinedPublicCells objectAtIndex:rowIndex];
            
            ///Set Cell name
            otherPublicCell.lblCellName.text = publicCellObject[kPublicCellNameKey];
            
            ///Set cell Image
            
            ///Set verified Image
            /*OLD implementation of verification request handling
             BOOL isVerified = [publicCellObject[kPublicCellIsVerifiedKey]boolValue];
             */
            BOOL isVerified = [publicCellObject[kPublicCellVerificationStatusKey]integerValue] == CellVerificationStatusApproved;
            if (isVerified) {
                
                ///Set verified image
                static UIImage *imgVerified = nil;
                if (!imgVerified) {
                    imgVerified = [UIImage imageNamed:@"ic_verified"];
                }
                
                otherPublicCell.imgVuVerified.image = imgVerified;
                otherPublicCell.imgVuVerified.layer.borderWidth = 2.0;
                

            }
            else{
                
                ///Remove verified image
                otherPublicCell.imgVuVerified.image = nil;
                otherPublicCell.imgVuVerified.layer.borderWidth = 0;
            }
            
            ///Set status
            NSString *strStatus = NSLocalizedString(@"LEAVE", nil);
            ///enable the button
            otherPublicCell.btnJoinStatus.enabled = YES;
            otherPublicCell.strStatus = strStatus;
           
            ///Set title on button
            [otherPublicCell.btnJoinStatus setTitle:strStatus forState:UIControlStateNormal];
            otherPublicCell.btnJoinStatus.tag = indexPath.row;
            [otherPublicCell.btnJoinStatus addTarget:self action:@selector(leaveCellTapped:) forControlEvents:UIControlEventTouchUpInside];

#if CHAT_ENABLED
            ///set target on chat button
            otherPublicCell.btnChat.tag = rowIndex;
            [otherPublicCell.btnChat addTarget:self action:@selector(btnOtherPublicCellChatTapped:) forControlEvents:UIControlEventTouchUpInside];

#else
            otherPublicCell.btnChat.hidden = YES;
#endif
            

            
            return otherPublicCell;
            
        }
        
    }
    
    
    return nil;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;//
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    NSInteger secIndex = indexPath.section;
    if (secIndex == TABLE_SEC_INDEX_OWNED_CELLS) {
        
        if (rowIndex < self.publicCellsDelegate.arrOwnedPublicCells.count){
            
            ///Get the PublicCell object and pass it to the Members screen
            PFObject *myPublicCellObj = [self.publicCellsDelegate.arrOwnedPublicCells objectAtIndex:rowIndex];
            
            C411PublicCellDetailVC *publicCellDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411PublicCellDetailVC"];
            publicCellDetailVC.publicCellObj = myPublicCellObj;
            publicCellDetailVC.owner = YES;
            publicCellDetailVC.publicCellsDelegate = self.publicCellsDelegate;
            //publicCellDetailVC.strBarBtnRightTitle = NSLocalizedString(@"Request verification", nil);
            publicCellDetailVC.cellMembershipStatus = CellMembershipStatusIsAMember;

            [self.navigationController pushViewController:publicCellDetailVC animated:YES];
            
            ///set can refresh to no, so that it will not refresh the screen if user is coming back
            self.canRefresh = NO;

            
        }
        
    }
    else if (secIndex == TABLE_SEC_INDEX_JOINED_CELLS){
        
        if (rowIndex <= self.arrJoinedPublicCells.count){
            
            ///Get the PublicCell object and pass it to the Members screen
            PFObject *joinedPublicCellObj = [self.arrJoinedPublicCells objectAtIndex:rowIndex];
            
            C411PublicCellDetailVC *publicCellDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411PublicCellDetailVC"];
            publicCellDetailVC.publicCellObj = joinedPublicCellObj;
            publicCellDetailVC.owner = NO;
            //publicCellDetailVC.strBarBtnRightTitle = NSLocalizedString(@"Leave this Cell", nil);
            publicCellDetailVC.cellMembershipStatus = CellMembershipStatusIsAMember;
            
            [self.navigationController pushViewController:publicCellDetailVC animated:YES];
            
            ///set can refresh to no, so that it will not refresh the screen if user is coming back
            self.canRefresh = NO;

        }
        
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"SectionHeader" owner:self options:nil] lastObject];
    UILabel *lblSectionName = (UILabel *)[headerView viewWithTag:101];
    if (section == TABLE_SEC_INDEX_OWNED_CELLS && self.publicCellsDelegate.arrOwnedPublicCells.count > 0) {
        ///Owned cells section
        lblSectionName.text = NSLocalizedString(@"OWNED CELLS", nil);
        
    }
    else if (section == TABLE_SEC_INDEX_JOINED_CELLS && self.arrJoinedPublicCells.count > 0){
        
        ///joined cells sections
        lblSectionName.text = NSLocalizedString(@"JOINED CELLS", nil);
    }
    else{
        
        return nil;
    }
    
    ///Apply colors
    [self applyColorOnHeaderview:headerView forSection:section];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == TABLE_SEC_INDEX_OWNED_CELLS && self.publicCellsDelegate.arrOwnedPublicCells.count > 0) {
        ///Owned cells section
        return 32.0f;
        
    }
    else if (section == TABLE_SEC_INDEX_JOINED_CELLS && self.arrJoinedPublicCells.count > 0){
        
        ///joined cells sections
        return 32.0f;
    }
    else{
        
        return CGFLOAT_MIN;
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
     if (section == TABLE_SEC_INDEX_JOINED_CELLS  && self.arrJoinedPublicCells.count > 0){
         return 32.0f;
     }
    return CGFLOAT_MIN;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == TABLE_SEC_INDEX_JOINED_CELLS  && self.arrJoinedPublicCells.count > 0){
       
        return self.noMoreData ? NSLocalizedString(@"No more Cells to load", nil) : nil;

    }
    
    return nil;
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

-(void)leaveCellTapped:(UIButton *)sender
{
    NSInteger rowIndex = sender.tag;
    if (rowIndex < self.arrJoinedPublicCells.count) {
        
        PFObject *publicCellObj = [self.arrJoinedPublicCells objectAtIndex:rowIndex];
        NSString *strStatus = [sender titleForState:UIControlStateNormal];
        
        if ([strStatus isEqualToString:NSLocalizedString(@"LEAVE", nil)]) {
            
            ///Post notification to leave public cell
            [[NSNotificationCenter defaultCenter]postNotificationName:kLeavePublicCellNotification object:publicCellObj];
        }
        
    }
}


-(void)btnMyPublicCellChatTapped:(UIButton *)sender
{
    NSInteger rowIndex = sender.tag;
    if (rowIndex < self.publicCellsDelegate.arrOwnedPublicCells.count) {
        
        PFObject *publicCellObj = [self.publicCellsDelegate.arrOwnedPublicCells objectAtIndex:rowIndex];
        [self showChatVCForPublicCell:publicCellObj];
        
    }
}

-(void)btnOtherPublicCellChatTapped:(UIButton *)sender
{
    NSInteger rowIndex = sender.tag;
    if (rowIndex < self.arrJoinedPublicCells.count) {
        
        PFObject *publicCellObj = [self.arrJoinedPublicCells objectAtIndex:rowIndex];
        [self showChatVCForPublicCell:publicCellObj];

        
    }
}

-(void)refresh:(UIRefreshControl *)refreshControl
{
    [self fetchMyPublicCells];
    [refreshControl endRefreshing];
    
}


//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)myOwnedPublicCellsListUpdated:(NSNotification *)notif
{
    [self.tblVuMyPublicCells reloadData];
    
}

-(void)userRemovedFromCell:(NSNotification *)notif
{
    [self.tblVuMyPublicCells reloadData];
}


-(void)publicCellLeaved:(NSNotification *)notif
{
    ///1.remove the Cell411Alert object from the arrJoinedOrPendingCells
    PFObject *publicCellObj = notif.object;
    
    ///remove the public cell object from the array
    [self removeJoinedPublicCellWithObjectId:publicCellObj.objectId];
    
    ///Reload table
    [self.tblVuMyPublicCells reloadData];
}

-(void)publicCellDoesNotExist:(NSNotification *)notif
{
    ///remove the public cell object from the list
    NSString *strDeletedPublicCellObjId = notif.object;
    
    [self removeJoinedPublicCellWithObjectId:strDeletedPublicCellObjId];
    
    ///refresh the table
    [self.tblVuMyPublicCells reloadData];
}

-(void)refreshPublicCellsListing:(NSNotification *)notif
{
    [self fetchMyPublicCells];
}

-(void)publicCellUpdated:(NSNotification *)notif
{
    ///Public cell is updated so reload the tableview to reflect the change
    [self.tblVuMyPublicCells reloadData];
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
    for (NSInteger index = 0; index < [self numberOfSectionsInTableView:self.tblVuMyPublicCells]; index++) {
        UIView *sectionHeaderView = [self.tblVuMyPublicCells headerViewForSection:index];
        [self applyColorOnHeaderview:sectionHeaderView forSection:index];
    }
}


@end
