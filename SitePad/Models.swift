import Foundation

let checklistItems = [
    "Isolated supply before work",
    "Tested for dead / made safe",
    "Work area left clean",
    "Customer shown completed work",
    "Old parts removed from site",
]

enum JobStatus: String, Codable, Equatable {
    case open, scheduled, sent
}

enum SignatureState: Equatable {
    case none
    case seed
    case captured(Data)

    var isSigned: Bool { self != .none }
}

struct JobPhoto: Identifiable, Equatable {
    let id: UUID
    var imageData: Data
    var caption: String

    init(id: UUID = UUID(), imageData: Data, caption: String = "") {
        self.id = id
        self.imageData = imageData
        self.caption = caption
    }
}

struct Part: Identifiable, Equatable {
    let id: UUID
    var desc: String
    var qty: Int
    var price: Double

    init(id: UUID = UUID(), desc: String, qty: Int, price: Double) {
        self.id = id
        self.desc = desc
        self.qty = qty
        self.price = price
    }

    var lineTotal: Double { Double(qty) * price }
}

struct Job: Identifiable, Equatable {
    var id: String
    var customer: String
    var address: String
    var phone: String
    var type: String
    var status: JobStatus
    var arrived: String?
    var notes: String = ""
    var photos: [JobPhoto] = []
    var checks: [String: Bool] = [:]
    var parts: [Part] = []
    var signature: SignatureState = .none
    var signedBy: String = ""

    var partsTotal: Double { parts.reduce(0) { $0 + $1.lineTotal } }

    var notesComplete: Bool { notes.trimmingCharacters(in: .whitespacesAndNewlines).count > 10 }
    var photosComplete: Bool { !photos.isEmpty }
    var checksComplete: Bool { checklistItems.allSatisfy { checks[$0] == true } }
    var signComplete: Bool { signature.isSigned }
    var readyForReport: Bool { notesComplete && checksComplete && signComplete }
}

extension Job {
    static let placeholder = Job(
        id: "J-0000",
        customer: "",
        address: "",
        phone: "",
        type: "",
        status: .open,
        arrived: nil
    )

    static let seedJobs: [Job] = [
        Job(
            id: "J-1043",
            customer: "Marcus Webb",
            address: "14 Elmsdale Road, Unit B",
            phone: "07700 900341",
            type: "Consumer unit fault",
            status: .open,
            arrived: "08:42"
        ),
        Job(
            id: "J-1042",
            customer: "Hartley Dental",
            address: "3 Cross Street",
            phone: "07700 900118",
            type: "Emergency lighting test",
            status: .scheduled,
            arrived: nil
        ),
        Job(
            id: "J-1041",
            customer: "S. Ranganathan",
            address: "89 Balmoral Court",
            phone: "07700 900552",
            type: "Immersion heater replacement",
            status: .sent,
            arrived: "07:10",
            notes: "Replaced faulty immersion element and thermostat. Tested to 60°C, no leaks.",
            checks: Dictionary(uniqueKeysWithValues: checklistItems.map { ($0, true) }),
            parts: [Part(desc: "Immersion element 11\"", qty: 1, price: 32)],
            signature: .seed,
            signedBy: "S. Ranganathan"
        ),
    ]
}
