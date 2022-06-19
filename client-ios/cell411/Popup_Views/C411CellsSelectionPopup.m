//
//  C411CellsSelectionPopup.m
//  cell411
//
//  Created by Milan Agarwal on 20/04/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411CellsSelectionPopup.h"
#import "C411PubPvtCellSelectionCell.h"
#import "CellsDelegate.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411AlertSettings.h"
#import "C411ColorHelper.h"

#define PAGE_LIMIT  10

@interface C411CellsSelectionPopup ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITableView *tblVuCells;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIView *vuStickyNote;
@property (weak, nonatomic) IBOutlet UILabel *lblStickyNoteTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblStickyNoteSubtitle;
@property (strong, nonatomic) IBOutlet UIView *vuNavHairline;

- (IBAction)btnBackTapped:(UIButton *)sender;

@property (nonatomic, strong) NSMutableArray *arrPublicCells;
@property (nonatomic, assign) BOOL noMoreData;


@end

@implementation C411CellsSelectionPopup

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.tblVuCells.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    [self fetchPublicCells];
    [C411StaticHelper removeOnScreenKeyboard];
    [self registerForNotifications];
    [self applyColors];
}

-(void)dealloc {
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
#pragma mark - Property Initializers
//****************************************************

-(NSMutableArray *)arrPublicCells
{
    if(!_arrPublicCells){
        _arrPublicCells = [NSMutableArray array];
    }
    return _arrPublicCells;
}


//****************************************************
#pragma mark - Public Methods
//****************************************************
-(void)reloadData
{
    [self.tblVuCells reloadData];
}

//****************************************************
#pragma mark - Private Method
//****************************************************
-(void)applyColors {
    ///set background color
    UIColor *lightCardColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.backgroundColor = lightCardColor;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblTitle.textColor = primaryTextColor;
    self.lblStickyNoteTitle.textColor = primaryTextColor;
    
    ///Set disabled text color
    self.lblStickyNoteSubtitle.textColor = [C411ColorHelper sharedInstance].disabledTextColor;

    ///Set hint icon color
    self.btnBack.tintColor = [C411ColorHelper sharedInstance].hintIconColor;
    
    ///Set hairline color
    self.vuNavHairline.backgroundColor = [C411ColorHelper sharedInstance].separatorColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)fetchPublicCells
{
    __weak typeof(self) weakself = self;
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *getPublicCellsQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
    [getPublicCellsQuery whereKey:kPublicCellMembersKey equalTo:currentUser];
    [getPublicCellsQuery whereKey:kPublicCellTotalMembersKey greaterThan:@1];
    getPublicCellsQuery.skip = self.arrPublicCells.count;
    getPublicCellsQuery.limit = PAGE_LIMIT;
    [getPublicCellsQuery orderByAscending:kPublicCellNameKey];
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    
    [getPublicCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (!error) {
            [weakself.arrPublicCells addObjectsFromArray:objects];
            
            if (objects.count < PAGE_LIMIT) {
                
                weakself.noMoreData = YES;
            }
            else{
                
                weakself.noMoreData = NO;
            }
            
            ///Reload Table view
            [weakself reloadData];
        }
        else {
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:nil];
            }
        }
        [MBProgressHUD hideHUDForView:weakself animated:YES];
    }];
}

-(BOOL)isPrivateCellSelected:(NSString *)strCellId
{
    if((strCellId.length > 0)
       && (!self.dictFilteredDeselectedPrivateCells[strCellId])){
        
        return YES;
    }
    
    return NO;
}
-(BOOL)isPublicCellSelected:(NSString *)strCellId
{
    if((strCellId.length > 0)
       && (!self.dictFilteredDeselectedPublicCells[strCellId])){
        
        return YES;
    }
    
    return NO;
}

-(void)showStickyNote{
    
    ///Show sticky view
    self.vuStickyNote.hidden = NO;
}

-(void)hideStickyNote{
    
    ///Hide sticky note
    self.vuStickyNote.hidden = YES;
    
}


//****************************************************
#pragma mark - TableView DataSource and Delegate Methods
//****************************************************

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ((velocity.y>0) && (!self.noMoreData)) {
        CGSize contentSize = scrollView.contentSize;
        CGSize scrollVSize  = scrollView.bounds.size;
        
        float downloadTriggerPointFromBottom = scrollVSize.height + 100;
        float downloadTriggerPoint              = contentSize.height - downloadTriggerPointFromBottom;
        
        if (targetContentOffset->y>=downloadTriggerPoint) {
            [self fetchPublicCells];
            
        }
        
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = self.arrPublicCells.count + self.arrFilteredPrivateCells.count;
    if(rowCount == 0){
        [self showStickyNote];
    }
    else{
        [self hideStickyNote];
    }
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    static NSString *cellId = @"C411PubPvtCellSelectionCell";
    C411PubPvtCellSelectionCell *pubPvtCellSelectionCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(rowIndex < self.arrFilteredPrivateCells.count){
        ///Display Private Cells
        ///Get Parse Cell object
        PFObject *myPrivateCellObject = [self.arrFilteredPrivateCells objectAtIndex:rowIndex];
        pubPvtCellSelectionCell.lblCellName.text = [C411StaticHelper getLocalizedNameForCell:myPrivateCellObject];
        pubPvtCellSelectionCell.lblCellType.text = NSLocalizedString(@"Private Cell", nil);
        ///Remove verified image
        pubPvtCellSelectionCell.imgVuVerified.image = nil;
        pubPvtCellSelectionCell.imgVuVerified.layer.borderWidth = 0;
        pubPvtCellSelectionCell.tglBtnCellSelection.selected = [self isPrivateCellSelected:myPrivateCellObject.objectId];
    }
    else{
        ///Display Public Cells
        NSInteger publicCellIndex = rowIndex - self.arrFilteredPrivateCells.count;
        if(publicCellIndex < self.arrPublicCells.count){
            PFObject *publicCellObject = [self.arrPublicCells objectAtIndex:publicCellIndex];
            pubPvtCellSelectionCell.lblCellName.text = publicCellObject[kPublicCellNameKey];
            pubPvtCellSelectionCell.lblCellType.text = NSLocalizedString(@"Public Cell", nil);
            pubPvtCellSelectionCell.tglBtnCellSelection.selected = [self isPublicCellSelected:publicCellObject.objectId];
            BOOL isVerified = [publicCellObject[kPublicCellVerificationStatusKey]integerValue] == CellVerificationStatusApproved;
            
            if (isVerified) {
                
                ///Set verified image
                static UIImage *imgVerified = nil;
                if (!imgVerified) {
                    imgVerified = [UIImage imageNamed:@"ic_verified"];
                }
                
                pubPvtCellSelectionCell.imgVuVerified.image = imgVerified;
                pubPvtCellSelectionCell.imgVuVerified.layer.borderWidth = 2.0;
                
            }
            else{
                
                ///Remove verified image
                pubPvtCellSelectionCell.imgVuVerified.image = nil;
                pubPvtCellSelectionCell.imgVuVerified.layer.borderWidth = 0;
            }
            
        }
    }
    
    pubPvtCellSelectionCell.tglBtnCellSelection.tag = rowIndex;
    [pubPvtCellSelectionCell.tglBtnCellSelection addTarget:self action:@selector(tglBtnCellSelectionTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return pubPvtCellSelectionCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0f;
}

//****************************************************
#pragma mark - Action Methods
//****************************************************
- (IBAction)btnBackTapped:(UIButton *)sender
{
    if([self.delegate respondsToSelector:@selector(cellsSelectionPopupDidTappedBack)]){
        
        [self.delegate cellsSelectionPopupDidTappedBack];
    }
    self.hidden = YES;
}

-(void)tglBtnCellSelectionTapped:(UIButton *)sender {
    
    NSInteger rowIndex = sender.tag;
    BOOL shouldSelect = !sender.selected;
    
    if(rowIndex < self.arrFilteredPrivateCells.count){
        ///Get the cell
        PFObject *myPrivateCellObject = [self.arrFilteredPrivateCells objectAtIndex:rowIndex];
        NSInteger cellMembers = [myPrivateCellObject[kCellMembersKey] count] + [myPrivateCellObject[kCellNauMembersKey] count];
        ///Update local filtered dictionary of unselected cells
        if(shouldSelect){
            
            ///Remove it from filtered dictionary of unselected cells
            [self.dictFilteredDeselectedPrivateCells removeObjectForKey:myPrivateCellObject.objectId];
            
            [self.delegate incrementTotalMembersCountBy:cellMembers];
        }
        else{
            ///Add it to filtered dictionary of unselected cells
            self.dictFilteredDeselectedPrivateCells[myPrivateCellObject.objectId] = @(YES);
            
            [self.delegate decrementTotalMembersCountBy:cellMembers];
        }
        
        ///Update selection on saved settings
        [self.alertSettings togglePrivateCellSelection:shouldSelect forCellId:myPrivateCellObject.objectId];
        
    }
    else{
        ///Get Public Cells index
        NSInteger publicCellIndex = rowIndex - self.arrFilteredPrivateCells.count;
        if(publicCellIndex < self.arrPublicCells.count){
            PFObject *publicCellObject = [self.arrPublicCells objectAtIndex:publicCellIndex];
            NSInteger cellMembers = [publicCellObject[kPublicCellTotalMembersKey]integerValue] - 1;
            ///Update local filtered dictionary of unselected cells
            if(shouldSelect){
                ///Remove it from filtered dictionary of unselected cells
                [self.dictFilteredDeselectedPublicCells removeObjectForKey:publicCellObject.objectId];
                
                [self.delegate incrementTotalMembersCountBy:cellMembers];
            }
            else{
                ///Add it to filtered dictionary of unselected cells
                self.dictFilteredDeselectedPublicCells[publicCellObject.objectId] = @(YES);
                
                [self.delegate decrementTotalMembersCountBy:cellMembers];
            }

            ///Update selection on saved settings
            [self.alertSettings togglePublicCellSelection:shouldSelect forCellId:publicCellObject.objectId];
            
        }
    }
    
    ///Reload the row
    [self.tblVuCells reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
