import SwiftUI

@MainActor
final class JobStore: ObservableObject {
    @Published var jobs: [Job]

    init(jobs: [Job] = Job.seedJobs) {
        self.jobs = jobs
    }

    func job(_ id: String) -> Job? {
        jobs.first(where: { $0.id == id })
    }

    func binding(for id: String) -> Binding<Job> {
        Binding(
            get: { [weak self] in self?.job(id) ?? Job.placeholder },
            set: { [weak self] newValue in
                guard let self, let idx = self.jobs.firstIndex(where: { $0.id == id }) else { return }
                self.jobs[idx] = newValue
            }
        )
    }

    func addJob(_ job: Job) {
        jobs.insert(job, at: 0)
    }

    func markSent(_ id: String) {
        guard let idx = jobs.firstIndex(where: { $0.id == id }) else { return }
        jobs[idx].status = .sent
    }
}
