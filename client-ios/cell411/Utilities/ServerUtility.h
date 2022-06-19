//
//  ServerUtility.h
//  cell411
//
//  Created by Milan Agarwal on 26/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
@import CoreLocation;

typedef void (^C411WebServiceHandler)(NSError *error, id data);

@interface ServerUtility : NSObject

+(NSURLSessionDataTask *)getAddressForCoordinate:(NSString *)latlong andCompletion:(C411WebServiceHandler)completion;
+(NSURLSessionDataTask *)getDistanceAndDurationMatrixFromLocation:(NSString *)originLatlong toLocation:(NSString *)destLatlong andCompletion:(C411WebServiceHandler)completion;
+(NSURLSessionDataTask *)streamVideoToFBPageWithDetails:(NSDictionary *)dictStreamDetails andCompletion:(C411WebServiceHandler)completion;
+(NSString *)stringByAppendingParams:(NSDictionary *)dictParams toUrlString:(NSString *)strUrl;
+(NSDictionary *)getParamsFromUrl:(NSURL *)url;

+(NSURLSessionDataTask *)sendAlertToSecurityGuardsWithDetails:(NSDictionary *)dictAlertDetails andCompletion:(C411WebServiceHandler)completion;
+(NSURLSessionDataTask *)sendSms:(NSString *)strMessage onNumber:(NSString *)strContactNumber withCompletion:(C411WebServiceHandler)completion;
+(NSURLSessionDataTask *)uploadImage:(NSData *)imageData withType:(NSString *)strImageType imageName:(NSString *)strImageName forUserWithId:(NSString *)strUserId withCompletion:(C411WebServiceHandler)completion;
+(NSURLSessionDataTask *)getAppVersionsWithCompletion:(C411WebServiceHandler)completion;
+(NSURLSessionDataTask *)getOverpassAmenities:(NSArray *)arrAmenityType aroundLocation:(CLLocationCoordinate2D)locCoordinate withRadius:(NSInteger)radius andCompletion:(C411WebServiceHandler)completion;

#if NOTIFICATION_ACK_ENABLED
+(NSURLSessionDataTask *)sendAckForAlertNotificationWithDetails:(NSDictionary *)dictAlertAckDetails andCompletion:(C411WebServiceHandler)completion;
#endif

#if APP_IER
+(NSURLSessionDataTask *)postIERAlertWithDetails:(NSDictionary *)dictAlertDetails  andCompletion:(C411WebServiceHandler)completion;
+(NSURLSessionDataTask *)registerIERUserWithDetails:(NSDictionary *)dictRegDetails  andCompletion:(C411WebServiceHandler)completion;
+(NSURLSessionDataTask *)postIERPhotoAlert:(UIImage *)imgPhoto withDetails:(NSDictionary *)dictAlertDetails  andCompletion:(C411WebServiceHandler)completion;
+(NSURLSessionDataTask *)updateIERUserWithDetails:(NSDictionary *)dictUserDetails  andCompletion:(C411WebServiceHandler)completion;

#endif


@end
