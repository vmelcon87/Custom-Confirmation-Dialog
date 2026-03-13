import SwiftUI
import CoreTransferable

// MARK: - Option Model

/// Describes a single selectable row rendered by ``CustomConfirmationDialog``.
///
/// Use the action initializer for regular callbacks, and one of the share initializers
/// when the row should open the native system share sheet managed by the presenter.
public struct CustomConfirmationDialogOption: Identifiable {
    // MARK: Properties

    /// Stable identity for diffing and rendering updates.
    public let id: UUID

    /// Optional payload consumed by the presenter to open `UIActivityViewController`.
    ///
    /// `nil` means the option is a standard action row.
    let shareItems: [Any]?

    /// Internal row factory that injects presenter-level tap behavior.
    private let rowBuilder: (_ onTap: @escaping () -> Void) -> AnyView

    // MARK: Initializers

    /// Creates a standard action row.
    ///
    /// - Parameters:
    ///   - id: Stable identifier for list diffing.
    ///   - title: Visible label for the row.
    ///   - action: Callback executed after the presenter tap hook.
    public init(
        id: UUID = UUID(),
        title: String,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.shareItems = nil
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

    /// Creates a share row using a text payload.
    ///
    /// This initializer keeps a `ShareLink`-like API at call-site level, but rendering is
    /// handled as a regular button and the native share UI is presented by the presenter.
    ///
    /// - Parameters:
    ///   - id: Stable identifier for list diffing.
    ///   - title: Visible label for the row.
    ///   - text: Text payload to share.
    ///   - subject: Reserved for API compatibility with `ShareLink` style usage.
    ///   - message: Reserved for API compatibility with `ShareLink` style usage.
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
        self.shareItems = [text]
        self.rowBuilder = { onTap in
            AnyView(
                Button {
                    onTap()
                    onSelect?()
                } label: {
                    DialogRowLabel(title: title)
                }
                .buttonStyle(.plain)
            )
        }
    }

    /// Creates a share row using a URL payload.
    ///
    /// This initializer keeps a `ShareLink`-like API at call-site level, but rendering is
    /// handled as a regular button and the native share UI is presented by the presenter.
    ///
    /// - Parameters:
    ///   - id: Stable identifier for list diffing.
    ///   - title: Visible label for the row.
    ///   - url: URL payload to share.
    ///   - subject: Reserved for API compatibility with `ShareLink` style usage.
    ///   - message: Reserved for API compatibility with `ShareLink` style usage.
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
        self.shareItems = [url]
        self.rowBuilder = { onTap in
            AnyView(
                Button {
                    onTap()
                    onSelect?()
                } label: {
                    DialogRowLabel(title: title)
                }
                .buttonStyle(.plain)
            )
        }
    }


    /// Creates a share row using a `Transferable` payload routed through `UIActivityViewController`.
    ///
    /// - Parameters:
    ///   - id: Stable identifier for list diffing.
    ///   - title: Visible label for the row.
    ///   - item: Transferable payload to share.
    ///   - activityItems: Items forwarded to `UIActivityViewController`.
    ///     If omitted, it tries to forward `item` directly.
    ///   - iconSystemName: Optional SF Symbol displayed alongside title in the row.
    ///   - onSelect: Optional callback fired when the row is tapped.
    public init<Item: Transferable>(
        id: UUID = UUID(),
        title: String,
        shareItem item: Item,
        activityItems: [Any]? = nil,
        iconSystemName: String? = nil,
        onSelect: (() -> Void)? = nil
    ) {
        self.id = id
        self.shareItems = activityItems ?? [item]
        self.rowBuilder = { onTap in
            AnyView(
                Button {
                    onTap()
                    onSelect?()
                } label: {
                    DialogRowLabel(title: title, iconSystemName: iconSystemName)
                }
                .buttonStyle(.plain)
            )
        }
    }

    // MARK: Internal API

    /// Builds the row view while injecting the presenter-level tap hook.
    ///
    /// - Parameter onTap: Presenter callback used for dialog-level behavior.
    /// - Returns: A type-erased view for row rendering.
    func makeRow(onTap: @escaping () -> Void) -> AnyView {
        rowBuilder(onTap)
    }
}

// MARK: - Supporting Views

/// Shared visual label used by action and share rows.
private struct DialogRowLabel: View {
    /// Text displayed in the row.
    let title: String
    /// Optional SF Symbol displayed next to title.
    let iconSystemName: String?

    init(title: String, iconSystemName: String? = nil) {
        self.title = title
        self.iconSystemName = iconSystemName
    }

    var body: some View {
        Group {
            if let iconSystemName {
                Label(title, systemImage: iconSystemName)
            } else {
                Text(title)
            }
        }
        .font(.title3)
        .foregroundStyle(.blue)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
    }
}
