//
//  C411ViewPhotoVC.m
//  cell411
//
//  Created by Milan Agarwal on 02/11/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411ViewPhotoVC.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "UIImageView+ImageDownloadHelper.h"

@interface C411ViewPhotoVC ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgVuPhoto;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlVuBase;
@property (weak, nonatomic) IBOutlet UIView *vuImgPlaceholderBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuPlaceholder;
@property (weak, nonatomic) IBOutlet UILabel *lblNoProfilePicAvailable;
@end

@implementation C411ViewPhotoVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///post notification that it's being displayed
    [[NSNotificationCenter defaultCenter]postNotificationName:kDidOpenedPhotoVCNotification object:nil];

    /*
    CGRect imgVuFrame = self.imgVuPhoto.frame;
    CGSize vuSize = self.view.bounds.size;
    vuSize.height = vuSize.height - 64; ///remove navigation height
    imgVuFrame.size = vuSize;
    self.imgVuPhoto.frame = imgVuFrame;
    self.imgVuPhoto.translatesAutoresizingMaskIntoConstraints = YES;
     */
    [self configureViews];
    
    if (self.imgPhoto) {
        ///Photo image is provided, so show photo using that
        [self showPhotoUsingImage:self.imgPhoto];
        
    }
    else if (self.user){
        
        ///Photo image is not provided but user object is provided, so load user avatar using user object
        [self showPhotoUsingUser:self.user];
    }
    else if (self.photoFile) {
        ///Photo file is already available which means notification may be fetched from parse
        [self showPhotoUsingPhotoFile:self.photoFile];
    }
    else{
        ///Photo file is not available which can happen if user taps on push notification to view photo alert instead of being pulled from parse
        [self showPhotoUsingAlertId:self.strCell411AlertId];
    }
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
    self.strCell411AlertId = nil;
    self.photoFile = nil;
    self.strAdditionalNote = nil;
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
    [[NSNotificationCenter defaultCenter]postNotificationName:kDidClosedPhotoVCNotification object:nil];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    if(self.user){
        self.title = [C411StaticHelper getFullNameUsingFirstName:self.user[kUserFirstnameKey] andLastName:self.user[kUserLastnameKey]];
    }
    else{
        self.title = NSLocalizedString(@"Photo Alert", nil);
    }
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
}

-(void)showPhotoUsingAlertId:(NSString *)strCell411AlertId
{
    if (strCell411AlertId) {
        __weak typeof(self) weakSelf = self;
        
        ///1.Get the photo file from Parse
        PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [getCell411AlertQuery whereKey:@"objectId" equalTo:strCell411AlertId];
        [getCell411AlertQuery selectKeys:@[kCell411AlertPhotoKey]];
        [getCell411AlertQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error && objects.count > 0) {
                
                PFObject *cell411Alert = [objects firstObject];
                PFFileObject *photoFile = cell411Alert[kCell411AlertPhotoKey];
                if (photoFile) {
                    ///Photo file object fetched, now fetch the photo using this file object and show the photo
                    [weakSelf showPhotoUsingPhotoFile:photoFile];
                }
                else{
                   
                    ///photo file not available
                    NSString *errorString = NSLocalizedString(@"Unable to load the photo", nil);
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                    
                }
               
                
                
            }
            else {
                
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                
                
            }
            
            
            
        }];
        
    }
}

-(void)showPhotoUsingPhotoFile:(PFFileObject *)photoFile
{
    if (photoFile) {
        __weak typeof(self) weakSelf = self;
        ///Get photo file
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError * error){
        
            if (!error) {
                
                ///make image from data
                if (data) {
                    
                   UIImage *image = [UIImage imageWithData:data];
                    
                    if (image) {
                        ///Show image on main thread
                        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                            
                            ///hide the placeholder image base view
                            self.vuImgPlaceholderBase.hidden = YES;

                            weakSelf.imgVuPhoto.image = image;
                           
                        }];
                    }
                    else{
                        
                        NSString *errorString = NSLocalizedString(@"Unable to load the photo", nil);
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                    }
                    
                    
                    
                }
                else{
                
                    NSString *errorString = NSLocalizedString(@"Unable to load the photo", nil);
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                }
                
                
            }
            else {
                
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                
                
            }

        }];
        
    }
}

-(void)showPhotoUsingImage:(UIImage *)imgPhoto
{

    if (imgPhoto) {
        __weak typeof(self) weakSelf = self;
        ///Show image on main thread
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            
            ///hide the placeholder image base view
            self.vuImgPlaceholderBase.hidden = YES;

            weakSelf.imgVuPhoto.image = imgPhoto;
            
        }];
    }

}


-(void)showPhotoUsingUser:(PFUser *)user
{
    ///set the default image first, then fetch the gravatar
    UIImage *avatarPlaceHolder = [UIImage imageNamed:@"ic_placeholder"];
    __weak typeof(self) weakSelf = self;
    ///Show image on main thread
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        
        weakSelf.imgVuPlaceholder.image = avatarPlaceHolder;
        if (user) {
            [weakSelf.imgVuPhoto setAvatarForUser:user shouldFallbackToGravatar:YES ofSize:weakSelf.imgVuPhoto.bounds.size.width * 3 roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
                
                if (!image) {
                    
                    ///show This user has no profile picture available
                    weakSelf.lblNoProfilePicAvailable.hidden = NO;
                }
                else{
                
                    ///hide the placeholder image base view
                    self.vuImgPlaceholderBase.hidden = YES;

                }
                
            }];
        }

    }];


    
}


//****************************************************
#pragma mark - UIScrollViewDelegate Methods
//****************************************************

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgVuPhoto;
}

@end
