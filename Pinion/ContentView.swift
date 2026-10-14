import SwiftUI

/// Root. Onboarding covers the reel until the completion flag is set. Launch keys are read once after that.
@MainActor
struct ContentView: View {
    var store: ReelStore
    @State private var model: PracticeModel

    init(store: ReelStore) {
        self.store = store
        _model = State(initialValue: PracticeModel(store: store))
    }

    var body: some View {
        ZStack {
            ReelColor.bg.ignoresSafeArea()
            if model.ready && model.root.onboardingComplete {
                PracticeScreen(model: model)
            } else if model.ready {
                OnboardingScreen {
                    Task { await model.finishOnboarding() }
                }
            } else {
                VStack(alignment: .leading, spacing: ReelSpace.s2) {
                    Text("Pin the number")
                        .font(ReelType.title)
                        .foregroundStyle(ReelColor.ink)
                        .redacted(reason: .placeholder)
                    if model.showSpinner {
                        ProgressView()
                            .tint(ReelColor.accent)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(ReelSpace.s3)
            }
        }
        .task { await model.boot() }
    }
}

#Preview {
    ContentView(store: ReelStore())
}
