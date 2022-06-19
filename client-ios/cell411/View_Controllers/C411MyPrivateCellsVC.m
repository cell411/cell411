//
//  C411MyPrivateCellsVC.m
//  cell411
//
//  Created by Milan Agarwal on 29/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411MyPrivateCellsVC.h"
#import "AppDelegate.h"
#import "UITableView+RemoveTopPadding.h"
#import "C411MyPrivateCell.h"
#import "Constants.h"
#import "CellsDelegate.h"
#import "C411AppDefaults.h"
#import <Parse/Parse.h>
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "MAAlertPresenter.h"
#import "C411ColorHelper.h"

#import "C411PrivateCellMembersVC.h"




@interface C411MyPrivateCellsVC ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>


@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UITableView *tblVuMyPrivateCells;

@property (nonatomic, assign) id<CellsDelegate> cellsDelegate;

@end

@implementation C411MyPrivateCellsVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self.tblVuMyPrivateCells removeTopPadding];
    self.cellsDelegate = [C411AppDefaults sharedAppDefaults];

    [self registerForNotifications];
    [self addGestures];
    [self applyColors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
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
#pragma mark - Private Method
//****************************************************

-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    ///Set secondary text color
    self.lblDescription.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cellsListUpdated:) name:kCellsListUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)reloadData
{
    [self.tblVuMyPrivateCells reloadData];
    
}



-(void)addGestures
{
    UILongPressGestureRecognizer *deleteGesture = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(handlePrivateCellDeletion:)];
    deleteGesture.delegate = self;
    [self.tblVuMyPrivateCells addGestureRecognizer:deleteGesture];
}





//****************************************************
#pragma mark - Gesture Methods
//****************************************************

-(void)handlePrivateCellDeletion:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        ///Show delete Cell popup
        CGPoint touchPoint = [gestureRecognizer locationInView:self.tblVuMyPrivateCells];
        
        NSIndexPath *indexPath = [self.tblVuMyPrivateCells indexPathForRowAtPoint:touchPoint];
        if (indexPath != nil) {
            
            NSInteger rowIndex = indexPath.row;
            PFObject *privateCell = nil;
            NSString *strCellName = nil;
            
            if (rowIndex < self.cellsDelegate.arrCells.count) {
                ///Private cell is long pressed
                ///Set private cell object and it's name
                privateCell = [self.cellsDelegate.arrCells objectAtIndex:rowIndex];
                strCellName = [C411StaticHelper getLocalizedNameForCell:privateCell];
                
                
                
            }
            
            if (privateCell) {
                
                ///There is a valid cell object available to be deleted, show confirmation alert
                NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Do you want to remove %@ ?",nil),strCellName];
                UIAlertController *confirmDeletionAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    ///user said No, do nothing
                    
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];
                    
                }];
                
                UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    ///User opted to remove the cell
                    
                    __weak typeof(self) weakSelf = self;
                    [privateCell deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            
                            ///1.Ask cells delegate to remove this cell from its array and post notification when removed to update the cells list
                            ///Delete app user cell/private cell from array
                            [weakSelf.cellsDelegate removeCellAtIndex:rowIndex];
                            
                            
                        }
                        else{
                            
                            if (error) {
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                                }
                            }
                            
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellsDelegate.arrCells.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    static NSString *myPrivateCellId = @"C411MyPrivateCell";
    
    ///App user cells section
    if (rowIndex < self.cellsDelegate.arrCells.count) {
        
        ///Create and Return cell
        C411MyPrivateCell *myPrivateCell = [tableView dequeueReusableCellWithIdentifier:myPrivateCellId];
        
        ///Get Parse Cell object
        PFObject *myPrivateCellObject = [self.cellsDelegate.arrCells objectAtIndex:rowIndex];
        
        ///Set Cell name
        myPrivateCell.lblCellName.text = [C411StaticHelper getLocalizedNameForCell:myPrivateCellObject];
        
        
        return myPrivateCell;
        
    }
    
    return nil;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    
    
    if (rowIndex < self.cellsDelegate.arrCells.count){
        
        ///show the members of the selected cell
        
        PFObject *myPrivateCell = [self.cellsDelegate.arrCells objectAtIndex:rowIndex];
//#if NON_APP_USERS_ENABLED

        ///Show Private Cell Members VC
        C411PrivateCellMembersVC *pvtCellMembersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411PrivateCellMembersVC"];
        
        pvtCellMembersVC.myPrivateCell = myPrivateCell;
        
        [self.navigationController pushViewController:pvtCellMembersVC animated:YES];

//#else
//    
//        ///Show Cell selection VC
//        C411PvtCellMembersSelectionVC *pvtCellMembersSelectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411PvtCellMembersSelectionVC"];
//        
//        pvtCellMembersSelectionVC.myPrivateCell = myPrivateCell;
//        pvtCellMembersSelectionVC.arrFriends = [C411AppDefaults sharedAppDefaults].arrFriends;
//        pvtCellMembersSelectionVC.membersSelectionDelegate = [C411AppDefaults sharedAppDefaults];
//        [self.navigationController pushViewController:pvtCellMembersSelectionVC animated:YES];
//
//#endif
        
        
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

-(void)cellsListUpdated:(NSNotification *)notif
{
    [self reloadData];
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


@end
