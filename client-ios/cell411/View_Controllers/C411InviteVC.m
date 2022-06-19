//
//  C411InviteVC.m
//  cell411
//
//  Created by Milan Agarwal on 28/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411InviteVC.h"
#import "C411ImportedContactCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411AppDefaults.h"
#import "AppDelegate.h"
#import "C411ColorHelper.h"

@interface C411InviteVC ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UITableView *tblVuPhnContacts;
@property (nonatomic, strong) NSArray *arrSearchResults;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation C411InviteVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSearchController];
    [self applyColors];
    [self registerForNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
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
#pragma mark - Private Methods
//****************************************************
-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(contactStatusDidInitialized:) name:kImportContactListInitializedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didMovedAwayFromContacts:) name:kDidMovedAwayFromContactListNotification object:nil];
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
    self.tblVuPhnContacts.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = NO;///setting it to YES will crash on switching to other tab while search bar is first responder
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    self.searchController.searchBar.returnKeyType = UIReturnKeyDone;

    [self.searchController.searchBar sizeToFit];
    
}

-(void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.fullName contains[c] %@ OR SELF.strEmail contains[c] %@ OR SELF.strPhoneNumber contains[c] %@",searchText,searchText,searchText];
    
    self.arrSearchResults = [self.importContactsDelegate.arrNonExistingContacts filteredArrayUsingPredicate:resultPredicate];
}

//****************************************************
#pragma mark - Table View Datasource and Delegate Methods
//****************************************************

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.isActive && self.searchController.searchBar.text.length > 0) {
        
        ///Search TableView
        return self.arrSearchResults.count;
        
    }
    else{
        ///Contact list tableview
        return self.importContactsDelegate.arrNonExistingContacts.count;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    
    
    ///Create a Contact Row
    static NSString *contactCellId = @"C411ImportedContactCell";
    static NSString *contactSearchCellId = @"C411ImportedContactSearchCell";
    C411ImportedContactCell *contactCell = nil;
    ContactsData *contact = nil;
    
    ///Get Tableview specific cell and Contact object
    if (self.searchController.isActive && self.searchController.searchBar.text.length > 0){
        ///Search TableView
        contactCell = [self.tblVuPhnContacts dequeueReusableCellWithIdentifier:contactSearchCellId];
        contact = [self.arrSearchResults objectAtIndex:rowIndex];
        
    }
    else{
        ///Contact Index list tableview
        contactCell =  [self.tblVuPhnContacts dequeueReusableCellWithIdentifier:contactCellId];
        
        contact = [self.importContactsDelegate.arrNonExistingContacts objectAtIndex:rowIndex];
        
    }
    
    ///Set Contact name
    contactCell.lblContactName.text = contact.fullName;
    
    ///Set Contact email/phone
    if(contact.contactType == ContactTypeEmail){
        
        contactCell.lblContactEmail.text = contact.strEmail;
    }
    else if(contact.contactType == ContactTypePhone){
        
        contactCell.lblContactEmail.text = contact.strPhoneNumber;
    }
    
    
    ///set status button
    if (contact.contactStatus == ContactStatusInitializing) {
        
        ///Status is still initializing, hide the status buttons
        contactCell.btnContactStatus.hidden = YES;
        ///Remove contact data from button to avoid mismatch due to reusability
        contactCell.btnContactStatus.contact = nil;
        
    }
    else{
        contactCell.btnContactStatus.hidden = NO;
        [contactCell.btnContactStatus addTarget:self action:@selector(btnStatusTapped:) forControlEvents:UIControlEventTouchUpInside];
        contactCell.btnContactStatus.contact = contact;
        
        NSString *themeColor = @"2196F3";
        ///Set status button
        if (contact.contactStatus == ContactStatusInvitationPending) {
            [contactCell.btnContactStatus setBackgroundColor:[C411StaticHelper colorFromHexString:themeColor]];
            [contactCell.btnContactStatus setTitle:NSLocalizedString(@"Re-invite", nil) forState:UIControlStateNormal];
            [contactCell.btnContactStatus setTitle:NSLocalizedString(@"Re-invite", nil) forState:UIControlStateDisabled];
            contactCell.btnContactStatus.enabled = YES;
            
        }
        else if (contact.contactStatus == ContactStatusUserDoesNotExist) {
            [contactCell.btnContactStatus setBackgroundColor:[C411StaticHelper colorFromHexString:themeColor]];
            [contactCell.btnContactStatus setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
            [contactCell.btnContactStatus setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateDisabled];
            contactCell.btnContactStatus.enabled = YES;
            
        }
        else{
            
            contactCell.btnContactStatus.hidden = YES;
        }
        
        
        if (contact.isRequestInProgress) {
            
            ///Sending friend invite/reinvite in progress
            contactCell.btnContactStatus.enabled = NO;
            contactCell.btnContactStatus.alpha = 0.6;
            
        }
        else{
            
            ///Sending Friend invite/reinvite is not in progress for this contact
            contactCell.btnContactStatus.enabled = YES;
            contactCell.btnContactStatus.alpha = 1.0;
            
        }

    }
    
    return contactCell;
    
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 52.0f;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///Do nothing on cell selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    CGRect searchBarFrame = self.searchController.searchBar.frame;
    [self.tblVuPhnContacts scrollRectToVisible:searchBarFrame animated:NO];
    return NSNotFound;
}

//****************************************************
#pragma mark - UISearchResultsUpdating Methods
//****************************************************

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self filterContentForSearchText:searchString scope:[[self.searchController.searchBar scopeButtonTitles]objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
    [self.tblVuPhnContacts reloadData];
    
    if(searchString.length == 0){
        
        [C411StaticHelper localizeCancelButtonForSearchBar:searchController.searchBar];
        
    }
}


//****************************************************
#pragma mark - Action Method
//****************************************************

-(void)btnStatusTapped:(UIButton *)sender
{
    ContactsData *contact = sender.contact;
    if ((contact.contactStatus == ContactStatusUserDoesNotExist)
        ||(contact.contactStatus == ContactStatusInvitationPending)) {
        
        if (contact.contactType == ContactTypeEmail) {
            
            ///Send Email Invite
            PFUser *currentUser = [AppDelegate getLoggedInUser];
            NSString *strEmail = [C411StaticHelper getEmailFromUser:currentUser];
            strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (strEmail.length > 0) {
                ///Handle Friend invite
                [self handleEmailInviteForStatusButton:sender];
                
            }
            else{
                
                ///Show update email popup
                __weak typeof(self) weakSelf = self;
                
                [[C411AppDefaults sharedAppDefaults]showUpdateEmailPopupForUser:currentUser fromViewController:self withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    ///Perform operation only if succeeded, error display is already handled
                    if (succeeded) {
                        
                        ///Handle Friend invite
                        [weakSelf handleEmailInviteForStatusButton:sender];
                        
                        
                    }
                    
                }];
                
            }

            
        }
        else if(contact.contactType == ContactTypePhone){
            
            ///Send SMS Invite
            [self handleSMSInviteForStatusButton:sender];
        }

    }
}


-(void)handleEmailInviteForStatusButton:(UIButton *)sender
{
    ContactsData *contact = sender.contact;
    
    if (contact.contactStatus == ContactStatusUserDoesNotExist) {
        
        NSLog(@"Send friend invite to this contact");
        contact.requestInProgress = YES;
        [self.tblVuPhnContacts reloadRowsAtIndexPaths:[self.tblVuPhnContacts indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
        __weak typeof(self) weakSelf = self;
        
        NSString *strEmailId = contact.strEmail;
        strEmailId = [strEmailId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [[C411AppDefaults sharedAppDefaults]inviteFriendWithEmailId:strEmailId shouldShowMessageOnSuccessOrError:NO withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (succeeded) {
                
                ///Friend invite is sent successfully
                ///Update status of contact
                contact.contactStatus = ContactStatusInvitationPending;
                
                
            }
            else if (error){
                
                ///Some error occured sending friend invite email to this user
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                    
                }
                
                
            }
            else{
                
                ///there is no error but operation doesn't get succeeded, could be the case that email id is not available
                
                ///Show message that unable to send invitation to this user
                [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Sorry, we are unable to send friend invite on this email.", nil) onViewController:weakSelf];
                
            }
            
            ///Reset progress state
            contact.requestInProgress = NO;
            ///Reload visible cells
            [weakSelf.tblVuPhnContacts reloadRowsAtIndexPaths:[weakSelf.tblVuPhnContacts indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];

            
        }];
        
    }
    else if (contact.contactStatus == ContactStatusInvitationPending) {
        
        NSLog(@"Send friend invite email to this contact again");
        contact.requestInProgress = YES;
        [self.tblVuPhnContacts reloadRowsAtIndexPaths:[self.tblVuPhnContacts indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        __weak typeof(self) weakSelf = self;
        
        NSString *strEmailId = contact.strEmail;
        strEmailId = [strEmailId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        NSString *strCurrentUserEmail = [C411StaticHelper getEmailFromUser:currentUser];
        strCurrentUserEmail = [strCurrentUserEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
        
        
        ///Send an invite email
        [C411StaticHelper sendInviteEmailTo:strEmailId.lowercaseString from:strUserFullName withSenderEmail:strCurrentUserEmail.lowercaseString andCompletion:^(id object, NSError *error) {
            
            
            if (!error) {
                
                ///Invite sent successfully
                NSLog(@"Invite sent successfully");
                ///Update status of contact
                contact.contactStatus = ContactStatusInvitationPending;
            
            }
            else{
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"%@",errorString);
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
            }
            
            
            ///Reset progress state
            contact.requestInProgress = NO;
            ///Reload visible cells
            [weakSelf.tblVuPhnContacts reloadRowsAtIndexPaths:[weakSelf.tblVuPhnContacts indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            
        }];
        
    }
    
    
}


-(void)handleSMSInviteForStatusButton:(UIButton *)sender
{
    ContactsData *contact = sender.contact;
    
    if (contact.contactStatus == ContactStatusUserDoesNotExist) {
        
        NSLog(@"Send friend invite sms to this contact");
        contact.requestInProgress = YES;
        [self.tblVuPhnContacts reloadRowsAtIndexPaths:[self.tblVuPhnContacts indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
        __weak typeof(self) weakSelf = self;
        
        NSString *strPhoneNumber = contact.strPhoneNumber;
        [[C411AppDefaults sharedAppDefaults]sendSMSInviteToFriendWithPhoneNumber:strPhoneNumber withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (succeeded) {
                
                ///Friend invite is sent successfully
                ///Update status of contact
                contact.contactStatus = ContactStatusInvitationPending;
                
                
            }
            else{
                
                ///Some error occured sending friend invite sms to this user
                
                ///show error
                ///NSString *errorString = [error userInfo][@"error"];
                NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Unable to send SMS on phone number %@, valid number should start with country code followed by contact number. Please open Contacts app and update it if it's not correct.", nil),strPhoneNumber];
                
                [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:weakSelf];
            
            }
            
            ///Reset progress state
            contact.requestInProgress = NO;
            ///Reload visible cells
            [weakSelf.tblVuPhnContacts reloadRowsAtIndexPaths:[weakSelf.tblVuPhnContacts indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            
        }];
        
    }
    else if (contact.contactStatus == ContactStatusInvitationPending) {
        
        NSLog(@"Send friend invite sms to this contact again");
        contact.requestInProgress = YES;
        [self.tblVuPhnContacts reloadRowsAtIndexPaths:[self.tblVuPhnContacts indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        __weak typeof(self) weakSelf = self;
        
        NSString *strPhoneNumber = contact.strPhoneNumber;
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
        if (![strPhoneNumber hasPrefix:@"+"]) {
            ///Add + if it's not there
            strPhoneNumber = [@"+" stringByAppendingString:strPhoneNumber];
        }
        
        NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ invited you to install %@ to respond to emergencies: %@", nil),strUserFullName,LOCALIZED_APP_NAME,DOWNLOAD_APP_URL];
        [ServerUtility sendSms:strMessage onNumber:strPhoneNumber withCompletion:^(NSError *error, id data) {
            
            if (!error) {
                
                ///Invite sent successfully
                NSLog(@"Invite sent successfully");
                ///Update status of contact
                contact.contactStatus = ContactStatusInvitationPending;
                
            }
            else{
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"%@",errorString);
                NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Unable to send SMS on phone number %@, valid number should start with country code followed by contact number. Please open Contacts app and update it if it's not correct.", nil),strPhoneNumber];
                
                [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:weakSelf];
            }
            
            
            ///Reset progress state
            contact.requestInProgress = NO;
            ///Reload visible cells
            [weakSelf.tblVuPhnContacts reloadRowsAtIndexPaths:[weakSelf.tblVuPhnContacts indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            
        }];
        
    }
    
}

//****************************************************
#pragma mark - Notifications Method
//****************************************************

-(void)contactStatusDidInitialized:(NSNotification *)notif
{
    [self.tblVuPhnContacts reloadData];
}

-(void)didMovedAwayFromContacts:(NSNotification *)notification
{
    ///hide the search bar
    self.searchController.active = NO;
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}
@end
