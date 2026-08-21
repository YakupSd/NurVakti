import SwiftUI

@MainActor
struct ShareImageRenderer {
    static func render<Content: View>(view: Content, scale: CGFloat = 1.0) -> UIImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        return renderer.uiImage
    }
}
