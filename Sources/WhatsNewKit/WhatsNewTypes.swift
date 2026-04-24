import SwiftUI

public struct WhatsNewFeature: Identifiable {
    public let id = UUID()
    public let image: Image?
    public let label: Text?
    public let description: Text

    public init(image: Image? = nil, label: Text? = nil, description: Text) {
        self.image = image
        self.label = label
        self.description = description
    }

    public init(
        systemImage: String? = nil,
        label: LocalizedStringResource? = nil,
        description: LocalizedStringResource)
    {
        self.image = systemImage.map { Image(systemName: $0) }
        self.label = label.map { Text($0) }
        self.description = Text(description)
    }
}

public struct WhatsNewNotice {
    public let text: Text

    public init(text: Text) {
        self.text = text
    }
}

public protocol WhatsNewContent {
    var appIcon: Image? { get }
    var title: Text { get }
    var features: [WhatsNewFeature] { get }
    var notice: WhatsNewNotice? { get }
    var buttonText: Text { get }
}

public extension WhatsNewContent {
    var appIcon: Image? {
        nil
    }
}
