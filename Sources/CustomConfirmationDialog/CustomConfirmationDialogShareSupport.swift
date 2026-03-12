import SwiftUI

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

        let controller = UIActivityViewController(activityItems: payload.items, applicationActivities: nil)
        controller.modalPresentationStyle = .automatic
        controller.presentationController?.delegate = context.coordinator
        context.coordinator.reset()

        // Fallback callback for completion paths that may bypass the delegate timing.
        controller.completionWithItemsHandler = { _, _, _, _ in
            context.coordinator.handleDismissIfNeeded()
        }

        uiViewController.present(controller, animated: true)
    }
}
