//
//  C411BaseVC.m
//  cell411
//
//  Created by Milan Agarwal on 22/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411BaseVC.h"
#import "C411NotificationVC.h"
#import "AppDelegate.h"
#import "C411AppDefaults.h"

@interface C411BaseVC ()

@end

@implementation C411BaseVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![C411AppDefaults isBroadcastEnabled]) {
    
        ///Remove the Notification bar button if broadcasting is not enabled
        NSArray *arrRightBarButtons = self.navigationItem.rightBarButtonItems;
        NSMutableArray *arrBarBtnsWithoutNotification = [NSMutableArray array];
        
        for (UIBarButtonItem *rightBarButtonItem in arrRightBarButtons) {
            
            if(!(rightBarButtonItem.action == @selector(barBtnNotificationTapped:))){
            
                ///Add non notification bar buttons to array
                [arrBarBtnsWithoutNotification addObject:rightBarButtonItem];
            }
        }
        
        ///Set the new array of right bar button items
        self.navigationItem.rightBarButtonItems = arrBarBtnsWithoutNotification;
        

    }
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
#pragma mark - Action Methods
//****************************************************

- (IBAction)barBtnRevealSideMenuTapped:(UIBarButtonItem *)sender {
    
    switch (sender.tag) {
        case TAG_HIDE_LEFT_MENU:
            if ([_revealDelegate respondsToSelector:@selector(movePanelToOriginalPosition)]) {
                [_revealDelegate movePanelToOriginalPosition];
            }
            break;
            
        case TAG_SHOW_LEFT_MENU:
            [_revealDelegate movePanelToRight];
            [self.view endEditing:YES];
        default:
            break;
    }
    
    
}

- (IBAction)barBtnNotificationTapped:(UIBarButtonItem *)sender {
    
    C411NotificationVC *notificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411NotificationVC"];
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:notificationVC animated:YES];
}

@end
