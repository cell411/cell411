//
//  ConfigConstants.h
//  cell411
//
//  Created by Milan Agarwal on 19/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//
#import "Secrets.h"

#ifndef ConfigConstants_h
#define ConfigConstants_h


//****************************************************
#pragma mark - Color Constants
//****************************************************
#define POPUP_CROSS_BUTTON_COLOR    @"FF0000"

#define ALERT_VIDEO_COLOR_DARK                      @"b2367c"
#define ALERT_VIDEO_COLOR_LIGHT                     @"ff4eb2"
#define ALERT_PHOTO_COLOR_DARK                      @"b2367c"
#define ALERT_PHOTO_COLOR_LIGHT                     @"ff4eb2"
#if APP_IER
#define ALERT_PULLED_OVER_COLOR_DARK                @"b2367c"
#define ALERT_PULLED_OVER_COLOR_LIGHT               @"ff4eb2"
#else
#define ALERT_PULLED_OVER_COLOR_DARK                @"203384"
#define ALERT_PULLED_OVER_COLOR_LIGHT               @"2e49bd"
#endif
#define ALERT_ARRESTED_COLOR_DARK                   @"203384"
#define ALERT_ARRESTED_COLOR_LIGHT                  @"2e49bd"
#define ALERT_MEDICAL_ATTENTION_COLOR_DARK          @"006230"
#define ALERT_MEDICAL_ATTENTION_COLOR_LIGHT         @"008d45"
#define ALERT_CAR_BROKE_COLOR_DARK                  @"751990"
#define ALERT_CAR_BROKE_COLOR_LIGHT                 @"a824ce"
#define ALERT_CRIME_COLOR_DARK                      @"203384"
#define ALERT_CRIME_COLOR_LIGHT                     @"2e49bd"
#define ALERT_FIRE_COLOR_DARK                       @"b2750a"
#define ALERT_FIRE_COLOR_LIGHT                      @"ffa70f"
#define ALERT_DANGER_COLOR_DARK                     @"982626"
#define ALERT_DANGER_COLOR_LIGHT                    @"da3636"
#define ALERT_COP_BLOCKING_COLOR_DARK               @"203384"
#define ALERT_COP_BLOCKING_COLOR_LIGHT              @"2e49bd"
#define ALERT_BULLIED_COLOR_DARK                    @"6662b2"
#define ALERT_BULLIED_COLOR_LIGHT                   @"928dff"
#define ALERT_GENERAL_COLOR_DARK                    @"4d4d4d"
#define ALERT_GENERAL_COLOR_LIGHT                   @"6e6e6e"
#define ALERT_PANIC_COLOR_DARK                      @"982626"
#define ALERT_PANIC_COLOR_LIGHT                     @"da3636"
#if APP_RO112
#define ALERT_HIJACK_COLOR_DARK                     @"ab4002"
#define ALERT_HIJACK_COLOR_LIGHT                    @"ff5e00"
#else
#define ALERT_HIJACK_COLOR_DARK                     @"982626"
#define ALERT_HIJACK_COLOR_LIGHT                    @"da3636"
#endif
#define ALERT_FALLEN_COLOR_DARK                     @"982626"
#define ALERT_FALLEN_COLOR_LIGHT                    @"da3636"
#define ALERT_CAR_ACCIDENT_COLOR_DARK               @"751990"
#define ALERT_CAR_ACCIDENT_COLOR_LIGHT              @"a824ce"
#define ALERT_NATURAL_DISASTER_COLOR_DARK           @"014a6b"
#define ALERT_NATURAL_DISASTER_COLOR_LIGHT          @"0098db"
#define ALERT_PHYSICAL_ABUSE_COLOR_DARK             @"203384"
#define ALERT_PHYSICAL_ABUSE_COLOR_LIGHT            @"2e49bd"
#define ALERT_TRAPPED_COLOR_DARK                    @"54036e"
#define ALERT_TRAPPED_COLOR_LIGHT                   @"9205bf"
#define ALERT_PRE_AUTHORIZATION_COLOR_DARK          @"b2750a"
#define ALERT_PRE_AUTHORIZATION_COLOR_LIGHT         @"ffa70f"
#define ALERT_UNRECOGNIZED_COLOR_DARK               @"55423b"
#define ALERT_UNRECOGNIZED_COLOR_LIGHT              @"8d6e63"

#define PAY_CASH_COLOR                      @"0000ff"
#define PAY_SILVER_COLOR                    @"666666"
#define PAY_CRYPTO_COLOR                    @"ffcc00"
#define PAY_BARTERING_COLOR                 @"00cccc"
#define PAY_CREDIT_CARD_COLOR               @"00cc00"
#define PAY_SELECTED_ALPHA                  0.7
#define PAY_DESELECTED_ALPHA                0.3

//****************************************************
#pragma mark - App Groups Keys
//****************************************************

#if APP_GTA

#if DEBUG
///Keys for Debug builds
#define NOTIFICATION_SERVICE_SHARING_DEFAULTS   @"group.dev.safearx.gta.notificationExtensionSharingDefaults"
#else
///Keys for Release builds
#define NOTIFICATION_SERVICE_SHARING_DEFAULTS   @"group.prod.safearx.gta.notificationExtensionSharingDefaults"

#endif

#elif APP_RO112

#if DEBUG
///Keys for Debug builds
#define NOTIFICATION_SERVICE_SHARING_DEFAULTS   @"group.dev.cell411.ro112.notificationExtensionSharingDefaults"
#else
///Keys for Release builds
#define NOTIFICATION_SERVICE_SHARING_DEFAULTS   @"group.prod.cell411.ro112.notificationExtensionSharingDefaults"

#endif


#else

#if DEBUG
///Keys for Debug builds
#define NOTIFICATION_SERVICE_SHARING_DEFAULTS   @"group.dev.safearx.notificationExtensionSharingDefaults"
#else
///Keys for Release builds
#define NOTIFICATION_SERVICE_SHARING_DEFAULTS   @"group.prod.safearx.notificationExtensionSharingDefaults"

#endif

#endif

//****************************************************
#pragma mark - Firebase Keys
//****************************************************

#if DEBUG
///Keys for Debug builds
#define CHAT_ROOT_NODE  @"dev"
#define IMG_ROOT_NODE   @"images"

#else
///Keys for Release builds
#define CHAT_ROOT_NODE  @"live"
#define IMG_ROOT_NODE   @"images"


#endif


//****************************************************
#pragma mark - Chat Constants
//****************************************************

#if DEBUG
///Constant for Debug builds
#define ALERT_CHAT_EXPIRATION_TIME  72*60*60
#else
///Constant for Release builds
#define ALERT_CHAT_EXPIRATION_TIME  72*60*60


#endif

//****************************************************
#pragma mark - Application Values
//****************************************************


#define PATROL_MODE_VALUE_ON    @1
#define PATROL_MODE_VALUE_OFF   @0

#define PATROL_MODE_MIN_RADIUS  0
#define PATROL_MODE_MAX_RADIUS  50
#define PATROL_MODE_DEFAULT_RADIUS  50

#define PUBLIC_CELL_VISIBILITY_MIN_RADIUS 0
#define PUBLIC_CELL_VISIBILITY_MAX_RADIUS 200
#define PUBLIC_CELL_VISIBILITY_DEFAULT_RADIUS 100

#define NEW_PUBLIC_CELL_ALERT_VALUE_ON    @1
#define NEW_PUBLIC_CELL_ALERT_VALUE_OFF   @0

#define CNAME @"streamer.cell411inc.com"
#define WZA_APP_NAME    @"dvr"

#define TIME_TO_LIVE_FOR_RIDE_REQ 30*60  ///IN seconds
#define TIME_TO_LIVE_FOR_PICKUP_NOTIFY 60*60  ///IN seconds

#define DEFAULT_RIDE_CURRENCY   @"$"
#define DEFAULT_PICKUP_COST     2.0
#define DEFAULT_PER_MIN_COST    0.2
#define DEFAULT_PER_MILE_COST   2.0

#if DEBUG
///Time in seconds until next data can be downloaded, 1 day
#define DOWNLOAD_DATA_TIME_LIMIT (24 * 60 * 60)
#else
///Time in seconds until next data can be downloaded. 7 days
#define DOWNLOAD_DATA_TIME_LIMIT (7 * 24 * 60 * 60)
#endif

#if APP_IER

///IER Values
#define PRIVACY_POLICY_URL @"https://www.ier.co.za/terms-and-conditions/"
#define TERMS_AND_CONDITIONS_URL @"https://www.ier.co.za/terms-and-conditions/"
#define RATE_APP_URL    @"https://goo.gl/SLKUoa"
#define DEFAULT_GRAVATAR_URL    @"http://getcell411.com/wp-content/uploads/2016/08/ier.png"
#define FAQ_AND_TUTORIAL_URL    @"http://www.ier.co.za/faq/"
//#define SHARE_APP_TEXT  NSLocalizedString(@"Hi, I am using iER to issue alerts while emergencies. It's free. Why don't you check it out on your phone.\nhttp://www.ier.co.za/index.html", nil)
#define kOpenInGoogleMapCallbackUrlScheme   @"GMiER://"
#define CLIENT_FIRM_ID  @2
#define LOCALIZED_APP_NAME  NSLocalizedString(@"iER", nil)
#define CENTRAL_MGR_RESTORATION_ID  @"com.cell411.ier.cmrestorationid"
#define MAP_MARKER_ICON_NAME    @"ic_map_marker_ier"

/*
///LMA API Values
#define LMA_API_BASE_URL    @"http://lma.nanodynamix.co.za/api/pde/id/"
#define LMA_ALERT_API_ID    @"13"
#define LMA_ALERT_API_KEY    @"606c526eb4d3383fd312a61945e30022fcb4766d"

#define LMA_REG_API_ID      @"14"
#define LMA_REG_API_KEY      @"e69105423fe55f41f003a1655ba4db26ac7e1f4e"

#define LMA_API_PARAM_FIRST_NAME  @"First_Name"
#define LMA_API_PARAM_SURNAME  @"Surname"
#define LMA_API_PARAM_ALERT_TYPE  @"Alert_type"
#define LMA_API_PARAM_GEO_LOCATION  @"Geo_Location"
#define LMA_API_PARAM_CONTACT_MOBILE  @"Contact_Mobile"
#define LMA_API_PARAM_CONTACT_EMAIL  @"Contact_Email"
#define LMA_API_PARAM_EMERGENCY_CONTACT_MOBILE  @"Emergency_Contact_Mobile"
#define LMA_API_PARAM_EMERGENCY_CONTACT_EMAIL  @"Emergency_Contact_Email"
#define LMA_API_PARAM_EMERGENCY_CONTACT_NAME  @"Emergency_Contact_Name"
#define LMA_API_PARAM_BLOOD_TYPE  @"Blood_Type"
#define LMA_API_PARAM_ALLERGIES  @"Allergies"

#define LMA_API_HEADER_NDX_KEY  @"ndx-lma-key"
*/

#define IER_API_BASE_URL @"http://api.affinityhealth.co.za/api/ier/"

#define IER_API_NAME_REG    @"register"
#define IER_API_NAME_ALERT  @"panic"
#define IER_API_NAME_UPDATE_PROFILE  @"updateProfile"

#define IER_API_PARAM_USER_ID           @"User_ID"
#define IER_API_PARAM_UNIQUE_ID         @"unique_id"
#define IER_API_PARAM_FIRST_NAME        @"First_Name"
#define IER_API_PARAM_SURNAME           @"Surname"
#define IER_API_PARAM_CONTACT_MOBILE    @"Contact_Mobile"
#define IER_API_PARAM_CONTACT_EMAIL     @"Contact_Email"
#define IER_API_PARAM_BLOOD_GROUP       @"blood_group"
#define IER_API_PARAM_ALLERGIES         @"allergies"
#define IER_API_PARAM_CONDITIONS        @"conditions"
#define IER_API_PARAM_EMER_CONTACT      @"emergecy_contact"
#define IER_API_PARAM_EMER_CONTACT_NUM  @"emergcency_number"

#define IER_API_PARAM_GEO_LOCATION      @"Geo_Location"
#define IER_API_PARAM_ALERT_TYPE        @"Alert_Type"
#define IER_API_PARAM_NOTE              @"note"
#define IER_API_PARAM_IMG_URL           @"image_url"

#define DOWNLOAD_APP_URL    @"http://ier.co.za"

#elif APP_GTA

///GTA Values
#define PRIVACY_POLICY_URL @"https://getcell411.com/privacy-policy/"
#define TERMS_AND_CONDITIONS_URL @"http://getcell411.com/terms-and-conditions"
#define RATE_APP_URL    @"https://goo.gl/vkbFOc"
#define DEFAULT_GRAVATAR_URL    @"http://getcell411.com/wp-content/uploads/2016/08/gravatar.png"
#define FAQ_AND_TUTORIAL_URL    @"http://getcell411.com/#faq"
//#define SHARE_APP_TEXT  NSLocalizedString(@"Hi, I am using Cell 411 to issue alerts while emergencies. It's free. Why don't you check it out on your phone.\nhttp://getcell411.com", nil)
#define kOpenInGoogleMapCallbackUrlScheme   @"GMGTA://"
#define CLIENT_FIRM_ID  @0
#define LOCALIZED_APP_NAME  NSLocalizedString(@"GTA", nil)
#define CENTRAL_MGR_RESTORATION_ID  @"com.safearx.gta.cmrestorationid"
#define DOWNLOAD_APP_URL    @"http://getcell411.com/download"
#define MAP_MARKER_ICON_NAME    @"ic_map_marker"

#elif APP_RO112
#warning MILAN-> Need to Update this key

///RO 112 Values
#define PRIVACY_POLICY_URL @"https://getcell411.com/privacy-policy/"
#define TERMS_AND_CONDITIONS_URL @"http://getcell411.com/terms-and-conditions"
#define RATE_APP_URL    @"https://goo.gl/qXphMw"
#define DEFAULT_GRAVATAR_URL    @"http://getcell411.com/wp-content/uploads/2016/08/gravatar.png"
#define FAQ_AND_TUTORIAL_URL    @"http://getcell411.com/#faq"
//#define SHARE_APP_TEXT  NSLocalizedString(@"Hi, I am using Cell 411 to issue alerts while emergencies. It's free. Why don't you check it out on your phone.\nhttp://getcell411.com", nil)
#define kOpenInGoogleMapCallbackUrlScheme   @"GMRO112://"
#define CLIENT_FIRM_ID  @3
#define LOCALIZED_APP_NAME  NSLocalizedString(@"RO 112", nil)
#define CENTRAL_MGR_RESTORATION_ID  @"com.cell411.ro112.cmrestorationid"
#warning MILAN-> Need to Update this key
#define DOWNLOAD_APP_URL    @"https://goo.gl/qXphMw"
#define MAP_MARKER_ICON_NAME    @"ic_map_marker_ro112"


#else

///Cell 411 Values
#define PRIVACY_POLICY_URL @"https://getcell411.com/privacy-policy/"
#define TERMS_AND_CONDITIONS_URL @"http://getcell411.com/terms-and-conditions"
#define RATE_APP_URL    @"https://goo.gl/vkbFOc"
#define DEFAULT_GRAVATAR_URL    @"http://getcell411.com/wp-content/uploads/2016/08/gravatar.png"
#define FAQ_AND_TUTORIAL_URL    @"http://getcell411.com/#faq"
//#define SHARE_APP_TEXT  NSLocalizedString(@"Hi, I am using Cell 411 to issue alerts while emergencies. It's free. Why don't you check it out on your phone.\nhttp://getcell411.com", nil)
#define kOpenInGoogleMapCallbackUrlScheme   @"GMCell411://"
#define CLIENT_FIRM_ID  @1
#define LOCALIZED_APP_NAME  NSLocalizedString(@"Cell 411", nil)
#define CENTRAL_MGR_RESTORATION_ID  @"com.safearx.cell411.cmrestorationid"
#define DOWNLOAD_APP_URL    @"http://getcell411.com/download"
#define MAP_MARKER_ICON_NAME    @"ic_map_marker"



#endif

///Alert Portal Users API

#define ALERT_PORTAL_USERS_API_NAME_BROADCAST_ALERT @"broadcast_alert.php"
#define ALERT_PORTAL_USERS_API_PARAM_ALERT_ID   @"cell411AlertId"
#define ALERT_PORTAL_USERS_API_PARAM_ISSUER_ID   @"issuerId"


///To DISABLE/ENABLE FACEBOOK completely from a target follow steps in file white_label_app_creation_basic_steps.rtf
///To DISBALE/ENABLE VIDEO STREAMING completely from a target follow steps in file white_label_app_creation_basic_steps.rtf



//****************************************************
#pragma mark - Update Pic API Keys
//****************************************************


///API NAME
#define API_NAME_UPDATE_PIC @"update_pic.php"
///API PARAMS
#define UPDATE_PIC_API_PARAM_IMAGE_TYPE @"image_type"
#define UPDATE_PIC_API_PARAM_USER_ID    @"user_id"
#define UPDATE_PIC_API_PARAM_MODE    @"mode"
#define UPDATE_PIC_API_PARAM_APP_ID    @"app_id"

///IMAGE TYPE VALUES
#define IMAGE_TYPE_AVATAR   @"a"
#define IMAGE_TYPE_CAR   @"c"

///MODE TYPE VALUES
#define MODE_TYPE_DEV    @"d"
#define MODE_TYPE_PROD    @"p"



///Response keys
#define kResponseTypeKey          @"res_type"
#define kResponseTypeData         @"Data"
#define kResponseTypeWarning      @"Warning"
#define kResponseTypeError        @"Error"
#define kResponseTypeErrorDisplay @"ErrorDisplay"
#define kMessageKey               @"msg"


//****************************************************
#pragma mark - Download image url values
//****************************************************

#if APP_IER

///IER VALUES
#if DEBUG
///BUCKET NAME FOR DEVELOPMENT
#define DOWNLOAD_PIC_API_BUCKET_NAME @"cell411-ier-dev"

#else
///BUCKET NAME FOR PRODUCTION
#define DOWNLOAD_PIC_API_BUCKET_NAME @"cell411-ier"
#endif

#elif APP_RO112

///RO112 VALUES
#if DEBUG
///BUCKET NAME FOR DEVELOPMENT
#define DOWNLOAD_PIC_API_BUCKET_NAME @"cell411-ro112-dev"

#else
///BUCKET NAME FOR PRODUCTION
#define DOWNLOAD_PIC_API_BUCKET_NAME @"cell411-ro112"
#endif

#else

///CELL 411 VALUES
#if DEBUG
///BUCKET NAME FOR DEVELOPMENT
#define DOWNLOAD_PIC_API_BUCKET_NAME @"cell411-dev"

#else
///BUCKET NAME FOR PRODUCTION
#define DOWNLOAD_PIC_API_BUCKET_NAME @"cell411"
#endif

#endif



#define DOWNLOAD_PIC_API_BASE_URL @"https://s3.amazonaws.com/"
#define DOWNLOAD_PIC_AVATAR_FOLDER_NAME @"profile_pic"
#define DOWNLOAD_PIC_CAR_FOLDER_NAME @"vehicle_pic"


//****************************************************
#pragma mark - App Version api values
//****************************************************

#define APP_VERSION_API_NAME @"appversion.php"

//****************************************************
#pragma mark - Alert Received Ack API
//****************************************************

#define ACK_RECEIVED_ALERT_API_NAME @"alert_received_ack.php"


//****************************************************
#pragma mark - COMMON KEYS FOR API
//****************************************************

#if DEBUG
///BASE URL
#define API_BASE_URL @"https://dev.copblock.app/webservice/api/v1/"
#define IS_APP_LIVE @0

#else
///BASE URL
#define API_BASE_URL @"https://pro.copblock.app/webservice/api/v1/"
#define IS_APP_LIVE @1

#endif


#define API_PARAM_PLATFORM @"platform"
#define API_PARAM_APP_ID @"app_id"
#define API_PARAM_MIN_VERSION  @"minimum_version"
#define API_PARAM_RECOMMENDED_VERSION  @"recommended_version"
#define API_PARAM_MAJOR_VERSION  @"major_version"
#define API_PARAM_CURRENT_VERSION  @"current_version"
#define API_PARAM_REMAINING_DAYS  @"remaining_days"
#define API_PARAM_BAD_VERSIONS  @"bad_versions"
#define API_PARAM_DESC_MIN_VERSION  @"description_minimum_version"
#define API_PARAM_DESC_RECOMMENDED_VERSION  @"description_recommended_version"
#define API_PARAM_DESC_RECOMMENDED_VERSION_PERIOD_OVER  @"description_recommended_version_period_over"
#define API_PARAM_DESC_MAJOR_VERSION  @"description_major_version"
#define API_PARAM_DESC_CURRENT_VERSION  @"description_current_version"
#define API_PARAM_VERSION   @"version"
#define API_PARAM_DESCRIPTION   @"description"
#define API_PARAM_MESSAGES @"messages"
#define API_PARAM_PROMPT_FREQUENCY  @"prompt_frequency"

#define API_PLATFORM_VALUE  @"ios"

#define API_PROMPT_FREQUENCY_VALUE_ALWAYS   @"always"
#define API_PROMPT_FREQUENCY_VALUE_DAILY   @"daily"
#define API_PROMPT_FREQUENCY_VALUE_ONCE   @"once"

#define API_PARAM_CLIENT_FIRM_ID   @"clientFirmId"
#define API_PARAM_IS_LIVE   @"isLive"
#define API_PARAM_USER_ID   @"userId"
#define API_PARAM_KEY   @"key"



#endif /* ConfigConstants_h */
