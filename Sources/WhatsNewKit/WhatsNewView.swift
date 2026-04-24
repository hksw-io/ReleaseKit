#if os(iOS) || os(macOS)
import SwiftUI

public struct WhatsNewView<Content: WhatsNewContent>: View {
    let content: Content
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var featuresVisible = false
    @State private var fadeOpacity: Double = 1

    private let featureBaseDelay = 0.3
    private let featureStaggerDelay = 0.15
    private let contentMaxWidth: CGFloat = 560

    #if os(macOS)
        @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 64
        @ScaledMetric(relativeTo: .body) private var featureIconSize: CGFloat = 24
        @ScaledMetric(relativeTo: .body) private var buttonPadding: CGFloat = 8
        @ScaledMetric(relativeTo: .body) private var contentSpacing: CGFloat = 24
        @ScaledMetric(relativeTo: .body) private var featureSpacing: CGFloat = 20
        @ScaledMetric(relativeTo: .body) private var topPadding: CGFloat = 32
        @ScaledMetric(relativeTo: .body) private var bottomPadding: CGFloat = 20
        @ScaledMetric(relativeTo: .body) private var gradientMaskHeight: CGFloat = 60
    #else
        @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 100
        @ScaledMetric(relativeTo: .body) private var featureIconSize: CGFloat = 35
        @ScaledMetric(relativeTo: .body) private var buttonPadding: CGFloat = 14
        @ScaledMetric(relativeTo: .body) private var contentSpacing: CGFloat = 38
        @ScaledMetric(relativeTo: .body) private var featureSpacing: CGFloat = 32
        @ScaledMetric(relativeTo: .body) private var topPadding: CGFloat = 32
        @ScaledMetric(relativeTo: .body) private var bottomPadding: CGFloat = 24
        @ScaledMetric(relativeTo: .body) private var gradientMaskHeight: CGFloat = 80
    #endif

    @ScaledMetric(relativeTo: .body) private var compactHorizontalPadding: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var regularHorizontalPadding: CGFloat = 24

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
                .frame(maxWidth: self.contentMaxWidth)
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
                        .frame(maxWidth: self.contentMaxWidth)
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
        width < 390 ? self.compactHorizontalPadding : self.regularHorizontalPadding
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
                    .clipShape(RoundedRectangle(cornerRadius: self.iconSize * 0.22))
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
        let delay = self.featureBaseDelay + (Double(index) * self.featureStaggerDelay)
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
        .offset(y: isVisible ? 0 : (self.reduceMotion ? 0 : 30))
        .animation(
            self.reduceMotion ? nil : .easeOut(duration: 0.4).delay(delay),
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
        .padding(.vertical, 20)
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
