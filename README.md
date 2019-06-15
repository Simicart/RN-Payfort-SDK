
# react-native-payfort-sdk

## Getting started

`$ npm install react-native-payfort-sdk --save`

### Mostly automatic installation

`$ react-native link react-native-payfort-sdk`

### Add library to each platform


#### iOS

1. Extract [this](https://docs.payfort.com/docs/mobile-sdk/build/lib/PayFortSDK%201.8.zip) folder. 
2. Drag the `PayFortSDK.framework` & `PayFortSDK.bundle` to `Frameworks` in Project Navigator.
3. Create a new group `Frameworks` if it does not exist:
        * Choose Create groups for any added folders.
        * Make Sure to select Copy files if needed.
4. Set `-ObjC` in the Other Linker Flags in the `Target` → `Build Settings` Tab.
5. For Swift Projects Don’t forget to add the `#import` to the `Bridging-Header.h`

#### Android

1. Extract [this](https://docs.payfort.com/docs/mobile-sdk/build/lib/FORTSDKv1.5.zip) folder.
2. In Android Studio, choose `File` → `New` → `New Module` then select `Import .JAR\.AAR Package`.
3. In the next step, find to the path of .aar file in library folder and press `Finish`.


## Usage

#### First, you have to read the [document](https://docs.payfort.com/docs/mobile-sdk/build/index.html#before-starting-the-integration-section-in-the-api) from Payfort carefully

```javascript
import RNReactNativePayfortSdk from 'react-native-payfort-sdk';

let data = {};
data['access_code'] = 'abcdxyzqwerty';          // require field
data['merchant_identify'] = 'poilkjyhm';        // require field
data['request_phrase'] = 'tgbvfe';              // require field
data['customer_email'] = 'v@example.com';       // require field
data['currency'] = 'USD';                       // require field
data['amount'] = '10';                          // require field
data['merchant_reference'] = '123456';          // require field
data['customer_name'] = 'Glenn';
data['customer_ip'] = '27.79.60.231';
data['payment_option'] = 'VISA';
data['order_description'] = 'Order for testing';

RNReactNativePayfortSdk.openPayfort(data, (response) => {
    console.log(response);
}, (message) => {
    // Message in case payment is failure or cancel
});
```
  
