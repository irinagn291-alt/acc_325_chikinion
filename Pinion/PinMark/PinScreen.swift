import SwiftUI

/// Review key `pin`. The match plate, separate from the home instrument.
struct PinScreen: View {
    @Bindable var model: PracticeModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: ReelSpace.s3) {
                Text(lead)
                    .font(ReelType.body)
                    .foregroundStyle(ReelColor.ink)
                Text(liveNumber)
                    .font(ReelType.display)
                    .foregroundStyle(ReelColor.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(ReelSpace.s3)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: ReelRadius.card))
                Text(windowLine)
                    .font(ReelType.caption)
                    .foregroundStyle(ReelColor.muted)
                Spacer(minLength: ReelSpace.s2)
            }
            .padding(ReelSpace.s3)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.regularMaterial)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { close }
        }
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(ReelRadius.card)
    }

    private var title: String { "Pin" }

    private var lead: String { "Pin is accepted only while the number is moving." }

    private var windowLine: String { "The window opens on the second tick and stays open for three." }

    private var liveNumber: String {
        if let pass = model.root.live.pass {
            return ReelFormat.whole(pass.prompt.digit.value)
        }
        return ReelFormat.whole(0)
    }

    private var close: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                model.sheet = nil
            } label: {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Close")
        }
    }
}
