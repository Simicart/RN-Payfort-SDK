
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

}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(openPayfort:(NSDictionary *)indic createDialog:(RCTResponseSenderBlock)doneCallback createDialog:(RCTResponseSenderBlock)cancelCallback){
  onDoneClick = doneCallback;
  onCancelClick = cancelCallback;
  
  udidString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    data = [[NSDictionary alloc] initWithDictionary:indic];
    rootViewController = (UIViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    [self handleTokenString];
  });
}

- (void)handleTokenString{
  [self startLoadingData];
  
  NSMutableString *post = [NSMutableString string];
  [post appendString:data[@"request_phrase"]];
  [post appendFormat:@"access_code=%@", data[@"access_code"]];
  [post appendFormat:@"device_id=%@",  udidString];
  [post appendFormat:@"language=%@", @"en"];
  [post appendFormat:@"merchant_identifier=%@", data[@"merchant_identifier"]];
  [post appendFormat:@"service_command=%@", @"SDK_TOKEN"];
  [post appendString:data[@"request_phrase"]];
  
  [self requestTokenSDK:[self sha1Encode:post]];
}

- (void)requestTokenSDK:(NSString *)signature{
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
                         @"language": @"en",
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
}

- (void)openPayfort:(NSString *)sdkToken{
  [self stopLoadingData];
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

