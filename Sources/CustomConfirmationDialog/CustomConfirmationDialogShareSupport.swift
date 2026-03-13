import SwiftUI
import UIKit
import LinkPresentation

// MARK: - Share Support

/// Payload consumed by the UIKit bridge to open the native share sheet.
struct ShareSheetPayload: Identifiable {
    /// Stable identifier for SwiftUI presentation updates.
    let id = UUID()

    /// Items passed to `UIActivityViewController`.
    let items: [Any]
}

/// UIKit presenter host that opens `UIActivityViewController` from SwiftUI context.
///
/// This bridge is used instead of SwiftUI `.sheet` to preserve the same compact,
/// bottom-sheet style behavior users expect from the system share experience.
struct ActivitySharePresenterHost: UIViewControllerRepresentable {
    /// Active payload. When non-`nil`, the host presents the share controller.
    @Binding var payload: ShareSheetPayload?

    /// Callback invoked when share UI starts/finishes dismissing.
    let onDismiss: () -> Void

    /// Coordinator used to synchronize UIKit dismissal callbacks with SwiftUI state.
    final class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        /// Dismiss callback propagated to SwiftUI.
        var onDismiss: () -> Void = {}

        /// State cleanup callback for the bound payload.
        var clearPayload: () -> Void = {}

        /// Guard flag to avoid duplicate dismiss handling from multiple UIKit callbacks.
        private var hasHandledDismiss = false

        /// Resets internal dismissal tracking before presenting a new controller.
        func reset() {
            hasHandledDismiss = false
        }

        /// Executes dismiss workflow exactly once.
        func handleDismissIfNeeded() {
            guard !hasHandledDismiss else { return }
            hasHandledDismiss = true
            clearPayload()
            onDismiss()
        }

        /// Called when interactive/system dismissal begins.
        ///
        /// We use this callback to make dialog dismissal feel immediate.
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            handleDismissIfNeeded()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let payloadBinding = _payload
        context.coordinator.onDismiss = onDismiss
        context.coordinator.clearPayload = {
            payloadBinding.wrappedValue = nil
        }

        guard let payload, uiViewController.presentedViewController == nil else { return }

        let activityItems = ActivityShareItemNormalizer.normalize(payload.items)
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.modalPresentationStyle = .automatic

        if let popover = controller.popoverPresentationController {
            popover.sourceView = uiViewController.view
            popover.sourceRect = CGRect(
                x: uiViewController.view.bounds.midX,
                y: uiViewController.view.bounds.midY,
                width: 1,
                height: 1
            )
            popover.permittedArrowDirections = []
        }
        controller.presentationController?.delegate = context.coordinator
        context.coordinator.reset()

        // Fallback callback for completion paths that may bypass the delegate timing.
        controller.completionWithItemsHandler = { _, _, _, _ in
            context.coordinator.handleDismissIfNeeded()
        }

        uiViewController.present(controller, animated: true)
    }
}

// MARK: - Share Item Normalization

/// Normalizes share items so image `Data` gets proper metadata preview in the native share sheet.
private enum ActivityShareItemNormalizer {
    /// Title used in the native share header when the payload is image data.
    ///
    /// This avoids falling back to the app name and makes QR sharing intent explicit.
    private static let imageShareTitle = "Share QR Code"

    /// Converts image `Data` payloads into `UIActivityItemSource` objects with metadata,
    /// while leaving non-image payloads untouched.
    static func normalize(_ items: [Any]) -> [Any] {
        return items.map { item in
            guard let data = item as? Data, let image = UIImage(data: data) else {
                return item
            }
            return ImageActivityItemSource(image: image, title: imageShareTitle)
        }
    }
}

/// Item source used to provide image metadata preview (instead of app icon) in activity sheets.
private final class ImageActivityItemSource: NSObject, UIActivityItemSource {
    private let image: UIImage
    private let title: String

    init(image: UIImage, title: String) {
        self.image = image
        self.title = title
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        image
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        image
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.iconProvider = NSItemProvider(object: image)
        metadata.imageProvider = NSItemProvider(object: image)
        return metadata
    }
}
