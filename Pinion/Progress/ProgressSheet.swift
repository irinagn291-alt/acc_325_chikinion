import SwiftUI

/// Five-arm readout and filed grades. Stock list. The drawn radar stays on Practice.
struct ProgressScreen: View {
    @Bindable var model: PracticeModel

    var body: some View {
        NavigationStack {
            Group {
                if let warning = model.snapshot.warning {
                    StatusPage(
                        image: "pin_EmptyList",
                        title: "Progress could not be read.",
                        line: warning,
                        action: "Retry",
                        role: .quiet
                    ) {
                        Task { await model.reload() }
                    }
                } else if model.root.results.isEmpty {
                    StatusPage(
                        image: "pin_EmptyList",
                        title: "No grades filed.",
                        line: "Seal a pin to move an arm.",
                        action: "Close",
                        role: .quiet
                    ) {
                        model.sheet = nil
                    }
                } else {
                    List {
                        Section {
                            ForEach(Radar.means(for: model.root.results), id: \.axis) { mean in
                                HStack {
                                    Text(latest(mean.axis))
                                        .font(ReelType.headline)
                                        .foregroundStyle(ReelColor.ink)
                                        .frame(width: ReelSpace.s4, alignment: .leading)
                                    Text(mean.axis.plate)
                                        .font(ReelType.body)
                                        .foregroundStyle(ReelColor.ink)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(ReelFormat.mean(milli: mean.milli))
                                        .font(ReelType.caption)
                                        .foregroundStyle(ReelColor.muted)
                                }
                                .frame(minHeight: ReelSpace.hit)
                                .listRowBackground(ReelColor.surface)
                            }
                        }
                        Section {
                            ForEach(model.root.results.reversed()) { result in
                                HStack(alignment: .firstTextBaseline, spacing: ReelSpace.s2) {
                                    Text(ReelFormat.score(for: result.grade))
                                        .font(ReelType.headline)
                                        .foregroundStyle(ReelColor.ink)
                                        .frame(minWidth: ReelSpace.s6, alignment: .leading)
                                    VStack(alignment: .leading, spacing: ReelSpace.s1) {
                                        Text(result.axis.plate)
                                            .font(ReelType.body)
                                            .foregroundStyle(ReelColor.ink)
                                            .lineLimit(1)
                                        Text(result.grade.rawValue + " · " + ReelFormat.filedDay(result.day))
                                            .font(ReelType.caption)
                                            .foregroundStyle(ReelColor.muted)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .frame(minHeight: ReelSpace.hit)
                                .accessibilityElement(children: .combine)
                                .listRowBackground(ReelColor.surface)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(.regularMaterial)
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(ReelRadius.card)
    }

    private func latest(_ axis: Axis) -> String {
        model.root.results.last { $0.axis == axis }?.grade.rawValue ?? "-"
    }
}
