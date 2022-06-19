//
//  C411CountrySelectionVC.h
//  cell411
//
//  Created by Milan Agarwal on 09/06/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  C411CountrySelectionVC;
@class MA_Country;

@protocol C411CountrySelectionVCDelegate <NSObject>

-(void)countrySelectionVC:(C411CountrySelectionVC *)countrySelectionVC didSelectCountry:(MA_Country *)country;

@end

@interface C411CountrySelectionVC : UIViewController

@property (nonatomic, strong) NSString *selectedCountryName;
@property (nonatomic, assign)id<C411CountrySelectionVCDelegate> delegate;

@end
