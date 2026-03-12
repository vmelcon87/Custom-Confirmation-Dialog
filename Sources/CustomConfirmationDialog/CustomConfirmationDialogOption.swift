import SwiftUI

/// Represents a row displayed by ``CustomConfirmationDialog``.
///
/// Use action options for regular callbacks and share options when you want to use native `ShareLink` behavior.
public struct CustomConfirmationDialogOption: Identifiable {
    /// Stable identity used for list diffing.
    public let id: UUID
    private let rowBuilder: (_ onTap: @escaping () -> Void) -> AnyView

    /// Creates an action row.
    ///
    /// - Parameters:
    ///   - id: Stable identifier for diffing and updates.
    ///   - title: Text displayed in the row.
    ///   - action: Callback triggered when the row is tapped.
    public init(
        id: UUID = UUID(),
        title: String,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.rowBuilder = { onTap in
            AnyView(
                Button {
                    onTap()
                    action()
                } label: {
                    DialogRowLabel(title: title)
                }
                .buttonStyle(.plain)
            )
        }
    }

    /// Creates a share row powered by native `ShareLink`.
    ///
    /// - Parameters:
    ///   - id: Stable identifier for diffing and updates.
    ///   - title: Text displayed in the row.
    ///   - text: Share payload.
    ///   - subject: Optional subject for supported targets.
    ///   - message: Optional message for supported targets.
    ///   - onSelect: Optional callback fired when the row is tapped.
    public init(
        id: UUID = UUID(),
        title: String,
        shareText text: String,
        subject: Text? = nil,
        message: Text? = nil,
        onSelect: (() -> Void)? = nil
    ) {
        self.id = id
        self.rowBuilder = { _ in
            AnyView(
                ShareLink(item: text, subject: subject, message: message) {
                    DialogRowLabel(title: title)
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        onSelect?()
                    }
                )
            )
        }
    }

    /// Creates a share row powered by native `ShareLink` for URL payloads.
    ///
    /// - Parameters:
    ///   - id: Stable identifier for diffing and updates.
    ///   - title: Text displayed in the row.
    ///   - url: URL payload.
    ///   - subject: Optional subject for supported targets.
    ///   - message: Optional message for supported targets.
    ///   - onSelect: Optional callback fired when the row is tapped.
    public init(
        id: UUID = UUID(),
        title: String,
        shareURL url: URL,
        subject: Text? = nil,
        message: Text? = nil,
        onSelect: (() -> Void)? = nil
    ) {
        self.id = id
        self.rowBuilder = { _ in
            AnyView(
                ShareLink(item: url, subject: subject, message: message) {
                    DialogRowLabel(title: title)
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        onSelect?()
                    }
                )
            )
        }
    }

    func makeRow(onTap: @escaping () -> Void) -> AnyView {
        rowBuilder(onTap)
    }
}

private struct DialogRowLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3)
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
    }
}
