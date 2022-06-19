//
//  C411Audience.h
//  cell411
//
//  Created by Milan Agarwal on 21/02/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "C411Enums.h"
@class PFObject;

@interface C411Audience : NSObject

@property (nonatomic, assign) AudienceType audienceType;
@property (nonatomic, strong) NSArray *arrMembers;

///Will hold a valid value if AudienceType is either AudienceTypePrivateCellMembers or AudienceTypePublicCellMembers
@property (nonatomic, strong) PFObject *audienceCell;

@end
