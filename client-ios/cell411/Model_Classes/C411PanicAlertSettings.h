//
//  C411PanicAlertSettings.h
//  cell411
//
//  Created by Milan Agarwal on 17/08/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface C411PanicAlertSettings : NSObject

@property (nonatomic, assign) NSInteger waitTime;
@property (nonatomic, strong) NSMutableDictionary *dictAlertRecipients;
@property (nonatomic, strong) NSString *strAdditionalNote;


+(instancetype)getPanicAlertSettings;
+(void)removeSavedSettings;
-(void)saveSettings;

@end
