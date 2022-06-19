//
//  UINavigationController+OrientaionCategory.m
//  GaurSons
//
//  Created by Milan Agarwal on 14/11/13.
//  Copyright (c) 2013 Milan Agarwal. All rights reserved.
//

#import "UINavigationController+OrientaionCategory.h"
#import "AppDelegate.h"
@implementation UINavigationController (OrientaionCategory)
-(BOOL)shouldAutorotate
{
    AppDelegate *appDelegate = [AppDelegate sharedInstance];
    if (appDelegate.shouldRotate) {
        return YES;
    }
    
    return YES;
}


-(NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        AppDelegate *appDelegate = [AppDelegate sharedInstance];
        if (appDelegate.shouldRotate) {
            return UIInterfaceOrientationMaskAll;
        }
        return (UIInterfaceOrientationMaskPortrait| UIInterfaceOrientationMaskPortraitUpsideDown);
    }
    else{
        AppDelegate *appDelegate = [AppDelegate sharedInstance];
        if (appDelegate.shouldRotate) {
            return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
        }
        return (UIInterfaceOrientationMaskPortrait);
    
    
    }
        //return UIInterfaceOrientationMaskAllButUpsideDown ;

}

@end
