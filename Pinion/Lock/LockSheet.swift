import SwiftUI

/// Axis lock after five results. Roll on another arm writes LockMark and is refused.
struct LockSheet: View {
    @Bindable var model: PracticeModel

    var body: some View {
        NavigationStack {
            Group {
                if let warning = model.snapshot.warning, model.root.lockMarks.isEmpty {
                    StatusPage(
                        image: "pin_TwistHero",
                        title: "Lock could not be read.",
                        line: warning,
                        action: "Retry",
                        role: .quiet
                    ) {
                        Task { await model.reload() }
                    }
                } else if model.root.lockMarks.isEmpty && model.root.axisLock.heldAxis == nil {
                    StatusPage(
                        image: "pin_TwistHero",
                        title: "No arm is locked.",
                        line: "After five grades, the next start stays on the weakest arm until it clears the next.",
                        action: "Close",
                        role: .quiet
                    ) {
                        model.sheet = nil
                    }
                } else {
                    List {
                        Section {
                            HStack(alignment: .center, spacing: ReelSpace.s2) {
                                Image("pin_TwistHero")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: ReelSpace.s6, height: ReelSpace.s6)
                                    .clipShape(RoundedRectangle(cornerRadius: ReelRadius.chip))
                                    .accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: ReelSpace.s1) {
                                    Text(lockTitle)
                                        .font(ReelType.headline)
                                        .foregroundStyle(ReelColor.ink)
                                        .lineLimit(2)
                                    Text("A hop to another arm is refused.")
                                        .font(ReelType.caption)
                                        .foregroundStyle(ReelColor.muted)
                                }
                            }
                            .frame(minHeight: ReelSpace.hit)
                            .listRowBackground(ReelColor.surface)
                        }
                        Section {
                            ForEach(model.root.lockMarks) { mark in
                                VStack(alignment: .leading, spacing: ReelSpace.s1) {
                                    Text("\(mark.requested.plate) refused")
                                        .font(ReelType.body)
                                        .foregroundStyle(ReelColor.ink)
                                    Text(heldLine(mark))
                                        .font(ReelType.caption)
                                        .foregroundStyle(ReelColor.muted)
                                }
                                .frame(minHeight: ReelSpace.hit, alignment: .leading)
                                .listRowBackground(ReelColor.surface)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(.regularMaterial)
            .navigationTitle("Axis lock")
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

    private func heldLine(_ mark: LockMark) -> String {
        "Held " + mark.locked.plate + ", day " + ReelFormat.whole(mark.day)
    }

    private var lockTitle: String {
        if let held = model.root.axisLock.heldAxis {
            return "Locked to \(held.plate)."
        }
        return "Lock is open."
    }
}
