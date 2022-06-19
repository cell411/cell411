//
//  C411AlertSettings.m
//  cell411
//
//  Created by Milan Agarwal on 03/04/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411AlertSettings.h"
#import "C411Enums.h"
#import "Constants.h"
#import "C411AppDefaults.h"

@implementation C411AlertSettings

//****************************************************
#pragma mark - NSCoder implementation
//****************************************************

NSString *const kCoderKey_dictAlertAudiences = @"dictAlertAudiences";
NSString *const kCoderKey_strAlertAdditionalNote = @"strAlertAdditionalNote";

- (void)encodeWithCoder:(NSCoder *)encoder
{
   [encoder encodeObject:self.dictAlertAudiences forKey:kCoderKey_dictAlertAudiences];
    [encoder encodeObject:self.strAdditionalNote forKey:kCoderKey_strAlertAdditionalNote];
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.dictAlertAudiences = [aDecoder decodeObjectForKey:kCoderKey_dictAlertAudiences];
    self.strAdditionalNote = [aDecoder decodeObjectForKey:kCoderKey_strAlertAdditionalNote];
    return self;
}

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

///Override the init method to set default settings
-(instancetype)init
{
    if (self = [super init]) {
        
        ///Set default settings
        NSMutableDictionary *dictSelectedOption = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(YES),kAlertAudienceIsSelectedKey, nil];
        [self.dictAlertAudiences setObject:dictSelectedOption forKey:kAlertAudienceFamilyKey];
        [self.dictAlertAudiences setObject:dictSelectedOption forKey:kAlertAudienceFriendsKey];
        [self.dictAlertAudiences setObject:dictSelectedOption forKey:kAlertAudienceNeighboursKey];
        if([C411AppDefaults canShowSecurityGuardOption]){
            [self.dictAlertAudiences setObject:dictSelectedOption forKey:kAlertAudienceCallCentreKey];
        }
        ///All public and private cells will be selected by default
        NSMutableDictionary *dictAllSelectedOption = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(YES),kAlertAudienceIsAllSelectedKey, nil];
        
        NSMutableDictionary *dictCellsSettings = [NSMutableDictionary dictionary];
        [dictCellsSettings setObject:@(YES) forKey:kAlertAudienceIsSelectedKey];
        [dictCellsSettings setObject:dictAllSelectedOption forKey:kAlertAudienceCellsPrivateCellsKey];
        [dictCellsSettings setObject:dictAllSelectedOption forKey:kAlertAudienceCellsPublicCellsKey];
        [self.dictAlertAudiences setObject:dictCellsSettings forKey:kAlertAudienceCellsKey];
    }
    
    return self;
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(NSMutableDictionary *)dictAlertAudiences
{
    if (!_dictAlertAudiences) {
        
        _dictAlertAudiences = [NSMutableDictionary dictionary];
    }
    
    return _dictAlertAudiences;
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

+(instancetype)getAlertSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *alertSettingsData = [defaults objectForKey:kAlertSettings];
    if (alertSettingsData) {
        ///get alert settings saved in user defaults
        C411AlertSettings *alertSettings = [self unarchiveWithData:alertSettingsData];
        return alertSettings;
    }
    else{
        ///Get the default panic alert settings object
        C411AlertSettings *alertSettings = [[C411AlertSettings alloc]init];
        return alertSettings;
    }
}

+(void)removeSavedSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kAlertSettings];
    [defaults synchronize];
}

-(void)saveSettings
{
    NSData *alertSettingsData = [self archive];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:alertSettingsData forKey:kAlertSettings];
    [defaults synchronize];
}

-(void)toggleAudienceSelection:(BOOL)shouldSelect forKey:(NSString *)strAudienceKey
{
    NSMutableDictionary *dictAudience = [self.dictAlertAudiences[strAudienceKey] mutableCopy];
    if(!dictAudience){
        
        dictAudience = [NSMutableDictionary dictionary];
    }
    dictAudience[kAlertAudienceIsSelectedKey] = @(shouldSelect);
    self.dictAlertAudiences[strAudienceKey] = dictAudience;
    [self saveSettings];
    
}

-(BOOL)isAudienceSelected:(NSString *)strAudienceKey
{
    NSDictionary *dictAudience = self.dictAlertAudiences[strAudienceKey];
    return [dictAudience[kAlertAudienceIsSelectedKey]boolValue];
    
}

-(NSArray *)getSelectedNauMembers
{
    NSDictionary *dictNauAudience = self.dictAlertAudiences[kAlertAudienceNauKey];
    return dictNauAudience[kAlertAudienceSelectedNauMembersKey];
}

-(void)updateSelectedNauMembers:(NSArray *)arrSelectedNauMembers
{
    NSMutableDictionary *dictNauAudience = [self.dictAlertAudiences[kAlertAudienceNauKey] mutableCopy];
    if(!dictNauAudience){
        
        dictNauAudience = [NSMutableDictionary dictionary];
    }
    
    dictNauAudience[kAlertAudienceSelectedNauMembersKey] = arrSelectedNauMembers ? arrSelectedNauMembers : [NSArray array];
    self.dictAlertAudiences[kAlertAudienceNauKey] = dictNauAudience;
    [self saveSettings];

}

-(NSDictionary *)getCellsSelectionData
{
    return self.dictAlertAudiences[kAlertAudienceCellsKey];
}

-(void)togglePrivateCellSelection:(BOOL)shouldSelect forCellId:(NSString *)strCellId
{
    if(strCellId.length > 0){
        NSMutableDictionary *dictCellsAudience = [self.dictAlertAudiences[kAlertAudienceCellsKey] mutableCopy];
        NSMutableDictionary *dictPrivateCells = [dictCellsAudience[kAlertAudienceCellsPrivateCellsKey] mutableCopy];
        if(!dictPrivateCells){
            dictPrivateCells = [NSMutableDictionary dictionary];
        }
        
        NSMutableDictionary *dictDeselectedPrivateCells = [dictPrivateCells[kAlertAudienceDeselectedCellsKey]mutableCopy];
        if(!dictDeselectedPrivateCells){
            dictDeselectedPrivateCells = [NSMutableDictionary dictionary];
        }
        
        if(shouldSelect){
            ///Remove it from filtered dictionary of unselected cells
            [dictDeselectedPrivateCells removeObjectForKey:strCellId];
        }
        else{
            ///Add it to filtered dictionary of unselected cells
            dictDeselectedPrivateCells[strCellId] = @(YES);
        }
        
        dictPrivateCells[kAlertAudienceDeselectedCellsKey] = dictDeselectedPrivateCells;
        dictCellsAudience[kAlertAudienceCellsPrivateCellsKey] = dictPrivateCells;
        self.dictAlertAudiences[kAlertAudienceCellsKey] = dictCellsAudience;
        [self saveSettings];
    }
}

-(void)togglePublicCellSelection:(BOOL)shouldSelect forCellId:(NSString *)strCellId
{
    if(strCellId.length > 0){
        NSMutableDictionary *dictCellsAudience = [self.dictAlertAudiences[kAlertAudienceCellsKey] mutableCopy];
        NSMutableDictionary *dictPublicCells = [dictCellsAudience[kAlertAudienceCellsPublicCellsKey] mutableCopy];
        if(!dictPublicCells){
            dictPublicCells = [NSMutableDictionary dictionary];
        }
        
        NSMutableDictionary *dictDeselectedPublicCells = [dictPublicCells[kAlertAudienceDeselectedCellsKey]mutableCopy];
        if(!dictDeselectedPublicCells){
            dictDeselectedPublicCells = [NSMutableDictionary dictionary];
        }
        
        if(shouldSelect){
            ///Remove it from filtered dictionary of unselected cells
            [dictDeselectedPublicCells removeObjectForKey:strCellId];
        }
        else{
            ///Add it to filtered dictionary of unselected cells
            dictDeselectedPublicCells[strCellId] = @(YES);
        }
        
        dictPublicCells[kAlertAudienceDeselectedCellsKey] = dictDeselectedPublicCells;
        dictCellsAudience[kAlertAudienceCellsPublicCellsKey] = dictPublicCells;
        self.dictAlertAudiences[kAlertAudienceCellsKey] = dictCellsAudience;
        [self saveSettings];
    }
}

@end
