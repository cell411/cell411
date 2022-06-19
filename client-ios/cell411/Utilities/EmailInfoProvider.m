//
//  EmailInfoProvider.m
//  UltimateSexTips
//
//  Created by Milan Agarwal on 10/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "EmailInfoProvider.h"

@implementation EmailInfoProvider

-(instancetype)initWithPlaceholderItem:(id)placeholderItem
{
   return [super initWithPlaceholderItem:placeholderItem];
}

-(id)item
{
    //Generates and returns the actual data object
    return self.emailBody;
}


//****************************************************
#pragma mark - UIAct
//****************************************************

//- Returns the data object to be acted upon. (required)
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType{
    
    return self.emailBody;
    
}

//- Returns the placeholder object for the data. (required)
//- The class of this object must match the class of the object you return from the above method
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController{
    
    return self.emailBody;
    
}


-(NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    
    if (activityType == UIActivityTypeMail) {
        
        return self.emailSubject;
    }
    
    return nil;
}

@end
