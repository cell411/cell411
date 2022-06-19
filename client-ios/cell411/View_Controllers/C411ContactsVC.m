//
//  C411ContactsVC.m
//  cell411
//
//  Created by Milan Agarwal on 28/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ContactsVC.h"
#import "C411ImportedContactCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411AppDefaults.h"
#import "AppDelegate.h"
#import "C411ColorHelper.h"

@interface C411ContactsVC ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UITableView *tblVuPhnContacts;
@property (nonatomic, strong) NSArray *arrSearchResults;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation C411ContactsVC

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
    
    self.arrSearchResults = [self.importContactsDelegate.arrExistingContacts filteredArrayUsingPredicate:resultPredicate];
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
        return self.importContactsDelegate.arrExistingContacts.count;
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
        
        contact = [self.importContactsDelegate.arrExistingContacts objectAtIndex:rowIndex];
        
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
        
        UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
        NSString *disabledColor = @"888888";
        ///Set status button
        if (contact.contactStatus == ContactStatusFriends) {
            [contactCell.btnContactStatus setBackgroundColor:[C411StaticHelper colorFromHexString:disabledColor]];
            [contactCell.btnContactStatus setTitle:NSLocalizedString(@"Friends", nil) forState:UIControlStateNormal];
            [contactCell.btnContactStatus setTitle:NSLocalizedString(@"Friends", nil) forState:UIControlStateDisabled];
            contactCell.btnContactStatus.enabled = NO;
            contactCell.btnContactStatus.alpha = 1.0;

        }
        else if (contact.contactStatus == ContactStatusFriendRequestPending) {
            [contactCell.btnContactStatus setBackgroundColor:themeColor];
            [contactCell.btnContactStatus setTitle:NSLocalizedString(@"Resend", nil) forState:UIControlStateNormal];
            [contactCell.btnContactStatus setTitle:NSLocalizedString(@"Resend", nil) forState:UIControlStateDisabled];
            if (contact.isRequestInProgress) {
                
                ///Resending friend request in progress
                contactCell.btnContactStatus.enabled = NO;
                contactCell.btnContactStatus.alpha = 0.6;
                
            }
            else{
                
                ///Resending Friend request is not done for this contact
                contactCell.btnContactStatus.enabled = YES;
                contactCell.btnContactStatus.alpha = 1.0;
                
            }

        }
        else if (contact.contactStatus == ContactStatusUserExist) {
            [contactCell.btnContactStatus setBackgroundColor:themeColor];
            [contactCell.btnContactStatus setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
            [contactCell.btnContactStatus setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateDisabled];
            
            if (contact.isRequestInProgress) {
                
                ///Sending friend request in progress
                contactCell.btnContactStatus.enabled = NO;
                contactCell.btnContactStatus.alpha = 0.6;
                
            }
            else{
                
                ///Friend request is not yet initiated for this contact
                contactCell.btnContactStatus.enabled = YES;
                contactCell.btnContactStatus.alpha = 1.0;

            }
            
        }
        else{
            
            contactCell.btnContactStatus.hidden = YES;
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
    if ((contact.contactStatus == ContactStatusUserExist)
        ||(contact.contactStatus == ContactStatusFriendRequestPending)) {
        
        ///Send/resend friend request
        NSLog(@"Send friend request to this contact");
        contact.requestInProgress = YES;
        [self.tblVuPhnContacts reloadRowsAtIndexPaths:[self.tblVuPhnContacts indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
        __weak typeof(self) weakSelf = self;
        PFUser *userObject = contact.matchedUserObject;
        [[C411AppDefaults sharedAppDefaults]sendFriendRequestToUser:userObject withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (succeeded) {
                
                ///Friend request is sent successfully
                ///Update status of contact
                contact.contactStatus = ContactStatusFriendRequestPending;
                
                
            }
            else if (error){
                
                ///Some error occured sending friend request to this user
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                }
                
                
            }
            else{
                
                ///there is no error but operation doesn't get succeeded, could be the case that user to whom friend request is being sent has spammed current user
                
                ///Show message that this user cannot be added as friend
                [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Sorry, we cannot send friend request to this user on your behalf", nil) onViewController:weakSelf];
                
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
