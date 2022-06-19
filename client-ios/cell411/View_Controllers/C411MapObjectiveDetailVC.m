//
//  C411MapObjectiveDetailVC.m
//  cell411
//
//  Created by Milan Agarwal on 03/06/19.
//  Copyright © 2019 Milan Agarwal. All rights reserved.
//

#import "C411MapObjectiveDetailVC.h"
#import "C411StaticHelper.h"
#import "C411ColorHelper.h"
#import "Constants.h"
#import "UIImageView+ImageDownloadHelper.h"

@interface C411MapObjectiveDetailVC ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *vuPopupBG;
@property (weak, nonatomic) IBOutlet UIView *vuPopupContainer;
@property (weak, nonatomic) IBOutlet UIView *vuPopupHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIView *vuPopupHeaderImgContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuObjectiveType;
@property (weak, nonatomic) IBOutlet UIView *vuContent;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuObjective;
@property (weak, nonatomic) IBOutlet UIView *vuNameCategoryContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblCategory;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuCategory;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuURL;
@property (weak, nonatomic) IBOutlet UILabel *lblURL;
@property (weak, nonatomic) IBOutlet UIView *vuSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuOpeningHours;
@property (weak, nonatomic) IBOutlet UILabel *lblOpenHours;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuContactNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblContactNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsURLImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsURLImageTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSeparatorViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSeparatorViewTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAddressImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAddressImageTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsOpenHoursImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsOpenHoursImageTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsContactNumberImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsContactNumberImageTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDescriptionTS;



- (IBAction)btnCloseTapped:(UIButton *)sender;
@end

@implementation C411MapObjectiveDetailVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerForNotifications];
    [self configureViews];
    [self setupViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
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
#pragma mark - Private Methods
//****************************************************

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)configureViews
{
    [C411StaticHelper makeCircularView:self.vuPopupHeaderImgContainer];
    [self setupTapGesture];
    [self applyColors];
}

-(void)applyColors {
    
    ///Set category color
    UIColor *categoryColor = [[C411ColorHelper sharedInstance]getMapObjectiveColorForCategory:[self.mapObjective[kMapObjectiveCategoryKey]intValue]];
    self.vuPopupHeaderImgContainer.backgroundColor = categoryColor;
    self.vuPopupHeader.backgroundColor = categoryColor;
    self.imgVuURL.tintColor = categoryColor;
    self.imgVuAddress.tintColor = categoryColor;
    self.imgVuOpeningHours.tintColor = categoryColor;
    self.imgVuContactNumber.tintColor = categoryColor;
    
    ///Set white color
    UIColor *whiteColor = [UIColor whiteColor];
    self.imgVuObjectiveType.tintColor = whiteColor;
    self.imgVuCategory.tintColor = whiteColor;
    self.lblName.textColor = whiteColor;
    self.lblCategory.textColor = whiteColor;
    self.btnClose.tintColor = whiteColor;
    
    ///set light card color
    UIColor *lightCardColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuContent.backgroundColor = lightCardColor;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblURL.textColor = primaryTextColor;
    self.lblAddress.textColor = primaryTextColor;
    self.lblOpenHours.textColor = primaryTextColor;
    self.lblContactNumber.textColor = primaryTextColor;
    self.lblDescription.textColor = primaryTextColor;

    ///Set separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuSeparator.backgroundColor = separatorColor;
}

-(void)setupViews {
    ///Set category Image
    MapObjectiveCategory category = [self.mapObjective[kMapObjectiveCategoryKey]intValue];
    UIImage *imgCategory = [C411StaticHelper getMapObjectiveImageForCategory:category];
    self.imgVuObjectiveType.image = imgCategory;
    self.imgVuCategory.image = imgCategory;
    ///Set objective image
    PFFileObject *mapObjectiveImageFile = self.mapObjective[kMapObjectiveImageKey];
    if(mapObjectiveImageFile) {
        [self.imgVuObjective setImageUsingFileObject:mapObjectiveImageFile withCompletion:NULL];
    }
    ///Set other details
    self.lblName.text = self.mapObjective[kMapObjectiveNameKey];
    self.lblCategory.text = [C411StaticHelper getLocalizedMapObjectiveCategory:category];
    self.lblURL.text = self.mapObjective[kMapObjectiveURLKey];
    if(self.lblURL.text.length == 0) {
        ///hide it
        self.cnsURLImageTS.constant = 0;
        self.cnsURLImageWidth.constant = 0;
        self.cnsSeparatorViewTS.constant = 0;
        self.cnsSeparatorViewHeight.constant = 0;
    }
    self.lblAddress.text = self.mapObjective[kMapObjectiveFullAddressKey];
    if(self.lblAddress.text.length == 0) {
        ///hide it
        self.cnsAddressImageTS.constant = 0;
        self.cnsAddressImageWidth.constant = 0;
        
    }
    self.lblOpenHours.text = self.mapObjective[kMapObjectiveHoursKey];
    if(self.lblOpenHours.text.length == 0) {
        ///hide it
        self.cnsOpenHoursImageTS.constant = 0;
        self.cnsOpenHoursImageWidth.constant = 0;
        
    }
    self.lblContactNumber.text = self.mapObjective[kMapObjectivePhoneKey];
    if(self.lblContactNumber.text.length == 0) {
        ///hide it
        self.cnsContactNumberImageTS.constant = 0;
        self.cnsContactNumberImageWidth.constant = 0;
        
    }
    self.lblDescription.text = self.mapObjective[kMapObjectiveDescKey];
    if(self.lblDescription.text.length == 0) {
        ///hide it
        self.cnsDescriptionTS.constant = 0;        
    }
}

-(void)setupTapGesture {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedOutsidePopup:)];
    tapRecognizer.delegate = self;
    [self.vuPopupBG addGestureRecognizer:tapRecognizer];
}

-(void)tappedOutsidePopup:(id)sender {
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    [self dismissPopup];
}

-(void)dismissPopup
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//****************************************************
#pragma mark - UIGestureRecognizerDelegate Methods
//****************************************************
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([gestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]])
    {
        return (touch.view == self.vuPopupBG || touch.view == self.vuPopupContainer) ;
    }
    return YES;
}

//****************************************************
#pragma mark - Action Methods
//****************************************************
- (IBAction)btnCloseTapped:(UIButton *)sender {
    [self dismissPopup];
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
