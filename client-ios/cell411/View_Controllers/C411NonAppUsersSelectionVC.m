//
//  C411NonAppUsersSelectionVC.m
//  cell411
//
//  Created by Milan Agarwal on 31/08/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411NonAppUsersSelectionVC.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "ContactsData.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MA_Country.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "C411ContactSelectionCell.h"
#import "C411AlertSettings.h"
#import "C411ColorHelper.h"

@interface C411NonAppUsersSelectionVC ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating>

@property (strong, nonatomic) IBOutlet UITableView *tblVuContacts;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barBtnSendOrSave;
- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender;
- (IBAction)barBtnSendOrSaveTapped:(UIButton *)sender;

///Will contain list of phone contacts containing emails and phone numbers
@property (nonatomic, strong) NSArray *arrPhnContacts;
@property (nonatomic, strong) NSMutableArray *arrSelectedNAUs;
@property (nonatomic, strong) NSArray *arrSearchResults;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation C411NonAppUsersSelectionVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setupSearchController];
    [self configureViews];
    [self registerForNotifications];
    if (self.myPrivateCell) {
        
        ///Called from C411NAUCellMembers Screen, set the right bar button item title to update
        self.barBtnSendOrSave.title = NSLocalizedString(@"Update", nil);
        
    }
    else if(self.alertSettings){
        
        ///Remove the bar button for send or save
        self.navigationItem.rightBarButtonItem = nil;
        
    }
    else{
        
        ///Called from C411SendAlertPopupVC while sending out an alert, set the right bar button item title to update
        self.barBtnSendOrSave.title = NSLocalizedString(@"Send", nil);
        
        if(self.sendAlertPopupVC){
        
            ///post notification that it's being displayed to move send alert popup to back
            [[NSNotificationCenter defaultCenter]postNotificationName:kDidOpenedNonAppUsersSelectionVCNotification object:nil];
        }
        
    }
    
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        
        [weakSelf requestAuthAndGetPhoneContacts];
    }];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ///Unhide the navigation bar
    self.navigationController.navigationBarHidden = NO;
    
}

-(void)dealloc
{
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


-(NSMutableArray *)arrSelectedNAUs
{
    
    if (!_arrSelectedNAUs) {
        
        _arrSelectedNAUs = [NSMutableArray array];
        
        if (self.myPrivateCell) {
        
            ///Append Contacts data which are initially the part of the cell
            NSArray *arrNauMembers = self.myPrivateCell[kCellNauMembersKey];
            _arrSelectedNAUs = [self getContactRepresentationOfNauMembers:arrNauMembers];
        }
        else if(self.alertSettings){
            
            ///Append already selected Contacts data
            NSArray *arrNauMembers = [self.alertSettings getSelectedNauMembers];
            _arrSelectedNAUs = [self getContactRepresentationOfNauMembers:arrNauMembers];
            
        }
        
    }
    
    return _arrSelectedNAUs;
    
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    self.title = NSLocalizedString(@"Select Contacts", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)applyColors {
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)setupSearchController
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.tblVuContacts.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = NO;///setting it to YES will crash on switching to other tab while search bar is first responder
    self.searchController.searchBar.returnKeyType = UIReturnKeyDone;
    
    [self.searchController.searchBar sizeToFit];
}

-(void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.fullName contains[c] %@ OR SELF.strEmail contains[c] %@ OR SELF.strPhoneNumber contains[c] %@",searchText,searchText,searchText];
    
    self.arrSearchResults = [self.arrPhnContacts filteredArrayUsingPredicate:resultPredicate];
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
                    
                    ///Hide the hud
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

                    if (weakSelf.arrPhnContacts.count > 0) {
                        
                        ///Reload the data
                        [weakSelf.tblVuContacts reloadData];
                        
                        
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
        
        ///Hide the hud
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

        if (self.arrPhnContacts.count > 0) {
            
            ///Reload the data
            [weakSelf.tblVuContacts reloadData];
            
        }
        
        
        
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        [C411StaticHelper showAlertWithTitle:nil message:[NSString localizedStringWithFormat:NSLocalizedString(@"Please allow access to contacts for %@",nil), LOCALIZED_APP_NAME] onViewController:self];
    }
}


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
                //[self.arrContactsEmail addObject:strEmail];
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
                //[self.arrContactsPhoneNumbers addObject:strPhoneNumber];
                
            }
            
#endif
            
            
        }
    } //autoreleasepool
    CFRelease(allPeople);
    CFRelease(addressBook);
    //CFRelease(source);
    
    
    return  items;
    
    
}

-(BOOL)didCellContainNAU:(ContactsData *)NAUContact
{
    BOOL isNAUExist = NO;
    
    for (ContactsData *contact in self.arrSelectedNAUs) {
        
        if ([self isContact:contact equalToContact:NAUContact]) {
            isNAUExist = YES;
            break;
        }
        
    }
    
    return isNAUExist;
}

-(NSUInteger)selectedIndexOfNAU:(ContactsData *)NAUContact
{
    NSUInteger NAUIndex = NSNotFound;
    NSUInteger counter = 0;
    for (ContactsData *contact in self.arrSelectedNAUs) {
        
        if ([self isContact:contact equalToContact:NAUContact]) {
            NAUIndex = counter;
            break;
        }
        
        counter++;
        
    }
    
    return NAUIndex;
}

-(BOOL)isContact:(ContactsData *)contact1 equalToContact:(ContactsData *)contact2
{
    BOOL isEqual = NO;
    if (contact1 && contact2) {
        
        if ((contact1.contactType == contact2.contactType)
            &&([contact1.fullName isEqualToString:contact2.fullName])
            &&(((contact1.contactType == ContactTypePhone)
                &&([contact1.strPhoneNumber isEqualToString:contact2.strPhoneNumber]))
               ||((contact1.contactType == ContactTypeEmail)
                  &&([contact1.strEmail isEqualToString:contact2.strEmail])))) {
            
                   ///Both contacts are equal
                   isEqual = YES;
        }
        
    }
    
    return isEqual;
    
}

-(NSArray *)getDictionaryRepresentationOfContacts:(NSArray *)arrContacts
{
    ///Convert the array of contacts to array of dictionary where a dictionary will represent the contact
    NSMutableArray *arrContactsDict = [NSMutableArray array];
    
    for (ContactsData *nauContact in arrContacts) {
        
        if (nauContact.contactType != ContactTypeInvalid) {
            
            ///Valid contact
            NSMutableDictionary *dictNauMember = [NSMutableDictionary dictionary];
            dictNauMember[kCellNauMemberNameKey] = nauContact.fullName;
            
            switch (nauContact.contactType) {
                case ContactTypePhone:
                    dictNauMember[kCellNauMemberPhoneKey] = nauContact.strPhoneNumber;
                    dictNauMember[kCellNauMemberTypeKey] = @(kCellNauMemberTypePhone);
                    break;
                case ContactTypeEmail:
                    dictNauMember[kCellNauMemberEmailKey] = nauContact.strEmail;
                    dictNauMember[kCellNauMemberTypeKey] = @(kCellNauMemberTypeEmail);
                    break;
                    
                default:
                    break;
            }
            
            ///Add dictionary representation of selected contact to array
            [arrContactsDict addObject:dictNauMember];
            
            
        }
    }
    
    return arrContactsDict;
        

}

-(NSMutableArray *)getContactRepresentationOfNauMembers:(NSArray *)arrNauMembers
{
    ///Convert the array of dictionary to array of contacts where a dictionary will represent the contact
    NSMutableArray *arrContacts = [NSMutableArray array];

    for (NSDictionary *dictNauMember in arrNauMembers) {
        
        ContactsData *NAUContact = [[ContactsData alloc]init];
        NAUContact.fullName = dictNauMember[kCellNauMemberNameKey];
        switch ([dictNauMember[kCellNauMemberTypeKey]intValue]) {
            case kCellNauMemberTypePhone:
                NAUContact.strPhoneNumber = dictNauMember[kCellNauMemberPhoneKey];
                NAUContact.contactType = ContactTypePhone;
                break;
            case kCellNauMemberTypeEmail:
                NAUContact.strEmail = dictNauMember[kCellNauMemberEmailKey];
                NAUContact.contactType = ContactTypeEmail;
                break;
                
            default:
                break;
        }
        
        if (NAUContact.contactType != ContactTypeInvalid) {
            
            ///Add this contact to selected members array
            [arrContacts addObject:NAUContact];
            
        }
    }
    
    return arrContacts;
    
}

//****************************************************
#pragma mark - UITableViewDatasource and delegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.searchController.isActive && self.searchController.searchBar.text.length > 0) {
        
        ///Search TableView
        return self.arrSearchResults.count;
        
    }
    else{
        ///Contact list tableview
        return self.arrPhnContacts.count;

    }

    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    
    
    ///Create and Return friend cell
    static NSString *nauSelectionCellId = @"C411ContactSelectionCell";
    C411ContactSelectionCell *nauSelectionCell = [tableView dequeueReusableCellWithIdentifier:nauSelectionCellId];
    
    
    ///Get NAU Contact object
    ContactsData *NAUContact;
    
    ///Get Tableview specific cell and Contact object
    if (self.searchController.isActive && self.searchController.searchBar.text.length > 0){
        ///Search TableView
        NAUContact = [self.arrSearchResults objectAtIndex:rowIndex];
        
    }
    else{
        ///Contact Index list tableview
        NAUContact = [self.arrPhnContacts objectAtIndex:rowIndex];

    }

    
    ///Set Friend name
    nauSelectionCell.lblContactName.text = NAUContact.fullName;
    
    ///Set Contact email/phone
    if(NAUContact.contactType == ContactTypeEmail){
        
        nauSelectionCell.lblContactEmailOrPhone.text = NAUContact.strEmail;
    }
    else if(NAUContact.contactType == ContactTypePhone){
        
        nauSelectionCell.lblContactEmailOrPhone.text = NAUContact.strPhoneNumber;
    }
    
    ///Show tick if contact is already selected
    if ([self didCellContainNAU:NAUContact]) {
        ///show selected
        nauSelectionCell.btnCheckbox.selected = YES;
    }
    else{
        ///show unselected
        nauSelectionCell.btnCheckbox.selected = NO;
    }
    return nauSelectionCell;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    
    ///Get NAU Contact object
    ContactsData *NAUContact;
    
    ///Get Tableview specific cell and Contact object
    if (self.searchController.isActive && self.searchController.searchBar.text.length > 0){
        ///Search TableView
        NAUContact = [self.arrSearchResults objectAtIndex:rowIndex];
        
    }
    else{
        ///Contact Index list tableview
        NAUContact = [self.arrPhnContacts objectAtIndex:rowIndex];
        
    }
    
    NSUInteger memberSelectedIndex = [self selectedIndexOfNAU:NAUContact];
    if (memberSelectedIndex != NSNotFound) {
        
        ///Member already selected, remove it from selected members array
        [self.arrSelectedNAUs removeObjectAtIndex:memberSelectedIndex];
        
    }
    else{
        
        ///This member is not currently in the group, add it to the selected members array
        [self.arrSelectedNAUs addObject:NAUContact];
    }
    
    ///Reload table to toggle tick marks
    [self.tblVuContacts reloadData];
    
    
}

//****************************************************
#pragma mark - UISearchResultsUpdating Methods
//****************************************************

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self filterContentForSearchText:searchString scope:[[self.searchController.searchBar scopeButtonTitles]objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
    [self.tblVuContacts reloadData];
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender {
    
    ///hide the search bar
    self.searchController.active = NO;
    
    if(self.alertSettings){
        
        ///Get the contacts in dictionary format
        NSArray *arrSelectedNAUs = [self getDictionaryRepresentationOfContacts:self.arrSelectedNAUs];
        
        ///Call the delegate and pass the members selected
        [self.delegate nonAppUsersSelectionVC:self didSelectNonAppUsers:arrSelectedNAUs];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if(self.sendAlertPopupVC){
        
        ///post notification that it's being displayed to move send alert popup to front
        [[NSNotificationCenter defaultCenter]postNotificationName:kDidClosedNonAppUsersSelectionVCNotification object:nil];
    }
}

- (IBAction)barBtnSendOrSaveTapped:(UIButton *)sender {
    
    if ((self.arrSelectedNAUs.count > 0)
        ||(self.myPrivateCell && ([self.myPrivateCell[kCellNauMembersKey] count] > 0))) {
        
        ///hide the search bar
        self.searchController.active = NO;
        
        ///Get the contacts in dictionary format
        NSArray *arrSelectedNAUs = [self getDictionaryRepresentationOfContacts:self.arrSelectedNAUs];
        
        ///Call the delegate and pass the members selected, also wait for the delegate to remove this screen as per their way
        [self.delegate nonAppUsersSelectionVC:self didSelectNonAppUsers:arrSelectedNAUs];

    }
    else{
        
        ///Show toast to select at least one user
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Please select at least 1 non app user", nil)];
    }
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
