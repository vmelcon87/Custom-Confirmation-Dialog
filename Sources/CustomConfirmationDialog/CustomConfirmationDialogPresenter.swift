import SwiftUI

// MARK: - Presenter

/// Internal view modifier responsible for overlay rendering, transitions and dismissal flow.
private struct CustomConfirmationDialogPresenter: ViewModifier {
    // MARK: Inputs

    /// Controls custom dialog visibility.
    @Binding var isPresented: Bool

    /// Optional title shown above options.
    let title: String?

    /// Data source for dialog rows.
    let options: [CustomConfirmationDialogOption]

    /// Height strategy for the dialog body.
    let useFullHeight: Bool

    /// Cancel callback executed when user taps `Cancel`.
    let onCancel: () -> Void

    /// Indicates whether tapping the dimmed backdrop dismisses the dialog.
    let dismissOnBackgroundTap: Bool

    // MARK: Internal State

    /// Active share payload. When set, the UIKit bridge presents the share sheet.
    @State private var shareSheetPayload: ShareSheetPayload?

    // MARK: Body

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        guard dismissOnBackgroundTap else { return }
                        closeDialog()
                    }

                VStack {
                    Spacer()

                    CustomConfirmationDialog(
                        title: title,
                        options: options,
                        useFullHeight: useFullHeight,
                        onCancel: {
                            onCancel()
                            closeDialog()
                        },
                        onOptionTap: { option in
                            handleOptionTap(option)
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(
            ActivitySharePresenterHost(payload: $shareSheetPayload) {
                closeDialog()
            }
        )
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }

    // MARK: Private Helpers

    /// Handles row taps and routes to either share presentation or direct dialog dismiss.
    private func handleOptionTap(_ option: CustomConfirmationDialogOption) {
        if let shareItems = option.shareItems {
            closeDialog()
            shareSheetPayload = ShareSheetPayload(items: shareItems)
            return
        }

        closeDialog()
    }

    /// Closes the custom dialog using the configured animation.
    private func closeDialog() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPresented = false
        }
    }
}

// MARK: - View Extension

public extension View {
    /// Presents a custom confirmation dialog overlay.
    ///
    /// This API centralizes overlay composition, transition and dismissal behavior.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls dialog visibility.
    ///   - title: Optional header title.
    ///   - options: Rows rendered by the dialog.
    ///   - useFullHeight: `true` allows growth up to full available height. `false` caps at half height.
    ///   - dismissOnBackgroundTap: Whether tapping the dimmed backdrop dismisses the dialog.
    ///   - onCancel: Callback executed when cancel is tapped.
    /// - Returns: A view capable of showing ``CustomConfirmationDialog`` as overlay.
    public func customConfirmationDialog(
        isPresented: Binding<Bool>,
        title: String? = nil,
        options: [CustomConfirmationDialogOption],
        useFullHeight: Bool = false,
        dismissOnBackgroundTap: Bool = true,
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        modifier(
            CustomConfirmationDialogPresenter(
                isPresented: isPresented,
                title: title,
                options: options,
                useFullHeight: useFullHeight,
                onCancel: onCancel,
                dismissOnBackgroundTap: dismissOnBackgroundTap
            )
        )
    }

    /// Backward-compatible overlay API that receives string source rows.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls dialog visibility.
    ///   - title: Optional header title.
    ///   - source: Raw string rows transformed into option models.
    ///   - useFullHeight: `true` allows growth up to full available height. `false` caps at half height.
    ///   - dismissOnBackgroundTap: Whether tapping the dimmed backdrop dismisses the dialog.
    ///   - onSelect: Callback executed with the selected source value.
    ///   - onCancel: Callback executed when cancel is tapped.
    /// - Returns: A view capable of showing ``CustomConfirmationDialog`` as overlay.
    public func customConfirmationDialog(
        isPresented: Binding<Bool>,
        title: String? = nil,
        source: [String],
        useFullHeight: Bool = false,
        dismissOnBackgroundTap: Bool = true,
        onSelect: @escaping (String) -> Void,
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        customConfirmationDialog(
            isPresented: isPresented,
            title: title,
            options: source.map { value in
                CustomConfirmationDialogOption(title: value) {
                    onSelect(value)
                }
            },
            useFullHeight: useFullHeight,
            dismissOnBackgroundTap: dismissOnBackgroundTap,
            onCancel: onCancel
        )
    }
}
