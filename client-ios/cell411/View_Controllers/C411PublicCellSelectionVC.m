//
//  C411PublicCellSelectionVC.m
//  cell411
//
//  Created by Milan Agarwal on 11/02/16.
//  Copyright (c) 2016 Milan Agarwal. All rights reserved.
//

#import "C411PublicCellSelectionVC.h"
#import "C411AlertGroupSelectionCell.h"
#import "Constants.h"
#import "C411StaticHelper.h"
#import "C411AppDefaults.h"
#import "AppDelegate.h"
#import "ConfigConstants.h"
#import "C411ColorHelper.h"

@interface C411PublicCellSelectionVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuContentContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UITableView *tblVuPublicCell;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnIncludeSecurityGuards;
@property (weak, nonatomic) IBOutlet UILabel *lblIncludeSecurityGuards;
@property (weak, nonatomic) IBOutlet UIButton *btnIncludeSecurityGuards;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsIncludeSecurityGuardButtonHeight;
- (IBAction)btnOkTapped:(UIButton *)sender;
- (IBAction)btnCancelTapped:(UIButton *)sender;
- (IBAction)btnIncludeSecurityGuardToggled:(UIButton *)sender;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray *arrPublicCells;

@end

@implementation C411PublicCellSelectionVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///Remove top padding of 15 pixel
    self.tblVuPublicCell.contentInset = UIEdgeInsetsMake(-15, 0, 0, 0);

    self.lblAlertTitle.text = self.strAlertTitle;
    
    [self fetchPublicCells];
    
    ///Set dynamic name for call center
    self.lblIncludeSecurityGuards.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Include %@ Call Centre",nil),LOCALIZED_APP_NAME];

    if (![C411AppDefaults canShowSecurityGuardOption]) {
        
        ///hide the include security guard option
        self.tglBtnIncludeSecurityGuards.hidden = YES;
        self.lblIncludeSecurityGuards.hidden = YES;
        self.btnIncludeSecurityGuards.hidden = YES;
        self.cnsIncludeSecurityGuardButtonHeight.constant = 0;
    }
    else{
        
        ///enable/disable include security guard option as per the settings
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.tglBtnIncludeSecurityGuards.selected = [[defaults objectForKey:kIncludeSecurityGuards]boolValue];
        
        ///this option will always be enabled and user is not allowed to edit it so disable it's interaction
        self.btnIncludeSecurityGuards.enabled = NO;
        self.tglBtnIncludeSecurityGuards.alpha = 0.6;
        self.lblIncludeSecurityGuards.alpha = 0.6;
        
    }
    [self applyColors];
    [self registerForNotifications];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.delegate = nil;
    self.arrPublicCells = nil;
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
#pragma mark - Private Methods
//****************************************************

-(void)fetchPublicCells
{
    __weak typeof(self) weakself = self;
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *getPublicCellsQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
    [getPublicCellsQuery whereKey:kPublicCellMembersKey equalTo:currentUser];
    [getPublicCellsQuery whereKey:kPublicCellTotalMembersKey greaterThan:@1];
    [getPublicCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (!error) {
            
            weakself.arrPublicCells = [NSMutableArray arrayWithArray:objects];
            
            ///Reload Table view
            [weakself.tblVuPublicCell reloadData];
            
            
        }
        else {
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakself];
            }
            
            
        }
        
        
        
    }];

}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}


-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)applyColors {
    ///set background color
    self.vuContentContainer.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblAlertTitle.textColor = primaryTextColor;
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblIncludeSecurityGuards.textColor = secondaryTextColor;
    self.tglBtnIncludeSecurityGuards.tintColor = secondaryTextColor;
    
    ///Set secondary color
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    [self.btnOk setTitleColor:secondaryColor forState:UIControlStateNormal];
    [self.btnCancel setTitleColor:secondaryColor forState:UIControlStateNormal];
    
}

//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)btnOkTapped:(UIButton *)sender {
    ///user selected the public cell
    PFObject *publicCell = [self.arrPublicCells objectAtIndex:self.selectedIndex];
    [self.delegate publicCellSelectionVC:self didSelectPublicCell:publicCell];

}

- (IBAction)btnCancelTapped:(UIButton *)sender {
    
    [self.delegate publicCellSelectionVCDidCancel:self];

}

- (IBAction)btnIncludeSecurityGuardToggled:(UIButton *)sender
{
    self.tglBtnIncludeSecurityGuards.selected = !self.tglBtnIncludeSecurityGuards.isSelected;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(self.tglBtnIncludeSecurityGuards.isSelected) forKey:kIncludeSecurityGuards];
    [defaults synchronize];
    
}

//****************************************************
#pragma mark - UITableViewDataSource and delegate methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = self.arrPublicCells.count;
    if (rowCount == 0) {
        //disable Ok button
        self.btnOk.enabled = NO;
    }
    else{
        ///enable the Ok button
        self.btnOk.enabled = YES;
    }
    
    return rowCount;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    NSInteger selectedIndex = self.selectedIndex;
    
    static NSString * cellId = @"C411AlertGroupSelectionCell";
    C411AlertGroupSelectionCell *alertGroupCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSString *strCellName  = nil;
    
    PFObject *publicCell = [self.arrPublicCells objectAtIndex:rowIndex];
        
    strCellName = publicCell[kPublicCellNameKey];
    
    alertGroupCell.lblAlertRecievingGroupName.text = strCellName;
    if (selectedIndex == rowIndex) {
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
    [self.tblVuPublicCell reloadData];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
