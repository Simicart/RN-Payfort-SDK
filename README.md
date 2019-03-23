
# react-native-react-native-payfort-sdk

## Getting started

`$ npm install react-native-react-native-payfort-sdk --save`

### Mostly automatic installation

`$ react-native link react-native-react-native-payfort-sdk`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-react-native-payfort-sdk` and add `RNReactNativePayfortSdk.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNReactNativePayfortSdk.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNReactNativePayfortSdkPackage;` to the imports at the top of the file
  - Add `new RNReactNativePayfortSdkPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-react-native-payfort-sdk'
  	project(':react-native-react-native-payfort-sdk').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-react-native-payfort-sdk/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-react-native-payfort-sdk')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNReactNativePayfortSdk.sln` in `node_modules/react-native-react-native-payfort-sdk/windows/RNReactNativePayfortSdk.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using React.Native.Payfort.Sdk.RNReactNativePayfortSdk;` to the usings at the top of the file
  - Add `new RNReactNativePayfortSdkPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNReactNativePayfortSdk from 'react-native-react-native-payfort-sdk';

// TODO: What to do with the module?
RNReactNativePayfortSdk;
```
  