//
//  ContactsData.h
//  cell411
//
//  Created by Milan Agarwal on 06/08/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    ///Default status, i.e status is still being initialized
    ContactStatusInitializing = 0,
    
    ///Current user and this contact person are already Cell 411 friends
    ContactStatusFriends,
    
    ///Friend request has already been sent to this user and is yet to be accepted by him/her
    ContactStatusFriendRequestPending,
    
    ///This contact person is using the Cell 411 app and is not a friend of current user
    ContactStatusUserExist,
    
    ///This contact person is not using the Cell 411 app and an invitation has already been sent to this person
    ContactStatusInvitationPending,
    
    ///This contact person is not using the Cell 411 app and an invitation has not been sent till now to this user
    ContactStatusUserDoesNotExist
    
} ContactStatus;

typedef NS_ENUM(NSUInteger, ContactType) {
    ContactTypeInvalid = 0,
    ContactTypePhone,
    ContactTypeEmail
};

@import AddressBook;

@interface ContactsData : NSObject
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, assign) ABRecordID contactId;
@property (nonatomic, strong) NSString *strEmail;
@property (nonatomic, strong) NSString *strPhoneNumber;

@property (nonatomic, strong) NSArray *arrEmails;
//@property (nonatomic, strong) UIImage *imgAvatar;
@property (nonatomic, strong) NSArray *arrPhoneNumbers;
@property (nonatomic, assign) ContactStatus contactStatus;
@property (nonatomic, assign) ContactType contactType;
///matchedUserObject will contain PFUser object if it's an existing user
@property (nonatomic, strong) id matchedUserObject;
@property (nonatomic, assign, getter=isRequestInProgress) BOOL requestInProgress;



@end
