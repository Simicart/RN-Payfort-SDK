
#import "RNReactNativePayfortSdk.h"
#include <CommonCrypto/CommonDigest.h>

@implementation RNReactNativePayfortSdk{
    RCTResponseSenderBlock onDoneClick;
    RCTResponseSenderBlock onCancelClick;
    NSDictionary *data;
    PayFortController *payfort;
    UIViewController *rootViewController;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(openPayfort:(NSDictionary *)indic createDialog:(RCTResponseSenderBlock)doneCallback createDialog:(RCTResponseSenderBlock)cancelCallback){
    onDoneClick = doneCallback;
    onCancelClick = cancelCallback;
    data = [[NSDictionary alloc] initWithDictionary:indic];
    
    [self handleTokenString];
}

- (void)handleTokenString{
    dispatch_async(dispatch_get_main_queue(), ^{
        rootViewController = (UIViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    });
    
    NSMutableString *post = [NSMutableString string];
    [post appendString:data[@"request_phrase"]];
    [post appendFormat:@"access_code=%@", data[@"access_code"]];
    [post appendFormat:@"device_id=%@",  [payfort getUDID ]];
    [post appendFormat:@"language=%@", @"en"];
    [post appendFormat:@"merchant_identifier=%@", data[@"merchant_identifier"]];
    [post appendFormat:@"service_command=%@", @"SDK_TOKEN"];
    [post appendString:data[@"request_phrase"]];
    
    [self requestTokenSDK:[self sha1Encode:post]];
}

- (void)requestTokenSDK:(NSString *)signature{
    NSError *error;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"https://sbpaymentservices.payfort.com/FortAPI/paymentApi"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"SDK_TOKEN", @"service_command",
                             data[@"access_code"], @"access_code",
                             data[@"merchant_identifier"], @"merchant_identifier",
                             @"en", @"language",
                             [payfort getUDID], @"device_id",
                             signature, @"signature",
                             
                             nil];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            
        } else {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            [self openPayfort:responseDictionary[@"sdk_token"]];
        }
    }];
    [postDataTask resume];
}

- (void)openPayfort:(NSString *)sdkToken{
    NSMutableDictionary *request = [[NSMutableDictionary alloc]init];
    [request setValue:data[@"amount"] forKey:@"amount"];
    [request setValue:data[@"currency"] forKey:@"currency"];
    [request setValue:data[@"customer_email"] forKey:@"customer_email"];
    [request setValue:data[@"customer_name"] forKey:@"customer_name"];
    [request setValue:data[@"customer_ip"] forKey:@"customer_ip"];
    [request setValue:data[@"merchant_reference"] forKey:@"merchant_reference"];
    [request setValue:sdkToken forKey:@"sdk_token"];
    [request setValue:@"PURCHASE" forKey:@"command"];
    [request setValue:@"en" forKey:@"language"];
    [request setValue:@"VISA" forKey:@"payment_option"];
    [request setValue:@"ECOMMERCE" forKey:@"eci"];
    
    payfort = [[PayFortController alloc] initWithEnviroment:KPayFortEnviromentSandBox];
    payfort.IsShowResponsePage = true;
    
    NSArray *events = @[];
    [payfort callPayFortWithRequest:request currentViewController:rootViewController
                            Success:^(NSDictionary *requestDic, NSDictionary *responeDic) {
                                NSLog(@"Success");
                                NSLog(@"responeDic=%@",responeDic);
                                onDoneClick(@[[NSNull null], events]);
                            }
                           Canceled:^(NSDictionary *requestDic, NSDictionary *responeDic) {
                               NSLog(@"Canceled");
                               NSLog(@"responeDic=%@",responeDic);
                               onCancelClick(@[[NSNull null], events]);
                           }
                              Faild:^(NSDictionary *requestDic, NSDictionary *responeDic, NSString *message) {
                                  NSLog(@"Faild");
                                  NSLog(@"responeDic=%@",responeDic);
                              }];
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


@end

