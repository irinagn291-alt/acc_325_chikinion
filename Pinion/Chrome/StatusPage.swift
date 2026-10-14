import SwiftUI

/// Full-page empty or error. One image, one headline, one line, one full-width action.
struct StatusPage: View {
    var image: String
    var title: String
    var line: String
    var action: String
    var role: StatusRole
    var act: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ReelSpace.s3) {
            Spacer(minLength: ReelSpace.s2)
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: ReelSpace.art, maxHeight: ReelSpace.art)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text(title)
                .font(ReelType.title)
                .foregroundStyle(ReelColor.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
            Text(line)
                .font(ReelType.body)
                .foregroundStyle(ReelColor.muted)
            Spacer(minLength: ReelSpace.s2)
            if role == .primary {
                Button(action, action: act)
                    .buttonStyle(ReelPressStyle())
            } else {
                Button(action, action: act)
                    .buttonStyle(ReelQuietStyle())
            }
        }
        .padding(ReelSpace.s3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(ReelColor.bg)
    }
}

enum StatusRole {
    case primary
    case quiet
}
