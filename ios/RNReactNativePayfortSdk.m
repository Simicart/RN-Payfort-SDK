
#import "RNReactNativePayfortSdk.h"
#include <CommonCrypto/CommonDigest.h>

@implementation RNReactNativePayfortSdk{
    RCTResponseSenderBlock onDoneClick;
    RCTResponseSenderBlock onCancelClick;
    NSDictionary *data;
    PayFortController *payfort;
    UIViewController *rootViewController;
    UIActivityIndicatorView *simiLoading;
    NSString *udidString;
    NSString *signatureString;

}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE(RNReactNativePayfortSdk);

RCT_EXPORT_METHOD(openPayfort:(NSDictionary *)indic createDialog:(RCTResponseSenderBlock)doneCallback createDialog:(RCTResponseSenderBlock)cancelCallback) {
    onDoneClick = doneCallback;
    onCancelClick = cancelCallback;
    
    udidString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        data = [[NSDictionary alloc] initWithDictionary:indic];
        rootViewController = (UIViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
        //    [self handleTokenString];
        NSString *sdk_token = @"";
        [self openPayfort:sdk_token];
        
    });
}

- (void)handleTokenString{
    [self startLoadingData];
    
    NSMutableString *post = [NSMutableString string];
    [post appendString:data[@"request_phrase"]];
    [post appendFormat:@"access_code=%@", data[@"access_code"]];
    [post appendFormat:@"device_id=%@",  udidString];
    [post appendFormat:@"language=%@", data[@"language"]];
    [post appendFormat:@"merchant_identifier=%@", data[@"merchant_identifier"]];
    [post appendFormat:@"service_command=%@", @"SDK_TOKEN"];
    [post appendString:data[@"request_phrase"]];
    
    [self requestTokenSDK:[self sha1Encode:post]];
}

- (void)requestTokenSDK:(NSString *)signature{
    dispatch_async(dispatch_get_main_queue(), ^{
        signatureString = signature;
        NSError *error;
        NSURL *url;
        if ([data[@"is_live"] isEqualToString:@"1"]) {
            url = [NSURL URLWithString:@"https://paymentservices.payfort.com/FortAPI/paymentApi"];
        }else{
            url = [NSURL URLWithString:@"https://sbpaymentservices.payfort.com/FortAPI/paymentApi"];
        }
        
        NSDictionary* tmp = @{ @"service_command": @"SDK_TOKEN",
                               @"merchant_identifier": data[@"merchant_identifier"],
                               @"access_code": data[@"access_code"],
                               @"signature": signature,
                               @"language": data[@"language"],
                               @"device_id": udidString
                               };
        NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
        
        NSString *postLength = [NSString stringWithFormat:@"%ld",[postdata length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postdata];
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data,
                                                                                         NSURLResponse *response,
                                                                                         NSError *error)
                                      {
                                          if (!error)
                                          {
                                              NSError *error = nil;
                                              id object = [NSJSONSerialization
                                                           JSONObjectWithData:data
                                                           options:0
                                                           error:&error];
                                              NSLog(@"object %@",object);
                                              
                                              if(error) {
                                                  NSLog(@"Error %@",error);
                                                  return;
                                              }
                                              NSString *sdk_token = object[@"sdk_token"];
                                              [self openPayfort:sdk_token];
                                              
                                          }
                                          else
                                          {
                                              NSLog(@"Error: %@", error.localizedDescription);
                                          }
                                      }];
        [task resume];
    });
}

- (void)openPayfort:(NSString *)sdkToken{
    [self stopLoadingData];
    NSMutableDictionary *request = [[NSMutableDictionary alloc]init];
    
    if (data[@"amount"]) {
        [request setValue:data[@"amount"] forKey:@"amount"];
    }
    if (data[@"currency"]) {
        [request setValue:data[@"currency"] forKey:@"currency"];
    }
    if (data[@"customer_email"]) {
        [request setValue:data[@"customer_email"] forKey:@"customer_email"];
    }
    if (data[@"customer_name"]) {
        [request setValue:data[@"customer_name"] forKey:@"customer_name"];
    }
  
    if (data[@"merchant_reference"]) {
        [request setValue:data[@"merchant_reference"] forKey:@"merchant_reference"];
    }
    
    if (data[@"language"]) {
        [request setValue:data[@"language"] forKey:@"language"];
    }else{
        [request setValue:@"en" forKey:@"language"];
    }
    
    if (data[@"sdk_token"]) {
        [request setValue:data[@"sdk_token"] forKey:@"sdk_token"];
    }
    
    if (data[@"payment_option"]) {
        [request setValue:data[@"payment_option"] forKey:@"payment_option"];
    }else{
        [request setValue:@"" forKey:@"payment_option"];
    }
    
    [request setValue:@"PURCHASE" forKey:@"command"];
    [request setValue:@"ECOMMERCE" forKey:@"eci"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([data[@"is_live"] isEqualToString:@"1"]) {
            payfort = [[PayFortController alloc] initWithEnviroment:KPayFortEnviromentProduction];
        }else{
            payfort = [[PayFortController alloc] initWithEnviroment:KPayFortEnviromentSandBox];
        }
        payfort.IsShowResponsePage = true;
        
        NSArray *events = @[];
        [payfort callPayFortWithRequest:request currentViewController:rootViewController
                                Success:^(NSDictionary *requestDic, NSDictionary *responeDic) {
                                    //                              NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:responeDic];
                                    //                              [dic setValue:signatureString forKey:@"signature"];
                                    
                                    onDoneClick(@[responeDic, events]);
                                }
                               Canceled:^(NSDictionary *requestDic, NSDictionary *responeDic) {
                                   onCancelClick(@[@"cancel", events]);
                               }
                                  Faild:^(NSDictionary *requestDic, NSDictionary *responeDic, NSString *message) {
                                      onCancelClick(@[message, events]);
                                  }];
    });
}


- (NSString*)sha1Encode:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, (int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

- (void)startLoadingData{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect frame = rootViewController.view.bounds;
        simiLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        simiLoading.hidesWhenStopped = YES;
        simiLoading.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [rootViewController.view addSubview:simiLoading];
        rootViewController.view.userInteractionEnabled = NO;
        [simiLoading startAnimating];
        rootViewController.view.alpha = 0.5;
    });
}

- (void)stopLoadingData{
    dispatch_async(dispatch_get_main_queue(), ^{
        rootViewController.view.userInteractionEnabled = YES;
        rootViewController.view.alpha = 1;
        [simiLoading stopAnimating];
        [simiLoading removeFromSuperview];
    });
}


@end

