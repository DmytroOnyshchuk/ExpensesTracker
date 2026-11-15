import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: .appMain.mix(with: .appPrimary, by: 0.22), location: 0),
                .init(color: .appMain.mix(with: .appPrimary, by: 0.06), location: 0.45),
                .init(color: .appMain.mix(with: .appBlack, by: 0.35), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackground()
}
