#if os(iOS) || os(macOS)
import SwiftUI

public struct WhatsNewView<Content: WhatsNewContent>: View {
    let content: Content
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var featuresVisible = false
    @State private var fadeOpacity: Double = 1

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = Tokens.Platform.iconSize
    @ScaledMetric(relativeTo: .body) private var featureIconSize: CGFloat = Tokens.Platform.featureIconSize
    @ScaledMetric(relativeTo: .body) private var buttonPadding: CGFloat = Tokens.Platform.buttonVerticalPadding
    @ScaledMetric(relativeTo: .body) private var contentSpacing: CGFloat = Tokens.Platform.contentSpacing
    @ScaledMetric(relativeTo: .body) private var featureSpacing: CGFloat = Tokens.Platform.featureSpacing
    @ScaledMetric(relativeTo: .body) private var topPadding: CGFloat = Tokens.Platform.topPadding
    @ScaledMetric(relativeTo: .body) private var bottomPadding: CGFloat = Tokens.Platform.bottomPadding
    @ScaledMetric(relativeTo: .body) private var gradientMaskHeight: CGFloat = Tokens.Platform.scrollEdgeFadeHeight
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
                    self.headerSection
                    self.featuresSection
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
                return min(1, max(0, distance / self.gradientMaskHeight))
            } action: { _, newOpacity in
                self.fadeOpacity = newOpacity
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ZStack {
                    self.footerSection
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
                        .frame(height: self.gradientMaskHeight)
                        .offset(y: -self.gradientMaskHeight)
                        .opacity(self.fadeOpacity)
                        .allowsHitTesting(false)
                }
                .background(Tokens.background)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .interactiveDismissDisabled()
        #if os(macOS)
            .frame(minWidth: 500, minHeight: 560)
        #endif
            .onAppear {
                self.featuresVisible = true
            }
    }

    private func horizontalPadding(for width: CGFloat) -> CGFloat {
        width < Tokens.Layout.compactWidthBreakpoint ? self.compactHorizontalPadding : self.regularHorizontalPadding
    }

    private var headerSection: some View {
        VStack(spacing: Tokens.Spacing.large) {
            if let appIcon = content.appIcon {
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

    private var featuresSection: some View {
        VStack(spacing: self.featureSpacing) {
            ForEach(Array(self.content.features.enumerated()), id: \.offset) { index, feature in
                self.featureRow(feature: feature, index: index)
            }
        }
    }

    private func featureRow(feature: WhatsNewFeature, index: Int) -> some View {
        let delay = Tokens.Motion.featureBaseDelay + (Double(index) * Tokens.Motion.featureStaggerDelay)
        let isVisible = self.featuresVisible

        return HStack(alignment: .top, spacing: Tokens.Spacing.large) {
            if let image = feature.image {
                image
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: self.featureIconSize, height: self.featureIconSize)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let label = feature.label {
                    label
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                feature.description
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

    private var footerSection: some View {
        VStack(spacing: Tokens.Spacing.medium) {
            if let notice = content.notice {
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

#Preview("What's New") {
    struct PreviewContent: WhatsNewContent {
        var title: Text { Text("What's New") }
        var features: [WhatsNewFeature] {
            [
                WhatsNewFeature(
                    image: Image(systemName: "sparkles"),
                    label: Text("First feature"),
                    description: Text("A short description of the first feature.")),
                WhatsNewFeature(
                    image: Image(systemName: "bolt"),
                    label: Text("Second feature"),
                    description: Text("A short description of the second feature.")),
                WhatsNewFeature(
                    image: Image(systemName: "arrow.triangle.2.circlepath"),
                    label: Text("Third feature"),
                    description: Text("A short description of the third feature.")),
            ]
        }
        var notice: WhatsNewNotice? {
            WhatsNewNotice(text: Text("Plus many other improvements."))
        }
        var buttonText: Text { Text("Continue") }
    }
    return WhatsNewView(content: PreviewContent(), onDismiss: {})
}
#endif
