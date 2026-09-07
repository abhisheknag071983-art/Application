import SwiftUI

struct JobDetailView: View {
    @Binding var job: Job
    var onBack: () -> Void
    var onFinish: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BarHeader(title: job.customer, subtitle: subtitle, onBack: onBack)
            ScrollView {
                VStack(spacing: 0) {
                    BlockContainer(label: "Work carried out", isComplete: job.notesComplete, isRequired: true) {
                        notesEditor
                    }

                    PhotoBlockView(job: $job)

                    BlockContainer(label: "Safety checklist", isComplete: job.checksComplete, isRequired: true) {
                        VStack(spacing: 8) {
                            ForEach(checklistItems, id: \.self) { item in
                                ChecklistRow(
                                    label: item,
                                    isOn: job.checks[item] == true,
                                    toggle: { job.checks[item] = !(job.checks[item] == true) }
                                )
                            }
                        }
                    }

                    PartsBlockView(job: $job)

                    SignBlockView(job: $job)

                    Color.clear.frame(height: 100)
                }
            }
            .background(Theme.surface)

            bottomBar
        }
        .background(Theme.surface.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var notesEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $job.notes)
                .frame(minHeight: 120)
                .font(.system(size: 16))
                .padding(6)
                .background(Theme.card)
                .overlay(Rectangle().stroke(Theme.rule, lineWidth: 1))

            if job.notes.isEmpty {
                Text("Found RCD tripping on lighting circuit. Traced fault to damaged cable in loft…")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.muted)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
            }
        }
    }

    private var subtitle: String {
        "\(job.id) · on site since \(job.arrived ?? "--:--")"
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().background(Theme.rule)
            PrimaryButton(
                title: job.readyForReport ? "Build the report" : "Finish the required sections",
                action: onFinish,
                enabled: job.readyForReport
            )
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 18)
        }
        .background(Theme.surface)
    }
}

private struct ChecklistRow: View {
    let label: String
    let isOn: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 12) {
                ZStack {
                    Rectangle()
                        .fill(isOn ? Theme.green : Color.clear)
                        .frame(width: 22, height: 22)
                        .overlay(Rectangle().stroke(isOn ? Theme.green : Theme.rule, lineWidth: 2))
                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(Theme.steel)
                Spacer()
            }
            .padding(14)
            .background(isOn ? Theme.green.opacity(0.12) : Theme.card)
            .overlay(Rectangle().stroke(isOn ? Theme.green : Theme.rule, lineWidth: 1))
        }
    }
}
