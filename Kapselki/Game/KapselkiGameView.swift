import SceneKit
import SwiftUI

enum KapselkiPlayMode: String, CaseIterable, Identifiable, Equatable {
    case quick
    case tour
    case daily
    case master

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quick:
            return "Szybka partyjka".kText
        case .tour:
            return "Osiedlowy tour".kText
        case .daily:
            return "Wyzwanie dnia".kText
        case .master:
            return "Mistrz podwórka".kText
        }
    }

    var subtitle: String {
        switch self {
        case .quick:
            return "3 krótkie próby".kText
        case .tour:
            return "5 podwórkowych etapów".kText
        case .daily:
            return "jedna trasa na dziś".kText
        case .master:
            return "5 rund specjalnych".kText
        }
    }

    var iconName: String {
        switch self {
        case .quick:
            return "bolt.fill"
        case .tour:
            return "map.fill"
        case .daily:
            return "calendar.badge.clock"
        case .master:
            return "crown.fill"
        }
    }
}

enum KapselkiObjectiveKind: String, Equatable {
    case cleanRun
    case collectPowerUp
    case lowMoves
    case saveEnergy
    case styleScore
}

struct KapselkiObjective: Equatable {
    let kind: KapselkiObjectiveKind
    let title: String
    let shortTitle: String
    let hint: String
    let iconName: String
    let target: Int

    static func objective(for mode: KapselkiPlayMode, board: KapselkiBoard, stageIndex: Int, date: Date = Date()) -> KapselkiObjective {
        switch mode {
        case .quick:
            return KapselkiObjective(
                kind: .lowMoves,
                title: "Szybki finisz".kText,
                shortTitle: "Meta do 8 pstryków".kText,
                hint: "Cel: dojedź do mety w maksymalnie 8 pstryków.".kText,
                iconName: "speedometer",
                target: 8
            )
        case .tour:
            return tourObjectives[min(stageIndex, tourObjectives.count - 1)]
        case .daily:
            let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
            return dailyObjectives[(day + board.rawValue.count) % dailyObjectives.count]
        case .master:
            return masterObjectives[min(stageIndex, masterObjectives.count - 1)]
        }
    }

    func progressText(moves: Int, penalties: Int, energy: Int, style: Int, powerUps: Int) -> String {
        switch kind {
        case .cleanRun:
            return penalties == 0 ? "czysto".kText : KapselkiL10n.pick(pl: "\(penalties) wyjazd", en: "\(penalties) off track")
        case .collectPowerUp:
            return "\(min(powerUps, target))/\(target) bonus"
        case .lowMoves:
            return KapselkiL10n.pick(pl: "\(moves)/\(target) pstryków", en: "\(moves)/\(target) flicks")
        case .saveEnergy:
            return KapselkiL10n.pick(pl: "\(energy)/\(target) energii", en: "\(energy)/\(target) energy")
        case .styleScore:
            return KapselkiL10n.pick(pl: "\(style)/\(target) stylu", en: "\(style)/\(target) style")
        }
    }

    func isComplete(moves: Int, penalties: Int, energy: Int, style: Int, powerUps: Int) -> Bool {
        switch kind {
        case .cleanRun:
            return penalties == 0
        case .collectPowerUp:
            return powerUps >= target
        case .lowMoves:
            return moves > 0 && moves <= target
        case .saveEnergy:
            return energy >= target
        case .styleScore:
            return style >= target
        }
    }

    private static let tourObjectives: [KapselkiObjective] = [
        KapselkiObjective(kind: .cleanRun, title: "Czysta kreda".kText, shortTitle: "Bez wyjazdu".kText, hint: "Cel: przejedź etap bez wyjazdu za kredę.".kText, iconName: "checkmark.seal.fill", target: 0),
        KapselkiObjective(kind: .collectPowerUp, title: "Zgarnij bonus".kText, shortTitle: "Weź 1 power-up".kText, hint: "Cel: wpadnij kapslem w przynajmniej jeden bonus.".kText, iconName: "star.circle.fill", target: 1),
        KapselkiObjective(kind: .lowMoves, title: "Mało pstryków".kText, shortTitle: "Do 11 pstryków".kText, hint: "Cel: dojedź do mety w maksymalnie 11 pstryków.".kText, iconName: "hand.tap.fill", target: 11),
        KapselkiObjective(kind: .saveEnergy, title: "Zapas siły".kText, shortTitle: "60+ energii".kText, hint: "Cel: dojedź do mety z energią co najmniej 60.".kText, iconName: "bolt.heart.fill", target: 60),
        KapselkiObjective(kind: .styleScore, title: "Stylowy finał".kText, shortTitle: "120 stylu".kText, hint: "Cel: uzbieraj 120 punktów stylu.".kText, iconName: "sparkles", target: 120)
    ]

    private static let dailyObjectives: [KapselkiObjective] = [
        KapselkiObjective(kind: .collectPowerUp, title: "Dzisiejszy łup".kText, shortTitle: "Weź 1 power-up".kText, hint: "Cel dnia: zgarnij bonus i dojedź do mety.".kText, iconName: "star.circle.fill", target: 1),
        KapselkiObjective(kind: .cleanRun, title: "Czysty dzień".kText, shortTitle: "Bez wyjazdu".kText, hint: "Cel dnia: żadnego wyjazdu za kredę.".kText, iconName: "checkmark.seal.fill", target: 0),
        KapselkiObjective(kind: .saveEnergy, title: "Oszczędzaj siłę".kText, shortTitle: "55+ energii".kText, hint: "Cel dnia: zachowaj co najmniej 55 energii.".kText, iconName: "bolt.heart.fill", target: 55),
        KapselkiObjective(kind: .styleScore, title: "Podpis na asfalcie".kText, shortTitle: "110 stylu".kText, hint: "Cel dnia: zrób 110 punktów stylu.".kText, iconName: "sparkles", target: 110)
    ]

    private static let masterObjectives: [KapselkiObjective] = [
        KapselkiObjective(kind: .cleanRun, title: "Runda czystości".kText, shortTitle: "Bez wyjazdu".kText, hint: "Cel: przejedź bez wyjazdu za kredę.".kText, iconName: "checkmark.seal.fill", target: 0),
        KapselkiObjective(kind: .collectPowerUp, title: "Turbo po drodze".kText, shortTitle: "Weź 2 power-upy".kText, hint: "Cel: zbierz dwa bonusy w jednej rundzie.".kText, iconName: "star.circle.fill", target: 2),
        KapselkiObjective(kind: .lowMoves, title: "Krótka ręka".kText, shortTitle: "Do 10 pstryków".kText, hint: "Cel: meta w maksymalnie 10 pstryków.".kText, iconName: "hand.tap.fill", target: 10),
        KapselkiObjective(kind: .saveEnergy, title: "Zimna głowa".kText, shortTitle: "65+ energii".kText, hint: "Cel: finisz z energią co najmniej 65.".kText, iconName: "bolt.heart.fill", target: 65),
        KapselkiObjective(kind: .styleScore, title: "Mistrzowski styl".kText, shortTitle: "135 stylu".kText, hint: "Cel: zakończ z wynikiem stylu 135+.".kText, iconName: "sparkles", target: 135)
    ]
}

struct KapselkiCampaignStage: Identifiable, Equatable {
    let id: Int
    let board: KapselkiBoard
    let title: String
    let subtitle: String

    static let stages: [KapselkiCampaignStage] = [
        KapselkiCampaignStage(id: 0, board: .sidewalk, title: "Blokowy Chodnik".kText, subtitle: "rozgrzewka na płytach".kText),
        KapselkiCampaignStage(id: 1, board: .schoolyard, title: "Boisko z Kredą".kText, subtitle: "ciasne zakręty".kText),
        KapselkiCampaignStage(id: 2, board: .grass, title: "Trawnik za Garażem".kText, subtitle: "miękki ślizg".kText),
        KapselkiCampaignStage(id: 3, board: .sand, title: "Piaskownica Turbo".kText, subtitle: "ciężkie pstryki".kText),
        KapselkiCampaignStage(id: 4, board: .table, title: "Kuchenny Finał".kText, subtitle: "szybka gładka meta".kText)
    ]
}

struct KapselkiMasterRound: Identifiable, Equatable {
    let id: Int
    let board: KapselkiBoard
    let title: String
    let subtitle: String

    static let rounds: [KapselkiMasterRound] = [
        KapselkiMasterRound(id: 0, board: .sidewalk, title: "Czysty Start".kText, subtitle: "bez wyjazdu za kredę".kText),
        KapselkiMasterRound(id: 1, board: .schoolyard, title: "Turbo Kreda".kText, subtitle: "zgarnij dwa bonusy".kText),
        KapselkiMasterRound(id: 2, board: .grass, title: "Trawnikowy Slalom".kText, subtitle: "krótka seria pstryków".kText),
        KapselkiMasterRound(id: 3, board: .sand, title: "Piaskowy Spokój".kText, subtitle: "oszczędzaj energię".kText),
        KapselkiMasterRound(id: 4, board: .table, title: "Finał na Stole".kText, subtitle: "styl ponad wszystko".kText)
    ]
}

struct KapselkiGameView: View {
    private enum Flow {
        case menu
        case intro
        case setup
        case race
    }

    private struct IntroSlide: Identifiable {
        let id: Int
        let iconName: String
        let title: String
        let body: String
        let color: Color
    }

    private let introSlides = [
        IntroSlide(id: 0, iconName: "hand.tap.fill", title: "Pstryknij".kText, body: "Dotknij kapsla, odciągnij palec i puść. Im dalej odciągniesz, tym mocniejszy strzał.".kText, color: KapselkiTheme.yellow),
        IntroSlide(id: 1, iconName: "scope", title: "Trzymaj kredę".kText, body: "Jedź między kredowymi liniami. Wyjazd poza trasę zabiera energię i psuje styl.".kText, color: KapselkiTheme.blue),
        IntroSlide(id: 2, iconName: "person.3.fill", title: "Wybierz ekipę".kText, body: "Każda postać ma własny kapsel: inną moc, kontrolę i spin. Dobierz styl do planszy.".kText, color: KapselkiTheme.orange)
    ]

    @State private var flow: Flow = .menu
    @State private var introIndex = 0
    @State private var selectedPlayMode: KapselkiPlayMode = .quick
    @State private var selectedStageIndex = 0
    @State private var selectedBoard: KapselkiBoard = .sidewalk
    @State private var selectedCharacter = KapselkiCharacter.defaultCharacter
    @State private var lockedCharacterNotice: String?
    @State private var unlockBanner: String?
    @AppStorage("kapselki.unlockedCharacters") private var unlockedCharactersRaw = ""

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                KapselkiTheme.sky
                    .ignoresSafeArea()

                backgroundTable

                switch flow {
                case .menu:
                    menuScreen(proxy: proxy)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                case .intro:
                    introScreen(proxy: proxy)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                case .setup:
                    setupScreen(proxy: proxy)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                case .race:
                    KapselkiRaceView(
                        playMode: selectedPlayMode,
                        selectedBoard: selectedBoard,
                        selectedCharacter: selectedCharacter,
                        selectedObjective: currentObjective,
                        stageIndex: selectedStageIndex,
                        stageCount: currentStageCount,
                        onExit: { flow = .setup },
                        onAdvanceStage: advanceSeriesStage,
                        onRestartSeries: restartSeries,
                        onUnlockCharacter: unlockCharacter
                    )
                    .transition(.opacity)
                }
            }
            .animation(.snappy(duration: 0.22), value: flow)
        }
        .preferredColorScheme(.light)
    }

    private var backgroundTable: some View {
        ZStack {
            KapselkiTheme.paper.opacity(0.48)

            ForEach(0..<7, id: \.self) { index in
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(tableAccentColor(index).opacity(index.isMultiple(of: 2) ? 0.24 : 0.18))
                    .frame(width: index.isMultiple(of: 2) ? 210 : 148, height: index.isMultiple(of: 3) ? 20 : 14)
                    .rotationEffect(.degrees(tableAccentRotation(index)))
                    .offset(x: tableAccentOffset(index).width, y: tableAccentOffset(index).height)
            }

            VStack(spacing: 38) {
                ForEach(0..<9, id: \.self) { _ in
                    Rectangle()
                        .fill(KapselkiTheme.ink.opacity(0.06))
                        .frame(height: 1)
                }
            }
            .rotationEffect(.degrees(-7))

            HStack(spacing: 44) {
                ForEach(0..<5, id: \.self) { _ in
                    Rectangle()
                        .fill(KapselkiTheme.ink.opacity(0.04))
                        .frame(width: 1)
                }
            }
            .rotationEffect(.degrees(-7))

            ForEach(0..<18, id: \.self) { index in
                Rectangle()
                    .fill(tableAccentColor(index + 2).opacity(0.30))
                    .frame(width: index.isMultiple(of: 3) ? 18 : 10, height: 3)
                    .rotationEffect(.degrees(Double((index % 5) * 22 - 34)))
                    .offset(
                        x: CGFloat((index % 6) * 72 - 190),
                        y: CGFloat((index / 6) * 130 - 145)
                    )
            }
        }
        .ignoresSafeArea()
    }

    private func tableAccentColor(_ index: Int) -> Color {
        let palette = [
            KapselkiTheme.red,
            KapselkiTheme.blue,
            KapselkiTheme.yellow,
            KapselkiTheme.green,
            KapselkiTheme.orange,
            Color(red: 0.55, green: 0.36, blue: 0.70),
            Color(red: 0.10, green: 0.60, blue: 0.66)
        ]
        return palette[index % palette.count]
    }

    private func tableAccentRotation(_ index: Int) -> Double {
        [-16, 9, -7, 14, -12, 6, 18][index % 7]
    }

    private func tableAccentOffset(_ index: Int) -> CGSize {
        let offsets = [
            CGSize(width: -170, height: -260),
            CGSize(width: 156, height: -210),
            CGSize(width: -218, height: -42),
            CGSize(width: 205, height: 36),
            CGSize(width: -118, height: 208),
            CGSize(width: 86, height: 256),
            CGSize(width: 232, height: -88)
        ]
        return offsets[index % offsets.count]
    }

    private func menuScreen(proxy: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: proxy.safeAreaInsets.top + 16)

            HStack(spacing: -12) {
                ForEach(KapselkiCharacter.roster.prefix(5)) { character in
                    capAvatar(character, size: 58, selected: character == selectedCharacter)
                }
            }

            VStack(spacing: 4) {
                Text("KAPSELKI")
                    .font(.system(size: min(54, proxy.size.width * 0.15), weight: .black, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink)
                    .lineLimit(1)

                Text("podwórkowy pstryk na kilka minut".kText)
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundStyle(KapselkiTheme.ink.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                colorTabs
                menuBadgeRow
            }

            VStack(spacing: 8) {
                primaryButton(title: "SZYBKA PARTYJKA".kText, iconName: "bolt.fill") {
                    selectedPlayMode = .quick
                    flow = .setup
                }

                primaryButton(title: "OSIEDLOWY TOUR".kText, iconName: "map.fill", color: KapselkiTheme.blue, foreground: KapselkiTheme.paper) {
                    selectedPlayMode = .tour
                    selectedStageIndex = stageIndex(for: selectedBoard)
                    flow = .setup
                }

                primaryButton(title: "WYZWANIE DNIA".kText, iconName: "calendar.badge.clock", color: KapselkiTheme.green, foreground: KapselkiTheme.ink) {
                    selectedPlayMode = .daily
                    selectedBoard = dailyChallengeBoard()
                    selectedStageIndex = 0
                    flow = .setup
                }

                primaryButton(title: "MISTRZ PODWÓRKA".kText, iconName: "crown.fill", color: KapselkiTheme.red, foreground: KapselkiTheme.paper) {
                    selectedPlayMode = .master
                    selectedStageIndex = 0
                    selectedBoard = KapselkiMasterRound.rounds[0].board
                    flow = .setup
                }

                Button {
                    introIndex = 0
                    flow = .intro
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 15, weight: .black))

                        Text("O CO CHODZI".kText)
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                    }
                    .foregroundStyle(KapselkiTheme.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(.white.opacity(0.38), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)

            Spacer()

            quickLoadout
                .padding(.horizontal, 14)
                .padding(.bottom, max(18, proxy.safeAreaInsets.bottom + 12))
        }
        .padding(.horizontal, 10)
    }

    private var colorTabs: some View {
        HStack(spacing: 5) {
            ForEach(0..<7, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(tableAccentColor(index))
                    .frame(width: index.isMultiple(of: 2) ? 28 : 18, height: 6)
                    .rotationEffect(.degrees(index.isMultiple(of: 2) ? -4 : 4))
            }
        }
        .padding(.top, 4)
    }

    private var menuBadgeRow: some View {
        HStack(spacing: 6) {
            retroBadge("OSIEDLE '86".kText, color: KapselkiTheme.yellow)
            retroBadge("PSTRYK".kText, color: KapselkiTheme.red, foreground: KapselkiTheme.paper)
            retroBadge("BONUSY".kText, color: KapselkiTheme.green)
        }
        .padding(.top, 6)
    }

    private func retroBadge(_ text: String, color: Color, foreground: Color = KapselkiTheme.ink) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .black, design: .monospaced))
            .foregroundStyle(foreground)
            .padding(.horizontal, 7)
            .frame(height: 18)
            .background(color, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .rotationEffect(.degrees(text.count.isMultiple(of: 2) ? -2 : 2))
    }

    private var quickLoadout: some View {
        HStack(spacing: 10) {
            capAvatar(selectedCharacter, size: 54, selected: true)

            VStack(alignment: .leading, spacing: 2) {
                Text(selectedCharacter.localizedName)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink)
                    .lineLimit(1)

                Text("\(selectedCharacter.localizedStyle) · \(selectedBoard.title)")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundStyle(KapselkiTheme.ink.opacity(0.56))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                Text(selectedPlayMode.subtitle.uppercased())
                    .font(.system(size: 8, weight: .black, design: .monospaced))
                    .foregroundStyle(selectedCharacter.color)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Button {
                flow = .setup
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(KapselkiTheme.ink)
                    .frame(width: 44, height: 40)
                    .background(KapselkiTheme.yellow, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Wybór kapsla".kText)
        }
        .padding(10)
        .kapselkiPanel()
    }

    private func stageIndex(for board: KapselkiBoard) -> Int {
        KapselkiCampaignStage.stages.firstIndex { $0.board == board } ?? 0
    }

    private var currentStageCount: Int {
        switch selectedPlayMode {
        case .quick, .daily:
            return 1
        case .tour:
            return KapselkiCampaignStage.stages.count
        case .master:
            return KapselkiMasterRound.rounds.count
        }
    }

    private var currentObjective: KapselkiObjective {
        KapselkiObjective.objective(for: selectedPlayMode, board: selectedBoard, stageIndex: selectedStageIndex)
    }

    private func dailyChallengeBoard(date: Date = Date()) -> KapselkiBoard {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let boards = KapselkiBoard.allCases
        return boards[day % boards.count]
    }

    private func advanceSeriesStage() {
        switch selectedPlayMode {
        case .tour:
            let nextIndex = min(selectedStageIndex + 1, KapselkiCampaignStage.stages.count - 1)
            selectedStageIndex = nextIndex
            selectedBoard = KapselkiCampaignStage.stages[nextIndex].board
        case .master:
            let nextIndex = min(selectedStageIndex + 1, KapselkiMasterRound.rounds.count - 1)
            selectedStageIndex = nextIndex
            selectedBoard = KapselkiMasterRound.rounds[nextIndex].board
        case .quick, .daily:
            break
        }
    }

    private func restartSeries() {
        switch selectedPlayMode {
        case .tour:
            selectedStageIndex = 0
            selectedBoard = KapselkiCampaignStage.stages[0].board
        case .master:
            selectedStageIndex = 0
            selectedBoard = KapselkiMasterRound.rounds[0].board
        case .quick, .daily:
            break
        }
    }

    private func introScreen(proxy: GeometryProxy) -> some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    flow = .menu
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(KapselkiTheme.ink)
                        .frame(width: 42, height: 38)
                        .background(.white.opacity(0.36), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)

                Spacer()

                Text("JAK SIĘ GRA".kText)
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundStyle(KapselkiTheme.ink.opacity(0.62))
            }
            .padding(.horizontal, 14)
            .padding(.top, max(12, proxy.safeAreaInsets.top + 8))

            TabView(selection: $introIndex) {
                ForEach(introSlides) { slide in
                    VStack(spacing: 18) {
                        Image(systemName: slide.iconName)
                            .font(.system(size: 42, weight: .black))
                            .foregroundStyle(KapselkiTheme.ink)
                            .frame(width: 96, height: 96)
                            .background(slide.color, in: Circle())

                        Text(slide.title)
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(KapselkiTheme.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Text(slide.body)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(KapselkiTheme.ink.opacity(0.72))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 22)
                    }
                    .tag(slide.id)
                    .padding(.horizontal, 22)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            primaryButton(title: introIndex == introSlides.count - 1 ? "WYBIERZ KAPSEL".kText : "DALEJ".kText, iconName: "arrow.right") {
                if introIndex < introSlides.count - 1 {
                    introIndex += 1
                } else {
                    flow = .setup
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, max(18, proxy.safeAreaInsets.bottom + 10))
        }
    }

    private func setupScreen(proxy: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button {
                    flow = .menu
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(KapselkiTheme.ink)
                        .frame(width: 42, height: 38)
                        .background(.white.opacity(0.36), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 1) {
                    Text(setupTitle)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(KapselkiTheme.ink)

                    Text(setupSubtitle)
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundStyle(KapselkiTheme.ink.opacity(0.56))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.top, 0)
            .padding(.bottom, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    selectedLoadoutCard
                    objectiveSetupCard
                    if let unlockBanner {
                        unlockInfoCard(text: unlockBanner, iconName: "sparkles", color: KapselkiTheme.green)
                    }
                    if let lockedCharacterNotice {
                        unlockInfoCard(text: lockedCharacterNotice, iconName: "lock.fill", color: KapselkiTheme.yellow)
                    }
                    characterSelection
                    boardSelection
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 92)
            }
        }
        .overlay(alignment: .bottom) {
            primaryButton(title: setupStartTitle, iconName: "flag.checkered") {
                flow = .race
            }
            .padding(.horizontal, 24)
            .padding(.bottom, max(18, proxy.safeAreaInsets.bottom + 10))
        }
    }

    private var setupTitle: String {
        switch selectedPlayMode {
        case .quick:
            return "SZYBKA PARTYJKA".kText
        case .tour:
            return "OSIEDLOWY TOUR".kText
        case .daily:
            return "WYZWANIE DNIA".kText
        case .master:
            return "MISTRZ PODWÓRKA".kText
        }
    }

    private var setupStartTitle: String {
        switch selectedPlayMode {
        case .quick:
            return "START 3 PRÓB".kText
        case .tour:
            return "START ETAPU".kText
        case .daily:
            return "START DNIA".kText
        case .master:
            return "START RUNDY".kText
        }
    }

    private var setupSubtitle: String {
        switch selectedPlayMode {
        case .quick:
            return KapselkiL10n.pick(pl: "\(selectedCharacter.localizedName) · \(selectedBoard.title) · 3 próby", en: "\(selectedCharacter.localizedName) · \(selectedBoard.title) · 3 runs")
        case .tour:
            let stage = KapselkiCampaignStage.stages[selectedStageIndex]
            return KapselkiL10n.pick(pl: "Etap \(selectedStageIndex + 1)/\(KapselkiCampaignStage.stages.count) · \(stage.title)", en: "Stage \(selectedStageIndex + 1)/\(KapselkiCampaignStage.stages.count) · \(stage.title)")
        case .daily:
            return KapselkiL10n.pick(pl: "Dzisiaj · \(dailyChallengeBoard().title) · \(currentObjective.shortTitle)", en: "Today · \(dailyChallengeBoard().title) · \(currentObjective.shortTitle)")
        case .master:
            let round = KapselkiMasterRound.rounds[selectedStageIndex]
            return KapselkiL10n.pick(pl: "Runda \(selectedStageIndex + 1)/\(KapselkiMasterRound.rounds.count) · \(round.title)", en: "Round \(selectedStageIndex + 1)/\(KapselkiMasterRound.rounds.count) · \(round.title)")
        }
    }

    private var unlockedCharacterIDs: Set<String> {
        Set(unlockedCharactersRaw.split(separator: ",").map(String.init))
    }

    private func isCharacterUnlocked(_ character: KapselkiCharacter) -> Bool {
        character.unlockRequirement == nil || unlockedCharacterIDs.contains(character.id)
    }

    private func unlockCharacter(id: String) -> String? {
        guard let character = KapselkiCharacter.roster.first(where: { $0.id == id }),
              character.unlockRequirement != nil,
              !isCharacterUnlocked(character)
        else {
            return nil
        }

        var ids = unlockedCharacterIDs
        ids.insert(id)
        unlockedCharactersRaw = ids.sorted().joined(separator: ",")
        unlockBanner = KapselkiL10n.pick(pl: "\(character.localizedName) odblokowany!", en: "\(character.localizedName) unlocked!")
        lockedCharacterNotice = nil
        return character.localizedName
    }

    private func unlockInfoCard(text: String, iconName: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(KapselkiTheme.ink)
                .frame(width: 32, height: 30)
                .background(color, in: RoundedRectangle(cornerRadius: 7, style: .continuous))

            Text(text)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(KapselkiTheme.ink.opacity(0.76))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 0)
        }
        .padding(9)
        .background(.white.opacity(0.26), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var selectedLoadoutCard: some View {
        HStack(spacing: 14) {
            capAvatar(selectedCharacter, size: 86, selected: true)

            VStack(alignment: .leading, spacing: 6) {
                Text(selectedCharacter.localizedName)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(selectedCharacter.localizedStyle.uppercased())
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(selectedCharacter.color)

                Text(selectedCharacter.trait.uppercased())
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundStyle(KapselkiTheme.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)

                Text(selectedCharacter.localizedCapDescription)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink.opacity(0.66))
                    .lineLimit(2)

                characterStatsRow
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .kapselkiPanel()
    }

    private var objectiveSetupCard: some View {
        HStack(spacing: 10) {
            Image(systemName: currentObjective.iconName)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(KapselkiTheme.ink)
                .frame(width: 46, height: 42)
                .background(KapselkiTheme.yellow, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(currentObjective.title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(currentObjective.hint)
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(KapselkiTheme.ink.opacity(0.62))
                    .lineLimit(2)
                    .minimumScaleFactor(0.70)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(KapselkiTheme.green.opacity(0.18), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(KapselkiTheme.ink.opacity(0.12), lineWidth: 1)
        )
    }

    private var characterStatsRow: some View {
        HStack(spacing: 6) {
            statPill(KapselkiL10n.pick(pl: "MOC", en: "PWR"), selectedCharacter.powerScore, KapselkiTheme.red)
            statPill(KapselkiL10n.pick(pl: "CEL", en: "AIM"), selectedCharacter.controlScore, KapselkiTheme.blue)
            statPill("SPIN", selectedCharacter.spinScore, KapselkiTheme.green)
        }
    }

    private func statPill(_ label: String, _ value: Int, _ color: Color) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(size: 7, weight: .black, design: .monospaced))

            Text(String(repeating: "●", count: max(1, min(7, value))))
                .font(.system(size: 7, weight: .black, design: .monospaced))
        }
        .foregroundStyle(KapselkiTheme.ink)
        .padding(.horizontal, 6)
        .frame(height: 20)
        .background(color.opacity(0.22), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var characterSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EKIPA".kText)
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundStyle(KapselkiTheme.ink.opacity(0.58))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 78), spacing: 8)], spacing: 8) {
                ForEach(KapselkiCharacter.roster) { character in
                    let isUnlocked = isCharacterUnlocked(character)
                    Button {
                        if isUnlocked {
                            selectedCharacter = character
                            lockedCharacterNotice = nil
                            unlockBanner = nil
                        } else {
                            lockedCharacterNotice = character.localizedUnlockRequirement ?? "Ta postać jest jeszcze zablokowana.".kText
                            unlockBanner = nil
                        }
                    } label: {
                        VStack(spacing: 5) {
                            ZStack(alignment: .bottomTrailing) {
                                capAvatar(character, size: 54, selected: selectedCharacter == character && isUnlocked)
                                    .saturation(isUnlocked ? 1 : 0.08)
                                    .opacity(isUnlocked ? 1 : 0.48)

                                if !isUnlocked {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundStyle(KapselkiTheme.paper)
                                        .frame(width: 22, height: 20)
                                        .background(KapselkiTheme.ink.opacity(0.78), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                                        .offset(x: 2, y: 2)
                                }
                            }

                            Text(character.localizedShortName.uppercased())
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .foregroundStyle(isUnlocked ? KapselkiTheme.ink : KapselkiTheme.ink.opacity(0.42))
                                .lineLimit(1)
                                .minimumScaleFactor(0.62)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 78)
                        .background(
                            selectedCharacter == character && isUnlocked ? character.color.opacity(0.18) : (isUnlocked ? .white.opacity(0.28) : KapselkiTheme.ink.opacity(0.08)),
                            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var boardSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(boardSelectionTitle)
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundStyle(KapselkiTheme.ink.opacity(0.58))

            VStack(spacing: 8) {
                switch selectedPlayMode {
                case .quick:
                    ForEach(KapselkiBoard.allCases) { board in
                        boardButton(
                            title: board.title,
                            subtitle: board.subtitle,
                            iconName: board.iconName,
                            tint: board.tint,
                            isSelected: selectedBoard == board
                        ) {
                            selectedBoard = board
                            selectedStageIndex = stageIndex(for: board)
                        }
                    }
                case .tour:
                    ForEach(KapselkiCampaignStage.stages) { stage in
                        boardButton(
                            title: "\(stage.id + 1). \(stage.title)",
                            subtitle: stage.subtitle,
                            iconName: stage.board.iconName,
                            tint: stage.board.tint,
                            isSelected: selectedStageIndex == stage.id
                        ) {
                            selectedStageIndex = stage.id
                            selectedBoard = stage.board
                        }
                    }
                case .daily:
                    dailyBoardSelectionButton
                case .master:
                    ForEach(KapselkiMasterRound.rounds) { round in
                        boardButton(
                            title: "\(round.id + 1). \(round.title)",
                            subtitle: "\(round.subtitle) · \(KapselkiObjective.objective(for: .master, board: round.board, stageIndex: round.id).shortTitle)",
                            iconName: round.board.iconName,
                            tint: round.board.tint,
                            isSelected: selectedStageIndex == round.id
                        ) {
                            selectedStageIndex = round.id
                            selectedBoard = round.board
                        }
                    }
                }
            }
        }
    }

    private var dailyBoardSelectionButton: some View {
        let board = dailyChallengeBoard()
        return boardButton(
            title: KapselkiL10n.pick(pl: "Dzisiaj: \(board.title)", en: "Today: \(board.title)"),
            subtitle: "\(board.subtitle) · \(currentObjective.shortTitle)",
            iconName: board.iconName,
            tint: board.tint,
            isSelected: true
        ) {
            selectedBoard = board
            selectedStageIndex = 0
        }
    }

    private var boardSelectionTitle: String {
        switch selectedPlayMode {
        case .quick:
            return "PLANSZE".kText
        case .tour:
            return "ETAPY TOURU".kText
        case .daily:
            return "TRASA DNIA".kText
        case .master:
            return "RUNDY MISTRZA".kText
        }
    }

    private func boardButton(
        title: String,
        subtitle: String,
        iconName: String,
        tint: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(isSelected ? KapselkiTheme.ink : KapselkiTheme.paper)
                    .frame(width: 42, height: 38)
                    .background(isSelected ? tint : KapselkiTheme.ink.opacity(0.58), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(KapselkiTheme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(subtitle)
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(KapselkiTheme.ink.opacity(0.54))
                        .lineLimit(1)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(tint)
                }
            }
            .padding(9)
            .background(isSelected ? tint.opacity(0.16) : .white.opacity(0.24), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func capAvatar(_ character: KapselkiCharacter, size: CGFloat, selected: Bool) -> some View {
        Image(character.portraitAssetName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .background(
                Circle()
                    .fill(selected ? character.color.opacity(0.22) : KapselkiTheme.paper.opacity(0.40))
                    .scaleEffect(selected ? 1.18 : 1.04)
            )
            .overlay(
                Circle()
                    .stroke(character.color, lineWidth: selected ? 4 : 2)
            )
            .scaleEffect(selected ? 1.06 : 1)
            .rotationEffect(.degrees(selected ? -3 : 0))
            .shadow(color: .black.opacity(selected ? 0.18 : 0.08), radius: selected ? 8 : 3, x: 0, y: selected ? 4 : 2)
            .animation(.spring(response: 0.24, dampingFraction: 0.74), value: selected)
    }

    private func primaryButton(
        title: String,
        iconName: String,
        color: Color = KapselkiTheme.yellow,
        foreground: Color = KapselkiTheme.ink,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .black))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(KapselkiTheme.ink.opacity(0.16), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct KapselkiRaceView: View {
    @StateObject private var controller = KapselkiSceneController()
    @StateObject private var audioPlayer = KapselkiAudioPlayer()
    let playMode: KapselkiPlayMode
    let selectedBoard: KapselkiBoard
    let selectedCharacter: KapselkiCharacter
    let selectedObjective: KapselkiObjective
    let stageIndex: Int
    let stageCount: Int
    let onExit: () -> Void
    let onAdvanceStage: () -> Void
    let onRestartSeries: () -> Void
    let onUnlockCharacter: (String) -> String?
    @State private var dragStart: CGPoint?
    @State private var isCameraControlVisible = false
    @State private var cameraStickOffset = CGSize.zero
    @State private var cameraLiftStickOffset: CGFloat = 0
    @State private var cameraZoomStickOffset: CGFloat = 0
    @State private var quickAttempt = 1
    @State private var feedbackToast: String?
    @State private var feedbackToastID = UUID()

    private let quickAttemptLimit = 3

    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height
            let sidePadding = isLandscape ? max(12, proxy.safeAreaInsets.leading + 8) : (proxy.size.width < 430 ? 10 : 14)

            ZStack {
                KapselkiSceneView(controller: controller)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .highPriorityGesture(flickGesture(in: proxy.size))
                    .accessibilityHidden(true)

                VStack(spacing: 0) {
                    topHUD(proxy: proxy, compact: isLandscape)

                    Spacer(minLength: 0)

                    bottomDock(proxy: proxy, compact: isLandscape)
                }
                .padding(.horizontal, sidePadding)
                .padding(.top, 0)
                .padding(.bottom, isLandscape ? max(8, proxy.safeAreaInsets.bottom + 6) : max(10, proxy.safeAreaInsets.bottom + 8))

                if isCameraControlVisible {
                    cameraControlPad(compact: isLandscape)
                        .padding(.trailing, max(14, proxy.safeAreaInsets.trailing + 10))
                        .padding(.bottom, isLandscape ? max(76, proxy.safeAreaInsets.bottom + 70) : max(104, proxy.safeAreaInsets.bottom + 96))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .transition(.scale(scale: 0.9, anchor: .bottomTrailing).combined(with: .opacity))
                }

                if controller.isAiming {
                    aimBubble
                        .position(controller.aimPreview)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                }

                if let feedbackToast {
                    feedbackToastView(feedbackToast)
                        .padding(.top, isLandscape ? 58 : 96)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .transition(.scale(scale: 0.86).combined(with: .opacity))
                        .allowsHitTesting(false)
                }

                if let result = controller.finishResult {
                    finishOverlay(result)
                        .transition(.scale(scale: 0.94).combined(with: .opacity))
                }
            }
            .background(KapselkiTheme.sky)
            .onAppear {
                controller.configure(board: selectedBoard, player: selectedCharacter, mode: playMode, objective: selectedObjective)
            }
            .onChange(of: selectedBoard) { _, _ in
                quickAttempt = 1
                setCameraControlsVisible(false)
                controller.configure(board: selectedBoard, player: selectedCharacter, mode: playMode, objective: selectedObjective)
            }
            .onChange(of: selectedCharacter) { _, _ in
                quickAttempt = 1
                controller.configure(board: selectedBoard, player: selectedCharacter, mode: playMode, objective: selectedObjective)
            }
            .onChange(of: playMode) { _, _ in
                quickAttempt = 1
                controller.configure(board: selectedBoard, player: selectedCharacter, mode: playMode, objective: selectedObjective)
            }
            .onChange(of: selectedObjective) { _, _ in
                quickAttempt = 1
                controller.configure(board: selectedBoard, player: selectedCharacter, mode: playMode, objective: selectedObjective)
            }
            .onChange(of: controller.flickCue) { _, _ in
                audioPlayer.play("cap_flick")
            }
            .onChange(of: controller.hitCue) { _, _ in
                audioPlayer.play("cap_hit")
            }
            .onChange(of: controller.penaltyCue) { _, _ in
                audioPlayer.play("cap_hit")
            }
            .onChange(of: controller.finishCue) { _, _ in
                audioPlayer.play("finish_applause")
                if let result = controller.finishResult {
                    handleUnlocks(for: result)
                }
            }
            .onChange(of: controller.feedbackCue) { _, _ in
                showFeedbackToast(controller.feedbackText)
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: controller.flickCue)
            .sensoryFeedback(.impact(weight: .heavy), trigger: controller.hitCue)
            .sensoryFeedback(.impact(weight: .heavy), trigger: controller.feedbackCue)
            .sensoryFeedback(.warning, trigger: controller.penaltyCue)
            .sensoryFeedback(.success, trigger: controller.finishCue)
        }
    }

    @ViewBuilder
    private func topHUD(proxy: GeometryProxy, compact: Bool) -> some View {
        let narrow = proxy.size.width < 430

        if compact {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("KAPSELKI")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(KapselkiTheme.ink)
                        .lineLimit(1)

                    Text(controller.status.uppercased())
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundStyle(controller.isOffRoute ? KapselkiTheme.red : KapselkiTheme.ink.opacity(0.62))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }
                .frame(width: 112, alignment: .leading)

                VStack(alignment: .leading, spacing: 5) {
                    Text(raceContextText.uppercased())
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundStyle(selectedCharacter.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    objectiveHUDText(compact: true)

                    progressBar
                        .frame(height: 5)
                }

                Spacer(minLength: 4)

                HStack(spacing: 5) {
                    hudMetric("\(controller.moveCount)", "Pstryki".kText, "hand.tap.fill", compact: true)
                    hudMetric("\(controller.penaltyCount)", "Kreda".kText, "exclamationmark.triangle.fill", compact: true)
                    hudMetric("\(controller.energy)", "Energia".kText, "bolt.fill", compact: true)
                }
            }
            .padding(8)
            .kapselkiPanel()
            .frame(maxWidth: min(proxy.size.width - 130, 660))
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(spacing: 7) {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("KAPSELKI")
                            .font(.system(size: narrow ? 20 : 26, weight: .black, design: .rounded))
                            .foregroundStyle(KapselkiTheme.ink)
                            .lineLimit(1)

                        Text(controller.status.uppercased())
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundStyle(controller.isOffRoute ? KapselkiTheme.red : KapselkiTheme.ink.opacity(0.60))
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)

                        Text(selectedCharacter.localizedName.uppercased())
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .foregroundStyle(selectedCharacter.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)

                        Text(raceContextText.uppercased())
                            .font(.system(size: 7, weight: .black, design: .monospaced))
                            .foregroundStyle(KapselkiTheme.blue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)

                        objectiveHUDText(compact: false)
                    }

                    Spacer(minLength: 4)

                    HStack(spacing: 5) {
                    hudMetric("\(controller.moveCount)", "Pstryki".kText, "hand.tap.fill")
                    hudMetric("\(controller.penaltyCount)", "Kreda".kText, "exclamationmark.triangle.fill")
                    hudMetric("\(controller.energy)", "Energia".kText, "bolt.fill")
                    }
                }

                progressBar
                    .frame(height: 5)
            }
            .padding(10)
            .kapselkiPanel()
        }
    }

    private var progressBar: some View {
        GeometryReader { progressProxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(KapselkiTheme.ink.opacity(0.12))

                Capsule()
                    .fill(controller.isOffRoute ? KapselkiTheme.red : KapselkiTheme.yellow)
                    .frame(width: max(8, progressProxy.size.width * CGFloat(controller.progressPercent) / 100))
            }
        }
    }

    private var raceContextText: String {
        switch playMode {
        case .quick:
            return KapselkiL10n.pick(pl: "Próba \(quickAttempt)/\(quickAttemptLimit)", en: "Run \(quickAttempt)/\(quickAttemptLimit)")
        case .tour:
            return KapselkiL10n.pick(pl: "Etap \(stageIndex + 1)/\(stageCount)", en: "Stage \(stageIndex + 1)/\(stageCount)")
        case .daily:
            return "Wyzwanie dnia".kText
        case .master:
            return KapselkiL10n.pick(pl: "Runda \(stageIndex + 1)/\(stageCount)", en: "Round \(stageIndex + 1)/\(stageCount)")
        }
    }

    private func objectiveHUDText(compact: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: controller.objectiveComplete ? "checkmark.circle.fill" : selectedObjective.iconName)
                .font(.system(size: compact ? 7 : 8, weight: .black))

            Text(controller.objectiveProgressText.uppercased())
                .font(.system(size: compact ? 7 : 8, weight: .black, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
        .foregroundStyle(controller.objectiveComplete ? KapselkiTheme.green : KapselkiTheme.ink.opacity(0.62))
    }

    private func hudMetric(_ value: String, _ label: String, _ iconName: String, compact: Bool = false) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 3) {
                Image(systemName: iconName)
                    .font(.system(size: compact ? 8 : 9, weight: .black))
                    .foregroundStyle(KapselkiTheme.yellow)

                Text(value)
                    .font(.system(size: compact ? 12 : 13, weight: .black, design: .monospaced))
                    .foregroundStyle(KapselkiTheme.ink)
            }

            Text(label.uppercased())
                .font(.system(size: compact ? 6 : 7, weight: .black, design: .monospaced))
                .foregroundStyle(KapselkiTheme.ink.opacity(0.50))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(width: compact ? 44 : 52, height: compact ? 32 : 38)
        .background(KapselkiTheme.paper.opacity(0.72), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    @ViewBuilder
    private func bottomDock(proxy: GeometryProxy, compact: Bool) -> some View {
        if compact {
            HStack(spacing: 7) {
                dockButton(
                    iconName: "house.fill",
                    background: KapselkiTheme.ink.opacity(0.66),
                    foreground: KapselkiTheme.paper,
                    width: 42,
                    height: 36,
                    accessibility: "Menu".kText
                ) {
                    setCameraControlsVisible(false)
                    onExit()
                }

                boardBadge(compact: true)

                dockButton(
                    iconName: "camera.viewfinder",
                    background: isCameraControlVisible ? selectedCharacter.color : KapselkiTheme.blue,
                    foreground: KapselkiTheme.paper,
                    width: 44,
                    height: 36,
                    accessibility: "Kamera".kText
                ) {
                    setCameraControlsVisible(!isCameraControlVisible)
                }

                dockButton(
                    iconName: "arrow.counterclockwise",
                    background: KapselkiTheme.yellow,
                    width: 42,
                    height: 36,
                    accessibility: "Restart".kText
                ) {
                    controller.resetRun()
                }

                selectedCharacterSummary(proxy: proxy, compact: true)

                Spacer(minLength: 4)

                Text(controller.hint)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink.opacity(0.72))
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }
            .padding(7)
            .kapselkiPanel()
            .frame(maxWidth: min(proxy.size.width - 130, 710))
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(spacing: 8) {
                selectedCharacterSummary(proxy: proxy, compact: false)

                HStack(spacing: 7) {
                    dockButton(
                        iconName: "house.fill",
                        background: KapselkiTheme.ink.opacity(0.64),
                        foreground: KapselkiTheme.paper,
                        accessibility: "Menu".kText
                    ) {
                        setCameraControlsVisible(false)
                        onExit()
                    }

                    boardBadge(compact: false)

                    dockButton(
                        iconName: "camera.viewfinder",
                        background: isCameraControlVisible ? selectedCharacter.color : KapselkiTheme.blue,
                        foreground: KapselkiTheme.paper,
                        accessibility: "Kamera".kText
                    ) {
                        setCameraControlsVisible(!isCameraControlVisible)
                    }

                    Spacer(minLength: 4)

                    Text(controller.hint)
                        .font(.system(size: proxy.size.width < 430 ? 11 : 12, weight: .black, design: .rounded))
                        .foregroundStyle(KapselkiTheme.ink.opacity(0.72))
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)

                    dockButton(
                        iconName: "arrow.counterclockwise",
                        background: KapselkiTheme.yellow,
                        accessibility: "Restart".kText
                    ) {
                        controller.resetRun()
                    }
                }
            }
            .padding(9)
            .kapselkiPanel()
        }
    }

    private func dockButton(
        iconName: String,
        background: Color,
        foreground: Color = KapselkiTheme.ink,
        width: CGFloat = 40,
        height: CGFloat = 36,
        accessibility: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(foreground)
                .frame(width: width, height: height)
                .background(background, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(KapselkiTheme.ink.opacity(0.12), lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibility)
    }

    private func boardBadge(compact: Bool) -> some View {
        Image(systemName: selectedBoard.iconName)
            .font(.system(size: compact ? 13 : 14, weight: .black))
            .foregroundStyle(KapselkiTheme.ink)
            .frame(width: compact ? 42 : 40, height: compact ? 36 : 36)
            .background(selectedBoard.tint, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(KapselkiTheme.ink.opacity(0.12), lineWidth: 1)
            )
            .accessibilityLabel(selectedBoard.title)
    }

    @ViewBuilder
    private func selectedCharacterSummary(proxy: GeometryProxy, compact: Bool) -> some View {
        if compact {
            HStack(spacing: 7) {
                Image(selectedCharacter.portraitAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(selectedCharacter.color, lineWidth: 2.2)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(selectedCharacter.localizedShortName)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(KapselkiTheme.ink)
                        .lineLimit(1)

                    Text(selectedCharacter.localizedStyle.uppercased())
                        .font(.system(size: 7, weight: .black, design: .monospaced))
                        .foregroundStyle(selectedCharacter.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                }
            }
            .frame(maxWidth: 150, alignment: .leading)
        } else {
            HStack(spacing: 9) {
                Image(selectedCharacter.portraitAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(selectedCharacter.color, lineWidth: 2.5)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text(selectedCharacter.localizedName)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(KapselkiTheme.ink)
                            .lineLimit(1)

                        Text(selectedCharacter.localizedStyle.uppercased())
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .foregroundStyle(selectedCharacter.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                    }

                    Text(selectedCharacter.localizedCapDescription)
                        .font(.system(size: proxy.size.width < 430 ? 9 : 10, weight: .bold, design: .rounded))
                        .foregroundStyle(KapselkiTheme.ink.opacity(0.62))
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: 0)
            }
        }
    }

    private func setCameraControlsVisible(_ isVisible: Bool) {
        withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
            isCameraControlVisible = isVisible
            cameraStickOffset = .zero
            cameraLiftStickOffset = 0
            cameraZoomStickOffset = 0
        }
        controller.updateCameraMoveInput(x: 0, z: 0)
        controller.updateCameraLiftInput(0)
        controller.updateCameraZoomInput(0)
        controller.setManualCameraMode(isVisible)
    }

    private func cameraControlPad(compact: Bool) -> some View {
        HStack(spacing: compact ? 6 : 8) {
            cameraJoystick(compact: compact)

            cameraAxisRail(
                systemImage: "arrow.up.and.down",
                offset: $cameraLiftStickOffset,
                compact: compact,
                label: "Podnieś albo opuść kamerę".kText
            ) { value in
                controller.updateCameraLiftInput(value)
            }

            cameraAxisRail(
                systemImage: "plus.magnifyingglass",
                offset: $cameraZoomStickOffset,
                compact: compact,
                label: "Przybliż albo oddal kamerę".kText
            ) { value in
                controller.updateCameraZoomInput(value)
            }
        }
        .padding(compact ? 6 : 8)
        .background(KapselkiTheme.ink.opacity(0.42), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(selectedCharacter.color.opacity(0.84), lineWidth: 1.4)
        )
        .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 7)
    }

    private func cameraJoystick(compact: Bool) -> some View {
        let radius: CGFloat = compact ? 28 : 34
        let baseSize: CGFloat = compact ? 72 : 84
        let innerSize: CGFloat = compact ? 48 : 56
        let knobSize: CGFloat = compact ? 24 : 28

        return ZStack {
            Circle()
                .fill(KapselkiTheme.paper.opacity(0.18))
                .frame(width: baseSize, height: baseSize)
                .overlay(
                    Circle()
                        .stroke(KapselkiTheme.paper.opacity(0.38), lineWidth: 1.2)
                )

            Circle()
                .fill(KapselkiTheme.paper.opacity(0.84))
                .frame(width: innerSize, height: innerSize)
                .overlay(
                    Circle()
                        .stroke(KapselkiTheme.ink.opacity(0.20), lineWidth: 1)
                )

            Circle()
                .fill(KapselkiTheme.yellow)
                .frame(width: knobSize, height: knobSize)
                .overlay(
                    Image(systemName: "scope")
                        .font(.system(size: compact ? 10 : 12, weight: .black))
                        .foregroundStyle(KapselkiTheme.ink.opacity(0.72))
                )
                .offset(cameraStickOffset)
        }
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let limited = limitedCameraStick(value.translation, radius: radius)
                    cameraStickOffset = limited
                    controller.updateCameraMoveInput(
                        x: Float(limited.width / radius),
                        z: Float(-limited.height / radius)
                    )
                }
                .onEnded { value in
                    let didTapCenter = hypot(value.translation.width, value.translation.height) < 5
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                        cameraStickOffset = .zero
                    }
                    controller.updateCameraMoveInput(x: 0, z: 0)
                    if didTapCenter {
                        controller.resetCameraRig()
                    }
                }
        )
        .accessibilityLabel("Porusz kamerą".kText)
    }

    private func cameraAxisRail(
        systemImage: String,
        offset: Binding<CGFloat>,
        compact: Bool,
        label: String,
        onChange: @escaping (Float) -> Void
    ) -> some View {
        let railHeight: CGFloat = compact ? 72 : 84
        let railWidth: CGFloat = compact ? 28 : 32
        let limit: CGFloat = compact ? 29 : 34
        let knobSize: CGFloat = compact ? 24 : 26

        return ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(KapselkiTheme.paper.opacity(0.18))
                .frame(width: railWidth, height: railHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(KapselkiTheme.paper.opacity(0.22), lineWidth: 1)
                )

            Capsule()
                .fill(KapselkiTheme.paper.opacity(0.28))
                .frame(width: 5, height: railHeight - 26)

            Circle()
                .fill(KapselkiTheme.paper.opacity(0.92))
                .frame(width: knobSize, height: knobSize)
                .overlay(
                    Image(systemName: systemImage)
                        .font(.system(size: compact ? 9 : 11, weight: .black))
                        .foregroundStyle(KapselkiTheme.ink.opacity(0.72))
                )
                .offset(y: offset.wrappedValue)
        }
        .contentShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let limited = max(-limit, min(limit, value.translation.height))
                    offset.wrappedValue = limited
                    onChange(Float(-limited / limit))
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                        offset.wrappedValue = 0
                    }
                    onChange(0)
                }
        )
        .accessibilityLabel(label)
    }

    private func limitedCameraStick(_ translation: CGSize, radius: CGFloat) -> CGSize {
        let distance = hypot(translation.width, translation.height)
        guard distance > radius else {
            return translation
        }

        let scale = radius / max(distance, 0.001)
        return CGSize(width: translation.width * scale, height: translation.height * scale)
    }

    private var aimBubble: some View {
        Text("\(controller.aimPowerPercent)%")
            .font(.system(size: 13, weight: .black, design: .monospaced))
            .foregroundStyle(KapselkiTheme.ink)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(KapselkiTheme.yellow, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(KapselkiTheme.ink.opacity(0.24), lineWidth: 1)
            )
            .allowsHitTesting(false)
    }

    private func feedbackToastView(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .black))

            Text(text.uppercased())
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.66)
        }
        .foregroundStyle(KapselkiTheme.ink)
        .padding(.horizontal, 13)
        .frame(height: 36)
        .background(KapselkiTheme.yellow, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(KapselkiTheme.ink.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 5)
    }

    private func showFeedbackToast(_ text: String) {
        guard !text.isEmpty else {
            return
        }

        let toastID = UUID()
        feedbackToastID = toastID
        withAnimation(.spring(response: 0.22, dampingFraction: 0.78)) {
            feedbackToast = text
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            guard feedbackToastID == toastID else {
                return
            }
            withAnimation(.easeOut(duration: 0.18)) {
                feedbackToast = nil
            }
        }
    }

    private func finishOverlay(_ result: KapselkiRunResult) -> some View {
        ZStack {
            finishConfettiLayer

            VStack(spacing: 12) {
                finishPodium(result)

                Text(result.title)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink)
                    .multilineTextAlignment(.center)

                Text(result.summary)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink.opacity(0.70))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(finishContextText)
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(selectedCharacter.color)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                objectiveFinishBadge(result)

                HStack(spacing: 6) {
                    resultTile("\(result.place)/\(result.boardSize)", "Miejsce".kText)
                    resultTile("\(result.moves)", "Pstryki".kText)
                    resultTile("\(result.penalties)", "Wyjazdy".kText)
                    resultTile("\(result.styleScore)", "Styl".kText)
                }

                Button {
                    handleFinishPrimaryAction()
                } label: {
                    HStack {
                        Text(finishPrimaryTitle)
                            .font(.system(size: 15, weight: .black, design: .monospaced))

                        Image(systemName: finishPrimaryIconName)
                            .font(.system(size: 15, weight: .black))
                    }
                    .foregroundStyle(KapselkiTheme.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(KapselkiTheme.yellow, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .frame(width: 330)
        .background(KapselkiTheme.paper.opacity(0.96), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(KapselkiTheme.ink.opacity(0.22), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.22), radius: 24, x: 0, y: 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(KapselkiTheme.ink.opacity(0.14).ignoresSafeArea())
    }

    private var finishConfettiLayer: some View {
        ZStack {
            ForEach(0..<22, id: \.self) { index in
                Rectangle()
                    .fill(tableFinishColor(index))
                    .frame(width: CGFloat(6 + (index % 3) * 4), height: CGFloat(3 + (index % 2) * 3))
                    .rotationEffect(.degrees(Double((index * 23) % 88) - 44))
                    .offset(
                        x: CGFloat((index % 6) * 54 - 135),
                        y: CGFloat((index / 6) * 44 - 86)
                    )
            }
        }
        .opacity(0.72)
        .allowsHitTesting(false)
    }

    private func tableFinishColor(_ index: Int) -> Color {
        [KapselkiTheme.red, KapselkiTheme.blue, KapselkiTheme.yellow, KapselkiTheme.green, KapselkiTheme.orange][index % 5]
    }

    private func finishPodium(_ result: KapselkiRunResult) -> some View {
        let first = result.podium.first { $0.place == 1 }
        let second = result.podium.first { $0.place == 2 }
        let third = result.podium.first { $0.place == 3 }

        return HStack(alignment: .bottom, spacing: 8) {
            if let second {
                podiumEntryView(second, height: 42, avatarSize: 48, color: KapselkiTheme.blue.opacity(0.74))
            }

            if let first {
                podiumEntryView(first, height: 58, avatarSize: 62, color: KapselkiTheme.yellow)
            }

            if let third {
                podiumEntryView(third, height: 34, avatarSize: 44, color: KapselkiTheme.green.opacity(0.78))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func podiumEntryView(_ entry: KapselkiPodiumEntry, height: CGFloat, avatarSize: CGFloat, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(entry.character.portraitAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())
                .overlay(Circle().stroke(entry.character.color, lineWidth: entry.isPlayer ? 4 : 3))
                .shadow(color: .black.opacity(entry.isPlayer ? 0.18 : 0.12), radius: entry.isPlayer ? 8 : 5, x: 0, y: entry.isPlayer ? 4 : 3)

            podiumStep(
                place: "\(entry.place)",
                height: height,
                color: color,
                label: entry.character.localizedShortName.uppercased()
            )
        }
        .frame(width: 86)
    }

    private func podiumStep(place: String, height: CGFloat, color: Color, label: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 7, weight: .black, design: .monospaced))
                .foregroundStyle(KapselkiTheme.ink.opacity(0.60))
                .lineLimit(1)
                .minimumScaleFactor(0.60)

            Text(place)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(KapselkiTheme.ink)
                .frame(width: 72, height: height)
                .background(color, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
    }

    private func objectiveFinishBadge(_ result: KapselkiRunResult) -> some View {
        HStack(spacing: 8) {
            Image(systemName: result.objectiveCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(result.objectiveCompleted ? KapselkiTheme.green : KapselkiTheme.red)

            VStack(alignment: .leading, spacing: 1) {
                Text(result.objectiveCompleted ? "CEL ZALICZONY".kText : "CEL NA NASTĘPNY RAZ".kText)
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundStyle(KapselkiTheme.ink.opacity(0.58))

                Text(result.objectiveTitle)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }

            Spacer(minLength: 0)
        }
        .padding(9)
        .background((result.objectiveCompleted ? KapselkiTheme.green : KapselkiTheme.red).opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var finishContextText: String {
        switch playMode {
        case .quick:
            return quickAttempt < quickAttemptLimit
                ? KapselkiL10n.pick(pl: "Szybka partyjka: próba \(quickAttempt) z \(quickAttemptLimit)", en: "Quick match: run \(quickAttempt) of \(quickAttemptLimit)")
                : "Szybka partyjka zakończona. Najlepszy wynik robisz kolejną serią.".kText
        case .tour:
            if stageIndex < stageCount - 1 {
                return KapselkiL10n.pick(pl: "Tour: etap \(stageIndex + 1) z \(stageCount). Następny czeka za rogiem.", en: "Tour: stage \(stageIndex + 1) of \(stageCount). The next one is waiting.")
            }
            return "Tour ukończony. To już finał osiedla.".kText
        case .daily:
            return "Dzisiejsze wyzwanie możesz poprawiać, aż pstryk będzie idealny.".kText
        case .master:
            if stageIndex < stageCount - 1 {
                return KapselkiL10n.pick(pl: "Mistrz podwórka: runda \(stageIndex + 1) z \(stageCount). Jedziemy dalej.", en: "Backyard champ: round \(stageIndex + 1) of \(stageCount). Keep going.")
            }
            return "Seria Mistrza podwórka ukończona.".kText
        }
    }

    private var finishPrimaryTitle: String {
        switch playMode {
        case .quick:
            return quickAttempt < quickAttemptLimit
                ? KapselkiL10n.pick(pl: "PRÓBA \(quickAttempt + 1)/\(quickAttemptLimit)", en: "RUN \(quickAttempt + 1)/\(quickAttemptLimit)")
                : KapselkiL10n.pick(pl: "3 PRÓBY OD NOWA", en: "RESTART 3 RUNS")
        case .tour:
            return stageIndex < stageCount - 1 ? "NASTĘPNY ETAP".kText : "TOUR OD NOWA".kText
        case .daily:
            return "POPRAW WYNIK DNIA".kText
        case .master:
            return stageIndex < stageCount - 1 ? "NASTĘPNA RUNDA".kText : "SERIA OD NOWA".kText
        }
    }

    private var finishPrimaryIconName: String {
        switch playMode {
        case .quick:
            return quickAttempt < quickAttemptLimit ? "forward.fill" : "arrow.clockwise"
        case .tour:
            return stageIndex < stageCount - 1 ? "arrow.right" : "arrow.clockwise"
        case .daily:
            return "arrow.clockwise"
        case .master:
            return stageIndex < stageCount - 1 ? "arrow.right" : "arrow.clockwise"
        }
    }

    private func handleFinishPrimaryAction() {
        switch playMode {
        case .quick:
            if quickAttempt < quickAttemptLimit {
                quickAttempt += 1
            } else {
                quickAttempt = 1
            }
            controller.resetRun()
        case .tour:
            if stageIndex < stageCount - 1 {
                onAdvanceStage()
            } else {
                onRestartSeries()
            }
        case .daily:
            controller.resetRun()
        case .master:
            if stageIndex < stageCount - 1 {
                onAdvanceStage()
            } else {
                onRestartSeries()
            }
        }
    }

    private func handleUnlocks(for result: KapselkiRunResult) {
        switch playMode {
        case .quick:
            guard result.medalRank >= 2 else {
                return
            }
            if let name = onUnlockCharacter("neon") {
                showFeedbackToast(KapselkiL10n.pick(pl: "Odblokowano \(name)!", en: "\(name) unlocked!"))
            }
        case .tour:
            guard stageIndex == stageCount - 1 else {
                return
            }
            if let name = onUnlockCharacter("sprezyna") {
                showFeedbackToast(KapselkiL10n.pick(pl: "Odblokowano \(name)!", en: "\(name) unlocked!"))
            }
        case .daily, .master:
            return
        }
    }

    private func resultTile(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 15, weight: .black, design: .monospaced))
                .foregroundStyle(KapselkiTheme.ink)

            Text(label.uppercased())
                .font(.system(size: 8, weight: .black, design: .monospaced))
                .foregroundStyle(KapselkiTheme.ink.opacity(0.50))
                .lineLimit(1)
                .minimumScaleFactor(0.66)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(.white.opacity(0.38), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private func flickGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if dragStart == nil {
                    dragStart = value.startLocation
                }

                controller.updateDrag(
                    from: dragStart ?? value.startLocation,
                    to: value.location,
                    screenSize: size
                )
            }
            .onEnded { value in
                controller.endDrag(
                    from: dragStart ?? value.startLocation,
                    to: value.location,
                    screenSize: size
                )
                dragStart = nil
            }
    }
}

struct KapselkiSceneView: UIViewRepresentable {
    @ObservedObject var controller: KapselkiSceneController

    func makeUIView(context _: Context) -> SCNView {
        let view = SCNView()
        view.scene = controller.scene
        view.delegate = controller
        view.isPlaying = true
        view.preferredFramesPerSecond = 60
        view.antialiasingMode = .multisampling4X
        view.rendersContinuously = true
        view.backgroundColor = KapselkiTheme.uiSky
        view.allowsCameraControl = false
        return view
    }

    func updateUIView(_ uiView: SCNView, context _: Context) {
        if uiView.scene !== controller.scene {
            uiView.scene = controller.scene
        }
    }
}
