# WhatsNewKit

A reusable SwiftUI "What's New" sheet for iOS and macOS apps in the HK Softworks portfolio.

## Requirements

- iOS 26+ / macOS 26+
- Swift 6.0+

## Installation

Add to your `Package.swift`:

```swift
.package(url: "https://github.com/hksw-io/WhatsNewKit.git", from: "1.0.0")
```

Or in Xcode: **File > Add Package Dependencies** and enter the URL above.

## Usage

Implement `WhatsNewContent` with your app's strings and icon, then present the view:

```swift
import SwiftUI
import WhatsNewKit

struct MyWhatsNew: WhatsNewContent {
    var appIcon: Image? { Image("AppIconImage") }
    var title: Text { Text("What's New in MyApp") }
    var features: [WhatsNewFeature] {
        [
            WhatsNewFeature(
                systemImage: "chart.line.uptrend.xyaxis.circle",
                label: "New Charts",
                description: "Track your progress with redesigned charts."),
        ]
    }
    var notice: WhatsNewNotice? {
        WhatsNewNotice(text: Text("Plus many other improvements."))
    }
    var buttonText: Text { Text("Continue") }
}

struct RootView: View {
    @State private var isShowing = false

    var body: some View {
        ContentView()
            .sheet(isPresented: $isShowing) {
                WhatsNewView(content: MyWhatsNew()) {
                    isShowing = false
                }
            }
    }
}
```

## Version tracking

`WhatsNewVersionTracker` persists the last-shown version in `UserDefaults` and decides whether to present the sheet on launch:

```swift
let tracker = WhatsNewVersionTracker(
    keyPrefix: "com.example.myapp",
    currentVersion: "1.2.0")

if tracker.shouldShowWhatsNew() {
    // present WhatsNewView
}

// after dismiss:
tracker.markAsShown()
```

The first launch after install is treated as "not new" — users see the sheet only on subsequent version upgrades.

## License

Private. Copyright © HK Softworks.
