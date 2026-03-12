import SwiftUI

/// A custom bottom-sheet style confirmation dialog that mimics the system action sheet look.
///
/// The dialog shows an optional title, a list of selectable options, and a dedicated cancel button.
/// It can grow up to half screen height or full available height depending on `useFullHeight`.
/// When content exceeds the configured maximum height, scrolling is enabled automatically.
public struct CustomConfirmationDialog: View {
    /// Optional title displayed at the top of the dialog.
    public let title: String?
    /// Ordered rows rendered as dialog options.
    public let options: [CustomConfirmationDialogOption]
    /// Controls whether the dialog can grow to full height or half height.
    public let useFullHeight: Bool
    /// Callback fired when the cancel button is tapped.
    public let onCancel: () -> Void

    private let onOptionTap: () -> Void

    /// Creates a custom confirmation dialog with typed options.
    ///
    /// - Parameters:
    ///   - title: Optional title displayed above the options list. Pass `nil` or an empty value to hide it.
    ///   - options: Rows displayed in the dialog.
    ///   - useFullHeight: If `true`, the dialog can grow up to the full available height.
    ///     If `false`, it grows up to half the available height.
    ///   - onCancel: Called when the user taps the cancel button.
    ///   - onOptionTap: Internal hook used by the presenter to dismiss before row actions.
    public init(
        title: String? = nil,
        options: [CustomConfirmationDialogOption],
        useFullHeight: Bool,
        onCancel: @escaping () -> Void,
        onOptionTap: @escaping () -> Void = {}
    ) {
        self.title = title
        self.options = options
        self.useFullHeight = useFullHeight
        self.onCancel = onCancel
        self.onOptionTap = onOptionTap
    }

    /// Backward-compatible initializer based on string source and select callback.
    ///
    /// - Parameters:
    ///   - title: Optional title displayed above the options list.
    ///   - source: String rows displayed in the dialog.
    ///   - useFullHeight: If `true`, the dialog can grow up to the full available height.
    ///   - onSelect: Called when any row is tapped.
    ///   - onCancel: Called when the user taps the cancel button.
    public init(
        title: String? = nil,
        source: [String],
        useFullHeight: Bool,
        onSelect: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.init(
            title: title,
            options: source.map { value in
                CustomConfirmationDialogOption(title: value) {
                    onSelect(value)
                }
            },
            useFullHeight: useFullHeight,
            onCancel: onCancel
        )
    }

    public var body: some View {
        GeometryReader { proxy in
            let availableHeight = max(proxy.size.height, 0)
            let maxDialogHeight = useFullHeight ? availableHeight : availableHeight * 0.5
            let hasTitle = !(title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            let headerHeight: CGFloat = hasTitle ? 52 : 0
            let cancelButtonHeight: CGFloat = 54
            let sectionsSpacing: CGFloat = 10
            let fixedHeight = headerHeight + cancelButtonHeight + sectionsSpacing
            let maxOptionsHeight = max(maxDialogHeight - fixedHeight, 0)
            let rowHeight: CGFloat = 56
            let dividerHeight: CGFloat = 1
            let optionsCount = options.count
            let optionsContentHeight = (CGFloat(optionsCount) * rowHeight) + (CGFloat(max(optionsCount - 1, 0)) * dividerHeight)
            let shouldScroll = optionsContentHeight > maxOptionsHeight
            let optionsHeight = min(optionsContentHeight, maxOptionsHeight)
            let finalDialogHeight = min(fixedHeight + optionsHeight, maxDialogHeight)

            VStack(spacing: sectionsSpacing) {
                VStack(spacing: 0) {
                    if let title, hasTitle {
                        Text(title)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .frame(height: headerHeight)
                            .padding(.horizontal, 12)

                        Divider()
                    }

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(options.indices, id: \.self) { index in
                                options[index].makeRow(onTap: onOptionTap)

                                if index < options.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .scrollDisabled(!shouldScroll)
                    .frame(height: max(optionsHeight, 1))
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.regularMaterial)
                )

                Button(role: .cancel) {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: cancelButtonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.systemBackground))
                        )
                }
                .buttonStyle(.plain)
            }
            .frame(height: max(finalDialogHeight, fixedHeight), alignment: .top)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}
