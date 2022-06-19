//
//  MAGBackActionCallbackVC.m
//  cell411
//
//  Created by Milan Agarwal on 20/02/19.
//  Copyright © 2019 Milan Agarwal. All rights reserved.
//

#import "MAGBackActionCallbackVC.h"

@interface MAGBackActionCallbackVC ()

@end

@implementation MAGBackActionCallbackVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    if(!parent){
        ///Moving back to parent VC
        [self mag_viewDidBack];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)mag_viewDidBack {
    ///Empty implementation of mag_viewDidBack
}
@end
