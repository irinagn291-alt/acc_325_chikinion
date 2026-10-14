import SwiftUI

/// Speed bounds, radar baseline, onboarding, full reset, and the contact link.
struct SettingsScreen: View {
    @Bindable var model: PracticeModel
    @State private var confirmRadar = false
    @State private var confirmAll = false

    var body: some View {
        NavigationStack {
            Group {
                if let warning = model.snapshot.warning, model.root.results.isEmpty, model.root.programs.isEmpty {
                    StatusPage(
                        image: "pin_EmptyList",
                        title: "Settings could not be read.",
                        line: warning,
                        action: "Retry",
                        role: .quiet
                    ) {
                        Task { await model.reload() }
                    }
                } else {
                    Form {
                        if model.root.results.isEmpty && model.root.bounds == .opening {
                            Section {
                                Text("Bounds are still at the opening detent.")
                                    .font(ReelType.body)
                                    .foregroundStyle(ReelColor.muted)
                            }
                        }
                        if let warning = model.snapshot.warning {
                            Section {
                                Text(warning)
                                    .font(ReelType.body)
                                    .foregroundStyle(ReelColor.ink)
                                Button("Retry") {
                                    Task { await model.reload() }
                                }
                            }
                        }
                        Section("Roll speed") {
                            Stepper(value: floorBinding, in: 1...12) {
                                Text(boundLine("Floor", model.root.bounds.floor))
                                    .font(ReelType.body)
                            }
                            Stepper(value: ceilingBinding, in: 1...12) {
                                Text(boundLine("Ceiling", model.root.bounds.ceiling))
                                    .font(ReelType.body)
                            }
                            Stepper(value: detentBinding, in: 1...12) {
                                Text(boundLine("Detent", model.root.bounds.detent))
                                    .font(ReelType.body)
                            }
                        }
                        Section {
                            Button("Reset the baseline") {
                                confirmRadar = true
                            }
                            .frame(minHeight: ReelSpace.hit)
                            Button("Run onboarding again") {
                                Task { await model.reopenOnboarding() }
                            }
                            .frame(minHeight: ReelSpace.hit)
                            Button("Reset all data") {
                                confirmAll = true
                            }
                            .buttonStyle(ReelPressStyle(destructive: true))
                        }
                        Section {
                            if let contact = URL(string: "https://pinion-reel.pro/contact-us") {
                            Link(destination: contact) {
                                Text("Contact")
                                    .font(ReelType.body)
                                    .frame(maxWidth: .infinity, minHeight: ReelSpace.hit, alignment: .leading)
                            }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .background(.regularMaterial)
            .navigationTitle("Settings")
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
            .confirmationDialog(
                "Clear the radar baseline?",
                isPresented: $confirmRadar,
                titleVisibility: .visible
            ) {
                Button("Clear baseline", role: .destructive) {
                    Task { await model.resetRadar() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Grades leave the five arms. Drills stay.")
            }
            .confirmationDialog(
                "Reset all data?",
                isPresented: $confirmAll,
                titleVisibility: .visible
            ) {
                Button("Reset all data", role: .destructive) {
                    Task { await model.resetAll() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Programs, grades, and history are removed.")
            }
        }
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(ReelRadius.card)
    }

    private func boundLine(_ name: String, _ value: Int) -> String {
        name + " " + ReelFormat.whole(value)
    }

    private var floorBinding: Binding<Int> {
        Binding(
            get: { model.root.bounds.floor },
            set: { next in
                var bounds = model.root.bounds
                bounds.floor = next
                Task { await model.applyBounds(bounds) }
            }
        )
    }

    private var ceilingBinding: Binding<Int> {
        Binding(
            get: { model.root.bounds.ceiling },
            set: { next in
                var bounds = model.root.bounds
                bounds.ceiling = next
                Task { await model.applyBounds(bounds) }
            }
        )
    }

    private var detentBinding: Binding<Int> {
        Binding(
            get: { model.root.bounds.detent },
            set: { next in
                var bounds = model.root.bounds
                bounds.detent = next
                Task { await model.applyBounds(bounds) }
            }
        )
    }
}
