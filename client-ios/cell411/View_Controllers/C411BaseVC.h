//
//  C411BaseVC.h
//  cell411
//
//  Created by Milan Agarwal on 22/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TAG_HIDE_LEFT_MENU              1001
#define TAG_SHOW_LEFT_MENU              1002

@protocol C411BaseVCDelegate  <NSObject>

@optional

-(void)movePanelToOriginalPosition;

@required
-(void)movePanelToRight;


@end

@interface C411BaseVC : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnRevealSideMenu;


- (IBAction)barBtnRevealSideMenuTapped:(UIBarButtonItem *)sender;
- (IBAction)barBtnNotificationTapped:(UIBarButtonItem *)sender;
@property (nonatomic, assign)id<C411BaseVCDelegate> revealDelegate;

@end
