//
//  C411SendAlertVC.m
//  cell411
//
//  Created by Milan Agarwal on 30/03/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411SendAlertVC.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411AlertAudienceCell.h"
#import "C411AlertSettings.h"
#import "C411AppDefaults.h"
#import "AppDelegate.h"
#import "C411CellsSelectionPopup.h"
#import "C411LocationManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIImage+ColoredImage.h"
#import "C411ColorHelper.h"
#if NON_APP_USERS_ENABLED
#import "C411NonAppUsersSelectionVC.h"
#endif

#define TOTAL_ROWS  9

#define TABLE_ROW_INDEX_FAMILY          0
#define TABLE_ROW_INDEX_FRIENDS         1
#define TABLE_ROW_INDEX_COWORKERS       2
#define TABLE_ROW_INDEX_SCHOOLMATES     3
#define TABLE_ROW_INDEX_NEIGHBOURS      4
#define TABLE_ROW_INDEX_NAU             5
#define TABLE_ROW_INDEX_CELLS           6
#define TABLE_ROW_INDEX_GLOBAL_ALERT    7
#define TABLE_ROW_INDEX_CALL_CENTRE     8

//#define kDefaultCells   @"defaultCells"
//#define kFilteredPrivateCells   @"filteredPrivateCells"
//#define kFilteredDeselectedPrivateCells   @"filteredDeselectedPrivateCells"
//#define kFilteredPublicCellsId   @"filteredPublicCellsId"
//#define kFilteredDeselectedPublicCells   @"filteredDeselectedPublicCells"
static NSString *const C411ConstDarkRedColor = @"d50000";
static NSString *const C411ConstRedPressedColor = @"FF0000";
static NSString *const C411ConstDarkGreenColor = @"018b01";
static NSString *const C411ConstGreenPressedColor = @"00FF00";


@interface C411SendAlertVC ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, C411CellsSelectionPopupDelegate
#if NON_APP_USERS_ENABLED
,C411NonAppUsersSelectionVCDelegate
#endif
>

@property (weak, nonatomic) IBOutlet UIView *vuAlertBG;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlVuBase;
@property (weak, nonatomic) IBOutlet UIView *vuContainer;
@property (weak, nonatomic) IBOutlet C411CellsSelectionPopup *vuCellsSelectionPopup;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertSubtitle;
@property (weak, nonatomic) IBOutlet UITableView *tblVuAlertAudiences;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNoteTitle;
@property (weak, nonatomic) IBOutlet UIView *vuAdditionalNoteContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNotePlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *txtVuAdditionalNote;
@property (weak, nonatomic) IBOutlet UIView *vuAdditionalNoteBottomLine;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPlaceholderVuBS;
- (IBAction)btnSendTapped:(UIButton *)sender;
- (IBAction)btnCancelTapped:(UIButton *)sender;
- (IBAction)btnCloseTapped:(UIButton *)sender;

@property (nonatomic, assign) float kbHeight;
@property (nonatomic, strong) C411AlertSettings *alertSettings;
@property (nonatomic, strong) NSArray *arrRowIndexMapping;
@property (nonatomic, assign) NSUInteger selectedCellsMembersCount;
@property (nonatomic, assign, getter=isMembersCountFetched) BOOL membersCountFetched;
#if PATROL_FEATURE_ENABLED
@property (nonatomic, assign, getter=isGlobalAlertDataFetched) BOOL globalAlertDataFetched;
@property (nonatomic, assign, getter=isGlobalAlertEnabled) BOOL globalAlertEnabled;
@property (nonatomic, strong) NSDictionary *dictPrivilegeResult;
#endif
///Properties are created with some extent of thread safety in mind
@property (nonatomic, strong) NSDictionary *dictDefaultCells;
@property (nonatomic, strong) NSArray *arrFilteredPrivateCells;
@property (nonatomic, strong) NSMutableDictionary *dictFilteredDeselectedPrivateCells;
@property (nonatomic, strong) NSArray *arrFilteredPublicCellsId;
@property (nonatomic, strong) NSMutableDictionary *dictFilteredDeselectedPublicCells;
@property (nonatomic, strong) id privateCellsParams;
@property (nonatomic, strong) id publicCellsParams;

@property (nonatomic, strong) NSOperationQueue *initializationOpQueue;
@property (nonatomic, assign, getter=isPrivateCellsDataInitialized) BOOL privateCellsDataInitialized;
@property (nonatomic, assign, getter=isPublicCellsDataInitialized) BOOL publicCellsDataInitialized;
@property (nonatomic, assign, getter=shouldSelectNauOnNonZeroVal)BOOL selectNauOnNonZeroVal;
@property (nonatomic, assign, getter=shouldSelectCellsOnNonZeroVal)BOOL selectCellsOnNonZeroVal;
@property (nonatomic, assign) BOOL wasCellsAudienceSelected;
@property (nonatomic, assign, getter=shouldSendAlertOnLocationUpdate) BOOL sendAlertOnLocationUpdate;
@property (nonatomic, weak) MBProgressHUD *locationRetrievalProgressHud;

@end

@implementation C411SendAlertVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblVuAlertAudiences.contentInset = UIEdgeInsetsMake(-28, 0, 0, 0);
    [self registerForNotifications];
    [self configureViews];
    [self setupViews];
    [self initializeData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)dealloc
{
    [self unregisterNotifications];
    [self.initializationOpQueue cancelAllOperations];
    self.initializationOpQueue = nil;
    NSLog(@"C411SendAlertVC:%s",__PRETTY_FUNCTION__);
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

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(C411AlertSettings *)alertSettings
{
    if(!_alertSettings){
        _alertSettings = [C411AlertSettings getAlertSettings];
    }
    
    return _alertSettings;
}

-(NSMutableDictionary *)dictFilteredDeselectedPrivateCells
{
    if(!_dictFilteredDeselectedPrivateCells){
        _dictFilteredDeselectedPrivateCells = [NSMutableDictionary dictionary];
    }
    
    return _dictFilteredDeselectedPrivateCells;
}

-(NSMutableDictionary *)dictFilteredDeselectedPublicCells
{
    if(!_dictFilteredDeselectedPublicCells){
        _dictFilteredDeselectedPublicCells = [NSMutableDictionary dictionary];
    }
    
    return _dictFilteredDeselectedPublicCells;
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(friendListUpdated:) name:kFriendListUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)configureViews
{
    self.vuContainer.layer.cornerRadius = 5.0;
    self.vuContainer.layer.borderWidth = 1.0f;
    
    self.vuAdditionalNoteContainer.layer.cornerRadius = 5.0;
    self.btnCancel.layer.cornerRadius = 3.0;
    self.btnCancel.layer.masksToBounds = YES;
    self.btnSend.layer.cornerRadius = 3.0;
    self.btnSend.layer.masksToBounds = YES;
    
    ///Set background images for highlight
    UIColor *darkRedColor = [C411StaticHelper colorFromHexString:C411ConstDarkRedColor];
    UIColor *redPressedColor = [C411StaticHelper colorFromHexString:C411ConstRedPressedColor andAlpha:0.6f];
    [self.btnCancel setBackgroundImage:[UIImage imageWithColor:darkRedColor] forState:UIControlStateNormal];
    [self.btnCancel setBackgroundImage:[UIImage imageWithColor:redPressedColor] forState:UIControlStateHighlighted];
    
    UIColor *darkGreenColor = [C411StaticHelper colorFromHexString:C411ConstDarkGreenColor];
    UIColor *greenPressedColor = [C411StaticHelper colorFromHexString:C411ConstGreenPressedColor andAlpha:0.6f];
    [self.btnSend setBackgroundImage:[UIImage imageWithColor:darkGreenColor] forState:UIControlStateNormal];
    [self.btnSend setBackgroundImage:[UIImage imageWithColor:greenPressedColor] forState:UIControlStateHighlighted];
    
    [C411StaticHelper makeCircularView:self.btnClose];
    
//    UIColor *primaryColor = [C411StaticHelper colorFromHexString:PRIMARY_COLOR];
//    [self.btnSend setTitleColor:primaryColor forState:UIControlStateNormal];
    self.btnClose.layer.borderWidth = 1.0;
    [self applyColors];
}

-(void)applyColors {
    ///set light card color
    UIColor *lightCardColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuContainer.backgroundColor = lightCardColor;
    
    ///Set background color
    self.vuAdditionalNoteContainer.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblAlertTitle.textColor = primaryTextColor;
    self.lblAdditionalNoteTitle.textColor = primaryTextColor;
    self.txtVuAdditionalNote.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblAlertSubtitle.textColor = secondaryTextColor;
    
    ///Set disabled color for placeholder text
    UIColor *disabledTextColor = [C411ColorHelper sharedInstance].disabledTextColor;
    self.lblAdditionalNotePlaceholder.textColor = disabledTextColor;
    
    ///Set separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuAdditionalNoteBottomLine.backgroundColor = separatorColor;
    
    UIColor *crossButtonColor = [C411ColorHelper sharedInstance].popupCrossButtonColor;
    self.btnClose.backgroundColor = crossButtonColor;
    
    UIColor *blackColor = [UIColor blackColor];
    self.btnClose.layer.borderColor = blackColor.CGColor;
    
    self.vuContainer.layer.borderColor = blackColor.CGColor;
    
}

-(void)setupViews
{
    NSString *strTitle = nil;
    
//    if (self.isForwardingAlert) {
//        
//        ///User is forwarding someone's else alert.
//        strTitle = NSLocalizedString(@"Forward Alert?", nil);
//        
//    }
//    else{
    
        ///User is actually initiating the alert, use alertType to make the title
        switch (self.alertType) {
            case AlertTypeBrokeCar:
                strTitle = NSLocalizedString(@"Send vehicle broken alert?", nil);
                break;
            case AlertTypeBullied:
#if APP_IER
                strTitle = NSLocalizedString(@"Send bullied alert?", nil);
#else
                strTitle = NSLocalizedString(@"Send harassed alert?", nil);
#endif
                break;
            case AlertTypeCriminal:
                strTitle = NSLocalizedString(@"Send crime alert?", nil);
                break;
            case AlertTypeGeneral:
                strTitle = NSLocalizedString(@"Send general alert?", nil);
                break;
            case AlertTypePulledOver:
                strTitle = NSLocalizedString(@"Send pulled over alert?", nil);
                break;
            case AlertTypeDanger:
                strTitle = NSLocalizedString(@"Send danger alert?", nil);
                break;
            case AlertTypeVideo:
                strTitle = NSLocalizedString(@"Stream and share live video with?", nil);
                break;
            case AlertTypePhoto:
                strTitle = NSLocalizedString(@"Send photo alert?", nil);
                break;
            case AlertTypeFire:
                strTitle = NSLocalizedString(@"Send fire alert?", nil);
                break;
            case AlertTypeMedical:
                strTitle = NSLocalizedString(@"Send medical alert?", nil);
                break;
            case AlertTypePoliceInteraction:
                strTitle = NSLocalizedString(@"Send police interaction alert?", nil);
                break;
            case AlertTypePoliceArrest:
                strTitle = NSLocalizedString(@"Send arrested alert?", nil);
                break;
            case AlertTypeHijack:
                strTitle = NSLocalizedString(@"Send hijack alert?", nil);
                break;
            case AlertTypePhysicalAbuse:
                strTitle = NSLocalizedString(@"Send physical abuse alert?", nil);
                break;
            case AlertTypeTrapped:
                strTitle = NSLocalizedString(@"Send trapped/lost alert?", nil);
                break;
            case AlertTypeCarAccident:
                strTitle = NSLocalizedString(@"Send car accident alert?", nil);
                break;
            case AlertTypeNaturalDisaster:
                strTitle = NSLocalizedString(@"Send natural disaster alert?", nil);
                break;
            case AlertTypePreAuthorisation:
                strTitle = NSLocalizedString(@"Send pre-authorisation alert?", nil);
                break;
            default:
                break;
        }
//    }
    
    
    self.lblAlertTitle.text = strTitle;
    
    ///Set the background color
    if(self.alertType == AlertTypeGeneral){
        ///more dark and transparent for general alert
        self.view.backgroundColor = [C411StaticHelper colorFromHexString:@"373737" andAlpha:0.6];
    }
    else{
       self.view.backgroundColor = [[C411StaticHelper getColorForAlertType:self.alertType withColorType:ColorTypeLight]colorWithAlphaComponent:0.6];
    }
    

    ///Iniitalize the rowIndex mapping
    [self initializeRowIndexMapping];
    
    self.vuCellsSelectionPopup.alertSettings = self.alertSettings;
    self.vuCellsSelectionPopup.delegate = self;
}

-(void)initializeData
{
    ///Cancel all previous operations
    [self.initializationOpQueue cancelAllOperations];
    ///disable the send button until initialization is completed
    self.btnSend.alpha = 0.6f;
    self.btnSend.enabled = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSBlockOperation *privateCellsInitOperation = [self initializePrivateCellsData];
    NSBlockOperation *publicCellsInitOperation = [self initializePublicCellsData];
    ///Create an operation queue as this could be a long operation
    if (!self.initializationOpQueue) {
        self.initializationOpQueue = [[NSOperationQueue alloc]init];
    }
    
    __weak typeof(self) weakSelf = self;
    ///Create a block completion operation
    NSBlockOperation *completionOperation=[[NSBlockOperation alloc]init];
    __block NSBlockOperation *weakCompletionOperation=completionOperation;
    [completionOperation addExecutionBlock:^{
        if (![weakCompletionOperation isCancelled]) {
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                weakSelf.btnSend.alpha = 1.0f;
                weakSelf.btnSend.enabled = YES;
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf initializeSelectedCellsMembersCount];
                weakSelf.vuCellsSelectionPopup.dictFilteredDeselectedPrivateCells = weakSelf.dictFilteredDeselectedPrivateCells;
                weakSelf.vuCellsSelectionPopup.dictFilteredDeselectedPublicCells = weakSelf.dictFilteredDeselectedPublicCells;
                weakSelf.vuCellsSelectionPopup.arrFilteredPrivateCells = weakSelf.arrFilteredPrivateCells;
                [weakSelf.vuCellsSelectionPopup reloadData];
                NSLog(@"Initialization operation completed");
            }];
        }
    }];

    ///Add dependency
    [completionOperation addDependency:privateCellsInitOperation];
    [completionOperation addDependency:publicCellsInitOperation];
    
    
    ///Add and execute operations in background
    [self.initializationOpQueue addOperations:@[privateCellsInitOperation, publicCellsInitOperation, completionOperation] waitUntilFinished:NO];
    
}

-(NSBlockOperation *)initializePrivateCellsData
{
    __weak typeof(self) weakSelf = self;
    
    ///Create a block operation for initializing Private Cells Data
    NSBlockOperation *initPrivateCellsDataOp = [[NSBlockOperation alloc]init];
    __block NSBlockOperation *weakInitPrivateCellsDataOp = initPrivateCellsDataOp;
    [initPrivateCellsDataOp addExecutionBlock:^{
        if (![weakInitPrivateCellsDataOp isCancelled]) {
            
            ///Get all Private cells
            NSArray *arrAllPrivateCells = [C411AppDefaults sharedAppDefaults].arrCells;
            if(!arrAllPrivateCells){
                ///Fetch all private cells synchronously as this method is running asynchronously
                PFUser *currentUser = [AppDelegate getLoggedInUser];
                PFQuery *getCellsQuery = [PFQuery queryWithClassName:kCellClassNameKey];
                [getCellsQuery includeKey:kCellMembersKey];
                [getCellsQuery whereKey:kCellCreatedByKey equalTo:currentUser];
                NSError *error = nil;
                NSArray *arrPrivateCellObjects = [getCellsQuery findObjects:&error];
                if([weakInitPrivateCellsDataOp isCancelled]){
                    ///Return if operation is cancelled
                    return;
                }
                
                if (!error) {
                    ///Private Cells fetched
                    arrAllPrivateCells = arrPrivateCellObjects;
                }
                else{
                    NSLog(@"Error Initializing Private Cells data: %@", error);
                }
            }
            
            if(arrAllPrivateCells)
            {
                NSMutableDictionary *dictDefaultCells = [NSMutableDictionary dictionary];
                NSMutableArray *arrFilteredPrivateCells = [NSMutableArray array];
                NSMutableDictionary *dictFilteredDeselectedPrivateCells = [NSMutableDictionary dictionary];
                NSDictionary *dictDefaultCellMapping = [C411StaticHelper getDefaultCellsLocalizedNameAndTypeMapping];
                
                NSDictionary *dictCellsSelectionData = [weakSelf.alertSettings getCellsSelectionData];
                NSDictionary *dictPrivateCellSelectionData = dictCellsSelectionData[kAlertAudienceCellsPrivateCellsKey];
                NSDictionary *dictDeselectedPrivateCells = dictPrivateCellSelectionData[kAlertAudienceDeselectedCellsKey];

                for(PFObject *cell in arrAllPrivateCells){
                    
                    NSNumber *numCellType = cell[kCellTypeKey];
                    NSInteger totalCellMembers = [weakSelf getTotalMembersInPrivateCell:cell];
                    if(numCellType && dictDefaultCellMapping[numCellType]){
                        ///Get the default Cells
                        dictDefaultCells[numCellType] = cell;
                    }
                    else if (totalCellMembers > 0 && [numCellType integerValue] != PrivateCellTypeFriends){
                        ///Filter Private Cells
                        [arrFilteredPrivateCells addObject:cell];
                        
                        if(dictDeselectedPrivateCells && dictDeselectedPrivateCells[cell.objectId]){
                            ///Get the filtered unselected Private Cells
                            dictFilteredDeselectedPrivateCells[cell.objectId] = @(YES);
                        }
                    }
                }
                
                if([weakInitPrivateCellsDataOp isCancelled]){
                    ///Return if operation is cancelled
                    return;
                }

                weakSelf.dictDefaultCells = dictDefaultCells;
                weakSelf.arrFilteredPrivateCells = arrFilteredPrivateCells;
                weakSelf.dictFilteredDeselectedPrivateCells = dictFilteredDeselectedPrivateCells;
                
                if (![weakInitPrivateCellsDataOp isCancelled]) {
                    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                        [weakSelf.tblVuAlertAudiences reloadData];
                    }];
                }
                
                weakSelf.privateCellsParams = [weakSelf getPrivateCellsParam];
                
                ///Set the success flag
                weakSelf.privateCellsDataInitialized = YES;
                
            }
            
            NSLog(@"Private Cells initialization operation completed");
            

        }
    }];
    
    return initPrivateCellsDataOp;
}

-(NSBlockOperation *)initializePublicCellsData
{
    
    __weak typeof(self) weakSelf = self;
    
    ///Create a block operation for initializing Public Cells Data
    NSBlockOperation *initPublicCellsDataOp = [[NSBlockOperation alloc]init];
    __block NSBlockOperation *weakInitPublicCellsDataOp = initPublicCellsDataOp;
    [initPublicCellsDataOp addExecutionBlock:^{
        if (![weakInitPublicCellsDataOp isCancelled]) {
            
            ///Get all Public Cells Ids
            PFUser *currentUser = [AppDelegate getLoggedInUser];
            PFQuery *getAllPublicCellsIdQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
            [getAllPublicCellsIdQuery whereKey:kPublicCellMembersKey equalTo:currentUser];
            [getAllPublicCellsIdQuery whereKey:kPublicCellTotalMembersKey greaterThan:@1];
            [getAllPublicCellsIdQuery selectKeys:@[kPublicCellTotalMembersKey]];
            getAllPublicCellsIdQuery.limit = 1000;///Max Limit
            NSError *error = nil;
            NSArray *arrPublicCellObjects = [getAllPublicCellsIdQuery findObjects:&error];
            if([weakInitPublicCellsDataOp isCancelled]){
                ///Return if operation is cancelled
                return;
            }
            
            
            if (!error && arrPublicCellObjects) {
                ///Public Cells fetched
                NSMutableArray *arrFilteredPublicCellsId = [NSMutableArray array];
                NSMutableDictionary *dictFilteredDeselectedPublicCells = [NSMutableDictionary dictionary];
                
                NSDictionary *dictCellsSelectionData = [weakSelf.alertSettings getCellsSelectionData];
                NSDictionary *dictPublicCellSelectionData = dictCellsSelectionData[kAlertAudienceCellsPublicCellsKey];
                NSDictionary *dictDeselectedPublicCells = dictPublicCellSelectionData[kAlertAudienceDeselectedCellsKey];
                
                for(PFObject *cell in arrPublicCellObjects){
                    
                    [arrFilteredPublicCellsId addObject:cell.objectId];
                    
                    if(dictDeselectedPublicCells && dictDeselectedPublicCells[cell.objectId]){
                        ///Get the filtered unselected Public Cells
                        dictFilteredDeselectedPublicCells[cell.objectId] = @(YES);
                    }
                }
                
                if([weakInitPublicCellsDataOp isCancelled]){
                    ///Return if operation is cancelled
                    return;
                }
                
                weakSelf.arrFilteredPublicCellsId = arrFilteredPublicCellsId;
                weakSelf.dictFilteredDeselectedPublicCells = dictFilteredDeselectedPublicCells;
                
                weakSelf.publicCellsParams = [weakSelf getPublicCellsParam];
                
            }
            
            if(error){
                
                NSLog(@"Error initializing Public Cells data: %@", error);
            }
            else{
                ///Set the success flag
                weakSelf.publicCellsDataInitialized = YES;
            }
            
            NSLog(@"Public Cells initialization operation completed");
        }
    }];
    
    return initPublicCellsDataOp;
}


-(void)initializeSelectedCellsMembersCount
{
    if(self.isPrivateCellsDataInitialized && self.isPublicCellsDataInitialized){
        
        NSMutableDictionary *dictCellsData = [NSMutableDictionary dictionary];
        dictCellsData[kRetrieveTotalSelectedMembersFuncParamPrivateCellsKey] = self.privateCellsParams;
        dictCellsData[kRetrieveTotalSelectedMembersFuncParamPublicCellsKey] = self.publicCellsParams;
        NSError *err = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictCellsData options:NSJSONWritingPrettyPrinted error:&err];
        if (!err && jsonData) {
            
            NSString *strJsonData = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            if (strJsonData.length > 0) {
                NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
                dictParams[kRetrieveTotalSelectedMembersFuncParamDataKey] = strJsonData;
                
                __weak typeof(self) weakSelf = self;
                [C411StaticHelper retrieveTotalSelectedMembersWithDetails:dictParams andCompletion:^(id object, NSError * error) {
                    
                    if(!error){
                        
                        ///use the selected cells member count and update the row
                        if([object isKindOfClass:[NSDictionary class]]){
                            
                            NSInteger totalMembers = [object[@"users"] integerValue];
                            weakSelf.membersCountFetched = YES;
                            [weakSelf updateSelectedCellsMembersCount:totalMembers];
#if PATROL_FEATURE_ENABLED
                            weakSelf.globalAlertEnabled = [object[@"isGlobalAlertEnabled"] boolValue];
                            if(weakSelf.isGlobalAlertEnabled == NO){
                                weakSelf.dictPrivilegeResult = object[@"privilegeResult"];
                            }
                            weakSelf.globalAlertDataFetched = YES;
                            [weakSelf updateGlobalAlert];
#endif
                        }

//                        if([object isKindOfClass:[NSString class]]
//                           && [object length] > 0){
//
//                            NSInteger totalMembers = [object integerValue];
//                            weakSelf.membersCountFetched = YES;
//                            [weakSelf updateSelectedCellsMembersCount:totalMembers];
//                        }
                        NSLog(@"Cells members fetched: %@", object);
                    }
                }];
            }
            else{
                
                NSLog(@"Error converting to json string");
            }
        }
        else{
            
            NSLog(@"Error converting to json data: %@", err);
        }

    }
}

-(void)updateSelectedCellsMembersCount:(NSInteger)totalMembers
{
    self.selectedCellsMembersCount = totalMembers;
    
    NSInteger cellsVisibleIndex = [self getVisibleRowIndexFromMappedRowIndex:TABLE_ROW_INDEX_CELLS];
    [self.tblVuAlertAudiences reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellsVisibleIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#if PATROL_FEATURE_ENABLED
-(void)updateGlobalAlert
{
    NSInteger cellsVisibleIndex = [self getVisibleRowIndexFromMappedRowIndex:TABLE_ROW_INDEX_GLOBAL_ALERT];
    [self.tblVuAlertAudiences reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellsVisibleIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
#endif

-(id)getPrivateCellsParam
{
    
    NSArray *arrFilteredPrivateCells = self.arrFilteredPrivateCells;
    NSDictionary *dictFilteredDeselectedPrivateCells = self.dictFilteredDeselectedPrivateCells;
    NSInteger filteredDeselectedPrivateCellsCount = dictFilteredDeselectedPrivateCells.allKeys.count;
    if((arrFilteredPrivateCells.count > 0)
       && (arrFilteredPrivateCells.count != filteredDeselectedPrivateCellsCount)){
        
        if(filteredDeselectedPrivateCellsCount > 0){
            
            if((arrFilteredPrivateCells.count / 2) < filteredDeselectedPrivateCellsCount){
                
                ///Selected Cells are less than deselected cells
                NSMutableArray *arrSelectedPrivateCellsId = [NSMutableArray array];
                for (PFObject *cell in arrFilteredPrivateCells) {
                    
                    if(!(dictFilteredDeselectedPrivateCells[cell.objectId])){
                        
                        [arrSelectedPrivateCellsId addObject:cell.objectId];
                        if(arrFilteredPrivateCells.count - filteredDeselectedPrivateCellsCount == arrSelectedPrivateCellsId.count)
                        {
                            ///stop iteration if all selected cells are inserted
                            break;
                        }
                        
                    }
                }
                
                NSMutableDictionary *dictSelectedCellsData = [NSMutableDictionary dictionary];
                dictSelectedCellsData[kRetrieveTotalSelectedMembersFuncParamTypeKey] = kRetrieveTotalSelectedMembersFuncTypeValueSelected;
                dictSelectedCellsData[kRetrieveTotalSelectedMembersFuncParamArrayKey] = arrSelectedPrivateCellsId;
                
                return dictSelectedCellsData;
                
            }
            else{
                
                ///Deselected cells are less than selected
                NSMutableDictionary *dictDeselectedCellsData = [NSMutableDictionary dictionary];
                dictDeselectedCellsData[kRetrieveTotalSelectedMembersFuncParamTypeKey] = kRetrieveTotalSelectedMembersFuncTypeValueDeselected;
                dictDeselectedCellsData[kRetrieveTotalSelectedMembersFuncParamArrayKey] = dictFilteredDeselectedPrivateCells.allKeys;
                
                return dictDeselectedCellsData;
            }
            
            
        }
        else{
            ///All filtered private cells are selected. There could be the case that some private cells which have no members(not avaialble on filtered private cells list) are selected or unselected. We'll ignore them for now and send true flag for Private cells which will check all private cells members and the cells which have no members will not create any impact
            return @(YES);
            
            
        }
    }
    else{
        ///There is no private cells available that has some members in it other than default cells.
        return @(NO);
        
    }
}

-(id)getPublicCellsParam
{
    
    NSArray *arrFilteredPublicCellsId = self.arrFilteredPublicCellsId;
    NSDictionary *dictFilteredDeselectedPublicCells = self.dictFilteredDeselectedPublicCells;
    NSInteger filteredDeselectedPublicCellsCount = dictFilteredDeselectedPublicCells.allKeys.count;
    if((arrFilteredPublicCellsId.count > 0)
       && (arrFilteredPublicCellsId.count != filteredDeselectedPublicCellsCount)){
        
        if(filteredDeselectedPublicCellsCount > 0){
            
            if((arrFilteredPublicCellsId.count / 2) < filteredDeselectedPublicCellsCount){
                
                ///Selected Cells are less than deselected cells
                NSMutableArray *arrSelectedPublicCellsId = [NSMutableArray array];
                for (NSString *strCellId in arrFilteredPublicCellsId) {
                    
                    if(!(dictFilteredDeselectedPublicCells[strCellId])){
                        
                        [arrSelectedPublicCellsId addObject:strCellId];
                        if(arrFilteredPublicCellsId.count - filteredDeselectedPublicCellsCount == arrSelectedPublicCellsId.count)
                        {
                            ///stop iteration if all selected cells are inserted
                            break;
                        }
                        
                    }
                }
                
                NSMutableDictionary *dictSelectedCellsData = [NSMutableDictionary dictionary];
                dictSelectedCellsData[kRetrieveTotalSelectedMembersFuncParamTypeKey] = kRetrieveTotalSelectedMembersFuncTypeValueSelected;
                dictSelectedCellsData[kRetrieveTotalSelectedMembersFuncParamArrayKey] = arrSelectedPublicCellsId;
                
                return dictSelectedCellsData;
                
            }
            else{
                
                ///Deselected cells are less than selected
                NSMutableDictionary *dictDeselectedCellsData = [NSMutableDictionary dictionary];
                dictDeselectedCellsData[kRetrieveTotalSelectedMembersFuncParamTypeKey] = kRetrieveTotalSelectedMembersFuncTypeValueDeselected;
                dictDeselectedCellsData[kRetrieveTotalSelectedMembersFuncParamArrayKey] = dictFilteredDeselectedPublicCells.allKeys;
                
                return dictDeselectedCellsData;
            }
            
            
        }
        else{
            ///All filtered public cells are selected. There could be the case that some public cells which have no members(not avaialble on filtered public cells list) are selected or unselected. We'll ignore them for now and send true flag for Public cells which will check all public cells members and the cells which have no members will not create any impact
            return @(YES);
        }
    }
    else{
        ///There is no public cells available that has some members in it other than default cells.
        return @(NO);
        
    }
}

-(BOOL)isAnyAudienceSelected
{
    for (NSInteger rowIndex = 0; rowIndex < self.arrRowIndexMapping.count; rowIndex++) {
        
        NSInteger mappedRowIndex = [self getMappedRowIndexFromVisibleRowIndex:rowIndex];
        NSString *strAlertAudienceKey = [self getAlertAudienceKeyForRowIndex:mappedRowIndex];
        if([self.alertSettings isAudienceSelected:strAlertAudienceKey]){
            ///Yes there is some audience selected, get it's associated cell object and check if toggle button is selected
            ///Create a static cell for each reuse identifier
            static C411AlertAudienceCell *alertAudienceCell = nil;
            static dispatch_once_t onceToken;
            __weak typeof(self) weakSelf = self;
            dispatch_once(&onceToken, ^{
                
                alertAudienceCell = [weakSelf.tblVuAlertAudiences dequeueReusableCellWithIdentifier:@"C411AlertAudienceCell"];
                
            });

            [self tableView:self.tblVuAlertAudiences configureCell:alertAudienceCell atIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0]];
            if(alertAudienceCell.tglBtnAudienceSelection.isSelected){
                return YES;
            }
            
        }
    }
    ///None of the audience option is selected
    return NO;
}

-(NSDictionary *)getAudienceParams
{
    ///Create selected audience params
    NSMutableDictionary *dictAudience = [NSMutableDictionary dictionary];
    NSMutableArray *arrDefaultCellId = [NSMutableArray array];
    for (NSInteger rowIndex = 0; rowIndex < self.arrRowIndexMapping.count; rowIndex++) {
        
        NSInteger mappedRowIndex = [self getMappedRowIndexFromVisibleRowIndex:rowIndex];
        NSString *strAlertAudienceKey = [self getAlertAudienceKeyForRowIndex:mappedRowIndex];
        if([self.alertSettings isAudienceSelected:strAlertAudienceKey]){
            
               PFObject *defaultCell = nil;
                switch (mappedRowIndex) {
                    case TABLE_ROW_INDEX_FAMILY:
                    defaultCell = [self.dictDefaultCells objectForKey:@(PrivateCellTypeFamily)];
                    break;
                    
                    case TABLE_ROW_INDEX_COWORKERS:
                    defaultCell = [self.dictDefaultCells objectForKey:@(PrivateCellTypeCoworkers)];
                    break;
                    
                    case TABLE_ROW_INDEX_SCHOOLMATES:
                    defaultCell = [self.dictDefaultCells objectForKey:@(PrivateCellTypeSchoolmates)];
                    break;
                    
                    case TABLE_ROW_INDEX_NEIGHBOURS:
                    defaultCell = [self.dictDefaultCells objectForKey:@(PrivateCellTypeNeighbours)];
                    break;
                    
                    case TABLE_ROW_INDEX_FRIENDS:
                    dictAudience[kSendAlertV3FuncParamAllFriendsKey] = @(YES);
                    break;

#if NON_APP_USERS_ENABLED
                    case TABLE_ROW_INDEX_NAU:{
                        NSArray *arrSelectedNau = [self.alertSettings getSelectedNauMembers];
                        NSError *err = nil;
                        NSData *arrContactsJsonData = [NSJSONSerialization dataWithJSONObject:arrSelectedNau options:NSJSONWritingPrettyPrinted error:&err];
                        if (!err && arrContactsJsonData) {
                            
                            NSString *strJsonArrContacts = [[NSString alloc]initWithData:arrContactsJsonData encoding:NSUTF8StringEncoding];
                            if (strJsonArrContacts.length > 0) {
                                
                                dictAudience[kSendAlertV3FuncParamNauKey] = strJsonArrContacts;
                            }
                        }
                    }
                        
                    break;
#endif
                    
                    case TABLE_ROW_INDEX_CELLS:
                    dictAudience[kSendAlertV3FuncParamPrivateCellsKey] = [self getPrivateCellsParam];
                    dictAudience[kSendAlertV3FuncParamPublicCellsKey] = [self getPublicCellsParam];
                    break;

#if PATROL_FEATURE_ENABLED
                    case TABLE_ROW_INDEX_GLOBAL_ALERT:
                    dictAudience[kSendAlertV3FuncParamGlobalKey] = @(YES);
                    break;
#endif
                    
                    case TABLE_ROW_INDEX_CALL_CENTRE:
                    dictAudience[kSendAlertV3FuncParamCallCenterKey] = @(YES);
                    break;
                    
                    default:
                    break;
                }
            
            if (defaultCell
                && ([self getTotalMembersInPrivateCell:defaultCell] > 0)) {
                
                [arrDefaultCellId addObject:defaultCell.objectId];
            }

        }
    }
    
    if(arrDefaultCellId.count > 0){
        
        dictAudience[kSendAlertV3FuncParamDefaultCellsKey] = arrDefaultCellId;
    }
    
    return dictAudience;
}

-(NSDictionary *)getAlertParams
{
    NSMutableDictionary *dictAlertParams = [NSMutableDictionary dictionary];
    
    dictAlertParams[kSendAlertV3FuncParamTitleKey] = [C411StaticHelper getAlertTypeStringUsingAlertType:self.alertType];
    dictAlertParams[kSendAlertV3FuncParamAlertIdKey] = @(self.alertType);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kDispatchMode]
        && self.alertType != AlertTypePhoto
        && (!self.strForwardedAlertId)) {
        
        dictAlertParams[kSendAlertV3FuncParamIsDispatchedKey] = @(YES);
        dictAlertParams[kSendAlertV3FuncParamLatKey] = @(self.dispatchLocation.latitude);
        dictAlertParams[kSendAlertV3FuncParamLongKey] = @(self.dispatchLocation.longitude);
    }
    else{
        CLLocationCoordinate2D currentLocationCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:NO].coordinate;
        dictAlertParams[kSendAlertV3FuncParamLatKey] = @(currentLocationCoordinate.latitude);
        dictAlertParams[kSendAlertV3FuncParamLongKey] = @(currentLocationCoordinate.longitude);
    }

    NSString *strAdditionalNote = [self.txtVuAdditionalNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(strAdditionalNote.length > 0){
        dictAlertParams[kSendAlertV3FuncParamAdditionalNoteKey] = strAdditionalNote;
    }
    
    NSDictionary *dictAlertAudience = [self getAudienceParams];
    dictAlertParams[kSendAlertV3FuncParamAudienceKey] = dictAlertAudience;
    
    if(dictAlertAudience[kSendAlertV3FuncParamGlobalKey]){
        ///Global audience is selected, add radius and metric params
        ///Set radius
        dictAlertParams[kSendAlertV3FuncParamMetricKey] = kSendAlertV3FuncMetricValueMiles;
        
        float patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];
        
        dictAlertParams[kSendAlertV3FuncParamRadiusKey] = @(patrolModeRadius);
    }
    
    if(self.strForwardedAlertId.length > 0){
        
        dictAlertParams[kSendAlertV3FuncParamTypeKey] = kPayloadAlertTypeNeedyForwarded;
        dictAlertParams[kSendAlertV3FuncParamFwdAlertIdKey] = self.strForwardedAlertId;
    }
    else{
        
        if(self.alertType == AlertTypePhoto){
            dictAlertParams[kSendAlertV3FuncParamTypeKey] = kPayloadAlertTypePhoto;
        }
        else if (self.alertType == AlertTypeVideo){
            dictAlertParams[kSendAlertV3FuncParamTypeKey] = kPayloadAlertTypeVideo;
        }
        else{
            dictAlertParams[kSendAlertV3FuncParamTypeKey] = kPayloadAlertTypeNeedy;
        }
        
    }
    
    return dictAlertParams;
}

-(void)dismissPopup
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
 *This will map the table rowindex with the Macros defined for TABLE_ROW_INDEX in order to handle feature enabling/disabling
*/
-(void)initializeRowIndexMapping
{
    NSMutableArray *arrRowIndexMapping = [NSMutableArray array];
    NSInteger rowIndex = 0;
    arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_FAMILY);
    arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_FRIENDS);
    arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_COWORKERS);
    arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_SCHOOLMATES);
    arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_NEIGHBOURS);
#if NON_APP_USERS_ENABLED
    arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_NAU);
#endif
    arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_CELLS);
#if PATROL_FEATURE_ENABLED
    arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_GLOBAL_ALERT);
#endif
    if([C411AppDefaults canShowSecurityGuardOption]){
        
        arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_CALL_CENTRE);
    }
    
    self.arrRowIndexMapping = arrRowIndexMapping;
    
}

-(NSInteger )getMappedRowIndexFromVisibleRowIndex:(NSInteger)visibleRowIndex
{
    if(visibleRowIndex < self.arrRowIndexMapping.count){
        
        NSInteger mappedRowIndex = [self.arrRowIndexMapping[visibleRowIndex] integerValue];
        return mappedRowIndex;
    }
    return NSNotFound;
}

-(NSInteger )getVisibleRowIndexFromMappedRowIndex:(NSInteger)mappedRowIndex
{
    for (NSInteger visibleIndex = 0; visibleIndex < self.arrRowIndexMapping.count; visibleIndex++) {
        NSInteger mappedIndex = [self.arrRowIndexMapping[visibleIndex] integerValue];
        if(mappedIndex == mappedRowIndex){
            
            return visibleIndex;
        }
    }
    return NSNotFound;
}

-(NSString *)getAlertAudienceKeyForRowIndex:(NSInteger)rowIndex
{
    switch (rowIndex) {
        case TABLE_ROW_INDEX_FAMILY:
            return kAlertAudienceFamilyKey;
        case TABLE_ROW_INDEX_FRIENDS:
            return kAlertAudienceFriendsKey;
        case TABLE_ROW_INDEX_COWORKERS:
            return kAlertAudienceCoworkersKey;
        case TABLE_ROW_INDEX_SCHOOLMATES:
            return kAlertAudienceSchoolmatesKey;
        case TABLE_ROW_INDEX_NEIGHBOURS:
            return kAlertAudienceNeighboursKey;
        case TABLE_ROW_INDEX_NAU:
            return kAlertAudienceNauKey;
        case TABLE_ROW_INDEX_CELLS:
            return kAlertAudienceCellsKey;
        case TABLE_ROW_INDEX_GLOBAL_ALERT:
            return kAlertAudienceGlobalKey;
        case TABLE_ROW_INDEX_CALL_CENTRE:
            return kAlertAudienceCallCentreKey;
        default:
            return nil;
    }
}

-(NSInteger)getTotalMembersInPrivateCell:(PFObject *)cell
{
    if(cell){
        NSInteger totalCellMembers = [cell[kCellMembersKey]count] + [cell[kCellNauMembersKey]count];
        if([C411AppDefaults canShowSecurityGuardOption]){
            ///Add 1 for security guards option
            totalCellMembers+= 1;
        }

        return totalCellMembers;
    }
    return 0;
}

#if NON_APP_USERS_ENABLED
-(void)showNauSelectionScreen
{
    C411NonAppUsersSelectionVC *nonAppUserSelectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411NonAppUsersSelectionVC"];
    nonAppUserSelectionVC.alertSettings = self.alertSettings;
    nonAppUserSelectionVC.delegate = self;
    [self.navigationController pushViewController:nonAppUserSelectionVC animated:YES];
}
#endif

-(void)showCellsSelectionPopup
{
    self.vuCellsSelectionPopup.hidden = NO;
}

-(void)sendAlert
{
    if(![self isAnyAudienceSelected]){
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Please select any audience", nil)];
        return;
    }
    if(self.alertType == AlertTypeGeneral){
        NSString *strAdditionalNote = [self.txtVuAdditionalNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(strAdditionalNote.length > 0){
            [self.delegate sendAlertWithParams:[self getAlertParams]];
            [self dismissPopup];
        }
        else{
            [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Please enter description", nil)];
        }
    }
    else{
        [self.delegate sendAlertWithParams:[self getAlertParams]];
        [self dismissPopup];
    }
}

-(void)sendAlertOnLocationUpdate
{
    ///Show progress hud to let user wait until his/her location is retrieved
    self.locationRetrievalProgressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.locationRetrievalProgressHud.labelText = NSLocalizedString(@"Retrieving Location", nil);
    self.locationRetrievalProgressHud.removeFromSuperViewOnHide = YES;
    
    ///Set ivar to send alert on location update
    self.sendAlertOnLocationUpdate = YES;
    
    ///Add location updated observer to send out the alert
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(locationManagerDidUpdateLocation:) name:kLocationUpdatedNotification object:nil];
    
    ///Add observer for app coming to foreground
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cell411AppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnSendTapped:(UIButton *)sender {
    
    if([[C411LocationManager sharedInstance]isLocationAccessAllowed]){
        ///Check if current location is updated or not, if not then wait for location update before sending out the alert
        if([[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:NO]){
            ///Current location is available, send out the alert
            [self sendAlert];
        }
        else{
            ///Current location is not available, so wait for location update to send an alert
            [self sendAlertOnLocationUpdate];
        }
    }
    else{
        ///Location access is denied, show enable location popup
        __weak typeof(self) weakSelf = self;
        [[C411LocationManager sharedInstance]showEnableLocationPopupWithCustomMessagePrefix:nil cancelActionHandler:^(id action, NSInteger actionIndex, id customObject) {
            ///Show cannot send alert toast
            [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Cannot send an alert without location access.", nil)];
        } andSettingsActionHandler:^(id action, NSInteger actionIndex, id customObject) {
            
            [weakSelf sendAlertOnLocationUpdate];
        }];
    }
}

- (IBAction)btnCancelTapped:(UIButton *)sender {
    
    [self dismissPopup];
    
}

- (IBAction)btnCloseTapped:(UIButton *)sender {
    
    [self dismissPopup];

}

-(void)tglBtnAudienceSelectionTapped:(UIButton *)sender {
    
    NSInteger rowIndex = sender.tag;
    NSString *strSelectedAlertAudienceKey = [self getAlertAudienceKeyForRowIndex:rowIndex];
    if(strSelectedAlertAudienceKey.length > 0){
        BOOL shouldSelect = !sender.isSelected;
        if(shouldSelect){
               ///User is trying to select Audience
               if([strSelectedAlertAudienceKey isEqualToString:kAlertAudienceNauKey]){
                   if([self.alertSettings getSelectedNauMembers].count > 0){
                       ///There are already some NAUs selected previously, so let the user select SMS/Email option without showing the NAU selection screen
                       ///Update selection
                       [self.alertSettings toggleAudienceSelection:!sender.isSelected forKey:strSelectedAlertAudienceKey];
                       
                       ///Reload data
                       [self.tblVuAlertAudiences reloadData];
                   }
                   else{
                      ///User is trying to select SMS/Email option but he has not selected any NAU previously, so keep this selection and show the NAU selection screen to let him choose some NAU first
                       self.selectNauOnNonZeroVal = YES;
#if NON_APP_USERS_ENABLED
                       [self showNauSelectionScreen];
#endif
                   }
                   
               }
               else if([strSelectedAlertAudienceKey isEqualToString:kAlertAudienceCellsKey]){
                   if(self.selectedCellsMembersCount > 0){
                       ///There are already some private or public cells selected previously, so let the user select Cells option without showing the Cells selection screen
                       ///Update selection
                       [self.alertSettings toggleAudienceSelection:!sender.isSelected forKey:strSelectedAlertAudienceKey];
                       
                       ///Reload data
                       [self.tblVuAlertAudiences reloadData];
                   }
                   else{
                       ///User is trying to select Cells option but he has not selected any private or public cells previously, so keep this selection and show the Cells selection screen to let him choose some private or public cells first
                       self.selectCellsOnNonZeroVal = YES;
                       [self showCellsSelectionPopup];

                   }
               }
               else{
                   ///User is trying to select some other audience
                   ///Update selection
                   [self.alertSettings toggleAudienceSelection:!sender.isSelected forKey:strSelectedAlertAudienceKey];
                   
                   ///Reload data
                   [self.tblVuAlertAudiences reloadData];
               }
            
        }
        else{
            ///Update selection
            [self.alertSettings toggleAudienceSelection:!sender.isSelected forKey:strSelectedAlertAudienceKey];
            
            ///Reload data
            [self.tblVuAlertAudiences reloadData];
        }
        
    }
}

#if PATROL_FEATURE_ENABLED
-(void)btnGlobalAlertInfoTapped:(UIButton *)sender{
    if(self.isGlobalAlertDataFetched
       && !self.isGlobalAlertEnabled
       && self.dictPrivilegeResult){
        ///Prepare the info
        NSString *strMessage = NSLocalizedString(@"1. Make at least 2 friends\n2. Join at least 2 Public Cells\n3. Your profile must be 80% complete\n4. One week should pass since signing up", nil);
        
        NSArray *arrIncompleteConditions = self.dictPrivilegeResult[@"incompleteConditions"];
        if(arrIncompleteConditions.count > 0){
            strMessage = [strMessage stringByAppendingFormat:@"\n\n%@",NSLocalizedString(@"Requirements not yet met for Global Alert privileges:", nil)];
            for (NSString *strConditions in arrIncompleteConditions) {
                if([strConditions isEqualToString:@"Friends"]){
                    strMessage = [strMessage stringByAppendingFormat:NSLocalizedString(@"\n- number of friends in %@", nil),LOCALIZED_APP_NAME];
                }
                else if([strConditions isEqualToString:@"Cell join request"]){
                    strMessage = [strMessage stringByAppendingString:NSLocalizedString(@"\n- number of Public Cells joined so far", nil)];
                }
                else if([strConditions isEqualToString:@"Profile Completeness"]){
                    NSInteger profileCompleteness = [self.dictPrivilegeResult[@"profileCompleteness"][@"total"]integerValue];
                    strMessage = [strMessage stringByAppendingFormat:NSLocalizedString(@"\n- profile status only %d%% complete", nil),(int)profileCompleteness];
                    
                }
                else if([strConditions isEqualToString:@"Signup time"]){
                    strMessage = [strMessage stringByAppendingFormat:NSLocalizedString(@"\n- time passed since signing up to %@", nil),LOCALIZED_APP_NAME];
                    
                }
            }
        }
        ///Show the message
        [C411StaticHelper showAlertWithTitle:NSLocalizedString(@"Global alert requirements", nil) message:strMessage onViewController:nil];
    }
}
#endif

//****************************************************
#pragma mark - UITableViewDataSource and Delegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrRowIndexMapping.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCellId = @"C411AlertAudienceCell";
    C411AlertAudienceCell *alertAudienceCell = [tableView dequeueReusableCellWithIdentifier:strCellId];
    [self tableView:tableView configureCell:alertAudienceCell atIndexPath:indexPath];
    return alertAudienceCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    NSInteger mappedRowIndex = [self getMappedRowIndexFromVisibleRowIndex:rowIndex];
    if(mappedRowIndex == TABLE_ROW_INDEX_NAU){
        
        ///Push detail screen
#if NON_APP_USERS_ENABLED
        [self showNauSelectionScreen];
#endif
        
    }
    else if(mappedRowIndex == TABLE_ROW_INDEX_CELLS
            && self.isPrivateCellsDataInitialized
            && self.isPublicCellsDataInitialized){
        
        ///Set current selection state of Cells Audience Option
        self.wasCellsAudienceSelected = [self.alertSettings isAudienceSelected:kAlertAudienceCellsKey];
         ///Show Cells selection screen
        [self showCellsSelectionPopup];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//**************************************************************
#pragma mark - - tableView:cellForRowAtIndexPath Helper Methods
//**************************************************************
-(void)tableView:(UITableView *)tableView configureCell:(C411AlertAudienceCell *)alertAudienceCell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    NSInteger mappedRowIndex = [self getMappedRowIndexFromVisibleRowIndex:rowIndex];
    ///Hide the info icon by default
    alertAudienceCell.btnInfo.hidden = YES;
    NSString *strAlertAudienceKey = [self getAlertAudienceKeyForRowIndex:mappedRowIndex];
    alertAudienceCell.tglBtnAudienceSelection.selected = (strAlertAudienceKey.length > 0) ? [self.alertSettings isAudienceSelected:strAlertAudienceKey] : NO;
    
    if(mappedRowIndex == TABLE_ROW_INDEX_FAMILY
       || mappedRowIndex == TABLE_ROW_INDEX_COWORKERS
       || mappedRowIndex == TABLE_ROW_INDEX_SCHOOLMATES
       || mappedRowIndex == TABLE_ROW_INDEX_NEIGHBOURS){
        
        ///Render default cells
        ///Hide the selected counter
        [alertAudienceCell hideCounter:YES];
        alertAudienceCell.accessoryType = UITableViewCellAccessoryNone;
        
        PFObject *defaultCell = nil;
        
        switch (mappedRowIndex) {
            case TABLE_ROW_INDEX_FAMILY:
                alertAudienceCell.lblAudienceType.text = NSLocalizedString(@"Family", nil);
                defaultCell = [self.dictDefaultCells objectForKey:@(PrivateCellTypeFamily)];
                break;
                
            case TABLE_ROW_INDEX_COWORKERS:
                alertAudienceCell.lblAudienceType.text = NSLocalizedString(@"Coworkers", nil);
                defaultCell = [self.dictDefaultCells objectForKey:@(PrivateCellTypeCoworkers)];
                break;
                
            case TABLE_ROW_INDEX_SCHOOLMATES:
                alertAudienceCell.lblAudienceType.text = NSLocalizedString(@"Schoolmates", nil);
                defaultCell = [self.dictDefaultCells objectForKey:@(PrivateCellTypeSchoolmates)];
                break;
                
            case TABLE_ROW_INDEX_NEIGHBOURS:
                alertAudienceCell.lblAudienceType.text = NSLocalizedString(@"Neighbours", nil);
                defaultCell = [self.dictDefaultCells objectForKey:@(PrivateCellTypeNeighbours)];
                break;
                
            default:
                break;
        }
        
        
        if(defaultCell){
            
            ///Get the members count
            NSInteger membersCount = [self getTotalMembersInPrivateCell:defaultCell];
            
            if(membersCount > 0){
                ///Enable Cell
                alertAudienceCell.audienceDisabled = NO;
            }
            else{
                
                ///Disable cell
                alertAudienceCell.audienceDisabled = YES;
                alertAudienceCell.tglBtnAudienceSelection.selected = NO;
                
            }
            
        }
        else{
            
            ///Could be the case that default cells are not fetched, so let it be enabled as user could be in emergency
            alertAudienceCell.audienceDisabled = NO;
            
        }
    }
    else if(mappedRowIndex == TABLE_ROW_INDEX_FRIENDS){
        
        ///Hide the selected counter
        [alertAudienceCell hideCounter:YES];
        alertAudienceCell.accessoryType = UITableViewCellAccessoryNone;
        
        alertAudienceCell.lblAudienceType.text = NSLocalizedString(@"Friends", nil);
        
        if([C411AppDefaults sharedAppDefaults].arrFriends.count > 0){
            
            ///Enable Cell
            alertAudienceCell.audienceDisabled = NO;
            
        }
        else{
            
            ///No friends available, so disable this option
            alertAudienceCell.audienceDisabled = YES;
            alertAudienceCell.tglBtnAudienceSelection.selected = NO;
            
        }
    }
#if NON_APP_USERS_ENABLED
    else if(mappedRowIndex == TABLE_ROW_INDEX_NAU){
        
        alertAudienceCell.lblAudienceType.text = NSLocalizedString(@"SMS/Email", nil);
        ///Show the selected counter
        [alertAudienceCell hideCounter:YES];
        alertAudienceCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        alertAudienceCell.audienceDisabled = NO;
        
        if(alertAudienceCell.tglBtnAudienceSelection.isSelected){
            ///Deselect if there is no selected NAU member
            NSArray *arrSelectedNauMembers = [self.alertSettings getSelectedNauMembers];
            if(!arrSelectedNauMembers || arrSelectedNauMembers.count == 0){
                alertAudienceCell.tglBtnAudienceSelection.selected = NO;
            }
        }
        
    }
#endif
    else if(mappedRowIndex == TABLE_ROW_INDEX_CELLS){
        
        alertAudienceCell.lblAudienceType.text = NSLocalizedString(@"Cells", nil);
        alertAudienceCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        alertAudienceCell.audienceDisabled = NO;
        
        if(self.isMembersCountFetched){
            NSString *strSuffix = self.selectedCellsMembersCount == 1 ? NSLocalizedString(@"user", nil) : NSLocalizedString(@"users", nil);
            alertAudienceCell.lblCounter.text = [NSString localizedStringWithFormat:@"%d %@",(int)self.selectedCellsMembersCount, strSuffix];
            ///Show the selected counter
            [alertAudienceCell hideCounter:NO];
            
            if(alertAudienceCell.tglBtnAudienceSelection.isSelected){
                ///Deselect if there is selectedCellsMembersCount is 0
                if(self.selectedCellsMembersCount == 0){
                    alertAudienceCell.tglBtnAudienceSelection.selected = NO;
                }
            }
        }
        else{
            ///Hide the selected counter
            [alertAudienceCell hideCounter:YES];
        }
        
    }
#if PATROL_FEATURE_ENABLED
    else if(mappedRowIndex == TABLE_ROW_INDEX_GLOBAL_ALERT){
        
        ///Hide the selected counter
        [alertAudienceCell hideCounter:YES];
        alertAudienceCell.lblAudienceType.text = NSLocalizedString(@"Global Alert", nil);
        alertAudienceCell.accessoryType = UITableViewCellAccessoryNone;
        if(self.isGlobalAlertDataFetched){
            alertAudienceCell.audienceDisabled = !self.isGlobalAlertEnabled;
            
            if(self.isGlobalAlertEnabled){
                ///hide the info button
                alertAudienceCell.btnInfo.hidden = YES;
            }
            else{
                ///Show the inco button
                alertAudienceCell.btnInfo.hidden = NO;
                ///Add target
                [alertAudienceCell.btnInfo addTarget:self action:@selector(btnGlobalAlertInfoTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                ///Enable the user interaction so user can tap on info button
                alertAudienceCell.userInteractionEnabled = YES;
                
                ///Deselect the Global alert option if it's selected
                if(alertAudienceCell.tglBtnAudienceSelection.isSelected){
                    alertAudienceCell.tglBtnAudienceSelection.selected = NO;
                }
            }
        }
        else if (!alertAudienceCell.tglBtnAudienceSelection.isSelected){
            ///Disable the audience until data is fetched
            alertAudienceCell.audienceDisabled = YES;
            
            ///Hide the info button as well
            alertAudienceCell.btnInfo.hidden = YES;

        }
        else{
            ///Let the audience enabled until data is fetched as it was earlier selected
            alertAudienceCell.audienceDisabled = NO;
            
            ///Hide the info button
            alertAudienceCell.btnInfo.hidden = YES;

        }
//        PFUser *currentUser = [AppDelegate getLoggedInUser];
//        NSString *strPrivilege = currentUser[kUserPrivilegeKey];
//        alertAudienceCell.audienceDisabled = [strPrivilege isEqualToString:kPrivilegeTypeFirst] ? YES : NO;
        
    }
#endif
    else if(mappedRowIndex == TABLE_ROW_INDEX_CALL_CENTRE){
        
        ///Hide the selected counter
        [alertAudienceCell hideCounter:YES];
        alertAudienceCell.lblAudienceType.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ Call Centre",nil),LOCALIZED_APP_NAME];
        alertAudienceCell.accessoryType = UITableViewCellAccessoryNone;
        alertAudienceCell.audienceDisabled = YES;
        
    }
    alertAudienceCell.tglBtnAudienceSelection.tag = mappedRowIndex;
    [alertAudienceCell.tglBtnAudienceSelection addTarget:self action:@selector(tglBtnAudienceSelectionTapped:) forControlEvents:UIControlEventTouchUpInside];
}

#if NON_APP_USERS_ENABLED
//****************************************************
#pragma mark - C411NonAppUsersSelectionVCDelegate Methods
//****************************************************
-(void)nonAppUsersSelectionVC:(C411NonAppUsersSelectionVC *)nonAppUsersSelectionVC didSelectNonAppUsers:(NSArray *)arrContacts
{
    [self.alertSettings updateSelectedNauMembers:arrContacts];
    
    BOOL isDirty = NO;
    if(arrContacts.count > 0){
        if(self.shouldSelectNauOnNonZeroVal){
            [self.alertSettings toggleAudienceSelection:YES forKey:kAlertAudienceNauKey];
            isDirty = YES;
        }
    }
    else{
        [self.alertSettings toggleAudienceSelection:NO forKey:kAlertAudienceNauKey];
        isDirty = YES;
    }
    
    ///Reset flag
    self.selectNauOnNonZeroVal = NO;
    ///Update UI
    if(isDirty){
        NSInteger nauVisibleIndex = [self getVisibleRowIndexFromMappedRowIndex:TABLE_ROW_INDEX_NAU];
        [self.tblVuAlertAudiences reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:nauVisibleIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}
#endif

//****************************************************
#pragma mark - C411CellsSelectionPopupDelegate Methods
//****************************************************

-(void)incrementTotalMembersCountBy:(NSInteger)incrementVal
{
    NSInteger totalMembers = self.selectedCellsMembersCount + incrementVal;
    if(totalMembers > 0
       && (self.wasCellsAudienceSelected
           || self.shouldSelectCellsOnNonZeroVal)){
        ///Some cells selected, so select the option as user was attempting to select it or it was already selected
        [self.alertSettings toggleAudienceSelection:YES forKey:kAlertAudienceCellsKey];
    }
    [self updateSelectedCellsMembersCount:totalMembers];
}

-(void)decrementTotalMembersCountBy:(NSInteger)decrementVal
{
    NSInteger totalMembers = self.selectedCellsMembersCount - decrementVal;
    if(totalMembers == 0){
        ///No cells selected, so deselect the option
        [self.alertSettings toggleAudienceSelection:NO forKey:kAlertAudienceCellsKey];
    }
    [self updateSelectedCellsMembersCount:totalMembers];
 
}

-(void)cellsSelectionPopupDidTappedBack
{
    ///Reset flags
    self.selectCellsOnNonZeroVal = NO;
    self.wasCellsAudienceSelected = NO;
}

//****************************************************
#pragma mark - UITextViewDelegate Methods
//****************************************************

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    float yOffset = self.kbHeight;
    if (yOffset >= 0) {
        
        float underBarPadding = 0;
        [self.scrlVuBase setContentOffset:CGPointMake(self.scrlVuBase.contentOffset.x,yOffset - underBarPadding) animated:YES];
        
    }
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    ///Toggle Place holder visibility
    if (finalString && finalString.length > 0) {
        ///Hide Placeholder string
        if (textView == self.txtVuAdditionalNote) {
            
            self.lblAdditionalNotePlaceholder.hidden = YES;
            
        }
    }
    else{
        ///Show Placeholder string
        if (textView == self.txtVuAdditionalNote) {
            
            self.lblAdditionalNotePlaceholder.hidden = NO;
            
        }
    }
    
    return YES;
    
}



//****************************************************
#pragma mark - Notifications
//****************************************************

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize _kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.kbHeight = _kbSize.width > _kbSize.height ? _kbSize.height : _kbSize.width;
    //      _scrlVu_Base.contentSize = CGSizeMake(_scrlVu_Base.bounds.size.width, _scrlVu_Base.bounds.size.height + kbHeight);
    self.cnsPlaceholderVuBS.constant = self.kbHeight;
    
}

-(void)keyboardWillHide:(NSNotification *)note
{
    self.cnsPlaceholderVuBS.constant = 0;
    
}

-(void)friendListUpdated:(NSNotification *)notif
{
    NSInteger friendsVisibleIndex = [self getVisibleRowIndexFromMappedRowIndex:TABLE_ROW_INDEX_FRIENDS];
    [self.tblVuAlertAudiences reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:friendsVisibleIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)locationManagerDidUpdateLocation:(NSNotification *)notif
{
    if(self.shouldSendAlertOnLocationUpdate){
        ///Set this flag to no to avoid sending multile alerts
        self.sendAlertOnLocationUpdate = NO;
        
        ///remove the notification observer
        [[NSNotificationCenter defaultCenter]removeObserver:self name:kLocationUpdatedNotification object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        
        ///Remove the progress hud
        [self.locationRetrievalProgressHud hide:YES];
        self.locationRetrievalProgressHud = nil;
        
        ///send the alert now
        [self sendAlert];

    }
}

-(void)cell411AppWillEnterForeground:(NSNotification *)notif
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.shouldSendAlertOnLocationUpdate
            && (![[C411LocationManager sharedInstance] isLocationAccessAllowed])) {
            ///Reset the alert sending flag
            weakSelf.sendAlertOnLocationUpdate = NO;
            
            ///remove the notification observer
            [[NSNotificationCenter defaultCenter]removeObserver:weakSelf name:kLocationUpdatedNotification object:nil];
            [[NSNotificationCenter defaultCenter]removeObserver:weakSelf name:UIApplicationWillEnterForegroundNotification object:nil];
            
            ///Remove the progress hud
            [weakSelf.locationRetrievalProgressHud hide:YES];
            weakSelf.locationRetrievalProgressHud = nil;
            
            ///Show cannot send alert toast
            [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Cannot send an alert without location access.", nil)];
        }
        
    });
    
}


-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
