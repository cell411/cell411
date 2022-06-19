//
//  C411CountrySelectionVC.m
//  cell411
//
//  Created by Milan Agarwal on 09/06/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411CountrySelectionVC.h"
#import "MA_Country.h"
#import "UITableView+RemoveTopPadding.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411CountrySelectionVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblVuCountries;
@property (nonatomic, strong)NSArray *arrCountries;

@property (nonatomic, assign, getter=shouldHideNavBar) BOOL hideNavBar;

@end

@implementation C411CountrySelectionVC



//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ///Remove top padding of 15 pixel
    [self.tblVuCountries removeTopPadding];
    self.tblVuCountries.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    [self applyColors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.selectedCountryName = nil;
    self.delegate = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        
        ///Navigation bar is initially hidden so unhide it and save it's state to hide it again when going back
        self.hideNavBar = YES;
        
        self.navigationController.navigationBarHidden = NO;

        
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (self.shouldHideNavBar) {
        
        ///Hide the navigation bar again as it was initially hidden
        self.navigationController.navigationBarHidden = YES;

    }
    
    [super viewWillDisappear:animated];
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


-(NSArray *)arrCountries
{
    if (!_arrCountries) {
        
        NSArray *arrCountries = [MA_Country getListOfAllCountries];
        
        ///Sort countries alphabetically
        NSSortDescriptor *sortCountryByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        
        _arrCountries = [arrCountries sortedArrayUsingDescriptors:@[sortCountryByName]];
        
    }
    
    return _arrCountries;
}

//****************************************************
#pragma mark - Private Methods
//****************************************************
-(void)applyColors {
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
}

-(void)registerForNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//****************************************************
#pragma mark - UITableView Delegate And Datasource Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrCountries.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellId = @"C411CountryCell";
    UITableViewCell *countryCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!countryCell) {
        
        countryCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        countryCell.backgroundColor = [UIColor clearColor];
    }
    countryCell.tintColor = [C411ColorHelper sharedInstance].themeColor;
    MA_Country *country = [self.arrCountries objectAtIndex:indexPath.row];
    
    if (!country.flag) {
        country.flag = [UIImage imageNamed:country.isoCode.lowercaseString];
    }
    
    countryCell.imageView.image = country.flag;
    
    NSString *strCountryName = NSLocalizedString(country.name, nil);
    NSString *strCountryNameAndCode = [NSString stringWithFormat:@"%@ (+%@)",strCountryName,country.dialingCode];
    countryCell.textLabel.text = strCountryNameAndCode;
    countryCell.textLabel.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    if ((self.selectedCountryName) && ([country.name isEqualToString:self.selectedCountryName])) {
        
        countryCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        
        countryCell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    return countryCell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MA_Country *country = [self.arrCountries objectAtIndex:indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(countrySelectionVC:didSelectCountry:)]) {
        [self.delegate countrySelectionVC:self didSelectCountry:country];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
    [self.tblVuCountries reloadData];
}


@end
