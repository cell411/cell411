//
//  C411KnowYourRightsVC.m
//  cell411
//
//  Created by Milan Agarwal on 28/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411KnowYourRightsVC.h"
#import "C411ColorHelper.h"
#import "C411StaticHelper.h"

@interface C411KnowYourRightsVC ()

@property (weak, nonatomic) IBOutlet UIView *vuRecordIcon;
@property (weak, nonatomic) IBOutlet UIView *vuDetainedIcon;
@property (weak, nonatomic) IBOutlet UIView *vuDoNotAnswerIcon;
@property (weak, nonatomic) IBOutlet UIView *vuNeverConsentIcon;
@property (weak, nonatomic) IBOutlet UIView *vuBePoliteIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblRememberMeText;
@end

@implementation C411KnowYourRightsVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
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

-(void)configureViews
{
    self.title = NSLocalizedString(@"Know Your Rights", nil);
    if (@available(iOS 11, *)) {
        //self.navigationController.navigationBar.prefersLargeTitles = YES;
        ///Above line is commented to disable large title temporarily to fix an issue(Navigation bar background color gets cleared for large titles) until we switch to Xcode 11 having base SDK as iOS 13 for compilation that provides the new UINavigationBarAppearance Class using which we can set same appearance for all scrollEdgeAppearance, standardAppearance and compactAppearance to resolve the issue as provided here: https://stackoverflow.com/a/56696967/3412051
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    UIColor *iconBorderColor = [C411ColorHelper sharedInstance].knowYourRightsIconBorderColor;
    self.vuRecordIcon.layer.borderColor = iconBorderColor.CGColor;
    self.vuRecordIcon.layer.borderWidth = 2.0;
    [C411StaticHelper makeCircularView:self.vuRecordIcon];
    
    self.vuDetainedIcon.layer.borderColor = iconBorderColor.CGColor;
    self.vuDetainedIcon.layer.borderWidth = 2.0;
    [C411StaticHelper makeCircularView:self.vuDetainedIcon];

    self.vuDoNotAnswerIcon.layer.borderColor = iconBorderColor.CGColor;
    self.vuDoNotAnswerIcon.layer.borderWidth = 2.0;
    [C411StaticHelper makeCircularView:self.vuDoNotAnswerIcon];

    self.vuNeverConsentIcon.layer.borderColor = iconBorderColor.CGColor;
    self.vuNeverConsentIcon.layer.borderWidth = 2.0;
    [C411StaticHelper makeCircularView:self.vuNeverConsentIcon];

    self.vuBePoliteIcon.layer.borderColor = iconBorderColor.CGColor;
    self.vuBePoliteIcon.layer.borderWidth = 2.0;
    [C411StaticHelper makeCircularView:self.vuBePoliteIcon];
    
    ///Set Remember me text with dynamic app name
    self.lblRememberMeText.text = [NSString localizedStringWithFormat:NSLocalizedString(@"REMEMBER: The police are allowed to LIE to you in order to incriminate you! You do not have to speak or answer any questions. Use %@ to stream live video to your friends and record the interaction. It cannot be detected by the police even if your phone is destroyed or confiscated!",nil),LOCALIZED_APP_NAME];

}

@end
