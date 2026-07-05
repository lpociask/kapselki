import SceneKit
import SwiftUI

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
        IntroSlide(id: 0, iconName: "hand.tap.fill", title: "Pstryknij", body: "Dotknij kapsla, odciągnij palec i puść. Im dalej odciągniesz, tym mocniejszy strzał.", color: KapselkiTheme.yellow),
        IntroSlide(id: 1, iconName: "scope", title: "Trzymaj kredę", body: "Jedź między kredowymi liniami. Wyjazd poza trasę zabiera energię i psuje styl.", color: KapselkiTheme.blue),
        IntroSlide(id: 2, iconName: "person.3.fill", title: "Wybierz ekipę", body: "Każda postać ma własny kapsel: inną moc, kontrolę i spin. Dobierz styl do planszy.", color: KapselkiTheme.orange)
    ]

    @State private var flow: Flow = .menu
    @State private var introIndex = 0
    @State private var selectedBoard: KapselkiBoard = .sidewalk
    @State private var selectedCharacter = KapselkiCharacter.defaultCharacter

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
                        selectedBoard: selectedBoard,
                        selectedCharacter: selectedCharacter,
                        onExit: { flow = .setup }
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

                Text("podwórkowy pstryk na kilka minut")
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundStyle(KapselkiTheme.ink.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                colorTabs
            }

            VStack(spacing: 10) {
                primaryButton(title: "GRAJ", iconName: "play.fill") {
                    flow = .setup
                }

                Button {
                    introIndex = 0
                    flow = .intro
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 15, weight: .black))

                        Text("O CO CHODZI")
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

    private var quickLoadout: some View {
        HStack(spacing: 10) {
            capAvatar(selectedCharacter, size: 54, selected: true)

            VStack(alignment: .leading, spacing: 2) {
                Text(selectedCharacter.name)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink)
                    .lineLimit(1)

                Text("\(selectedCharacter.style) · \(selectedBoard.title)")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundStyle(KapselkiTheme.ink.opacity(0.56))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
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
            .accessibilityLabel("Wybór kapsla")
        }
        .padding(10)
        .kapselkiPanel()
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

                Text("JAK SIĘ GRA")
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

            primaryButton(title: introIndex == introSlides.count - 1 ? "WYBIERZ KAPSEL" : "DALEJ", iconName: "arrow.right") {
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
                    Text("WYBÓR KAPSLA")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(KapselkiTheme.ink)

                    Text("\(selectedCharacter.name) · \(selectedBoard.title)")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundStyle(KapselkiTheme.ink.opacity(0.56))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.top, max(12, proxy.safeAreaInsets.top + 8))
            .padding(.bottom, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    selectedLoadoutCard
                    characterSelection
                    boardSelection
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 92)
            }
        }
        .overlay(alignment: .bottom) {
            primaryButton(title: "START RUNDY", iconName: "flag.checkered") {
                flow = .race
            }
            .padding(.horizontal, 24)
            .padding(.bottom, max(18, proxy.safeAreaInsets.bottom + 10))
        }
    }

    private var selectedLoadoutCard: some View {
        HStack(spacing: 14) {
            capAvatar(selectedCharacter, size: 86, selected: true)

            VStack(alignment: .leading, spacing: 6) {
                Text(selectedCharacter.name)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(selectedCharacter.style.uppercased())
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(selectedCharacter.color)

                Text(selectedCharacter.capDescription)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(KapselkiTheme.ink.opacity(0.66))
                    .lineLimit(3)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .kapselkiPanel()
    }

    private var characterSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EKIPA")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundStyle(KapselkiTheme.ink.opacity(0.58))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 78), spacing: 8)], spacing: 8) {
                ForEach(KapselkiCharacter.roster) { character in
                    Button {
                        selectedCharacter = character
                    } label: {
                        VStack(spacing: 5) {
                            capAvatar(character, size: 54, selected: selectedCharacter == character)

                            Text(character.shortName.uppercased())
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .foregroundStyle(KapselkiTheme.ink)
                                .lineLimit(1)
                                .minimumScaleFactor(0.62)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 78)
                        .background(selectedCharacter == character ? character.color.opacity(0.18) : .white.opacity(0.28), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var boardSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PLANSZE")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundStyle(KapselkiTheme.ink.opacity(0.58))

            VStack(spacing: 8) {
                ForEach(KapselkiBoard.allCases) { board in
                    Button {
                        selectedBoard = board
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: board.iconName)
                                .font(.system(size: 16, weight: .black))
                                .foregroundStyle(selectedBoard == board ? KapselkiTheme.ink : KapselkiTheme.paper)
                                .frame(width: 42, height: 38)
                                .background(selectedBoard == board ? board.tint : KapselkiTheme.ink.opacity(0.58), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(board.title)
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(KapselkiTheme.ink)

                                Text(board.subtitle)
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                                    .foregroundStyle(KapselkiTheme.ink.opacity(0.54))
                            }

                            Spacer()

                            if selectedBoard == board {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundStyle(board.tint)
                            }
                        }
                        .padding(9)
                        .background(selectedBoard == board ? board.tint.opacity(0.16) : .white.opacity(0.24), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func capAvatar(_ character: KapselkiCharacter, size: CGFloat, selected: Bool) -> some View {
        Image(character.portraitAssetName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(character.color, lineWidth: selected ? 4 : 2)
            )
            .shadow(color: .black.opacity(selected ? 0.18 : 0.08), radius: selected ? 8 : 3, x: 0, y: selected ? 4 : 2)
    }

    private func primaryButton(title: String, iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .black))
            }
            .foregroundStyle(KapselkiTheme.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(KapselkiTheme.yellow, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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
    let selectedBoard: KapselkiBoard
    let selectedCharacter: KapselkiCharacter
    let onExit: () -> Void
    @State private var dragStart: CGPoint?
    @State private var isCameraControlVisible = false
    @State private var cameraStickOffset = CGSize.zero
    @State private var cameraLiftStickOffset: CGFloat = 0
    @State private var cameraZoomStickOffset: CGFloat = 0

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
                .padding(.top, max(8, proxy.safeAreaInsets.top + 4))
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

                if let result = controller.finishResult {
                    finishOverlay(result)
                        .transition(.scale(scale: 0.94).combined(with: .opacity))
                }
            }
            .background(KapselkiTheme.sky)
            .onAppear {
                controller.configure(board: selectedBoard, player: selectedCharacter)
            }
            .onChange(of: controller.flickCue) { _, _ in
                audioPlayer.play("cap_flick")
            }
            .onChange(of: controller.hitCue) { _, _ in
                audioPlayer.play("cap_hit")
            }
            .onChange(of: controller.finishCue) { _, _ in
                audioPlayer.play("finish_applause")
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: controller.flickCue)
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
                    Text(selectedCharacter.name.uppercased())
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundStyle(selectedCharacter.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    progressBar
                        .frame(height: 5)
                }

                Spacer(minLength: 4)

                HStack(spacing: 5) {
                    hudMetric("\(controller.moveCount)", "Pstryki", "hand.tap.fill", compact: true)
                    hudMetric("\(controller.penaltyCount)", "Kreda", "exclamationmark.triangle.fill", compact: true)
                    hudMetric("\(controller.energy)", "Energia", "bolt.fill", compact: true)
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

                        Text(selectedCharacter.name.uppercased())
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .foregroundStyle(selectedCharacter.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                    }

                    Spacer(minLength: 4)

                    HStack(spacing: 5) {
                        hudMetric("\(controller.moveCount)", "Pstryki", "hand.tap.fill")
                        hudMetric("\(controller.penaltyCount)", "Kreda", "exclamationmark.triangle.fill")
                        hudMetric("\(controller.energy)", "Energia", "bolt.fill")
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
                    accessibility: "Menu"
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
                    accessibility: "Kamera"
                ) {
                    setCameraControlsVisible(!isCameraControlVisible)
                }

                dockButton(
                    iconName: "arrow.counterclockwise",
                    background: KapselkiTheme.yellow,
                    width: 42,
                    height: 36,
                    accessibility: "Restart"
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
                        accessibility: "Menu"
                    ) {
                        setCameraControlsVisible(false)
                        onExit()
                    }

                    boardBadge(compact: false)

                    dockButton(
                        iconName: "camera.viewfinder",
                        background: isCameraControlVisible ? selectedCharacter.color : KapselkiTheme.blue,
                        foreground: KapselkiTheme.paper,
                        accessibility: "Kamera"
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
                        accessibility: "Restart"
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
                    Text(selectedCharacter.shortName)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(KapselkiTheme.ink)
                        .lineLimit(1)

                    Text(selectedCharacter.style.uppercased())
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
                        Text(selectedCharacter.name)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(KapselkiTheme.ink)
                            .lineLimit(1)

                        Text(selectedCharacter.style.uppercased())
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .foregroundStyle(selectedCharacter.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                    }

                    Text(selectedCharacter.capDescription)
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
                label: "Podnieś albo opuść kamerę"
            ) { value in
                controller.updateCameraLiftInput(value)
            }

            cameraAxisRail(
                systemImage: "plus.magnifyingglass",
                offset: $cameraZoomStickOffset,
                compact: compact,
                label: "Przybliż albo oddal kamerę"
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
        .accessibilityLabel("Porusz kamerą")
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

    private func finishOverlay(_ result: KapselkiRunResult) -> some View {
        VStack(spacing: 12) {
            Image(systemName: result.medalRank >= 3 ? "trophy.fill" : "flag.checkered")
                .font(.system(size: 30, weight: .black))
                .foregroundStyle(KapselkiTheme.yellow)
                .frame(width: 62, height: 62)
                .background(KapselkiTheme.ink, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(result.title)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(KapselkiTheme.ink)
                .multilineTextAlignment(.center)

            Text(result.summary)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(KapselkiTheme.ink.opacity(0.70))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                resultTile("\(result.place)/\(result.boardSize)", "Miejsce")
                resultTile("\(result.moves)", "Pstryki")
                resultTile("\(result.penalties)", "Wyjazdy")
                resultTile("\(result.styleScore)", "Styl")
            }

            Button {
                controller.resetRun()
            } label: {
                HStack {
                    Text("JESZCZE RAZ")
                        .font(.system(size: 15, weight: .black, design: .monospaced))

                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 15, weight: .black))
                }
                .foregroundStyle(KapselkiTheme.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(KapselkiTheme.yellow, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
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
