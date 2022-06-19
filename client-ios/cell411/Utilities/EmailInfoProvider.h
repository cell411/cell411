//
//  EmailInfoProvider.h
//  UltimateSexTips
//
//  Created by Milan Agarwal on 10/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailInfoProvider : UIActivityItemProvider<UIActivityItemSource>

@property (nonatomic, strong) NSString *emailBody;
@property (nonatomic, strong) NSString *emailSubject;

@end
