//
//  C411PanicAlertSettings.m
//  cell411
//
//  Created by Milan Agarwal on 17/08/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411PanicAlertSettings.h"
#import "C411Enums.h"
#import "Constants.h"

@implementation C411PanicAlertSettings

//****************************************************
#pragma mark - NSCoder implementation
//****************************************************


NSString *const kCoderKey_waitTime = @"waitTime";
NSString *const kCoderKey_dictAlertRecipients = @"dictAlertRecipients";
NSString *const kCoderKey_strAdditionalNote = @"strAdditionalNote";

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:@(self.waitTime) forKey:kCoderKey_waitTime];
    [encoder encodeObject:self.dictAlertRecipients forKey:kCoderKey_dictAlertRecipients];
    [encoder encodeObject:self.strAdditionalNote forKey:kCoderKey_strAdditionalNote];
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.waitTime = [[aDecoder decodeObjectForKey:kCoderKey_waitTime]integerValue];
    self.dictAlertRecipients = [aDecoder decodeObjectForKey:kCoderKey_dictAlertRecipients];
    self.strAdditionalNote = [aDecoder decodeObjectForKey:kCoderKey_strAdditionalNote];
    return self;
}

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

///Override the init method to set default settings
-(instancetype)init
{
    if (self = [super init]) {
                
        self.waitTime = PanicWaitTime5Sec;
        
        ///select all friends by default
        NSMutableDictionary *dictSelectedOption = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(YES),kPanicAlertRecipientIsSelectedKey, nil];
        [self.dictAlertRecipients setObject:dictSelectedOption forKey:kPanicAlertRecipientAllFriendsKey];
    }
    
    return self;
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(NSMutableDictionary *)dictAlertRecipients
{
    if (!_dictAlertRecipients) {
        
        _dictAlertRecipients = [NSMutableDictionary dictionary];
    }
    
    return _dictAlertRecipients;
}

//****************************************************
#pragma mark - Private Methods
//****************************************************



-(NSData *)archive
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+(instancetype)unarchiveWithData:(NSData *)data
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}


//****************************************************
#pragma mark - Public Methods
//****************************************************

+(instancetype)getPanicAlertSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *panicAlertSettingsData = [defaults objectForKey:kPanicAlertSettings];
    if (panicAlertSettingsData) {
        ///get panic alert settings saved in user defaults
        C411PanicAlertSettings *panicAlertSettings = [self unarchiveWithData:panicAlertSettingsData];
        return panicAlertSettings;
        
    }
    else{
        ///Get the default panic alert settings object
        C411PanicAlertSettings *panicAlertSettings = [[C411PanicAlertSettings alloc]init];
        
        
        return panicAlertSettings;

    }
}

+(void)removeSavedSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kPanicAlertSettings];
    [defaults synchronize];
}

-(void)saveSettings
{
    NSData *panicAlertSettingsData = [self archive];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:panicAlertSettingsData forKey:kPanicAlertSettings];
    [defaults synchronize];
    
}


@end
