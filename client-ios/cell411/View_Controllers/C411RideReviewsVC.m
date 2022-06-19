//
//  C411RideReviewsVC.m
//  cell411
//
//  Created by Milan Agarwal on 03/11/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411RideReviewsVC.h"
#import <Parse/Parse.h>
#import "C411StaticHelper.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411MyRideReviewCell.h"
#import "C411OthersRideReviewCell.h"
#import "C411AverageRideRatingsCell.h"
#import "C411GiveRideReviewCell.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "UITableView+RemoveTopPadding.h"
#import "AppDelegate.h"
#import "C411ColorHelper.h"

@interface C411RideReviewsVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tblVuReviews;
@property (weak, nonatomic) IBOutlet UIView *vuReviewBase;
@property (weak, nonatomic) IBOutlet UIView *vuReviewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblReviewedByName;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btnRateStars;
@property (weak, nonatomic) IBOutlet UILabel *lblRating;
@property (weak, nonatomic) IBOutlet UITextField *txtReviewTitle;
@property (weak, nonatomic) IBOutlet UIView *vuReviewTitleSeparator;
@property (weak, nonatomic) IBOutlet UITextView *txtVuReviewDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblDescriptionPlaceholder;
@property (weak, nonatomic) IBOutlet UIView *vuReviewDescriptionSeparator;
@property (weak, nonatomic) IBOutlet UIView *vuReviewActionContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelReview;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmitReview;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAvatar;
@property (strong, nonatomic) IBOutlet UIToolbar *tlbrHideKeyboard;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnDone;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsReviewContainerCenterY;

- (IBAction)btnRateTapped:(UIButton *)sender;
- (IBAction)btnCancelReviewTapped:(UIButton *)sender;
- (IBAction)btnSubmitReviewTapped:(UIButton *)sender;
- (IBAction)barBtnDoneTapped:(UIBarButtonItem *)sender;

@property (nonatomic, strong) NSArray *arrReviews;
@property (nonatomic, strong) PFObject *reviewByCurrentUser;
@property (nonatomic, strong) NSNumber *numAvgRating;
@property (nonatomic, strong) NSNumber *numTotalRatingCount;

@end

@implementation C411RideReviewsVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///Remove top padding of 35 pixel
    //self.tblVuReviews.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    ///Post notification that review VC is opened to handle popups
    [[NSNotificationCenter defaultCenter]postNotificationName:kDidOpenedRideReviewsVCNotification object:nil];
    [self refreshViews];
    [self configureViews];
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
#pragma mark - Overridden Methods
//****************************************************
-(void)mag_viewDidBack {
    [super mag_viewDidBack];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDidClosedRideReviewsVCNotification object:nil];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

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


-(void)configureViews
{
    self.title = NSLocalizedString(@"Reviews", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    self.vuReviewContainer.layer.cornerRadius = 5.0;
    self.vuReviewContainer.layer.masksToBounds = YES;
    [C411StaticHelper makeCircularView:self.imgVuAvatar];

    ///Set toolbar as input accessory view
    self.txtReviewTitle.inputAccessoryView = self.tlbrHideKeyboard;
    self.txtVuReviewDescription.inputAccessoryView = self.tlbrHideKeyboard;

    [self applyColors];
}

-(void)applyColors {
    ///Set BG color
    UIColor *backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    self.view.backgroundColor = backgroundColor;
    
    ///Set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblReviewedByName.textColor = primaryTextColor;
    self.txtReviewTitle.textColor = primaryTextColor;
    self.txtVuReviewDescription.textColor = primaryTextColor;
    
    
    ///Set disabled color for placeholder text
    UIColor *disabledTextColor = [C411ColorHelper sharedInstance].disabledTextColor;
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtReviewTitle];
    self.lblDescriptionPlaceholder.textColor = disabledTextColor;
    
    ///Set separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuReviewTitleSeparator.backgroundColor = separatorColor;
    self.vuReviewDescriptionSeparator.backgroundColor = separatorColor;
    
    ///Set light card color
    self.vuReviewContainer.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    
    ///set blood group buttons
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    [self.btnCancelReview setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnSubmitReview setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnCancelReview.backgroundColor = themeColor;
    self.btnSubmitReview.backgroundColor = themeColor;
    
    self.vuReviewActionContainer.backgroundColor = [C411ColorHelper sharedInstance].darkThemeColor;
    
    self.txtVuReviewDescription.keyboardAppearance = [C411ColorHelper sharedInstance].keyboardAppearance;
   
    self.tlbrHideKeyboard.barTintColor = backgroundColor;
    self.tlbrHideKeyboard.tintColor = themeColor;
}


-(void)refreshViews
{
    ///empty tableview
    self.arrReviews = nil;
    self.reviewByCurrentUser = nil;
    self.numAvgRating = nil;
    self.numTotalRatingCount = nil;
    [self.tblVuReviews reloadData];
    
    //show loading indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [self fetchReviewsWithCompletion:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error) {
            
            
            ///filter the reviews
            [weakSelf filterReviews:objects WithCompletion:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                
                NSArray *arrFilteredReviews  = objects;
                if (arrFilteredReviews.count > 0) {
                    
                    ///Get the average rating
                    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
                    dictParams[kAverageStarsFuncParamUserIdKey] = weakSelf.targetUser.objectId;
                    [C411StaticHelper getAverageStarsForUserWithDetails:dictParams andCompletion:^(id  _Nullable object, NSError * _Nullable error) {
                        
                        if (!error) {
                            
                            weakSelf.arrReviews = arrFilteredReviews;
                            
                            NSString *strRatingComponents = (NSString *)object;
                            NSArray *arrRatingComponents = [strRatingComponents componentsSeparatedByString:@","];
                            if (arrRatingComponents.count == 2) {
                                int totalRatingCount = [[arrRatingComponents firstObject]intValue];
                                weakSelf.numTotalRatingCount = @(totalRatingCount);
                                
                                float avgRating = [[arrRatingComponents lastObject]floatValue];
                                weakSelf.numAvgRating = @(avgRating);

                            }
                            
                            ///hide the progress hud
                            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                            
                            ///reload table view
                            [weakSelf.tblVuReviews reloadData];

                        }
                        else{
                            
                            ///show error
                            NSString *errorString = [error userInfo][@"error"];
                            NSLog(@"#error fetching cell411alert :%@",errorString);
                            ///hide loading screen
                            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                            
                        }
                        
                    }];
                    
                    
                }
                else {
                    
                    weakSelf.arrReviews = nil;
                    
                    if (weakSelf.reviewByCurrentUser) {
                        
                        ///Set the total rating count to 1
                        weakSelf.numTotalRatingCount = @(1);
                        
                        ///set the avg rating to be same as current user rating
                        weakSelf.numAvgRating = weakSelf.reviewByCurrentUser[kReviewRatingKey];
                        
                    }
                    
                    ///hide the progress hud
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                    ///reload table view
                    [weakSelf.tblVuReviews reloadData];
                    
                }
                
            }];

        }
        else{
            
            ///show error
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"#error fetching cell411alert :%@",errorString);
            ///hide loading screen
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
        }
        
        
        
    }];

}

-(void)fetchReviewsWithCompletion:(PFArrayResultBlock)completion
{
    PFQuery *fetchReviewsQuery = [PFQuery queryWithClassName:kReviewClassNameKey];
    if(self.targetUser){
        
        [fetchReviewsQuery whereKey:kReviewRatedUserKey equalTo:self.targetUser];
        [fetchReviewsQuery includeKey:kReviewRatedByKey];
        fetchReviewsQuery.limit = 1000;
        [fetchReviewsQuery orderByDescending:@"createdAt"];
        [fetchReviewsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (completion != NULL) {
                
                completion(objects,error);
            }
            
        }];

    }
    else{
    
//        [fetchReviewsQuery whereKey:kReviewRatedUserKey equalTo:self.targetUserId];
        
        
        __weak typeof(self) weakSelf = self;
        PFQuery *getUserQuery = [PFUser query];
        [getUserQuery getObjectInBackgroundWithId:self.targetUserId block:^(PFObject *object,  NSError *error){
            
            if (!error && object) {
                
                ///User found, save it in iVar
                PFUser *targetUser = (PFUser *)object;
                weakSelf.targetUser = targetUser;
                
                ///call the same method recursively and pass the completion block
                [weakSelf fetchReviewsWithCompletion:completion];
                
            }
            else {
                
                ///log error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"#error: %@",errorString);
                
                ///call the completion block if provided
                if (completion!=NULL) {
                    
                    completion(nil,error);
                }
                
            }
        }];

    }
    
}

-(void)filterReviews:(NSArray *)arrReviews WithCompletion:(PFArrayResultBlock)completion
{
    ///Filter the reviews in background
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSMutableArray *arrFilteredArray = [NSMutableArray array];
        for (PFObject *review in arrReviews) {
            PFUser *ratedBy = review[kReviewRatedByKey];
            if (ratedBy) {
                
                if ([ratedBy.objectId isEqualToString:[AppDelegate getLoggedInUser].objectId]) {
                    
                    ///This review is given by current user, this should be added in the beginning of the list
                    weakSelf.reviewByCurrentUser = review;
                }
                else{
                    ///review by some other user
                    [arrFilteredArray addObject:review];
                    
                }
                
            }
            
            
        }
        
        if (completion != NULL) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(arrFilteredArray,nil);
                
            });
            
        }

        
    });
}

-(void)setOverlayStarsWithRating:(NSInteger)rating
{
    ///Set stars
    NSInteger baseTag = [[self.btnRateStars firstObject]tag];
    for (NSInteger index = 0; index < self.btnRateStars.count; index++) {
        
        UIButton *btnStar = [self.btnRateStars objectAtIndex:index];
        if (btnStar.tag < (baseTag + rating)) {
            ///set filled star
            btnStar.selected = YES;
        }
        else{
            ///set grey star
            btnStar.selected = NO;
        }
        
    }
    
    ///set rating text
    self.lblRating.text = [self getTextForRating:rating];
}

-(NSString *)getTextForRating:(NSInteger)rating
{
    NSString *strRatingText = nil;
    switch (rating) {
        case 1:
            strRatingText = NSLocalizedString(@"Hated it", nil);
            break;
        case 2:
            strRatingText = NSLocalizedString(@"Disliked it", nil);
            break;
        case 3:
            strRatingText = NSLocalizedString(@"It's OK", nil);
            break;
        case 4:
            strRatingText = NSLocalizedString(@"Liked it", nil);
            break;
        case 5:
            strRatingText = NSLocalizedString(@"Loved it", nil);
            break;
    
        default:
            break;
    }
    
    return strRatingText;
}

-(NSInteger)getRatingUsingStarsArray:(NSArray *)arrBtnStars
{

    NSInteger rating = 0;
    for (NSInteger index = 0; index < arrBtnStars.count; index++) {
        
        UIButton *btnStar = [arrBtnStars objectAtIndex:index];
        if (btnStar.isSelected == NO) {
            break;
        }
        
        ///set the rating
        rating++;
        
    }
    
    return rating;
}

//****************************************************
#pragma mark - UITableViewDatasource and Delegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = self.arrReviews.count + 1;///+1 for current user review
    
    if (self.numAvgRating) {
        
        ///append +1 for average rating
        rowCount++;
    }
    
    return rowCount;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    if (rowIndex == 0) {
        
        if (self.reviewByCurrentUser) {
            
            ///Show My Review Cell
            static NSString *cellId = @"C411MyRideReviewCell";
            C411MyRideReviewCell *myRideReviewCell = [tableView dequeueReusableCellWithIdentifier:cellId];
            [myRideReviewCell setDataUsingObject:self.reviewByCurrentUser];
            [myRideReviewCell.btnEditMyReview addTarget:self action:@selector(btnEditMyReviewTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            return myRideReviewCell;
            
        }
        else{
            
            ///Show Give ride review cell
            static NSString *cellId = @"C411GiveRideReviewCell";
            C411GiveRideReviewCell *giveRideReviewCell = [tableView dequeueReusableCellWithIdentifier:cellId];
            
            ///set avatar
            PFUser *currentUser = [AppDelegate getLoggedInUser];
            [giveRideReviewCell.imgVuAvatar setAvatarForUser:currentUser shouldFallbackToGravatar:YES ofSize:giveRideReviewCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
            
            ///Set Name
            NSString *strCurrentUserName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
            giveRideReviewCell.lblName.text = strCurrentUserName;

            for (UIButton *btnStar in giveRideReviewCell.btnRatingStars) {
                
                [btnStar addTarget:self action:@selector(btnRateThisUserStarTapped:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            return giveRideReviewCell;
            
        }
        
        
        
    }
    else if(rowIndex == 1 && self.numAvgRating){
        
        ///Show average ride rating cell
        static NSString *cellId = @"C411AverageRideRatingsCell";
        C411AverageRideRatingsCell *avgRideRatingsCell = [tableView dequeueReusableCellWithIdentifier:cellId];
        [avgRideRatingsCell setAverageRating:[self.numAvgRating floatValue] withRatingCount:[self.numTotalRatingCount intValue]];
        return avgRideRatingsCell;

        
    }
    else{
        
        ///Map the row index to array
        NSInteger mappedIndex = rowIndex - 1;///-1 for current user review cell
        
        if (self.numAvgRating) {
            
            mappedIndex--; ///-1 for average rating cell
        }
        
        
        ///show other review Cell
        PFObject *review = [self.arrReviews objectAtIndex:mappedIndex];
        static NSString *cellId = @"C411OthersRideReviewCell";
        C411OthersRideReviewCell *othersRideReviewCell = [tableView dequeueReusableCellWithIdentifier:cellId];
        [othersRideReviewCell setDataUsingObject:review];

        return othersRideReviewCell;

        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    if (rowIndex == 0) {
        
        if (self.reviewByCurrentUser) {
            
            ///Return height of My Review Cell
            ///Create a static cell for each reuse identifier
            static C411MyRideReviewCell *myRideReviewCell = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                
                myRideReviewCell = [tableView dequeueReusableCellWithIdentifier:@"C411MyRideReviewCell"];
                
            });
            
            
            ///Configure cell
            [myRideReviewCell setDataUsingObject:self.reviewByCurrentUser];
            
            ///Calculate height
            return [self tableView:tableView calculateHeightForConfiguredSizingCell:myRideReviewCell];

            
        }
        else{
            
            ///Return height of Give ride review cell
            return 157.0f;
            
        }
        
        
        
    }
    else if(rowIndex == 1 && self.numAvgRating){
        
        ///Return height of average ride rating cell
        return 106.0f;
        
    }
    else{
        
        ///Map the row index to array
        NSInteger mappedIndex = rowIndex - 1;///-1 for current user review cell
        
        if (self.numAvgRating) {
            
            mappedIndex--; ///-1 for average rating cell
        }
        
        
        ///Return height of other review Cell
        PFObject *review = [self.arrReviews objectAtIndex:mappedIndex];
        ///Create a static cell for each reuse identifier
        static C411OthersRideReviewCell *othersRideReviewCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            othersRideReviewCell = [tableView dequeueReusableCellWithIdentifier:@"C411OthersRideReviewCell"];
            
        });
        
        
        ///Configure cell
        [othersRideReviewCell setDataUsingObject:review];
        
        ///Calculate height
        return [self tableView:tableView calculateHeightForConfiguredSizingCell:othersRideReviewCell];

    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}


//****************************************************
#pragma mark - tableView:heightForRowAtIndexPath Helper Methods
//****************************************************


- (CGFloat)tableView:(UITableView *)tableView calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height);
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    float height = size.height + 1.0f; // Add 1.0f for the cell separator height
    
    //height = height < MIN_ROW_HEIGHT ? MIN_ROW_HEIGHT : height;
    
    return height;
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnRateTapped:(UIButton *)sender {
    
    ///Get the rating of the tapped star
    NSInteger baseTag = [[self.btnRateStars firstObject]tag];
    NSInteger rating = sender.tag - baseTag + 1;
    [self setOverlayStarsWithRating:rating];

}

- (IBAction)btnCancelReviewTapped:(UIButton *)sender {
    
    ///hide keyboard
    [self.view endEditing:YES];

    ///Hide the review base
    self.vuReviewBase.hidden = YES;
}

- (IBAction)btnSubmitReviewTapped:(UIButton *)sender {
    
    ///hide keyboard
    [self.view endEditing:YES];
    
    ///Show progress hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFObject *review = nil;
    if (self.reviewByCurrentUser) {
        
        ///Update this review object
        review = self.reviewByCurrentUser;
        
    }
    else{
        
        ///Create a new review object and save on parse
        review = [PFObject objectWithClassName:kReviewClassNameKey];
    }
    
    ///Set title
    NSString *strReviewTitle = self.txtReviewTitle.text;
    review[kReviewTitleKey] = strReviewTitle.length > 0 ? strReviewTitle : @"";
    
    ///set comment
    NSString *strReviewComment = self.txtVuReviewDescription.text;
    review[kReviewCommentKey] = strReviewComment.length > 0 ? strReviewComment : @"";
    
    ///Set rating
    NSInteger rating = [self getRatingUsingStarsArray:self.btnRateStars];
    review[kReviewRatingKey] = @(rating);
    
    if (!self.reviewByCurrentUser) {
        
        ///Set ratedBy
        review[kReviewRatedByKey] = [AppDelegate getLoggedInUser];
        
        ///Set ratedUser
        review[kReviewRatedUserKey] = self.targetUser;
    }
    
    __weak typeof(self) weakSelf = self;
    ///save this rating
    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (error) {
            
            ///save it eventually if error occured
            [review saveEventually];
            
        }
        
        ///Hide the progress hud
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        
        ///hide the rating overlay
        weakSelf.vuReviewBase.hidden = YES;
        
        ///Refresh the data
        [weakSelf refreshViews];
        
//        ///update the reviewByCurrentUser object
//        weakSelf.reviewByCurrentUser = review;
//        
//        ///reload table
//        [weakSelf.tblVuReviews reloadData];
        

        
    }];
    
    
    
}

- (IBAction)barBtnDoneTapped:(UIBarButtonItem *)sender {
    
    [self.view endEditing:YES];
}

-(void)btnEditMyReviewTapped:(UIButton *)sender
{
    ///set avatar
    PFUser *ratedByUser = [AppDelegate getLoggedInUser];
    [self.imgVuAvatar setAvatarForUser:ratedByUser shouldFallbackToGravatar:YES ofSize:self.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
    
    ///Set Name
    NSString *strRatedByUserName = [C411StaticHelper getFullNameUsingFirstName:ratedByUser[kUserFirstnameKey] andLastName:ratedByUser[kUserLastnameKey]];
   self.lblReviewedByName.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Reviewed by %@",nil),strRatedByUserName];

    ///set rating
    int rating = [self.reviewByCurrentUser[kReviewRatingKey]intValue];
    [self setOverlayStarsWithRating:rating];
    
    ///set title
    self.txtReviewTitle.text = self.reviewByCurrentUser[kReviewTitleKey];
    
    ///set comment
    NSString *strComment = self.reviewByCurrentUser[kReviewCommentKey];
    if (strComment.length > 0) {
        ///Show comment and hide placeholder
        self.txtVuReviewDescription.text = strComment;
        self.lblDescriptionPlaceholder.hidden = YES;
    }
    else{
        
        ///remove comment and show the placeholder
        self.txtVuReviewDescription.text = nil;
        self.lblDescriptionPlaceholder.hidden = NO;

    }
    ///Show the Edit review view
    self.vuReviewBase.hidden = NO;
}

-(void)btnRateThisUserStarTapped:(UIButton *)sender
{
    if (self.isRideConfirmed) {
        
        ///Set rating
        ///Get the rating of the tapped star
        NSInteger baseTag = [[self.btnRateStars firstObject]tag];
        NSInteger rating = sender.tag - baseTag + 1;
        [self setOverlayStarsWithRating:rating];
        
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        
        ///set avatar
        [self.imgVuAvatar setAvatarForUser:currentUser shouldFallbackToGravatar:YES ofSize:self.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
        
        ///Set Name
        NSString *strCurrentUserName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
        self.lblReviewedByName.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Reviewed by %@",nil),strCurrentUserName];
        
        ///set title to Nil
        self.txtReviewTitle.text = nil;
        
        ///set comment to Nil and show placeholder
        self.txtVuReviewDescription.text = nil;
        self.lblDescriptionPlaceholder.hidden = NO;
        
        ///show the review overlay
        self.vuReviewBase.hidden = NO;

    }
    else{
        
        ///Show ride not confirmed message
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"You can add review once the ride is confirmed.", nil) onViewController:self];
    }

}

//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtReviewTitle){
        
        [self.txtVuReviewDescription becomeFirstResponder];
        return NO;
    }
    else{
        [textField resignFirstResponder];
        return YES;
    }
}


//****************************************************
#pragma mark - UITextViewDelegate Methods
//****************************************************


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    ///Toggle Place holder visibility
    if (finalString && finalString.length > 0) {
        ///Hide Placeholder string
        if (textView == self.txtVuReviewDescription) {
            
            self.lblDescriptionPlaceholder.hidden = YES;
            
        }
        
        
    }
    else{
        ///Show Placeholder string
        if (textView == self.txtVuReviewDescription) {
            
            self.lblDescriptionPlaceholder.hidden = NO;
            
        }
       
    }
    
    return YES;
    
}



//****************************************************
#pragma mark - Notifications
//****************************************************

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
//    NSDictionary* info = [note userInfo];
//    CGSize _kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    float kbHeight = _kbSize.width > _kbSize.height ? _kbSize.height : _kbSize.width;
    //      _scrlVu_Base.contentSize = CGSizeMake(_scrlVu_Base.bounds.size.width, _scrlVu_Base.bounds.size.height + kbHeight);
    //self.vuBaseBLConstraints.constant = self.kbHeight + self.scrlVuInitialBLConstarintValue;
    self.cnsReviewContainerCenterY.constant = -120;
    
}

-(void)keyboardWillHide:(NSNotification *)note
{
    //self.vuBaseBLConstraints.constant = self.scrlVuInitialBLConstarintValue;
    self.cnsReviewContainerCenterY.constant = 0;

}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
