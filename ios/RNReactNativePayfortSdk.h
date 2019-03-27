
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <PayFortSDK/PayFortSDK.h>

@interface RNReactNativePayfortSdk : NSObject <RCTBridgeModule, NSURLSessionDelegate>

@end

