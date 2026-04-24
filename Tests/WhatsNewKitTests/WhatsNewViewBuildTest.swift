#if os(iOS) || os(macOS)
import SwiftUI
import Testing
@testable import WhatsNewKit

struct WhatsNewViewBuildTest {
    @Test
    func viewConstructsWithMockContent() {
        struct MockContent: WhatsNewContent {
            var title: Text { Text("Mock") }
            var features: [WhatsNewFeature] {
                [WhatsNewFeature(description: Text("Single feature."))]
            }
            var notice: WhatsNewNotice? { nil }
            var buttonText: Text { Text("OK") }
        }

        _ = WhatsNewView(content: MockContent(), onDismiss: {})
    }

    @Test
    func viewConstructsWithAllOptionalFields() {
        struct RichContent: WhatsNewContent {
            var appIcon: Image? { Image(systemName: "app.gift.fill") }
            var title: Text { Text("Rich") }
            var features: [WhatsNewFeature] {
                [
                    WhatsNewFeature(
                        image: Image(systemName: "star"),
                        label: Text("Labeled"),
                        description: Text("With label and image.")),
                ]
            }
            var notice: WhatsNewNotice? { WhatsNewNotice(text: Text("Notice")) }
            var buttonText: Text { Text("Continue") }
        }

        _ = WhatsNewView(content: RichContent(), onDismiss: {})
    }
}
#endif
