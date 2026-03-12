# CustomConfirmationDialog

Reusable custom confirmation dialog for SwiftUI distributed as a Swift Package.

It provides an action-sheet-like UI with:
- Optional title
- Action rows
- Native `ShareLink` rows
- Built-in presenter modifier
- Automatic height + scroll behavior (`half` or `full`)

## Requirements

- iOS 16+
- Xcode 15+
- Swift 5.9+

## Installation

### Swift Package Manager (Xcode)

1. Open your app project in Xcode.
2. Go to `File` -> `Add Package Dependencies...`
3. Paste your repository URL.
4. Select version rule (recommended: `Up to Next Major` from `1.0.0`).
5. Add product: `CustomConfirmationDialog`.

### Swift Package Manager (Package.swift)

```swift
dependencies: [
    .package(url: "https://github.com/<your-user>/CustomConfirmationDialog.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "CustomConfirmationDialog", package: "CustomConfirmationDialog")
        ]
    )
]
```

## Quick Start

```swift
import SwiftUI
import CustomConfirmationDialog

struct DemoView: View {
    @State private var isPresented = false
    @State private var selected = "None"

    var body: some View {
        VStack(spacing: 12) {
            Text("Selected: \(selected)")

            Button("Open Dialog") {
                isPresented = true
            }
        }
        .customConfirmationDialog(
            isPresented: $isPresented,
            title: "Choose an option",
            options: [
                CustomConfirmationDialogOption(title: "Edit") {
                    selected = "Edit"
                },
                CustomConfirmationDialogOption(
                    title: "Share QR",
                    shareText: "https://example.com/qr",
                    subject: Text("QR"),
                    message: Text("Share this QR"),
                    onSelect: {
                        selected = "Share QR"
                    }
                ),
                CustomConfirmationDialogOption(title: "Delete") {
                    selected = "Delete"
                }
            ],
            useFullHeight: false,
            onCancel: {
                selected = "Cancel"
            }
        )
    }
}
```

## API Overview

### Option model

Use `CustomConfirmationDialogOption` to describe each row:

- Action row:
```swift
CustomConfirmationDialogOption(title: "Archive") {
    // do something
}
```

- Share row (text):
```swift
CustomConfirmationDialogOption(
    title: "ShareQR",
    shareText: "https://example.com/qr"
)
```

- Share row (URL):
```swift
CustomConfirmationDialogOption(
    title: "Open Website",
    shareURL: URL(string: "https://example.com")!
)
```

### Presenter modifier

Use the modifier to present the dialog as an overlay:

```swift
.customConfirmationDialog(
    isPresented: $isPresented,
    title: "Choose",
    options: options,
    useFullHeight: false,
    dismissOnBackgroundTap: true,
    onCancel: {}
)
```

### Height behavior

- `useFullHeight == false`:
  - Dialog grows until half of available height.
  - If options exceed this limit, scrolling activates.

- `useFullHeight == true`:
  - Dialog grows until full available height.
  - If options exceed this limit, scrolling activates.

## Backward-compatible API

If needed, you can still use the string-based overload:

```swift
.customConfirmationDialog(
    isPresented: $isPresented,
    title: "Choose",
    source: ["One", "Two", "Three"],
    onSelect: { value in
        print(value)
    }
)
```

## Integration Notes

- The package intentionally includes its own presenter to avoid repeating overlay/transition code.
- `ShareLink` rows are native SwiftUI components.
- If you use MVVM, route option callbacks into your ViewModel from each option closure.

## Versioning

Use semantic versioning tags:

- `1.0.0` initial stable release
- `1.0.1` bug fix
- `1.1.0` backward-compatible feature
- `2.0.0` breaking change

## License

MIT
