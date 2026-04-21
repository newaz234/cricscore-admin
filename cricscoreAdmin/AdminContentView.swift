import SwiftUI

struct AdminContentView: View {
    @StateObject private var service = AdminService()
    @State private var showingAdd = false
    @State private var editing: FirebaseMatch? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.black).ignoresSafeArea()
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cricscore Admin")
                                .font(.system(size: 22, weight: .semibold)).foregroundColor(.white)
                            
                        }
                        Spacer()
                        Button { showingAdd = true } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .medium)).foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.green.opacity(0.25)).clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 60).padding(.bottom, 20)

                    if service.matches.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "tray").font(.system(size: 36)).foregroundColor(.white.opacity(0.2))
                            Text("No matches yet").foregroundColor(.white)
                           
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(service.matches) { match in
                                    AdminMatchRow(match: match) {
                                        editing = match
                                    } onBallEntry: {
                                        // BallEntryView navigate করবে
                                    } onDelete: {
                                        if let id = match.id { service.deleteMatch(id: id) }
                                    }
                                }
                            }
                            .padding(.horizontal, 16).padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAdd) { MatchEditorView(match: nil, service: service) }
            .sheet(item: $editing) { match in MatchEditorView(match: match, service: service) }
        }
        .onAppear  { service.startListening() }
        .onDisappear { service.stopListening() }
    }
}

// MARK: - Admin Match Row
struct AdminMatchRow: View {
    let match: FirebaseMatch
    let onEdit: () -> Void
    let onBallEntry: () -> Void
    let onDelete: () -> Void
    @State private var showingBallEntry = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(match.teamA) vs \(match.teamB)")
                        .font(.system(size: 14, weight: .medium)).foregroundColor(.white.opacity(0.9))
                    Text("\(match.matchInfo) · \(match.status)")
                        .font(.caption).foregroundColor(.white.opacity(0.4))
                    Text("\(match.teamAScore.isEmpty ? "—" : match.teamAScore)  vs  \(match.teamBScore.isEmpty ? "—" : match.teamBScore)")
                        .font(.caption).foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                HStack(spacing: 6) {
                    // Ball entry button (only for LIVE)
                    if match.status == "LIVE" {
                        Button { showingBallEntry = true } label: {
                            Image(systemName: "cricket.ball.circle.fill")
                                .font(.system(size: 22)).foregroundColor(.green)
                        }
                    }
                    Button { onEdit() } label: {
                        Image(systemName: "pencil").font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6)).frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.07)).clipShape(Circle())
                    }
                    Button { onDelete() } label: {
                        Image(systemName: "trash").font(.system(size: 13))
                            .foregroundColor(.red.opacity(0.7)).frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.1)).clipShape(Circle())
                    }
                }
            }
            .padding(14)
        }
        .background(Color(hex: "#161b27"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 0.5))
        .sheet(isPresented: $showingBallEntry) {
            BallEntryView(
                matchId: match.id ?? "",
                inningNumber: 1,
                batsmanOnStrike: "",
                batsmanOffStrike: "",
                currentBowler: ""
            )
        }
    }
}

// MARK: - Match Editor
struct MatchEditorView: View {
    let match: FirebaseMatch?
    let service: AdminService
    @Environment(\.dismiss) private var dismiss

    @State private var teamA = ""
    @State private var teamAInitials = ""
    @State private var teamAScore = ""
    @State private var teamAOvers = ""
    @State private var teamB = ""
    @State private var teamBInitials = ""
    @State private var teamBScore = ""
    @State private var teamBOvers = ""
    @State private var status = "UPCOMING"
    @State private var matchType = "T20"
    @State private var venue = ""
    @State private var result = ""
    @State private var startTime = ""
    @State private var innings: [FirebaseInnings] = []
    @State private var showingInningsEditor = false
    @State private var editingInningsIndex: Int? = nil

    let statusOptions = ["UPCOMING", "LIVE", "FINISHED"]
    let typeOptions   = ["T20", "ODI", "TEST"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.white).ignoresSafeArea()
                
                ScrollView(.vertical,showsIndicators: false)
                {
                    VStack(spacing: 16) {

                        sectionCard("Match Info")
                        {
                                segmentField("Match Type", options: typeOptions, selection: $matchType)
                                segmentField("Status", options: statusOptions, selection: $status)
                                if status == "UPCOMING" { inputField("Start Time (e.g. Apr 20, 2:30 PM)", $startTime) }
                                if status == "FINISHED"  { inputField("Result (e.g. India won by 6 wkts)", $result) }
                            }
                            
                        

                        sectionCard("Team A") {
                            inputField("Team Name (e.g. India)", $teamA)
                            HStack(spacing: 8) {
                                inputField("Initials (IND)", $teamAInitials)
                                
                                inputField("Score (185/4)", $teamAScore)
                                inputField("Overs (18.3 ovs)", $teamAOvers)
                            }
                        }

                        sectionCard("Team B") {
                            inputField("Team Name (e.g. Pakistan)", $teamB)
                            HStack(spacing: 8) {
                                inputField("Initials (PAK)", $teamBInitials)
                                inputField("Score (172/8)", $teamBScore)
                                inputField("Overs (20.0 ovs)", $teamBOvers)
                            }
                        }

                        sectionCard("Innings (Scorecard)") {
                            ForEach(Array(innings.enumerated()), id: \.offset) { i, inn in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(inn.inningTitle).font(.system(size: 13, weight: .medium)).foregroundColor(.white.opacity(0.8))
                                        Text("\(inn.totalRuns)/\(inn.totalWickets) · \(inn.batting.count) batters · \(inn.bowling.count) bowlers")
                                            .font(.caption).foregroundColor(.white.opacity(0.4))
                                    }
                                    Spacer()
                                    Button { editingInningsIndex = i; showingInningsEditor = true } label: {
                                        Image(systemName: "pencil").foregroundColor(.white.opacity(0.5))
                                            .frame(width: 28, height: 28).background(Color.white.opacity(0.07)).clipShape(Circle())
                                    }
                                    Button { innings.remove(at: i) } label: {
                                        Image(systemName: "trash").foregroundColor(.red.opacity(0.6))
                                            .frame(width: 28, height: 28).background(Color.red.opacity(0.08)).clipShape(Circle())
                                    }
                                }
                                Spacer().frame(height: 120)
                                    .padding(16)
                                    .padding(.bottom, 100)
                                
                            }
                           
                            
                            Button { editingInningsIndex = nil; showingInningsEditor = true } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill").foregroundColor(.green)
                                    Text("Add Innings").font(.system(size: 14, weight: .medium)).foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(Color.green.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .scrollDismissesKeyboard(.interactively)
                           .ignoresSafeArea(.keyboard)
                        
                        Button { save() } label: {
                            HStack {
                                if service.isSaving { ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black)).scaleEffect(0.8) }
                                else { Image(systemName: "checkmark") }
                                Text(service.isSaving ? "Saving..." : "Save to Firebase").font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.black).frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.green).clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(service.isSaving || teamA.isEmpty || teamB.isEmpty)

                        if let msg = service.saveMessage {
                            Text(msg).font(.caption).foregroundColor(msg.contains("Error") ? .red : .green)
                        }
                    }
                    .padding(16).padding(.bottom, 40)
                }
            }
            .navigationTitle(match == nil ? "New Match" : "Edit Match")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.black.opacity(0.6))
                }
            }
            .sheet(isPresented: $showingInningsEditor) {
                InningsEditorView(innings: editingInningsIndex != nil ? innings[editingInningsIndex!] : nil) { inn in
                    if let idx = editingInningsIndex { innings[idx] = inn }
                    else { innings.append(inn) }
                }
            }
        }
        .onAppear { load() }
    }

    func load() {
        guard let m = match else { return }
        teamA = m.teamA; teamAInitials = m.teamAInitials; teamAScore = m.teamAScore; teamAOvers = m.teamAOvers
        teamB = m.teamB; teamBInitials = m.teamBInitials; teamBScore = m.teamBScore; teamBOvers = m.teamBOvers
        status = m.status; matchType = m.matchType; venue = m.venue
        result = m.result ?? ""; startTime = m.startTime ?? ""; innings = m.innings ?? []
    }

    func save() {
        let m = FirebaseMatch(id: match?.id, teamA: teamA, teamAInitials: teamAInitials,
            teamAScore: teamAScore, teamAOvers: teamAOvers, teamB: teamB,
            teamBInitials: teamBInitials, teamBScore: teamBScore, teamBOvers: teamBOvers,
            status: status, matchType: matchType, venue: venue,
            result: result.isEmpty ? nil : result,
            startTime: startTime.isEmpty ? nil : startTime,
            updatedAt: Date(), innings: innings.isEmpty ? nil : innings)
        service.saveMatch(m) { if $0 { dismiss() } }
    }

    func sectionCard(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.4)).tracking(0.5)
            content()
        }
        .padding(14).background(Color(hex: "#161b27"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 0.5))
    }

    func inputField(_ placeholder: String, _ text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 14))
            .foregroundColor(.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
    }
    func segmentField(_ label: String, options: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.4))
            HStack(spacing: 0) {
                ForEach(options, id: \.self) { opt in
                    Button { selection.wrappedValue = opt } label: {
                        Text(opt).font(.system(size: 12, weight: selection.wrappedValue == opt ? .semibold : .regular))
                            .foregroundColor(selection.wrappedValue == opt ? .white : .white.opacity(0.4))
                            .frame(maxWidth: .infinity).padding(.vertical, 8)
                            .background(selection.wrappedValue == opt ? Color.white.opacity(0.15) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(3).background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AdminContentView()
    }
}
