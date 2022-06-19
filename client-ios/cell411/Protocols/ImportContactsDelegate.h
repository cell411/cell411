//
//  ImportContactsDelegate.h
//  cell411
//
//  Created by Milan Agarwal on 28/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

@protocol ImportContactsDelegate <NSObject>

///Will contain list of phone contacts that includes email and phone number contacts that uses the app. Useful for managing Contacts section of Import Contacts screen
@property (nonatomic, readonly) NSArray *arrExistingContacts;

///Will contain list of phone contacts that includes email and phone number contacts that don't uses the app. Useful for managing Invite section of Import Contacts screen
@property (nonatomic, readonly) NSArray *arrNonExistingContacts;

@end
