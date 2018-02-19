WISPr-SWIFT
=======

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/hsylife/SwiftyPickerPopover)
[![Build Status](https://travis-ci.org/bagpack/WISPr-SWIFT.svg?branch=master)](https://travis-ci.org/bagpack/WISPr-SWIFT)
[![codecov](https://codecov.io/gh/bagpack/WISPr-SWIFT/branch/master/graph/badge.svg)](https://codecov.io/gh/bagpack/WISPr-SWIFT)


WISPr-SWIFT is WISPr Smart Client without the need for the user to manually type in his/her credentials.

```swift
WISPrClient().login(username: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxxx@xxxxx@xxx", password: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx") { (result) in
    switch result {
    case .success(let payload):
        print(payload)
    case .failure(let error):
        print(error)
    }
}
```

### Requirements ###

* Swift 4.0 or later

### Confirmed SSID ###

Confirmed with the following SSID.

* Wi2

### Installation ###

Add the following line to your Cartfile.

```
github "bagpack/WISPr-SWIFT" ~> 0.1.0
```

Then run carthage update. For details, please see [here](https://github.com/Carthage/Carthage).
