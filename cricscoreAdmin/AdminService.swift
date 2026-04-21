import Foundation
import FirebaseFirestore

class AdminService: ObservableObject {
    @Published var matches: [FirebaseMatch] = []
    @Published var isSaving = false
    @Published var saveMessage: String? = nil

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func startListening() {
        listener = db.collection("matches")
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.matches = snap?.documents.compactMap {
                        try? $0.data(as: FirebaseMatch.self)
                    } ?? []
                }
            }
    }

    func stopListening() { listener?.remove() }

    func saveMatch(_ match: FirebaseMatch, completion: @escaping (Bool) -> Void) {
        isSaving = true
        var m = match
        m.updatedAt = Date()
        do {
            if let id = match.id {
                try db.collection("matches").document(id).setData(from: m)
            } else {
                _ = try db.collection("matches").addDocument(from: m)
            }
            DispatchQueue.main.async {
                self.isSaving = false
                self.saveMessage = "Saved!"
                completion(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.saveMessage = nil }
            }
        } catch {
            DispatchQueue.main.async {
                self.isSaving = false
                self.saveMessage = "Error: \(error.localizedDescription)"
                completion(false)
            }
        }
    }

    func deleteMatch(id: String) {
        db.collection("matches").document(id).delete()
    }
}

class AdminBallService: ObservableObject {
    @Published var isSaving = false
    @Published var currentOver = 0
    @Published var currentBallNumber = 1
    @Published var legalBallsInOver = 0
    @Published var totalRuns = 0
    @Published var totalWickets = 0

    private let db = Firestore.firestore()

    func addBall(_ ball: Ball, matchId: String, completion: @escaping (Bool) -> Void) {
        isSaving = true
        var b = ball
        b.timestamp = Date()
        do {
            _ = try db.collection("matches").document(matchId).collection("balls").addDocument(from: b)
            DispatchQueue.main.async {
                self.isSaving = false
                self.totalRuns += ball.totalRuns
                if ball.isWicket { self.totalWickets += 1 }
                if !ball.isWide && !ball.isNoBall {
                    self.legalBallsInOver += 1
                    self.currentBallNumber += 1
                    if self.legalBallsInOver >= 6 {
                        self.currentOver += 1
                        self.currentBallNumber = 1
                        self.legalBallsInOver = 0
                    }
                } else {
                    self.currentBallNumber += 1
                }
                completion(true)
            }
        } catch {
            DispatchQueue.main.async { self.isSaving = false; completion(false) }
        }
    }

    func undoLastBall(matchId: String, inningNumber: Int) {
        db.collection("matches").document(matchId).collection("balls")
            .whereField("inningNumber", isEqualTo: inningNumber)
            .order(by: "timestamp", descending: true).limit(to: 1)
            .getDocuments { snap, _ in
                if let doc = snap?.documents.first {
                    if let ball = try? doc.data(as: Ball.self) {
                        DispatchQueue.main.async {
                            self.totalRuns = max(0, self.totalRuns - ball.totalRuns)
                            if ball.isWicket { self.totalWickets = max(0, self.totalWickets - 1) }
                            if !ball.isWide && !ball.isNoBall {
                                if self.legalBallsInOver > 0 { self.legalBallsInOver -= 1 }
                                else if self.currentOver > 0 {
                                    self.currentOver -= 1
                                    self.legalBallsInOver = 5
                                }
                            }
                        }
                    }
                    doc.reference.delete()
                }
            }
    }

    func reset() {
        currentOver = 0; currentBallNumber = 1
        legalBallsInOver = 0; totalRuns = 0; totalWickets = 0
    }
}
