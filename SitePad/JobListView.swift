import SwiftUI
import Foundation

struct JobListView: View {
    @ObservedObject var store: JobStore
    var onOpen: (String) -> Void
    var onNew: () -> Void

    private var openJobs: [Job] { store.jobs.filter { $0.status == .open } }
    private var scheduledJobs: [Job] { store.jobs.filter { $0.status == .scheduled } }
    private var sentJobs: [Job] { store.jobs.filter { $0.status == .sent } }

    private var todayName: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: Date())
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.surface.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    SectionListView(title: "On site now", jobs: openJobs, onOpen: onOpen)
                    SectionListView(title: "Next up", jobs: scheduledJobs, onOpen: onOpen)
                    SectionListView(title: "Report sent", jobs: sentJobs, onOpen: onOpen)
                    Color.clear.frame(height: 96)
                }
            }

            bottomBar
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SITEPAD")
                .font(.system(size: 12, weight: .bold))
                .tracking(1.4)
                .foregroundColor(Theme.amber)
            Text(todayName)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Theme.surface)
            Text("\(openJobs.count + scheduledJobs.count) jobs left · \(sentJobs.count) report sent")
                .font(.system(size: 14))
                .foregroundColor(Theme.dimText)
        }
        .padding(EdgeInsets(top: 22, leading: 20, bottom: 20, trailing: 20))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.steel)
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().background(Theme.rule)
            PrimaryButton(title: "Start a new job", action: onNew)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 18)
        }
        .background(Theme.surface)
    }
}

private struct SectionListView: View {
    let title: String
    let jobs: [Job]
    let onOpen: (String) -> Void

    var body: some View {
        if !jobs.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.muted)
                ForEach(jobs) { job in
                    Button { onOpen(job.id) } label: {
                        JobRow(job: job)
                    }
                }
            }
            .padding(EdgeInsets(top: 22, leading: 20, bottom: 0, trailing: 20))
        }
    }
}

private struct JobRow: View {
    let job: Job

    private var tone: Color {
        switch job.status {
        case .open: return Theme.amber
        case .sent: return Theme.green
        case .scheduled: return Theme.muted
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(tone).frame(width: 5)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(job.customer)
                        .font(.system(size: 17, weight: .bold))
                    Spacer()
                    Text(job.id)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.muted)
                }
                Text(job.type)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.muted)
                Text(job.address)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.muted)
            }
            .padding(14)
        }
        .background(Theme.card)
        .overlay(Rectangle().stroke(Theme.rule, lineWidth: 1))
        .foregroundColor(Theme.steel)
        .padding(.bottom, 10)
    }
}
