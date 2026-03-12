import SwiftUI
import XCTest
import CustomConfirmationDialog

final class ConsumerCompileTests: XCTestCase {
    func testConsumerAPICompiles() {
        _ = CustomConfirmationDialogOption(title: "Action") {}

        struct ConsumerView: View {
            @State private var isPresented = false

            var body: some View {
                Text("Host")
                    .customConfirmationDialog(
                        isPresented: $isPresented,
                        title: "Choose",
                        options: [
                            CustomConfirmationDialogOption(title: "Option") {}
                        ],
                        useFullHeight: false,
                        onCancel: {}
                    )
            }
        }

        _ = ConsumerView()
    }
}
