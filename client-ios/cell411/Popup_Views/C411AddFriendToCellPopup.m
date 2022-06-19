//
//  C411AddFriendToCellPopup.m
//  cell411
//
//  Created by Milan Agarwal on 10/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411AddFriendToCellPopup.h"
#import "C411AlertGroupSelectionCell.h"
#import "C411AppDefaults.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@interface C411AddFriendToCellPopup ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITableView *tblVuCellGroups;
- (IBAction)btnOkTapped:(UIButton *)sender;
- (IBAction)btnCancelTapped:(UIButton *)sender;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation C411AddFriendToCellPopup

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

-(void)awakeFromNib
{
    [super awakeFromNib];

    ///Initialization code
    //self.tblVuCellGroups.contentInset = UIEdgeInsetsMake(-15, 0, 0, 0);
    ///register Nib for cell reuse identifier as we are using XIB for popup view and in XIB prototype cell creation is not supported, hence a separate XIB needs to be created and to be registered on tableview
    [self.tblVuCellGroups registerNib:[UINib nibWithNibName:@"C411AlertGroupSelectionCell" bundle:nil] forCellReuseIdentifier:@"C411AlertGroupSelectionCell"];
    
    [self registerForNotifications];
    
    ///All Friends will be selected by default
    self.selectedIndex = 0;
    
    [self configureViews];
    
    [C411StaticHelper removeOnScreenKeyboard];

}

-(void)dealloc
{
    self.arrCellGroups = nil;
    self.userFriend = nil;
    [self unregisterFromNotifications];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)registerForNotifications
{
    [super registerForNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cellsListUpdated:) name:kCellsListUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)setupViews
{
    NSString *strTitle = nil;
    
    NSString *strFirstName = self.userFriend[kUserFirstnameKey];
    strTitle = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"Your new friend", nil),strFirstName,NSLocalizedString(@"is not part of any Cell. Would you like to add this friend to a Cell?", nil)];
    self.lblTitle.text = strTitle;
    
}

-(void)configureViews
{
    [self.btnOk setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"Not Now", nil) forState:UIControlStateNormal];
    [self applyColors];
}

-(void)applyColors {
    ///set background color
    UIColor *lightCardColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.backgroundColor = lightCardColor;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblTitle.textColor = primaryTextColor;
    
    ///set secondary color
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    [self.btnCancel setTitleColor:secondaryColor forState:UIControlStateNormal];
    [self.btnOk setTitleColor:secondaryColor forState:UIControlStateNormal];
}


//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)btnOkTapped:(UIButton *)sender {
    
    
    PFObject *cell = [self.arrCellGroups objectAtIndex:self.selectedIndex];
    if (self.actionHandler != NULL) {
        ///call the Ok action handler
        self.actionHandler(sender,1,cell);
        
    }
    
    [self removeFromSuperview];
    self.actionHandler = NULL;

    
}

- (IBAction)btnCancelTapped:(UIButton *)sender {
    
    if (self.actionHandler != NULL) {
        ///call the Cancel action handler
        self.actionHandler(sender,0,nil);
        
    }
    
    [self removeFromSuperview];
    self.actionHandler = NULL;

}


//****************************************************
#pragma mark - UITableViewDataSource and delegate methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrCellGroups.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    
    static NSString * cellId = @"C411AlertGroupSelectionCell";
    C411AlertGroupSelectionCell *alertGroupCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSString *strCellName  = nil;
    
    PFObject *cell = [self.arrCellGroups objectAtIndex:rowIndex];
    
    strCellName = [C411StaticHelper getLocalizedNameForCell:cell];
    
    alertGroupCell.lblAlertRecievingGroupName.text = strCellName;
    if (self.selectedIndex == rowIndex) {
        alertGroupCell.radioBtnCellSelectionIndicator.selected = YES;
    }
    else{
        
        alertGroupCell.radioBtnCellSelectionIndicator.selected = NO;
    }
    
    return alertGroupCell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    self.selectedIndex = rowIndex;
    [self.tblVuCellGroups reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
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

-(void)cellsListUpdated:(NSNotification *)notif
{
    self.arrCellGroups = [C411AppDefaults sharedAppDefaults].arrCells;
    
    [self.tblVuCellGroups reloadData];
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
