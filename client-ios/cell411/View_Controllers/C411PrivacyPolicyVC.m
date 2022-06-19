//
//  C411PrivacyPolicyVC.m
//  cell411
//
//  Created by Milan Agarwal on 31/07/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411PrivacyPolicyVC.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "MAGCheckbox.h"
#import "C411ColorHelper.h"

@interface C411PrivacyPolicyVC ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *txtVuTitle;
@property (weak, nonatomic) IBOutlet UITextView *txtVuSubtitle;
@property (weak, nonatomic) IBOutlet UIView *vuContentContainerShadow;
@property (weak, nonatomic) IBOutlet UIView *vuContentContainer;
@property (strong, nonatomic) IBOutletCollection(MAGCheckbox) NSArray *btnCheckboxCollection;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblTermsCollection;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *vuTermsSeparatorCollection;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
- (IBAction)btnOkTapped:(UIButton *)sender;
- (IBAction)btnPolicyTapped:(UIButton *)sender;
@end

@implementation C411PrivacyPolicyVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    [self registerForNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
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

-(void)configureViews {
    
    ///set corner radius
    self.vuContentContainer.layer.cornerRadius = 5.0f;
    self.vuContentContainer.layer.masksToBounds = YES;
    self.btnOk.layer.cornerRadius = 4.0f;
    self.btnOk.layer.masksToBounds = YES;
    
    ///set shadow
    self.vuContentContainerShadow.layer.shadowOffset = CGSizeZero;
    self.vuContentContainerShadow.layer.shadowOpacity = 0.4;
    self.vuContentContainerShadow.layer.shadowRadius = 5;
    self.vuContentContainerShadow.layer.masksToBounds = NO;
    
    
    ///Disable OK button initially
    self.btnOk.enabled = NO;
    self.btnOk.alpha = 0.6f;
    
    [self applyColors];
}

-(void)applyColors {
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set color on title and subtitle
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.txtVuTitle.textColor = primaryTextColor;

    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.txtVuSubtitle.textColor = secondaryTextColor;
    
    ///Set shadow color
    self.vuContentContainerShadow.layer.shadowColor = secondaryTextColor.CGColor;
    ///Set background color on content container
    self.vuContentContainer.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    
    ///Set Theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnOk.backgroundColor = themeColor;
    
    ///Set checkbox color
    for (MAGCheckbox *checkBox in self.btnCheckboxCollection) {
        checkBox.fillColor = themeColor;
        checkBox.borderColor = secondaryTextColor;
    }
    ///Set terms text color
    for (UILabel *lblTerm in self.lblTermsCollection) {
        lblTerm.textColor = primaryTextColor;
    }
    ///Set terms separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    for (UIView *vuTermSeparator in self.vuTermsSeparatorCollection) {
        vuTermSeparator.backgroundColor = separatorColor;
    }
    
    ///Setup links
    [self setupLinks];
}

-(void)registerForNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setupLinks {
    ///Setup link on title
    NSString *strPrivacyPolicy = NSLocalizedString(@"Privacy Policy", nil);
    NSString *strPrivacyPolicyFullText = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ Update",nil),strPrivacyPolicy];
    NSDictionary *dictParams = @{kInternalLinkParamType:kInternalLinkParamTypeShowPrivacyPolicy};
    [self setupLinkOnTextView:self.txtVuTitle withCompleteString:strPrivacyPolicyFullText andLinkString:strPrivacyPolicy andLinkParams:dictParams];
    self.txtVuTitle.delegate = self;
    
    ///Setup link on subtitle
    NSString *strTerms = NSLocalizedString(@"terms", nil);
    NSString *strTermsFullText = [NSString localizedStringWithFormat:NSLocalizedString(@"Please confirm that you agree to our %@ and check each of the points below, hereby acknowledging that you took them into consideration and agree with all of them.",nil),strTerms];
    NSDictionary *dictSubtitleParams = @{kInternalLinkParamType:kInternalLinkParamTypeShowTermsAndConditions};
    [self setupLinkOnTextView:self.txtVuSubtitle withCompleteString:strTermsFullText andLinkString:strTerms andLinkParams:dictSubtitleParams];
    self.txtVuSubtitle.delegate = self;
}

-(void)setupLinkOnTextView:(UITextView *)txtVu withCompleteString:(NSString *)strFullText andLinkString:(NSString *)strLinkText andLinkParams:(NSDictionary *)dictLinkParams
{
    NSDictionary *dictLinkTextAttr = @{NSForegroundColorAttributeName:txtVu.textColor};
    txtVu.linkTextAttributes = dictLinkTextAttr;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *dictMainAttr = @{NSFontAttributeName:txtVu.font,
                                   NSForegroundColorAttributeName:txtVu.textColor,
                                   NSParagraphStyleAttributeName:paragraphStyle};
    NSMutableAttributedString *attribStrFullText = [[NSMutableAttributedString alloc]initWithString:strFullText attributes:dictMainAttr];

    NSDictionary *dictSubAttr = @{NSFontAttributeName:txtVu.font,
                                  NSUnderlineStyleAttributeName:
                                      @(NSUnderlineStyleSingle)};

    ///set attributes on link text
    ///1. make range
    NSRange linkRange = [attribStrFullText.string rangeOfString:strLinkText];
    if (linkRange.location != NSNotFound) {
        
        ///2. set link attribute
        [attribStrFullText setAttributes:dictSubAttr range:linkRange];
        
        ///3. add link attribute
        NSURL *url = [NSURL URLWithString:[ServerUtility stringByAppendingParams:dictLinkParams toUrlString:kInternalLinkBaseURL]];
        [attribStrFullText addAttribute:NSLinkAttributeName value:url range:linkRange];
        
    }
    
    [attribStrFullText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attribStrFullText.string.length)];
    
    txtVu.attributedText = attribStrFullText;

}

-(void)toggleTickIconWithTag:(NSInteger)tag
{
    for (MAGCheckbox *checkBox in self.btnCheckboxCollection) {
        if(checkBox.tag == tag){
            checkBox.selected = !checkBox.isSelected;
            break;
        }
    }
}

-(BOOL)isAllOptionSelected
{
    for (MAGCheckbox *checkBox in self.btnCheckboxCollection) {
        if(!checkBox.isSelected){
            return NO;
        }
    }
    return YES;
}

-(void)handleInternalUrl:(NSURL *)url
{
    
    ///Parse the url and get the type value to take corresponding action
    NSDictionary *dictParams = [ServerUtility getParamsFromUrl:url];
    
    if (dictParams) {
        
        ///get the type value
        NSString *strType = dictParams[kInternalLinkParamType];
        if ([strType isEqualToString:kInternalLinkParamTypeShowPrivacyPolicy]) {
            
            [self showPrivacyPolicy];
            
        }
        else if ([strType isEqualToString:kInternalLinkParamTypeShowTermsAndConditions]) {
            
            [self showTermsAndConditions];
            
        }
    }
    
    
}

-(void)showPrivacyPolicy
{
    NSURL *privacyPolicyUrl = nil;
    if(self.strPrivacyPolicyUrl.length > 0){
        privacyPolicyUrl = [NSURL URLWithString:self.strPrivacyPolicyUrl];
    }
    else{
        privacyPolicyUrl = [NSURL URLWithString:PRIVACY_POLICY_URL];
    }
    if (privacyPolicyUrl && [[UIApplication sharedApplication]canOpenURL:privacyPolicyUrl]) {
        
        [[UIApplication sharedApplication]openURL:privacyPolicyUrl];
    }
}

-(void)showTermsAndConditions
{
    NSURL *termsAndConditionsUrl = nil;
    if(self.strTermsAndConditionsUrl.length > 0){
        termsAndConditionsUrl = [NSURL URLWithString:self.strTermsAndConditionsUrl];
    }
    else{
        termsAndConditionsUrl = [NSURL URLWithString:TERMS_AND_CONDITIONS_URL];
    }

    if (termsAndConditionsUrl && [[UIApplication sharedApplication]canOpenURL:termsAndConditionsUrl]) {
        
        [[UIApplication sharedApplication]openURL:termsAndConditionsUrl];
    }
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnOkTapped:(UIButton *)sender {
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if(currentUser){
        PFObject *userConsent = [PFObject objectWithClassName:kUserConsentClassNameKey];
        userConsent[kUserConsentUserIdKey] = currentUser.objectId;
        userConsent[kUserConsentPrivacyPolicyIdKey] = self.strPrivacyPolicyId;
        [userConsent saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                [userConsent saveEventually];
                NSLog(@"Saving eventually");
            }
            else{
                NSLog(@"Consent saved");
            }
        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)btnPolicyTapped:(UIButton *)sender {
    
    [self toggleTickIconWithTag:sender.tag];
    if([self isAllOptionSelected]){
        self.btnOk.enabled = YES;
        self.btnOk.alpha = 1.0f;
    }
    else{
        self.btnOk.enabled = NO;
        self.btnOk.alpha = 0.6f;
    }
}

//****************************************************
#pragma mark - UITextViewDelegate Methods
//****************************************************

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    // Call your method here.
    [self handleInternalUrl:URL];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    // Call your method here.
    [self handleInternalUrl:URL];
    return NO;
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
