//
//  C411StaticHelper.h
//  cell411
//
//  Created by Milan Agarwal on 14/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import "C411Enums.h"
#import "ConfigConstants.h"
#import "ServerUtility.h"

#if FB_ENABLED
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#endif

@import MapKit;

typedef struct {
    CLLocationDegrees minlat;
    CLLocationDegrees minlon;
    CLLocationDegrees maxlat;
    CLLocationDegrees maxlon;
}MapRegionBoundary;

typedef enum{
    
    ColorTypeLight = 0,
    ColorTypeDark
    
}ColorType;

@class MA_Country;

@interface C411StaticHelper : NSObject
//****************************************************
#pragma mark - Generic Helper Methods
//****************************************************



/*!
 * @abstract Helper method to show UIAlertView
 * @param strTitle Takes NSString or localizedString to be used as title of Alert View. It can be nil
 * @param strMessage Takes NSString or localizedString to be used to show message to user.
 * @param viewController Reference of UIViewController object on which alert has to be presented
 */
+(void)showAlertWithTitle:(NSString *)strTitle message:(NSString *)strMessage onViewController:(UIViewController *)viewController;




/*!
 * @description Helper method to validate JSON object specially fetched from a web service API for NULL and nil.
 * @param jsonObject Any json object to be validated for Not NULL and nil.
 * @result YES if the object is neither nil nor of NSNULL type otherwise NO.
 */
+(BOOL)canUseJsonObject:(id)jsonObject;

+ (UIImage *)getRoundedRectImageFromImage :(UIImage *)image withSize:(CGSize)imageSize withCornerRadius :(float)cornerRadius;
+(void)configurePromptView:(UIView *)view;

// Assumes input like "00FF00" (RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (UIColor *)colorFromHexString:(NSString *)hexString andAlpha:(CGFloat)alpha;

+(NSString *)getFullNameUsingFirstName:(NSString *)strFirstName andLastName:(NSString *)strLastName;

+(MKCoordinateRegion)regionForBoundary:(MapRegionBoundary )boundary marginSpanPercent:(CGPoint)percentage;

+(MKPolyline *)polineWithGoogleEncoded:(NSString *)encodedString;
+(GMSPolyline *)googlePolylineWithGoogleEncoded:(NSString *)encodedString;
+(void)focusMap:(GMSMapView *)mapView toShowAllMarkers:(NSArray *)arrMarkers;
+(float)roundOffToHigherSide:(float)number;


///Parse helpers
+(void)sendInviteEmailTo:(NSString *)strEmailId from:(NSString *)strFullName withSenderEmail:(NSString *)strSenderEmail andCompletion:(PFIdResultBlock)completion;
+(void)sendVerificationRequestWithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion;
+(void)sendAlertWithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion;
+(void)sendAlertV2WithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion;
+(void)sendAlertV3WithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion;
+(void)sendSMSAndEmailAlertWithDetails:(NSMutableDictionary *)dictParams cloudFuncName:(NSString *)strCloudFuncName andCompletion:(PFIdResultBlock)completion;
+(void)getAverageStarsForUserWithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion;
+(void)retrieveTotalSelectedMembersWithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion;
+(void)sendChatMessage:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion;
+(void)broadcastMessage:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion;
+(void)sendChangeIntimationToPublicCellMembersWithDetails:(NSMutableDictionary *)dictParams andCompletion:(PFIdResultBlock)completion;

#if IS_CONTACTS_SYNCING_ENABLED
+(void)uploadContacts:(NSMutableDictionary *)dictParams withCompletion:(PFIdResultBlock)completion;
+(void)deleteContactsWithCompletion:(PFIdResultBlock)completion;
+(void)sendJoinedNotificationWithCompletion:(PFIdResultBlock)completion;
#endif

+(void)deleteMyAccountWithCompletion:(PFIdResultBlock)completion;
+(void)downloadMyDataWithCompletion:(PFIdResultBlock)completion;

//+(void)sendForgotPasswordRequestWithDetails:(NSDictionary *)dictParams andCompletion:(PFIdResultBlock)completion;
+(void)setAverageRatingForUserWithDetails:(NSMutableDictionary *)dictParams onLabel:(UILabel *)lblAvgRating;
+(void)getPublicCellWithObjectId:(NSString *)strObjectId andCompletion:(PFObjectResultBlock)completion;
///will save privilege in background and will fallback to saveEventually if error occured
+(void)savePrivilege:(NSString *)strPrivilege forUser:(PFUser *)user withOptionalCompletion:(PFBooleanResultBlock)optionalCompletion;
+(void)getFriendCountForUser:(PFUser *)user withCompletion:(PFIntegerResultBlock)completion;
+(void)setSecondPrivilegeIfApplicableForUser:(PFUser *)user;
+(void)didUserIssuedMinNormalAlertForSecondPrivilege:(PFUser *)user withCompletion:(void(^)(BOOL success, BOOL isConditionSatisfied))completion;
+(void)getPrivilegeForUser:(PFUser *)user shouldSetPrivilegeIfUndefined:(BOOL)setPrivilegeIfUndef andCompletion:(PFStringResultBlock)completion;
+(AlertType)getAlertTypeFromAlertTypeTag:(NSInteger)alertTypeTag;
+(AlertType)getAlertTypeUsingAlertTypeString:(NSString *)strAlertRegarding;
///Other shared methods
+(NSString *)getShareTextForUserWithName:(NSString *)strFullName alertType:(NSInteger)alertTypeTag andAdditionalNote:(NSString *)strAdditionalNote;
+(NSString *)getAlertTypeStringUsingAlertTypeTag:(NSInteger)alertTypeTag;
+(NSString *)getAlertTypeStringUsingAlertType:(AlertType)alertType;
+(NSString *)getLocalizedAlertTypeStringFromString:(NSString *)strAlertType;

+(UIImage *)snapshot:(UIView *)view;
+(NSString *)documentDirectoryPath;
+(BOOL)createFolderAtDocumentDirectoryWithName:(NSString *)strFolderName;
+(BOOL)createFolderAtPath:(NSString *)directoryPath;
+(void)appendString:(NSString *)strText atFilePath:(NSString *)strFilePath;

+(void)setDiagonalGradientOnView:(UIView *)view withColors:(NSArray *)arrGradientColors;

+(void)setPlaceholderColor:(UIColor *)color ofTextField:(UITextField *)textField;

+(void)makeCircularView:(UIView *)view;
+(void)getGravatarForEmail:(NSString *)strEmail ofSize:(int)imageSize roundedCorners:(BOOL)roundedCorner withCompletion:(void(^)(BOOL success, UIImage *image))completion;
+(NSString *)getAddressCompFromResult:(NSArray *)result forType:(NSString *)strType useLongName:(BOOL)useLongName;
+(NSString *)getDecimalStringFromNumber:(NSNumber *)decimalNumber uptoDecimalPlaces:(int)decimalPlaces;
+(void)callOnNumber:(NSString *)strPhoneNumber;
+(UIColor *)getColorForAlert:(NSString *)strAlertRegarding withColorType:(ColorType)colorType;
+(UIColor *)getColorForAlertType:(AlertType)alertType withColorType:(ColorType)colorType;
+(UIImage *)getAlertTypeSmallImageForAlertType:(NSString *)strAlertType;


///It will try to get the valid email if available and possible, first it will look into the username field and validate it to see if it contains valid email (which would be true if user signed up using email from version 3.1 of app ) else it will look into the email field of user to get the email which will contain a valid email if user signed up through social media and email was available at signup else it will look whether username field contains @ symbol if yes it will return the username to provide support to old users else it will return nil.NOTE: This method is assuming that if user signup using social media then username field will not contain @ symbol
+(NSString *)getEmailFromUser:(PFUser *)user;

///Check whether the email is valid or not
+(BOOL)isValidEmail:(NSString *)strEmail;

///Give you the signup type of user
+(SignUpType)getSignUpTypeOfUser:(PFUser *)user;

///Give descption string for publishing on facebook, strCity and strAdditionalNote are optional
+(NSString *)getFBAlertDescriptionForAlertRegarding:(NSString *)strAlertRegarding withCity:(NSString *)strCity issuerName:(NSString *)strIssuerName additionalNote:(NSString *)strAdditionalNote andLocationCoordinate:(CLLocationCoordinate2D)locCoordinate;
+(NSString *)getGoogleMapsWebUrlStringUsingCoordinate:(CLLocationCoordinate2D)locCoordinate;

#if FB_ENABLED
+(void)performLoginOrSignupWithFacebookFromViewController:(UIViewController *)viewController;
#endif

+(void)handleLoginCompletionWithUser:(PFUser *)user fromViewController:(UIViewController *)viewController andCompletion:(PFStringResultBlock)completion;

+(NSString *)stringByRemovingEncodedCharacter:(NSString *)strEncodedCharacter fromString:(NSString *)strEncodedString;

+(void)getUserWithEmail:(NSString *)strEmail andCompletion:(PFObjectResultBlock)completion;
+(void)getUserWithMobileNumber:(NSString *)strContactNumber ignoreCurrentUser:(BOOL)ignoreCurrentUser andCompletion:(PFObjectResultBlock)completion;

///this will update the email field on Parse(exactly with the provided email, so pass the trimmed lowercase email) and should only be used for the case with facebook user without email
+(void)updateEmail:(NSString *)strEmail forUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion;

///It will remove the objects whose issuedBy is nil
+(NSMutableArray *)alertsArrayByRemovingInvalidObjectsFromArray:(NSArray *)arrAlerts isForwardedAlert:(BOOL)isForwardedAlert;
+(NSMutableArray *)rideRequestArrayByRemovingInvalidObjectsFromArray:(NSArray *)arrRequests;
+(NSMutableArray *)rideResponseArrayByRemovingInvalidObjectsFromArray:(NSArray *)arrResponses;
+(BOOL)validateUserUsingObjectId:(NSString *)strObjectId;
+(BOOL)validateUserUsingFullName:(NSString *)strFullName;

//+(UILocalNotification *)presentLocalNotificationNowWithLocalizedMessage:(NSString *)strLocalizedMessage andUserInfo:(NSDictionary *)dictUserInfo;
+(id)presentLocalNotificationNowWithSound:(BOOL)isSoundEnabled localizedMessage:(NSString *)strLocalizedMessage userInfo:(NSDictionary *)dictUserInfo identifier:(NSString *)strNotifId;
+(void)cancelLocalNotification:(id)oldNotification;

+(NSArray *)getUniqueParseObjectsFromArray:(NSArray *)arrParseObjects;
+(NSDictionary *)getDistanceAndDurationFromDistanceMatrixResponse:(NSDictionary *)dictDistanceMatrixResponse;
+(NSString *)getFormattedTimeFromDate:(NSDate *)date withFormat:(TimeStampFormat)timeStampFormat;
+(GMSMarker *)addMarkerOnMap:(GMSMapView *)mapView atPosition:(CLLocationCoordinate2D)coordinate withImage:(UIImage *)imgMarker andTitle:(NSString *)strMarkerTitle;

+(NSURL *)getAvatarUrlForUser:(PFUser *)parseUser;
+(NSURL *)getCarUrlForUser:(PFUser *)parseUser;
+(NSMutableAttributedString *)getSemiboldAttributedStringWithString:(NSString *)string ofSize:(CGFloat)fontSize withUnboldTextInRange:(NSRange)unboldTextRange;
+(NSURLSessionDataTask *)updateLocationonLabel:(UILabel *)lblSelectedAddress usingCoordinate:(CLLocationCoordinate2D)locCoordinate;
+(NSURLSessionDataTask *)updateDistanceMatrixOnLabel:(UILabel *)lblDistanceMatrix usingOriginCoordinate:(CLLocationCoordinate2D)originCoordinate destinationCoordinate:(CLLocationCoordinate2D)destCoordinate withCompletion:(C411WebServiceHandler)completion;
+(void)callUser:(PFUser *)user;
+(BOOL)isRideRequestValid:(NSNumber *)createdAtInMillis;
+(int)getRandomVerificationCodeOfDigits:(int)totalDigits;
+(BOOL)validateAndProcessBackendResponse:(id)parsedResponse;
+(void)getDriverProfileForUser:(PFUser *)user withCompletion:(PFObjectResultBlock)completion;
+(float)calculateRideCostForDistance:(float)distanceInMiles duration:(NSInteger)rideTimeInMins  usingPickupCost:(float)pickupCost costPerMin:(float)costPerMin andCostPerMile:(float)costPerMile;
+(void)showUpdateAppAlertWithMessage:(NSString *)strMessage;
+(void)showUpdateAppNowOrLaterAlertWithMessage:(NSString *)strMessage;
+(void)showCustomVersionSpecificAlertWithMessage:(NSString *)strMessage shouldDisplayDontShowOption:(BOOL)shouldDisplayDontShowOption forDefaultsKey:(NSString *)strDefaultsKey;
+(NSComparisonResult)compareVersionString:(NSString *)strVersion1 withString:(NSString *)strVersion2;
+(void)removeOnScreenKeyboard;
+(NSString *)getNumericStringFromString:(NSString *)strAlphaNumeric;
+(NSDictionary *)splitPhoneNumberAndCountryCodeFromNumber:(NSString *)strContactNumber;
+(BOOL)isPhoneNumberHasCountryCode:(NSString *)strContactNumber;
#if (APP_IER || APP_RO112)
+(BOOL)isMobileNumberValid:(NSString *)strMobileNumber forCountry:(MA_Country *)country;
+(NSString *)removeCountryCodePrefixFromMobileNumber:(NSString *)strMobileNumber forCountry:(MA_Country *)country;

#endif

+(UIImageView *)findHairlineImageViewUnder:(UIView *)view;
+(void)localizeCancelButtonForSearchBar:(UISearchBar *)searchBar;
+(NSURL *)getGoogleMapsSearchUrlForAllPlatforms:(NSDictionary *)dictParams;
+(NSURL *)getGoogleMapsDirectionsUrlForAllPlatforms:(NSDictionary *)dictParams;
+(UIViewController*) getTopMostController;
+(NSDictionary *)getDefaultCellsLocalizedNameAndTypeMapping;
/*!
 *@description Will return the localized name of a cell if it's a default cell, else will return the same name as provided by user
 */
+(NSString *)getLocalizedNameForCell:(PFObject *)cell;
+(NSArray *)getPublicCellCategoriesSortedByName;
+(NSString *)getLocalizedPublicCellCategory:(PublicCellCategory)category;
+(PublicCellCategory)getPublicCellCategoryFromPublicCell:(PFObject *)publicCell;
+(NSString *)getLocalizedMapObjectiveCategory:(MapObjectiveCategory)category;
+(UIImage *)getMapObjectiveMarkerImageForCategory:(MapObjectiveCategory)category;
+(UIImage *)getMapObjectiveImageForCategory:(MapObjectiveCategory)category;
+(BOOL)isUserDeleted:(PFUser *)user;
@end
