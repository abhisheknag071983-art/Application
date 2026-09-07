import SwiftUI
import UIKit

struct PartsBlockView: View {
    @Binding var job: Job

    @State private var desc = ""
    @State private var qty = "1"
    @State private var price = ""

    var body: some View {
        BlockContainer(label: "Parts and materials") {
            VStack(spacing: 0) {
                ForEach(job.parts) { part in
                    HStack {
                        Text("\(part.qty) × \(part.desc)")
                            .font(.system(size: 15))
                        Spacer()
                        Text(currency(part.lineTotal))
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .padding(.vertical, 10)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.rule), alignment: .bottom)
                }

                if !job.parts.isEmpty {
                    HStack {
                        Text("Materials total").font(.system(size: 15, weight: .bold))
                        Spacer()
                        Text(currency(job.partsTotal)).font(.system(size: 15, weight: .bold))
                    }
                    .padding(.top, 10)
                }

                HStack(spacing: 8) {
                    TextField("Part", text: $desc)
                        .padding(13)
                        .background(Theme.card)
                        .overlay(Rectangle().stroke(Theme.rule, lineWidth: 1))
                    TextField("Qty", text: $qty)
                        .keyboardType(.numberPad)
                        .frame(width: 56)
                        .padding(13)
                        .background(Theme.card)
                        .overlay(Rectangle().stroke(Theme.rule, lineWidth: 1))
                    TextField("£", text: $price)
                        .keyboardType(.decimalPad)
                        .frame(width: 70)
                        .padding(13)
                        .background(Theme.card)
                        .overlay(Rectangle().stroke(Theme.rule, lineWidth: 1))
                }
                .font(.system(size: 15))
                .padding(.top, 12)

                SecondaryButton(title: "Add part", action: addPart)
                    .padding(.top, 8)
            }
        }
    }

    private func currency(_ value: Double) -> String {
        String(format: "£%.2f", value)
    }

    private func addPart() {
        let trimmed = desc.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        job.parts.append(Part(desc: trimmed, qty: Int(qty) ?? 1, price: Double(price) ?? 0))
        desc = ""
        qty = "1"
        price = ""
    }
}
