//
//  C411AlertSettings.h
//  cell411
//
//  Created by Milan Agarwal on 03/04/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface C411AlertSettings : NSObject

@property (nonatomic, strong) NSMutableDictionary *dictAlertAudiences;
@property (nonatomic, strong) NSString *strAdditionalNote;


+(instancetype)getAlertSettings;
+(void)removeSavedSettings;
-(void)saveSettings;
-(void)toggleAudienceSelection:(BOOL)shouldSelect forKey:(NSString *)strAudienceKey;
-(BOOL)isAudienceSelected:(NSString *)strAudienceKey;
-(NSArray *)getSelectedNauMembers;
-(void)updateSelectedNauMembers:(NSArray *)arrSelectedNauMembers;
-(NSDictionary *)getCellsSelectionData;
-(void)togglePrivateCellSelection:(BOOL)shouldSelect forCellId:(NSString *)strCellId;
-(void)togglePublicCellSelection:(BOOL)shouldSelect forCellId:(NSString *)strCellId;


@end
