import SwiftUI

private struct CustomConfirmationDialogPresenter: ViewModifier {
    @Binding var isPresented: Bool
    let title: String?
    let options: [CustomConfirmationDialogOption]
    let useFullHeight: Bool
    let onCancel: () -> Void
    let dismissOnBackgroundTap: Bool

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        guard dismissOnBackgroundTap else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPresented = false
                        }
                    }

                VStack {
                    Spacer()

                    CustomConfirmationDialog(
                        title: title,
                        options: options,
                        useFullHeight: useFullHeight,
                        onCancel: {
                            onCancel()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isPresented = false
                            }
                        },
                        onOptionTap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isPresented = false
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}

public extension View {
    /// Presents a custom confirmation dialog as an overlay on top of the current view.
    ///
    /// This helper encapsulates presentation concerns (overlay, transition, and dismissal animation)
    /// so call sites only provide data and actions.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls whether the dialog is visible.
    ///   - title: Optional title displayed above the options list.
    ///   - options: Typed rows shown as action or share entries.
    ///   - useFullHeight: Height behavior for the options area. `false` uses half screen max height.
    ///   - dismissOnBackgroundTap: Whether tapping the dimmed background dismisses the dialog.
    ///   - onCancel: Called when cancel is tapped.
    /// - Returns: A view that can present `CustomConfirmationDialog` over its content.
    func customConfirmationDialog(
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

    /// Backward-compatible overlay API using `source` and `onSelect`.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls whether the dialog is visible.
    ///   - title: Optional title displayed above the options list.
    ///   - source: String rows transformed into dialog options.
    ///   - useFullHeight: Height behavior for the options area. `false` uses half screen max height.
    ///   - dismissOnBackgroundTap: Whether tapping the dimmed background dismisses the dialog.
    ///   - onSelect: Called with the selected string row.
    ///   - onCancel: Called when cancel is tapped.
    /// - Returns: A view that can present `CustomConfirmationDialog` over its content.
    func customConfirmationDialog(
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
