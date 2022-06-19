//
//  Constants.h
//  cell411
//
//  Created by Milan Agarwal on 15/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

//****************************************************
#pragma mark - Notifications
//****************************************************

#define kFriendListUpdatedNotification  @"com.wiselysoft.friendListUpdatedNotification"
#define kCellsListUpdatedNotification  @"com.wiselysoft.CellsListUpdatedNotification"
#define kOwnedPublicCellsListUpdatedNotification  @"com.wiselysoft.ownedPublicCellsListUpdatedNotification"

#define kCellsMembersUpdatedNotification  @"com.wiselysoft.CellsMembersUpdatedNotification"
#define kRecivedAlertFromNeedyNotification  @"com.wiselysoft.recivedAlertFromNeedyNotification"
#define kRecivedVideoStreamingNotification  @"com.wiselysoft.recivedVideoStreamingNotification"
#define kRecivedAlertFromHelperNotification  @"com.wiselysoft.recivedAlertFromHelperNotification"
#define kRecivedAlertFromRejectorNotification  @"com.wiselysoft.recivedAlertFromRejectorNotification"
#define kRecivedAlertForFriendRequestNotification  @"com.wiselysoft.recivedAlertForFriendRequestNotification"
#define kRecivedAlertForFriendApprovedNotification  @"com.wiselysoft.recivedAlertForFriendApprovedNotification"
#define kRecivedAlertToJoinPublicCellNotification  @"com.wiselysoft.recivedAlertToJoinPublicCellNotification"
#define kRecivedAlertForNewPublicCellCreatedNotification  @"com.wiselysoft.recivedAlertForNewPublicCellCreatedNotification"
#define kReceivedRideRequestNotification  @"com.wiselysoft.receivedRideRequestNotification"
#define kReceivedRideInterestedNotification  @"com.wiselysoft.receivedRideInterestedNotification"
#define kReceivedRideConfirmedNotification  @"com.wiselysoft.receivedRideConfirmedNotification"
#define kReceivedRideRejectedNotification  @"com.wiselysoft.receivedRideRejectedNotification"
#define kReceivedRideSelectedNotification  @"com.wiselysoft.receivedRideSelectedNotification"
#define kRecivedAlertForUserRemovedFromCellNotification  @"com.wiselysoft.recivedAlertForUserRemovedFromCellNotification"
#define kRecivedUserJoinedNotification  @"com.wiselysoft.recivedUserJoinedNotification"



#define kLocationAccuracyValueChangedNotification  @"com.wiselysoft.locationAccuracyValueChangedNotification"
//#define kLocationUpdateValueChangedNotification  @"com.wiselysoft.locationUpdateValueChangedNotification"
//#define kPatrolModeValueChangedNotification  @"com.wiselysoft.patrolModeValueChangedNotification"
//#define kNewPublicCellCreationAlertValueChangedNotification  @"com.wiselysoft.newPublicCellCreationAlertValueChangedNotification"
#define kAllOkValueChangedNotification  @"com.wiselysoft.allOkValueChangedNotification"
#define kDisplayContactsVCNotification  @"com.wiselysoft.displayContactsVCNotification"
#define kRecivedPhotoAlertNotification  @"com.wiselysoft.recivedPhotoAlertNotification"
#define kDisplayPublicCellsTabVCNotification  @"com.wiselysoft.displayPublicCellsTabVNotification"
#define kDisplayAlertDetailVCNotification  @"com.wiselysoft.displayAlertDetailVCNotification"
#define kPublicCellUpdatedNotification  @"com.wiselysoft.publicCellUpdatedNotification"
#define kJoinPublicCellNotification  @"com.wiselysoft.joinPublicCellNotification"
#define kLeavePublicCellNotification  @"com.wiselysoft.leavePublicCellNotification"
#define kPublicCellJoinedNotification  @"com.wiselysoft.publicCellJoinedNotification"
#define kPublicCellLeavedNotification  @"com.wiselysoft.publicCellLeavedNotification"
#define kPublicCellVerificationRequestSentNotification  @"com.wiselysoft.publicCellVerificationRequestSentNotification"
#define kPublicCellUserRemovedNotification  @"com.wiselysoft.publicCellUserRemovedNotification"

#define kPublicCellDoesNotExistNotification  @"com.wiselysoft.publicCellDoesNotExistNotification"
#define kRefreshPublicCellListingNotification  @"com.wiselysoft.refreshPublicCellListingNotification"

#define kDidUpdateVideoDownloadProgressNotification  @"com.wiselysoft.didUpdateVideoDownloadProgressNotification"
#define kDidFinishDownloadingVideoNotification  @"com.wiselysoft.didFinishDownloadingVideoNotification"

#define kMyProfileUpdatedNotification   @"com.wiselysoft.myProfileUpdatedNotification"

#define kDidMovedAwayFromContactListNotification   @"com.wiselysoft.didMovedAwayFromContactListNotification"
#define kDidMovedAwayFromSearchFriendsNotification   @"com.wiselysoft.didMovedAwayFromSearchFriendsNotification"
#define kUserUnblockedNotification   @"com.wiselysoft.userUnblockedNotification"
#define kUserBlockedNotification   @"com.wiselysoft.userBlockedNotification"

#define kDidOpenedPhotoVCNotification  @"com.wiselysoft.didOpenedPhotoVCNotification"
#define kDidClosedPhotoVCNotification  @"com.wiselysoft.didClosedPhotoVCNotification"
#define kDidOpenedRideSettingsVCNotification  @"com.wiselysoft.didOpenedRideSettingsVCNotification"
#define kDidClosedRideSettingsVCNotification  @"com.wiselysoft.didClosedRideSettingsVCNotification"
#define kDidOpenedRideReviewsVCNotification  @"com.wiselysoft.didOpenedRideReviewsVCNotification"
#define kDidClosedRideReviewsVCNotification  @"com.wiselysoft.didClosedRideReviewsVCNotification"
#define kDidOpenedChatVCNotification  @"com.wiselysoft.didOpenedChatVCNotification"
#define kDidClosedChatVCNotification  @"com.wiselysoft.didClosedChatVCNotification"
#define kDidOpenedNonAppUsersSelectionVCNotification  @"com.wiselysoft.didOpenedNonAppUsersSelectionVCNotification"
#define kDidClosedNonAppUsersSelectionVCNotification  @"com.wiselysoft.didClosedNonAppUsersSelectionVCNotification"


#define kUserDidLinkedToFBNotification  @"com.wiselysoft.userDidLinkedToFBNotification"

#define kSendPanicOrFallenAlertNotifocation  @"com.wiselysoft.sendPanicOrFallenAlertNotifocation"

#define kPhoneAddedNotification  @"com.wiselysoft.phoneAddedNotification"
#define kPhoneUpdatedNotification  @"com.wiselysoft.phoneAddedNotification"

#define kShowRideOverlayNotification  @"com.wiselysoft.showRideOverlayNotification"
#define kHideRideOverlayNotification  @"com.wiselysoft.hideRideOverlayNotification"
//#define kResetPasswordNotification  @"com.wiselysoft.resetPasswordNotification"
#define kNewChatMessageArrivedNotification  @"com.wiselysoft.newChatMessageArrivedNotification"
#define kUnreadMsgCountUpdatedNotification @"com.wiselysoft.unreadMsgCountUpdatedNotification"

#define kImportContactListInitializedNotification   @"com.wiselysoft.importContactListInitializedNotification"
#define kNonAppUserCellsListUpdatedNotification  @"com.wiselysoft.nonAppUserCellsListUpdatedNotification"
#define kContactSyncingEnabledNotification  @"com.wiselysoft.contactSyncingEnabledNotification"

#define kLocationUpdatedNotification  @"com.wiselysoft.locationUpdatedNotification"
#define kLocationAuthorizationStatusChangedNotification  @"com.wiselysoft.locationAuthorizationStatusChangedNotification"
#define kEnableLocationPopupCancelTappedNotification  @"com.wiselysoft.enableLocationPopupCancelTappedNotification"
#define kEnableLocationPopupEnableTappedNotification  @"com.wiselysoft.enableLocationPopupEnableTappedNotification"
#define kLocationBasedFeaturesTemporarilyDisabledNotification  @"com.wiselysoft.locationBasedFeaturesTemporarilyDisabledNotification"
#define kLocationBasedFeaturesReenabledNotification  @"com.wiselysoft.locationBasedFeaturesReenabledNotification"
#define kDarkModeValueChangedNotification  @"com.wiselysoft.darkModeValueChangedNotification"


//****************************************************
#pragma mark - Notification user info keys
//****************************************************

#define kRefreshedPublicCellKey  @"refreshedPublicCell"
#define kPanicOrFallenAlertTypeKey   @"panicOrFallenAlertTypeKey"

///Local Notification Identifiers
#define kLocalNotificationIdentifier @"LN_"
#define kChatMessageLocalNotifIdentifier    @"CM"

//****************************************************
#pragma mark - User defaults Keys
//****************************************************

#define kDidSetLocationSettings  @"didSetLocationSettings"
#define kLocationUpdateOn  @"locationUpdateOn"
#define kLocationAccuracyOn  @"locationAccuracyOn"
#define kPublishOnFB  @"publishOnFB"
#define kIncludeSecurityGuards    @"includeSecurityGuards"
#define kStreamVideoOnFBWall    @"streamVideoOnFBWall"
#define kStreamVideoOnFBPage  @"streamVideoOnFBPage"
#define kStreamVideoOnUserYTChannel  @"streamVideoOnUserYTChannel"
#define kStreamVideoOnCell411YTChannel  @"streamVideoOnCell411YTChannel"
#define kRecordVideoLocally @"recordVideoLocally"
#define kVideoStreamingResolution @"videoStreamingResolution"
#define kUserLiveYTChannelStreamName    @"userLiveYTChannelStreamName"
#define kUserLiveYTChannelServerUrl    @"userLiveYTChannelServerUrl"
#define kPanicAlertSettings @"panicAlertSettings"
#define kAlertSettings @"alertSettings"

#define kDarkMode  @"darkMode"
#define kPatrolModeRadius  @"patrolModeRadius"
#define kDispatchMode  @"dispatchMode"
#define kFakeDelete  @"fakeDelete"
#define kPublicCellVisibilityRadius  @"publicCellVisibilityRadius"
#define kCenterUserLocation @"centerUserLocation"
#define kMetricSystem   @"metricSystem"
#define kMetricSystemMiles  @"Miles"
#define kMetricSystemKms    @"Kilometers"
#define kUserPrivilegeKey  @"privilege"

///Privilege Type Values
#define kPrivilegeTypeFirst  @"FIRST"
#define kPrivilegeTypeSecond  @"SECOND"
#define kPrivilegeTypeBanned  @"BANNED"
#define kPrivilegeTypeShadowBanned  @"SHADOW_BANNED"
#define kPrivilegeTypeSuspended  @"SUSPENDED"

///Default value for user's Live Youtube channel Server Url
#define kUserLiveYTChannelDefaultServerUrl @"a.rtmp.youtube.com/live2"

///AppVersion keys
#define kVersionNumberKey   @"versionNumber"
#define kPopupDisplayTimestampKey   @"popupDisplayTimestamp"
#define kDontShowPopupKey   @"dontShowPopup"

///Chat data keys
#define kRecentChatKey @"recentChats"
#define kChatRoomsSettingsKey   @"chatRoomSettings"

///Logged In Keys
#define kIsLoggedIn @"ILI"
#define kLoggedInUserIdKey     @"userId"

///User Location keys
#define kLastKnowLocationKey        @"lkl"
#define kLastKnowLocLatitudeKey     @"lkllat"
#define kLastKnowLocLongitudeKey    @"lkllong"

///Temporary disabling Location services keys
#define kTempDisabledServicesKey   @"tds"
#define kTempDisabledServiceNewPublicCellAlert 0
#define kTempDisabledServicePatrolMode 1
#define kTempDisabledServiceRideRequests 2
#define kTempDisabledServiceUpdateLocation 3

///Disable download until key
#define kDisableDownloadMyDataUntilKey  @"ddmdu"


//****************************************************
#pragma mark - Date Formats
//****************************************************

#define kDateFormatTimeInAMPM  @"hh:mm a"
#define kDateFormatDateInddMMyyyy  @"dd/MM/yyyy"


//****************************************************
#pragma mark - User Class Keys
//****************************************************

///Field Keys
#define kUserUsernameKey  @"username"
#define kUserFirstnameKey  @"firstName"
#define kUserLastnameKey  @"lastName"
#define kUserMobileNumberKey  @"mobileNumber"
#define kUserFriendsKey  @"friends"
#define kUserEmergencyContactNameKey  @"emergencyContactName"
#define kUserEmergencyContactNumberKey  @"emergencyContactNumber"
#define kUserSpamUsersKey  @"spamUsers"
#define kUserSpammedByKey  @"spammedBy"
#define kUserPatrolModeKey  @"PatrolMode"
#define kUserLocationKey  @"location"
#define kUserBloodTypeKey  @"bloodType"
#define kUserAllergiesKey  @"allergies"
#define kUserOtherMedicalCondtionsKey  @"otherMedicalConditions"
#define kUserNewPublicCellAlertKey  @"newPublicCellAlert"
#define kUserClientFirmIdKey  @"clientFirmId"
#define kUserRideRequestAlertKey    @"rideRequestAlert"
#define kUserPhoneVerifiedKey   @"phoneVerified"
#define kUserImageNameKey   @"imageName"
#define kUserCarImageNameKey   @"carImageName"
#define kUserRoleIdKey  @"roleId"
#define kUserSyncContactsKey  @"syncContacts"
#define kUserIsActiveKey  @"isActive"
#define kUserIsDeletedKey   @"isDeleted"

//****************************************************
#pragma mark - Cell Class Keys
//****************************************************

///Class Key
#define kCellClassNameKey  @"Cell"

///Field Keys
#define kCellCreatedByKey  @"createdBy"
#define kCellNameKey  @"name"
#define kCellMembersKey  @"members"
#define kCellNauMembersKey  @"nauMembers"
#define kCellTypeKey    @"type"

#define kCellNauMemberNameKey    @"name"
#define kCellNauMemberEmailKey    @"email"
#define kCellNauMemberPhoneKey    @"phone"
#define kCellNauMemberTypeKey    @"type"

#define kCellNauMemberTypePhone    1
#define kCellNauMemberTypeEmail    2


//****************************************************
#pragma mark - Cell411Alert Class Keys
//****************************************************

///Class Key
#define kCell411AlertClassNameKey  @"Cell411Alert"

///Field Keys
#define kCell411AlertAdditionalNoteKey  @"additionalNote"
#define kCell411AlertAlertTypeKey  @"alertType"
#define kCell411AlertInitiatedByKey  @"initiatedBy"
#define kCell411AlertIssuedByKey  @"issuedBy"
#define kCell411AlertIssuerFirstNameKey  @"issuerFirstName"
#define kCell411AlertIssuerIdKey  @"issuerId"
#define kCell411AlertLocationKey  @"location"
#define kCell411AlertRejectedByKey  @"rejectedBy"
#define kCell411AlertTargetMembersKey  @"targetMembers"
#define kCell411AlertTargetNauMembersKey  @"targetNAUMembers"
#define kCell411AlertToKey  @"to"
#define kCell411AlertStatusKey  @"status"
#define kCell411AlertEntryForKey  @"entryFor"
#define kCell411AlertIsGlobalKey  @"isGlobal"
#define kCell411AlertPhotoKey  @"photo"
#define kCell411AlertDispatchModeKey  @"dispatchMode"
#define kCell411AlertForwardedByKey  @"forwardedBy"
#define kCell411AlertForwardedToMembersKey  @"forwardedToMembers"
#define kCell411AlertForwardedAlertKey  @"forwardedAlert"
#define kCell411AlertCellIdKey  @"cellId"
#define kCell411AlertCellMembersKey  @"cellMembers"
#define kCell411AlertCellNameKey  @"cellName"
#define kCell411AlertSeenByKey  @"seenBy"
#define kCell411AlertAlertIdKey  @"alertId"
#define kCell411AlertAudienceAUKey  @"audienceAU"
#define kCell411AlertCityKey  @"city"
#define kCell411AlertCountryKey  @"country"
#define kCell411AlertFullAddressKey  @"fullAddress"


///Alert Type values
#define kAlertTypeCopBlocking  @"Cop Blocking"
#define kAlertTypeFire  @"Fire"
#define kAlertTypeCrime  @"Crime"
#define kAlertTypeVehiclePulled  @"Vehicle Pulled"
#define kAlertTypeArrested  @"Arrested"
#define kAlertTypeMedical  @"Medical"
#define kAlertTypeVehicleBroken  @"Vehicle Broken"
#define kAlertTypeDanger  @"Danger"
#define kAlertTypeBullied  @"Bullied"
#define kAlertTypeGeneral  @"General"
#define kAlertTypeVideo  @"Video"
#define kAlertTypePhoto  @"Photo"
#define kAlertTypeHijack  @"Hijack"
#define kAlertTypePanic  @"Panic"
#define kAlertTypeFallen  @"Fallen"
#define kAlertTypeCustom  @"Custom"
#define kAlertTypePhysicalAbuse  @"Physical Abuse"
#define kAlertTypeTrapped  @"Trapped"
#define kAlertTypeCarAccident  @"Car Accident"
#define kAlertTypeNaturalDisaster  @"Natural Disaster"
#define kAlertTypePreAuthorisation  @"Pre Authorisation"


///Alert Status Values
#define kAlertStatusPending  @"PENDING"
#define kAlertStatusDenied  @"DENIED"
#define kAlertStatusApproved  @"APPROVED"
#define kAlertStatusAllOk  @"OK"
#define kAlertStatusProcessingVideo  @"PROC_VID"
#define kAlertStatusLive  @"LIVE"
#define kAlertStatusVOD  @"VOD"
#define kAlertStatusLeft  @"LEFT"
#define kAlertStatusRemoved  @"REMOVED"


///Entry For Values
#define kEntryForFriendInvite  @"FI"
#define kEntryForFriendRequest  @"FR"
#define kEntryForCellRequest  @"CR"

//****************************************************
#pragma mark - Task Class Keys
//****************************************************
///Class Key
#define kTaskClassNameKey  @"Task"

///Field Keys
#define kTaskAssigneeUserIdKey  @"assigneeUserId"
#define kTaskUserIdKey  @"userId"
#define kTaskTaskKey  @"task"
#define kTaskStatusKey  @"status"

///Task Values
#define kTaskFriendAdd  @"FRIEND_ADD"
#define kTaskSpamAdd  @"SPAM_ADD"
#define kTaskSpamRemove  @"SPAM_REMOVE"

///Task Status Values
#define kTaskStatusPending  @"PENDING"

//****************************************************
#pragma mark - AdditionalNote Class Keys
//****************************************************
///Class Key
#define kAdditionalNoteClassNameKey  @"AdditionalNote"

///Field Keys
#define kAdditionalNoteCell411AlertIdKey  @"cell411AlertId"
#define kAdditionalNoteNoteKey  @"note"
#define kAdditionalNoteSeenKey  @"seen"
#define kAdditionalNoteWriterIdKey  @"writerId"
#define kAdditionalNoteWriterNameKey  @"writerName"
#define kAdditionalNoteWriterDurationKey  @"writerDuration"
#define kAdditionalNoteAlertTypeKey  @"alertType"
#define kAdditionalNoteForwardedByKey  @"forwardedBy"
#define kAdditionalNoteCellIdKey  @"cellId"
#define kAdditionalNoteCellNameKey  @"cellName"
#define kAdditionalNoteUserTypeKey  @"userType"

///userType Values
#define kUserTypeFacebook @"FB"

//****************************************************
#pragma mark - Public Cell Class Keys
//****************************************************

///Class Key
#define kPublicCellClassNameKey  @"PublicCell"

///Field Keys
#define kPublicCellCreatedByKey  @"createdBy"
#define kPublicCellGeoTagKey  @"geoTag"
/*OLD implementation of verification request handling
#define kPublicCellIsVerifiedKey  @"isVerified"
*/
#define kPublicCellNameKey  @"name"
#define kPublicCellMembersKey  @"members"
#define kPublicCellTotalMembersKey  @"totalMembers"
#define kPublicCellCategoryKey  @"category"
#define kPublicCellDescriptionKey  @"description"
#define kPublicCellVerificationStatusKey    @"verificationStatus"
#define kPublicCellTypeKey  @"cellType"
#define kPublicCellCityKey  @"city"
#define kPublicCellCountryKey  @"country"
#define kPublicCellFullAddressKey  @"fullAddress"

///Cell Join Status Values
#define kCellJoinStatusJoin @"JOIN"
#define kCellJoinStatusPending @"PENDING"
#define kCellJoinStatusLeave @"LEAVE"

//****************************************************
#pragma mark - Verification Request Class Keys
//****************************************************

///Class Key
#define kVerificationRequestClassNameKey  @"VerificationRequest"

///Field Keys
#define kVerificationRequestCellKey  @"cell"
#define kVerificationRequestCellNameKey  @"cellName"
#define kVerificationRequestNameKey  @"name"
#define kVerificationRequestRequestedByKey  @"requestedBy"
#define kVerificationRequestStatusKey  @"status"

///Request Status Values
#define kRequestStatusPending  @"PENDING"
#define kRequestStatusRejected  @"REJECTED"
#define kRequestStatusApproved  @"APPROVED"


//****************************************************
#pragma mark - Ride Request Class Keys
//****************************************************

///Class Key
#define kRideRequestClassNameKey  @"RideRequest"

///Field Keys
//#define kRideRequestFirstNameKey  @"firstName"
//#define kRideRequestLastNameKey  @"lastName"
#define kRideRequestRequestedByKey    @"requestedBy"
#define kRideRequestPickupLocationKey    @"pickUpLocation"
#define kRideRequestDropLocationKey    @"dropLocation"
#define kRideRequestTargetMembersKey    @"targetMembers"
#define kRideRequestInitiatedByKey    @"initiatedBy"
#define kRideRequestRejectedByKey    @"rejectedBy"
#define kRideRequestAdditionalNoteKey    @"additionalNote"
#define kRideRequestSelectedUserKey    @"selectedUser"
#define kRideRequestStatusKey    @"status"
#define kRideRequestOverlayDismissedKey    @"overlayDismissed"
#define kRideRequestRideCompletedKey    @"rideCompleted"
#define kRideRequestPickupReachedKey    @"pickupReached"

///status values
#define kRideRequestStatusPending @"Pending"
#define kRideRequestStatusSelected  @"Selected"
#define kRideRequestStatusCancelled    @"Cancelled"

//****************************************************
#pragma mark - Ride Response Class Keys
//****************************************************

///Class Key
#define kRideResponseClassNameKey  @"RideResponse"

///Field Keys
//#define kRideResponseFirstNameKey  @"firstName"
//#define kRideResponseLastNameKey  @"lastName"
#define kRideResponseRespondedByKey    @"respondedBy"
#define kRideResponseRideRiquestIdKey    @"rideRequestId"
#define kRideResponseCostKey    @"cost"
#define kRideResponseSeenKey    @"seen"
#define kRideResponseStatusKey    @"status"
#define kRideResponseAdditionalNoteKey    @"additionalNote"
#define kRideResponseSeenByDriverKey    @"seenByDriver"
#define kRideResponseOverlayDismissedKey    @"overlayDismissed"

///status values
#define kRideResponseStatusWaiting @"WAITING"
#define kRideResponseStatusConfirmed  @"CONFIRMED"
#define kRideResponseStatusRejected    @"REJECTED"


//****************************************************
#pragma mark - Additional Note 4 Ride Class Keys
//****************************************************

///Class Key
#define kAdditionalNote4RideClassNameKey  @"AdditionalNote4Ride"

///Field Keys
#define kAddNote4RideWriterIdKey  @"writerId"
//#define kAddNote4RideRideRequestIdKey  @"rideRequestId"
#define kAddNote4RideNoteKey  @"note"
//#define kAddNote4RideAlertTypeKey  @"alertType"
//#define kAddNote4RideSeenKey  @"seen"
#define kAddNote4RideWriterNameKey  @"writerName"
#define kAddNote4RideRideResponseIdKey  @"rideResponseId"

///Alert type values
//#define kAddNote4RideAlertTypeRideConfirmed @"RIDE_CONFIRMED"
//#define kAddNote4RideAlertTypeRideRejected @"RIDE_REJECTED"


//****************************************************
#pragma mark - Driver Profile Class Keys
//****************************************************

///Class Key
#define kDriverProfileClassNameKey          @"DriverProfile"
///Field Keys
#define kDriverProfilePickupCostKey         @"pickUpCost"
#define kDriverProfilePerMinuteCostKey  @"perMinuteCost"
#define kDriverProfilePerMileCostKey  @"perMileCost"
#define kDriverProfileIsCashAcceptedKey  @"isCashAccepted"
#define kDriverProfileIsSilverAcceptedKey  @"isSilverAccepted"
#define kDriverProfileIsCryptoAcceptedKey  @"isCryptoAccepted"
#define kDriverProfileIsBarteringAcceptedKey  @"isBarteringAccepted"
#define kDriverProfileIsCreditCardAcceptedKey  @"isCreditCardAccepted"
#define kDriverProfileUserKey  @"user"
#define kDriverProfileCurrencyKey         @"currency"

//****************************************************
#pragma mark - Review Class Keys
//****************************************************

///Class Key
#define kReviewClassNameKey @"Review"
///Field Keys
#define kReviewRatedUserKey @"ratedUser"
#define kReviewRatedByKey   @"ratedBy"
#define kReviewTitleKey @"title"
#define kReviewCommentKey   @"comment"
#define kReviewRatingKey    @"rating"

//****************************************************
#pragma mark - NonAppUserCell Class Keys
//****************************************************

///Class Key
#define kNonAppUserCellClassNameKey  @"NonAppUserCell"

///Field Keys
#define kNonAppUserCellCreatedByKey  @"createdBy"
#define kNonAppUserCellNameKey  @"name"
#define kNonAppUserCellMembersKey  @"members"

#define kNonAppUserCellMemberNameKey    @"name"
#define kNonAppUserCellMemberEmailKey    @"email"
#define kNonAppUserCellMemberPhoneKey    @"phone"
#define kNonAppUserCellMemberTypeKey    @"type"

#define kNonAppUserCellMemberTypePhone    1
#define kNonAppUserCellMemberTypeEmail    2


//****************************************************
#pragma mark - Privacy Policy Class Keys
//****************************************************

///Class Key
#define kPrivacyPolicyClassNameKey  @"PrivacyPolicy"

///Field Keys
#define kPrivacyPolicyUrlKey   @"ppUrl"
#define kPrivacyPolicyTermsOfServiceUrlKey @"tosUrl"

//****************************************************
#pragma mark - User Consent Class Keys
//****************************************************

///Class Key
#define kUserConsentClassNameKey    @"UserConsent"

///Field Keys
#define kUserConsentUserIdKey   @"userId"
#define kUserConsentPrivacyPolicyIdKey    @"privacyPolicyId"

//****************************************************
#pragma mark - Map Objective Class Keys
//****************************************************

///Class Key
#define kMapObjectiveClassNameKey    @"MapObjective"

///Field Keys
#define kMapObjectiveFullAddressKey   @"fullAddress"
#define kMapObjectiveGeoTagKey   @"geoTag"
#define kMapObjectiveCityKey   @"city"
#define kMapObjectiveNameKey   @"name"
#define kMapObjectivePhoneKey   @"phone"
#define kMapObjectiveURLKey   @"url"
#define kMapObjectiveHoursKey   @"hours"
#define kMapObjectiveCountryKey   @"country"
#define kMapObjectiveImageKey   @"image"
#define kMapObjectiveDescKey   @"description"
#define kMapObjectiveCategoryKey   @"category"
#define kMapObjectiveCreatedByKey   @"createdBy"

//****************************************************
#pragma mark - App User Log Class Keys
//****************************************************

///Class Key
#define kAppUserLogClassNameKey    @"AppUserLog"

///Field Keys
#define kAppUserLogActionKey   @"action"
#define kAppUserLogUserKey   @"user"

///Field Values
#define kAppUserLogActionDownloaded 1
#define kAppUserLogActionUserDeleted -1

//****************************************************
#pragma mark - Common Cloud Function keys
//****************************************************

#define kClientFirmIdKey    @"clientFirmId"
#define kIsLiveKey          @"isLive"
#define kLanguageCodeKey    @"languageCode"

//****************************************************
#pragma mark - Send Invite Cloud Function
//****************************************************

#define kSendInviteFuncNameKey  @"sendInvite"
#define kSendInviteFuncParamEmailKey  @"email"
#define kSendInviteFuncParamNameKey  @"name"
#define kSendInviteFuncParamSenderEmailKey  @"senderEmail"

//****************************************************
#pragma mark - Send Verification Request Cloud Function
//****************************************************

#define kSendVerificationReqFuncNameKey  @"sendVerificationRequest"
//#define kSendVerificationReqFuncParamEmailKey  @"email"
//#define kSendVerificationReqFuncParamNameKey  @"name"
//#define kSendVerificationReqFuncParamCellNameKey  @"cellName"
//#define kSendVerificationReqFuncParamRequestIdKey  @"verificationRequestId"
#define kSendVerificationReqFuncParamCellIdKey  @"cellId"


//****************************************************
#pragma mark - Forgot Password Cloud Function
//****************************************************

//#define kForgotPasswordReqFuncNameKey  @"forgotPassword2"
//#define kForgotPasswordReqFuncParamEmailKey  @"email"
//#define kForgotPasswordReqFuncParamDeviceTypeKey  @"deviceType"
//
//#define kForgotPasswordReqFuncDeviceTypeValIOS  @"ios"

//****************************************************
#pragma mark - Send Alert Cloud Function
//****************************************************

#define kSendAlertFuncNameKey  @"sendAlert"
#define kSendAlertFuncParamNameKey  @"name"
#define kSendAlertFuncParamIssuerIdKey  @"issuerId"
#define kSendAlertFuncParamAlertTypeKey  @"alertType"
#define kSendAlertFuncParamAdditionalNoteKey  @"additionalNote"
#define kSendAlertFuncParamCellObjectIdKey  @"cellObjectId"
#define kSendAlertFuncParamCellNameKey  @"cellName"
#define kSendAlertFuncParamIsPhotoAlertKey  @"isPhotoAlert"
#define kSendAlertFuncParamImageBytesKey  @"imageBytes"
#define kSendAlertFuncParamDispatchModeKey  @"dispatchMode"
#define kSendAlertFuncParamLatKey  @"lat"
#define kSendAlertFuncParamLongKey  @"lng"

#define kSendAlertFuncRespCell411AlertIdKey @"cell411AlertId"
#define kSendAlertFuncRespCreatedAtKey @"createdAt"
#define kSendAlertFuncRespPhotoUrlKey @"photoUrl"


//****************************************************
#pragma mark - Send Alert V2 Cloud Function
//****************************************************

#define kSendAlertV2FuncNameKey  @"sendAlertV2"
#define kSendAlertV2FuncParamTitleKey  @"title"
#define kSendAlertV2FuncParamIsDispatchedKey  @"isDispatched"
#define kSendAlertV2FuncParamLatKey  @"lat"
#define kSendAlertV2FuncParamLongKey  @"lng"
#define kSendAlertV2FuncParamAdditionalNoteKey  @"additionalNote"
#define kSendAlertV2FuncParamMetricKey  @"metric"
#define kSendAlertV2FuncParamRadiusKey  @"radius"
#define kSendAlertV2FuncParamTypeKey  @"type"
#define kSendAlertV2FuncParamMsgKey  @"msg"
#define kSendAlertV2FuncParamFwdAlertIdKey  @"forwardedAlertId"
#define kSendAlertV2FuncParamAudienceKey  @"audience"
#define kSendAlertV2FuncParamGlobalKey  @"Global"
#define kSendAlertV2FuncParamAllFriendsKey  @"AllFriends"
#define kSendAlertV2FuncParamPrivateCellsKey  @"PrivateCells"
#define kSendAlertV2FuncParamPublicCellsKey  @"PublicCells"
#define kSendAlertV2FuncParamAlertKey  @"alert"
#define kSendAlertV2FuncParamImageBytesKey  @"imageBytes"

#define kSendAlertV2FuncMetricValueKms  @"kms"
#define kSendAlertV2FuncMetricValueMiles  @"miles"

#define kSendAlertV2FuncRespCell411AlertIdKey @"cell411AlertId"
#define kSendAlertV2FuncRespCreatedAtKey @"createdAt"
#define kSendAlertV2FuncRespPhotoUrlKey @"photoUrl"
#define kSendAlertV2FuncRespTargetMembersCountKey @"targetMembersCount"
#define kSendAlertV2FuncRespTargetNauMembersCountKey @"targetNAUMembersCount"

//****************************************************
#pragma mark - Send Alert V3 Cloud Function
//****************************************************

#define kSendAlertV3FuncNameKey  @"sendAlertV3"
#define kSendAlertV3FuncParamTitleKey  @"title"
#define kSendAlertV3FuncParamAlertIdKey  @"alertId"
#define kSendAlertV3FuncParamCell411AlertIdKey  @"cell411AlertId"
#define kSendAlertV3FuncParamIsDispatchedKey  @"isDispatched"
#define kSendAlertV3FuncParamLatKey  @"lat"
#define kSendAlertV3FuncParamLongKey  @"lng"
#define kSendAlertV3FuncParamAdditionalNoteKey  @"additionalNote"
#define kSendAlertV3FuncParamMetricKey  @"metric"
#define kSendAlertV3FuncParamRadiusKey  @"radius"
#define kSendAlertV3FuncParamTypeKey  @"type"
#define kSendAlertV3FuncParamFwdAlertIdKey  @"forwardedAlertId"
#define kSendAlertV3FuncParamAudienceKey  @"audience"
#define kSendAlertV3FuncParamGlobalKey  @"Global"
#define kSendAlertV3FuncParamAllFriendsKey  @"AllFriends"
#define kSendAlertV3FuncParamNauKey  @"NAU"
#define kSendAlertV3FuncParamPrivateCellsKey  @"PrivateCells"
#define kSendAlertV3FuncParamPublicCellsKey  @"PublicCells"
#define kSendAlertV3FuncParamCallCenterKey  @"CallCenter"
#define kSendAlertV3FuncParamDefaultCellsKey  @"DefaultCells"
//#define kSendAlertV3FuncParamPrivateCellsSelectedObjIdListKey  @"privateCellSelectedObjectIdList"
//#define kSendAlertV3FuncParamPrivateCellsDeselectedObjIdListKey  @"privateCellDeselectedObjectIdList"
//#define kSendAlertV3FuncParamPublicCellsSelectedObjIdListKey  @"publicCellSelectedObjectIdList"
//#define kSendAlertV3FuncParamPublicCellsDeselectedObjIdListKey  @"publicCellDeselectedObjectIdList"
#define kSendAlertV3FuncParamTypeKey  @"type"
#define kSendAlertV3FuncParamAlertKey  @"alert"
#define kSendAlertV3FuncParamImageBytesKey  @"imageBytes"

#define kSendAlertV3FuncMetricValueKms  @"kms"
#define kSendAlertV3FuncMetricValueMiles  @"miles"
//#define kSendAlertV3FuncListTypeValueDeselected    @0
//#define kSendAlertV3FuncListTypeValueSelected      @1


#define kSendAlertV3FuncRespCell411AlertIdKey @"cell411AlertId"
#define kSendAlertV3FuncRespCreatedAtKey @"createdAt"
#define kSendAlertV3FuncRespPhotoUrlKey @"photoUrl"
#define kSendAlertV3FuncRespTargetMembersCountKey @"targetMembersCount"
#define kSendAlertV3FuncRespTargetNauMembersCountKey @"targetNAUMembersCount"

//**************************************************************
#pragma mark - Retrieve Total Selected Members Cloud Function
//**************************************************************

#define kRetrieveTotalSelectedMembersFuncNameKey @"retrieveTotalSelectedMembers"
#define kRetrieveTotalSelectedMembersFuncParamPrivateCellsKey   @"PrivateCells"
#define kRetrieveTotalSelectedMembersFuncParamPublicCellsKey   @"PublicCells"
#define kRetrieveTotalSelectedMembersFuncParamTypeKey   @"type"
#define kRetrieveTotalSelectedMembersFuncParamArrayKey   @"array"
#define kRetrieveTotalSelectedMembersFuncParamDataKey   @"data"

#define kRetrieveTotalSelectedMembersFuncTypeValueDeselected    @0
#define kRetrieveTotalSelectedMembersFuncTypeValueSelected      @1

//****************************************************
#pragma mark - Send SMS and Email Alert Cloud Function
//****************************************************

#define kSendSMSAndEmailAlertFuncNameKey  @"sendSMSAndEmailAlert"
#define kSendSMSAndEmailAlertV2FuncNameKey  @"sendSMSAndEmailAlertV2"
#define kSendSMSAndEmailPanicAlertFuncNameKey  @"sendSMSAndEmailPanicAlert"
#define kSendSMSAndEmailAlertFuncParamContactArrayKey  @"contactArray"
#define kSendSMSAndEmailAlertFuncParamNauMembersKey  @"nauMembers"
#define kSendSMSAndEmailAlertFuncParamCellObjectIdKey  @"cellObjectId"
#define kSendSMSAndEmailAlertFuncParamCell411AlertObjectIdKey  @"cell411AlertObjectId"
#define kSendSMSAndEmailAlertFuncParamTitleKey  @"title"
#define kSendSMSAndEmailAlertFuncParamDispatchModeKey  @"dispatchMode"
#define kSendSMSAndEmailAlertFuncParamIsPhotoAlertKey  @"isPhotoAlert"
#define kSendSMSAndEmailAlertFuncParamImageBytesKey  @"imageBytes"
#define kSendSMSAndEmailAlertFuncParamImageUrlKey  @"imageUrl"
#define kSendSMSAndEmailAlertFuncParamLatKey  @"lat"
#define kSendSMSAndEmailAlertFuncParamLongKey  @"lng"


//****************************************************
#pragma mark - Average Stars Cloud Function
//****************************************************

#define kAverageStarsFuncNameKey    @"averageStars"
#define kAverageStarsFuncParamUserIdKey @"userId"

//****************************************************
#pragma mark - Send Message Cloud Function
//****************************************************

#define kSendMessageFuncNameKey    @"sendMessage"

//****************************************************
#pragma mark - Broadcast Message Cloud Function
//****************************************************

#define kBroadcastMessageFuncNameKey    @"broadcastMessage"
#define kBroadcastMessageFuncParamMessageKey @"message"


//*******************************************************************
#pragma mark - sendChangeIntimationToPublicCellMembers Cloud Function
//*******************************************************************

#define kChgIntmnToPubCellMembersFuncNameKey  @"sendChangeIntimationToPublicCellMembers"
#define kChgIntmnToPubCellMembersFuncParamPubCellObjectIdKey  @"publicCellObjectId"
#define kChgIntmnToPubCellMembersFuncParamPubCellNameKey  @"publicCellName"
#define kChgIntmnToPubCellMembersFuncParamIsNameChangedKey  @"isNameChanged"
#define kChgIntmnToPubCellMembersFuncParamIsCategoryChangedKey  @"isCategoryChanged"
#define kChgIntmnToPubCellMembersFuncParamIsDescChangedKey  @"isDescriptionChanged"
#define kChgIntmnToPubCellMembersFuncParamIsLocChnagedKey  @"isLocationChanged"

//*******************************************************************
#pragma mark - uploadContacts Cloud Function
//*******************************************************************

#define kUploadContactsFuncNameKey  @"uploadContacts"
#define kUploadContactsFuncParamContactArrayKey  @"contactArray"

//*******************************************************************
#pragma mark - deleteContacts Cloud Function
//*******************************************************************

#define kDeleteContactsFuncNameKey  @"deleteContacts"

//*******************************************************************
#pragma mark - sendJoinedNotification Cloud Function
//*******************************************************************

#define kSendJoinedNotificationFuncNameKey  @"sendJoinedNotification"

//*******************************************************************
#pragma mark - deleteUser Cloud Function
//*******************************************************************

#define kDeleteUserFuncNameKey  @"deleteUser"

//*******************************************************************
#pragma mark - downloadUserData Cloud Function
//*******************************************************************

#define kDownloadUserDataFuncNameKey  @"downloadUserData"



//****************************************************
#pragma mark - Installation Class
//****************************************************

///Field Keys
#define kInstallationUserKey  @"user"

//****************************************************
#pragma mark - Push Notification Keys
//****************************************************

///payload data keys
///Common Keys
#define kPayloadAlertTypeKey  @"alertType"
#define kPayloadAlertKey  @"alert"
#define kPayloadCreatedAtKey  @"createdAt"
#define kPayloadUserIdKey  @"userId"
#define kPayloadSoundKey  @"sound"
#define kPayloadAdditionalNoteKey  @"additionalNote"
#define kPayloadAdditionalNoteIdKey  @"additionalNoteId"
#define kPayloadBadgeKey  @"badge"
#define kPayloadNameKey  @"name"
#define kPayloadUsernameKey  @"username"
#define kPayloadAlertAckKey  @"key"

///Needy keys
#define kPayloadAlertRegardingKey  @"alertRegarding"
#define kPayloadAlertIdKey  @"alertId"
#define kPayloadCell411AlertIdKey  @"cell411AlertId"
#define kPayloadLatKey  @"lat"
#define kPayloadLonKey  @"lon"
#define kPayloadCityKey @"city"
#define kPayloadCountryKey  @"country"
#define kPayloadFullAddressKey  @"fullAddress"
#define kPayloadFirstNameKey  @"firstName"
#define kPayloadIsGlobalKey  @"isGlobal"
#define kPayloadDispatchModeKey  @"dispatchMode"

///Helper keys
#define kPayloadDurationKey  @"duration"
#define kPayloadUserTypeKey @"userType"

///Needy forwarded keys
#define kPayloadForwardedByKey  @"forwardedBy"
#define kPayloadForwardingAlertIdKey  @"forwardingAlertId"

///Friend Request Keys
#define kPayloadFRObjectIdKey  @"friendRequestObjectId"

///Task Keys
#define kPayloadTaskIdKey  @"taskId"

///Cell Request Keys
#define kPayloadCellRequestObjectIdKey  @"cellRequestObjectId"
#define kPayloadCellNameKey  @"cellName"
#define kPayloadCellIdKey  @"cellId"

///Ride Request Keys
#define kPayloadDropLatKey  @"dropLat"
#define kPayloadDropLongKey  @"dropLng"
#define kPayloadPickUpLatKey  @"pickUpLat"
#define kPayloadPickUpLongKey  @"pickUpLng"
#define kPayloadRideRequestIdKey  @"rideRequestId"

///Ride Response Keys
#define kPayloadCostKey @"cost"
#define kPayloadRideResponseIdKey   @"rideResponseId"

///Chat keys
#define kPayloadChatEntityObjectIdKey @"entityObjectId"
#define kPayloadChatEntityNameKey   @"entityName"
#define kPayloadChatEntityTypeKey   @"entityType"
#define kPayloadChatEntityCreatedAtKey   @"entityCreatedAt"
#define kPayloadChatMsgKey @"msg"
#define kPayloadChatMsgTypeKey @"msgType"
#define kPayloadChatSenderFirstNameKey @"senderFirstName"
#define kPayloadChatSenderLastNameKey @"senderLastName"
#define kPayloadChatSenderIdKey @"senderId"
#define kPayloadChatTimeKey @"time"

///Payload data alert Key values
#define kPayloadAlertMsgSuffix  @"issued an emergency alert!"
#define kPayloadAlertMsgVideoSuffix  @"is streaming live video!"

#define kPayloadFAMsgSuffix  @"approved your friend request!"
#define kPayloadPhotoAlertMsgSuffix  @"issued a photo alert!"
#define kPayloadAlertMsgFwdSuffix  @"forwarded an emergency alert!"
#define kPayloadPanicAlertMsgSuffix  @"issued a panic alert!"
#define kPayloadFallenAlertMsgSuffix  @"issued a fallen alert!"
#define kPayloadRideRequestMsgSuffix  @"is requesting a ride"
#define kPayloadRideInterestedMsgSuffix  @"offered to give you a ride"
#define kPayloadRideOfferRejectedMsgSuffix  @"has rejected your ride :("
#define kPayloadRideOfferConfirmedMsgSuffix  @"approved your ride!"
#define kPayloadNotifyPickupReachedMsgSuffix  @"reached the pickup location and is ready to pick you up"


///Payload data alertType Key values
#define kPayloadAlertTypeNeedy  @"NEEDY"
#define kPayloadAlertTypeHelper  @"HELPER"
#define kPayloadAlertTypeRejector  @"REJECTOR"
#define kPayloadAlertTypeFriendRequest  @"FRIEND_REQUEST"
#define kPayloadAlertTypeFriendApproved  @"FRIEND_APPROVED"
#define kPayloadAlertTypeSafe  @"SAFE"
#define kPayloadAlertTypeVideo  @"VIDEO"
#define kPayloadAlertTypeCustom  @"CUSTOM"
#define kPayloadAlertTypePhoto  @"PHOTO"
#define kPayloadAlertTypeNeedyForwarded  @"NEEDY_FORWARDED"
#define kPayloadAlertTypeCellRequest  @"CELL_REQUEST"
#define kPayloadAlertTypeCellDenied  @"CELL_DENIED"
#define kPayloadAlertTypeCellApproved  @"CELL_APPROVED"
#define kPayloadAlertTypeCellRemoved  @"CELL_REMOVED"
#define kPayloadAlertTypeCellDeleted  @"CELL_DELETED"
#define kPayloadAlertTypeCellChanged  @"CELL_CHANGED"
#define kPayloadAlertTypeCellVerified  @"CELL_VERIFIED"
#define kPayloadAlertTypeCellRejected  @"CELL_REJECTED"
#define kPayloadAlertTypeNewPublicCell  @"NEW_PUBLIC_CELL"
#define kPayloadAlertTypeNeedyCell  @"NEEDY_CELL"
#define kPayloadAlertTypePhotoCell  @"PHOTO_CELL"
#define kPayloadAlertTypeRideRequest  @"RIDE_REQUEST"
#define kPayloadAlertTypeRideInterested  @"RIDE_INTERESTED"
#define kPayloadAlertTypeRideRejected  @"RIDE_REJECTED"
#define kPayloadAlertTypeRideConfirmed  @"RIDE_CONFIRMED"
#define kPayloadAlertTypeRideSelected  @"RIDE_SELECTED"
#define kPayloadAlertTypeMessage  @"MESSAGE"
#define kPayloadAlertTypeUserJoined  @"USER_JOINED"
#define kPayloadAlertTypeBackground  @"BG"

#define kPayloadCategoryTypeMessage  @"MESSAGE"
#define kPayloadCategoryTypeAlert  @"ALERT"


///Payload data badge key value
#define kPayloadBadgeValueIncrement  @"Increment"

///Payload data user id value in case of anonymous
#define kPayloadUserIdValueAnonymous    @"anonymous"

///Reverse Geocoding keys
#define kGeocodeResultsKey              @"results"
#define kGeocodeAddressComponentsKey    @"address_components"
#define kGeocodeTypeLocality            @"locality"
#define kGeocodeTypeCountry             @"country"
#define kFormattedAddressKey            @"formatted_address"

///Distance matrix keys
#define kDistanceMatrixDistanceKey  @"distance"
#define kDistanceMatrixDurationKey  @"duration"


//****************************************************
#pragma mark - Facebook Keys
//****************************************************

///Read permissions
#define kReadPermissionEmail            @"email"
#define kReadPermissionPublicProfile    @"public_profile"

///Publish Permissions
#define kPubPermissionPublishActions    @"publish_actions"

///Canonical Url Params for Deep Linking
    ///required
#define kDeepLinkParamAlertType         @"alert_type"
#define kDeepLinkParamCell411AlertId    @"cell_411_alert_id"
#define kDeepLinkParamIssuerId          @"issuer_id"
#define kDeepLinkParamCreatedAt         @"created_at"
#define kDeepLinkParamLat               @"lat"
#define kDeepLinkParamLon               @"lon"
#define kDeepLinkParamIssuerName        @"issuer_name"
    ///optional
#define kDeepLinkParamAdditionalNote    @"additional_note"
#define kDeepLinkParamIsGlobal          @"is_global"
#define kDeepLinkParamDispatchMode      @"dispatch_mode"
    ///in case of alert sent on public cell
#define kDeepLinkParamCellId        @"cell_id"
#define kDeepLinkParamCellName      @"cell_name"

///additional details keys(kPhotoAlertImageKey will hold the image of photo alert if we have that or kPhotoAlertImageUrlKey will hold the URL of photo alert if posted on public cell)
#define kCanonicalUrlParamsKey  @"canonicalUrlParams"
#define kPhotoAlertImageKey @"photoAlertImage"
#define kPhotoAlertImageUrlKey @"photoAlertImageUrl"
#define kVideoAlertUrlKey   @"videoAlertUrl"

///golive API
#define kStreamVideoToSocialMediaAPIName        @"golive.php"
#define kStreamVideoToSocialMediaParamName           @"name"
#define kStreamVideoToSocialMediaParamStreamName     @"stream"
#define kStreamVideoToSocialMediaParamCity           @"city"
#define kStreamVideoToSocialMediaParamCountry        @"country"
#define kStreamVideoToSocialMediaParamUser           @"user"
///Streaming to FB page
#define kStreamVideoToSocialMediaParamFBPage             @"fb"
///Streaming to User FB Wall
#define kStreamVideoToSocialMediaParamFBWall             @"fbwall"
#define kStreamVideoToSocialMediaParamFBToken            @"fbtoken"
#define kStreamVideoToSocialMediaParamFBDestination      @"fbdestination"
///Streaming to Cell 411 Youtube Channel
#define kStreamVideoToSocialMediaParamYTCell411           @"ytcell411"
///Streaming to User's Live Youtube Channel
#define kStreamVideoToSocialMediaParamUserYT              @"yt"
#define kStreamVideoToSocialMediaParamUserYTKey           @"ytkey"
#define kStreamVideoToSocialMediaParamUserYTHost          @"ythost"
#define kStreamVideoToSocialMediaParamUserYTApp           @"ytapp"

//****************************************************
#pragma mark - Panic Alert Settings Keys
//****************************************************

#define kPanicAlertRecipientAllFriendsKey           @"allFriends"
#define kPanicAlertRecipientNearMeKey               @"nearMe"
#define kPanicAlertRecipientPrivateCellsMembersKey   @"privateCellsMembers"
#define kPanicAlertRecipientNauCellsMembersKey   @"nauCellsMembers"
#define kPanicAlertRecipientPublicCellsMembersKey   @"publicCellsMembers"

#define kPanicAlertRecipientIsSelectedKey   @"isSelected"
#define kPanicAlertRecipientSelectedCellsKey   @"selectedCells"
#define kPanicAlertRecipientSelectedCellIdKey   @"selectedCellId"
#define kPanicAlertRecipientSelectedCellNameKey   @"selectedCellName"

//****************************************************
#pragma mark - Alert Settings Keys
//****************************************************

#define kAlertAudienceFamilyKey         @"family"
#define kAlertAudienceFriendsKey        @"friends"
#define kAlertAudienceCoworkersKey      @"coworkers"
#define kAlertAudienceSchoolmatesKey    @"schoolmates"
#define kAlertAudienceNeighboursKey     @"neighbours"
#define kAlertAudienceNauKey            @"nau"
#define kAlertAudienceCellsKey          @"cells"
#define kAlertAudienceGlobalKey         @"global"
#define kAlertAudienceCallCentreKey     @"callCentre"


#define kAlertAudienceIsSelectedKey   @"isSelected"
#define kAlertAudienceCellsPrivateCellsKey  @"privateCells"
#define kAlertAudienceCellsPublicCellsKey   @"publicCells"

#define kAlertAudienceIsAllSelectedKey   @"isAllSelected"
#define kAlertAudienceSelectedCellsKey   @"selectedCells"
#define kAlertAudienceDeselectedCellsKey   @"deselectedCells"
#define kAlertAudienceSelectedNauMembersKey   @"selectedNauMembers"


//****************************************************
#pragma mark - Chat Keys
//****************************************************

///Message Node keys
#define kChatMsgKey @"msg"
#define kChatMsgTypeKey @"msgType"
#define kChatSenderFirstNameKey @"senderFirstName"
#define kChatSenderLastNameKey @"senderLastName"
#define kChatSenderIdKey @"senderId"
#define kChatTimeKey @"time"
#define kChatLatKey @"lat"
#define kChatLongKey @"lng"
#define kChatImageUrlKey @"imageUrl"

///Notification Keys
#define kChatNotificationMessageKey @"message"


///Message type keys
#define kChatMsgTypeText    @"text"
#define kChatMsgTypeLoc    @"loc"
#define kChatMsgTypeImg    @"img"


//****************************************************
#pragma mark - Blocks Declaration
//****************************************************

typedef void (^ popupActionHandler)(id action, NSInteger actionIndex, id customObject);
typedef void (^ backActionHandler)(id action, id customObject);
typedef void(^ SuccessCompletionHandler)(void);
typedef void (^ completionHandler)(id customObject);

//****************************************************
#pragma mark - Internal Linking URLs via NSLINKAttribute
//****************************************************

#define kInternalLinkBaseURL @"cell411://handle.internal.link"
#define kInternalLinkParamType  @"type"
#define kInternalLinkParamRefIndex  @"index"

///type values
#define kInternalLinkParamTypeShowUserProfile  @"showUserProfile"
#define kInternalLinkParamTypeShowAlertForwarderProfile  @"showAlertForwarderProfile"
#define kInternalLinkParamTypeShowAlertDetail  @"showAlertDetail"
#define kInternalLinkParamTypeShowTermsAndConditions  @"showTermsAndConditions"
#define kInternalLinkParamTypeShowPrivacyPolicy  @"showPrivacyPolicy"


//****************************************************
#pragma mark - Phone number keys
//****************************************************

#define kPhoneCountryKey    @"country"
#define kPhoneNumberKey     @"phoneNumber"

//****************************************************
#pragma mark - Maps url for all platform key
//****************************************************

#define kGoogleMapsOriginKey        @"origin"
#define kGoogleMapsDestinationKey   @"destination"
#define kGoogleMapsTravelModeKey    @"travelmode"
#define kGoogleMapsQueryKey         @"query"

#define kGoogleMapsTravelModeValueDriving    @"driving"

//****************************************************
#pragma mark - Overpass API Keys
//****************************************************
#define kOverpassAPIBaseURL     @"https://www.overpass-api.de/api/interpreter"
#define kOverpassAPIParamData   @"data"
#define kOverpassAPIStatementOut  @"[out:json];"
#define kOverpassAPIStatementNodeWithDynamicAmenity @"node[amenity=%@]"
#define kOverpassAPIStatementOutMeta    @"out meta;"
#define kOverpassAPIElementsKey   @"elements"
#define kOverpassAPILatKey   @"lat"
#define kOverpassAPILonKey   @"lon"
#define kOverpassAPITagsKey   @"tags"
#define kOverpassAPIAmenityKey   @"amenity"
#define kOverpassAPINameKey   @"name"
#define kOverpassAPITypeKey   @"type"
#define kOverpassAPIWebsiteKey   @"website"
#define kOverpassAPIOpeningHoursKey   @"opening_hours"



#define kOverpassAPIAmenityTypePharmacy @"pharmacy"
#define kOverpassAPIAmenityTypeHospital @"hospital"
#define kOverpassAPIAmenityTypePolice @"police"

//****************************************************
#pragma mark - Other App Level Values
//****************************************************

#define MILES_TO_KM 1.6 ///1 Miles is equal to 1.6 KM

#define MIN_FRIENDS_FOR_SECOND_PRIVILEGE            2
#define MIN_NORMAL_ALERTS_FOR_SECOND_PRIVILEGE      1 ///NOTE: Changing this value to other than 1 will impact the code written on MapView to set privilege as Second (inside send push block) when issuing or forwarding a normal alert


///Alert Slices Tags
#define BTN_ALERT_TAG_PULLED_OVER           101
#define BTN_ALERT_TAG_ARRESTED              102
#define BTN_ALERT_TAG_MEDICAL_ATTENTION     103
#define BTN_ALERT_TAG_CAR_BROKE             104
#define BTN_ALERT_TAG_CRIME                 105
#define BTN_ALERT_TAG_FIRE                  106
#define BTN_ALERT_TAG_DANGER                107
#define BTN_ALERT_TAG_COP_BLOCKING          108
#define BTN_ALERT_TAG_BULLIED               109
#define BTN_ALERT_TAG_GENERAL               110
#define BTN_ALERT_TAG_VIDEO                 111
#define BTN_ALERT_TAG_PHOTO                 112
#define BTN_ALERT_TAG_PANIC                 113
#define BTN_ALERT_TAG_HIJACK                114
#define BTN_ALERT_TAG_FALLEN                115
#define BTN_ALERT_TAG_PHYSICAL_ABUSE        116
#define BTN_ALERT_TAG_TRAPPED               117
#define BTN_ALERT_TAG_CAR_ACCIDENT          118
#define BTN_ALERT_TAG_CALL_112              119
#define BTN_ALERT_TAG_NATURAL_DISASTER      120
#define BTN_ALERT_TAG_PRE_AUTHORIZATION     121


#endif /* Constants_h */
