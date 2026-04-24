#if os(iOS) || os(macOS)
import SwiftUI

public struct WhatsNewView<Content: WhatsNewContent>: View {
    let content: Content
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var featuresVisible = false
    @State private var scrollEdgeFadeOpacity: Double = 1

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = Tokens.Platform.iconSize
    @ScaledMetric(relativeTo: .body) private var featureIconSize: CGFloat = Tokens.Platform.featureIconSize
    @ScaledMetric(relativeTo: .body) private var buttonPadding: CGFloat = Tokens.Platform.buttonVerticalPadding
    @ScaledMetric(relativeTo: .body) private var contentSpacing: CGFloat = Tokens.Platform.contentSpacing
    @ScaledMetric(relativeTo: .body) private var featureSpacing: CGFloat = Tokens.Platform.featureSpacing
    @ScaledMetric(relativeTo: .body) private var topPadding: CGFloat = Tokens.Platform.topPadding
    @ScaledMetric(relativeTo: .body) private var bottomPadding: CGFloat = Tokens.Platform.bottomPadding
    @ScaledMetric(relativeTo: .body) private var scrollEdgeFadeHeight: CGFloat = Tokens.Platform.scrollEdgeFadeHeight
    @ScaledMetric(relativeTo: .body) private var compactHorizontalPadding: CGFloat = Tokens.Layout.compactHorizontalPadding
    @ScaledMetric(relativeTo: .body) private var regularHorizontalPadding: CGFloat = Tokens.Layout.regularHorizontalPadding

    public init(content: Content, onDismiss: @escaping () -> Void) {
        self.content = content
        self.onDismiss = onDismiss
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: self.contentSpacing) {
                    WhatsNewHeaderSection(
                        content: self.content,
                        iconSize: self.iconSize)
                    WhatsNewFeatureList(
                        features: self.content.features,
                        featureSpacing: self.featureSpacing,
                        featureIconSize: self.featureIconSize,
                        featuresVisible: self.featuresVisible,
                        reduceMotion: self.reduceMotion)
                }
                .frame(maxWidth: Tokens.Layout.contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, self.horizontalPadding(for: geometry.size.width))
                .padding(.top, self.topPadding)
                .padding(.bottom, self.bottomPadding)
            }
            .scrollBounceBehavior(.basedOnSize)
            .onScrollGeometryChange(for: Double.self) { geometry in
                guard geometry.contentSize.height > 0 else { return 1 }
                let contentBottom = geometry.contentSize.height + geometry.contentInsets.bottom
                let distance = contentBottom - geometry.visibleRect.maxY
                return min(1, max(0, distance / self.scrollEdgeFadeHeight))
            } action: { _, newOpacity in
                self.scrollEdgeFadeOpacity = newOpacity
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ZStack {
                    WhatsNewFooterSection(
                        content: self.content,
                        buttonPadding: self.buttonPadding,
                        onDismiss: self.onDismiss)
                        .frame(maxWidth: Tokens.Layout.contentMaxWidth)
                        .padding(.horizontal, self.horizontalPadding(for: geometry.size.width))
                }
                .frame(maxWidth: .infinity)
                .background(alignment: .top) {
                    LinearGradient(
                        colors: [
                            Tokens.background.opacity(0),
                            Tokens.background,
                        ],
                        startPoint: .top,
                        endPoint: .bottom)
                        .frame(height: self.scrollEdgeFadeHeight)
                        .offset(y: -self.scrollEdgeFadeHeight)
                        .opacity(self.scrollEdgeFadeOpacity)
                        .allowsHitTesting(false)
                }
                .background(Tokens.background)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .interactiveDismissDisabled()
        #if os(macOS)
            .frame(minWidth: Tokens.Layout.compactSheetMinWidth, minHeight: 560)
        #endif
            .onAppear {
                self.featuresVisible = true
            }
    }

    private func horizontalPadding(for width: CGFloat) -> CGFloat {
        width < Tokens.Layout.compactWidthBreakpoint ? self.compactHorizontalPadding : self.regularHorizontalPadding
    }
}

private struct WhatsNewHeaderSection<Content: WhatsNewContent>: View {
    let content: Content
    let iconSize: CGFloat

    var body: some View {
        VStack(spacing: Tokens.Spacing.large) {
            if let appIcon = self.content.appIcon {
                appIcon
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.iconSize, height: self.iconSize)
                    .clipShape(RoundedRectangle(cornerRadius: self.iconSize * Tokens.Radius.iconScale))
                    .accessibilityHidden(true)
            }

            self.content.title
            #if os(macOS)
                .font(.title)
            #else
                .font(.largeTitle)
            #endif
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
    }
}

private struct WhatsNewFeatureList: View {
    let features: [WhatsNewFeature]
    let featureSpacing: CGFloat
    let featureIconSize: CGFloat
    let featuresVisible: Bool
    let reduceMotion: Bool

    var body: some View {
        VStack(spacing: self.featureSpacing) {
            ForEach(Array(self.features.enumerated()), id: \.offset) { index, feature in
                WhatsNewFeatureRow(
                    feature: feature,
                    index: index,
                    featureIconSize: self.featureIconSize,
                    featuresVisible: self.featuresVisible,
                    reduceMotion: self.reduceMotion)
            }
        }
    }
}

private struct WhatsNewFeatureRow: View {
    let feature: WhatsNewFeature
    let index: Int
    let featureIconSize: CGFloat
    let featuresVisible: Bool
    let reduceMotion: Bool

    var body: some View {
        let delay = Tokens.Motion.featureBaseDelay + (Double(index) * Tokens.Motion.featureStaggerDelay)
        let isVisible = self.featuresVisible

        HStack(alignment: .top, spacing: Tokens.Spacing.large) {
            if let image = self.feature.image {
                image
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: self.featureIconSize, height: self.featureIconSize)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let label = self.feature.label {
                    label
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                self.feature.description
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.leading)
            .layoutPriority(1)

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : (self.reduceMotion ? 0 : Tokens.Motion.revealOffset))
        .animation(
            self.reduceMotion ? nil : .easeOut(duration: Tokens.Motion.revealDuration).delay(delay),
            value: isVisible)
    }
}

private struct WhatsNewFooterSection<Content: WhatsNewContent>: View {
    let content: Content
    let buttonPadding: CGFloat
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: Tokens.Spacing.medium) {
            if let notice = self.content.notice {
                notice.text
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button {
                self.onDismiss()
            } label: {
                self.content.buttonText
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, self.buttonPadding)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            #if os(macOS)
                .environment(\.controlActiveState, .key)
                .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.large))
            #else
                .glassEffect(in: .rect(cornerRadius: Tokens.Radius.large))
            #endif
        }
        .padding(.vertical, Tokens.Layout.footerVerticalPadding)
    }
}

private struct WhatsNewPreviewContent: WhatsNewContent {
    var appIcon: Image? { Image(systemName: "app.gift.fill") }
    var title: Text { Text("What's New") }
    var features: [WhatsNewFeature] {
        [
            WhatsNewFeature(
                systemImage: "sparkles",
                label: "First feature",
                description: "A short description of the first feature."),
            WhatsNewFeature(
                systemImage: "bolt",
                label: "Second feature",
                description: "A short description of the second feature."),
            WhatsNewFeature(
                systemImage: "arrow.triangle.2.circlepath",
                label: "Third feature",
                description: "A short description of the third feature."),
        ]
    }
    var notice: WhatsNewNotice? {
        WhatsNewNotice(text: Text("Plus many other improvements."))
    }
    var buttonText: Text { Text("Continue") }
}

private struct LongWhatsNewPreviewContent: WhatsNewContent {
    var appIcon: Image? { Image(systemName: "square.stack.3d.up.fill") }
    var title: Text {
        Text("A much longer What's New title that needs to wrap cleanly")
    }
    var features: [WhatsNewFeature] {
        (1...10).map { index in
            WhatsNewFeature(
                systemImage: "checkmark.seal.fill",
                label: "Feature \(index) with a longer localized label",
                description: "This feature description is intentionally longer so the row wraps cleanly without clipping, overlapping, or hiding the footer action.")
        }
    }
    var notice: WhatsNewNotice? {
        WhatsNewNotice(text: Text("This notice is long enough to exercise multiline footer copy in a narrow sheet."))
    }
    var buttonText: Text {
        Text("Continue with all of these new improvements")
    }
}

#Preview("What's New") {
    WhatsNewView(content: WhatsNewPreviewContent(), onDismiss: {})
}

#Preview("What's New Long Narrow") {
    WhatsNewView(content: LongWhatsNewPreviewContent(), onDismiss: {})
        .frame(width: 320, height: 720)
}

#Preview("What's New Dark Accessibility") {
    WhatsNewView(content: LongWhatsNewPreviewContent(), onDismiss: {})
        .frame(width: 390, height: 760)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility2)
}
#endif
