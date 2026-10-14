import SwiftUI

/// Three full pages. Continue and Skip both write opening speed bounds and the completion flag.
struct OnboardingScreen: View {
    var finish: () -> Void
    @State private var page = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages: [(image: String, title: String, line: String)] = [
        ("pin_Onboarding1", "Pin the live digit.", "Match the prompt on the reel."),
        ("pin_Onboarding2", "Roll, then pin.", "The window opens on the second tick."),
        ("pin_Onboarding3", "Seal files the grade.", "The radar moves after five results.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: ReelSpace.s3) {
            Spacer(minLength: ReelSpace.s2)
            Image(pages[page].image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: ReelSpace.art, maxHeight: ReelSpace.art)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text(pages[page].title)
                .font(ReelType.title)
                .foregroundStyle(ReelColor.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
            Text(pages[page].line)
                .font(ReelType.body)
                .foregroundStyle(ReelColor.muted)
            Spacer(minLength: ReelSpace.s2)
            Button(page == pages.count - 1 ? "Start" : "Continue") {
                advance()
            }
            .buttonStyle(ReelPressStyle())
            Button("Skip") {
                finish()
            }
            .buttonStyle(ReelQuietStyle())
        }
        .padding(ReelSpace.s3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(ReelColor.bg.ignoresSafeArea())
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .easeOut(duration: 0.25), value: page)
    }

    private func advance() {
        if page < pages.count - 1 {
            page += 1
        } else {
            finish()
        }
    }
}
