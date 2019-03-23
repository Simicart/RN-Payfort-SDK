
# react-native-payfort-sdk

## Getting started

`$ npm install react-native-payfort-sdk --save`

### Mostly automatic installation

`$ react-native link react-native-payfort-sdk`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-payfort-sdk` and add `RNReactNativePayfortSdk.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNReactNativePayfortSdk.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNReactNativePayfortSdkPackage;` to the imports at the top of the file
  - Add `new RNReactNativePayfortSdkPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-payfort-sdk'
  	project(':react-native-payfort-sdk').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-payfort-sdk/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-payfort-sdk')
  	```


## Usage
```javascript
import RNReactNativePayfortSdk from 'react-native-payfort-sdk';

// TODO: What to do with the module?
RNReactNativePayfortSdk;
```
  
