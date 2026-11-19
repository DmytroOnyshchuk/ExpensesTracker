import StoreKit
import SwiftUI

struct AboutView: View {
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image("AboutIcon")
                        .resizable()
                        .frame(width: 102, height: 102)
                        .padding(.bottom, 8)

                    Text(L10n.appName)
                        .font(.appRegular(24))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(L10n.aboutVersion(version))
                        .font(.appLight(15))
                        .foregroundColor(.appLabel)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))

                VStack(spacing: 0) {
                    ShareLink(item: Constants.appStoreURL) {
                        MenuRowLabel(title: L10n.aboutShare, systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.plain)

                    MenuRowDivider()

                    MenuRow(title: L10n.aboutRate, systemImage: "star", action: rate)
                }
                .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))

                Text(copyright)
                    .font(.appLight(13))
                    .foregroundColor(.appLabel)
                    .multilineTextAlignment(.center)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .appBackground()
        .navigationTitle(L10n.menuAbout)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var version: String {
        "\(Bundle.main.appVersionNumber) (\(Bundle.main.appBuildNumber))"
    }

    private var copyright: String {
        "Copyright © \(Calendar.current.component(.year, from: Date())) Dmytro Onyshchuk"
    }

    private func rate() {
        FeedbackManager.shared.buttonTapped()
        requestReview()
    }
}

#Preview("About") {
    NavigationStack {
        AboutView()
    }
}
