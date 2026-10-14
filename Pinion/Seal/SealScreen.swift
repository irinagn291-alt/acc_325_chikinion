import SwiftUI

/// Review key `seal`. Grade bands, stock list. The commit stays on Practice.
struct SealScreen: View {
    @Bindable var model: PracticeModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(lead)
                        .font(ReelType.body)
                        .foregroundStyle(ReelColor.ink)
                        .listRowBackground(ReelColor.surface)
                }
                Section {
                    ForEach(bands, id: \.letter) { band in
                        HStack {
                            Text(band.letter)
                                .font(ReelType.headline)
                                .foregroundStyle(ReelColor.accent)
                                .frame(width: ReelSpace.s4, alignment: .leading)
                            Text(band.name)
                                .font(ReelType.body)
                                .foregroundStyle(ReelColor.ink)
                                .lineLimit(1)
                            Spacer()
                            Text(ReelFormat.whole(band.points))
                                .font(ReelType.caption)
                                .foregroundStyle(ReelColor.muted)
                        }
                        .frame(minHeight: ReelSpace.hit)
                        .listRowBackground(ReelColor.surface)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(.regularMaterial)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { close }
        }
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(ReelRadius.card)
    }

    private var title: String { "Seal" }

    private var lead: String { "File a grade only after the number is pinned." }

    private var bands: [(letter: String, name: String, points: Int)] {
        [
            ("S", "First third", 100),
            ("A", "Middle third", 80),
            ("B", "Last third", 60),
            ("C", "Missed window", 40),
            ("D", "Early or skew", 20)
        ]
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
