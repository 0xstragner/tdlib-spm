# SPM
Once you have your Swift package set up, adding TDLib as a dependency is as easy as adding it to the dependencies value of your Package.swift.
```
dependencies: [
    .package(url: "https://github.com/oboupo/tdlib-spm.git", .upToNextMajor(from: "1.7.0"))
]
```
Usage:
```
import libtdjson
```
> Sample of code can be found [in official tdlib repo](https://github.com/tdlib/td/blob/master/example/swift/src/main.swift)
# Building
Below are instructions for building `tdlibjson.xcframework`.

To compile `tdlibjson` you will need to:
* Install the latest Xcode via `xcode-select --install` or downloading it from [Xcode website](https://developer.apple.com/xcode/).
  It is not enough to install only command line developer tools to build `TDLib` for iOS.
* Install other build dependencies using [Homebrew](https://brew.sh):
```
brew install gperf cmake coreutils
```
* Build TDLib for iOS, watchOS, tvOS and macOS:
```
./xcframework.sh
```
This may take a while, because TDLib will be built about 10 times.
Built framework will be store in `build` directory.

# More
Other documentation can be found at https://github.com/tdlib/td/tree/master/example/ios.
