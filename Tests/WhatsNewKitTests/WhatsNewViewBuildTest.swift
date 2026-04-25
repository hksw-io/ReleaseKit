#if os(iOS) || os(macOS)
import SwiftUI
import Testing
@testable import WhatsNewKit

@MainActor
struct WhatsNewViewBuildTest {
    @Test
    func viewConstructsWithMockContent() {
        struct MockContent: WhatsNewContent {
            var title: Text { Text("Mock") }
            var features: [WhatsNewFeature] {
                [WhatsNewFeature(id: "single", description: Text("Single feature."))]
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
                        id: "labeled",
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

    @Test
    func viewConstructsWithConvenienceFeatureInitializer() {
        struct ConvenienceContent: WhatsNewContent {
            var title: Text { Text("Convenience") }
            var features: [WhatsNewFeature] {
                [
                    WhatsNewFeature(
                        id: "localized-label",
                        systemImage: "sparkles",
                        label: "Localized label",
                        description: "Localized description."),
                ]
            }
            var notice: WhatsNewNotice? { nil }
            var buttonText: Text { Text("OK") }
        }

        _ = WhatsNewView(content: ConvenienceContent(), onDismiss: {})
    }

    @Test
    func viewConstructsWithLongLocalizedContentAndManyFeatures() {
        struct LongContent: WhatsNewContent {
            var appIcon: Image? { Image(systemName: "sparkles") }
            var title: Text {
                Text("A much longer What's New title that needs to wrap cleanly on compact devices")
            }
            var features: [WhatsNewFeature] {
                (1...12).map { index in
                    WhatsNewFeature(
                        id: "feature-\(index)",
                        image: Image(systemName: "star.circle.fill"),
                        label: Text("Feature \(index) with a longer localized label"),
                        description: Text(
                            "This feature description is intentionally longer so the row has to wrap without clipping, overlapping, or pushing controls off screen."))
                }
            }
            var notice: WhatsNewNotice? {
                WhatsNewNotice(text: Text("This notice is also long enough to wrap over multiple lines in a narrow sheet."))
            }
            var buttonText: Text {
                Text("Continue with all of these new improvements")
            }
        }

        _ = WhatsNewView(content: LongContent(), onDismiss: {})
    }

    @Test
    func viewConstructsWhenComputedFeaturesRecreateValues() {
        struct ComputedContent: WhatsNewContent {
            var title: Text { Text("Computed") }
            var features: [WhatsNewFeature] {
                [
                    WhatsNewFeature(id: "first", description: Text("First computed feature.")),
                    WhatsNewFeature(id: "second", description: Text("Second computed feature.")),
                    WhatsNewFeature(id: "third", description: Text("Third computed feature.")),
                ]
            }
            var notice: WhatsNewNotice? { nil }
            var buttonText: Text { Text("Done") }
        }

        _ = WhatsNewView(content: ComputedContent(), onDismiss: {})
    }

    @Test
    func featureInitializerStoresStableID() {
        let feature = WhatsNewFeature(
            id: "stable-feature",
            label: Text("Stable feature"),
            description: Text("A feature with stable identity."))

        #expect(feature.id == "stable-feature")
    }

    @Test
    func scrollEdgeFadeQuantizesOpacity() {
        let opacity = ScrollEdgeFade.opacity(
            contentHeight: 1_000,
            contentBottomInset: 0,
            visibleMaxY: 955,
            fadeHeight: 100)

        #expect(opacity == 0.45)
    }

    @Test
    func scrollEdgeFadeIsOpaqueAtScrollEnd() {
        let opacity = ScrollEdgeFade.opacity(
            contentHeight: 1_000,
            contentBottomInset: 0,
            visibleMaxY: 1_000,
            fadeHeight: 100)

        #expect(opacity == 0)
    }
}
#endif
