//
//  ServerUtility.m
//  cell411
//
//  Created by Milan Agarwal on 26/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "ServerUtility.h"
#import "ConfigConstants.h"
#import "Constants.h"

#define FB_LIVE_BASEURL  @"http://"CNAME":81/"

@implementation ServerUtility

+(NSURLSessionDataTask *)getAddressForCoordinate:(NSString *)latlong andCompletion:(C411WebServiceHandler)completion
{
    
    NSDictionary *dictParams = @{
                                 @"latlng":latlong,
                                 @"sensor":@"false",
                                 @"key":GOOGLE_MAP_API_KEY
                                 };
    NSString *strReverseGeocodeUrl = @"https://maps.googleapis.com/maps/api/geocode/json";
    
    return [self createGETRequestWithParams:dictParams urlString:strReverseGeocodeUrl andCompletion:completion];

}

+(NSURLSessionDataTask *)getDistanceAndDurationMatrixFromLocation:(NSString *)originLatlong toLocation:(NSString *)destLatlong andCompletion:(C411WebServiceHandler)completion
{
    
    NSDictionary *dictParams = @{@"origins":originLatlong,
                                 @"destinations":destLatlong,
                                 @"key":GOOGLE_MAP_API_KEY};
    NSString *strDistanceMatrixUrl = @"https://maps.googleapis.com/maps/api/distancematrix/json";
    
    return [self createGETRequestWithParams:dictParams urlString:strDistanceMatrixUrl andCompletion:completion];
    
    
}


+(NSURLSessionDataTask *)streamVideoToFBPageWithDetails:(NSDictionary *)dictStreamDetails andCompletion:(C411WebServiceHandler)completion
{
    NSString *strStreamVideoToFBPageUrl =  [NSString stringWithFormat:@"%@%@",FB_LIVE_BASEURL,kStreamVideoToSocialMediaAPIName];
    NSString *strUrlWithParams = [self stringByAppendingParams:dictStreamDetails toUrlString:strStreamVideoToFBPageUrl];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = responseSerializer;
    NSString *strEncodedUrl = [strUrlWithParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"#m->\nParams = %@\nurl=%@\n<--#m",dictStreamDetails,strEncodedUrl);
    NSURLSessionDataTask *dataTask = [manager GET:strEncodedUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if(completion != NULL){
        
            completion(nil,responseObject);
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if(completion != NULL){
            
            completion(error,nil);
            
        }
        
    }];
    
    return dataTask;

}

+(NSURLSessionDataTask *)sendAlertToSecurityGuardsWithDetails:(NSDictionary *)dictAlertDetails andCompletion:(C411WebServiceHandler)completion
{
    NSString *strSendAlertToPortalUrl = [API_BASE_URL stringByAppendingString:ALERT_PORTAL_USERS_API_NAME_BROADCAST_ALERT];
    return [self createPOSTRequestWithParams:dictAlertDetails urlString:strSendAlertToPortalUrl andCompletion:completion];

}

+(NSURLSessionDataTask *)sendSms:(NSString *)strMessage onNumber:(NSString *)strContactNumber withCompletion:(C411WebServiceHandler)completion
{
    
    NSString *sendSmsUrl = [@"https://api.twilio.com/2010-04-01/Accounts/AC609064e9cc0a511809e057d4f775f5ff/Messages.json" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"AC609064e9cc0a511809e057d4f775f5ff" password:@"518adab466eb6e40865fce7aa6422ff6"];
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    [dictParams setObject:strMessage forKey:@"Body"];
    [dictParams setObject:strContactNumber forKey:@"To"];
    [dictParams setObject:@"+12136994111" forKey:@"From"];
    
    return [manager POST:sendSmsUrl parameters:dictParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if(completion != NULL){
            
            completion(nil,responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if(completion != NULL){
            
            completion(error,nil);
        }
        
    }];
    
    
    
}

+(NSURLSessionDataTask *)uploadImage:(NSData *)imageData withType:(NSString *)strImageType imageName:(NSString *)strImageName forUserWithId:(NSString *)strUserId withCompletion:(C411WebServiceHandler)completion
{
    NSString *strModeType = @"";
#if DEBUG
    strModeType = MODE_TYPE_DEV;
#else
    strModeType = MODE_TYPE_PROD;

#endif
    
    NSString *strUserIdWithImageName = [strUserId stringByAppendingString:strImageName];
    NSDictionary *dictParams = @{UPDATE_PIC_API_PARAM_USER_ID:strUserIdWithImageName,
                                 UPDATE_PIC_API_PARAM_IMAGE_TYPE:strImageType,
                                 UPDATE_PIC_API_PARAM_MODE:strModeType,
                                 UPDATE_PIC_API_PARAM_APP_ID:CLIENT_FIRM_ID
                                 };
    NSString *strUpdatePicUrl = [API_BASE_URL stringByAppendingString:API_NAME_UPDATE_PIC];
    NSString *strUrlWithParams = [self stringByAppendingParams:dictParams toUrlString:strUpdatePicUrl];
    NSString *strEncodedUrl = [strUrlWithParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *uploadImageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strEncodedUrl]];
    [uploadImageRequest setHTTPMethod:@"PUT"];
    [uploadImageRequest addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    [uploadImageRequest setHTTPBody:imageData];
    
    [NSURLConnection sendAsynchronousRequest:uploadImageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (completion != NULL) {
           
            id jsonData = nil;
            if (data && ![data isKindOfClass:[NSNull class]]) {
               
                NSError *error = nil;
                jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
            }
        
            completion(connectionError,jsonData);
        }
        
        
    }];

/*
    NSDictionary *dictBody = @{@"Body":imageData};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    return [manager POST:strEncodedUrl parameters:dictBody progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
 
        completion(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        completion(error,nil);
    }];
*/
    
    return nil;
    
}

+(NSURLSessionDataTask *)getAppVersionsWithCompletion:(C411WebServiceHandler)completion
{
    
    NSString *strAppVersionsUrl = [API_BASE_URL stringByAppendingString:APP_VERSION_API_NAME];
    NSDictionary *dictParams = @{API_PARAM_PLATFORM:API_PLATFORM_VALUE,
                                 API_PARAM_APP_ID:CLIENT_FIRM_ID};
    return [self createGETRequestWithParams:dictParams urlString:strAppVersionsUrl andCompletion:completion];
    
    
}

+(NSURLSessionDataTask *)getOverpassAmenities:(NSArray *)arrAmenityType aroundLocation:(CLLocationCoordinate2D)locCoordinate withRadius:(NSInteger)radius andCompletion:(C411WebServiceHandler)completion {
    
    ///Contruct the data statement to pass as data param value
    NSString *strBBox = [NSString stringWithFormat:@"(around:%d,%f,%f);",(int)radius, locCoordinate.latitude, locCoordinate.longitude];
    NSMutableString *strDataValue = [NSMutableString stringWithString:kOverpassAPIStatementOut];
    [strDataValue appendString:@"("];
    for (NSString *strAmenityType in arrAmenityType) {
        [strDataValue appendFormat:kOverpassAPIStatementNodeWithDynamicAmenity,strAmenityType];
        [strDataValue appendString:strBBox];
    }
    [strDataValue appendString:@");"];
    [strDataValue appendString:kOverpassAPIStatementOutMeta];
    NSDictionary *dictParams = @{kOverpassAPIParamData: strDataValue};
     return [self createGETRequestWithParams:dictParams urlString:kOverpassAPIBaseURL andCompletion:completion];
}

#if NOTIFICATION_ACK_ENABLED
+(NSURLSessionDataTask *)sendAckForAlertNotificationWithDetails:(NSDictionary *)dictAlertAckDetails andCompletion:(C411WebServiceHandler)completion
{
    NSString *strSendAlertAckUrl = [API_BASE_URL stringByAppendingString:ACK_RECEIVED_ALERT_API_NAME];
    return [self createPOSTRequestWithParams:dictAlertAckDetails urlString:strSendAlertAckUrl andCompletion:completion];
    
}
#endif

#if APP_IER

+(NSURLSessionDataTask *)postIERAlertWithDetails:(NSDictionary *)dictAlertDetails  andCompletion:(C411WebServiceHandler)completion
{
    /*LMA_INTEGRATION
    return [self callIERAPIEndpointWithId:LMA_ALERT_API_ID apiKey:LMA_ALERT_API_KEY apiParams:dictAlertDetails andCompletion:completion];
    */
    NSString *strSendIERAlertsUrl = [IER_API_BASE_URL stringByAppendingString:IER_API_NAME_ALERT];
    return [self createPOSTRequestWithParams:dictAlertDetails urlString:strSendIERAlertsUrl andCompletion:completion];
}

+(NSURLSessionDataTask *)postIERPhotoAlert:(UIImage *)imgPhoto withDetails:(NSDictionary *)dictAlertDetails  andCompletion:(C411WebServiceHandler)completion
{
    /*LMA_INTEGRATION
     return [self callIERAPIEndpointWithId:LMA_ALERT_API_ID apiKey:LMA_ALERT_API_KEY apiParams:dictAlertDetails andCompletion:completion];
     */
    NSString *strSendIERAlertsUrl = [@"http://api.affinityhealth.co.za/api/ier/" stringByAppendingString:@"photoAlert"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.removesKeysWithNullValues = YES;
    manager.responseSerializer = responseSerializer;
    
    NSString *strEncodedUrl = [strSendIERAlertsUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    NSDictionary *dictParams = @{@"User_ID":@"UxVyqnATHJ",@"First_Name":@"Milan",@"Surname":@"Agarwal",@"Contact_Email":@"agarwal.milan.apps@gmail.com",@"Contact_Mobile":@"917827289043",@"emergency_contact":@"",@"emergency_number":@"",@"blood_group":@"B+",@"allergies":@"",@"conditions":@""};
    
    UIImage *img = [UIImage imageNamed:@"default_marker"];
    NSURLSessionDataTask *dataTask = [manager POST:strEncodedUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFormData:[@"UxVyqnATHJ" dataUsingEncoding:NSUTF8StringEncoding] name:@"User_ID"];
        [formData appendPartWithFormData:[@"Photo" dataUsingEncoding:NSUTF8StringEncoding] name:@"Alert_Type"];
        [formData appendPartWithFormData:[@"28.628454,77.376945" dataUsingEncoding:NSUTF8StringEncoding] name:@"Geo_location"];
        [formData appendPartWithFileData:UIImageJPEGRepresentation(img, 0.5) name:@"File" fileName:@"File.jpg" mimeType:@"image/jpeg"];
        
        
        
    } progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"Success Image: %@",responseObject);
        
        if (completion != NULL) {
            
            completion(nil,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"Error: %@",error);
        
        if (completion != NULL) {
            
            completion(error,nil);
        }
    }];
    
    return dataTask;
    
    
}

+(NSURLSessionDataTask *)registerIERUserWithDetails:(NSDictionary *)dictRegDetails  andCompletion:(C411WebServiceHandler)completion
{
    /*LMA_INTEGRATION
     return [self callIERAPIEndpointWithId:LMA_REG_API_ID apiKey:LMA_REG_API_KEY apiParams:dictRegDetails andCompletion:completion];
    */
    
    NSString *strRegisterIERUserUrl = [IER_API_BASE_URL stringByAppendingString:IER_API_NAME_REG];
    return [self createPOSTRequestWithParams:dictRegDetails urlString:strRegisterIERUserUrl andCompletion:completion];

    
}

+(NSURLSessionDataTask *)updateIERUserWithDetails:(NSDictionary *)dictUserDetails  andCompletion:(C411WebServiceHandler)completion
{
    /*LMA_INTEGRATION
     return [self callIERAPIEndpointWithId:LMA_REG_API_ID apiKey:LMA_REG_API_KEY apiParams:dictRegDetails andCompletion:completion];
     */
    
    NSString *strUpdateIERUserUrl = [IER_API_BASE_URL stringByAppendingString:IER_API_NAME_UPDATE_PROFILE];
    return [self createPOSTRequestWithParams:dictUserDetails urlString:strUpdateIERUserUrl andCompletion:completion];
    
    
}


/*LMA_INTEGRATION
 +(NSURLSessionDataTask *)callIERAPIEndpointWithId:(NSString *)strApiId apiKey:(NSString *)strApiKey apiParams:(NSDictionary *)dictApiParams andCompletion:(C411WebServiceHandler)completion
{
    NSString *strIERApiUrl=[LMA_API_BASE_URL stringByAppendingString:strApiId];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.removesKeysWithNullValues = YES;
    manager.responseSerializer = responseSerializer;
    [manager.requestSerializer setValue:strApiKey forHTTPHeaderField:LMA_API_HEADER_NDX_KEY];
    NSString *strEncodedUrl = [strIERApiUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [manager POST:strEncodedUrl parameters:dictApiParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        completion(nil,responseObject);
        //NSLog(@"Success: %@", responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        completion(error,nil);
        NSLog(@"Error: %@", error);
        
    }];
    
    return dataTask;
    
    
}
*/

#endif


//****************************************************
#pragma mark - Helper Method for POST and GET request
//****************************************************


+(NSURLSessionDataTask *)createPOSTRequestWithParams:(NSDictionary *)dictParams urlString:(NSString *)strUrl andCompletion:(C411WebServiceHandler)completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.removesKeysWithNullValues = YES;
    manager.responseSerializer = responseSerializer;
    
    NSString *strEncodedUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [manager POST:strEncodedUrl parameters:dictParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if(completion != NULL){
            
            completion(nil,responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if(completion != NULL){
            
            completion(error,nil);
        }
    }];
    
    return dataTask;
}

+(NSURLSessionDataTask *)createGETRequestWithParams:(NSDictionary *)dictParams urlString:(NSString *)strUrl andCompletion:(C411WebServiceHandler)completion
{
    NSString *strUrlWithParams = [self stringByAppendingParams:dictParams toUrlString:strUrl];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.removesKeysWithNullValues = YES;
    manager.responseSerializer = responseSerializer;
    NSString *strEncodedUrl = [strUrlWithParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [manager GET:strEncodedUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        if(completion != NULL){
            
            completion(nil,responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if(completion != NULL){
            
            completion(error,nil);
        }

    }];
    
    return dataTask;
}

+(NSString *)stringByAppendingParams:(NSDictionary *)dictParams toUrlString:(NSString *)strUrl
{
    if (strUrl.length > 0) {
        
        NSMutableString *strUrlWithParams = [NSMutableString stringWithString:strUrl];
        if (dictParams.count > 0) {
            ///Append ? for first param
            [strUrlWithParams appendString:@"?"];
            
            for (id paramName in [dictParams allKeys]) {
                
                ///Get value associated to param name
                id paramVal = [dictParams objectForKey:paramName];
                
                ///Append Param
                [strUrlWithParams appendFormat:@"%@=%@&",paramName,paramVal];
            }
            
            ///Remove & from last
            NSRange lastCharRange = NSMakeRange(strUrlWithParams.length - 1, 1);
            [strUrlWithParams deleteCharactersInRange:lastCharRange];
            
        }
        
        return strUrlWithParams;
    }
    
    return nil;
}

+(NSDictionary *)getParamsFromUrl:(NSURL *)url
{
    NSString *strUrl = [url absoluteString];
    NSMutableDictionary *dictParams = nil;

    NSArray *arrUrlParts = [strUrl componentsSeparatedByString:@"?"];
    if (arrUrlParts.count == 2) {
        
        NSString *strParamsPart = arrUrlParts[1];
        NSArray *arrParams = [strParamsPart componentsSeparatedByString:@"&"];
            dictParams = [NSMutableDictionary dictionary];
            
            for (NSString *strKeyValuePair in arrParams) {
                
                NSArray *arrKeyValuePair = [strKeyValuePair componentsSeparatedByString:@"="];
                
                if (arrKeyValuePair.count == 2) {
                    
                    dictParams[arrKeyValuePair[0]] = arrKeyValuePair[1];
                    
                }
                
                
                
            }
            
     }
    
    return dictParams;
}

@end
