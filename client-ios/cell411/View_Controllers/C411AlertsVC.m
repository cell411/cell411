//
//  C411AlertsVC.m
//  cell411
//
//  Created by Milan Agarwal on 22/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411AlertsVC.h"
#import "C411Cell411AlertsVC.h"
#import "C411RideRequestsVC.h"
#import "C411StaticHelper.h"
#import "C411ColorHelper.h"
#import "Constants.h"

#define TAG_TAB_TITLE 101

@interface C411AlertsVC ()<ViewPagerDataSource,ViewPagerDelegate>
@end

@implementation C411AlertsVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = self;
    self.delegate = self;
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

-(void)configureViews
{
    self.title = NSLocalizedString(@"Alerts", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)applyColors {
    ///Set colors of tab labels
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    for (UIView *tabView in self.tabs) {
        UILabel *lblTabTitle = [tabView viewWithTag:TAG_TAB_TITLE];
        if([lblTabTitle isKindOfClass:[UILabel class]]) {
            lblTabTitle.textColor = primaryTextColor;
        }
    }
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


//****************************************************
#pragma mark - ViewPagerDataSource Methods
//****************************************************

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    NSInteger tabCount = 1;
#if RIDE_HAILING_ENABLED
    tabCount++;
#endif
    
    return tabCount;
    
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    NSString *strTabTitle = nil;
    
    switch (index) {
        case 0:
        {
            NSString *strLocalizedAppName = LOCALIZED_APP_NAME;
#if (!APP_IER)
            
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_8_x_Max) {
                ////iOS 8 or below
                strLocalizedAppName = [strLocalizedAppName uppercaseStringWithLocale:[NSLocale currentLocale]];

            }
            else{
                ///iOS 9 or later
                strLocalizedAppName = strLocalizedAppName.localizedUppercaseString;

            }
#endif
            strTabTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ ALERTS",nil),strLocalizedAppName];

        }
            break;
        case 1:
            strTabTitle = NSLocalizedString(@"RIDE REQUESTS", nil);
            break;
        default:
            break;
    }
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:14.0];
    label.text = strTabTitle;
    label.textAlignment = NSTextAlignmentCenter;
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    label.textColor = primaryTextColor;
    label.tag = TAG_TAB_TITLE;
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0:{
            
            C411Cell411AlertsVC *cell411AlertsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411Cell411AlertsVC"];
            return cell411AlertsVC;
            
            
        }
        case 1:{
            
            C411RideRequestsVC *rideRequestsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411RideRequestsVC"];
            return rideRequestsVC;
            
        }
        default:
            break;
    }
    
    return nil;
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 1.0;
        case ViewPagerOptionTabLocation:
            return 1.0;
        case ViewPagerOptionTabHeight:
            return 49.0;
        case ViewPagerOptionTabOffset:
            return 36.0;
        case ViewPagerOptionTabWidth:
            return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 182.0 : 160.0;
        case ViewPagerOptionFixFormerTabsPositions:
            return 1.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 1.0;
        default:
            return value;
    }
}

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [C411ColorHelper sharedInstance].themeColor;
        case ViewPagerTabsView:
            return [C411ColorHelper sharedInstance].cardColor;
        case ViewPagerContent:
            return [C411ColorHelper sharedInstance].backgroundColor;
        default:
            return color;
    }
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
    [self setNeedsReloadColors];
}


@end
