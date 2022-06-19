//
//  C411ImportContactsVC.m
//  cell411
//
//  Created by Milan Agarwal on 24/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ImportContactsVC.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411ContactsVC.h"
#import "C411InviteVC.h"
#import "ContactsData.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MA_Country.h"
#import "C411AppDefaults.h"
#import "AppDelegate.h"
#import "C411ColorHelper.h"
//@import Contacts;
//@import ContactsUI;

#define TAG_TAB_TITLE 101

@interface C411ImportContactsVC ()<ViewPagerDataSource,ViewPagerDelegate>


@property (nonatomic, readwrite) NSMutableArray *arrExistingContacts;
@property (nonatomic, readwrite) NSMutableArray *arrNonExistingContacts;

///Will contain list of phone contacts containing emails and phone numbers
@property (nonatomic, strong) NSArray *arrPhnContacts;
@property (nonatomic, strong) NSMutableArray *arrContactsEmail;
@property (nonatomic, strong) NSMutableArray *arrContactsPhoneNumbers;

@property (nonatomic, strong) NSOperationQueue *statusOpQueue;
@property (nonatomic, strong) UIImageView *navBarHairlineImageView;

#if IS_CONTACTS_SYNCING_ENABLED
///Will contain json compatible phone contacts
@property (nonatomic, strong) NSMutableArray *arrJsonCompatibleContacts;
#endif

- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender;

@end

@implementation C411ImportContactsVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///View Pager setup
    self.dataSource = self;
    self.delegate = self;

    self.navBarHairlineImageView = [C411StaticHelper findHairlineImageViewUnder:self.navigationController.navigationBar];
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        
        [weakSelf requestAuthAndGetPhoneContacts];
        //[weakSelf registerForNotifications];
    }];
    [self configureViews];
    [self registerForNotifications];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ///Unhide the navigation bar
    self.navBarHairlineImageView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated {

    self.navBarHairlineImageView.hidden = NO;
    [super viewWillDisappear:animated];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self.statusOpQueue cancelAllOperations];
    self.statusOpQueue = nil;
    self.navBarHairlineImageView = nil;
    [self unregisterFromNotifications];
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
#pragma mark - Property Initializers
//****************************************************

-(NSMutableArray *)arrExistingContacts
{
    if (!_arrExistingContacts) {
        
        _arrExistingContacts = [NSMutableArray array];
    }
    
    return _arrExistingContacts;
}

-(NSMutableArray *)arrNonExistingContacts
{
    if (!_arrNonExistingContacts) {
        
        _arrNonExistingContacts = [NSMutableArray array];
    }
    
    return _arrNonExistingContacts;
}

-(NSMutableArray *)arrContactsEmail
{
    if (!_arrContactsEmail) {
        
        _arrContactsEmail = [NSMutableArray array];
    }
    
    return _arrContactsEmail;
}

-(NSMutableArray *)arrContactsPhoneNumbers
{
    if (!_arrContactsPhoneNumbers) {
        
        _arrContactsPhoneNumbers = [NSMutableArray array];
    }
    
    return _arrContactsPhoneNumbers;
}

#if IS_CONTACTS_SYNCING_ENABLED

-(NSMutableArray *)arrJsonCompatibleContacts
{
    if (!_arrJsonCompatibleContacts) {
        
        _arrJsonCompatibleContacts = [NSMutableArray array];
    }
    
    return _arrJsonCompatibleContacts;
}

#endif

//****************************************************
#pragma mark - ViewPagerDataSource Methods
//****************************************************

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 2;
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    NSString *strTabTitle = nil;
    
    switch (index) {
        case 0:
            strTabTitle = NSLocalizedString(@"Contacts", nil);
            break;
        case 1:
            strTabTitle = NSLocalizedString(@"Invites", nil);
            break;
            
        default:
            break;
    }
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:14.0];
    label.text = strTabTitle;
    label.textAlignment = NSTextAlignmentCenter;
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    label.textColor = primaryBGTextColor;
    label.tag = TAG_TAB_TITLE;
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0:{
        
            C411ContactsVC *contactsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ContactsVC"];
            contactsVC.importContactsDelegate = self;
            return contactsVC;

        }
           
        case 1:{
            
            C411InviteVC *inviteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411InviteVC"];
            inviteVC.importContactsDelegate = self;
            return inviteVC;
            
        }
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 0.0;
        case ViewPagerOptionTabLocation:
            return 1.0;
        case ViewPagerOptionTabHeight:
            return 49.0;
        case ViewPagerOptionTabOffset:
            return 36.0;
        case ViewPagerOptionTabWidth:
            //return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 168.0 : 136.0;
            return viewPager.view.bounds.size.width / 2;
        case ViewPagerOptionFixFormerTabsPositions:
            return 0.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 0.0;
        default:
            return value;
    }
}

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [C411ColorHelper sharedInstance].secondaryColor;
        case ViewPagerTabsView:
            return self.navigationController.navigationBar.barTintColor;
        case ViewPagerContent:
            return [C411ColorHelper sharedInstance].backgroundColor;
        default:
            return color;
    }
}

-(void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index fromIndex:(NSUInteger)previousIndex didSwipe:(BOOL)didSwipe
{

    ///Post notification to remove contact list search bar if visible
        [[NSNotificationCenter defaultCenter]postNotificationName:kDidMovedAwayFromContactListNotification object:nil];
        
        
 
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

/*
-(void)registerForNotifications
{
    if ([CNContact class]) {
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(contactsDidUpdated:) name:CNContactStoreDidChangeNotification object:nil];

    }
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}


-(void)refreshContacts
{
    ///Stop the operation queue if it's running
    if (self.statusOpQueue) {
        
        [self.statusOpQueue cancelAllOperations];
        self.statusOpQueue = nil;

    }
    
    ///reset ivars
    self.arrPhnContacts = nil;
    self.arrContactsEmail = nil;
    self.arrContactsPhoneNumbers = nil;
    self.arrExistingContacts = nil;
    self.arrNonExistingContacts = nil;
    
    ///Get contacts and initialize them again
    [self requestAuthAndGetPhoneContacts];
}
*/

-(void)configureViews
{
    self.title = NSLocalizedString(@"Import Contacts", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)applyColors {
    ///Set colors of tab labels
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    for (UIView *tabView in self.tabs) {
        UILabel *lblTabTitle = [tabView viewWithTag:TAG_TAB_TITLE];
        if([lblTabTitle isKindOfClass:[UILabel class]]) {
            lblTabTitle.textColor = primaryBGTextColor;
        }
    }
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)requestAuthAndGetPhoneContacts
{
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    __weak typeof(self) weakSelf = self;
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                ///Do rest of the task on main queue
                if (granted) {
                    
                    
                    ///Show progress hud
                    [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                    
                    // First time access has been granted, add the contact
                    weakSelf.arrPhnContacts = [weakSelf  getAllContacts];
                    
#if IS_CONTACTS_SYNCING_ENABLED
                    
                    if (weakSelf.shouldSyncContacts) {
                        
                        /// Sync contacts with server
                        [weakSelf syncContactsWithServer:weakSelf.arrJsonCompatibleContacts];
                    }
                    
#endif
                    
                    if (weakSelf.arrPhnContacts.count > 0) {
                        
                        ///Initialize status of contacts
                        [weakSelf initializeStatusForContacts];
                        
                    }
                    else{
                        
                        ///Hide the hud
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    }
                    
                    
                } else {
                    // User denied access
                    // Display an alert telling user the contact could not be added
                    [C411StaticHelper showAlertWithTitle:nil message:[(__bridge NSError *)error localizedDescription] onViewController:weakSelf];
                    
                }

            });
            
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        ///Show progress hud
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        self.arrPhnContacts = [self getAllContacts];

#if IS_CONTACTS_SYNCING_ENABLED
      
        if (weakSelf.shouldSyncContacts) {
            
            /// Sync contacts with server
            [weakSelf syncContactsWithServer:weakSelf.arrJsonCompatibleContacts];
        }
#endif
        
        if (self.arrPhnContacts.count > 0) {
            
            ///Initialize status of contacts
            [self initializeStatusForContacts];
            
        }
        else{
            
            ///Hide the hud
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }


        
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        [C411StaticHelper showAlertWithTitle:nil message:[NSString localizedStringWithFormat:NSLocalizedString(@"Please allow access to contacts for %@",nil), LOCALIZED_APP_NAME] onViewController:self];
    }
}

/*Method related to resolve Linked Contacts issue, but needs to verify
 +(NSArray *)getUnifiedRecords
 {
 NSMutableSet *unifiedRecordsSet = [NSMutableSet set];
 CFErrorRef *error = nil;
 ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
 CFArrayRef records = ABAddressBookCopyArrayOfAllPeople(addressBook);
 for (CFIndex i = 0; i < CFArrayGetCount(records); i++)
 {
 NSMutableSet *contactSet = [NSMutableSet set];
 
 ABRecordRef record = CFArrayGetValueAtIndex(records, i);
 [contactSet addObject:(__bridge id)record];
 
 NSArray *linkedRecordsArray = (__bridge NSArray *)ABPersonCopyArrayOfAllLinkedPeople(record);
 [contactSet addObjectsFromArray:linkedRecordsArray];
 
 // Your own custom "unified record" class (or just an NSSet!)
 NSSet *unifiedRecord = [[NSSet alloc] initWithSet:contactSet];
 
 [unifiedRecordsSet addObject:unifiedRecord];
 CFRelease(record);
 }
 
 NSArray *unifiedRecords = [unifiedRecordsSet allObjects];
 CFRelease(records);
 CFRelease(addressBook);
 
 
 //NSLog(@"records Start#\n%@\nRecords end",_unifiedRecords);
 return unifiedRecords;
 }
 */

-(NSArray *)getAllContacts {
    
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    //ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    CFArrayRef allPeople = (ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, nil, kABPersonSortByFirstName));
    //CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    //CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    CFIndex nPeople = CFArrayGetCount(allPeople); // bugfix who synced contacts with facebook
    NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];

    if (!allPeople || !nPeople) {
        NSLog(@"people nil");
    }
    
    
    /// Get user country to be used for initializing phone contacts
    MA_Country *defaultCountry = [MA_Country defaultCountry];
    NSInteger minPhoneDigits = 7;
    NSInteger maxPhoneDigits = 15;
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strCurrentUserPhoneNumber = currentUser[kUserMobileNumberKey];
    if (strCurrentUserPhoneNumber.length > 0) {
        
        NSDictionary *dictContactDetails = [C411StaticHelper splitPhoneNumberAndCountryCodeFromNumber:strCurrentUserPhoneNumber];
        
        MA_Country *userCountry = [dictContactDetails objectForKey:kPhoneCountryKey];
        if(userCountry){
            ///If user country is available, give it a higher preference to set as country code for other contacts if required
            defaultCountry = userCountry;
        }
        
        ///Extract a numeric string from phone number as it could be a formatted number with characters other than digits
        strCurrentUserPhoneNumber = [C411StaticHelper getNumericStringFromString:strCurrentUserPhoneNumber];
        
    }
    
    NSString *strCurrentUserEmail = [C411StaticHelper getEmailFromUser:currentUser];
    
    
    for (int i = 0; i < nPeople; i++) {
    
        @autoreleasepool {
            
            //data model
            ContactsData *contacts = [ContactsData new];
            
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            //get First Name
            CFStringRef firstName = (CFStringRef)ABRecordCopyValue(person,kABPersonFirstNameProperty);
            contacts.firstName = [(__bridge NSString*)firstName copy];
            
            if (firstName != NULL) {
                CFRelease(firstName);
            }
            
            
            //get Last Name
            CFStringRef lastName = (CFStringRef)ABRecordCopyValue(person,kABPersonLastNameProperty);
            contacts.lastName = [(__bridge NSString*)lastName copy];
            
            if (lastName != NULL) {
                CFRelease(lastName);
            }
            
            
            if (!contacts.firstName) {
                contacts.firstName = @"";
            }
            
            if (!contacts.lastName) {
                contacts.lastName = @"";
            }
            
            
            
            contacts.contactId = ABRecordGetRecordID(person);
            //append first name and last name
            contacts.fullName = [NSString stringWithFormat:@"%@ %@", contacts.firstName, contacts.lastName];
            
            /*uncomment it if contact picture is required
             // get contacts picture, if pic doesn't exists, show standart one
             CFDataRef imgData = ABPersonCopyImageData(person);
             NSData *imageData = (__bridge NSData *)imgData;
             contacts.imgAvatar = [UIImage imageWithData:imageData];
             
             if (imgData != NULL) {
             CFRelease(imgData);
             }
             
             //            if (!contacts.imgAvatar) {
             //                contacts.imgAvatar = [UIImage imageNamed:@"avatar.png"];
             //            }
             */
            
            
            //get Contact email
            NSMutableArray *arrEmails = [NSMutableArray array];
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                @autoreleasepool {
                    CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                    NSString *contactEmail = CFBridgingRelease(contactEmailRef);
                    //trim white spaces from email
                    contactEmail = [contactEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    ///filter out facebook emails and current user email
                    if ((contactEmail != nil)
                        &&([contactEmail.lowercaseString rangeOfString:@"@facebook"].location == NSNotFound)
                        &&(![contactEmail isEqualToString:strCurrentUserEmail]))
                    {
                        
                        [arrEmails addObject:contactEmail];
                        
                    }
                    // NSLog(@"All emails are:%@", contactEmails);
                }
            }
            
            if (multiEmails != NULL) {
                CFRelease(multiEmails);
            }
            
            ///Add a separate contact object for each email of a user
            for (NSString *strEmail in arrEmails) {
                
                ContactsData *emailContact = [ContactsData new];
                emailContact.contactId = contacts.contactId;
                emailContact.firstName = contacts.firstName;
                emailContact.lastName = contacts.lastName;
                emailContact.fullName = contacts.fullName;
                emailContact.strEmail = strEmail;
                emailContact.contactType = ContactTypeEmail;
                [items addObject:emailContact];
                [self.arrContactsEmail addObject:strEmail];
#if IS_CONTACTS_SYNCING_ENABLED
                
                if (self.shouldSyncContacts) {
                    
                    NSMutableDictionary *dictEmailContact = [NSMutableDictionary dictionary];
                    dictEmailContact[kCellNauMemberNameKey] = contacts.fullName;
                    dictEmailContact[kCellNauMemberEmailKey] = strEmail;
                    dictEmailContact[kCellNauMemberTypeKey] = @(kCellNauMemberTypeEmail);
                    [self.arrJsonCompatibleContacts addObject:dictEmailContact];
                    
                }
                
#endif
            }
            
            
#if SMS_INVITE_ENABLED
            //Uncomment it if phone number is required
            //get Phone Numbers
            NSMutableArray *arrPhoneNumbers = [NSMutableArray array];
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
           
            for(CFIndex i=0; i<ABMultiValueGetCount(multiPhones); i++) {
                @autoreleasepool {
                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                    NSString *strFormattedPhoneNumber = CFBridgingRelease(phoneNumberRef);
                   if (strFormattedPhoneNumber != nil){
                    
                        ///Extract a numeric string from formatted phone number
                       NSString *strPhoneNumber = [C411StaticHelper getNumericStringFromString:strFormattedPhoneNumber];
                    
                       if (strPhoneNumber.length >= minPhoneDigits && strPhoneNumber.length <= maxPhoneDigits) {
                           
                           ///It's a valid phone number, now check for prefix
                           if ([strPhoneNumber hasPrefix:@"00"]) {
                               
                               ///Could be a possible case of 00<Country code> e.g, 0091, so remove 00 from beginning
                               strPhoneNumber = [strPhoneNumber substringFromIndex:2];
                               
                           }
                           else if ([strPhoneNumber hasPrefix:@"0"]){
                               
                               ///Could be a possible case of using 0 in place of country code, like here in India 09876543211 is equivalent to 919876543211. So replace starting 0 with country code to maintain uniformity in DB
                               
                               ///1. remove starting 0 and append dialing code assuming dialing code of current user will always be available in our country database
                               
                               ///Remove 0
                                strPhoneNumber = [strPhoneNumber substringFromIndex:1];
                                   
                                ///Append the dialing code as prefix
                                strPhoneNumber = [defaultCountry.dialingCode stringByAppendingString:strPhoneNumber];
                               
                           }
                           else if (![C411StaticHelper isPhoneNumberHasCountryCode:strPhoneNumber]){
                               
                               ///Append current user's country dialing code as prefix  as phone number doesn't contain any country dialing code
                               strPhoneNumber = [defaultCountry.dialingCode stringByAppendingString:strPhoneNumber];
                           }
                           
                           
                           ///skip this phone number if it's equal to current user phone number
                           if ((strCurrentUserPhoneNumber.length > 0)
                               && ([strCurrentUserPhoneNumber isEqualToString:strPhoneNumber])) {
                               
                               ///this is a current users number, do nothing
                               
                               
                           }
                           else{
                               
                               ///Add this number to phone number array
                               [arrPhoneNumbers addObject:strPhoneNumber];
                           }
                           
                           
                           
                       }
                       
                       
                    }
                }
            }
           // NSLog(@"All numbers of %@-> %@",contacts.fullName, arrPhoneNumbers);
            
            if (multiPhones != NULL) {
                CFRelease(multiPhones);
            }
            
            
            
            
            ///Add a separate contact object for each phone number of a user
            for (NSString *strPhoneNumber in arrPhoneNumbers) {
                
                ContactsData *phoneNumberContact = [ContactsData new];
                phoneNumberContact.contactId = contacts.contactId;
                phoneNumberContact.firstName = contacts.firstName;
                phoneNumberContact.lastName = contacts.lastName;
                phoneNumberContact.fullName = contacts.fullName;
                phoneNumberContact.strPhoneNumber = strPhoneNumber;
                phoneNumberContact.contactType = ContactTypePhone;
                [items addObject:phoneNumberContact];
                [self.arrContactsPhoneNumbers addObject:strPhoneNumber];

#if IS_CONTACTS_SYNCING_ENABLED
                
                if (self.shouldSyncContacts) {
                    
                    NSMutableDictionary *dictPhoneContact = [NSMutableDictionary dictionary];
                    dictPhoneContact[kCellNauMemberNameKey] = contacts.fullName;
                    dictPhoneContact[kCellNauMemberPhoneKey] = strPhoneNumber;
                    dictPhoneContact[kCellNauMemberTypeKey] = @(kCellNauMemberTypePhone);
                    [self.arrJsonCompatibleContacts addObject:dictPhoneContact];
                    
                }
                
#endif

                
            }
  
#endif
            
            
        }
    } //autoreleasepool
    CFRelease(allPeople);
    CFRelease(addressBook);
    //CFRelease(source);
        
    
    return  items;
    
    
}

-(void)initializeStatusForContacts
{
    __weak typeof(self) weakSelf = self;
    
    ///1.Fetch friend list
    [self getFriendsListWithCompletion:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            ///Friends list fetched successfully
            NSArray *arrFriends = objects;
            
            ///2.Retrive Cell411 friend requests/invites in pending state for current user
            PFQuery *pendingRequestQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            
            //NSMutableArray *arrContactsEmailAndPhone = [NSMutableArray array];
            ///Append email contacts
            //[arrContactsEmailAndPhone addObjectsFromArray:weakSelf.arrContactsEmail];
            ///Append phone contacts
            //[arrContactsEmailAndPhone addObjectsFromArray:weakSelf.arrContactsPhoneNumbers];
            //[pendingRequestQuery whereKey:kCell411AlertToKey containedIn:arrContactsEmailAndPhone];
            
            [pendingRequestQuery whereKey:kCell411AlertEntryForKey containedIn:@[kEntryForFriendRequest,kEntryForFriendInvite]];
            [pendingRequestQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
            [pendingRequestQuery whereKey:kCell411AlertIssuedByKey equalTo:[AppDelegate getLoggedInUser]];
            pendingRequestQuery.limit = 1000;
            
            [pendingRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (!error) {
                    
                    ///Pending requests fetched successfully
                    NSArray *arrPendingRequests = objects;
                    
                    ///3. Fetch existing Cell 411 users in current users phone contacts by checking on both username and email field
                    NSMutableArray *arrExistingContactsSubQuery = [NSMutableArray array];
                    
                    ///Add subqueries related to email if available
                    if (weakSelf.arrContactsEmail.count > 0) {
                        
                        PFQuery *getUserWithSameUsernameQuery = [PFUser query];
                        [getUserWithSameUsernameQuery whereKey:@"username" containedIn:weakSelf.arrContactsEmail];
                        [arrExistingContactsSubQuery addObject:getUserWithSameUsernameQuery];
                        
                        
                        PFQuery *getUserWithSameEmailQuery = [PFUser query];
                        [getUserWithSameEmailQuery whereKey:@"email" containedIn:weakSelf.arrContactsEmail];
                        [arrExistingContactsSubQuery addObject:getUserWithSameEmailQuery];
                        
                    }
                    
                    ///Add subqueries related to phone number if available
                    if (weakSelf.arrContactsPhoneNumbers.count > 0) {
                        
                        PFQuery *getUserWithSamePhoneNumberQuery = [PFUser query];
                        [getUserWithSamePhoneNumberQuery whereKey:kUserMobileNumberKey containedIn:weakSelf.arrContactsPhoneNumbers];
                        [arrExistingContactsSubQuery addObject:getUserWithSamePhoneNumberQuery];
                        
                    }
                    
                    PFQuery *existingCell411ContactsQuery = nil;
                    if (arrExistingContactsSubQuery.count == 1) {
                        ///There is only one sub query which could be in the case if only phone contacts are available so make it as main query
                        existingCell411ContactsQuery = [arrExistingContactsSubQuery firstObject];
                            
                    }
                    else{
                        ///More than one sub queries are available
                        existingCell411ContactsQuery = [PFQuery orQueryWithSubqueries:arrExistingContactsSubQuery];
                    }
                        
                        existingCell411ContactsQuery.limit = 1000;
                        [existingCell411ContactsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            
                            if (!error) {
                                
                                ///Existing cell 411 contacts fetched successfully
                                NSArray *arrExistingUsers = objects;
                                
                                ///use these arrays to set contact status
                                [weakSelf setContactsStatusUsingFriendsList:arrFriends pendingRequestsList:arrPendingRequests andExistingUsersList:arrExistingUsers];
                                
                            }
                        }];
                    
                
                    
                    
                    
                    
                }
                else if(![AppDelegate handleParseError:error]){
                    
                    NSLog(@"Error:%@",error);
                }
            }];
            
        }
        
    }];
    
    
}

-(void)getFriendsListWithCompletion:(PFArrayResultBlock)completion
{
    NSArray *arrFriends = [C411AppDefaults sharedAppDefaults].arrFriends;
    
    if (!arrFriends) {
        
        ///Get Friends from parse
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        PFRelation *getFriendsRelation = [currentUser relationForKey:kUserFriendsKey];
        [[getFriendsRelation query] findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (completion!=NULL) {
                completion(objects,error);
            }
            
        }];
        
    }
    else{
        ///Friend list already fetched return it back
        if (completion!=NULL) {
            
            completion(arrFriends,nil);
        }
    }
    
    
}


-(void)setContactsStatusUsingFriendsList:(NSArray *)arrFriends pendingRequestsList:(NSArray *)arrPendingRequests andExistingUsersList:(NSArray *)arrExistingUsers
{
    ///Cancel all previous operations
    [self.statusOpQueue cancelAllOperations];
    
    __weak typeof(self) weakSelf = self;
    
    ///Create a block operation for setting status
    NSBlockOperation *updateContactStatusOp = [[NSBlockOperation alloc]init];
    __block NSBlockOperation *weakUpdateContactStatusOp = updateContactStatusOp;
    [updateContactStatusOp addExecutionBlock:^{
        if (![weakUpdateContactStatusOp isCancelled]) {
            
            /// loop through the device contacts list to initialize statuses for each contact
                ///2.Iterate Contacts List
                for (ContactsData *contact in weakSelf.arrPhnContacts) {
                    
                    ///3.Iterate existing users list to check if this contact's account exist in parse
                    BOOL isAccountExist = NO;
                    PFUser *matchedExistingUser = nil;
                    for (PFUser *user in arrExistingUsers) {
                        
                        if (contact.contactType == ContactTypeEmail) {
                            ///Compare email from existing contact
                            NSString *strExistingUserEmail = [C411StaticHelper getEmailFromUser:user];
                            strExistingUserEmail = [strExistingUserEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if ([strExistingUserEmail.lowercaseString isEqualToString:contact.strEmail.lowercaseString]) {
                               
                                ///This contact exist on parse
                                isAccountExist = YES;
                                matchedExistingUser = user;
                                break;
                                
                            }
                        }
                        else if (contact.contactType == ContactTypePhone){
                        
                            ///Compare phone from existing contact
                            NSString *strExistingUserPhone = user[kUserMobileNumberKey];
                           if (strExistingUserPhone.length > 0) {
                                
                               ///There could be some old users which may contain formatted phone number, so extract a numeric string from formatted phone number
                               strExistingUserPhone = [C411StaticHelper getNumericStringFromString:strExistingUserPhone];
                                if ([strExistingUserPhone isEqualToString:contact.strPhoneNumber]) {
                                    
                                    ///This contact exist on parse
                                    isAccountExist = YES;
                                    matchedExistingUser = user;
                                    break;
                                }
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    if (isAccountExist) {
                        
                        ///4.loop through the friendsList to check if the user is friend
                        BOOL isFriend = NO;
                        for (PFUser *friend in arrFriends) {
                            
                            if (contact.contactType == ContactTypeEmail) {
                                ///Compare email from friend's email
                                NSString *strFriendEmail = [C411StaticHelper getEmailFromUser:friend];
                                strFriendEmail = [strFriendEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                if ([strFriendEmail.lowercaseString isEqualToString:contact.strEmail.lowercaseString]) {
                                    
                                    ///This contact is a friend of current user
                                    isFriend = YES;
                                    break;

                                    
                                }
                            }
                            else if (contact.contactType == ContactTypePhone){
                                
                                ///Compare phone from friend's phone
                                NSString *strFriendPhoneNumber = friend[kUserMobileNumberKey];
                                if (strFriendPhoneNumber.length > 0) {
                                    
                                    ///There could be some old users which may contain formatted phone number, so extract a numeric string from formatted phone number
                                    strFriendPhoneNumber = [C411StaticHelper getNumericStringFromString:strFriendPhoneNumber];
                                    if ([strFriendPhoneNumber isEqualToString:contact.strPhoneNumber]) {
                                        
                                        ///This contact is a friend of current user
                                        isFriend = YES;
                                        break;

                                    }
                                    
                                }
                                
                            }

                            
                        }
                        
                        if (isFriend) {
                            
                            ///4.1 Initialize the contact status to friend
                            contact.contactStatus = ContactStatusFriends;
                            
                        }
                        else{
                            
                            ///4.2 loop through the pendingRequestsList to check if the user has already been sent a request which is pending for approval, by comparing the entryFor attribute to FR
                            BOOL isPendingFR = NO;
                            
                            for (PFObject *cell411Alert in arrPendingRequests) {
                                
                                NSString *entryFor = cell411Alert[kCell411AlertEntryForKey];
                               
                                ///requestTo may contain email, phone or fb username as per following scenarios:
                                ///1)Email: a) Friend request sent to email user.
                                ///         b) Friend invite sent to an email address(which may later convert to an email user or facebook user).
                                ///2)Phone: a) Friend invite sent on a phone number(which may later convert to an email user or facebook user).
                                ///3)FB Username: a) Friend request sent to facebook user having same email address.
                                ///               b) Frient request sent to facebook user having same phone number.
                                NSString *requestTo = cell411Alert[kCell411AlertToKey];
                                
                                
                                
                                if ([entryFor isEqualToString:kEntryForFriendRequest]) {
                                    ///FR entry will exist for existing users, i.e this friend request is sent to an existing user
                                    if (contact.contactType == ContactTypeEmail) {
                                        
                                        ///requestTo will contain username which could be email or FB username
                                        ///Compare email first
                                        if ([requestTo isEqualToString:contact.strEmail.lowercaseString]) {
                                            
                                            ///Friend request has been sent to this email user contact and is yet pending.
                                            isPendingFR = YES;
                                            break;

                                        }
                                        else if (([C411StaticHelper getSignUpTypeOfUser:matchedExistingUser] == SignUpTypeFacebook)
                                                 &&([requestTo isEqualToString:matchedExistingUser.username])){
                                            
                                            ///Matched user is a facebook user and Friend request has been sent to this facebook user contact and is yet pending.
                                            isPendingFR = YES;
                                            break;
                                        }
                                        
                                        
                                    }
                                    else if (contact.contactType == ContactTypePhone){
                                    
                                        ///requestTo will contain the user name
                                        if ([requestTo isEqualToString:matchedExistingUser.username]) {
                                            
                                            ///Friend request has been sent to this phone number contact and is yet pending.
                                            isPendingFR = YES;
                                            break;
                                        }
                                        
                                    }
                                    
                                    
                                }
                                else if ([entryFor isEqualToString:kEntryForFriendInvite]){
                                    ///FI entry will exist for non existing users, i.e this friend invite was sent to a non existing user, but later that contact became app user.
                                    
                                    if (contact.contactType == ContactTypeEmail) {
                                        
                                        ///requestTo will always contain email if friend invite is sent to an email address
                                        ///Compare email
                                        if ([requestTo isEqualToString:contact.strEmail.lowercaseString]) {
                                            
                                            ///Friend invite(needs to be considered as friend request now as there is an existing user with this email) has been sent to this email user contact and is yet pending.
                                            isPendingFR = YES;
                                            break;
                                            
                                        }
                                    }
                                    else if (contact.contactType == ContactTypePhone){
                                            
                                            ///requestTo will always contain phone number if friend invite is sent to a phone number
                                            if ([requestTo isEqualToString:contact.strPhoneNumber]) {
                                                
                                                ///Friend invite(needs to be considered as friend request now as there is an existing user with this phone number) has been sent to this phone number contact and is yet pending.
                                                isPendingFR = YES;
                                                break;
                                            }
                                            
                                        }

                                }
                                
                            }
                            
                            if (isPendingFR) {
                                
                                ///4.3 initialize the contact status to friend request pending
                                contact.contactStatus = ContactStatusFriendRequestPending;
                                
                            }
                            else{
                                
                                ///4.3 initialize the contact status to user exist
                                contact.contactStatus = ContactStatusUserExist;
                                
                            }
                            
                        }
                        
                        ///Add matching user to contact object to be used later for sending friend request to this contact
                        contact.matchedUserObject = matchedExistingUser;
                        
                        ///Add this user to the existing contacts array
                        [weakSelf.arrExistingContacts addObject:contact];
                        
                    }
                    else{
                        
                        ///5.loop through the pendingRequestsList to check if the user has already been sent a 			request which is pending for approval, by comparing the entryFor attribute to FI
                        BOOL isPendingFI = NO;
                        
                        for (PFObject *cell411Alert in arrPendingRequests) {
                            
                            NSString *entryFor = cell411Alert[kCell411AlertEntryForKey];
                            
                            NSString *requestTo = cell411Alert[kCell411AlertToKey];
                            
                            if ([entryFor isEqualToString:kEntryForFriendInvite]){
                                ///FI entry will exist for non existing users, i.e this friend invite was sent to a non existing user, who has still not joined the app.
                                
                                if (contact.contactType == ContactTypeEmail) {
                                    
                                    ///requestTo will always contain email if friend invite is sent to an email address
                                    ///Compare email
                                    if ([requestTo isEqualToString:contact.strEmail.lowercaseString]) {
                                        
                                        ///Friend invite has been sent to this email user contact and is yet pending.
                                        isPendingFI = YES;
                                        break;
                                        
                                    }
                                }
                                else if (contact.contactType == ContactTypePhone){
                                    
                                    ///requestTo will always contain phone number if friend invite is sent to a phone number
                                    if ([requestTo isEqualToString:contact.strPhoneNumber]) {
                                        
                                        ///Friend invite has been sent to this phone number contact and is yet pending.
                                        isPendingFI = YES;
                                        break;
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                        if (isPendingFI) {
                            
                            ///5.1 initialize the contact status to invitation pending
                            contact.contactStatus = ContactStatusInvitationPending;
                            
                        }
                        else{
                            
                            ///5.2 initialize the contact status to user does not exist
                            contact.contactStatus = ContactStatusUserDoesNotExist;
                            
                        }
                        
                        ///Add this user to non existing contacts array
                        [weakSelf.arrNonExistingContacts addObject:contact];

                    }
                    
                }
                
            
        }
        
        
    }];
    
    ///Create a block completion operation
    NSBlockOperation *completionOperation=[[NSBlockOperation alloc]init];
    __block NSBlockOperation *weakCompletionOperation=completionOperation;
    [completionOperation addExecutionBlock:^{
        if (![weakCompletionOperation isCancelled]) {
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                
                ///Remove the progress hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                ///Post notification to update the contact/invite list
                [[NSNotificationCenter defaultCenter]postNotificationName:kImportContactListInitializedNotification object:nil];
                
            }];
            
            
        }
        
    }];
    
    
    ///Create an operation queue as this could be a long operation
    if (!self.statusOpQueue) {
        
        self.statusOpQueue = [[NSOperationQueue alloc]init];
    }
    
    ///Add dependency
    [completionOperation addDependency:updateContactStatusOp];
    
    ///Add and execute operations in background
    [self.statusOpQueue addOperations:@[updateContactStatusOp,completionOperation] waitUntilFinished:NO];
    
}

#if IS_CONTACTS_SYNCING_ENABLED

-(void)syncContactsWithServer:(NSArray *)arrContacts
{
    
    ///Enable contact syncing on Parse
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSNumber *syncContactValue = @1;
    
    currentUser[kUserSyncContactsKey] = syncContactValue;
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (!succeeded) {
            
            if(error){
                
                ///some error occured updating SyncContact value on parse, save it eventually
                [currentUser saveEventually];
                
            }
            
            
        }
        
        ///Show toast for disabled
        [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Upload Contacts Enabled", nil)];
        
        ///Post the notiification for it
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kContactSyncingEnabledNotification object:nil];
       
        
    }];
    
    
    ///Upload contacts on server
    NSError *err = nil;
    NSData *contactsJsonData = [NSJSONSerialization dataWithJSONObject:arrContacts options:NSJSONWritingPrettyPrinted error:&err];
    if (!err && contactsJsonData) {
        
        NSString *strJsonArrContacts = [[NSString alloc]initWithData:contactsJsonData encoding:NSUTF8StringEncoding];
        if (strJsonArrContacts.length > 0) {
            
            NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
            dictParams[kUploadContactsFuncParamContactArrayKey] = strJsonArrContacts;
            [C411StaticHelper uploadContacts:dictParams withCompletion:^(id  _Nullable object, NSError * _Nullable error) {
                
                if (!error) {
                    
                    [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Contacts uploaded successfully", nil)];
                }
                else{
                    
                    [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Error uploading contacts", nil)];
                    
                }
                
            }];
            
        }
    }

    
    
    
}
#endif


//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender {
    
    
#if IS_CONTACTS_SYNCING_ENABLED
    
    if(self.parentVC){
        
       [self.navigationController popToViewController:self.parentVC animated:YES];
    }
    else{
    
        [self.navigationController popViewControllerAnimated:YES];
    }
    
#else
    
    [self.navigationController popViewControllerAnimated:YES];
    
#endif
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
/*
-(void)contactsDidUpdated:(NSNotification *)notif
{
    [self refreshContacts];
}
*/

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
    [self setNeedsReloadColors];
}

@end
