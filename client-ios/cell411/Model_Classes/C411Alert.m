//
//  C411Alert.m
//  cell411
//
//  Created by Milan Agarwal on 21/02/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411Alert.h"
#import "C411StaticHelper.h"

@implementation C411Alert

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(NSMutableArray *)arrAudiences
{
    if(!_arrAudiences){
        
        _arrAudiences = [NSMutableArray array];
    }
    
    return _arrAudiences;
}

-(NSString *)strAlertType
{
    if(!_strAlertType || _strAlertType.length == 0){
        
        _strAlertType = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:self.alertType];
        
    }
    
    return _strAlertType;
}


@end
