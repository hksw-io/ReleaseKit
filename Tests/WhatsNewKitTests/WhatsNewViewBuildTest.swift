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
    func viewConstructsWithStandardStyleModifier() {
        _ = WhatsNewView(content: StyledContent(), onDismiss: {})
            .whatsNewStyle(.standard)
    }

    @Test
    func viewConstructsWithCustomStyleColors() {
        let style = WhatsNewStyle(
            tint: .indigo,
            titleColor: .primary,
            featureIconColor: .mint,
            featureTitleColor: .primary,
            featureDescriptionColor: .secondary,
            noticeColor: .secondary,
            buttonForegroundColor: .white)

        _ = WhatsNewView(content: StyledContent(), onDismiss: {})
            .whatsNewStyle(style)
    }

    @Test
    func viewConstructsWithSystemBackgroundModifier() {
        _ = self.backgroundView(.system)
    }

    @Test
    func viewConstructsWithSoftGradientBackground() {
        _ = self.backgroundView(.softGradient)
    }

    @Test
    func viewConstructsWithLinearGradientBackground() {
        _ = self.backgroundView(.linearGradient(
            colors: [.blue.opacity(0.18), .mint.opacity(0.12), .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing))
    }

    @Test
    func viewConstructsWithAnimatedMeshBackground() {
        _ = self.backgroundView(.animatedMesh())
    }

    @Test
    func viewConstructsWithCustomBackground() {
        _ = self.backgroundView(.custom { context in
            LinearGradient(
                colors: [
                    Color.blue.opacity(context.reduceMotion ? 0.10 : 0.18),
                    Color.purple.opacity(0.12),
                ],
                startPoint: .top,
                endPoint: .bottom)
        })
    }

    @Test
    func footerMaskHeightQuantizesToWholePoints() {
        #expect(FooterMaskMetrics.quantizedHeight(123.4) == 123)
        #expect(FooterMaskMetrics.quantizedHeight(123.5) == 124)
    }

    @Test
    func footerMaskFrameQuantizesPositionAndHeight() {
        let frame = FooterMaskMetrics.quantizedFrame(CGRect(x: 0, y: 612.4, width: 390, height: 127.5))

        #expect(frame.minY == 612)
        #expect(frame.height == 128)
    }

    @Test
    func footerMaskFadeHeightCapsToAvoidEarlyMasking() {
        #expect(FooterMaskMetrics.resolvedFadeHeight(80) == FooterMaskMetrics.maximumFadeHeight)
    }

    @Test
    func footerMaskFadeHeightKeepsShorterValues() {
        #expect(FooterMaskMetrics.resolvedFadeHeight(18) == 18)
        #expect(FooterMaskMetrics.resolvedFadeHeight(0) == 0)
    }

    @Test
    func footerMaskFadeBottomIsHiddenWhenScrollableContentContinues() {
        #expect(FooterMaskMetrics.fadeBottomOpacity(scrollEdgeFadeOpacity: 1) == 0)
    }

    @Test
    func footerMaskFadeBottomIsVisibleAtScrollEnd() {
        #expect(FooterMaskMetrics.fadeBottomOpacity(scrollEdgeFadeOpacity: 0) == 1)
    }

    @Test
    func footerMaskLayoutUsesMeasuredFooterTop() {
        let layout = FooterMaskMetrics.layout(
            containerHeight: 740,
            footerFrame: FooterMaskFrame(minY: 612, height: 128),
            fadeHeight: FooterMaskMetrics.resolvedFadeHeight(80),
            scrollEdgeFadeOpacity: 1)

        #expect(layout.opaqueHeight == 584)
        #expect(layout.fadeHeight == 28)
        #expect(layout.clearHeight == 128)
        #expect(layout.fadeBottomOpacity == 0)
    }

    @Test
    func footerMaskLayoutStaysOpaqueBeforeFooterMeasurement() {
        let layout = FooterMaskMetrics.layout(
            containerHeight: 740,
            footerFrame: .zero,
            fadeHeight: FooterMaskMetrics.resolvedFadeHeight(80),
            scrollEdgeFadeOpacity: 1)

        #expect(layout.opaqueHeight == 740)
        #expect(layout.fadeHeight == 0)
        #expect(layout.clearHeight == 0)
        #expect(layout.fadeBottomOpacity == 1)
    }

    @Test
    func footerMaskContentBottomInsetMatchesMeasuredFooterArea() {
        let inset = FooterMaskMetrics.contentBottomInset(
            containerHeight: 740,
            footerFrame: FooterMaskFrame(minY: 612, height: 128))

        #expect(inset == 128)
    }

    @Test
    func footerMaskContentBottomInsetIsZeroBeforeFooterMeasurement() {
        let inset = FooterMaskMetrics.contentBottomInset(
            containerHeight: 740,
            footerFrame: .zero)

        #expect(inset == 0)
    }

    @Test
    func animatedMeshPointsAreStableWithReduceMotion() {
        let first = WhatsNewAnimatedMeshGeometry.points(phase: 0, reduceMotion: true)
        let second = WhatsNewAnimatedMeshGeometry.points(phase: 0.5, reduceMotion: true)

        #expect(first[4].x == second[4].x)
        #expect(first[4].y == second[4].y)
    }

    @Test
    func animatedMeshPointsChangeAcrossPhases() {
        let first = WhatsNewAnimatedMeshGeometry.points(phase: 0, reduceMotion: false)
        let second = WhatsNewAnimatedMeshGeometry.points(phase: 0.25, reduceMotion: false)

        #expect(abs(first[4].x - second[4].x) > 0.0001)
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
    func revealDelayStartsWithBaseDelay() {
        #expect(Tokens.Motion.revealDelay(for: 0) == Tokens.Motion.featureBaseDelay)
    }

    @Test
    func revealDelayCapsLongLists() {
        let expectedDelay = Tokens.Motion.featureBaseDelay + Tokens.Motion.maxFeatureStaggerDelay
        let actualDelay = Tokens.Motion.revealDelay(for: 100)

        #expect(abs(actualDelay - expectedDelay) < 0.0001)
    }

    @Test
    func scrollEdgeFadeQuantizesOpacity() {
        let opacity = ScrollEdgeFade.opacity(
            contentHeight: 1_000,
            visibleMaxY: 955,
            fadeHeight: 100)

        #expect(opacity == 0.45)
    }

    @Test
    func scrollEdgeFadeIsOpaqueAtScrollEnd() {
        let opacity = ScrollEdgeFade.opacity(
            contentHeight: 1_000,
            visibleMaxY: 1_000,
            fadeHeight: 100)

        #expect(opacity == 0)
    }

    @Test
    func scrollEdgeFadeIsOpaqueWhenVisibleRectExtendsPastContentEnd() {
        let opacity = ScrollEdgeFade.opacity(
            contentHeight: 1_000,
            visibleMaxY: 1_128,
            fadeHeight: 100)

        #expect(opacity == 0)
    }

    @Test
    func layoutUsesCompactPaddingAtBreakpoint() {
        let padding = LayoutMetrics.horizontalPadding(
            for: 390,
            compact: 16,
            regular: 24,
            breakpoint: 390)

        #expect(padding == 16)
    }

    @Test
    func layoutUsesRegularPaddingAboveBreakpoint() {
        let padding = LayoutMetrics.horizontalPadding(
            for: 391,
            compact: 16,
            regular: 24,
            breakpoint: 390)

        #expect(padding == 24)
    }

    private func backgroundView(_ background: WhatsNewBackground) -> some View {
        WhatsNewView(content: StyledContent(), onDismiss: {})
            .whatsNewBackground(background)
    }
}

private struct StyledContent: WhatsNewContent {
    var title: Text { Text("Styled") }
    var features: [WhatsNewFeature] {
        [
            WhatsNewFeature(
                id: "styled-feature",
                image: Image(systemName: "paintpalette.fill"),
                label: Text("Styled feature"),
                description: Text("This feature checks custom style construction.")),
        ]
    }
    var notice: WhatsNewNotice? { WhatsNewNotice(text: Text("Styled notice")) }
    var buttonText: Text { Text("Done") }
}
#endif
