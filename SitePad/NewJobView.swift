import SwiftUI
import Foundation

struct NewJobView: View {
    var onCancel: () -> Void
    var onCreate: (Job) -> Void

    @State private var customer = ""
    @State private var address = ""
    @State private var phone = ""
    @State private var type = ""

    private var canCreate: Bool {
        !customer.trimmingCharacters(in: .whitespaces).isEmpty
            && !address.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            BarHeader(title: "New job", onBack: onCancel)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    LabeledField(label: "Customer name", text: $customer, placeholder: "Marcus Webb")
                    LabeledField(label: "Site address", text: $address, placeholder: "14 Elmsdale Road")
                    LabeledField(label: "Phone", text: $phone, placeholder: "07700 900341", keyboard: .phonePad)
                    LabeledField(label: "Job type", text: $type, placeholder: "Consumer unit fault")

                    PrimaryButton(title: "Start job and clock in", action: createJob, enabled: canCreate)
                        .padding(.top, 10)

                    Text("Arrival time is recorded when you start.")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.muted)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
                .padding(20)
            }
            .background(Theme.surface)
        }
        .background(Theme.surface.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func createJob() {
        guard canCreate else { return }
        let arrivedTime = DateFormatter.hhmm.string(from: Date())
        let newJob = Job(
            id: "J-\(1044 + Int.random(in: 0..<50))",
            customer: customer,
            address: address,
            phone: phone,
            type: type.isEmpty ? "General callout" : type,
            status: .open,
            arrived: arrivedTime
        )
        onCreate(newJob)
    }
}

extension DateFormatter {
    static let hhmm: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
}
