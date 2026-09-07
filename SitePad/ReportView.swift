import SwiftUI
import UIKit

struct ReportView: View {
    @Binding var job: Job
    var onBack: () -> Void
    var onSend: () -> Void

    @State private var isSent = false
    @State private var isSharing = false
    @State private var pdfURL: URL?

    private var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "d MMMM"
        return f.string(from: Date())
    }

    var body: some View {
        Group {
            if isSent {
                sentView
            } else {
                reportView
            }
        }
        .sheet(isPresented: $isSharing) {
            if let pdfURL {
                ShareSheet(activityItems: [pdfURL]) { completed in
                    if completed { isSent = true }
                }
            }
        }
    }

    private var sentView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle().fill(Theme.green).frame(width: 60, height: 60)
                Image(systemName: "checkmark")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            }
            Text("Report sent").font(.system(size: 22, weight: .bold))
            Text("\(job.customer) has the PDF. A copy is saved against \(job.id).")
                .font(.system(size: 15))
                .foregroundColor(Theme.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            PrimaryButton(title: "Back to jobs", action: onSend)
        }
        .padding(24)
        .padding(.top, 80)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.surface.ignoresSafeArea())
    }

    private var reportView: some View {
        VStack(spacing: 0) {
            BarHeader(title: "Report preview", subtitle: "This is what the customer receives", onBack: onBack)
            ScrollView {
                ReportCard(job: job, todayString: todayString)
                    .padding(20)
                Color.clear.frame(height: 100)
            }
            .background(Theme.surface)

            VStack(spacing: 0) {
                Divider().background(Theme.rule)
                PrimaryButton(title: "Email PDF to customer", action: sharePDF)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 18)
            }
            .background(Theme.surface)
        }
        .background(Theme.surface.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func sharePDF() {
        let data = PDFGenerator.generate(for: job, dateString: todayString)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(job.id)-report.pdf")
        do {
            try data.write(to: url)
            pdfURL = url
            isSharing = true
        } catch {
            isSent = true
        }
    }
}

private struct ReportCard: View {
    let job: Job
    let todayString: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Ridgeway Electrical").font(.system(size: 18, weight: .bold))
                Text("NICEIC 84102 · 07700 900000")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.muted)
            }
            .padding(.bottom, 10)
            .overlay(Rectangle().frame(height: 3).foregroundColor(Theme.steel), alignment: .bottom)

            VStack(alignment: .leading, spacing: 4) {
                ReportRow(label: "Job", value: job.id)
                ReportRow(label: "Customer", value: job.customer)
                ReportRow(label: "Site", value: job.address)
                ReportRow(label: "Attended", value: "From \(job.arrived ?? "--:--"), \(todayString)")
                ReportRow(label: "Work", value: job.type)
            }
            .padding(.top, 16)

            SectionHeading("Work carried out")
            Text(job.notes)
                .font(.system(size: 13))
                .lineSpacing(4)

            if !job.photos.isEmpty {
                SectionHeading("Photographs")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(job.photos) { photo in
                        VStack(alignment: .leading, spacing: 4) {
                            if let uiImage = UIImage(data: photo.imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 96)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .overlay(Rectangle().stroke(Theme.rule, lineWidth: 1))
                            }
                            Text(photo.caption.isEmpty ? "No caption" : photo.caption)
                                .font(.system(size: 11))
                                .foregroundColor(Theme.muted)
                        }
                    }
                }
            }

            SectionHeading("Safety checks completed")
            ForEach(checklistItems, id: \.self) { item in
                HStack(spacing: 4) {
                    Text(job.checks[item] == true ? "✓" : "✕")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(job.checks[item] == true ? Theme.green : Theme.red)
                    Text(item).font(.system(size: 13))
                }
                .padding(.vertical, 2)
            }

            if !job.parts.isEmpty {
                SectionHeading("Parts and materials")
                ForEach(job.parts) { part in
                    HStack {
                        Text("\(part.qty) × \(part.desc)").font(.system(size: 13))
                        Spacer()
                        Text(String(format: "£%.2f", part.lineTotal)).font(.system(size: 13))
                    }
                }
                HStack {
                    Text("Total").font(.system(size: 13, weight: .bold))
                    Spacer()
                    Text(String(format: "£%.2f", job.partsTotal)).font(.system(size: 13, weight: .bold))
                }
                .padding(.top, 6)
                .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.rule), alignment: .top)
            }

            SectionHeading("Signed on completion")
            VStack(alignment: .leading, spacing: 4) {
                if case .captured(let data) = job.signature, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 60)
                }
                Text("\(job.signedBy.isEmpty ? job.customer : job.signedBy) · \(todayString)")
                    .font(.system(size: 12))
                    .padding(.top, 5)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.steel), alignment: .top)
                    .frame(width: 160, alignment: .leading)
            }
        }
        .padding(22)
        .background(Theme.card)
        .overlay(Rectangle().stroke(Theme.rule, lineWidth: 1))
        .foregroundColor(Theme.steel)
    }
}

private struct ReportRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)
                .frame(width: 88, alignment: .leading)
            Text(value).font(.system(size: 13, weight: .semibold))
        }
    }
}

private struct SectionHeading: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .padding(.top, 20)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.rule), alignment: .bottom)
    }
}
