import SwiftUI

// MARK: - Innings Editor
struct InningsEditorView: View {
    let innings: FirebaseInnings?
    let onSave: (FirebaseInnings) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var totalRuns = ""
    @State private var totalWickets = ""
    @State private var totalOvers = ""
    @State private var runRate = ""
    @State private var extras = ""
    @State private var batters: [FirebaseBatter] = []
    @State private var bowlers: [FirebaseBowler] = []

    @State private var bName = ""; @State private var bRuns = ""; @State private var bBalls = ""
    @State private var bSR = ""; @State private var bDismissal = "not out"
    @State private var bBowler = ""; @State private var bCatcher = ""
    @State private var wName = ""; @State private var wOvers = ""; @State private var wRuns = ""
    @State private var wWickets = ""; @State private var wEco = ""; @State private var wMaidens = ""

    let dismissalOpts = ["not out", "bowled", "catch", "lbw", "runout", "stumped", "hit wicket"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0e1117").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {

                        card("Innings Info") {
                            inp("Title (e.g. India Inning 1)", $title)
                            HStack(spacing: 8) {
                                inp("Runs", $totalRuns).keyboardType(.numberPad)
                                inp("Wkts", $totalWickets).keyboardType(.numberPad)
                                inp("Overs", $totalOvers).keyboardType(.decimalPad)
                            }
                            HStack(spacing: 8) {
                                inp("Run Rate", $runRate).keyboardType(.decimalPad)
                                inp("Extras", $extras).keyboardType(.numberPad)
                            }
                        }

                        card("Batters (\(batters.count))") {
                            ForEach(Array(batters.enumerated()), id: \.offset) { i, b in
                                HStack {
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(b.name).font(.system(size: 13)).foregroundColor(.white.opacity(0.8))
                                        Text("\(b.runs)(\(b.balls)) · \(b.dismissal)").font(.caption).foregroundColor(.white.opacity(0.4))
                                    }
                                    Spacer()
                                    Button { batters.remove(at: i) } label: {
                                        Image(systemName: "minus.circle.fill").foregroundColor(.red.opacity(0.6))
                                    }
                                }
                                Divider().background(Color.white.opacity(0.05))
                            }
                            VStack(spacing: 8) {
                                inp("Batter Name", $bName)
                                HStack(spacing: 6) {
                                    inp("Runs", $bRuns).keyboardType(.numberPad)
                                    inp("Balls", $bBalls).keyboardType(.numberPad)
                                    inp("SR", $bSR).keyboardType(.decimalPad)
                                }
                                Picker("Dismissal", selection: $bDismissal) {
                                    ForEach(dismissalOpts, id: \.self) { Text($0).tag($0) }
                                }
                                .pickerStyle(.menu).foregroundColor(.white)
                                .padding(.horizontal, 10).padding(.vertical, 8)
                                .background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 10))

                                if bDismissal != "not out" && bDismissal != "runout" && bDismissal != "hit wicket" {
                                    inp("Bowler Name", $bBowler)
                                }
                                if bDismissal == "catch" || bDismissal == "stumped" {
                                    inp("Catcher/Keeper Name", $bCatcher)
                                }
                                Button {
                                    guard !bName.isEmpty else { return }
                                    batters.append(FirebaseBatter(name: bName, runs: Int(bRuns) ?? 0,
                                        balls: Int(bBalls) ?? 0, strikeRate: Double(bSR) ?? 0,
                                        fours: 0, sixes: 0, dismissal: bDismissal,
                                        bowlerName: bBowler.isEmpty ? nil : bBowler,
                                        catcherName: bCatcher.isEmpty ? nil : bCatcher))
                                    bName = ""; bRuns = ""; bBalls = ""; bSR = ""
                                    bDismissal = "not out"; bBowler = ""; bCatcher = ""
                                } label: {
                                    Text("+ Add Batter").font(.system(size: 13, weight: .medium)).foregroundColor(.green)
                                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                                        .background(Color.green.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }

                        card("Bowlers (\(bowlers.count))") {
                            ForEach(Array(bowlers.enumerated()), id: \.offset) { i, b in
                                HStack {
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(b.name).font(.system(size: 13)).foregroundColor(.white.opacity(0.8))
                                        Text("\(String(format:"%.1f",b.overs))-\(b.maidens)-\(b.runs)-\(b.wickets) Eco:\(String(format:"%.1f",b.economy))")
                                            .font(.caption).foregroundColor(.white.opacity(0.4))
                                    }
                                    Spacer()
                                    Button { bowlers.remove(at: i) } label: {
                                        Image(systemName: "minus.circle.fill").foregroundColor(.red.opacity(0.6))
                                    }
                                }
                                Divider().background(Color.white.opacity(0.05))
                            }
                            VStack(spacing: 8) {
                                inp("Bowler Name", $wName)
                                HStack(spacing: 5) {
                                    inp("Ovs", $wOvers).keyboardType(.decimalPad)
                                    inp("Mdn", $wMaidens).keyboardType(.numberPad)
                                    inp("Runs", $wRuns).keyboardType(.numberPad)
                                    inp("Wkts", $wWickets).keyboardType(.numberPad)
                                    inp("Eco", $wEco).keyboardType(.decimalPad)
                                }
                                Button {
                                    guard !wName.isEmpty else { return }
                                    bowlers.append(FirebaseBowler(name: wName, overs: Double(wOvers) ?? 0,
                                        maidens: Int(wMaidens) ?? 0, runs: Int(wRuns) ?? 0,
                                        wickets: Int(wWickets) ?? 0, economy: Double(wEco) ?? 0))
                                    wName = ""; wOvers = ""; wMaidens = ""; wRuns = ""; wWickets = ""; wEco = ""
                                } label: {
                                    Text("+ Add Bowler").font(.system(size: 13, weight: .medium)).foregroundColor(.green)
                                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                                        .background(Color.green.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .padding(16).padding(.bottom, 40)
                }
            }
            .navigationTitle(innings == nil ? "Add Innings" : "Edit Innings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.white.opacity(0.6))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let inn = FirebaseInnings(inningTitle: title.isEmpty ? "Innings" : title,
                            totalRuns: Int(totalRuns) ?? 0, totalWickets: Int(totalWickets) ?? 0,
                            totalOvers: Double(totalOvers) ?? 0, runRate: Double(runRate),
                            batting: batters, bowling: bowlers, extras: Int(extras) ?? 0)
                        onSave(inn); dismiss()
                    }
                    .foregroundColor(.green).fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            guard let inn = innings else { return }
            title = inn.inningTitle; totalRuns = "\(inn.totalRuns)"; totalWickets = "\(inn.totalWickets)"
            totalOvers = "\(inn.totalOvers)"; extras = "\(inn.extras)"
            runRate = inn.runRate != nil ? "\(inn.runRate!)" : ""
            batters = inn.batting; bowlers = inn.bowling
        }
    }

    func card(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.4)).tracking(0.5)
            content()
        }
        .padding(14).background(Color(hex: "#161b27"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 0.5))
    }

    func inp(_ placeholder: String, _ text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 13)).foregroundColor(.white)
            .padding(.horizontal, 10).padding(.vertical, 9)
            .background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 9))
    }
}

// MARK: - Ball Entry View
struct BallEntryView: View {
    let matchId: String
    let inningNumber: Int
    let batsmanOnStrike: String
    let batsmanOffStrike: String
    let currentBowler: String

    @StateObject private var service = AdminBallService()
    @StateObject private var ballService = BallService()
    @Environment(\.dismiss) private var dismiss

    @State private var runs = 0
    @State private var isWicket = false
    @State private var isWide = false
    @State private var isNoBall = false
    @State private var isBye = false
    @State private var isFour = false
    @State private var isSix = false
    @State private var wicketType = "bowled"
    @State private var commentary = ""
    @State private var playerOut = ""
    @State private var fielder = ""
    @State private var batsman = ""
    @State private var bowler = ""

    let wicketTypes = ["bowled", "catch", "lbw", "runout", "stumped", "hit wicket"]

    var totalRunsForBall: Int {
        var r = runs
        if isWide  { r += 1 }
        if isNoBall { r += 1 }
        return r
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0e1117").ignoresSafeArea()
                VStack(spacing: 0) {
                    // Live score bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ballService.liveState.scoreDisplay)
                                .font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                            Text("Over \(ballService.liveState.overDisplay)")
                                .font(.caption).foregroundColor(.white.opacity(0.4))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("RR: \(String(format: "%.2f", ballService.liveState.runRate))")
                                .font(.system(size: 13, weight: .medium)).foregroundColor(.green)
                            Text("Over \(service.currentOver + 1), Ball \(service.legalBallsInOver + 1)")
                                .font(.caption).foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    .background(Color(hex: "#151922"))
                    .overlay(Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5), alignment: .bottom)

                    ScrollView {
                        VStack(spacing: 12) {
                            // This over
                            entryCard("This Over") {
                                HStack(spacing: 7) {
                                    ForEach(ballService.liveState.lastBalls.suffix(6)) { ball in
                                        BallMarkerView(ball: ball, size: 34)
                                    }
                                    ForEach(0..<max(0, 6 - ballService.liveState.lastBalls.suffix(6).count), id: \.self) { _ in
                                        Circle().stroke(Color.white.opacity(0.1), lineWidth: 1).frame(width: 34, height: 34)
                                    }
                                    Spacer()
                                }
                            }

                            // Players
                            entryCard("Players") {
                                HStack(spacing: 8) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Batsman").font(.caption2).foregroundColor(.white.opacity(0.35))
                                        TextField("Name", text: $batsman).font(.system(size: 13)).foregroundColor(.white)
                                            .padding(.horizontal, 10).padding(.vertical, 8)
                                            .background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 9))
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Bowler").font(.caption2).foregroundColor(.white.opacity(0.35))
                                        TextField("Name", text: $bowler).font(.system(size: 13)).foregroundColor(.white)
                                            .padding(.horizontal, 10).padding(.vertical, 8)
                                            .background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 9))
                                    }
                                }
                            }

                            // Runs
                            entryCard("Runs") {
                                HStack(spacing: 6) {
                                    ForEach([0,1,2,3,4,5,6], id: \.self) { r in
                                        Button {
                                            runs = r; isFour = r == 4; isSix = r == 6
                                        } label: {
                                            Text("\(r)").font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(runs == r ? (r==4||r==6 ? .white : .black) : .white.opacity(0.7))
                                                .frame(maxWidth: .infinity).frame(height: 44)
                                                .background(runs == r ? (r == 6 ? Color.purple : r == 4 ? Color(hex: "#1d4ed8") : Color.green) : Color.white.opacity(0.07))
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                            }

                            // Extras
                            entryCard("Extras & Special") {
                                HStack(spacing: 8) {
                                    extraToggle("Wide",    $isWide,    .orange)
                                    extraToggle("No Ball", $isNoBall,  .orange)
                                    extraToggle("Bye",     $isBye,     Color(hex: "#64748b"))
                                    extraToggle("Wicket",  $isWicket,  .red)
                                }
                            }

                            // Wicket details
                            if isWicket {
                                entryCard("Wicket Details") {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 7) {
                                            ForEach(wicketTypes, id: \.self) { wt in
                                                Button { wicketType = wt } label: {
                                                    Text(wt.capitalized).font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(wicketType == wt ? .white : .white.opacity(0.5))
                                                        .padding(.horizontal, 12).padding(.vertical, 7)
                                                        .background(wicketType == wt ? Color.red.opacity(0.3) : Color.white.opacity(0.06))
                                                        .clipShape(Capsule())
                                                        .overlay(Capsule().stroke(wicketType == wt ? Color.red.opacity(0.4) : Color.clear, lineWidth: 0.5))
                                                }
                                            }
                                        }
                                    }
                                    TextField("Player out", text: $playerOut).font(.system(size: 13)).foregroundColor(.white)
                                        .padding(.horizontal, 10).padding(.vertical, 9)
                                        .background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 9))
                                    if wicketType == "catch" || wicketType == "runout" || wicketType == "stumped" {
                                        TextField("Fielder/Catcher", text: $fielder).font(.system(size: 13)).foregroundColor(.white)
                                            .padding(.horizontal, 10).padding(.vertical, 9)
                                            .background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 9))
                                    }
                                }
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.2), lineWidth: 0.5))
                            }

                            // Commentary
                            entryCard("Commentary") {
                                let suggestion = autoCommentary()
                                if !suggestion.isEmpty {
                                    Button { commentary = suggestion } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "sparkles").font(.system(size: 11)).foregroundColor(.yellow)
                                            Text(suggestion).font(.system(size: 11)).foregroundColor(.white.opacity(0.5)).lineLimit(2)
                                            Spacer()
                                        }
                                        .padding(10).background(Color.yellow.opacity(0.05))
                                        .clipShape(RoundedRectangle(cornerRadius: 9))
                                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.yellow.opacity(0.15), lineWidth: 0.5))
                                    }
                                }
                                TextField("Add commentary...", text: $commentary, axis: .vertical)
                                    .font(.system(size: 13)).foregroundColor(.white).lineLimit(2...4)
                                    .padding(.horizontal, 10).padding(.vertical, 9)
                                    .background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 9))
                            }

                            // Submit
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Ball: \(service.currentOver).\(service.legalBallsInOver + 1)")
                                        .font(.system(size: 12)).foregroundColor(.white.opacity(0.4))
                                    Spacer()
                                    Text(isWicket ? "WICKET! \(runs)runs" : isSix ? "SIX!" : isFour ? "FOUR!" : isWide ? "Wide +1" : "\(runs) run\(runs==1 ? "" : "s")")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(isWicket ? .red : isSix ? .purple : isFour ? .blue : .green)
                                }
                                Button { submit() } label: {
                                    HStack {
                                        if service.isSaving { ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black)).scaleEffect(0.8) }
                                        else { Image(systemName: "checkmark").font(.system(size: 14, weight: .semibold)) }
                                        Text(service.isSaving ? "Saving..." : "Submit Ball").font(.system(size: 15, weight: .semibold))
                                    }
                                    .foregroundColor(.black).frame(maxWidth: .infinity).frame(height: 50)
                                    .background(isWicket ? Color.red : Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .disabled(service.isSaving || batsman.isEmpty || bowler.isEmpty)
                            }
                            .padding(.top, 4)
                        }
                        .padding(14).padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Ball Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }.foregroundColor(.white.opacity(0.6))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        service.undoLastBall(matchId: matchId, inningNumber: inningNumber)
                    } label: {
                        Image(systemName: "arrow.uturn.backward").foregroundColor(.orange)
                    }
                }
            }
        }
        .onAppear {
            batsman = batsmanOnStrike; bowler = currentBowler
            ballService.startListening(matchId: matchId, inningNumber: inningNumber)
        }
        .onDisappear { ballService.stopListening() }
    }

    func entryCard(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 10, weight: .medium)).foregroundColor(.white.opacity(0.35)).tracking(0.5)
            content()
        }
        .padding(14).background(Color(hex: "#161b27"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 0.5))
    }

    func extraToggle(_ label: String, _ isOn: Binding<Bool>, _ color: Color) -> some View {
        Button { isOn.wrappedValue.toggle() } label: {
            Text(label).font(.system(size: 12, weight: .medium))
                .foregroundColor(isOn.wrappedValue ? .white : .white.opacity(0.5))
                .frame(maxWidth: .infinity).frame(height: 36)
                .background(isOn.wrappedValue ? color.opacity(0.3) : Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9).stroke(isOn.wrappedValue ? color.opacity(0.5) : Color.clear, lineWidth: 1))
        }
    }

    func submit() {
        let ball = Ball(matchId: matchId, inningNumber: inningNumber,
            overNumber: service.currentOver, ballNumber: service.currentBallNumber,
            legalBallNumber: service.legalBallsInOver + 1,
            batsmanName: batsman, bowlerName: bowler,
            runs: runs, totalRuns: totalRunsForBall,
            isWicket: isWicket, isWide: isWide, isNoBall: isNoBall,
            isBye: isBye, isLegBye: false, isFour: isFour, isSix: isSix,
            wicketType: isWicket ? wicketType : nil,
            wicketPlayerOut: isWicket && !playerOut.isEmpty ? playerOut : nil,
            fielderName: fielder.isEmpty ? nil : fielder,
            commentary: commentary.isEmpty ? autoCommentary() : commentary,
            timestamp: Date())

        service.addBall(ball, matchId: matchId) { success in
            if success { resetForm() }
        }
    }

    func resetForm() {
        runs = 0; isWicket = false; isWide = false; isNoBall = false
        isBye = false; isFour = false; isSix = false
        wicketType = "bowled"; commentary = ""; playerOut = ""; fielder = ""
    }

    func autoCommentary() -> String {
        if isWicket {
            switch wicketType {
            case "bowled":  return "\(bowler) to \(batsman), BOWLED! Clean bowled!"
            case "catch":   return "\(bowler) to \(batsman), caught \(fielder.isEmpty ? "" : "by \(fielder)")!"
            case "lbw":     return "\(bowler) to \(batsman), LBW! Plumb in front!"
            case "runout":  return "RUN OUT! \(playerOut.isEmpty ? batsman : playerOut) is short of the crease!"
            default:        return "\(bowler) to \(batsman), OUT!"
            }
        }
        if isSix    { return "\(bowler) to \(batsman), SIX! Magnificent shot over the ropes!" }
        if isFour   { return "\(bowler) to \(batsman), FOUR! Beautifully timed!" }
        if isWide   { return "\(bowler) to \(batsman), Wide ball. +1 run." }
        if isNoBall { return "\(bowler) to \(batsman), No ball! Free hit next delivery!" }
        if runs == 0 { return "\(bowler) to \(batsman), dot ball. Well bowled." }
        return "\(bowler) to \(batsman), \(runs) run\(runs > 1 ? "s" : "")."
    }
}
