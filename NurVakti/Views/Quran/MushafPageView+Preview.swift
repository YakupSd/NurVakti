import SwiftUI

struct MushafPageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MushafPageView(page: .mock)
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone 15 Pro")
            
            MushafPageView(page: .mock)
                .previewDevice("iPad Pro (11-inch) (4th generation)")
                .previewDisplayName("iPad Pro 11\"")
        }
    }
}
