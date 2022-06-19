//
//  C411Enums.h
//  cell411
//
//  Created by Milan Agarwal on 08/07/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#ifndef C411Enums_h
#define C411Enums_h

typedef enum{
    SignUpTypeUnknown = -1,
    SignUpTypeEmail = 0,
    SignUpTypeFacebook
    
}SignUpType;

typedef enum {

    PanicWaitTimeInstant = 0,
    PanicWaitTime5Sec = 5,
    PanicWaitTime10Sec = 10
    
}PanicWaitTime;

typedef enum{
    
    TimeStampFormatDateAndTime = 0,///eg.(today at 04:53 PM for current day, or 08/10/16 at 04:53 PM for other days)
    TimeStampFormatDateOrTime ///eg.(04:53 PM for current day, or 08/10/16 for other day)
    
}TimeStampFormat;

typedef NS_ENUM(NSUInteger, ChatEntityType) {
    ChatEntityTypeInvalid = 1001,
    ChatEntityTypePublicCell = 0,
    ChatEntityTypePrivateCell,
    ChatEntityTypeAlert
};

typedef NS_ENUM(NSUInteger, ChatMsgType) {
    ChatMsgTypeInvalid = 1001,
    ChatMsgTypeText = 0,
    ChatMsgTypeLoc,
    ChatMsgTypeImg
};

typedef NS_ENUM(NSUInteger, ChatMuteTimeType) {
    ChatMuteTimeType1Hour,
    ChatMuteTimeType6Hours,
    ChatMuteTimeType24Hours,
    ChatMuteTimeType1Month,
    ChatMuteTimeTypeDefault = ChatMuteTimeType1Hour
};


typedef NS_ENUM(NSUInteger, CellMembershipStatus) {
    
    CellMembershipStatusUnknown,
    CellMembershipStatusNotAMember,
    CellMembershipStatusPendingApproval,
    CellMembershipStatusIsAMember
    
};

typedef NS_ENUM(NSUInteger, FriendRequestAction) {
    FriendRequestActionPendingApproved = 1,
    FriendRequestActionPendingDenied
};

typedef NS_ENUM(NSUInteger, AddFriendRequestState) {
    AddFriendRequestStateSending = 1,
    AddFriendRequestStateSent,
    AddFriendRequestStateReSending

};

typedef enum {
    
    AudienceTypeNone = 0,
    AudienceTypePatrolMembers,
    AudienceTypeAllFriends,
    AudienceTypePrivateCellMembers,
    AudienceTypeOnlySocialMediaMembers,
    AudienceTypeSecurityGuards,
    AudienceTypePublicCellMembers
    
}AudienceType;


typedef NS_ENUM(NSInteger, CellVerificationStatus) {
    
    CellVerificationStatusRejected = -2,
    CellVerificationStatusPending,
    CellVerificationStatusUnsolicited,
    CellVerificationStatusApproved
    
};

typedef NS_ENUM(NSInteger, PrivateCellType) {
    
    PrivateCellTypeFamily = 1,
    PrivateCellTypeCoworkers,
    PrivateCellTypeSchoolmates,
    PrivateCellTypeNeighbours,
    PrivateCellTypeFriends
};

typedef NS_ENUM(NSInteger, AlertType) {
    
    AlertTypeUnreconized = 0,
    AlertTypeBrokeCar,
    AlertTypeBullied,
    AlertTypeCriminal,
    AlertTypeGeneral,
    AlertTypePulledOver,
    AlertTypeDanger,
    AlertTypeVideo,
    AlertTypePhoto,
    AlertTypeFire,
    AlertTypeMedical,
    AlertTypePoliceInteraction,
    AlertTypePoliceArrest,
    AlertTypeHijack,
    AlertTypePanic,
    AlertTypeFallen,
    AlertTypePhysicalAbuse,
    AlertTypeTrapped,
    AlertTypeCarAccident,
    AlertTypeNaturalDisaster,
    AlertTypePreAuthorisation
    
};

typedef NS_ENUM(NSInteger, PublicCellCategory) {
    PublicCellCategoryUnrecognized = 0,
    PublicCellCategoryActivism,
    PublicCellCategoryCommercial,
    PublicCellCategoryCommunitySafety,
    PublicCellCategoryEducation,
    PublicCellCategoryGovernment,
    PublicCellCategoryJournalism,
    PublicCellCategoryPersonalSafety
};

typedef NS_ENUM(NSInteger, MapObjectiveCategory) {
    MapObjectiveCategoryUnrecognized = 0,
    MapObjectiveCategoryPharmacy,
    MapObjectiveCategoryHospital,
    MapObjectiveCategoryPolice
};

#endif /* C411Enums_h */
