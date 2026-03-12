import SwiftUI

// MARK: - Custom Confirmation Dialog

/// A bottom-sheet styled confirmation dialog that mimics the system action-sheet layout.
///
/// The dialog renders:
/// - an optional title section,
/// - a list of selectable options,
/// - and a dedicated cancel button.
///
/// Height behavior is controlled by `useFullHeight`:
/// - `false`: options area grows up to half of available height.
/// - `true`: options area can grow up to full available height.
///
/// Once the options exceed the configured maximum, vertical scrolling is enabled automatically.
struct CustomConfirmationDialog: View {
    // MARK: Properties

    /// Optional title displayed at the top of the options container.
    let title: String?

    /// Ordered rows rendered inside the options list.
    let options: [CustomConfirmationDialogOption]

    /// Height strategy used to compute the maximum list area.
    let useFullHeight: Bool

    /// Callback executed when user taps cancel.
    let onCancel: () -> Void

    /// Presenter hook called when a row is selected.
    private let onOptionTap: (CustomConfirmationDialogOption) -> Void

    // MARK: Initializers

    /// Creates a dialog using typed option rows.
    ///
    /// - Parameters:
    ///   - title: Optional title. Pass `nil` or whitespace-only text to hide the title area.
    ///   - options: Rows displayed by the dialog.
    ///   - useFullHeight: `true` enables growth up to full available height; `false` caps at half height.
    ///   - onCancel: Callback invoked when cancel is tapped.
    ///   - onOptionTap: Internal presenter callback invoked before/along option action handling.
    init(
        title: String? = nil,
        options: [CustomConfirmationDialogOption],
        useFullHeight: Bool,
        onCancel: @escaping () -> Void,
        onOptionTap: @escaping (CustomConfirmationDialogOption) -> Void = { _ in }
    ) {
        self.title = title
        self.options = options
        self.useFullHeight = useFullHeight
        self.onCancel = onCancel
        self.onOptionTap = onOptionTap
    }

    /// Backward-compatible initializer based on source strings.
    ///
    /// - Parameters:
    ///   - title: Optional title displayed above options.
    ///   - source: Raw string rows transformed into option models.
    ///   - useFullHeight: `true` enables growth up to full available height; `false` caps at half height.
    ///   - onSelect: Callback invoked with the selected source value.
    ///   - onCancel: Callback invoked when cancel is tapped.
    init(
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

    // MARK: Body

    var body: some View {
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
                                let option = options[index]
                                option.makeRow {
                                    onOptionTap(option)
                                }

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
