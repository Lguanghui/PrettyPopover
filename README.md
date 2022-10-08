# PrettyPopover

![CI Status](https://github.com/Lguanghui/PrettyPopover/actions/workflows/ios.yml/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/PrettyPopover.svg?style=flat)](https://cocoapods.org/pods/PrettyPopover)
[![License](https://img.shields.io/cocoapods/l/PrettyPopover.svg?style=flat)](https://cocoapods.org/pods/PrettyPopover)
[![Platform](https://img.shields.io/cocoapods/p/PrettyPopover.svg?style=flat)](https://cocoapods.org/pods/PrettyPopover)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 11.0 or later

## Installation

### Cocoapods
PrettyPopover is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PrettyPopover'
```

### SwiftPM

In your Package.swift, add

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/Lguanghui/PrettyPopover.git", .upToNextMajor(from: "0.1.0"))
    ]
    // ...
)
```

Or, click Xcode `File` -> `Swift Packages` -> `Add Package Dependency`, enter [PrettyPopover repo's URL](https://github.com/Lguanghui/PrettyPopover.git).

## Usage

`PrettyPopoverConfig` is the config of your popover, such as background, width, height...

`PrettyPopoverManager` is the manager of your popovers.

`PrettyPopover` is the view of your popover.

Firstly, create an instance of `PrettyPopoverConfig` to tell the manager what your popover look like.

Then, write codes like this,

```swift
PrettyPopoverManager.sharedInstance.show(WithSourceView: yourSourceView, inView: yourInView, customView: yourCustomView, config: yourConfig)
```

to show your popover.

## Showcase

### Auto Direction

![](Images/auto_direction.gif)

### Gradient Background

![](Images/gradient.png)

### Custom Content View

![](Images/custom_content.png)

### Update Width/Height with Animation

![](Images/update_animation.gif)

### Set Popover Offset

![](Images/set_offset_1.png)

You can also make the triangle shift with the popover:

![](Images/set_offset_2.png)

### and so on...

## Author

Lguanghui, meetguanghuiliang@gmail.com

## License

PrettyPopover is available under the MIT license. See the LICENSE file for more info.
