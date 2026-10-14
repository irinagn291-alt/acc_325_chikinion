import SwiftUI

/// Local axis-emphasis plates. Not a course. Empty, filled, and unreadable states.
struct LibraryScreen: View {
    @Bindable var model: PracticeModel

    var body: some View {
        NavigationStack {
            Group {
                if let warning = model.snapshot.warning {
                    StatusPage(
                        image: "pin_EmptyList",
                        title: "Library could not be read.",
                        line: warning,
                        action: "Retry",
                        role: .quiet
                    ) {
                        Task { await model.reload() }
                    }
                } else if model.root.programs.isEmpty {
                    StatusPage(
                        image: "pin_EmptyList",
                        title: "No plates yet.",
                        line: "Add an axis emphasis for the next roll.",
                        action: "Add a plate",
                        role: .primary
                    ) {
                        if model.draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            model.draftName = "\(model.draftAxis.plate) plate"
                        }
                        Task { await model.addProgram() }
                    }
                } else {
                    List {
                        Section {
                            draft
                                .listRowBackground(ReelColor.surface)
                        }
                        Section {
                            ForEach(model.root.programs) { program in
                                Button {
                                    model.choose(program.emphasis)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: ReelSpace.s1) {
                                            Text(program.name)
                                                .font(ReelType.headline)
                                                .foregroundStyle(ReelColor.ink)
                                                .lineLimit(1)
                                            Text(program.emphasis.plate)
                                                .font(ReelType.caption)
                                                .foregroundStyle(ReelColor.muted)
                                        }
                                        Spacer()
                                        if model.selectedAxis == program.emphasis {
                                            Text("Active")
                                                .font(ReelType.micro)
                                                .foregroundStyle(ReelColor.accent)
                                        }
                                    }
                                    .frame(minHeight: ReelSpace.hit)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(ReelColor.surface)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .background(.regularMaterial)
            .navigationTitle("Library")
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

    private var draft: some View {
        VStack(alignment: .leading, spacing: ReelSpace.s2) {
            TextField("Plate name", text: $model.draftName)
                .font(ReelType.body)
                .textInputAutocapitalization(.words)
            Picker("Axis", selection: $model.draftAxis) {
                ForEach(Axis.allCases) { axis in
                    Text(axis.plate).tag(axis)
                }
            }
            .pickerStyle(.menu)
            Button("Add a plate") {
                Task { await model.addProgram() }
            }
            .buttonStyle(ReelPressStyle())
            .disabled(model.draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.vertical, ReelSpace.s1)
    }
}
