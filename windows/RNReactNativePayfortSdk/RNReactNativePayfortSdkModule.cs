using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace React.Native.Payfort.Sdk.RNReactNativePayfortSdk
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNReactNativePayfortSdkModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNReactNativePayfortSdkModule"/>.
        /// </summary>
        internal RNReactNativePayfortSdkModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNReactNativePayfortSdk";
            }
        }
    }
}
