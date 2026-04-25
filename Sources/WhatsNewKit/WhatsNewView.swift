#if os(iOS) || os(macOS)
import SwiftUI

public struct WhatsNewView<Content: WhatsNewContent>: View {
    let content: Content
    let onDismiss: () -> Void
    private var background: WhatsNewBackground = .system
    private var style: WhatsNewStyle = .standard

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var featuresVisible = false
    @State private var scrollEdgeFadeOpacity: Double = 1
    @State private var footerHeight: CGFloat = 0

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
        ZStack {
            WhatsNewBackgroundView(
                background: self.background,
                reduceMotion: self.reduceMotion)

            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: self.contentSpacing) {
                        WhatsNewHeaderSection(
                            content: self.content,
                            iconSize: self.iconSize,
                            style: self.style)
                        WhatsNewFeatureList(
                            features: self.content.features,
                            featureSpacing: self.featureSpacing,
                            featureIconSize: self.featureIconSize,
                            featuresVisible: self.featuresVisible,
                            reduceMotion: self.reduceMotion,
                            style: self.style)
                    }
                    .frame(maxWidth: Tokens.Layout.contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, self.horizontalPadding(for: geometry.size.width))
                    .padding(.top, self.topPadding)
                    .padding(.bottom, self.bottomPadding)
                }
                .scrollBounceBehavior(.basedOnSize)
                .onScrollGeometryChange(for: Double.self) { geometry in
                    ScrollEdgeFade.opacity(
                        contentHeight: geometry.contentSize.height,
                        contentBottomInset: geometry.contentInsets.bottom,
                        visibleMaxY: geometry.visibleRect.maxY,
                        fadeHeight: self.scrollEdgeFadeHeight)
                } action: { _, newOpacity in
                    if self.scrollEdgeFadeOpacity != newOpacity {
                        self.scrollEdgeFadeOpacity = newOpacity
                    }
                }
                .mask {
                    FooterContentMask(
                        footerHeight: self.footerHeight,
                        fadeHeight: self.scrollEdgeFadeHeight,
                        scrollEdgeFadeOpacity: self.scrollEdgeFadeOpacity)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    ZStack {
                        WhatsNewFooterSection(
                            content: self.content,
                            buttonPadding: self.buttonPadding,
                            style: self.style,
                            onDismiss: self.onDismiss)
                            .frame(maxWidth: Tokens.Layout.contentMaxWidth)
                            .padding(.horizontal, self.horizontalPadding(for: geometry.size.width))
                    }
                    .onGeometryChange(for: CGFloat.self) { geometry in
                        FooterMaskMetrics.quantizedHeight(geometry.size.height)
                    } action: { newHeight in
                        if self.footerHeight != newHeight {
                            self.footerHeight = newHeight
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .clipped()
        .interactiveDismissDisabled()
        .whatsNewTint(self.style.tint)
        #if os(macOS)
            .frame(minWidth: Tokens.Layout.compactSheetMinWidth, minHeight: 560)
        #endif
            .onAppear {
                self.featuresVisible = true
            }
    }

    public func whatsNewBackground(_ background: WhatsNewBackground) -> Self {
        var view = self
        view.background = background
        return view
    }

    public func whatsNewStyle(_ style: WhatsNewStyle) -> Self {
        var view = self
        view.style = style
        return view
    }

    private func horizontalPadding(for width: CGFloat) -> CGFloat {
        LayoutMetrics.horizontalPadding(
            for: width,
            compact: self.compactHorizontalPadding,
            regular: self.regularHorizontalPadding,
            breakpoint: Tokens.Layout.compactWidthBreakpoint)
    }
}

enum LayoutMetrics {
    static func horizontalPadding(
        for width: CGFloat,
        compact: CGFloat,
        regular: CGFloat,
        breakpoint: CGFloat) -> CGFloat
    {
        width <= breakpoint ? compact : regular
    }
}

enum ScrollEdgeFade {
    static let opacityStep = 0.05

    static func opacity(
        contentHeight: CGFloat,
        contentBottomInset: CGFloat,
        visibleMaxY: CGFloat,
        fadeHeight: CGFloat) -> Double
    {
        guard contentHeight > 0, fadeHeight > 0 else {
            return 1
        }

        let contentBottom = contentHeight + contentBottomInset
        let distance = contentBottom - visibleMaxY
        let rawOpacity = Double(min(1, max(0, distance / fadeHeight)))
        return self.quantize(rawOpacity)
    }

    static func quantize(_ opacity: Double, step: Double = Self.opacityStep) -> Double {
        guard step > 0 else {
            return opacity
        }

        return (opacity / step).rounded() * step
    }
}

enum FooterMaskMetrics {
    static let heightStep: CGFloat = 1

    static func quantizedHeight(_ height: CGFloat, step: CGFloat = Self.heightStep) -> CGFloat {
        guard height > 0, step > 0 else {
            return 0
        }

        return (height / step).rounded() * step
    }

    static func fadeBottomOpacity(scrollEdgeFadeOpacity: Double) -> Double {
        1 - min(1, max(0, scrollEdgeFadeOpacity))
    }
}

private struct FooterContentMask: View {
    let footerHeight: CGFloat
    let fadeHeight: CGFloat
    let scrollEdgeFadeOpacity: Double

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(.black)

            LinearGradient(
                colors: [
                    .black,
                    .black.opacity(FooterMaskMetrics.fadeBottomOpacity(
                        scrollEdgeFadeOpacity: self.scrollEdgeFadeOpacity)),
                ],
                startPoint: .top,
                endPoint: .bottom)
                .frame(height: max(0, self.fadeHeight))

            Rectangle()
                .fill(.clear)
                .frame(height: max(0, self.footerHeight))
        }
    }
}

private struct WhatsNewBackgroundView: View {
    let background: WhatsNewBackground
    let reduceMotion: Bool

    var body: some View {
        self.background
            .makeView(context: WhatsNewBackgroundContext(reduceMotion: self.reduceMotion))
            .ignoresSafeArea()
    }
}

private struct WhatsNewHeaderSection<Content: WhatsNewContent>: View {
    let content: Content
    let iconSize: CGFloat
    let style: WhatsNewStyle

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
                .whatsNewOptionalForegroundStyle(self.style.titleColor)
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
    let style: WhatsNewStyle

    var body: some View {
        VStack(spacing: self.featureSpacing) {
            ForEach(Array(self.features.enumerated()), id: \.element.id) { index, feature in
                WhatsNewFeatureRow(
                    feature: feature,
                    index: index,
                    featureIconSize: self.featureIconSize,
                    featuresVisible: self.featuresVisible,
                    reduceMotion: self.reduceMotion,
                    style: self.style)
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
    let style: WhatsNewStyle

    var body: some View {
        let delay = Tokens.Motion.revealDelay(for: self.index)
        let isVisible = self.featuresVisible

        HStack(alignment: .top, spacing: Tokens.Spacing.large) {
            if let image = self.feature.image {
                image
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: self.featureIconSize, height: self.featureIconSize)
                    .foregroundStyle(self.style.featureIconForegroundStyle)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let label = self.feature.label {
                    label
                        .font(.headline)
                        .whatsNewOptionalForegroundStyle(self.style.featureTitleColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                self.feature.description
                    .font(.subheadline)
                    .foregroundStyle(self.style.featureDescriptionForegroundStyle)
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
    let style: WhatsNewStyle
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: Tokens.Spacing.medium) {
            if let notice = self.content.notice {
                notice.text
                    .font(.caption)
                    .foregroundStyle(self.style.noticeForegroundStyle)
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
                    .whatsNewOptionalForegroundStyle(self.style.buttonForegroundColor)
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

private extension View {
    @ViewBuilder
    func whatsNewTint(_ color: Color?) -> some View {
        if let color {
            self.tint(color)
        } else {
            self
        }
    }

    @ViewBuilder
    func whatsNewOptionalForegroundStyle(_ color: Color?) -> some View {
        if let color {
            self.foregroundStyle(color)
        } else {
            self
        }
    }
}

private struct WhatsNewPreviewContent: WhatsNewContent {
    var appIcon: Image? { Image(systemName: "app.gift.fill") }
    var title: Text { Text("What's New") }
    var features: [WhatsNewFeature] {
        [
            WhatsNewFeature(
                id: "first-feature",
                systemImage: "sparkles",
                label: "First feature",
                description: "A short description of the first feature."),
            WhatsNewFeature(
                id: "second-feature",
                systemImage: "bolt",
                label: "Second feature",
                description: "A short description of the second feature."),
            WhatsNewFeature(
                id: "third-feature",
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
                id: "long-feature-\(index)",
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
