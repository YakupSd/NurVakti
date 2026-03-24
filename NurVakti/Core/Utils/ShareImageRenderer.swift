import SwiftUI

@MainActor
struct ShareImageRenderer {
    static func render<Content: View>(view: Content) -> UIImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0 // High quality
        return renderer.uiImage
    }
}
