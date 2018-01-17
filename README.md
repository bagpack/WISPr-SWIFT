WISPr-SWIFT
=======

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

* Wi2

### Installation ###

TODO
