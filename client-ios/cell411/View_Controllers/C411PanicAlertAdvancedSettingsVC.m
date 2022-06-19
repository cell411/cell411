//
//  C411PanicAlertAdvancedSettingsVC.m
//  cell411
//
//  Created by Milan Agarwal on 26/08/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411PanicAlertAdvancedSettingsVC.h"
#import "C411PanicAlertSettings.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411PanicAlertRecipientCellsSelectionVC.h"
#import "MAAlertPresenter.h"
#import "C411ColorHelper.h"

@interface C411PanicAlertAdvancedSettingsVC ()<UITextFieldDelegate,C411PanicAlertRecipientCellsSelectionVCDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuWaitTimeContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblWaitTimeTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnInstant;
@property (weak, nonatomic) IBOutlet UILabel *lblInstant;
@property (weak, nonatomic) IBOutlet UIButton *btn5Sec;
@property (weak, nonatomic) IBOutlet UILabel *lbl5Sec;
@property (weak, nonatomic) IBOutlet UIButton *btn10Sec;
@property (weak, nonatomic) IBOutlet UILabel *lbl10Sec;

@property (weak, nonatomic) IBOutlet UIView *vuAlertRecipientSelectionContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertRecipientTitle;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnAllFriends;
@property (weak, nonatomic) IBOutlet UILabel *lblAllFriends;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnNearBy;
@property (weak, nonatomic) IBOutlet UILabel *lblNearBy;
@property (weak, nonatomic) IBOutlet UIButton *btnNearByToggleActionHandler;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnPrivateCell;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivateCell;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnPublicCell;
@property (weak, nonatomic) IBOutlet UILabel *lblPublicCell;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivateCellSelectionCount;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuPrivateCellDisclosureIndicator;
@property (weak, nonatomic) IBOutlet UILabel *lblPublicCellSelectionCount;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuPublicCellDisclosureIndicator;

@property (weak, nonatomic) IBOutlet UIView *vuAdditionalNoteContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNoteTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtAdditionalNote;
@property (weak, nonatomic) IBOutlet UIView *vuAdditionalNoteSeparator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlVuBase;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAdditionalNoteContainerBS;

- (IBAction)btnPanicAlertWaitTimeSelected:(UIButton *)sender;
- (IBAction)btnAllFriendsToggled:(UIButton *)sender;
- (IBAction)btnNearByToggled:(UIButton *)sender;
- (IBAction)btnPrivateCellToggled:(UIButton *)sender;
- (IBAction)btnPublicCellToggled:(UIButton *)sender;
- (IBAction)btnSelectPrivateCellsTapped:(UIButton *)sender;
- (IBAction)btnSelectPublicCellsTapped:(UIButton *)sender;

@property (nonatomic, strong) C411PanicAlertSettings *panicAlertSettings;

///Property for scroll management
@property (nonatomic, assign)float kbHeight;
@property (nonatomic, assign) CGFloat scrlVuInitialBLConstarintValue;

@end

@implementation C411PanicAlertAdvancedSettingsVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    [self setInitialSettings];
    
    [self registerForNotifications];
    
    ///set initial bottom constraint of scrollview
    self.scrlVuInitialBLConstarintValue = self.cnsAdditionalNoteContainerBS.constant;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self unregisterNotifications];
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

-(C411PanicAlertSettings *)panicAlertSettings
{
    if (!_panicAlertSettings) {
        
        _panicAlertSettings = [C411PanicAlertSettings getPanicAlertSettings];
        
    }
    
    return _panicAlertSettings;
    
}
//****************************************************
#pragma mark - Overridden Methods
//****************************************************
-(void)mag_viewDidBack {
    [super mag_viewDidBack];
    ///save Panic alert settings
    [self.panicAlertSettings saveSettings];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    self.title = NSLocalizedString(@"Advance Settings", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    ///set corner radius of options container
    self.vuWaitTimeContainer.layer.cornerRadius = 3.0;
    self.vuWaitTimeContainer.layer.masksToBounds = YES;
    self.vuAlertRecipientSelectionContainer.layer.cornerRadius = 3.0;
    self.vuAlertRecipientSelectionContainer.layer.masksToBounds = YES;
    self.vuAdditionalNoteContainer.layer.cornerRadius = 3.0;
    self.vuAdditionalNoteContainer.layer.masksToBounds = YES;

    self.btnInstant.layer.borderWidth = 2.0;
    [C411StaticHelper makeCircularView:self.btnInstant];
    
    self.btn5Sec.layer.borderWidth = 2.0;
    [C411StaticHelper makeCircularView:self.btn5Sec];
    
    self.btn10Sec.layer.borderWidth = 2.0;
    [C411StaticHelper makeCircularView:self.btn10Sec];
    
#if (!PATROL_FEATURE_ENABLED)
    
    ///Hide nearby option
    self.lblNearBy.hidden = YES;
    self.tglBtnNearBy.hidden = YES;
    self.btnNearByToggleActionHandler.hidden = YES;

#endif

    ///Set Additional Note Placeholder
    self.txtAdditionalNote.placeholder = NSLocalizedString(@"Additional Note", nil);
    
    [self applyColors];
}

-(void)applyColors {
    ///Set Background Color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set background color on option containers
    UIColor *containerBGColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuWaitTimeContainer.backgroundColor = containerBGColor;
    self.vuAlertRecipientSelectionContainer.backgroundColor = containerBGColor;
    self.vuAdditionalNoteContainer.backgroundColor = containerBGColor;
    
    ///Set separator color
    self.vuAdditionalNoteSeparator.backgroundColor = [C411ColorHelper sharedInstance].separatorColor;
    
    ///Set container title colors
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblWaitTimeTitle.textColor = primaryTextColor;
    self.lblAlertRecipientTitle.textColor = primaryTextColor;
    self.lblAdditionalNoteTitle.textColor = primaryTextColor;
    self.lblInstant.textColor = primaryTextColor;
    self.lbl5Sec.textColor = primaryTextColor;
    self.lbl10Sec.textColor = primaryTextColor;
    self.txtAdditionalNote.textColor = primaryTextColor;
    
    ///Set container subtitle colors
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblAllFriends.textColor = secondaryTextColor;
    self.lblNearBy.textColor = secondaryTextColor;
    self.lblPrivateCell.textColor = secondaryTextColor;
    self.lblPublicCell.textColor = secondaryTextColor;
    self.lblPrivateCellSelectionCount.textColor = secondaryTextColor;
    self.lblPublicCellSelectionCount.textColor = secondaryTextColor;
    self.tglBtnAllFriends.tintColor = secondaryTextColor;
    self.tglBtnNearBy.tintColor = secondaryTextColor;
    self.tglBtnPrivateCell.tintColor = secondaryTextColor;
    self.tglBtnPublicCell.tintColor = secondaryTextColor;
    
    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnInstant.tintColor = themeColor;
    self.btnInstant.layer.borderColor = themeColor.CGColor;
    self.btn5Sec.tintColor = themeColor;
    self.btn5Sec.layer.borderColor = themeColor.CGColor;
    self.btn10Sec.tintColor = themeColor;
    self.btn10Sec.layer.borderColor = themeColor.CGColor;
    
    ///Set primaryBGText Color
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.btnInstant.backgroundColor = primaryBGTextColor;
    self.btn5Sec.backgroundColor = primaryBGTextColor;
    self.btn10Sec.backgroundColor = primaryBGTextColor;
    
    ///Set disabled text color
    UIColor *disabledTextColor = [C411ColorHelper sharedInstance].disabledTextColor;
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtAdditionalNote];

    ///Set hint icon color
    UIColor *hintIconColor = [C411ColorHelper sharedInstance].hintIconColor;
    self.imgVuPrivateCellDisclosureIndicator.tintColor = hintIconColor;
    self.imgVuPublicCellDisclosureIndicator.tintColor = hintIconColor;
}

-(void)setInitialSettings{
    
    ///Select the wait time button
    if (self.panicAlertSettings.waitTime == PanicWaitTimeInstant) {
        
        [self selectWaitTimeButton:self.btnInstant];
    }
    else if(self.panicAlertSettings.waitTime == PanicWaitTime5Sec){
        [self selectWaitTimeButton:self.btn5Sec];
        
    }
    else if(self.panicAlertSettings.waitTime == PanicWaitTime10Sec){
        
        [self selectWaitTimeButton:self.btn10Sec];
        
    }
    
    ///Set alert recipients
    ///1.Check all friends option
    NSDictionary *dictAllFriends = [self.panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientAllFriendsKey];
    if (dictAllFriends && [[dictAllFriends objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
        
        ///All friends option is selected
        self.tglBtnAllFriends.selected = YES;
        
    }
    else{
        
        ///2.Check for Private Cell option is selected or not. Both All Friends and Private Cell are Mutually Exclusive
        NSDictionary *dictPrivateCells = [self.panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientPrivateCellsMembersKey];
        if (dictPrivateCells && [[dictPrivateCells objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
            
            ///Private Cells option is selected
            self.tglBtnPrivateCell.selected = YES;
            
        }

        
    }
    
    ///3. Check for near by option
    NSDictionary *dictNearBy = [self.panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientNearMeKey];
    if (dictNearBy && [[dictNearBy objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
        
        ///Near me option is selected
        self.tglBtnNearBy.selected = YES;
        
    }
    
    ///4. Check for Public Cells option
    NSDictionary *dictPublicCells = [self.panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientPublicCellsMembersKey];
    if (dictPublicCells && [[dictPublicCells objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
        
        ///Public Cells option is selected
        self.tglBtnPublicCell.selected = YES;
        
    }

    ///Set selected count for Private Cells
    NSInteger selectedPrivateCellsCount = [self getSelectedPrivateCellCount];
    ///Make formatted string and set it on label
    self.lblPrivateCellSelectionCount.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d selected",nil),(int)selectedPrivateCellsCount];
    
    
    ///Set selected count for Public Cells
    NSInteger selectedPublicCellsCount = [self getSelectedPublicCellCount];
    
    ///Make formatted string and set it on label
    self.lblPublicCellSelectionCount.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d selected",nil),(int)selectedPublicCellsCount];
    
    
    ///Set Additional note if available
    self.txtAdditionalNote.text = self.panicAlertSettings.strAdditionalNote;
    
    
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];

}

-(void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


-(void)selectWaitTimeButton:(UIButton *)btnWaitTime
{
    ///select the button
    btnWaitTime.selected = YES;
    btnWaitTime.backgroundColor = [C411ColorHelper sharedInstance].themeColor;
    btnWaitTime.tintColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
}

-(void)deSelectWaitTimeButton:(UIButton *)btnWaitTime
{
    ///select the button
    btnWaitTime.selected = NO;
    btnWaitTime.backgroundColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    btnWaitTime.tintColor = [C411ColorHelper sharedInstance].themeColor;
}

-(void)showRecipientSelectionCellsVCWithSelectionType:(CellSelectionType)cellSelectionType
{
    ///Show the Cell Selection VC, if no cell is selected yet
    C411PanicAlertRecipientCellsSelectionVC *recipientCellsSelectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411PanicAlertRecipientCellsSelectionVC"];
    recipientCellsSelectionVC.cellSelectionType = cellSelectionType;
    NSMutableArray *arrSelectedCells = nil;
    
    if (cellSelectionType == CellSelectionTypePublic) {
        
        ///get the array of selected public cells id
        arrSelectedCells = [[[self.panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientPublicCellsMembersKey]objectForKey:kPanicAlertRecipientSelectedCellsKey]mutableCopy];
        
    }
    else if (cellSelectionType == CellSelectionTypePrivate) {
        
        ///get the array of selected private cells id
        arrSelectedCells = [[[self.panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientPrivateCellsMembersKey]objectForKey:kPanicAlertRecipientSelectedCellsKey]mutableCopy];
        
    }
    if (arrSelectedCells == nil) {
        
        arrSelectedCells = [NSMutableArray array];
    }
    recipientCellsSelectionVC.arrSelectedCells = arrSelectedCells;

    recipientCellsSelectionVC.delegate = self;
    [self.navigationController pushViewController:recipientCellsSelectionVC animated:YES];

}

-(NSInteger)getSelectedPrivateCellCount
{
    NSDictionary *dictPrivateCells = [self.panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientPrivateCellsMembersKey];
    NSInteger selectedPrivateCellsCount = 0;
    if (dictPrivateCells) {
        
        ///Get the array of the selected Private Cells
        NSArray *arrSelectedPrivateCells = [dictPrivateCells objectForKey:kPanicAlertRecipientSelectedCellsKey];
        if (arrSelectedPrivateCells) {
            
            selectedPrivateCellsCount = arrSelectedPrivateCells.count;
        }
        
        
    }

    return selectedPrivateCellsCount;
}

-(NSInteger)getSelectedPublicCellCount
{
    ///Set selected count for Public Cells
    NSDictionary *dictPublicCells = [self.panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientPublicCellsMembersKey];
    NSInteger selectedPublicCellsCount = 0;
    if (dictPublicCells) {
        
        ///Get the array of the selected Public Cells
        NSArray *arrSelectedPublicCells = [dictPublicCells objectForKey:kPanicAlertRecipientSelectedCellsKey];
        if (arrSelectedPublicCells) {
            
            selectedPublicCellsCount = arrSelectedPublicCells.count;
        }
        
        
    }
    
    return selectedPublicCellsCount;

}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnPanicAlertWaitTimeSelected:(UIButton *)sender {
    
    ///Select the tapped button
    [self selectWaitTimeButton:sender];
    
    ///Deselect the rest button
    if (sender == self.btnInstant) {
        
        [self deSelectWaitTimeButton:self.btn5Sec];
        [self deSelectWaitTimeButton:self.btn10Sec];
        
        self.panicAlertSettings.waitTime = PanicWaitTimeInstant;
 
    }
    else if (sender == self.btn5Sec) {
        
        [self deSelectWaitTimeButton:self.btnInstant];
        [self deSelectWaitTimeButton:self.btn10Sec];
        
        self.panicAlertSettings.waitTime = PanicWaitTime5Sec;
    }
    else if (sender == self.btn10Sec) {
        
        [self deSelectWaitTimeButton:self.btn5Sec];
        [self deSelectWaitTimeButton:self.btnInstant];
        
        self.panicAlertSettings.waitTime = PanicWaitTime10Sec;
        

    }
    
    ///save panic settings
    [self.panicAlertSettings saveSettings];

}

- (IBAction)btnAllFriendsToggled:(UIButton *)sender {
    
    /// get the mutable copy of the dictAlertRecipients
    NSMutableDictionary *dictAlertRecipients = [self.panicAlertSettings.dictAlertRecipients mutableCopy];
    ///get the mutable copy of all friends dictionary
    NSMutableDictionary *dictAllFriends = [[dictAlertRecipients objectForKey:kPanicAlertRecipientAllFriendsKey]mutableCopy];
    if (dictAllFriends == nil) {
        
        dictAllFriends = [NSMutableDictionary dictionary];
    }
    
    
    if (self.tglBtnAllFriends.isSelected) {
        
        ///User is trying to deselect the All Friends option
        self.tglBtnAllFriends.selected = NO;
        
    }
    else{
        
        ///User is trying to select the All friends option
        self.tglBtnAllFriends.selected = YES;
        

        ///Deselect the Private Cell option if selected as both are mutually exclusive to each other
        if (self.tglBtnPrivateCell.isSelected) {
            
            self.tglBtnPrivateCell.selected = NO;
            
            ///update panic settings for Private Cells
            ///get the mutable copy of Private Cells dictionary
            NSMutableDictionary *dictPrivateCells = [[dictAlertRecipients objectForKey:kPanicAlertRecipientPrivateCellsMembersKey]mutableCopy];
            if (dictPrivateCells == nil) {
                
                dictPrivateCells = [NSMutableDictionary dictionary];
            }

            [dictPrivateCells setObject:@(self.tglBtnPrivateCell.isSelected) forKey:kPanicAlertRecipientIsSelectedKey];
            [dictAlertRecipients setObject:dictPrivateCells forKey:kPanicAlertRecipientPrivateCellsMembersKey];

            
        }
        
 
    }
    
    
    ///update panic settings for all friends
    [dictAllFriends setObject:@(self.tglBtnAllFriends.isSelected) forKey:kPanicAlertRecipientIsSelectedKey];
    [dictAlertRecipients setObject:dictAllFriends forKey:kPanicAlertRecipientAllFriendsKey];
    self.panicAlertSettings.dictAlertRecipients = dictAlertRecipients;
    [self.panicAlertSettings saveSettings];

}

- (IBAction)btnNearByToggled:(UIButton *)sender {

#if PATROL_FEATURE_ENABLED

    self.tglBtnNearBy.selected = !self.tglBtnNearBy.isSelected;
    
    /// get the mutable copy of the dictAlertRecipients
    NSMutableDictionary *dictAlertRecipients = [self.panicAlertSettings.dictAlertRecipients mutableCopy];
    ///get the mutable copy of near me dictionary
    NSMutableDictionary *dictNearMe = [[dictAlertRecipients objectForKey:kPanicAlertRecipientNearMeKey]mutableCopy];
    if (dictNearMe == nil) {
        
        dictNearMe = [NSMutableDictionary dictionary];
    }
    
    if (self.tglBtnNearBy.isSelected) {
        
        ///User is trying to turn on the near by flag, show him warning first
        NSString *strLocalizedMessage = NSLocalizedString(@"By sending alerts to nearby users, strangers who are not your friends may receive these alerts.  Are you sure you want to alert strangers when issuing a panic alert?", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil) message:strLocalizedMessage preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            ///3.1 User cancelled, reset the button to unchek
            self.tglBtnNearBy.selected = NO;
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
            
            
        }];
        
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            ///update panic settings for near me
            [dictNearMe setObject:@(self.tglBtnNearBy.isSelected) forKey:kPanicAlertRecipientIsSelectedKey];
            [dictAlertRecipients setObject:dictNearMe forKey:kPanicAlertRecipientNearMeKey];
            self.panicAlertSettings.dictAlertRecipients = dictAlertRecipients;
            [self.panicAlertSettings saveSettings];

            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
            
        }];
        
        [alertController addAction:noAction];
        [alertController addAction:yesAction];
        //[self presentViewController:alertController animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];
    }
    else{
        ///User is trying to turn off the near by flag, let him do that
  
        ///update panic settings for near me
        [dictNearMe setObject:@(self.tglBtnNearBy.isSelected) forKey:kPanicAlertRecipientIsSelectedKey];
        [dictAlertRecipients setObject:dictNearMe forKey:kPanicAlertRecipientNearMeKey];
        self.panicAlertSettings.dictAlertRecipients = dictAlertRecipients;
        [self.panicAlertSettings saveSettings];

    }

#endif

}

- (IBAction)btnPrivateCellToggled:(UIButton *)sender {
   
    /// get the mutable copy of the dictAlertRecipients
    NSMutableDictionary *dictAlertRecipients = [self.panicAlertSettings.dictAlertRecipients mutableCopy];

    if (self.tglBtnPrivateCell.isSelected) {
        
        ///User is trying to deselect the Private Cells option
        self.tglBtnPrivateCell.selected = NO;
    }
    else{
        
        ///User is trying to select the Private Cells option
        self.tglBtnPrivateCell.selected = YES;
        
        ///Deselect the All Friends option if selected as both are mutually exclusive to each other
        if (self.tglBtnAllFriends.isSelected) {
            
            self.tglBtnAllFriends.selected = NO;
            
            ///get the mutable copy of all friends dictionary
            NSMutableDictionary *dictAllFriends = [[dictAlertRecipients objectForKey:kPanicAlertRecipientAllFriendsKey]mutableCopy];
            if (dictAllFriends == nil) {
                
                dictAllFriends = [NSMutableDictionary dictionary];
            }
            ///update panic settings for all friends
            [dictAllFriends setObject:@(self.tglBtnAllFriends.isSelected) forKey:kPanicAlertRecipientIsSelectedKey];
            [dictAlertRecipients setObject:dictAllFriends forKey:kPanicAlertRecipientAllFriendsKey];

        }
        
        ///Show the Cell Selection VC, if no cell is selected yet
        if ([self getSelectedPrivateCellCount] == 0) {
            
            [self showRecipientSelectionCellsVCWithSelectionType:CellSelectionTypePrivate];
            
        }
        
    }

    ///get the mutable copy of Private Cells dictionary
    NSMutableDictionary *dictPrivateCells = [[dictAlertRecipients objectForKey:kPanicAlertRecipientPrivateCellsMembersKey]mutableCopy];
    if (dictPrivateCells == nil) {
        
        dictPrivateCells = [NSMutableDictionary dictionary];
    }
    
    [dictPrivateCells setObject:@(self.tglBtnPrivateCell.isSelected) forKey:kPanicAlertRecipientIsSelectedKey];
    [dictAlertRecipients setObject:dictPrivateCells forKey:kPanicAlertRecipientPrivateCellsMembersKey];
    self.panicAlertSettings.dictAlertRecipients = dictAlertRecipients;
    [self.panicAlertSettings saveSettings];

}

- (IBAction)btnPublicCellToggled:(UIButton *)sender {
    
    
    if (self.tglBtnPublicCell.isSelected) {
        
        ///User is trying to deselect the Public Cells option
        self.tglBtnPublicCell.selected = NO;
    }
    else{
        
        ///User is trying to select the Public Cells option
        self.tglBtnPublicCell.selected = YES;
        
        ///Show the Cell Selection VC, if no cell is selected yet
        if ([self getSelectedPublicCellCount] == 0) {
            
            [self showRecipientSelectionCellsVCWithSelectionType:CellSelectionTypePublic];
            
        }
        
    }

    /// get the mutable copy of the dictAlertRecipients
    NSMutableDictionary *dictAlertRecipients = [self.panicAlertSettings.dictAlertRecipients mutableCopy];
    ///get the mutable copy of Public Cells dictionary
    NSMutableDictionary *dictPublicCells = [[dictAlertRecipients objectForKey:kPanicAlertRecipientPublicCellsMembersKey]mutableCopy];
    if (dictPublicCells == nil) {
        
        dictPublicCells = [NSMutableDictionary dictionary];
    }
    
    [dictPublicCells setObject:@(self.tglBtnPublicCell.isSelected) forKey:kPanicAlertRecipientIsSelectedKey];
    [dictAlertRecipients setObject:dictPublicCells forKey:kPanicAlertRecipientPublicCellsMembersKey];
    self.panicAlertSettings.dictAlertRecipients = dictAlertRecipients;
    [self.panicAlertSettings saveSettings];

}

- (IBAction)btnSelectPrivateCellsTapped:(UIButton *)sender {
    
    ///Show the Cell Selection VC
    [self showRecipientSelectionCellsVCWithSelectionType:CellSelectionTypePrivate];

}

- (IBAction)btnSelectPublicCellsTapped:(UIButton *)sender {

    ///Show the Cell Selection VC
    [self showRecipientSelectionCellsVCWithSelectionType:CellSelectionTypePublic];

}

//****************************************************
#pragma mark - C411PanicAlertRecipientCellsSelectionVCDelegate Methods
//****************************************************

-(void)cellSelectionVCDidTapBack:(C411PanicAlertRecipientCellsSelectionVC *)recipientCellsSelectionVC
{
    ///Update the Private and Public Cells data
    if (recipientCellsSelectionVC.cellSelectionType == CellSelectionTypePrivate) {
    
        ///1. Private Cell Handling
        
        ///Update the selected array of private cells and save it
        /// get the mutable copy of the dictAlertRecipients
        NSMutableDictionary *dictAlertRecipients = [self.panicAlertSettings.dictAlertRecipients mutableCopy];
        ///get the mutable copy of Private Cells dictionary
        NSMutableDictionary *dictPrivateCells = [[dictAlertRecipients objectForKey:kPanicAlertRecipientPrivateCellsMembersKey]mutableCopy];
        if (dictPrivateCells == nil) {
            
            dictPrivateCells = [NSMutableDictionary dictionary];
        }
        
        [dictPrivateCells setObject:recipientCellsSelectionVC.arrSelectedCells forKey:kPanicAlertRecipientSelectedCellsKey];
        
        ///get the private cells count
        NSInteger selectedPrivateCellsCount = recipientCellsSelectionVC.arrSelectedCells.count;
        if (selectedPrivateCellsCount == 0) {
            
            ///Deselect the Private cell checkbox if selected
            if (self.tglBtnPrivateCell.isSelected) {
                
                self.tglBtnPrivateCell.selected = NO;
                
                ///update panic settings for Private Cells
                [dictPrivateCells setObject:@(self.tglBtnPrivateCell.isSelected) forKey:kPanicAlertRecipientIsSelectedKey];
                
            }
            
        }
        ///Update the selected label
        self.lblPrivateCellSelectionCount.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d selected",nil),(int)selectedPrivateCellsCount];

        ///update panic settings for Private Cells
        [dictAlertRecipients setObject:dictPrivateCells forKey:kPanicAlertRecipientPrivateCellsMembersKey];
        self.panicAlertSettings.dictAlertRecipients = dictAlertRecipients;
        [self.panicAlertSettings saveSettings];

        
    }
    else if (recipientCellsSelectionVC.cellSelectionType == CellSelectionTypePublic){
       
        ///2. PublicCellHandling
        
        ///Update the selected array of public cells and save it
        /// get the mutable copy of the dictAlertRecipients
        NSMutableDictionary *dictAlertRecipients = [self.panicAlertSettings.dictAlertRecipients mutableCopy];
        ///get the mutable copy of Public Cells dictionary
        NSMutableDictionary *dictPublicCells = [[dictAlertRecipients objectForKey:kPanicAlertRecipientPublicCellsMembersKey]mutableCopy];
        if (dictPublicCells == nil) {
            
            dictPublicCells = [NSMutableDictionary dictionary];
        }
        
        [dictPublicCells setObject:recipientCellsSelectionVC.arrSelectedCells forKey:kPanicAlertRecipientSelectedCellsKey];

        ///get the public cells count
        NSInteger selectedPublicCellsCount = recipientCellsSelectionVC.arrSelectedCells.count;
        if (selectedPublicCellsCount == 0) {
            
            ///Deselect the Public cell checkbox if selected
            if (self.tglBtnPublicCell.isSelected) {
                
                self.tglBtnPublicCell.selected = NO;
                
                ///update panic settings for Public Cells
                [dictPublicCells setObject:@(self.tglBtnPublicCell.isSelected) forKey:kPanicAlertRecipientIsSelectedKey];

            }
            
        }
        
        
        ///Update the selected label
        self.lblPublicCellSelectionCount.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d selected",nil),(int)selectedPublicCellsCount];

        ///update panic settings for Public Cells
        [dictAlertRecipients setObject:dictPublicCells forKey:kPanicAlertRecipientPublicCellsMembersKey];
        self.panicAlertSettings.dictAlertRecipients = dictAlertRecipients;
        [self.panicAlertSettings saveSettings];

    }
    
}

//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    float yOffset = self.vuAdditionalNoteContainer.frame.origin.y;
    if (yOffset >= 0) {
        
        float underBarPadding = 0;
        [self.scrlVuBase setContentOffset:CGPointMake(self.scrlVuBase.contentOffset.x,yOffset - underBarPadding) animated:YES];
        
    }
    
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.panicAlertSettings.strAdditionalNote = self.txtAdditionalNote.text;
    [self.panicAlertSettings saveSettings];
    
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
    self.cnsAdditionalNoteContainerBS.constant = self.kbHeight + self.scrlVuInitialBLConstarintValue;
    
}

-(void)keyboardWillHide:(NSNotification *)note
{
    self.cnsAdditionalNoteContainerBS.constant = self.scrlVuInitialBLConstarintValue;
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
