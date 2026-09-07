import SwiftUI

struct RootView: View {
    @StateObject private var store = JobStore()
    @State private var path: [String] = []
    @State private var showingNewJob = false
    @State private var showingReport = false
    @State private var reportJobID: String?

    var body: some View {
        NavigationStack(path: $path) {
            JobListView(store: store, onOpen: { path.append($0) }, onNew: { showingNewJob = true })
                .navigationDestination(for: String.self) { jobID in
                    JobDetailView(
                        job: store.binding(for: jobID),
                        onBack: { if !path.isEmpty { path.removeLast() } },
                        onFinish: {
                            reportJobID = jobID
                            showingReport = true
                        }
                    )
                }
        }
        .tint(Theme.amber)
        .fullScreenCover(isPresented: $showingNewJob) {
            NewJobView(
                onCancel: { showingNewJob = false },
                onCreate: { newJob in
                    store.addJob(newJob)
                    showingNewJob = false
                    path.append(newJob.id)
                }
            )
        }
        .fullScreenCover(isPresented: $showingReport) {
            if let id = reportJobID {
                ReportView(
                    job: store.binding(for: id),
                    onBack: { showingReport = false },
                    onSend: {
                        store.markSent(id)
                        showingReport = false
                        path.removeAll()
                    }
                )
            }
        }
    }
}
