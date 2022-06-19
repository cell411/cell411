//
//  C411StaticHelper.m
//  cell411
//
//  Created by Milan Agarwal on 14/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411StaticHelper.h"
#import "NSFileManager+DoNotBackUp.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "RFGravatarImageView.h"
#import "PFFacebookUtils.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "MAAlertPresenter.h"
#import "DateHelper.h"
#import "UIImage+ResizeAdditions.h"
#import "MA_Country.h"


@import UserNotifications;

#if FB_ENABLED
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#endif

static NSString *docDirPath;

@implementation C411StaticHelper
//****************************************************
#pragma mark - Generic Helper Methods
//****************************************************

+(void)showAlertWithTitle:(NSString *)strTitle message:(NSString *)strMessage onViewController:(UIViewController *)viewController
{
    if ([UIAlertController class]) {
        ///Show UIAlertController
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:strTitle message:strMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            ///Do anything required on OK action
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        [alertController addAction:okAction];
        //[viewController presentViewController:alertController animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

        
    }
    else{
        
        ///Show UIAlertView
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:strTitle message:strMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
        [alert show];
        
    }
    
    
    
}

+(BOOL)canUseJsonObject:(id)jsonObject
{
    if(jsonObject && (![jsonObject isKindOfClass:[NSNull class]]))
    {
        if ([jsonObject isKindOfClass:[NSString class]] && ([[(NSString *)jsonObject lowercaseString]isEqualToString:@"null"])) {
            
            return NO;
        }
        return YES;
    }
    
    return NO;
}

+ (UIImage *)getRoundedRectImageFromImage :(UIImage *)image withSize:(CGSize)imageSize withCornerRadius :(float)cornerRadius
{
    
    if (image.size.width != image.size.height) {
        
        ///Resize the image with Aspect Fill mode first to resolve image distortion
       UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:imageSize interpolationQuality:kCGInterpolationHigh];

        // Crop out any part of the image that's larger than the thumbnail size
        // The cropped rect must be centered on the resized image
        // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
        float squareSize = imageSize.width;
        CGRect cropRect = CGRectMake(round((resizedImage.size.width - squareSize) / 2),
                                     round((resizedImage.size.height - squareSize) / 2),
                                     squareSize,
                                     squareSize);
        image = [resizedImage croppedImage:cropRect];

    }
    
    CGRect imageBounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    [[UIBezierPath bezierPathWithRoundedRect:imageBounds
                                cornerRadius:cornerRadius] addClip];
    [image drawInRect:imageBounds];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+(void)configurePromptView:(UIView *)view
{
    //UIBezierPath *bPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:10];
    // view.layer.shadowPath = bPath.CGPath;
    //[view.layer setMasksToBounds:NO];
    [view.layer setCornerRadius:10];
    [view.layer setMasksToBounds:YES];
}


// Assumes input like "00FF00" (RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    //[scanner setScanLocation:1]; //to bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

// Assumes input like "00FF00" (RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString andAlpha:(CGFloat)alpha{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    //[scanner setScanLocation:1]; //to bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}


+(NSString *)getFullNameUsingFirstName:(NSString *)strFirstName andLastName:(NSString *)strLastName
{
    NSString *strFullName = nil;
    if (strFirstName.length > 0 && strLastName.length > 0) {
        strFullName = [NSString stringWithFormat:@"%@ %@",strFirstName,strLastName];
    }
    else if (strFirstName.length > 0){
        
        strFullName = strFirstName;
    }
    else if (strLastName.length > 0){
        
        strFullName = strLastName;
    }
    
    return strFullName;
    
}

+(MKCoordinateRegion)regionForBoundary:(MapRegionBoundary )boundary marginSpanPercent:(CGPoint)percentage
{
    MKCoordinateSpan span   = MKCoordinateSpanMake((boundary.maxlat - boundary.minlat), (boundary.maxlon - boundary.minlon));
    
    span.latitudeDelta = span.latitudeDelta + span.latitudeDelta*percentage.x;
    span.longitudeDelta = span.longitudeDelta + span.longitudeDelta*percentage.y;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(boundary.minlat + span.latitudeDelta/2.f
                                                               , boundary.minlon + span.longitudeDelta/2.f);
    MKCoordinateRegion region = MKCoordinateRegionMake( center, span);
    return region;
}

+(MKPolyline *)polineWithGoogleEncoded:(NSString *)encodedString
{
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
   
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
    free(coords);
    
    return polyline;
}

+(GMSPolyline *)googlePolylineWithGoogleEncoded:(NSString *)encodedString
{
    /* Applying the algorithm itself
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    GMSMutablePath *path = [GMSMutablePath path];
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        
        [path addLatitude:finalLat longitude:finalLon];
        
        
    }
    
    if (path.count > 0) {
        
        CLLocationCoordinate2D pathStartCoord = [path coordinateAtIndex:0];
        [path addLatitude:pathStartCoord.latitude longitude:pathStartCoord.longitude];
    }
     */
    
    GMSMutablePath *path = [GMSMutablePath pathFromEncodedPath:encodedString];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    
    
    return polyline;
}

+(void)focusMap:(GMSMapView *)mapView toShowAllMarkers:(NSArray *)arrMarkers
{
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    
    for (GMSMarker *marker in arrMarkers)
        bounds = [bounds includingCoordinate:marker.position];
    
    [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];
}

+(float)roundOffToHigherSide:(float)number
{
    int divider = number;
    float remainder = fmodf(number, (float)divider);
    if (remainder>0) {
        number = number+ 1 - remainder;
    }
    return number;
}


///Parse Helpers
+(void)sendInviteEmailTo:(NSString *)strEmailId from:(NSString *)strFullName withSenderEmail:(NSString *)strSenderEmail andCompletion:(PFIdResultBlock)completion
{
    if (strEmailId.length > 0) {
        
        NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
        dictParams[kSendInviteFuncParamEmailKey] = strEmailId;
        dictParams[kSendInviteFuncParamNameKey] = strFullName;
        dictParams[kSendInviteFuncParamSenderEmailKey] = strSenderEmail;
        
         [self callFunctionInBackground:kSendInviteFuncNameKey withParams:dictParams andCompletion:completion];
        
    }
    else{
        
        NSLog(@"Email id should not be empty");
    }
   
}

+(void)sendVerificationRequestWithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion
{
    
    [self callFunctionInBackground:kSendVerificationReqFuncNameKey withParams:dictParams andCompletion:completion];
    
}

+(void)sendAlertWithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion
{
    
    [self callFunctionInBackground:kSendAlertFuncNameKey withParams:dictParams andCompletion:completion];
    
}

+(void)sendAlertV2WithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion
{
     [self callFunctionInBackground:kSendAlertV2FuncNameKey withParams:dictParams andCompletion:completion];
    
}

+(void)sendAlertV3WithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion
{
    [self callFunctionInBackground:kSendAlertV3FuncNameKey withParams:dictParams andCompletion:completion];
    
}


+(void)sendSMSAndEmailAlertWithDetails:(NSMutableDictionary *)dictParams cloudFuncName:(NSString *)strCloudFuncName andCompletion:(PFIdResultBlock)completion
{
    
    [self callFunctionInBackground:strCloudFuncName withParams:dictParams andCompletion:completion];
    
}


+(void)getAverageStarsForUserWithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion
{

    [self callFunctionInBackground:kAverageStarsFuncNameKey withParams:dictParams andCompletion:completion];
    
}

+(void)retrieveTotalSelectedMembersWithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion
{
    [self callFunctionInBackground:kRetrieveTotalSelectedMembersFuncNameKey withParams:dictParams andCompletion:completion];
    
}


+(void)sendChatMessage:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion
{
    
     [self callFunctionInBackground:kSendMessageFuncNameKey withParams:dictParams andCompletion:completion];
}

+(void)broadcastMessage:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion
{
    
    [self callFunctionInBackground:kBroadcastMessageFuncNameKey withParams:dictParams andCompletion:completion];
    
}

+(void)sendChangeIntimationToPublicCellMembersWithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion
{
    [self callFunctionInBackground:kChgIntmnToPubCellMembersFuncNameKey withParams:dictParams andCompletion:completion];
    
}

#if IS_CONTACTS_SYNCING_ENABLED

+(void)uploadContacts:(NSMutableDictionary *)dictParams withCompletion:(PFIdResultBlock)completion
{
    [self callFunctionInBackground:kUploadContactsFuncNameKey withParams:dictParams andCompletion:completion];
    
}

+(void)deleteContactsWithCompletion:(PFIdResultBlock)completion
{
    
    [self callFunctionInBackground:kDeleteContactsFuncNameKey withParams:nil andCompletion:completion];
    
}

+(void)sendJoinedNotificationWithCompletion:(PFIdResultBlock)completion
{
    
    [self callFunctionInBackground:kSendJoinedNotificationFuncNameKey withParams:nil andCompletion:completion];
}


#endif


/*
+(void)sendForgotPasswordRequestWithDetails:(NSDictionary *)dictParams andCompletion:(PFIdResultBlock)completion
{
    [PFCloud callFunctionInBackground:kForgotPasswordReqFuncNameKey withParameters:dictParams block:^(PFObject *object,  NSError *error){
        
        if (completion != NULL) {
            
            completion(object, error);
        }
        
    }];
}
*/

+(void)deleteMyAccountWithCompletion:(PFIdResultBlock)completion
{
    [self callFunctionInBackground:kDeleteUserFuncNameKey withParams:nil andCompletion:completion];
}

+(void)downloadMyDataWithCompletion:(PFIdResultBlock)completion
{
    [self callFunctionInBackground:kDownloadUserDataFuncNameKey withParams:nil andCompletion:completion];
}

+(void)callFunctionInBackground:(NSString *)strFuncName withParams:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion
{
    
    if(strFuncName.length > 0){
        
        ///Append common keys to params dictionary
        if(!dictParams){
        
            dictParams = [NSMutableDictionary dictionary];
        }
        
        dictParams[kClientFirmIdKey] = CLIENT_FIRM_ID;
        dictParams[kIsLiveKey] = IS_APP_LIVE;
        dictParams[kLanguageCodeKey] = [self getAppLanguageCode:YES];
        dictParams[API_PARAM_PLATFORM] = API_PLATFORM_VALUE;
        
        [PFCloud callFunctionInBackground:strFuncName withParameters:dictParams block:^(id object,  NSError *error){
            
            if (completion != NULL) {
                
                completion(object, error);
            }
            
        }];
        
    }
    
}

+(void)setAverageRatingForUserWithDetails:(NSMutableDictionary *)dictParams onLabel:(UILabel *)lblAvgRating
{
    __weak typeof(self) weakSelf = self;
    [self getAverageStarsForUserWithDetails:dictParams andCompletion:^(id  _Nullable object, NSError * _Nullable error) {
        
        if (!error) {
            
            NSString *strRatingComponents = (NSString *)object;
            NSArray *arrRatingComponents = [strRatingComponents componentsSeparatedByString:@","];
            if (arrRatingComponents.count == 2) {
                
                NSString *strAvgRating = [arrRatingComponents lastObject];
                lblAvgRating.text = [weakSelf getDecimalStringFromNumber:@([strAvgRating floatValue]) uptoDecimalPlaces:1];
                
               
            }
            else{
                
                ///show N/A
                lblAvgRating.text = NSLocalizedString(@"N/A", nil);

            }
            
        }
        else{
            
            ///show N/A
            lblAvgRating.text = NSLocalizedString(@"N/A", nil);

            
        }
        
    }];
}

+(void)getPublicCellWithObjectId:(NSString *)strObjectId andCompletion:(PFObjectResultBlock)completion
{

    PFQuery *fetchPublicCellQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
    [fetchPublicCellQuery whereKey:@"objectId" equalTo:strObjectId];
    [fetchPublicCellQuery includeKey:kPublicCellCreatedByKey];

    [fetchPublicCellQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        if (completion != NULL) {
            
            completion(object,error);
        }
    
    }];
    
}

+(void)savePrivilege:(NSString *)strPrivilege forUser:(PFUser *)user withOptionalCompletion:(PFBooleanResultBlock)optionalCompletion
{
    NSLog(@"Saving privilege: %@",strPrivilege);
    
    user[kUserPrivilegeKey] = strPrivilege;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (error) {
            ///save it eventually if error occured to make sure privilege is set
            [user saveEventually];
            
        }
        
        if (optionalCompletion != NULL) {
            ///If optionalCompletion is available call it, so that listener can do other handling if possible
            
            optionalCompletion(succeeded, error);
            
        }
        
    }];
}

+(void)getFriendCountForUser:(PFUser *)user withCompletion:(PFIntegerResultBlock)completion
{
    ///Get the friends count
    PFRelation *friendsRelation = [user relationForKey:kUserFriendsKey];
    PFQuery *getFriendCountQuery = [friendsRelation query];
    [getFriendCountQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        
        if (completion != NULL) {
            
            completion(number,error);
            
        }
        
    }];
}

+(void)setSecondPrivilegeIfApplicableForUser:(PFUser *)user
{
    ///SECOND privilege will be set if his current privilege is either undefined(i.e nil) or FIRST and user has defined number of friends (may be 2) and issued atleast one alert to a private cell
    
    __weak typeof(self) weakSelf = self;
    
    ///Get all the keys of user object
    [user fetchInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            NSString *strPrivilege = user[kUserPrivilegeKey];
            if ((!strPrivilege)
                || (strPrivilege.length == 0)
                ||([strPrivilege isEqualToString:kPrivilegeTypeFirst])) {
                
                ///get the friends count
                [weakSelf getFriendCountForUser:user withCompletion:^(int number, NSError * _Nullable error) {
                    
                    ///check the friend count
                    if (!error) {
                        
                        if (number >= MIN_FRIENDS_FOR_SECOND_PRIVILEGE) {
                            
                            ///get the normal alert count issued by current user
                            [weakSelf didUserIssuedMinNormalAlertForSecondPrivilege:user withCompletion:^(BOOL success, BOOL isConditionSatisfied) {
                                
                                if (success) {
                                    ///successfully querried for the minimum normal alert issued condition
                                    if (isConditionSatisfied) {
                                        ///User has issued min normal alerts, set the SECOND privilege
                                        [weakSelf savePrivilege:kPrivilegeTypeSecond forUser:user withOptionalCompletion:NULL];
                                    }
                                    
                                    
                                }
                                else{
                                    
                                    ///error occured checking min normal alert issued query, do not set SECOND privelige for now
                                    NSLog(@"check privilege -> Error checking minimum normal alert issued by current user");
                                    
                                    
                                }
                                
                                
                            }];
                            
                        }
                        
                        
                    }
                    else{
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@"check privilege -> error getting friend count %@",errorString);
                        
                    }
                    
                }];
                
                
            }
            else{
                
                NSLog(@"check privilege -> privilege is other than FIRST or nil, privilege = %@",strPrivilege);
            }
            
        }
        else{
            ///some error occured fetching user object
            if (error) {
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"check privilege -> error fetching user object %@",errorString);
            }
            
        }
        
        
    }];
    
    
}


+(void)didUserIssuedMinNormalAlertForSecondPrivilege:(PFUser *)user withCompletion:(void(^)(BOOL success, BOOL isConditionSatisfied))completion
{
    
    PFQuery *minNormalAlertIssuedQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [minNormalAlertIssuedQuery whereKey:kCell411AlertIssuedByKey equalTo:user];
    [minNormalAlertIssuedQuery whereKeyExists:kCell411AlertAlertTypeKey];
    [minNormalAlertIssuedQuery whereKey:kCell411AlertIsGlobalKey notEqualTo:@1];
    [minNormalAlertIssuedQuery whereKeyExists:kCell411AlertTargetMembersKey];
    [minNormalAlertIssuedQuery whereKeyDoesNotExist:kCell411AlertCellNameKey];
    [minNormalAlertIssuedQuery whereKeyDoesNotExist:kCell411AlertCellIdKey];
    [minNormalAlertIssuedQuery whereKeyDoesNotExist:kCell411AlertEntryForKey];
    [minNormalAlertIssuedQuery whereKeyDoesNotExist:kCell411AlertToKey];
    
    PFQuery *minNormalAlertFwdQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [minNormalAlertFwdQuery whereKey:kCell411AlertForwardedByKey equalTo:user];
    [minNormalAlertFwdQuery whereKeyExists:kCell411AlertForwardedToMembersKey];
    [minNormalAlertFwdQuery whereKey:kCell411AlertIsGlobalKey notEqualTo:@1];
    [minNormalAlertFwdQuery whereKeyDoesNotExist:kCell411AlertCellNameKey];
    [minNormalAlertFwdQuery whereKeyDoesNotExist:kCell411AlertCellIdKey];
    
    PFQuery *minNormalAlertQuery = [PFQuery  orQueryWithSubqueries:@[minNormalAlertIssuedQuery,minNormalAlertFwdQuery]];
    
    minNormalAlertQuery.limit = MIN_NORMAL_ALERTS_FOR_SECOND_PRIVILEGE;
    [minNormalAlertQuery selectKeys:@[kCell411AlertAlertTypeKey]];///optimize to query to fetch only 1 key as count needs to be checked and not the data in it
    
    [minNormalAlertQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            if (objects.count >= MIN_NORMAL_ALERTS_FOR_SECOND_PRIVILEGE) {
                ///query succeeds and condition is also satisfied
                if (completion != NULL) {
                    
                    completion(YES, YES);
                }
            }
            else{
                ///query succeeds and condition is not satisfied
                if (completion != NULL) {
                    
                    completion(YES, NO);
                }
                
            }
        }
        else if (error.code == kPFErrorObjectNotFound){
            
            ///query succeeds and condition is not satisfied
            if (completion != NULL) {
                
                completion(YES, NO);
            }
        }
        else{
            
            ///some error occured making query, so we'll consider that condition is not satisfied
            if (completion != NULL) {
                
                completion(NO, NO);
            }
            
        }
        
        
    }];
}


+(void)getPrivilegeForUser:(PFUser *)user shouldSetPrivilegeIfUndefined:(BOOL)setPrivilegeIfUndef andCompletion:(PFStringResultBlock)completion
{
    ///Get all the keys of user object
    __weak typeof(self) weakSelf = self;
    [user fetchInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            ///no error and got the updated user object
            NSString *strPrivilege = user[kUserPrivilegeKey];
            if ((!strPrivilege)
                ||(strPrivilege.length == 0)) {
                
                ///privilege is not set yet, set the privilege to FIRST or SECOND depending on the criteria
                [weakSelf getFriendCountForUser:user withCompletion:^(int number, NSError * _Nullable error) {
                    
                    if (number >= MIN_FRIENDS_FOR_SECOND_PRIVILEGE) {
                        
                        ///check whether user has issued min normal alerts to be eligible for SECOND PRIVILEGE
                        [weakSelf didUserIssuedMinNormalAlertForSecondPrivilege:user withCompletion:^(BOOL success, BOOL isConditionSatisfied) {
                            
                            if (success && isConditionSatisfied) {
                                
                                ///user is eligible for SECOND PRIVILEGE
                                if (setPrivilegeIfUndef) {
                                    ///set the privilege and then send
                                    [weakSelf savePrivilege:kPrivilegeTypeSecond forUser:user withOptionalCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                                        
                                        if (completion != NULL) {
                                            
                                            ///send privilege as SECOND
                                            completion(kPrivilegeTypeSecond,nil);
                                            
                                        }
                                        
                                    }];
                                }
                                else{
                                    
                                    ///don't set, just return the privilege
                                    if (completion != NULL) {
                                        
                                        ///send privilege as SECOND
                                        completion(kPrivilegeTypeSecond,nil);
                                        
                                    }
                                    
                                }
                                
                            }
                            else if(success){
                                
                                ///user is eligible for FIRST privilege only
                                if (setPrivilegeIfUndef) {
                                    ///set the privilege and then send
                                    [weakSelf savePrivilege:kPrivilegeTypeFirst forUser:user withOptionalCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                                        
                                        if (completion != NULL) {
                                            
                                            ///send privilege as FIRST
                                            completion(kPrivilegeTypeFirst,nil);
                                            
                                        }
                                        
                                    }];
                                    
                                }
                                else{
                                    
                                    ///don't set, just return the privilege
                                    if (completion != NULL) {
                                        
                                        ///send privilege as FIRST
                                        completion(kPrivilegeTypeFirst,nil);
                                        
                                    }
                                    
                                }
                                
                            }
                            else{
                                
                                ///Error occured checking whether user issued the minimum normal alert to be eligible for SECOND privilege, create and send error object
                                NSError *error = [NSError errorWithDomain:@"Cell411ErrorDomain" code:-1002 userInfo:@{@"error":NSLocalizedString(@"Some error occurred", nil)}];
                                
                                if (completion != NULL) {
                                    completion(nil,error);
                                }
                                
                            }
                            
                        }];
                        
                    }
                    else{
                        
                        ///set the privilege to FIRST
                        [weakSelf savePrivilege:kPrivilegeTypeFirst forUser:user withOptionalCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                            
                            if (completion != NULL) {
                                
                                ///send privilege as FIRST
                                completion(kPrivilegeTypeFirst,nil);
                                
                            }
                            
                        }];
                        
                    }
                    
                }];
                
                
            }
            else{
                
                ///return the user privilege
                if (completion != NULL) {
                    
                    completion(strPrivilege,error);
                }
            }
        }
        else{
            
            ///error fetching user details
            if (completion != NULL) {
                completion(nil,error);
            }
            
        }
    }];
    
}

+(AlertType)getAlertTypeFromAlertTypeTag:(NSInteger)alertTypeTag
{
    
    switch (alertTypeTag) {
        case BTN_ALERT_TAG_PULLED_OVER:
        return AlertTypePulledOver;
        
        case BTN_ALERT_TAG_ARRESTED:
        return AlertTypePoliceArrest;
        
        case BTN_ALERT_TAG_MEDICAL_ATTENTION:
        return AlertTypeMedical;
        
        case BTN_ALERT_TAG_CAR_BROKE:
        return AlertTypeBrokeCar;
        
        case BTN_ALERT_TAG_CRIME:
        return AlertTypeCriminal;
        
        case BTN_ALERT_TAG_FIRE:
        return AlertTypeFire;
        
        case BTN_ALERT_TAG_DANGER:
        return AlertTypeDanger;
        
        case BTN_ALERT_TAG_COP_BLOCKING:
        return AlertTypePoliceInteraction;
        
        case BTN_ALERT_TAG_BULLIED:
        return AlertTypeBullied;
        
        case BTN_ALERT_TAG_GENERAL:
        return AlertTypeGeneral;
        
        case BTN_ALERT_TAG_VIDEO:
        return AlertTypeVideo;
        
        case BTN_ALERT_TAG_PHOTO:
        return AlertTypePhoto;
        
        case BTN_ALERT_TAG_PANIC:
        return AlertTypePanic;
        
        case BTN_ALERT_TAG_HIJACK:
        return AlertTypeHijack;
        
        case BTN_ALERT_TAG_FALLEN:
        return AlertTypeFallen;
        
        case BTN_ALERT_TAG_PHYSICAL_ABUSE:
        return AlertTypePhysicalAbuse;
        
        case BTN_ALERT_TAG_TRAPPED:
        return AlertTypeTrapped;
        
        case BTN_ALERT_TAG_CAR_ACCIDENT:
        return AlertTypeCarAccident;
        
        case BTN_ALERT_TAG_NATURAL_DISASTER:
        return AlertTypeNaturalDisaster;
        
        case BTN_ALERT_TAG_PRE_AUTHORIZATION:
        return AlertTypePreAuthorisation;
        
        default:
        return AlertTypeUnreconized;
    }
}

+(AlertType)getAlertTypeUsingAlertTypeString:(NSString *)strAlertRegarding
{
    if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeVehiclePulled.lowercaseString]) {
        return AlertTypePulledOver;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeArrested.lowercaseString]) {
        return AlertTypePoliceArrest;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeMedical.lowercaseString]) {
        return AlertTypeMedical;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeVehicleBroken.lowercaseString]) {
        return AlertTypeBrokeCar;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeCrime.lowercaseString]) {
        return AlertTypeCriminal;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeFire.lowercaseString]) {
        return AlertTypeFire;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeDanger.lowercaseString]) {
        return AlertTypeDanger;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeCopBlocking.lowercaseString]) {
        return AlertTypePoliceInteraction;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeBullied.lowercaseString]) {
        return AlertTypeBullied;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeGeneral.lowercaseString]) {
        return AlertTypeGeneral;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeVideo.lowercaseString]) {
        return AlertTypeVideo;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypePhoto.lowercaseString]) {
        return AlertTypePhoto;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypePanic.lowercaseString]) {
        return AlertTypePanic;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeHijack.lowercaseString]) {
        return AlertTypeHijack;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeFallen.lowercaseString]) {
        return AlertTypeFallen;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypePhysicalAbuse.lowercaseString]) {
        return AlertTypePhysicalAbuse;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeTrapped.lowercaseString]) {
        return AlertTypeTrapped;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeCarAccident.lowercaseString]) {
        return AlertTypeCarAccident;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeNaturalDisaster.lowercaseString]) {
        return AlertTypeNaturalDisaster;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypePreAuthorisation.lowercaseString]) {
        return AlertTypePreAuthorisation;
    }
    else{
        return AlertTypeUnreconized;
    }
}

+(NSString *)getShareTextForUserWithName:(NSString *)strFullName alertType:(NSInteger)alertTypeTag andAdditionalNote:(NSString *)strAdditionalNote
{
    NSString *strShareText = @"";
    switch (alertTypeTag) {
        case BTN_ALERT_TAG_PULLED_OVER:
            strShareText = NSLocalizedString(@" is being pulled over by police", nil);
            break;
            
        case BTN_ALERT_TAG_ARRESTED:
            strShareText = NSLocalizedString(@" is observing someone being arrested", nil);
            break;
            
        case BTN_ALERT_TAG_MEDICAL_ATTENTION:
            strShareText = NSLocalizedString(@" needs medical attention", nil);
            break;
            
        case BTN_ALERT_TAG_CAR_BROKE:
            strShareText = NSLocalizedString(@"'s car broke down", nil);
            break;
            
        case BTN_ALERT_TAG_CRIME:
            strShareText = NSLocalizedString(@" is observing criminal activity", nil);
            break;
            
        case BTN_ALERT_TAG_FIRE:
            strShareText = NSLocalizedString(@" is observing a fire", nil);
            break;
            
        case BTN_ALERT_TAG_DANGER:
            strShareText = NSLocalizedString(@" is in danger", nil);
            break;
            
        case BTN_ALERT_TAG_COP_BLOCKING:
            strShareText = NSLocalizedString(@" is cop blocking", nil);
            break;
        case BTN_ALERT_TAG_BULLIED:
#if APP_IER
            strShareText = NSLocalizedString(@" is being bullied", nil);
#else
            strShareText = NSLocalizedString(@" is being harassed", nil);
#endif
            break;
        case BTN_ALERT_TAG_GENERAL:
            strShareText = NSLocalizedString(@" issued this alert", nil);
            break;
        case BTN_ALERT_TAG_PANIC:
            strShareText = NSLocalizedString(@" is in panic", nil);
            break;
        case BTN_ALERT_TAG_HIJACK:
            strShareText = NSLocalizedString(@" is being hijacked", nil);
            break;
        case BTN_ALERT_TAG_FALLEN:
            strShareText = NSLocalizedString(@" is fallen", nil);
            break;
        case BTN_ALERT_TAG_PHYSICAL_ABUSE:
            strShareText = NSLocalizedString(@" is being physical abused", nil);
            break;
        case BTN_ALERT_TAG_TRAPPED:
            strShareText = NSLocalizedString(@" is trapped/lost", nil);
            break;
        case BTN_ALERT_TAG_CAR_ACCIDENT:
            strShareText = NSLocalizedString(@" had car accident", nil);
            break;
        case BTN_ALERT_TAG_NATURAL_DISASTER:
            strShareText = NSLocalizedString(@" is observing a natural disaster", nil);
            break;
        case BTN_ALERT_TAG_PRE_AUTHORIZATION:
            strShareText = NSLocalizedString(@" issued a pre-authorisation alert", nil);
            break;

        default:
            break;
    }
    
    if (strShareText.length > 0) {
        
        strShareText = [NSString stringWithFormat:@"%@%@",strFullName,strShareText];
        
        if (strAdditionalNote.length > 0) {
            strShareText = [NSString stringWithFormat:@"%@:%@",strShareText,strAdditionalNote];
        }
        
    }
    
    return strShareText;
}

+(NSString *)getAlertTypeStringUsingAlertTypeTag:(NSInteger)alertTypeTag
{
    
    NSString *strAlertType = @"";
    switch (alertTypeTag) {
        case BTN_ALERT_TAG_PULLED_OVER:
            strAlertType = kAlertTypeVehiclePulled;
            break;
            
        case BTN_ALERT_TAG_ARRESTED:
            strAlertType = kAlertTypeArrested;
            break;
            
        case BTN_ALERT_TAG_MEDICAL_ATTENTION:
            strAlertType = kAlertTypeMedical;
            break;
            
        case BTN_ALERT_TAG_CAR_BROKE:
            strAlertType = kAlertTypeVehicleBroken;
            break;
            
        case BTN_ALERT_TAG_CRIME:
            strAlertType = kAlertTypeCrime;
            break;
            
        case BTN_ALERT_TAG_FIRE:
            strAlertType = kAlertTypeFire;
            break;
            
        case BTN_ALERT_TAG_DANGER:
            strAlertType = kAlertTypeDanger;
            break;
            
        case BTN_ALERT_TAG_COP_BLOCKING:
            strAlertType = kAlertTypeCopBlocking;
            break;
        case BTN_ALERT_TAG_BULLIED:
            strAlertType = kAlertTypeBullied;
            break;
        case BTN_ALERT_TAG_GENERAL:
            strAlertType = kAlertTypeGeneral;
            break;
        case BTN_ALERT_TAG_VIDEO:
            strAlertType = kAlertTypeVideo;
            break;
        case BTN_ALERT_TAG_PHOTO:
            strAlertType = kAlertTypePhoto;
            break;
        case BTN_ALERT_TAG_PANIC:
            strAlertType = kAlertTypePanic;
            break;
        case BTN_ALERT_TAG_HIJACK:
            strAlertType = kAlertTypeHijack;
            break;
        case BTN_ALERT_TAG_FALLEN:
            strAlertType = kAlertTypeFallen;
            break;
        case BTN_ALERT_TAG_PHYSICAL_ABUSE:
            strAlertType = kAlertTypePhysicalAbuse;
            break;
        case BTN_ALERT_TAG_TRAPPED:
            strAlertType = kAlertTypeTrapped;
            break;
        case BTN_ALERT_TAG_CAR_ACCIDENT:
            strAlertType = kAlertTypeCarAccident;
            break;
        case BTN_ALERT_TAG_NATURAL_DISASTER:
            strAlertType = kAlertTypeNaturalDisaster;
            break;
        case BTN_ALERT_TAG_PRE_AUTHORIZATION:
            strAlertType = kAlertTypePreAuthorisation;
            break;
            
        default:
            break;
    }
    
    return strAlertType;
}

+(NSString *)getAlertTypeStringUsingAlertType:(AlertType)alertType
{
    
    NSString *strAlertType = @"";
    switch (alertType)
    {
        case AlertTypeBrokeCar:
            strAlertType = kAlertTypeVehicleBroken;
            break;
        
        case AlertTypeBullied:
            strAlertType = kAlertTypeBullied;
            break;
        
        case AlertTypeCriminal:
            strAlertType = kAlertTypeCrime;
            break;
        
        case AlertTypeGeneral:
            strAlertType = kAlertTypeGeneral;
            break;
        
        case AlertTypePulledOver:
            strAlertType = kAlertTypeVehiclePulled;
            break;
        
        case AlertTypeDanger:
            strAlertType = kAlertTypeDanger;
            break;
        
        case AlertTypeVideo:
            strAlertType = kAlertTypeVideo;
            break;
        
        case AlertTypePhoto:
            strAlertType = kAlertTypePhoto;
            break;
        
        case AlertTypeFire:
            strAlertType = kAlertTypeFire;
            break;
        
        case AlertTypeMedical:
            strAlertType = kAlertTypeMedical;
            break;
        
        case AlertTypePoliceInteraction:
            strAlertType = kAlertTypeCopBlocking;
            break;
        
        case AlertTypePoliceArrest:
            strAlertType = kAlertTypeArrested;
            break;
        
        case AlertTypeHijack:
            strAlertType = kAlertTypeHijack;
            break;
        
        case AlertTypePanic:
            strAlertType = kAlertTypePanic;
            break;
        
        case AlertTypeFallen:
            strAlertType = kAlertTypeFallen;
            break;
        
        case AlertTypePhysicalAbuse:
            strAlertType = kAlertTypePhysicalAbuse;
            break;
        
        case AlertTypeTrapped:
            strAlertType = kAlertTypeTrapped;
            break;
        
        case AlertTypeCarAccident:
            strAlertType = kAlertTypeCarAccident;
            break;
        
        case AlertTypeNaturalDisaster:
            strAlertType = kAlertTypeNaturalDisaster;
            break;
        
        case AlertTypePreAuthorisation:
            strAlertType = kAlertTypePreAuthorisation;
            break;
        
        default:
            break;
    }

    return strAlertType;
}



+(NSString *)getLocalizedAlertTypeStringFromString:(NSString *)strAlertType
{
    NSString *strLocalizedAlertType = nil;
    
    if ([strAlertType.lowercaseString isEqualToString:kAlertTypeVehiclePulled.lowercaseString]
        || [strAlertType isEqualToString:@"Pulled Over"]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Pulled Over", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeArrested.lowercaseString]
             || [strAlertType isEqualToString:@"Police Arrest"]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Arrested", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeMedical.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Medical", nil);
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeVehicleBroken.lowercaseString]
             || [strAlertType isEqualToString:@"Car Broken"]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Vehicle Broken", nil);
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeCrime.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Crime", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeFire.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Fire", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeDanger.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Danger", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeCopBlocking.lowercaseString]
             || [strAlertType isEqualToString:@"Police Interaction"]) {
        
        ///Rename Cop Blocking to Police Interaction in UI only
        strLocalizedAlertType = NSLocalizedString(@"Police Interaction", nil);
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeBullied.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Bullied", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeGeneral.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"General", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeHijack.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Hijack", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypePanic.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Panic", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeFallen.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Fallen", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypePhoto.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Photo", nil);
        
    }

    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeVideo.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Video", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeNaturalDisaster.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Natural Disaster", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeCarAccident.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Car Accident", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypePhysicalAbuse.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Physical Abuse", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypeTrapped.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Trapped", nil);
        
    }
    else if ([strAlertType.lowercaseString isEqualToString:kAlertTypePreAuthorisation.lowercaseString]) {
        
        strLocalizedAlertType = NSLocalizedString(@"Pre-Authorisation", nil);
        
    }
    else{
        
        strLocalizedAlertType = NSLocalizedString(@"Unrecognized", nil);
        
    }
    
    return strLocalizedAlertType;
    
    
}

+(UIImage *)snapshot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(NSString *)documentDirectoryPath
{
    if (!docDirPath) {
        ///Create Document Directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docDirPath = [paths firstObject];
        
    }
    
    return docDirPath;
}

+(BOOL)createFolderAtDocumentDirectoryWithName:(NSString *)strFolderName
{
    ///make a new directory at document directory
    NSString *directoryPath = [[self documentDirectoryPath] stringByAppendingPathComponent:strFolderName];
    
    BOOL success = [self createFolderAtPath:directoryPath];
    
    return success;
}

+(BOOL)createFolderAtPath:(NSString *)directoryPath
{
    ///make a new directory at specified path
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [defaultManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    if(!success)
    {
        NSLog(@"Some error occurred creating image directory");
    }
    
    [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:directoryPath]];
    return success;
}

+(void)appendString:(NSString *)strText atFilePath:(NSString *)strFilePath
{
    if([strText isKindOfClass:[NSString class]] && strText.length > 0){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:strFilePath])
        {
            [strText writeToFile:strFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        }
        else
        {
            NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:strFilePath];
            [myHandle seekToEndOfFile];
            [myHandle writeData:[strText dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
}

+(void)setDiagonalGradientOnView:(UIView *)view withColors:(NSArray *)arrGradientColors
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    gradientLayer.colors = arrGradientColors;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    [view.layer insertSublayer:gradientLayer atIndex:0];
    
}

+(void)setPlaceholderColor:(UIColor *)color ofTextField:(UITextField *)textField
{
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        if(textField.placeholder.length > 0) {
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
        }
        else{
            NSLog(@"Empty placeholder text");
        }
        
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}

+(void)makeCircularView:(UIView *)view
{
    view.layer.cornerRadius = view.bounds.size.width / 2;
    view.layer.masksToBounds = YES;
    
}

+(void)getGravatarForEmail:(NSString *)strEmail ofSize:(int)imageSize roundedCorners:(BOOL)roundedCorner withCompletion:(void(^)(BOOL success, UIImage *image))completion
{
    //    static UIImage *defaultPinImage = nil;
    //    if (!defaultPinImage) {
    //        defaultPinImage = [UIImage imageNamed:@"icon_default_pin"];
    //    }
    
    if (strEmail.length > 0) {
        
        ///Make a temporary imageview and set gravatar image on it
        //int imageSize = 60;
        RFGravatarImageView *tempImageView = [[RFGravatarImageView alloc]initWithFrame:CGRectMake(0, 0, imageSize, imageSize) andPlaceholder:nil];
        tempImageView.email = strEmail;
        tempImageView.defaultGravatar = RFDefaultGravatar404;
        tempImageView.size = imageSize;
        [tempImageView load:^(NSError *error) {
            UIImage *gravatar = nil;
            BOOL success = NO;
            if (!error && tempImageView.image) {
                
                gravatar = tempImageView.image;
                if (roundedCorner) {
                    
                    gravatar = [C411StaticHelper getRoundedRectImageFromImage:gravatar withSize:CGSizeMake(imageSize, imageSize) withCornerRadius:imageSize/2];
                }
                
                
                success = YES;
            }
            else{
                
                // mapPinImage = defaultPinImage;
            }
            
            if (completion) {
                
                completion(success, gravatar);
                
            }
            
            
        }];
        
    }
    else{
        
        if (completion) {
            
            completion(NO,nil);
            
        }
        
    }
}

+(NSString *)getAddressCompFromResult:(NSArray *)result forType:(NSString *)strType useLongName:(BOOL)useLongName
{
    
    NSString *comp=@"";
    
    for (NSDictionary * d in result) {
        
        
        if([[d objectForKey:@"types"] containsObject:strType])
        {
            if (useLongName) {
                comp=[d objectForKey:@"long_name"];
            }
            else{
                comp = [d objectForKey:@"short_name"];
            }
            
            break;
            
        }
    }
    
    return comp;
    
    
}

+(NSString *)getDecimalStringFromNumber:(NSNumber *)decimalNumber uptoDecimalPlaces:(int)decimalPlaces
{
    NSNumberFormatter *decimalFormatter = [[NSNumberFormatter alloc]init];
    decimalFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    decimalFormatter.maximumFractionDigits = decimalPlaces;
    decimalFormatter.decimalSeparator = @".";
    decimalFormatter.groupingSeparator = @"";
    return [decimalFormatter stringFromNumber:decimalNumber];
    
}

+(void)callOnNumber:(NSString *)strPhoneNumber
{
    NSString *strPhoneNumberURL = [@"tel://" stringByAppendingString:strPhoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strPhoneNumberURL]];
}

+(UIColor *)getColorForAlert:(NSString *)strAlertRegarding withColorType:(ColorType)colorType
{
    NSString *strColorHex = nil;
    
    if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeVideo.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_VIDEO_COLOR_LIGHT : ALERT_VIDEO_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypePhoto.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_PHOTO_COLOR_LIGHT : ALERT_PHOTO_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeVehiclePulled.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_PULLED_OVER_COLOR_LIGHT : ALERT_PULLED_OVER_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeArrested.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_ARRESTED_COLOR_LIGHT: ALERT_ARRESTED_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeMedical.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_MEDICAL_ATTENTION_COLOR_LIGHT : ALERT_MEDICAL_ATTENTION_COLOR_DARK;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeVehicleBroken.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_CAR_BROKE_COLOR_LIGHT : ALERT_CAR_BROKE_COLOR_DARK;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeCrime.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_CRIME_COLOR_LIGHT : ALERT_CRIME_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeFire.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_FIRE_COLOR_LIGHT : ALERT_FIRE_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeDanger.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_DANGER_COLOR_LIGHT: ALERT_DANGER_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeCopBlocking.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_COP_BLOCKING_COLOR_LIGHT: ALERT_COP_BLOCKING_COLOR_DARK;
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeBullied.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_BULLIED_COLOR_LIGHT : ALERT_BULLIED_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeGeneral.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_GENERAL_COLOR_LIGHT : ALERT_GENERAL_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypePanic.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_PANIC_COLOR_LIGHT : ALERT_PANIC_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeHijack.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_HIJACK_COLOR_LIGHT : ALERT_HIJACK_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeFallen.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_FALLEN_COLOR_LIGHT : ALERT_FALLEN_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeNaturalDisaster.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_NATURAL_DISASTER_COLOR_LIGHT : ALERT_NATURAL_DISASTER_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeCarAccident.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_CAR_ACCIDENT_COLOR_LIGHT : ALERT_CAR_ACCIDENT_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypePhysicalAbuse.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_PHYSICAL_ABUSE_COLOR_LIGHT : ALERT_PHYSICAL_ABUSE_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeTrapped.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_TRAPPED_COLOR_LIGHT : ALERT_TRAPPED_COLOR_DARK;
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypePreAuthorisation.lowercaseString]) {
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_PRE_AUTHORIZATION_COLOR_LIGHT: ALERT_PRE_AUTHORIZATION_COLOR_DARK;
        
    }
    else{
        
        strColorHex = (colorType == ColorTypeLight) ? ALERT_UNRECOGNIZED_COLOR_LIGHT : ALERT_UNRECOGNIZED_COLOR_DARK;
        
    }
    
    return [C411StaticHelper colorFromHexString:strColorHex];
    
    
}

+(UIColor *)getColorForAlertType:(AlertType)alertType withColorType:(ColorType)colorType
{
    NSString *strColorHex = nil;
    
    switch (alertType) {
        case AlertTypeBrokeCar:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_CAR_BROKE_COLOR_LIGHT : ALERT_CAR_BROKE_COLOR_DARK;
            break;
        
        case AlertTypeBullied:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_BULLIED_COLOR_LIGHT : ALERT_BULLIED_COLOR_DARK;
            break;
        
        case AlertTypeCriminal:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_CRIME_COLOR_LIGHT : ALERT_CRIME_COLOR_DARK;
            break;
        
        case AlertTypeGeneral:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_GENERAL_COLOR_LIGHT : ALERT_GENERAL_COLOR_DARK;
            break;
        
        case AlertTypePulledOver:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_PULLED_OVER_COLOR_LIGHT : ALERT_PULLED_OVER_COLOR_DARK;
            break;
        
        case AlertTypeDanger:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_DANGER_COLOR_LIGHT: ALERT_DANGER_COLOR_DARK;
            break;
        
        case AlertTypeVideo:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_VIDEO_COLOR_LIGHT : ALERT_VIDEO_COLOR_DARK;
        
            break;
        
        case AlertTypePhoto:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_PHOTO_COLOR_LIGHT : ALERT_PHOTO_COLOR_DARK;
            break;
        
        case AlertTypeFire:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_FIRE_COLOR_LIGHT : ALERT_FIRE_COLOR_DARK;
            break;
        
        case AlertTypeMedical:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_MEDICAL_ATTENTION_COLOR_LIGHT : ALERT_MEDICAL_ATTENTION_COLOR_DARK;
            break;
        
        case AlertTypePoliceInteraction:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_COP_BLOCKING_COLOR_LIGHT: ALERT_COP_BLOCKING_COLOR_DARK;
            break;
        
        case AlertTypePoliceArrest:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_ARRESTED_COLOR_LIGHT: ALERT_ARRESTED_COLOR_DARK;
            break;
        
        case AlertTypeHijack:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_HIJACK_COLOR_LIGHT : ALERT_HIJACK_COLOR_DARK;
            break;
        
        case AlertTypePanic:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_PANIC_COLOR_LIGHT : ALERT_PANIC_COLOR_DARK;
            break;
        
        case AlertTypeFallen:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_FALLEN_COLOR_LIGHT : ALERT_FALLEN_COLOR_DARK;
            break;
        
        case AlertTypePhysicalAbuse:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_PHYSICAL_ABUSE_COLOR_LIGHT : ALERT_PHYSICAL_ABUSE_COLOR_DARK;
            break;
        
        case AlertTypeTrapped:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_TRAPPED_COLOR_LIGHT : ALERT_TRAPPED_COLOR_DARK;
            break;
        
        case AlertTypeCarAccident:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_CAR_ACCIDENT_COLOR_LIGHT : ALERT_CAR_ACCIDENT_COLOR_DARK;
            break;
        
        case AlertTypeNaturalDisaster:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_NATURAL_DISASTER_COLOR_LIGHT : ALERT_NATURAL_DISASTER_COLOR_DARK;
            break;
        
        case AlertTypePreAuthorisation:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_PRE_AUTHORIZATION_COLOR_LIGHT: ALERT_PRE_AUTHORIZATION_COLOR_DARK;
            break;
        
        default:
            strColorHex = (colorType == ColorTypeLight) ? ALERT_UNRECOGNIZED_COLOR_LIGHT : ALERT_UNRECOGNIZED_COLOR_DARK;
            break;
    }
    
    return [C411StaticHelper colorFromHexString:strColorHex];
}

+(UIImage *)getAlertTypeSmallImageForAlertType:(NSString *)strAlertType
{
    
    NSString *strAlertImgName = nil;
    if ([strAlertType isEqualToString:kAlertTypeCopBlocking]
        || [strAlertType isEqualToString:@"Police Interaction"]) {
        
        strAlertImgName = @"alert_small_police_interaction";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeFire]) {
        
        strAlertImgName = @"alert_small_fire";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeCrime]) {
        
        strAlertImgName = @"alert_small_criminal";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeVehiclePulled]
             || [strAlertType isEqualToString:@"Pulled Over"]) {
        
        strAlertImgName = @"alert_small_pulled_over";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeArrested]
             || [strAlertType isEqualToString:@"Police Arrest"]) {
        
        strAlertImgName = @"alert_small_police_arrest";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeMedical]) {
        
        strAlertImgName = @"alert_small_medical";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeVehicleBroken]
             || [strAlertType isEqualToString:@"Car Broken"]) {
        
        strAlertImgName = @"alert_small_broken_car";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeDanger]) {
        
        strAlertImgName = @"alert_small_danger";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeBullied]) {
        
        strAlertImgName = @"alert_small_bullied";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeGeneral]) {
        
        strAlertImgName = @"alert_small_general";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeVideo]) {
        
        strAlertImgName = @"alert_small_video";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypePhoto]) {
        
        strAlertImgName = @"alert_small_photo";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeHijack]) {
        
        strAlertImgName = @"alert_small_hijack";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypePanic]) {
        
        strAlertImgName = @"alert_small_panic";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeFallen]) {
        
        strAlertImgName = @"alert_small_fallen";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeNaturalDisaster]) {
        
        strAlertImgName = @"alert_small_natural_disaster";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeCarAccident]) {
        
        strAlertImgName = @"alert_small_broken_car";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypePhysicalAbuse]) {
        
        strAlertImgName = @"alert_small_physical_abuse";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypeTrapped]) {
        
        strAlertImgName = @"alert_small_trapped";
        
    }
    else if ([strAlertType isEqualToString:kAlertTypePreAuthorisation]) {
        
        strAlertImgName = @"alert_small_pre_authorization";
        
    }
    else{
        
        strAlertImgName = @"alert_small_un_recoznied";
    }
    
    UIImage *alertImg = [UIImage imageNamed:strAlertImgName];
    return alertImg;
    
}


+(NSString *)getEmailFromUser:(PFUser *)user
{
   ///try to retieve the email from username field first as username field will never be empty, either it will contain valid email if signed up using email else it will contain unique string
    NSString *strEmail = user.username;
    if ([self isValidEmail:strEmail]) {
        ///user would have signed up using email
        return strEmail;
        
    }
    else if (user.email.length > 0){
        ///user would have signed up without email and email exist for them
        return user.email;
        
    }
    else if ([strEmail containsString:@"@"]){
        ///return whatever is there in strEmail field with @ symbol, it could be some value which may not be valid email(for old users)
        return strEmail;
    }
    else{
        
        ///user signed up with email and provided invalid email without @ even or signed up using social media which didn't provided email at signup
        return nil;
        
    }
}

+(BOOL)isValidEmail:(NSString *)strEmail
{
    ///TODO:validate email using regex
    ///for now just check @ symbol
    return [strEmail containsString:@"@"];
    
}

+(SignUpType)getSignUpTypeOfUser:(PFUser *)user
{
    if ([self isValidEmail:user.username] || [user.username containsString:@"@"]) {
        
        ///user signed up using email
        return SignUpTypeEmail;
        
    }
    else if([PFFacebookUtils isLinkedWithUser:user]){
        
        ///user signed up using facebook
        return SignUpTypeFacebook;
    }
    else{
        
        ///Cannot determine
        return SignUpTypeUnknown;
    }
    
}

+(NSString *)getFBAlertDescriptionForAlertRegarding:(NSString *)strAlertRegarding withCity:(NSString *)strCity issuerName:(NSString *)strIssuerName additionalNote:(NSString *)strAdditionalNote andLocationCoordinate:(CLLocationCoordinate2D)locCoordinate
{
    ///make a description
    NSMutableString *strDescription = [NSMutableString stringWithString:strIssuerName];
    if (strCity) {
        
        ///append city info
        [strDescription appendString:[NSString localizedStringWithFormat:NSLocalizedString(@" is in the city of %@ and",nil),strCity]];
    }
    
    ///append alert regarding
#if APP_CELL411
    [strDescription appendString:[NSString localizedStringWithFormat:NSLocalizedString(@" issued a %@ 411 alert.",nil),[C411StaticHelper getLocalizedAlertTypeStringFromString:strAlertRegarding]]];
#elif APP_RO112
    [strDescription appendString:[NSString localizedStringWithFormat:NSLocalizedString(@" issued a %@ 112 alert.",nil),[C411StaticHelper getLocalizedAlertTypeStringFromString:strAlertRegarding]]];
#else
    [strDescription appendString:[NSString localizedStringWithFormat:NSLocalizedString(@" issued a %@ alert.",nil),[C411StaticHelper getLocalizedAlertTypeStringFromString:strAlertRegarding]]];

#endif

    
    ///append additional note if available
    if (strAdditionalNote.length > 0) {
        
        [strDescription appendString:[NSString localizedStringWithFormat:NSLocalizedString(@" Additional Note: %@",nil),strAdditionalNote]];
        
    }
    
    ///append google url to open local in google map in web
    NSString *strMapUrl = [self getGoogleMapsWebUrlStringUsingCoordinate:locCoordinate];
    [strDescription appendString:[NSString localizedStringWithFormat:NSLocalizedString(@"\nYou can view the location here: %@",nil),strMapUrl]];
    
    return strDescription;
}

+(NSString *)getGoogleMapsWebUrlStringUsingCoordinate:(CLLocationCoordinate2D)locCoordinate
{
    ///ex: http://maps.google.com/maps?q=24.197611,120.780512
    NSString *strMapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f",locCoordinate.latitude,locCoordinate.longitude];
    return strMapUrl;
}

#if FB_ENABLED
 
+(void)performLoginOrSignupWithFacebookFromViewController:(UIViewController *)viewController
{
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    //[FBSDKAccessToken setCurrentAccessToken:nil];
    [[PFFacebookUtils facebookLoginManager]logOut];///logging out before logging in to handle different user login else it will give facebook login error "Domain=com.facebook.sdk.login Code=304 "(null)"
    __weak typeof(self) weakSelf = self;
    
    ///1. Login with facebook with read permission
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[kReadPermissionEmail,kReadPermissionPublicProfile] block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            ///user cancelled login or error occured
            if (error) {
                
                ///show the error message
                [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:viewController];
                
            }
            
            ///hide the hud
            [MBProgressHUD hideHUDForView:viewController.view animated:YES];
            
        }
        else if (user.isNew) {
            
            ///2.A new user is created using Facebook signup and logged in, get the basic info of the user and update it on parse
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"email,first_name,last_name"}]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     
                     
                     ///get first and last name
                     NSString *strFirstName = result[@"first_name"];
                     if (strFirstName.length > 0) {
                         
                         user[kUserFirstnameKey] = strFirstName;
                     }
                     
                     NSString *strLastName = result[@"last_name"];
                     if (strLastName.length > 0) {
                         
                         user[kUserLastnameKey] = strLastName;
                     }
                     
                     ///Set client firm id
                     user[kUserClientFirmIdKey] = CLIENT_FIRM_ID;
                     
                     ///Enable New Public Cell alert notifications to on by default
                     user[kUserNewPublicCellAlertKey] = NEW_PUBLIC_CELL_ALERT_VALUE_ON;

                     
                     ///get the email
                     NSString *strEmail = result[@"email"];
                     NSString *strTrimmedEmail = [strEmail  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                     if (strTrimmedEmail.length > 0) {
                         ///Facebook user has an email, user this email to check if there is already a user with this email
                         [C411StaticHelper getUserWithEmail:strTrimmedEmail.lowercaseString andCompletion:^(PFObject * _Nullable object, NSError * _Nullable error) {
                             
                             if (!error && object) {
                                 ///1.hide the hud
                                 [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                                 
                                 ///Found existing user object with this email, show the error message that user already exist with this email
                                 NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"You already have a %@ Account. Please login with your existing account, go to Settings, then Connect your account with Facebook",nil), LOCALIZED_APP_NAME];
                                 [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:viewController];
                                 
                                 ///delete the current facebook user just created from parse
                                 [user deleteEventually];
                                 
                                 
                             }
                             else if (error.code == kPFErrorObjectNotFound){
                                 
                                 ///No user exist with this email, user signup is successful, set the email as well and update user object
                                 user.email = strTrimmedEmail.lowercaseString;
                                 
                                 ///update user object
                                 [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                     
                                     if (!error) {
                                         
                                         ///User details updated
                                         NSLog(@"user details updated");
                                         
                                     } else {
                                         
                                         ///save it eventually
                                         [user saveEventually];
                                         
                                         // Show the errorString somewhere and let the user try again.
                                         NSString *errorString = [error userInfo][@"error"];
                                         [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:viewController];
                                         
                                         
                                     }
                                     
                                     ///hide the hud
                                     [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                                     
                                     
                                     ///perform post signup steps even if error occured as it will be saved eventually
                                     ///Show main interface
                                     [[AppDelegate sharedInstance]userDidCreatedAccountWithSignUpType:SignUpTypeFacebook];
                                     
                                 }];
                                
                                 
                             }
                             else{
                                 ///1.hide the hud
                                 [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                                 
                                 // Show the errorString somewhere and let the user try again.
                                 NSString *errorString = [error userInfo][@"error"];
                                 [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:viewController];
                             }
                             
                             
                         }];
                         
                     }
                     else{
                         ///Facebook user don't have an email so no need to check for user with existing email and simply update the user other details
                         
                         ///update user object
                         [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                             
                             if (!error) {
                                 
                                 ///User details updated
                                 NSLog(@"user details updated");
                                 
                             } else {
                                 
                                 ///save it eventually
                                 [user saveEventually];
                                 
                                 // Show the errorString somewhere and let the user try again.
                                 NSString *errorString = [error userInfo][@"error"];
                                 [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:viewController];
                                 
                                 
                             }
                             
                             ///hide the hud
                             [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                             
                             
                             ///perform post signup steps even if error occured as it will be saved eventually
                             ///Show main interface
                             [[AppDelegate sharedInstance]userDidCreatedAccountWithSignUpType:SignUpTypeFacebook];
                             
                         }];

                     }
                     
                     
                 }
                 else{
                     
                     ///Show the error
                     [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:viewController];
                     
                     ///hide the hud
                     [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                     
                 }
             }];
            
            
        }
        else{
            
            ///Existing user logged in again through Facebook!
            [weakSelf handleLoginCompletionWithUser:user fromViewController:viewController andCompletion:^(NSString * _Nullable string, NSError * _Nullable error) {
                
                ///hide the progress hud
                [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                
            }];
            
        }
    }];
    
}


#endif





+(void)handleLoginCompletionWithUser:(PFUser *)user fromViewController:(UIViewController *)viewController andCompletion:(PFStringResultBlock)completion
{

    ///Verify the user privileges and proceed with post login operations if applicable
    [C411StaticHelper getPrivilegeForUser:user shouldSetPrivilegeIfUndefined:YES andCompletion:^(NSString * _Nullable string, NSError * _Nullable error) {
        if (completion!= NULL) {
            ///call compeltion to remove progress hud and other cleanup if required
            completion(string,error);
            
        }
        NSString *strPrivilege = string;
        if ((!strPrivilege)
            ||(strPrivilege.length == 0)) {
            
            ///some error occured fetching privilege
            NSLog(@"#error fetching privilege : %@",error.localizedDescription);
            
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Some error occurred, please try again.", nil) onViewController:viewController];
            
        }
        else if ([strPrivilege isEqualToString:kPrivilegeTypeBanned]){
            
            ///This user account is banned, log him out of the app
            [PFUser logOutInBackground];
            
            ///show message
            [C411StaticHelper showAlertWithTitle:nil message:[NSString localizedStringWithFormat:NSLocalizedString(@"Your account has been blocked for violating the %@ Terms of Service.",nil), LOCALIZED_APP_NAME] onViewController:viewController];
            
        }
        else if ([strPrivilege hasPrefix:kPrivilegeTypeSuspended]){
            
            ///This user account is suspended, log him out of the app
            [PFUser logOutInBackground];
            
            ///show message
            [C411StaticHelper showAlertWithTitle:nil message:[NSString localizedStringWithFormat:NSLocalizedString(@"Your account has been temporarily suspended for violating the %@ Terms of Service.",nil), LOCALIZED_APP_NAME] onViewController:viewController];
            
        }
        else{
            
            ///privilege is either FIRST, SECOND or SHADOW_BANNED. User with privilege FIRST or SHADOW_BANNED cannot send Global Alerts but can use the app
            
            // Do stuff after successful login.
            [[AppDelegate sharedInstance]userDidLogin];
            
            
        }
    }];
    
}


+(NSString *)stringByRemovingEncodedCharacter:(NSString *)strEncodedCharacter fromString:(NSString *)strEncodedString
{
    NSArray *arrStringComponents = [strEncodedString componentsSeparatedByString:strEncodedCharacter];
    NSMutableString *strDecodedString = [NSMutableString stringWithString:@""];
    
    ///Iterate this array and make the decoded string by appending the encoded character where it is having empty string
    for (NSInteger index = 0; index < arrStringComponents.count; index++) {
        
        NSString *strWord = [arrStringComponents objectAtIndex:index];
        if (strWord.length == 0) {
            
            ///append with encoded character, as this character is not encoded and is the part of the string
            [strDecodedString appendString:strEncodedCharacter];
        }
        else{
            
            ///append the word
            [strDecodedString appendString:strWord];
            
            ///append space if this is not the last word
            if (index < (arrStringComponents.count - 1)) {
                
                [strDecodedString appendString:@" "];
            }
        }
        
    }
    
    return strDecodedString;
    
}

+(void)getUserWithEmail:(NSString *)strEmail andCompletion:(PFObjectResultBlock)completion
{
    
    ///Get existing user object by checking on both username and email field
    PFQuery *getUserWithSameUsernameQuery = [PFUser query];
    [getUserWithSameUsernameQuery whereKey:@"username" equalTo:strEmail];
    
    PFQuery *getUserWithSameEmailQuery = [PFUser query];
    [getUserWithSameEmailQuery whereKey:@"email" equalTo:strEmail];
    
    PFQuery *getExistingUserQuery = [PFQuery orQueryWithSubqueries:@[getUserWithSameUsernameQuery, getUserWithSameEmailQuery]];
    [getExistingUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (completion != NULL) {
            
            completion(object, error);
            
        }
    }];

}

+(void)getUserWithMobileNumber:(NSString *)strContactNumber ignoreCurrentUser:(BOOL)ignoreCurrentUser andCompletion:(PFObjectResultBlock)completion
{
    
    ///Get existing user object by checking on both username and email field
    PFQuery *getUserWithSameMobileQuery = [PFUser query];
    [getUserWithSameMobileQuery whereKey:kUserMobileNumberKey equalTo:strContactNumber];
    if (ignoreCurrentUser) {
        ///Ignore current user for same mobile number
        PFUser *currentUser = [PFUser currentUser];///This should be fetched from parse only as it is created at the time of signup and before setting isLoggedIn flag
        [getUserWithSameMobileQuery whereKey:@"objectId" notEqualTo:currentUser.objectId];

        
    }
    
    [getUserWithSameMobileQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (completion != NULL) {
            
            completion(object, error);
            
        }
    }];
    
}



+(void)updateEmail:(NSString *)strEmail forUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion
{
    
    ///before updating an email first check whether a user already exist with this email id or not by checking on both username and email field
    [self getUserWithEmail:strEmail andCompletion:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            ///Found user object with this email, show the error message that user already exist with this email
            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is already registered, please use different email",nil),strEmail];
            [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
            ///call completion with NO
            if (completion !=  NULL) {
                
                completion(NO,nil);
            }
            
            
        }
        else if (error.code == kPFErrorObjectNotFound){
            
            ///No user exist with this email, you can update the user email safely
            user.email = strEmail;
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                
                if (succeeded) {
                    
                    ///Post notification to reflect email updation everywhere
                    [[NSNotificationCenter defaultCenter]postNotificationName:kMyProfileUpdatedNotification object:nil];
                    
                }
                
                ///pass the result to completion block
                if (completion != NULL) {
                    
                    completion(succeeded, error);
                    
                }
                
            }];
            
        }
        else{
            
            ///call the completion block if provided and error will be handled there
            if (completion != NULL) {
                
                completion(NO, error);
            }
            
        }
        
    }];

    
}


+(NSMutableArray *)alertsArrayByRemovingInvalidObjectsFromArray:(NSArray *)arrAlerts isForwardedAlert:(BOOL)isForwardedAlert
{
    
    NSMutableArray *arrFilteredArray = [NSMutableArray array];
    for (PFObject *cell411Alert in arrAlerts) {
        PFUser *issuedBy = cell411Alert[kCell411AlertIssuedByKey];
        if (issuedBy) {
            
            if (isForwardedAlert) {
                
                ///Validate ForwardedBy object as well for it's existence
                PFUser *forwardedBy = cell411Alert[kCell411AlertForwardedByKey];
                if (forwardedBy) {
                    
                    ///Forwarded alert and ForwardedBy user exist
                    [arrFilteredArray addObject:cell411Alert];
 
                }
                
            }
            else{
                ///Not a forwarded alert and issuedBy user exist
                [arrFilteredArray addObject:cell411Alert];
            }

        }
        
    }
    
    return arrFilteredArray;
}

+(NSMutableArray *)rideRequestArrayByRemovingInvalidObjectsFromArray:(NSArray *)arrRequests
{
    
    NSMutableArray *arrFilteredArray = [NSMutableArray array];
    for (PFObject *rideRequest in arrRequests) {
        PFUser *requestedBy = rideRequest[kRideRequestRequestedByKey];
        if (requestedBy) {
            
            ///requestedBy user exist
            [arrFilteredArray addObject:rideRequest];
            
        }
        
    }
    
    return arrFilteredArray;
}

+(NSMutableArray *)rideResponseArrayByRemovingInvalidObjectsFromArray:(NSArray *)arrResponses
{
    
    NSMutableArray *arrFilteredArray = [NSMutableArray array];
    for (PFObject *rideResponse in arrResponses) {
        PFUser *respondedBy = rideResponse[kRideResponseRespondedByKey];
        if (respondedBy) {
            
            ///respondedBy user exist
            [arrFilteredArray addObject:rideResponse];
            
        }
        
    }
    
    return arrFilteredArray;
}



+(BOOL)validateUserUsingObjectId:(NSString *)strObjectId
{
    
    if(strObjectId
       && (![strObjectId isKindOfClass:[NSNull class]])
       && ([strObjectId isKindOfClass:[NSString class]])
       && (![strObjectId isEqualToString:@"null"])
       && strObjectId.length > 0)
    {
        return YES;
    }

    return NO;
}

+(BOOL)validateUserUsingFullName:(NSString *)strFullName
{
    
    if(strFullName
       && (![strFullName isKindOfClass:[NSNull class]])
       && ([strFullName isKindOfClass:[NSString class]])
       && strFullName.length > 0)
    {
        NSString *strFirstname = [[strFullName componentsSeparatedByString:@" "]firstObject];
        if (![strFirstname isEqualToString:@"null"]) {
           
            return YES;

        }
        
    }
    
    return NO;
}

/*
+(UILocalNotification *)presentLocalNotificationNowWithLocalizedMessage:(NSString *)strLocalizedMessage andUserInfo:(NSDictionary *)dictUserInfo
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = strLocalizedMessage;
    // notification.alertAction = @"Show";
    notification.userInfo = dictUserInfo;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];

    return notification;
}
*/

+(id)presentLocalNotificationNowWithSound:(BOOL)isSoundEnabled localizedMessage:(NSString *)strLocalizedMessage userInfo:(NSDictionary *)dictUserInfo identifier:(NSString *)strNotifId
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        ///iOS 9 or below
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = strLocalizedMessage;
        // notification.alertAction = @"Show";
        notification.userInfo = dictUserInfo;
        if (isSoundEnabled) {
            
            notification.soundName = UILocalNotificationDefaultSoundName;
            
        }
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        return notification;

        
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        //content.title = [NSString localizedUserNotificationStringForKey:@"Wake up!" arguments:nil];
        content.body = strLocalizedMessage;
        content.userInfo = dictUserInfo;
        if (isSoundEnabled) {
            
            content.sound = [UNNotificationSound defaultSound];
            
        }

        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
//        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:[NSDate date] repeats:NO];
        
        // Create the request object.
        NSString *strLocalNotifId = [NSString stringWithFormat:@"%@%@",kLocalNotificationIdentifier,strNotifId];
        UNNotificationRequest* request = [UNNotificationRequest
                                          requestWithIdentifier:strLocalNotifId content:content trigger:trigger];
        
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        
        return request;
        
#endif
    }

}


+(void)cancelLocalNotification:(id)oldNotification
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        
        ///iOS 9 or below
        ///Cancel it
        [[UIApplication sharedApplication]cancelLocalNotification:oldNotification];
        
        
        
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    
        if ([oldNotification isKindOfClass:[UNNotificationRequest class]]) {
            
            UNNotificationRequest *request = (UNNotificationRequest *)oldNotification;
            if (request.identifier) {
                
                ///Cancel it
                [[UNUserNotificationCenter currentNotificationCenter]removePendingNotificationRequestsWithIdentifiers:@[request.identifier]];

            }

        }
        
#endif
    }

}

+(NSArray *)getUniqueParseObjectsFromArray:(NSArray *)arrParseObjects
{
    NSMutableArray *arrUniqueObjects = [NSMutableArray array];
    for (PFObject *object in arrParseObjects) {
        
        BOOL isAdded = NO;
        for (PFObject *existingObject in arrUniqueObjects) {
            
            if ([existingObject.objectId isEqualToString:object.objectId]) {
                
                isAdded = YES;
                break;
            }
        }
        
        if (!isAdded) {
            
            [arrUniqueObjects addObject:object];
        }
        
    }
    
    return arrUniqueObjects;
}

+(NSDictionary *)getDistanceAndDurationFromDistanceMatrixResponse:(NSDictionary *)dictDistanceMatrixResponse
{
    NSMutableDictionary *dictDistanceAndDuration = [NSMutableDictionary dictionary];
    NSArray *arrRows = [dictDistanceMatrixResponse objectForKey:@"rows"];
    if (arrRows.count > 0) {
        
        NSDictionary *dictRow = [arrRows firstObject];
        NSArray *arrElements = [dictRow objectForKey:@"elements"];
        if (arrElements.count > 0) {
            
            NSDictionary *dictElement = [arrElements firstObject];
            NSDictionary *dictDistance = [dictElement objectForKey:kDistanceMatrixDistanceKey];
            NSNumber *distance = [dictDistance objectForKey:@"value"];
            if (distance) {
                
                [dictDistanceAndDuration setObject:distance forKey:kDistanceMatrixDistanceKey];
            }
            
            NSDictionary *dictDuration = [dictElement objectForKey:kDistanceMatrixDurationKey];
            NSNumber *durationInSec = [dictDuration objectForKey:@"value"];
            if (durationInSec) {
                
                [dictDistanceAndDuration setObject:durationInSec forKey:kDistanceMatrixDurationKey];
            }
            
        }

    }
    
    return dictDistanceAndDuration;
    
}

+(NSString *)getFormattedTimeFromDate:(NSDate *)date withFormat:(TimeStampFormat)timeStampFormat
{
    ///1. Set time formatted string
    NSDate *now = [NSDate date];
    NSInteger dayDiff = [DateHelper daysBetweenDate:now andDate:date];
    NSString *strTime = [[DateHelper sharedHelper]stringFromDate:date withFormat:kDateFormatTimeInAMPM];
    NSString *timeString = @"";
    
    if (dayDiff == 0) {
        
        ///It's today
        if (timeStampFormat == TimeStampFormatDateAndTime) {
            timeString = [NSString localizedStringWithFormat:NSLocalizedString(@"today at %@",nil),strTime.uppercaseString];
        }
        else{
        ///timeStamp format is TimeStampFormatDateOrTime
            timeString = [NSString localizedStringWithFormat:@"%@",strTime.uppercaseString];
            
        }
        
        
    }
    else{
        
        ///date was earlier than today
        NSString *dateString = [[DateHelper sharedHelper]stringFromDate:date withFormat:kDateFormatDateInddMMyyyy];
        if (timeStampFormat == TimeStampFormatDateAndTime) {
            timeString = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ at %@",nil),dateString,strTime.uppercaseString];
        }
        else{
            ///timeStamp format is TimeStampFormatDateOrTime
            timeString = [NSString localizedStringWithFormat:@"%@",dateString];
            
        }

        
    }

    return timeString;
}

+(GMSMarker *)addMarkerOnMap:(GMSMapView *)mapView atPosition:(CLLocationCoordinate2D)coordinate withImage:(UIImage *)imgMarker andTitle:(NSString *)strMarkerTitle
{
    GMSMarker *marker =[[GMSMarker alloc]init];
    marker.map = mapView;
    if (imgMarker) {
        
        marker.icon = imgMarker;

    }
    
    if (strMarkerTitle.length > 0) {
        
        marker.title = strMarkerTitle;
    }
    
    marker.position = coordinate;
    return marker;
}


+(NSURL *)getAvatarUrlForUser:(PFUser *)parseUser
{
    
#if CUSTOM_PIC_ENABLED

    ///construct and return the valid server url for the user avatar
    NSNumber *imageNameNum = parseUser[kUserImageNameKey];
    if (imageNameNum) {
        
        NSString *strAvatarUrl = [NSString stringWithFormat:@"%@%@/%@/%@%d.png",DOWNLOAD_PIC_API_BASE_URL,DOWNLOAD_PIC_API_BUCKET_NAME,DOWNLOAD_PIC_AVATAR_FOLDER_NAME,parseUser.objectId,[imageNameNum intValue]];
        NSURL *avatarUrl = [NSURL URLWithString:strAvatarUrl];
        return avatarUrl;

    }
    else{
        
        return nil;
    }
#else
    return nil;
#endif

}

/*
+(void)getAvatarForUser:(PFUser *)parseUser shouldFallbackToGravatar:(BOOL)fallbackToGravatar ofSize:(int)imageSize roundedCorners:(BOOL)roundedCorner withCompletion:(void(^)(BOOL success, UIImage *image))completion
{
    [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[self getAvatarUrlForUser:parseUser] options:SDWebImageDownloaderUseNSURLCache progress:NULL completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        
        if (finished) {
            
            if (!error && image) {
                
                if (roundedCorner) {
                    
                    image = [C411StaticHelper getRoundedRectImageFromImage:image withSize:CGSizeMake(imageSize, imageSize) withCornerRadius:imageSize/2];
                }
                
                ///call the completion block and pass the image
                if (completion!=NULL) {
                    
                    completion(YES,image);
                }

            }
            else if (fallbackToGravatar){
                
                ///get the email of the user
                NSString *strEmail = [self getEmailFromUser:parseUser];
                [self getGravatarForEmail:strEmail ofSize:imageSize roundedCorners:roundedCorner withCompletion:completion];
            }
            else{
                
                ///call the completion block if provided
                if (completion!=NULL) {
                    
                    completion(NO,image);
                }
            }
            
        }
        
    }];
}

+(void)getAvatarForUserWithId:(NSString *)strUserId shouldFallbackToGravatar:(BOOL)fallbackToGravatar ofSize:(int)imageSize roundedCorners:(BOOL)roundedCorner withCompletion:(void(^)(BOOL success, UIImage *image))completion
{
    ///get the user object from parse
    __weak typeof(self) weakSelf = self;
    PFQuery *getUserQuery = [PFUser query];
    [getUserQuery getObjectInBackgroundWithId:strUserId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            ///User found, get the avatar for this user
            PFUser *parseuser = (PFUser *)object;
            [weakSelf getAvatarForUser:parseuser shouldFallbackToGravatar:fallbackToGravatar ofSize:imageSize roundedCorners:roundedCorner withCompletion:completion];
            
        }
        else {
            
            ///log error
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"#error: %@",errorString);
            
            ///call the completion block if provided
            if (completion!=NULL) {
                
                completion(NO,nil);
            }
            
        }
    }];

}
 */

+(NSURL *)getCarUrlForUser:(PFUser *)parseUser
{
    
#if RIDE_HAILING_ENABLED
    ///construct and return the valid server url for the user car image
    NSNumber *carImageNameNum = parseUser[kUserCarImageNameKey];
    if (carImageNameNum) {
        
        NSString *strCarUrl = [NSString stringWithFormat:@"%@%@/%@/%@%d.png",DOWNLOAD_PIC_API_BASE_URL,DOWNLOAD_PIC_API_BUCKET_NAME,DOWNLOAD_PIC_CAR_FOLDER_NAME,parseUser.objectId,[carImageNameNum intValue]];
        NSURL *carUrl = [NSURL URLWithString:strCarUrl];
        return carUrl;
        
    }
    else{
        
        return nil;
    }

#else
    return nil;
#endif

}

/*
+(void)getCarImageForUser:(PFUser *)parseUser withCompletion:(void(^)(BOOL success, UIImage *image))completion
{
    [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[self getCarUrlForUser:parseUser] options:SDWebImageDownloaderUseNSURLCache progress:NULL completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        
        if (finished) {
            
            if (!error && image) {
                
                ///call the completion block and pass the image
                if (completion!=NULL) {
                    
                    completion(YES,image);
                }
                
            }
            else{
                
                ///call the completion block if provided
                if (completion!=NULL) {
                    
                    completion(NO,image);
                }
            }
            
        }
        
    }];
}

+(void)getCarImageForUserWithId:(NSString *)strUserId withCompletion:(void(^)(BOOL success, UIImage *image))completion
{
    ///get the user object from parse
    __weak typeof(self) weakSelf = self;
    PFQuery *getUserQuery = [PFUser query];
    [getUserQuery getObjectInBackgroundWithId:strUserId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            ///User found, get the avatar for this user
            PFUser *parseuser = (PFUser *)object;
            [weakSelf getCarImageForUser:parseuser withCompletion:completion];
            
        }
        else {
            
            ///log error
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"#error: %@",errorString);
            
            ///call the completion block if provided
            if (completion!=NULL) {
                
                completion(NO,nil);
            }
            
        }
    }];
    
}
*/


+(NSMutableAttributedString *)getSemiboldAttributedStringWithString:(NSString *)string ofSize:(CGFloat)fontSize withUnboldTextInRange:(NSRange)unboldTextRange
{
    // Create the attributes
    NSDictionary *boldAttrs = @{
                            NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]
                            //,NSForegroundColorAttributeName:[UIColor whiteColor]
                            };
    NSDictionary *unboldAttrs = @{
                               NSFontAttributeName:[UIFont systemFontOfSize:fontSize]
                               };
    
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:string
                                           attributes:boldAttrs];
    [attributedText setAttributes:unboldAttrs range:unboldTextRange];

    return attributedText;
}



+(NSURLSessionDataTask *)updateLocationonLabel:(UILabel *)lblSelectedAddress usingCoordinate:(CLLocationCoordinate2D)locCoordinate
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    ///make a new request
    NSString *strLatLong = [NSString stringWithFormat:@"%f,%f",locCoordinate.latitude,locCoordinate.longitude];
    
    
    return [ServerUtility getAddressForCoordinate:strLatLong andCompletion:^(NSError *error, id data) {
        NSLog(@"%s,data = %@",__PRETTY_FUNCTION__,data);
        
        if (!error && data) {
            
            NSArray *results=[data objectForKey:kGeocodeResultsKey];
            
            if([results count]>0){
                
                NSDictionary *address=[results firstObject];
                ///set the formatted address on the label
                //lblSelectedAddress = formattedaddress;
                
                NSString *strFormattedAddress = [address objectForKey:kFormattedAddressKey];
                lblSelectedAddress.text = strFormattedAddress;
                
            }
            else{
                
                lblSelectedAddress.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        
    }];
}

+(NSURLSessionDataTask *)updateDistanceMatrixOnLabel:(UILabel *)lblDistanceMatrix usingOriginCoordinate:(CLLocationCoordinate2D)originCoordinate destinationCoordinate:(CLLocationCoordinate2D)destCoordinate withCompletion:(C411WebServiceHandler)completion
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    ///make a new request
    NSString *strOriginLatLong = [NSString stringWithFormat:@"%f,%f",originCoordinate.latitude,originCoordinate.longitude];
    NSString *strDestLatLong = [NSString stringWithFormat:@"%f,%f",destCoordinate.latitude,destCoordinate.longitude];
    __weak typeof(self) weakSelf = self;
    
    return [ServerUtility getDistanceAndDurationMatrixFromLocation:strOriginLatLong toLocation:strDestLatLong andCompletion:^(NSError *error, id data) {
        NSLog(@"%s,data = %@",__PRETTY_FUNCTION__,data);
        
        if (!error && data) {
            
            NSDictionary *dictDistanceMatrix = [weakSelf getDistanceAndDurationFromDistanceMatrixResponse:data];
            NSNumber *numDistanceValueInMeters = [dictDistanceMatrix objectForKey:kDistanceMatrixDistanceKey];
            NSNumber *numDuration = [dictDistanceMatrix objectForKey:kDistanceMatrixDurationKey];
            if(numDistanceValueInMeters || numDuration){
                
                
                NSString *strDistMatrix = nil;
                if (numDistanceValueInMeters) {
                    
                    float distanceInKms = [numDistanceValueInMeters integerValue] / 1000.0;
                    float distanceInMiles = distanceInKms/MILES_TO_KM;
                    ///Set data according to the selected metric system
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    ///Get metric chosen by user
                    NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
                    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
                        
                        ///set values in kms
                        NSString *strMetricSuffix = (distanceInKms <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
                        strDistMatrix = [NSString stringWithFormat:@"%0.1f %@",distanceInKms,strMetricSuffix];
                        
                    }
                    else{
                        
                        ///Set values in miles
                        NSString *strMetricSuffix = (distanceInMiles <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
                        strDistMatrix = [NSString stringWithFormat:@"%0.1f %@",distanceInMiles,strMetricSuffix];
                        
                        
                    }

//                    NSString *strMetricSuffix = NSLocalizedString(@"Km", nil);
//                    if (distanceInKms > 1) {
//                        
//                        strMetricSuffix = NSLocalizedString(@"Kms", nil);
//                    }
//                    strDistMatrix = [NSString stringWithFormat:@"%0.1f %@",distanceInKms,strMetricSuffix];
                }
                
                if (numDuration) {
                    
                    int seconds = [numDuration intValue];
                    int hours = (int)seconds / (60 * 60);
                    int remainingSec = seconds % (60 * 60);
                    int mins = remainingSec / 60;
                   
                    NSString *strHourSuffix = hours > 1 ? NSLocalizedString(@"hrs", nil):NSLocalizedString(@"hr", nil);
                    NSString *strMinSuffix = mins > 1 ? NSLocalizedString(@"mins", nil):NSLocalizedString(@"min", nil);
                    
                    NSString *strDuration = nil;
                    if (hours > 0 && mins > 0) {
                        
                        ///show hours and mins
                        strDuration = [NSString localizedStringWithFormat:@"%d %@ %d %@",hours,strHourSuffix,mins,strMinSuffix];
                        
                    }
                    else if (hours > 0){
                        
                        ///show hours
                        strDuration = [NSString localizedStringWithFormat:@"%d %@",hours,strHourSuffix];
                        
                    }
                    else{
                        
                        ///show mins
                        strDuration = [NSString localizedStringWithFormat:@"%d %@",mins,strMinSuffix];
                        
                    }
                    
                    if (strDistMatrix.length > 0) {
                        
                        ///append \n to it
                        strDistMatrix = [strDistMatrix stringByAppendingFormat:@"\n%@",strDuration];
                    }
                    else{
                        
                        ///set duration to distance matrix
                        strDistMatrix = strDuration;
                    }
                    
                   
                }
                
                if (strDistMatrix.length > 0) {
                    
                    lblDistanceMatrix.text = strDistMatrix;
                }
                else{
                    
                    lblDistanceMatrix.text = NSLocalizedString(@"N/A", nil);
                    
                }
                
            }
            else{
                
                lblDistanceMatrix.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        else{
            lblDistanceMatrix.text = NSLocalizedString(@"N/A", nil);
            
        }
        
        if (completion != NULL) {
            
            completion(error,data);
        }
        
    }];
}



+(void)callUser:(PFUser *)user
{
    NSString *strContactNumber = user[kUserMobileNumberKey];
    [self callOnNumber:strContactNumber];
 
}

+(BOOL)isRideRequestValid:(NSNumber *)createdAtInMillis
{
    if (createdAtInMillis) {
        
        double currentTimeInMillis = [[NSDate date]timeIntervalSince1970] * 1000;///Multiply by 1000 to convert it from second to millisecond
        
        double timeElaplsedInMillis = currentTimeInMillis - [createdAtInMillis doubleValue];
        
        if (timeElaplsedInMillis <= ((TIME_TO_LIVE_FOR_RIDE_REQ)*1000.0)) {
            
            ///Notification is valid
            return YES;
            
        }
        
    }
    
    return NO;
}

+(int)getRandomVerificationCodeOfDigits:(int)totalDigits
{
    int minValue = (int)powf(10, totalDigits - 1);
    int maxValue = (int)powf(10,totalDigits) - 1;
    int rangeValue = maxValue - minValue;
    return (minValue + (arc4random() % rangeValue));
}

+(BOOL)validateAndProcessBackendResponse:(id)parsedResponse
{
    BOOL isValid = NO;
    if (parsedResponse && [parsedResponse isKindOfClass:[NSDictionary class]]) {
        
        NSString *strRespType = [(NSDictionary *)parsedResponse objectForKey:kResponseTypeKey];
        if ([strRespType.lowercaseString isEqualToString:kResponseTypeData.lowercaseString]) {
            ///Response is valid
            isValid = YES;
        }
        else if ([strRespType.lowercaseString isEqualToString:kResponseTypeError.lowercaseString]) {
            ///Some error occured
            
            NSString *strErrorMsg = [parsedResponse objectForKey:kMessageKey];
            
            [self showAlertWithTitle:nil message:NSLocalizedString(strErrorMsg, nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
        }
        else if ([strRespType.lowercaseString isEqualToString:kResponseTypeWarning.lowercaseString]) {
            ///Some warning occured to be handled internally
            NSString *strWarningMsg = [parsedResponse objectForKey:kMessageKey];
            NSLog(@"#Warning:%@",strWarningMsg);
        }
        
        
        
    }
    else{
        
        NSLog(@"#Unexpected Type: It should be of dictionary type");
        
    }
    
    return isValid;
    
}

+(void)getDriverProfileForUser:(PFUser *)user withCompletion:(PFObjectResultBlock)completion
{
    ///get the driver profile if available
    PFQuery *getDriverProfileQuery = [PFQuery queryWithClassName:kDriverProfileClassNameKey];
    [getDriverProfileQuery whereKey:kDriverProfileUserKey equalTo:user];
    [getDriverProfileQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        if (completion != NULL) {
            
            completion(object,error);
        }
        
    }];
    
}

+(float)calculateRideCostForDistance:(float)distanceInMiles duration:(NSInteger)rideTimeInMins  usingPickupCost:(float)pickupCost costPerMin:(float)costPerMin andCostPerMile:(float)costPerMile
{
    float totalCost = pickupCost + (distanceInMiles * costPerMile) + (rideTimeInMins * costPerMin);
    return totalCost;
}

+(void)showUpdateAppAlertWithMessage:(NSString *)strMessage
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:strMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *updateAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Update", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       ///User tapped update,
                                       if (RATE_APP_URL.length > 0) {
                                           NSURL *rateAppUrl = [NSURL URLWithString:RATE_APP_URL];
                                           [[UIApplication sharedApplication]openURL:rateAppUrl];
                                           
                                       }
                                       
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                       
                                   }];
    
    [alertController addAction:updateAction];
    //[viewController presentViewController:alertController animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

}

+(void)showUpdateAppNowOrLaterAlertWithMessage:(NSString *)strMessage
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:strMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *laterAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Later", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       ///User tapped later,
                                       
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                       
                                   }];

    UIAlertAction *updateAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Update", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       ///User tapped update,
                                       if (RATE_APP_URL.length > 0) {
                                           NSURL *rateAppUrl = [NSURL URLWithString:RATE_APP_URL];
                                           [[UIApplication sharedApplication]openURL:rateAppUrl];
                                           
                                       }
                                       
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                       
                                   }];
    
    [alertController addAction:laterAction];
    [alertController addAction:updateAction];
    //[viewController presentViewController:alertController animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];
    
}

+(void)showCustomVersionSpecificAlertWithMessage:(NSString *)strMessage shouldDisplayDontShowOption:(BOOL)shouldDisplayDontShowOption forDefaultsKey:(NSString *)strDefaultsKey
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:strMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    if (shouldDisplayDontShowOption) {
        
        UIAlertAction *dontShowAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Don't show again", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       ///User tapped don't show again button, save it in defaults
                                       if (strDefaultsKey.length > 0) {
                                           
                                           ///save the entry on defaults
                                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                           NSMutableDictionary *dictPopupDetails = [[defaults objectForKey:strDefaultsKey]mutableCopy];
                                           if (dictPopupDetails) {
                                               
                                               [dictPopupDetails setObject:@(YES) forKey:kDontShowPopupKey];
                                               [defaults setObject:dictPopupDetails forKey:strDefaultsKey];
                                               [defaults synchronize];
                                           }
                                           
                                           
                                       }

                                       
                                       
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                       
                                   }];
        
        [alertController addAction:dontShowAction];

    }
    
    UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Ok", nil)
                               style:shouldDisplayDontShowOption ? UIAlertActionStyleDefault: UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       ///User tapped ok,do nothing
                                       
                                       
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                       
                                   }];
    
    [alertController addAction:okAction];
    
    //[viewController presentViewController:alertController animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];
    
    if (strDefaultsKey.length > 0) {
        
        ///save the entry on defaults
        NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        NSTimeInterval popupDisplayTimestamp = [[NSDate date]timeIntervalSince1970];
        NSDictionary *dictPopupDetails = @{kVersionNumberKey:appVersionString,
                                          kPopupDisplayTimestampKey:@(popupDisplayTimestamp)};
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:dictPopupDetails forKey:strDefaultsKey];
        [defaults synchronize];
    }


}


+(NSComparisonResult)compareVersionString:(NSString *)strVersion1 withString:(NSString *)strVersion2
{
    if (strVersion1.length > 0 && strVersion2.length > 0) {
        
        NSArray *arrVersion1Items = [strVersion1 componentsSeparatedByString:@"."];

        NSArray *arrVersion2Items = [strVersion2 componentsSeparatedByString:@"."];
        for (NSInteger index = 0; index < arrVersion1Items.count; index++) {
            NSString *strVersion1Item = [arrVersion1Items objectAtIndex:index];
            int version1Item = [strVersion1Item intValue];
            
            if (index == arrVersion2Items.count) {
                
                if (version1Item == 0) {
                    
                    ///strVersion1 = strVersion2, e.g use case 5.0 = 5
                    return NSOrderedSame;
                }
                else{
                   
                    ///strVersion1 > strVersion2, e.g use case 5.2 > 5
                    return NSOrderedDescending;
                    
                }
            }
            
             NSString *strVersion2Item = [arrVersion2Items objectAtIndex:index];
            int version2Item = [strVersion2Item intValue];
            
            if (version1Item > version2Item) {
                
                return NSOrderedDescending;
            }
            else if (version1Item < version2Item){
                
                return NSOrderedAscending;
            }
            else if((index == (arrVersion1Items.count - 1))
                    &&(index == (arrVersion2Items.count - 1))){
                
                ///both items are same
                return NSOrderedSame;
                
            }
            
        }

        ///Control will come out of for loop in below use cases:
        ///1)strVersion1 = strVersion2, e.g use case 5 = 5.0
        ///2)strVersion1 < strVersion2, e.g use case 5 < 5.2
        
        ///get the next version2Item in sequence
        NSString *strVersion2Item = [arrVersion2Items objectAtIndex:arrVersion1Items.count];
        int version2Item = [strVersion2Item intValue];
        if (version2Item == 0) {
            
            ///strVersion1 = strVersion2, e.g use case 5 = 5.0
            return NSOrderedSame;
        }
        else{
            
            ///strVersion1 < strVersion2, e.g use case 5 < 5.2
            return NSOrderedAscending;
            
        }

        return NSOrderedAscending;
  
    }
    else if(strVersion1.length > 0){
        
        return NSOrderedDescending;
    }
    else {
        
        return NSOrderedAscending;
    }
}

+(void)removeOnScreenKeyboard
{
    UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
    [rootVC.view endEditing:YES];
}


+(NSString *)getNumericStringFromString:(NSString *)strAlphaNumeric
{
    if (strAlphaNumeric.length > 0) {
    
        NSError *err = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\D" options:NSRegularExpressionCaseInsensitive error:&err];
        NSString *strNumericString = [regex stringByReplacingMatchesInString:strAlphaNumeric options:0 range:NSMakeRange(0, strAlphaNumeric.length) withTemplate:@""];
        //NSLog(@"%@ = %@",strAlphaNumeric,strNumericString);
        return strNumericString;

    }
    else{
        ///return empty string if the strAlphaNumeric length is 0 or if it's nil
        return @"";
    }
    
}



+(NSDictionary *)splitPhoneNumberAndCountryCodeFromNumber:(NSString *)strContactNumber
{
    
    NSMutableDictionary *dictContactDetails = nil;
    
    if (strContactNumber.length > 0) {
        
        ///Get numeric only string from it as it may contain some formatting characters other than numbers
        strContactNumber = [self getNumericStringFromString:strContactNumber];
        
        if (strContactNumber.length > 0) {
            
            ///If there is a numeric string then try to split it into country code and phone number if possible
            dictContactDetails = [NSMutableDictionary dictionary];
            
            ///1. Get the default country object as per current locale
            MA_Country *currentCountry = [MA_Country defaultCountry];
            
            ///2. Check if default country code matches with the initial digits of the contact number or not
            if ([strContactNumber hasPrefix:currentCountry.dialingCode]) {
                ///2.1 If it matches use default country object for country code and use the rest for the phone number.
                NSString *strPhoneNumber = nil;
                if (strContactNumber.length > currentCountry.dialingCode.length) {
                    
                    strPhoneNumber = [strContactNumber substringFromIndex:currentCountry.dialingCode.length];
                }
                
                ///put it in dictionary
                [dictContactDetails setObject:currentCountry forKey:kPhoneCountryKey];
                if (strPhoneNumber) {
                    
                    [dictContactDetails setObject:strPhoneNumber forKey:kPhoneNumberKey];
                }
                
                
            }
            else{
                
                ///2.2 If it didn't matches then get the list of country codes and iterate them to see if it matches with any.
                NSDictionary *dictISOAndDialingCodeMapping = [MA_Country getCountryISOAndDialingCodeMappingDictionary];
                
                MA_Country *country = nil;
                NSString *strPhoneNumber = nil;
                
                for (NSString *isoCode in dictISOAndDialingCodeMapping.allKeys) {
                    
                    NSString *strDialCode = [dictISOAndDialingCodeMapping objectForKey:isoCode];
                    if ([strContactNumber hasPrefix:strDialCode]) {
                        
                        ///Matching code found, create the country object
                        country = [[MA_Country alloc]init];
                        country.isoCode = isoCode;
                        country.name = [MA_Country countryNameFromCountryISOCode:isoCode];
                        country.dialingCode = strDialCode;
                        
                        break;
                        
                    }
                    
                    
                }
                
                if (country) {
                    
                    ///2.2.1 if it matches with any then use that part as country code and rest as phone number.
                    ///extract phone number from rest part
                    if (strContactNumber.length > country.dialingCode.length) {
                        
                        strPhoneNumber = [strContactNumber substringFromIndex:country.dialingCode.length];
                    }
                    
                    ///put it in dictionary
                    [dictContactDetails setObject:country forKey:kPhoneCountryKey];
                    if (strPhoneNumber) {
                        
                        [dictContactDetails setObject:strPhoneNumber forKey:kPhoneNumberKey];
                    }
                    
                    
                    
                }
                else{
                    
                    ///2.2.2 If it didn't matches then use complete string for phone number
                    [dictContactDetails setObject:strContactNumber forKey:kPhoneNumberKey];
                    
                }
                
                
            }
        }
    }
    
    return dictContactDetails;
    
}

+(BOOL)isPhoneNumberHasCountryCode:(NSString *)strContactNumber
{
    if(strContactNumber.length > 0){
        
        ///1. Get the default country object as per current locale
        MA_Country *currentCountry = [MA_Country defaultCountry];
        
        ///Get the country object for logged in user
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        NSString *strCurrentUserPhoneNumber = currentUser[kUserMobileNumberKey];
        MA_Country *userCountry = nil;
        if(strCurrentUserPhoneNumber.length > 0){
        
            NSDictionary *dictContactDetails = [self splitPhoneNumberAndCountryCodeFromNumber:strCurrentUserPhoneNumber];
            
            userCountry = [dictContactDetails objectForKey:kPhoneCountryKey];
            
        }
        
        if(userCountry && [strContactNumber hasPrefix:userCountry.dialingCode]){
            
            ///2.1 Phone number has the same dialing code as in current user mobile number
            return YES;
        }
        else if ([strContactNumber hasPrefix:currentCountry.dialingCode]) {
            
            ///2.2Phone number has dialing code of the country the current user lives
            return YES;
            
        }
        else{
            ///return no to give preference to current country contacts starting with series that can be the prefix of some other country code
            //EX. contact number 9278347843 will now be considered as current country number instead of Pakistan number(92 is the country code of Pakistan)
            return NO;

/*Code to match phone prefix with country code of some other country is commented out to give preference to current country contacts starting with series that can be the prefix of some other country code
            ///2.2 If it didn't matches then get the list of country codes and iterate them to see if it matches with any.
            NSDictionary *dictISOAndDialingCodeMapping = [MA_Country getCountryISOAndDialingCodeMappingDictionary];
            
            BOOL hasCountryCode = NO;
            
            for (NSString *isoCode in dictISOAndDialingCodeMapping.allKeys) {
                
                NSString *strDialCode = [dictISOAndDialingCodeMapping objectForKey:isoCode];
                if ([strContactNumber hasPrefix:strDialCode]) {
                    
                    ///Matching code found
                    hasCountryCode = YES;
                    
                    break;
                    
                }
                
                
            }
            
            return hasCountryCode;
            
*/
            
        }
        

    }
    else{
        
        return NO;
    }
}

#if (APP_IER || APP_RO112)

+(BOOL)isMobileNumberValid:(NSString *)strMobileNumber forCountry:(MA_Country *)country
{
    
    BOOL shouldVerifyLength = NO;
#if APP_IER
    
    NSString *dialingCodeForSouthAfrica = @"27";
    shouldVerifyLength = [country.dialingCode isEqualToString:dialingCodeForSouthAfrica];
#elif APP_RO112
    NSString *dialingCodeForRomania = @"40";
    shouldVerifyLength = [country.dialingCode isEqualToString:dialingCodeForRomania];
    
#endif
 
    if(shouldVerifyLength){
        
        NSString *strMobileNumWithoutDialingCode = [self removeCountryCodePrefixFromMobileNumber:strMobileNumber forCountry:country];
        
        NSInteger validMobileNumberLength = strMobileNumber.length;
#if APP_IER
        validMobileNumberLength = 9;
#elif APP_RO112
        validMobileNumberLength = 9;
#endif
        
        return  (strMobileNumWithoutDialingCode.length == validMobileNumberLength);
        
    }
    
    return YES;
}


+(NSString *)removeCountryCodePrefixFromMobileNumber:(NSString *)strMobileNumber forCountry:(MA_Country *)country
{
    
    NSArray *arrValidCountryDialingCodesPrefix = nil;

#if APP_IER
    
    NSString *dialingCodeForSouthAfrica = @"27";
    if([country.dialingCode isEqualToString:dialingCodeForSouthAfrica]){
        arrValidCountryDialingCodesPrefix = @[@"0",
                                              dialingCodeForSouthAfrica];
    }
   
#elif APP_RO112
    NSString *dialingCodeForRomania = @"40";
    if([country.dialingCode isEqualToString:dialingCodeForRomania]){
        arrValidCountryDialingCodesPrefix = @[@"0",
                                              dialingCodeForRomania];
    }
    
#endif
    
    for (NSString *strValidDialingCodePrefix in arrValidCountryDialingCodesPrefix) {
        
        if([strMobileNumber hasPrefix:strValidDialingCodePrefix]){
            
            ///Remove the prefix
            strMobileNumber = [strMobileNumber substringFromIndex:strValidDialingCodePrefix.length];
            
            ///exit out of loop as prefix is removed
            break;
        }
        
    }
    
    return strMobileNumber;
}


#endif


+(UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

+(void)localizeCancelButtonForSearchBar:(UISearchBar *)searchBar
{

    searchBar.showsCancelButton = YES;
    UIButton *cancelButton;
    UIView *topView = searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            cancelButton = (UIButton*)subView;
        }
    }
    if (cancelButton) {
        //Set the new title of the cancel button
        NSString *localizedCancelText = NSLocalizedString(@"Cancel", nil);
        [cancelButton setTitle:localizedCancelText forState:UIControlStateNormal];
    }
    
}

+(NSURL *)getGoogleMapsSearchUrlForAllPlatforms:(NSDictionary *)dictParams
{
    NSString *strSearchUrl = @"https://www.google.com/maps/search/";
    
    NSMutableDictionary *dictSearchParams = [dictParams mutableCopy];
    [dictSearchParams setObject:@1 forKey:@"api"];
    
    return [self getGoogleMapsUrlForAllPlatformsWithUrl:strSearchUrl byAppendingParams:dictSearchParams];

    

}

+(NSURL *)getGoogleMapsDirectionsUrlForAllPlatforms:(NSDictionary *)dictParams
{
    NSString *strDirectionsUrl = @"https://www.google.com/maps/dir/";
    
    NSMutableDictionary *dictDirectionsParams = [dictParams mutableCopy];
    [dictDirectionsParams setObject:@1 forKey:@"api"];
    
    return [self getGoogleMapsUrlForAllPlatformsWithUrl:strDirectionsUrl byAppendingParams:dictDirectionsParams];
    
    
}

+(NSURL *)getGoogleMapsUrlForAllPlatformsWithUrl:(NSString *)strUrl byAppendingParams:(NSDictionary *)dictParams
{
    NSString *strUrlWithParams = [ServerUtility stringByAppendingParams:dictParams toUrlString:strUrl];
    NSString *strEncodedUrl = [strUrlWithParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:strEncodedUrl];
    
    
}

+(NSString *)getAppLanguageCode:(BOOL)shouldExcludeCountry
{
   
    NSString *strLanguageCode = @"";
#if APP_RO112

    strLanguageCode = @"ro-RO";
    
#else

    strLanguageCode = [[NSLocale preferredLanguages]firstObject];
    strLanguageCode = strLanguageCode.length > 0 ? strLanguageCode : @"";
    
#endif
    
    if(shouldExcludeCountry){
        
        ///Remove country code which could be available after -
        strLanguageCode = [[strLanguageCode componentsSeparatedByString:@"-"]firstObject];
        
    }
    
    return strLanguageCode;
    
}

+(UIViewController*) getTopMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

+(NSArray *)getDefaultCellNames
{
    return @[NSLocalizedString(@"Friends", nil),
             NSLocalizedString(@"Family", nil),
             NSLocalizedString(@"Neighborhood Watch", nil),
             NSLocalizedString(@"Coworkers", nil),
             NSLocalizedString(@"School Friends", nil)];
    
}

+(NSDictionary *)getDefaultCellsLocalizedNameAndTypeMapping
{
    return @{@(PrivateCellTypeFamily):NSLocalizedString(@"Family", nil),
             @(PrivateCellTypeCoworkers):NSLocalizedString(@"Coworkers", nil),
             @(PrivateCellTypeSchoolmates):NSLocalizedString(@"School Friends", nil),
             @(PrivateCellTypeNeighbours):NSLocalizedString(@"Neighborhood Watch", nil)
             };
    
}

+(NSString *)getLocalizedNameForCell:(PFObject *)cell
{
    
    NSNumber *numCellType = cell[kCellTypeKey];
    if(numCellType){
        NSDictionary *dictDefaultCellMapping = [self getDefaultCellsLocalizedNameAndTypeMapping];
        NSString *strLocalizedDefCellName = dictDefaultCellMapping[numCellType];
        if(strLocalizedDefCellName.length > 0){
            
            return strLocalizedDefCellName;
        }
        
    }
    
    return cell[kCellNameKey];
    
}


+(NSDictionary *)getPublicCellsCategoryNameAndTypeMapping
{
    return @{
             @(PublicCellCategoryActivism):@"Activism",
             @(PublicCellCategoryCommercial):@"Commercial",
             @(PublicCellCategoryCommunitySafety):@"Community Safety",
             @(PublicCellCategoryEducation):@"Education",
             @(PublicCellCategoryGovernment):@"Government",
             @(PublicCellCategoryJournalism):@"Journalism",
             @(PublicCellCategoryPersonalSafety):@"Personal Safety",
             };
    
}

+(NSDictionary *)getPublicCellsCategoryLocalizedNameAndTypeMapping
{
    return @{
             @(PublicCellCategoryActivism):NSLocalizedString(@"Activism", nil),
             @(PublicCellCategoryCommercial):NSLocalizedString(@"Commercial", nil),
             @(PublicCellCategoryCommunitySafety):NSLocalizedString(@"Community Safety", nil),
             @(PublicCellCategoryEducation):NSLocalizedString(@"Education", nil),
             @(PublicCellCategoryGovernment):NSLocalizedString(@"Government", nil),
             @(PublicCellCategoryJournalism):NSLocalizedString(@"Journalism", nil),
             @(PublicCellCategoryPersonalSafety):NSLocalizedString(@"Personal Safety", nil),
             };
    
}

+(PublicCellCategory)getPublicCellCategoryFromString:(NSString *)strCategory
{
    __block PublicCellCategory category = PublicCellCategoryUnrecognized;
    ///Compare with english names
    NSDictionary *dictCategoryNameAndTypeMapping = [self getPublicCellsCategoryNameAndTypeMapping];
    [dictCategoryNameAndTypeMapping enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([strCategory isEqualToString:obj]){
            category = (PublicCellCategory)[key integerValue];
            *stop = YES;
        }
    }];
    
    if(category == PublicCellCategoryUnrecognized){
        ///Compare with localized names
        NSDictionary *dictLocalizedCategoryNameAndTypeMapping = [self getPublicCellsCategoryLocalizedNameAndTypeMapping];
        [dictLocalizedCategoryNameAndTypeMapping enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if([strCategory isEqualToString:obj]){
                category = (PublicCellCategory)[key integerValue];
                *stop = YES;
            }
        }];
    }
    
    return category;
}

+(NSArray *)getPublicCellCategoriesSortedByName
{
    NSDictionary *dictPubliCellCategoryMapping = [self getPublicCellsCategoryLocalizedNameAndTypeMapping];
    return [dictPubliCellCategoryMapping keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [(NSString *)obj1 localizedCaseInsensitiveCompare:(NSString *)obj2];
    }];
}

+(NSString *)getLocalizedPublicCellCategory:(PublicCellCategory)category
{
    NSDictionary *dictPubliCellCategoryMapping = [self getPublicCellsCategoryLocalizedNameAndTypeMapping];
    NSString *strLocalizedCellCategory = dictPubliCellCategoryMapping[@(category)];
    if(strLocalizedCellCategory.length > 0){
        return strLocalizedCellCategory;
    }
    else{
        return NSLocalizedString(@"Unrecognized", nil);
    }
}

+(PublicCellCategory)getPublicCellCategoryFromPublicCell:(PFObject *)publicCell
{
    NSNumber *numCellCategory = publicCell[kPublicCellTypeKey];
    if(numCellCategory){
        PublicCellCategory category = (PublicCellCategory)[numCellCategory integerValue];
        return category;
    }
    else{
        NSString *strCellCategory = publicCell[kPublicCellCategoryKey];
        PublicCellCategory category = [C411StaticHelper getPublicCellCategoryFromString:strCellCategory];
        return category;
    }
}

+(NSDictionary *)getMapObjectiveLocalizedNameAndTypeMapping {
    return @{
             @(MapObjectiveCategoryPharmacy): NSLocalizedString(@"Pharmacy",nil),
             @(MapObjectiveCategoryHospital): NSLocalizedString(@"Hospital",nil),
             @(MapObjectiveCategoryPolice): NSLocalizedString(@"Police",nil)
             };
}

+(NSString *)getLocalizedMapObjectiveCategory:(MapObjectiveCategory)category {
    NSDictionary *dictMapObjectiveCategoryMapping = [self getMapObjectiveLocalizedNameAndTypeMapping];
    NSString *strLocalizedMapObjectiveCategory = dictMapObjectiveCategoryMapping[@(category)];
    if(strLocalizedMapObjectiveCategory.length > 0){
        return strLocalizedMapObjectiveCategory;
    }
    else{
        return NSLocalizedString(@"Unrecognized", nil);
    }
}

+(UIImage *)getMapObjectiveMarkerImageForCategory:(MapObjectiveCategory)category {
    NSString *strPinName = nil;
    switch(category) {
        case MapObjectiveCategoryPharmacy:
            strPinName = @"pin_pharmacy";
            break;
        case MapObjectiveCategoryHospital:
            strPinName = @"pin_hospital";
            break;
        case MapObjectiveCategoryPolice:
            strPinName = @"pin_police";
            break;
        default:
            strPinName = @"pin_unrecognized";
            break;
    }
    return [UIImage imageNamed:strPinName];
}

+(UIImage *)getMapObjectiveImageForCategory:(MapObjectiveCategory)category {
    NSString *strImgName = nil;
    switch(category) {
        case MapObjectiveCategoryPharmacy:
            strImgName = @"ic_pharmacy";
            break;
        case MapObjectiveCategoryHospital:
            strImgName = @"ic_hospital";
            break;
        case MapObjectiveCategoryPolice:
            strImgName = @"ic_police";
            break;
        default:
            strImgName = @"ic_unrecognized";
            break;
    }
    return [UIImage imageNamed:strImgName];
}

+(BOOL)isUserDeleted:(PFUser *)user {
    return ([user[kUserIsDeletedKey]integerValue] == 1);
}

@end
