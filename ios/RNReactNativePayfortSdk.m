
#import "RNReactNativePayfortSdk.h"

@implementation RNReactNativePayfortSdk{
    RCTResponseSenderBlock onDoneClick;
    RCTResponseSenderBlock onCancelClick;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(openPayfort:(NSDictionary *)indic createDialog:(RCTResponseSenderBlock)doneCallback createDialog:(RCTResponseSenderBlock)cancelCallback){
    onDoneClick = doneCallback;
    onCancelClick = cancelCallback;
    
    PayFortController *payfort = [[PayFortController alloc] initWithEnviroment:KPayFortEnviromentSandBox];
    payfort.IsShowResponsePage = true;
    NSLog(@"%@", [payfort getUDID]);
    NSMutableDictionary *request = [[NSMutableDictionary alloc]init];
    [request setValue:indic[@"amount"] forKey:@"amount"];
    [request setValue:indic[@"currency"] forKey:@"currency"];
    [request setValue:indic[@"customer_email"] forKey:@"customer_email"];
    [request setValue:indic[@"customer_name"] forKey:@"customer_name"];
    [request setValue:indic[@"customer_ip"] forKey:@"customer_ip"];
    [request setValue:indic[@"merchant_reference"] forKey:@"merchant_reference"];
    [request setValue:indic[@"sdk_token"] forKey:@"sdk_token"];
    [request setValue:@"PURCHASE" forKey:@"command"];
    [request setValue:@"en" forKey:@"language"];
    [request setValue:@"VISA" forKey:@"payment_option"];
    [request setValue:@"ECOMMERCE" forKey:@"eci"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
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


@end
  
