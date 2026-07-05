import SceneKit
import SwiftUI
import UIKit

enum KapselkiBoard: String, CaseIterable, Identifiable {
    case sidewalk
    case grass
    case sand
    case schoolyard
    case table

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sidewalk:
            return "Chodnik"
        case .grass:
            return "Trawa"
        case .sand:
            return "Piasek"
        case .schoolyard:
            return "Boisko"
        case .table:
            return "Stół"
        }
    }

    var subtitle: String {
        switch self {
        case .sidewalk:
            return "szybki ślizg"
        case .grass:
            return "miękka kontrola"
        case .sand:
            return "krótki, ciężki ruch"
        case .schoolyard:
            return "kreda i zakręty"
        case .table:
            return "gładka jazda"
        }
    }

    var iconName: String {
        switch self {
        case .sidewalk:
            return "square.grid.3x3.fill"
        case .grass:
            return "leaf.fill"
        case .sand:
            return "sun.max.fill"
        case .schoolyard:
            return "sportscourt.fill"
        case .table:
            return "tablecells.fill"
        }
    }

    var tint: Color {
        switch self {
        case .sidewalk:
            return KapselkiTheme.concrete
        case .grass:
            return KapselkiTheme.green
        case .sand:
            return KapselkiTheme.sand
        case .schoolyard:
            return KapselkiTheme.blue
        case .table:
            return KapselkiTheme.orange
        }
    }

    var materialColor: UIColor {
        switch self {
        case .sidewalk:
            return UIColor(red: 0.54, green: 0.53, blue: 0.46, alpha: 1)
        case .grass:
            return UIColor(red: 0.28, green: 0.46, blue: 0.24, alpha: 1)
        case .sand:
            return UIColor(red: 0.72, green: 0.56, blue: 0.33, alpha: 1)
        case .schoolyard:
            return UIColor(red: 0.47, green: 0.57, blue: 0.60, alpha: 1)
        case .table:
            return UIColor(red: 0.70, green: 0.47, blue: 0.24, alpha: 1)
        }
    }

    var friction: Float {
        switch self {
        case .sidewalk:
            return 2.10
        case .grass:
            return 4.95
        case .sand:
            return 5.40
        case .schoolyard:
            return 2.70
        case .table:
            return 1.72
        }
    }

    var slip: Float {
        switch self {
        case .sidewalk:
            return 0.058
        case .grass:
            return 0.115
        case .sand:
            return 0.145
        case .schoolyard:
            return 0.078
        case .table:
            return 0.045
        }
    }
}

struct KapselkiRunResult: Equatable {
    let place: Int
    let boardSize: Int
    let moves: Int
    let penalties: Int
    let energy: Int
    let styleScore: Int
    let medalRank: Int

    var title: String {
        switch medalRank {
        case 3:
            return "Złoto pod blokiem"
        case 2:
            return "Srebro na kredzie"
        case 1:
            return "Brązowy pstryk"
        default:
            return "Meta zaliczona"
        }
    }

    var summary: String {
        "Miejsce \(place) z \(boardSize), \(moves) pstryków, energia \(energy), wyjazdy za kredę \(penalties)."
    }
}

final class KapselkiSceneController: NSObject, ObservableObject, SCNSceneRendererDelegate, @unchecked Sendable {
    private enum TurnPhase {
        case playerReady
        case playerMoving
        case rivalsMoving
        case finished
    }

    private enum ObstacleKind: CaseIterable {
        case chalk
        case twig
        case gum
        case matchbox
        case marble

        var drag: Float {
            switch self {
            case .chalk:
                return 0.66
            case .twig:
                return 0.58
            case .gum:
                return 0.33
            case .matchbox:
                return 0.50
            case .marble:
                return 0.78
            }
        }

        var bounce: Float {
            switch self {
            case .chalk:
                return 0.82
            case .twig:
                return 0.94
            case .gum:
                return 0.04
            case .matchbox:
                return 0.76
            case .marble:
                return 1.28
            }
        }
    }

    private struct RouteShape {
        var startZ: Float
        var length: Float
        var amplitudeA: Float
        var amplitudeB: Float
        var frequencyA: Float
        var frequencyB: Float
        var phaseA: Float
        var phaseB: Float
        var lean: Float

        static let sidewalk = RouteShape(
            startZ: -22.3,
            length: 45.0,
            amplitudeA: 2.25,
            amplitudeB: 0.64,
            frequencyA: 2.70,
            frequencyB: 6.20,
            phaseA: 0.20,
            phaseB: 1.05,
            lean: 0.78
        )

        static let grass = RouteShape(
            startZ: -22.0,
            length: 44.0,
            amplitudeA: 2.75,
            amplitudeB: 0.80,
            frequencyA: 3.10,
            frequencyB: 7.40,
            phaseA: 0.70,
            phaseB: 1.40,
            lean: -0.62
        )

        static let sand = RouteShape(
            startZ: -21.8,
            length: 43.6,
            amplitudeA: 2.05,
            amplitudeB: 0.52,
            frequencyA: 2.35,
            frequencyB: 5.10,
            phaseA: 1.10,
            phaseB: 0.35,
            lean: 0.28
        )

        static let schoolyard = RouteShape(
            startZ: -22.2,
            length: 44.7,
            amplitudeA: 2.95,
            amplitudeB: 0.48,
            frequencyA: 3.45,
            frequencyB: 6.90,
            phaseA: 0.10,
            phaseB: 1.80,
            lean: -0.38
        )

        static let table = RouteShape(
            startZ: -22.6,
            length: 45.3,
            amplitudeA: 1.62,
            amplitudeB: 0.38,
            frequencyA: 2.05,
            frequencyB: 4.60,
            phaseA: 0.55,
            phaseB: 0.20,
            lean: 0.18
        )
    }

    private struct CapMotion {
        var x: Float
        var z: Float
        var vx: Float
        var vz: Float
        var spin: Float
        var yaw: Float
    }

    private struct RouteContact {
        let distance: Float
        let nearest: SCNVector3
        let tangent: SCNVector3
        let outward: SCNVector3
        let t: Float
    }

    private struct ObstacleSpec {
        let t: Float
        let lane: Float
        let radius: Float
        let kind: ObstacleKind
    }

    let scene = SCNScene()

    @Published private(set) var status = "Dotknij kapsla"
    @Published private(set) var hint = "Dotknij kapsla, odciągnij palec i puść."
    @Published private(set) var moveCount = 0
    @Published private(set) var penaltyCount = 0
    @Published private(set) var energy = 100
    @Published private(set) var styleScore = 0
    @Published private(set) var progressPercent = 0
    @Published private(set) var isOffRoute = false
    @Published private(set) var isAiming = false
    @Published private(set) var aimPreview = CGPoint.zero
    @Published private(set) var aimPowerPercent = 0
    @Published private(set) var finishResult: KapselkiRunResult?
    @Published private(set) var flickCue = 0
    @Published private(set) var hitCue = 0
    @Published private(set) var penaltyCue = 0
    @Published private(set) var finishCue = 0
    @Published private(set) var isManualCameraMode = false

    private let boardNode = SCNNode()
    private let capNode = SCNNode()
    private let aimNode = SCNNode()
    private let dustRoot = SCNNode()
    private let cameraNode = SCNNode()
    private let routeSegmentCount = 150
    private let boardWidth: Float = 19.8
    private let boardDepth: Float = 53.5
    private let routeWidth: Float = 5.25
    private let capRadius: Float = 0.58
    private let capTouchWorldRadius: Float = 1.55
    private let inputPlaneY: Float = 0.10
    private let finishTriggerT: Float = 0.985
    private let maxAimDashCount = 7
    private let aimDashBaseLength: Float = 0.42

    private var currentBoard: KapselkiBoard = .sidewalk
    private var playerCharacter = KapselkiCharacter.defaultCharacter
    private var routeShape: RouteShape = .sidewalk
    private var turnPhase: TurnPhase = .playerReady
    private var cap = CapMotion(x: 0, z: -20, vx: 0, vz: 0, spin: 0, yaw: 0)
    private var rivals: [CapMotion] = []
    private var rivalNodes: [SCNNode] = []
    private var obstacles: [ObstacleSpec] = []
    private var aimDashNodes: [SCNNode] = []
    private var aimContactNode: SCNNode?
    private var aimEndNode: SCNNode?
    private var lastUpdateTime: TimeInterval = 0
    private var turnElapsedTime: TimeInterval = 0
    private var rivalsStarted = false
    private var playerLegalProgressT: Float = 0.035
    private var cachedPlayerContact: RouteContact?
    private var rivalLegalProgressT: [Float] = []
    private var playerOffRouteState = false
    private var hasPenaltyThisTurn = false
    private var activeAimStart: CGPoint?
    private var activeAimStartWorld: SCNVector3?
    private var projectedCapAnchorRatio: CGPoint?
    private var lastProjectedCapAnchorRatio: CGPoint?
    private var viewportAspectRatio: Float = 9.0 / 16.0
    private var isPortraitViewport = true
    private var impactCooldown: TimeInterval = 0
    private var trailCooldown: TimeInterval = 0
    private var smoothedCameraLookTarget = SCNVector3Zero
    private var hasCameraTarget = false
    private var cameraMoveInput = SCNVector3Zero
    private var cameraOrbitOffset = SCNVector3Zero
    private var cameraHeightOffset: Float = 0
    private var cameraZoomInput: Float = 0
    private var cameraZoomOffset: Float = 0
    private var statsMoves = 0
    private var statsPenalties = 0
    private var statsEnergy = 100
    private var statsStyle = 0
#if DEBUG
    private let shouldAutoFlickOnLaunch = CommandLine.arguments.contains("--kapselki-autoflick-once")
    private var didAutoFlickOnLaunch = false
#endif

    override init() {
        super.init()
        scene.background.contents = KapselkiTheme.uiSky
    }

    func configure(board: KapselkiBoard, player: KapselkiCharacter) {
        currentBoard = board
        playerCharacter = player
        switch board {
        case .sidewalk:
            routeShape = .sidewalk
        case .grass:
            routeShape = .grass
        case .sand:
            routeShape = .sand
        case .schoolyard:
            routeShape = .schoolyard
        case .table:
            routeShape = .table
        }

        buildScene()
        resetRun()
    }

    func setManualCameraMode(_ isActive: Bool) {
        if isActive, !isManualCameraMode {
            cameraOrbitOffset = SCNVector3Zero
            cameraHeightOffset = 0
            cameraZoomOffset = 0
        }
        publishMain { [weak self] in
            self?.isManualCameraMode = isActive
        }
        cameraMoveInput = SCNVector3Zero
        cameraZoomInput = 0
        if !isActive {
            cameraOrbitOffset = SCNVector3Zero
            cameraHeightOffset = 0
            cameraZoomOffset = 0
            hasCameraTarget = false
        }
    }

    func updateCameraMoveInput(x: Float, z: Float) {
        cameraMoveInput.x = clampedCameraControl(x)
        cameraMoveInput.z = clampedCameraControl(z)
    }

    func updateCameraLiftInput(_ lift: Float) {
        cameraMoveInput.y = clampedCameraControl(lift)
    }

    func updateCameraZoomInput(_ zoom: Float) {
        cameraZoomInput = clampedCameraControl(zoom)
    }

    func resetCameraRig() {
        cameraMoveInput = SCNVector3Zero
        cameraOrbitOffset = SCNVector3Zero
        cameraHeightOffset = 0
        cameraZoomInput = 0
        cameraZoomOffset = 0
        hasCameraTarget = false
        lastProjectedCapAnchorRatio = nil
        updateCamera(force: true)
    }

    func resetRun() {
        dustRoot.childNodes.forEach { $0.removeFromParentNode() }
        let start = routePosition(t: 0.035, lane: -routeHalfWidth * 0.20)
        cap = CapMotion(x: start.x, z: start.z, vx: 0, vz: 0, spin: 0, yaw: 0)
        rivals = [
            makeRival(t: 0.085, lane: routeHalfWidth * 0.55, spin: 0.08),
            makeRival(t: 0.125, lane: -routeHalfWidth * 0.55, spin: -0.08),
            makeRival(t: 0.170, lane: routeHalfWidth * 0.12, spin: 0.05),
            makeRival(t: 0.215, lane: -routeHalfWidth * 0.22, spin: -0.04)
        ]
        rivalLegalProgressT = rivals.map { nearestRouteContact(x: $0.x, z: $0.z).t }
        playerLegalProgressT = 0.035
        cachedPlayerContact = nearestRouteContact(x: cap.x, z: cap.z)
        playerOffRouteState = false
        hasPenaltyThisTurn = false
        statsMoves = 0
        statsPenalties = 0
        statsEnergy = 100
        statsStyle = 0
        turnElapsedTime = 0
        lastUpdateTime = 0
        rivalsStarted = false
        impactCooldown = 0
        trailCooldown = 0
        hasCameraTarget = false
        cameraMoveInput = SCNVector3Zero
        cameraOrbitOffset = SCNVector3Zero
        cameraHeightOffset = 0
        cameraZoomInput = 0
        cameraZoomOffset = 0
#if DEBUG
        didAutoFlickOnLaunch = false
#endif
        hideAimGuide()
        publishStats()
        publishProgress()
        publishMain { [weak self] in
            self?.finishResult = nil
            self?.status = "Twój ruch"
            self?.hint = "Dotknij kapsla, odciągnij palec i puść."
            self?.isOffRoute = false
        }
        turnPhase = .playerReady
        updateNodes()
        updateCamera(force: true)
    }

    func updateDrag(from start: CGPoint, to current: CGPoint, screenSize: CGSize) {
        guard turnPhase == .playerReady, finishResult == nil else {
            hideAimGuide()
            return
        }

        let anchor: CGPoint
        if let activeAimStart {
            anchor = activeAimStart
        } else {
            guard canStartAim(from: start, screenSize: screenSize) else {
                hideAimGuide()
                return
            }
            activeAimStart = start
            activeAimStartWorld = boardPoint(fromScreen: start, screenSize: screenSize)
            anchor = start
        }

        let pull = CGVector(dx: anchor.x - current.x, dy: anchor.y - current.y)
        let pullLength = min(144, pull.length)
        guard pullLength > 4 else {
            return
        }

        let vector = aimBoardVector(from: anchor, to: current, screenSize: screenSize)
        guard vector.horizontalLength > 0.001 else {
            hideAimGuide()
            return
        }

        let power = min(1, Float(pullLength / 144))
        updateAimOverlay(preview: current, power: power)
        updateAimGuide3D(direction: vector.normalized, power: power)
    }

    func endDrag(from start: CGPoint, to current: CGPoint, screenSize: CGSize) {
        guard turnPhase == .playerReady, finishResult == nil else {
            hideAimGuide()
            return
        }

        let anchor = activeAimStart ?? start
        guard activeAimStart != nil || canStartAim(from: anchor, screenSize: screenSize) else {
            hideAimGuide()
            return
        }

        let pullLength = min(144, CGVector(dx: anchor.x - current.x, dy: anchor.y - current.y).length)
        guard pullLength >= 13 else {
            hideAimGuide()
            return
        }

        let vector = aimBoardVector(from: anchor, to: current, screenSize: screenSize)
        guard vector.horizontalLength > 0.001 else {
            hideAimGuide()
            return
        }

        let power = min(1, Float(pullLength / 144))
        let control = playerCharacter.control
        let directionJitter = ((1 - control) * 0.026 + max(0, power - 0.86) * 0.052) * boardJitterMultiplier
        let direction = vector.normalized.rotated(by: Float.random(in: -directionJitter...directionJitter))
        let speed = (1.10 + power * 5.95) * boardSpeedMultiplier * playerCharacter.powerMultiplier
        let contact = contactVector(fromScreen: anchor, screenSize: screenSize)
        let rimDistance = min(1, contact.horizontalLength)
        let rimStrength = max(0, (rimDistance - 0.36) / 0.64)
        let torque = contact.x * direction.z - contact.z * direction.x
        let spinDirection: Float = torque >= 0 ? 1 : -1
        let spinImpulse = spinDirection * rimStrength * max(0.14, abs(torque)) * (0.55 + power * 2.65) * playerCharacter.spinMultiplier

        cap.vx = direction.x * speed
        cap.vz = direction.z * speed
        if rimStrength > 0.08 {
            cap.spin = max(-2.85, min(2.85, cap.spin * 0.16 + spinImpulse + Float.random(in: -0.018...0.018)))
        } else {
            cap.spin *= 0.08
        }

        recordPlayerFlick(power: power, rimStrength: rimStrength)
        emitFlickBurst(power: power, direction: direction)
        hideAimGuide()
        setTurnPhase(.playerMoving)
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 1.0 / 60.0 : min(1.0 / 30.0, time - lastUpdateTime)
        lastUpdateTime = time
        impactCooldown = max(0, impactCooldown - dt)
        trailCooldown = max(0, trailCooldown - dt)

        switch turnPhase {
        case .playerReady:
            turnElapsedTime = 0
#if DEBUG
            triggerDebugAutoFlickIfNeeded()
#endif
        case .playerMoving:
            turnElapsedTime += dt
            stepPlayer(dt: Float(dt))
            stepRivalContactReactions(dt: Float(dt))
            resolveCollisions()
            if finishIfNeeded() {
                break
            }
            if allCapsSlow || turnElapsedTime > 2.75 {
                cap.vx = 0
                cap.vz = 0
                setTurnPhase(.rivalsMoving)
                rivalsStarted = false
            }
        case .rivalsMoving:
            turnElapsedTime += dt
            if !rivalsStarted {
                startRivalTurn()
                rivalsStarted = true
            }
            stepPlayer(dt: Float(dt))
            stepRivals(dt: Float(dt))
            resolveCollisions()
            if finishIfNeeded() {
                break
            }
            if allCapsSlow || turnElapsedTime > 2.80 {
                stopAllCaps()
                setTurnPhase(.playerReady)
            }
        case .finished:
            turnElapsedTime = 0
        }

        stepCameraRig(dt: Float(dt))
        updateNodes()
        updateCamera(force: false)
        updateViewportMetrics(using: renderer)
        updateProjectedCapAnchor(using: renderer)
        publishProgress()
    }

    private var routeHalfWidth: Float {
        routeWidth * 0.5
    }

    private var boardSpeedMultiplier: Float {
        switch currentBoard {
        case .sidewalk:
            return 1.05
        case .grass:
            return 0.88
        case .sand:
            return 0.80
        case .schoolyard:
            return 0.99
        case .table:
            return 1.14
        }
    }

    private var boardJitterMultiplier: Float {
        switch currentBoard {
        case .sidewalk:
            return 1.02
        case .grass:
            return 0.88
        case .sand:
            return 1.12
        case .schoolyard:
            return 0.96
        case .table:
            return 1.08
        }
    }

    private var allCapsSlow: Bool {
        hypot(cap.vx, cap.vz) < 0.050 && rivals.allSatisfy { hypot($0.vx, $0.vz) < 0.075 }
    }

#if DEBUG
    private func triggerDebugAutoFlickIfNeeded() {
        guard shouldAutoFlickOnLaunch, !didAutoFlickOnLaunch, finishResult == nil else {
            return
        }

        didAutoFlickOnLaunch = true
        cap.vx = 0.32
        cap.vz = 5.65
        cap.spin = 0.54
        setTurnPhase(.playerMoving)
    }
#endif

    private func makeRival(t: Float, lane: Float, spin: Float) -> CapMotion {
        let point = routePosition(t: t, lane: lane)
        return CapMotion(x: point.x, z: point.z, vx: 0, vz: 0, spin: spin, yaw: Float.random(in: -0.35...0.35))
    }

    private func buildScene() {
        scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        boardNode.childNodes.forEach { $0.removeFromParentNode() }
        capNode.childNodes.forEach { $0.removeFromParentNode() }
        aimNode.childNodes.forEach { $0.removeFromParentNode() }
        dustRoot.childNodes.forEach { $0.removeFromParentNode() }
        rivalNodes = []
        aimDashNodes = []
        aimContactNode = nil
        aimEndNode = nil

        scene.background.contents = backgroundColor()
        buildLights()
        scene.rootNode.addChildNode(boardNode)
        scene.rootNode.addChildNode(capNode)
        scene.rootNode.addChildNode(aimNode)
        scene.rootNode.addChildNode(dustRoot)
        buildBoard()
        obstacles = obstacleSpecs()
        buildRoute()
        buildFinish()
        buildObstacles()
        buildCaps()
    }

    private func backgroundColor() -> UIColor {
        switch currentBoard {
        case .sidewalk:
            return UIColor(red: 0.58, green: 0.74, blue: 0.76, alpha: 1)
        case .grass:
            return UIColor(red: 0.64, green: 0.78, blue: 0.62, alpha: 1)
        case .sand:
            return UIColor(red: 0.77, green: 0.72, blue: 0.55, alpha: 1)
        case .schoolyard:
            return UIColor(red: 0.62, green: 0.72, blue: 0.76, alpha: 1)
        case .table:
            return UIColor(red: 0.82, green: 0.64, blue: 0.42, alpha: 1)
        }
    }

    private func buildLights() {
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor(red: 0.94, green: 0.90, blue: 0.76, alpha: 1)
        ambient.light?.intensity = 620
        scene.rootNode.addChildNode(ambient)

        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light?.type = .directional
        sun.light?.castsShadow = true
        sun.light?.shadowRadius = 7
        sun.light?.shadowSampleCount = 4
        sun.light?.color = UIColor(red: 1.0, green: 0.91, blue: 0.70, alpha: 1)
        sun.light?.intensity = 720
        sun.eulerAngles = SCNVector3(-1.02, -0.54, -0.20)
        scene.rootNode.addChildNode(sun)

        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 39
        cameraNode.camera?.wantsHDR = false
        cameraNode.camera?.bloomIntensity = 0
        cameraNode.camera?.screenSpaceAmbientOcclusionIntensity = 0.04
        scene.rootNode.addChildNode(cameraNode)
    }

    private func buildBoard() {
        let slab = SCNBox(width: CGFloat(boardWidth), height: 0.30, length: CGFloat(boardDepth), chamferRadius: 0.22)
        slab.firstMaterial = material(UIColor(red: 0.28, green: 0.27, blue: 0.23, alpha: 1), roughness: 0.9)
        let slabNode = SCNNode(geometry: slab)
        slabNode.position = SCNVector3(0, -0.18, 0)
        boardNode.addChildNode(slabNode)

        let top = SCNBox(width: CGFloat(boardWidth - 0.28), height: 0.035, length: CGFloat(boardDepth - 0.28), chamferRadius: 0.16)
        top.firstMaterial = material(currentBoard.materialColor, roughness: 0.94)
        let topNode = SCNNode(geometry: top)
        topNode.position = SCNVector3(0, 0.015, 0)
        boardNode.addChildNode(topNode)

        switch currentBoard {
        case .sidewalk:
            addSidewalkTiles()
        case .grass:
            addGrassTexture()
        case .sand:
            addSandTexture()
        case .schoolyard:
            addSchoolyardTexture()
        case .table:
            addTableTexture()
        }

        addRetroProps()
        addPlaygroundDetails()
    }

    private func addSidewalkTiles() {
        let tileWidth: Float = 2.18
        let tileDepth: Float = 2.28
        let columns = Int(ceil(boardWidth / tileWidth))
        let rows = Int(ceil(boardDepth / tileDepth))
        for row in 0..<rows {
            for column in 0..<columns {
                let tile = SCNBox(
                    width: CGFloat(tileWidth - 0.06),
                    height: 0.018,
                    length: CGFloat(tileDepth - 0.06),
                    chamferRadius: 0.035
                )
                let tone = CGFloat.random(in: -0.035...0.045)
                tile.firstMaterial = material(
                    UIColor(red: 0.54 + tone, green: 0.53 + tone, blue: 0.47 + tone, alpha: 1),
                    roughness: 0.96
                )
                let node = SCNNode(geometry: tile)
                node.position = SCNVector3(
                    -boardWidth * 0.5 + tileWidth * (Float(column) + 0.5),
                    0.048,
                    -boardDepth * 0.5 + tileDepth * (Float(row) + 0.5)
                )
                boardNode.addChildNode(node)
            }
        }

        for _ in 0..<18 {
            addFlatMark(color: UIColor(red: 0.10, green: 0.09, blue: 0.08, alpha: 0.20), width: 0.035, length: Float.random(in: 0.50...1.90))
        }
    }

    private func addGrassTexture() {
        for _ in 0..<92 {
            let blade = SCNBox(width: CGFloat.random(in: 0.018...0.035), height: CGFloat.random(in: 0.10...0.26), length: 0.018, chamferRadius: 0.006)
            blade.firstMaterial = material(UIColor(red: CGFloat.random(in: 0.16...0.26), green: CGFloat.random(in: 0.38...0.58), blue: CGFloat.random(in: 0.12...0.22), alpha: 0.88), roughness: 1, transparency: 0.88)
            let node = SCNNode(geometry: blade)
            node.position = randomBoardPosition(y: 0.11)
            node.eulerAngles = SCNVector3(Float.random(in: -0.25...0.25), Float.random(in: -1.2...1.2), Float.random(in: -0.24...0.24))
            boardNode.addChildNode(node)
        }
    }

    private func addSandTexture() {
        for _ in 0..<130 {
            let grain = SCNSphere(radius: CGFloat.random(in: 0.015...0.045))
            grain.segmentCount = 8
            grain.firstMaterial = material(UIColor(red: CGFloat.random(in: 0.58...0.82), green: CGFloat.random(in: 0.44...0.64), blue: CGFloat.random(in: 0.25...0.39), alpha: 0.55), roughness: 1, transparency: 0.55)
            let node = SCNNode(geometry: grain)
            node.position = randomBoardPosition(y: Float.random(in: 0.052...0.085))
            boardNode.addChildNode(node)
        }
    }

    private func addSchoolyardTexture() {
        let tileWidth: Float = 2.45
        let tileDepth: Float = 2.10
        let columns = Int(ceil(boardWidth / tileWidth))
        let rows = Int(ceil(boardDepth / tileDepth))
        for row in 0..<rows {
            for column in 0..<columns {
                let tile = SCNBox(
                    width: CGFloat(tileWidth - 0.055),
                    height: 0.016,
                    length: CGFloat(tileDepth - 0.055),
                    chamferRadius: 0.030
                )
                let tone = CGFloat.random(in: -0.028...0.038)
                tile.firstMaterial = material(
                    UIColor(red: 0.47 + tone, green: 0.56 + tone, blue: 0.58 + tone, alpha: 1),
                    roughness: 0.98
                )
                let node = SCNNode(geometry: tile)
                node.position = SCNVector3(
                    -boardWidth * 0.5 + tileWidth * (Float(column) + 0.5),
                    0.048,
                    -boardDepth * 0.5 + tileDepth * (Float(row) + 0.5)
                )
                boardNode.addChildNode(node)
            }
        }

        for _ in 0..<24 {
            addFlatMark(color: KapselkiTheme.uiChalk.withAlphaComponent(CGFloat.random(in: 0.26...0.50)), width: Float.random(in: 0.032...0.060), length: Float.random(in: 0.36...1.35))
        }
    }

    private func addTableTexture() {
        for offset in stride(from: -boardWidth * 0.48, through: boardWidth * 0.48, by: 2.18) {
            let plank = SCNBox(width: 0.030, height: 0.010, length: CGFloat(boardDepth * 0.92), chamferRadius: 0.006)
            plank.firstMaterial = material(UIColor(red: 0.50, green: 0.31, blue: 0.14, alpha: 0.28), roughness: 1, transparency: 0.28)
            let node = SCNNode(geometry: plank)
            node.position = SCNVector3(offset, 0.070, 0)
            boardNode.addChildNode(node)
        }

        for _ in 0..<38 {
            addFlatMark(color: UIColor(red: 0.42, green: 0.25, blue: 0.10, alpha: CGFloat.random(in: 0.14...0.24)), width: Float.random(in: 0.018...0.034), length: Float.random(in: 0.46...1.70))
        }
    }

    private func addFlatMark(color: UIColor, width: Float, length: Float) {
        let mark = SCNBox(width: CGFloat(width), height: 0.008, length: CGFloat(length), chamferRadius: 0.006)
        mark.firstMaterial = material(color, roughness: 1, transparency: color.cgColor.alpha)
        let node = SCNNode(geometry: mark)
        node.position = randomBoardPosition(y: 0.072)
        node.eulerAngles.y = Float.random(in: -1.1...1.1)
        boardNode.addChildNode(node)
    }

    private func addPlaygroundDetails() {
        for _ in 0..<14 {
            let color: UIColor
            switch currentBoard {
            case .sidewalk:
                color = KapselkiTheme.uiChalk.withAlphaComponent(CGFloat.random(in: 0.22...0.44))
            case .grass:
                color = UIColor(red: 0.76, green: 0.86, blue: 0.55, alpha: CGFloat.random(in: 0.16...0.30))
            case .sand:
                color = UIColor(red: 0.98, green: 0.84, blue: 0.54, alpha: CGFloat.random(in: 0.16...0.28))
            case .schoolyard:
                color = KapselkiTheme.uiChalk.withAlphaComponent(CGFloat.random(in: 0.24...0.42))
            case .table:
                color = UIColor(red: 0.95, green: 0.77, blue: 0.45, alpha: CGFloat.random(in: 0.12...0.24))
            }
            addFlatMark(color: color, width: Float.random(in: 0.026...0.050), length: Float.random(in: 0.34...1.10))
        }

        for _ in 0..<7 {
            addChalkCross()
        }

        for _ in 0..<8 {
            let scrap = SCNBox(
                width: CGFloat(Float.random(in: 0.18...0.36)),
                height: 0.010,
                length: CGFloat(Float.random(in: 0.10...0.24)),
                chamferRadius: 0.018
            )
            let paperTone = CGFloat.random(in: -0.04...0.04)
            scrap.firstMaterial = material(
                UIColor(red: 0.94 + paperTone, green: 0.86 + paperTone, blue: 0.62 + paperTone, alpha: 0.72),
                roughness: 1,
                transparency: 0.72
            )
            let node = SCNNode(geometry: scrap)
            node.position = randomBoardPosition(y: 0.082)
            node.eulerAngles.y = Float.random(in: -1.4...1.4)
            boardNode.addChildNode(node)
        }
    }

    private func addChalkCross() {
        let root = SCNNode()
        root.position = randomBoardPosition(y: 0.086)
        root.eulerAngles.y = Float.random(in: -1.1...1.1)
        let crossMaterial = material(KapselkiTheme.uiChalk.withAlphaComponent(0.48), roughness: 1, transparency: 0.48)

        for angle in [-0.58 as Float, 0.58 as Float] {
            let bar = SCNBox(width: CGFloat(Float.random(in: 0.30...0.46)), height: 0.010, length: 0.034, chamferRadius: 0.008)
            bar.firstMaterial = crossMaterial
            let node = SCNNode(geometry: bar)
            node.eulerAngles.y = angle
            root.addChildNode(node)
        }

        boardNode.addChildNode(root)
    }

    private func addRetroProps() {
        addChalkBox(side: -1, t: 0.22)
        addGumWrapper(side: 1, t: 0.38)
        addScorePaper(side: -1, t: 0.62)
        addToyCar(side: 1, t: 0.76)
    }

    private func addChalkBox(side: Float, t: Float) {
        let root = SCNNode()
        root.position = propPosition(side: side, t: t, offset: 1.55)
        root.eulerAngles.y = Float.random(in: -0.8...0.8)

        let box = SCNBox(width: 1.12, height: 0.24, length: 0.76, chamferRadius: 0.06)
        box.firstMaterial = material(KapselkiTheme.uiRed, roughness: 0.78)
        root.addChildNode(SCNNode(geometry: box))

        let label = SCNBox(width: 0.70, height: 0.018, length: 0.34, chamferRadius: 0.02)
        label.firstMaterial = material(KapselkiTheme.uiPaper, roughness: 0.82)
        let labelNode = SCNNode(geometry: label)
        labelNode.position.y = 0.135
        root.addChildNode(labelNode)

        boardNode.addChildNode(root)
    }

    private func addGumWrapper(side: Float, t: Float) {
        let root = SCNNode()
        root.position = propPosition(side: side, t: t, offset: 1.55)
        root.eulerAngles.y = Float.random(in: -0.9...0.9)

        let wrapper = SCNBox(width: 1.50, height: 0.018, length: 0.58, chamferRadius: 0.035)
        wrapper.firstMaterial = material(KapselkiTheme.uiYellow, roughness: 0.88)
        root.addChildNode(SCNNode(geometry: wrapper))

        let stripe = SCNBox(width: 1.38, height: 0.010, length: 0.13, chamferRadius: 0.012)
        stripe.firstMaterial = material(KapselkiTheme.uiRed, roughness: 0.86)
        let stripeNode = SCNNode(geometry: stripe)
        stripeNode.position = SCNVector3(0, 0.020, -0.16)
        root.addChildNode(stripeNode)
        boardNode.addChildNode(root)
    }

    private func addScorePaper(side: Float, t: Float) {
        let root = SCNNode()
        root.position = propPosition(side: side, t: t, offset: 1.42)
        root.eulerAngles.y = Float.random(in: -0.7...0.7)

        let page = SCNBox(width: 1.18, height: 0.016, length: 0.90, chamferRadius: 0.018)
        page.firstMaterial = material(UIColor(red: 0.96, green: 0.91, blue: 0.76, alpha: 1), roughness: 0.92)
        root.addChildNode(SCNNode(geometry: page))

        for index in 0..<4 {
            let line = SCNBox(width: 0.82, height: 0.008, length: 0.018, chamferRadius: 0.004)
            line.firstMaterial = material(KapselkiTheme.uiBlue.withAlphaComponent(0.34), roughness: 0.98, transparency: 0.34)
            let node = SCNNode(geometry: line)
            node.position = SCNVector3(0.05, 0.018, -0.27 + Float(index) * 0.17)
            root.addChildNode(node)
        }
        boardNode.addChildNode(root)
    }

    private func addToyCar(side: Float, t: Float) {
        let root = SCNNode()
        root.position = propPosition(side: side, t: t, offset: 1.68)
        root.eulerAngles.y = Float.random(in: -0.8...0.8)

        let body = SCNBox(width: 0.78, height: 0.18, length: 0.42, chamferRadius: 0.08)
        body.firstMaterial = material(KapselkiTheme.uiBlue, roughness: 0.70)
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position.y = 0.10
        root.addChildNode(bodyNode)

        for x in [-0.26 as Float, 0.26 as Float] {
            for z in [-0.18 as Float, 0.18 as Float] {
                let wheel = SCNCylinder(radius: 0.065, height: 0.055)
                wheel.radialSegmentCount = 10
                wheel.firstMaterial = material(KapselkiTheme.uiInk, roughness: 0.80)
                let node = SCNNode(geometry: wheel)
                node.position = SCNVector3(x, 0.05, z)
                node.eulerAngles.z = .pi / 2
                root.addChildNode(node)
            }
        }
        boardNode.addChildNode(root)
    }

    private func propPosition(side: Float, t: Float, offset: Float) -> SCNVector3 {
        let center = routePoint(t: t)
        let tangent = routeTangent(t: t)
        let normal = SCNVector3(-tangent.z, 0, tangent.x)
        let lane = (routeHalfWidth + offset) * side
        return SCNVector3(
            clamped(center.x + normal.x * lane, min: -boardWidth * 0.46, max: boardWidth * 0.46),
            0.12,
            clamped(center.z + normal.z * lane, min: -boardDepth * 0.46, max: boardDepth * 0.46)
        )
    }

    private func buildRoute() {
        let samples = (0...routeSegmentCount).map { routePoint(t: Float($0) / Float(routeSegmentCount)) }
        let chalkStrong = material(KapselkiTheme.uiChalk, roughness: 1, transparency: 0.94)
        let chalkDust = material(KapselkiTheme.uiChalk.withAlphaComponent(0.42), roughness: 1, transparency: 0.42)

        for index in 1..<samples.count {
            if index.isMultiple(of: 15) {
                continue
            }

            let previous = samples[index - 1]
            let current = samples[index]
            let segment = current - previous
            let angle = atan2(segment.x, segment.z)
            let tangent = segment.normalized
            let normal = SCNVector3(-tangent.z, 0, tangent.x)

            for side in [-1.0 as Float, 1.0 as Float] {
                let chalk = SCNBox(width: CGFloat(Float.random(in: 0.032...0.082)), height: 0.016, length: CGFloat(Float.random(in: 0.11...0.34)), chamferRadius: 0.018)
                chalk.firstMaterial = Bool.random() ? chalkStrong : chalkDust
                let node = SCNNode(geometry: chalk)
                node.position = SCNVector3(
                    current.x + normal.x * (routeHalfWidth + Float.random(in: -0.055...0.055)) * side,
                    0.090,
                    current.z + normal.z * (routeHalfWidth + Float.random(in: -0.055...0.055)) * side
                )
                node.eulerAngles.y = angle + Float.random(in: -0.10...0.10)
                boardNode.addChildNode(node)
            }

            if index.isMultiple(of: 11) {
                addChalkArrow(at: current, angle: angle)
            }
        }
    }

    private func addChalkArrow(at point: SCNVector3, angle: Float) {
        let arrowMaterial = material(KapselkiTheme.uiChalk.withAlphaComponent(0.68), roughness: 1, transparency: 0.68)
        for side in [-1.0 as Float, 1.0 as Float] {
            let bar = SCNBox(width: 0.38, height: 0.016, length: 0.055, chamferRadius: 0.012)
            bar.firstMaterial = arrowMaterial
            let node = SCNNode(geometry: bar)
            node.position = SCNVector3(point.x, 0.083, point.z)
            node.eulerAngles.y = angle + side * 0.55
            boardNode.addChildNode(node)
        }
    }

    private func buildFinish() {
        let finishPoint = routePoint(t: 0.985)
        let tangent = routeTangent(t: 0.985)
        let normal = SCNVector3(-tangent.z, 0, tangent.x)
        let angle = atan2(tangent.x, tangent.z)
        let squareStep = routeWidth / 10

        for index in 0..<10 {
            let square = SCNBox(width: CGFloat(squareStep), height: 0.040, length: 0.25, chamferRadius: 0.004)
            square.firstMaterial = material(index.isMultiple(of: 2) ? KapselkiTheme.uiChalk : KapselkiTheme.uiInk, roughness: 0.70)
            let node = SCNNode(geometry: square)
            let lane = -routeHalfWidth + squareStep * (Float(index) + 0.5)
            node.position = SCNVector3(
                finishPoint.x + normal.x * lane,
                0.122,
                finishPoint.z + normal.z * lane
            )
            node.eulerAngles.y = angle
            boardNode.addChildNode(node)
        }
    }

    private func obstacleSpecs() -> [ObstacleSpec] {
        switch currentBoard {
        case .sidewalk:
            return [
                ObstacleSpec(t: 0.22, lane: routeHalfWidth * 0.45, radius: 0.34, kind: .matchbox),
                ObstacleSpec(t: 0.48, lane: -routeHalfWidth * 0.28, radius: 0.25, kind: .gum),
                ObstacleSpec(t: 0.72, lane: routeHalfWidth * 0.38, radius: 0.22, kind: .marble)
            ]
        case .grass:
            return [
                ObstacleSpec(t: 0.28, lane: -routeHalfWidth * 0.40, radius: 0.31, kind: .twig),
                ObstacleSpec(t: 0.52, lane: routeHalfWidth * 0.34, radius: 0.34, kind: .chalk),
                ObstacleSpec(t: 0.77, lane: -routeHalfWidth * 0.20, radius: 0.30, kind: .twig)
            ]
        case .sand:
            return [
                ObstacleSpec(t: 0.25, lane: routeHalfWidth * 0.30, radius: 0.35, kind: .chalk),
                ObstacleSpec(t: 0.54, lane: -routeHalfWidth * 0.36, radius: 0.42, kind: .matchbox),
                ObstacleSpec(t: 0.80, lane: routeHalfWidth * 0.18, radius: 0.25, kind: .marble)
            ]
        case .schoolyard:
            return [
                ObstacleSpec(t: 0.18, lane: -routeHalfWidth * 0.30, radius: 0.28, kind: .chalk),
                ObstacleSpec(t: 0.43, lane: routeHalfWidth * 0.42, radius: 0.22, kind: .marble),
                ObstacleSpec(t: 0.66, lane: -routeHalfWidth * 0.42, radius: 0.30, kind: .chalk),
                ObstacleSpec(t: 0.84, lane: routeHalfWidth * 0.12, radius: 0.28, kind: .gum)
            ]
        case .table:
            return [
                ObstacleSpec(t: 0.24, lane: routeHalfWidth * 0.34, radius: 0.35, kind: .matchbox),
                ObstacleSpec(t: 0.50, lane: -routeHalfWidth * 0.34, radius: 0.22, kind: .marble),
                ObstacleSpec(t: 0.74, lane: routeHalfWidth * 0.24, radius: 0.31, kind: .chalk)
            ]
        }
    }

    private func buildObstacles() {
        for spec in obstacles {
            let root = makeObstacle(spec)
            let position = routePosition(t: spec.t, lane: spec.lane)
            root.position = SCNVector3(position.x, 0.092, position.z)
            root.eulerAngles.y = atan2(routeTangent(t: spec.t).x, routeTangent(t: spec.t).z) + Float.random(in: -0.6...0.6)
            boardNode.addChildNode(root)
        }
    }

    private func makeObstacle(_ spec: ObstacleSpec) -> SCNNode {
        let root = SCNNode()
        let shadow = SCNCylinder(radius: CGFloat(spec.radius * 1.18), height: 0.006)
        shadow.radialSegmentCount = 24
        shadow.firstMaterial = material(UIColor.black.withAlphaComponent(0.20), roughness: 1, transparency: 0.20)
        let shadowNode = SCNNode(geometry: shadow)
        shadowNode.position.y = -0.050
        shadowNode.scale = SCNVector3(1, 1, 0.68)
        root.addChildNode(shadowNode)

        switch spec.kind {
        case .chalk:
            let chalk = SCNBox(width: CGFloat(spec.radius * 2.1), height: 0.13, length: CGFloat(spec.radius * 0.70), chamferRadius: 0.05)
            chalk.firstMaterial = material(KapselkiTheme.uiChalk, roughness: 1)
            let node = SCNNode(geometry: chalk)
            node.position.y = 0.035
            root.addChildNode(node)
        case .twig:
            let twig = SCNCylinder(radius: CGFloat(spec.radius * 0.12), height: CGFloat(spec.radius * 2.7))
            twig.radialSegmentCount = 8
            twig.firstMaterial = material(UIColor(red: 0.30, green: 0.18, blue: 0.08, alpha: 1), roughness: 0.88)
            let node = SCNNode(geometry: twig)
            node.position.y = 0.060
            node.eulerAngles.z = .pi / 2
            root.addChildNode(node)
        case .gum:
            let gum = SCNSphere(radius: CGFloat(spec.radius))
            gum.segmentCount = 12
            gum.firstMaterial = material(UIColor(red: 0.92, green: 0.63, blue: 0.70, alpha: 0.88), roughness: 0.46, transparency: 0.88)
            let node = SCNNode(geometry: gum)
            node.scale = SCNVector3(1.4, 0.07, 0.94)
            node.position.y = 0.020
            root.addChildNode(node)
        case .matchbox:
            let box = SCNBox(width: CGFloat(spec.radius * 2.25), height: CGFloat(spec.radius * 0.34), length: CGFloat(spec.radius * 1.34), chamferRadius: 0.035)
            box.firstMaterial = material(KapselkiTheme.uiRed, roughness: 0.82)
            let node = SCNNode(geometry: box)
            node.position.y = spec.radius * 0.17
            root.addChildNode(node)

            let label = SCNBox(width: CGFloat(spec.radius * 1.35), height: 0.014, length: CGFloat(spec.radius * 0.72), chamferRadius: 0.012)
            label.firstMaterial = material(KapselkiTheme.uiPaper, roughness: 0.88)
            let labelNode = SCNNode(geometry: label)
            labelNode.position.y = spec.radius * 0.36
            root.addChildNode(labelNode)
        case .marble:
            let marble = SCNSphere(radius: CGFloat(spec.radius))
            marble.segmentCount = 20
            marble.firstMaterial = material(KapselkiTheme.uiBlue.withAlphaComponent(0.78), roughness: 0.22, transparency: 0.78)
            let node = SCNNode(geometry: marble)
            node.position.y = spec.radius
            root.addChildNode(node)
        }

        return root
    }

    private func buildCaps() {
        capNode.addChildNode(makeCap(character: playerCharacter, isPlayer: true))
        let rivalCharacters = KapselkiCharacter.roster.filter { $0.id != playerCharacter.id }.prefix(4)
        for character in rivalCharacters {
            let node = makeCap(character: character, isPlayer: false)
            scene.rootNode.addChildNode(node)
            rivalNodes.append(node)
        }
    }

    private func makeCap(character: KapselkiCharacter, isPlayer: Bool) -> SCNNode {
        let root = SCNNode()
        let scale: Float = isPlayer ? 1.08 : 0.98
        let radius = CGFloat(capRadius * scale)
        let color = character.uiColor

        let shadow = SCNCylinder(radius: CGFloat(capRadius * 1.05), height: 0.010)
        shadow.radialSegmentCount = 40
        shadow.firstMaterial = material(UIColor.black.withAlphaComponent(0.16), roughness: 1, transparency: 0.16)
        let shadowNode = SCNNode(geometry: shadow)
        shadowNode.position.y = -0.030
        shadowNode.scale = SCNVector3(1.10 * scale, 1, 0.72 * scale)
        root.addChildNode(shadowNode)

        let wall = makeFlutedCapWall(radius: radius, scale: scale, color: color)
        root.addChildNode(wall)

        let metalBasin = SCNCylinder(radius: radius * 0.92, height: CGFloat(0.024 * scale))
        metalBasin.radialSegmentCount = 72
        metalBasin.firstMaterial = material(UIColor(red: 0.87, green: 0.84, blue: 0.68, alpha: 1), roughness: 0.98)
        let metalBasinNode = SCNNode(geometry: metalBasin)
        metalBasinNode.position.y = 0.092 * scale
        root.addChildNode(metalBasinNode)

        let liner = SCNCylinder(radius: radius * 0.84, height: CGFloat(0.030 * scale))
        liner.radialSegmentCount = 72
        liner.firstMaterial = material(UIColor(red: 0.97, green: 0.91, blue: 0.72, alpha: 1), roughness: 1)
        let linerNode = SCNNode(geometry: liner)
        linerNode.position.y = 0.130 * scale
        root.addChildNode(linerNode)

        let putty = SCNSphere(radius: radius * 0.76)
        putty.segmentCount = 36
        putty.firstMaterial = material(UIColor(red: 0.84, green: 0.79, blue: 0.59, alpha: 1), roughness: 1)
        let puttyNode = SCNNode(geometry: putty)
        puttyNode.position.y = 0.154 * scale
        puttyNode.scale = SCNVector3(1.0, 0.036, 0.96)
        root.addChildNode(puttyNode)

        let paperAngle = isPlayer ? Float(-0.12) : Float.random(in: -0.24...0.20)
        let sticker = SCNBox(
            width: radius * 1.06,
            height: CGFloat(0.018 * scale),
            length: radius * 0.60,
            chamferRadius: 0.032
        )
        sticker.firstMaterial = material(KapselkiTheme.uiPaper, roughness: 1)
        let stickerNode = SCNNode(geometry: sticker)
        stickerNode.position.y = 0.190 * scale
        stickerNode.eulerAngles.y = paperAngle
        root.addChildNode(stickerNode)

        let stripe = SCNBox(width: radius * 0.84, height: CGFloat(0.010 * scale), length: CGFloat(0.055 * scale), chamferRadius: 0.010)
        stripe.firstMaterial = material(character.stripeColor.lighter(by: isPlayer ? 0.06 : 0), roughness: 1)
        let stripeNode = SCNNode(geometry: stripe)
        stripeNode.position = SCNVector3(0, 0.204 * scale, -Float(radius) * 0.17)
        stripeNode.eulerAngles.y = paperAngle
        root.addChildNode(stripeNode)

        addCharacterPortrait(character, to: root, radius: Float(radius), scale: scale)

        let tape = SCNBox(width: radius * 0.82, height: CGFloat(0.008 * scale), length: CGFloat(0.044 * scale), chamferRadius: 0.010)
        tape.firstMaterial = material(UIColor.white.withAlphaComponent(0.46), roughness: 1, transparency: 0.46)
        let tapeNode = SCNNode(geometry: tape)
        tapeNode.position = SCNVector3(0, 0.226 * scale, -Float(radius) * 0.17)
        tapeNode.eulerAngles.y = paperAngle
        root.addChildNode(tapeNode)

        addCapPaperDetails(to: root, radius: Float(radius), scale: scale, paperAngle: paperAngle, accent: color, isPlayer: isPlayer)
        addCapPuttyDimples(to: root, radius: Float(radius), scale: scale)
        addCapRimDetails(to: root, radius: Float(radius), scale: scale, color: color)

        return root
    }

    private func addCharacterPortrait(_ character: KapselkiCharacter, to root: SCNNode, radius: Float, scale: Float) {
        let portrait = SCNCylinder(radius: CGFloat(radius * 0.54), height: CGFloat(0.018 * scale))
        portrait.radialSegmentCount = 72
        portrait.firstMaterial = portraitMaterial(named: character.portraitAssetName)
        let portraitNode = SCNNode(geometry: portrait)
        portraitNode.position.y = 0.221 * scale
        portraitNode.eulerAngles.y = -0.12
        root.addChildNode(portraitNode)

        let badge = SCNText(string: character.number, extrusionDepth: 0.003)
        badge.font = UIFont.systemFont(ofSize: 1, weight: .black)
        badge.flatness = 0.18
        badge.firstMaterial = material(KapselkiTheme.uiInk.withAlphaComponent(0.68), roughness: 1, transparency: 0.68)
        let badgeNode = SCNNode(geometry: badge)
        let bounds = badge.boundingBox
        badgeNode.pivot = SCNMatrix4MakeTranslation((bounds.max.x + bounds.min.x) * 0.5, (bounds.max.y + bounds.min.y) * 0.5, 0)
        badgeNode.eulerAngles = SCNVector3(-Float.pi / 2, Float.pi - 0.12, 0)
        badgeNode.scale = SCNVector3(0.060 * scale, 0.060 * scale, 0.060 * scale)
        badgeNode.position = SCNVector3(radius * 0.31, 0.244 * scale, radius * 0.28)
        root.addChildNode(badgeNode)
    }

    private func addCapPaperDetails(to root: SCNNode, radius: Float, scale: Float, paperAngle: Float, accent: UIColor, isPlayer: Bool) {
        let lineMaterial = material((isPlayer ? KapselkiTheme.uiBlue : accent).darker(by: 0.06).withAlphaComponent(0.72), roughness: 1, transparency: 0.72)
        for index in 0..<3 {
            let line = SCNBox(
                width: CGFloat(radius * Float.random(in: 0.34...0.54)),
                height: CGFloat(0.006 * scale),
                length: CGFloat(0.018 * scale),
                chamferRadius: 0.004
            )
            line.firstMaterial = lineMaterial
            let node = SCNNode(geometry: line)
            node.position = SCNVector3(
                Float.random(in: -0.08...0.08) * radius,
                0.230 * scale,
                radius * (-0.19 + Float(index) * 0.16)
            )
            node.eulerAngles.y = paperAngle + Float.random(in: -0.045...0.045)
            root.addChildNode(node)
        }

        for offset in [-0.31 as Float, 0.31 as Float] {
            let fold = SCNBox(width: CGFloat(radius * 0.18), height: CGFloat(0.007 * scale), length: CGFloat(radius * 0.12), chamferRadius: 0.007)
            fold.firstMaterial = material(UIColor(red: 0.81, green: 0.71, blue: 0.49, alpha: 0.42), roughness: 1, transparency: 0.42)
            let node = SCNNode(geometry: fold)
            node.position = SCNVector3(offset * radius, 0.232 * scale, radius * 0.27)
            node.eulerAngles.y = paperAngle + offset * 0.32
            root.addChildNode(node)
        }
    }

    private func addCapPuttyDimples(to root: SCNNode, radius: Float, scale: Float) {
        let dimpleMaterial = material(UIColor(red: 0.66, green: 0.60, blue: 0.42, alpha: 0.32), roughness: 1, transparency: 0.32)
        for index in 0..<5 {
            let dimple = SCNSphere(radius: CGFloat(radius * Float.random(in: 0.022...0.036)))
            dimple.segmentCount = 10
            dimple.firstMaterial = dimpleMaterial
            let node = SCNNode(geometry: dimple)
            let angle = Float(index) * 1.18 + Float.random(in: -0.20...0.20)
            let distance = radius * Float.random(in: 0.18...0.54)
            node.position = SCNVector3(cos(angle) * distance, 0.205 * scale, sin(angle) * distance)
            node.scale = SCNVector3(1.25, 0.18, 0.82)
            root.addChildNode(node)
        }
    }

    private func addCapRimDetails(to root: SCNNode, radius: Float, scale: Float, color: UIColor) {
        let highlight = material(UIColor.white.withAlphaComponent(0.54), roughness: 1, transparency: 0.54)
        let paintChip = material(KapselkiTheme.uiPaper.withAlphaComponent(0.66), roughness: 1, transparency: 0.66)
        let lowlight = material(color.darker(by: 0.13).withAlphaComponent(0.46), roughness: 1, transparency: 0.46)

        for index in [1, 4, 8, 12, 16, 19] {
            let dash = SCNBox(width: CGFloat(radius * 0.19), height: CGFloat(0.009 * scale), length: CGFloat(0.034 * scale), chamferRadius: 0.009)
            dash.firstMaterial = index.isMultiple(of: 4) ? paintChip : highlight
            let node = SCNNode(geometry: dash)
            let angle = Float(index) * (.pi * 2 / 21)
            node.position = SCNVector3(cos(angle) * radius * 0.86, 0.330 * scale, sin(angle) * radius * 0.86)
            node.eulerAngles.y = -angle
            root.addChildNode(node)
        }

        for index in [3, 10, 15] {
            let crease = SCNBox(width: CGFloat(radius * 0.055), height: CGFloat(0.032 * scale), length: CGFloat(0.050 * scale), chamferRadius: 0.007)
            crease.firstMaterial = lowlight
            let node = SCNNode(geometry: crease)
            let angle = Float(index) * (.pi * 2 / 21)
            node.position = SCNVector3(cos(angle) * radius * 0.99, 0.224 * scale, sin(angle) * radius * 0.99)
            node.eulerAngles.y = -angle
            root.addChildNode(node)
        }
    }

    private func makeFlutedCapWall(radius: CGFloat, scale: Float, color: UIColor) -> SCNNode {
        let segments = 96
        let toothCount: Float = 21
        let radiusFloat = Float(radius)
        let rings: [(y: Float, baseRadius: Float, wave: Float)] = [
            (0.034, 0.900, 0.006),
            (0.070, 0.965, 0.012),
            (0.145, 1.006, 0.030),
            (0.254, 1.026, 0.044),
            (0.320, 1.018, 0.046),
            (0.352, 0.982, 0.030)
        ]

        var vertices: [SCNVector3] = []
        vertices.reserveCapacity(rings.count * segments)
        var normals: [SCNVector3] = []
        normals.reserveCapacity(rings.count * segments)

        for ringIndex in rings.indices {
            let ring = rings[ringIndex]
            for segment in 0..<segments {
                let angle = Float(segment) / Float(segments) * .pi * 2
                let toothWave = cos(angle * toothCount)
                let roundedWave = toothWave * 0.80 + cos(angle * toothCount * 2) * 0.035
                let softenedWave = roundedWave * 0.92 + sin(angle * toothCount) * 0.030
                let topLift = ringIndex >= rings.count - 2 ? max(0, toothWave) * 0.010 * scale : 0
                let localRadius = radiusFloat * (ring.baseRadius + ring.wave * softenedWave)
                vertices.append(
                    SCNVector3(
                        cos(angle) * localRadius,
                        ring.y * scale + topLift,
                        sin(angle) * localRadius
                    )
                )

                let verticalBias: Float
                if ringIndex == rings.startIndex {
                    verticalBias = -0.16
                } else if ringIndex == rings.index(before: rings.endIndex) {
                    verticalBias = 0.24
                } else {
                    verticalBias = 0.08
                }
                normals.append(SCNVector3(cos(angle), verticalBias, sin(angle)).normalized)
            }
        }

        var indices: [Int32] = []
        indices.reserveCapacity((rings.count - 1) * segments * 6)
        for ringIndex in 0..<(rings.count - 1) {
            for segment in 0..<segments {
                let nextSegment = (segment + 1) % segments
                let a = Int32(ringIndex * segments + segment)
                let b = Int32(ringIndex * segments + nextSegment)
                let c = Int32((ringIndex + 1) * segments + segment)
                let d = Int32((ringIndex + 1) * segments + nextSegment)
                indices.append(contentsOf: [a, c, b, b, c, d])
            }
        }

        let source = SCNGeometrySource(vertices: vertices)
        let normalSource = SCNGeometrySource(normals: normals)
        let indexData = indices.withUnsafeBufferPointer { Data(buffer: $0) }
        let element = SCNGeometryElement(
            data: indexData,
            primitiveType: .triangles,
            primitiveCount: indices.count / 3,
            bytesPerIndex: MemoryLayout<Int32>.size
        )
        let geometry = SCNGeometry(sources: [source, normalSource], elements: [element])
        geometry.firstMaterial = material(color.lighter(by: 0.06), roughness: 1)
        return SCNNode(geometry: geometry)
    }

    private func stepPlayer(dt: Float) {
        step(motion: &cap, dt: dt, isPlayer: true)
        updatePlayerRouteState()
    }

    private func stepRivals(dt: Float) {
        for index in rivals.indices {
            step(motion: &rivals[index], dt: dt, isPlayer: false)
            updateRivalRouteState(index: index)
        }
    }

    private func stepRivalContactReactions(dt: Float) {
        for index in rivals.indices {
            guard hypot(rivals[index].vx, rivals[index].vz) > 0.025 else {
                rivals[index].vx = 0
                rivals[index].vz = 0
                continue
            }
            step(motion: &rivals[index], dt: dt, isPlayer: false)
            updateRivalRouteState(index: index)
        }
    }

    private func step(motion: inout CapMotion, dt: Float, isPlayer: Bool) {
        var velocity = SCNVector3(motion.vx, 0, motion.vz)
        let speed = velocity.horizontalLength
        guard speed > 0.006 else {
            motion.vx = 0
            motion.vz = 0
            return
        }

        let side = SCNVector3(-velocity.z, 0, velocity.x).normalized
        velocity = velocity + side * (motion.spin * currentBoard.slip * speed * 0.14 * dt)
        let friction = currentBoard.friction * (isPlayer ? 1.0 : 1.06)
        let nextSpeed = max(0, speed - friction * (0.34 + min(speed, 7.0) * 0.024) * dt)
        velocity = velocity.normalized * nextSpeed

        motion.x += velocity.x * dt
        motion.z += velocity.z * dt
        motion.vx = velocity.x
        motion.vz = velocity.z
        motion.yaw += motion.spin * dt * 1.32
        motion.spin *= max(0.82, 1 - dt * 0.55)

        resolveObstacleCollisions(for: &motion, isPlayer: isPlayer)
        clampToBoard(&motion)

        if isPlayer, speed > 0.40, trailCooldown <= 0 {
            trailCooldown = 0.055
            emitSlideTrail(at: SCNVector3(motion.x, 0.075, motion.z), velocity: velocity)
        }
    }

    private func startRivalTurn() {
        let playerContact = playerOffRouteState ? (cachedPlayerContact ?? nearestRouteContact(x: cap.x, z: cap.z)) : nearestRouteContact(x: cap.x, z: cap.z)
        let playerLane = playerOffRouteState ? 0 : laneOffset(at: playerContact, x: cap.x, z: cap.z)

        for index in rivals.indices {
            let current = nearestRouteContact(x: rivals[index].x, z: rivals[index].z)
            let gap = playerContact.t - current.t
            let attack = gap > 0 ? min(0.050, gap * 0.42) : max(-0.010, gap * 0.10)
            let targetT = clamped(current.t + 0.090 + Float(index) * 0.008 + attack + Float.random(in: -0.012...0.014), min: 0.06, max: 0.965)
            let laneLimit = routeHalfWidth * 0.82
            let tacticalLane = clamped(playerLane + (index.isMultiple(of: 2) ? 0.35 : -0.35), min: -laneLimit, max: laneLimit)
            let fallbackLane = clamped((Float(index) - 1.5) * routeHalfWidth * 0.25, min: -laneLimit, max: laneLimit)
            let lane = Bool.random() ? tacticalLane : fallbackLane
            let target = routePosition(t: targetT, lane: lane)
            let toTarget = SCNVector3(target.x - rivals[index].x, 0, target.z - rivals[index].z)
            let distance = max(0.1, toTarget.horizontalLength)
            let direction = toTarget.normalized
            let speed = min(5.25, max(1.55, distance * 0.96 + 0.95)) * (0.92 + Float(index) * 0.045) * boardSpeedMultiplier

            rivals[index].vx = direction.x * speed
            rivals[index].vz = direction.z * speed
            rivals[index].spin = (lane >= 0 ? 1 : -1) * Float.random(in: 0.16...0.56)
        }
    }

    private func resolveObstacleCollisions(for motion: inout CapMotion, isPlayer: Bool) {
        for spec in obstacles {
            let obstacle = routePosition(t: spec.t, lane: spec.lane)
            let dx = motion.x - obstacle.x
            let dz = motion.z - obstacle.z
            let distance = max(0.001, sqrt(dx * dx + dz * dz))
            let minimum = capRadius * 0.72 + spec.radius
            guard distance < minimum else {
                continue
            }

            let nx = dx / distance
            let nz = dz / distance
            let overlap = minimum - distance
            motion.x += nx * overlap * 0.92
            motion.z += nz * overlap * 0.92

            let intoObstacle = motion.vx * nx + motion.vz * nz
            if intoObstacle < 0 {
                motion.vx -= nx * intoObstacle * spec.kind.bounce
                motion.vz -= nz * intoObstacle * spec.kind.bounce
            }
            motion.vx *= spec.kind.drag
            motion.vz *= spec.kind.drag
            motion.spin += (nx * motion.vz - nz * motion.vx) * (isPlayer ? 0.44 : 0.28)

            if isPlayer, impactCooldown <= 0 {
                impactCooldown = 0.20
                publishMain { [weak self] in
                    self?.hitCue += 1
                }
                emitImpactFlash(at: SCNVector3(obstacle.x, 0.16, obstacle.z))
            }
        }
    }

    private func resolveCollisions() {
        for index in rivals.indices {
            let dx = cap.x - rivals[index].x
            let dz = cap.z - rivals[index].z
            let distance = max(0.001, sqrt(dx * dx + dz * dz))
            let minimum = capRadius * 1.82
            guard distance < minimum else {
                continue
            }

            let nx = dx / distance
            let nz = dz / distance
            let overlap = minimum - distance
            cap.x += nx * overlap * 0.55
            cap.z += nz * overlap * 0.55
            rivals[index].x -= nx * overlap * 0.45
            rivals[index].z -= nz * overlap * 0.45

            let rvx = cap.vx - rivals[index].vx
            let rvz = cap.vz - rivals[index].vz
            let relative = rvx * nx + rvz * nz
            let closing = max(0, -relative)
            let impulse = min(8.2, max(1.0, closing * 1.20 + overlap * 1.62))
            let tangent = SCNVector3(-nz, 0, nx)
            let glancing = rvx * tangent.x + rvz * tangent.z

            cap.vx = (cap.vx + nx * impulse * 0.52 - tangent.x * glancing * 0.10) * 0.80
            cap.vz = (cap.vz + nz * impulse * 0.52 - tangent.z * glancing * 0.10) * 0.80
            rivals[index].vx = (rivals[index].vx - nx * impulse * 1.16 + tangent.x * glancing * 0.22) * 0.98
            rivals[index].vz = (rivals[index].vz - nz * impulse * 1.16 + tangent.z * glancing * 0.22) * 0.98
            let spinKick = nx * rvz - nz * rvx
            cap.spin += spinKick * 0.42
            rivals[index].spin -= spinKick * 0.34

            if impactCooldown <= 0 {
                impactCooldown = 0.22
                statsStyle = min(999, statsStyle + Int(max(2, closing * 4).rounded()))
                publishStats()
                publishMain { [weak self] in
                    self?.hitCue += 1
                }
                emitImpactFlash(at: SCNVector3((cap.x + rivals[index].x) * 0.5, 0.16, (cap.z + rivals[index].z) * 0.5))
            }
        }

        guard rivals.count > 1 else {
            return
        }

        for first in 0..<(rivals.count - 1) {
            for second in (first + 1)..<rivals.count {
                let dx = rivals[first].x - rivals[second].x
                let dz = rivals[first].z - rivals[second].z
                let distance = max(0.001, sqrt(dx * dx + dz * dz))
                let minimum = capRadius * 1.74
                guard distance < minimum else {
                    continue
                }

                let nx = dx / distance
                let nz = dz / distance
                let overlap = minimum - distance
                rivals[first].x += nx * overlap * 0.50
                rivals[first].z += nz * overlap * 0.50
                rivals[second].x -= nx * overlap * 0.50
                rivals[second].z -= nz * overlap * 0.50
                rivals[first].vx *= 0.82
                rivals[first].vz *= 0.82
                rivals[second].vx *= 0.82
                rivals[second].vz *= 0.82
            }
        }
    }

    private func updatePlayerRouteState() {
        let contact = nearestRouteContact(x: cap.x, z: cap.z)
        if isRouteLegal(contact) {
            playerOffRouteState = false
            if contact.t >= playerLegalProgressT {
                playerLegalProgressT = contact.t
                cachedPlayerContact = contact
            }
            publishMain { [weak self] in
                self?.isOffRoute = false
            }
            return
        }

        playerOffRouteState = true
        publishMain { [weak self] in
            self?.isOffRoute = true
        }
        recordOffRoutePenalty(at: contact)
    }

    private func updateRivalRouteState(index: Int) {
        guard rivals.indices.contains(index), rivalLegalProgressT.indices.contains(index) else {
            return
        }

        let contact = nearestRouteContact(x: rivals[index].x, z: rivals[index].z)
        if isRouteLegal(contact) {
            rivalLegalProgressT[index] = max(rivalLegalProgressT[index], contact.t)
        }
    }

    private func recordPlayerFlick(power: Float, rimStrength: Float) {
        statsMoves += 1
        hasPenaltyThisTurn = false
        let energyCost = Int((7 + power * 16 + currentBoard.friction * 1.2).rounded())
        statsEnergy = max(0, statsEnergy - energyCost)
        let precisionBonus = max(0, 1 - abs(power - 0.62) * 1.25)
        let spinBonus = rimStrength > 0.35 ? rimStrength * 5 : 0
        statsStyle = min(999, statsStyle + Int((5 + precisionBonus * 9 + spinBonus).rounded()))
        publishStats()
        publishMain { [weak self] in
            self?.flickCue += 1
        }
    }

    private func recordOffRoutePenalty(at contact: RouteContact) {
        guard !hasPenaltyThisTurn else {
            return
        }

        hasPenaltyThisTurn = true
        statsPenalties += 1
        statsEnergy = max(0, statsEnergy - 8)
        statsStyle = max(0, statsStyle - 11)
        publishStats()
        publishMain { [weak self] in
            self?.penaltyCue += 1
        }
        emitOffRouteDust(at: SCNVector3(cap.x, 0.13, cap.z), outward: contact.outward)
    }

    private func finishIfNeeded() -> Bool {
        guard turnPhase != .finished else {
            return true
        }

        let contact = nearestRouteContact(x: cap.x, z: cap.z)
        guard isRouteLegal(contact), playerLegalProgressT >= finishTriggerT else {
            return false
        }

        playerLegalProgressT = max(playerLegalProgressT, contact.t)
        cachedPlayerContact = contact
        stopAllCaps()
        statsStyle = min(999, statsStyle + max(12, 42 - statsPenalties * 7))
        publishStats()
        setTurnPhase(.finished)

        let place = min(
            rivals.count + 1,
            rivals.indices.filter { index in
                let progress = rivalLegalProgressT.indices.contains(index) ? rivalLegalProgressT[index] : nearestRouteContact(x: rivals[index].x, z: rivals[index].z).t
                return progress >= playerLegalProgressT
            }.count + 1
        )
        let medalRank: Int
        if statsPenalties == 0, statsMoves <= 10, statsStyle >= 105 {
            medalRank = 3
        } else if statsPenalties <= 1, statsMoves <= 14 {
            medalRank = 2
        } else if statsEnergy > 0 {
            medalRank = 1
        } else {
            medalRank = 0
        }
        let result = KapselkiRunResult(
            place: place,
            boardSize: rivals.count + 1,
            moves: statsMoves,
            penalties: statsPenalties,
            energy: statsEnergy,
            styleScore: statsStyle,
            medalRank: medalRank
        )
        publishMain { [weak self] in
            self?.finishResult = result
            self?.finishCue += 1
        }
        return true
    }

    private func stopAllCaps() {
        cap.vx = 0
        cap.vz = 0
        for index in rivals.indices {
            rivals[index].vx = 0
            rivals[index].vz = 0
        }
    }

    private func setTurnPhase(_ phase: TurnPhase) {
        turnPhase = phase
        turnElapsedTime = 0
        let text: String
        let nextHint: String
        switch phase {
        case .playerReady:
            text = playerOffRouteState ? "Poza trasą" : "Twój ruch"
            nextHint = playerOffRouteState ? "Wróć kapslem na kredę jednym spokojnym pstrykiem." : "Dotknij kapsla, odciągnij palec i puść."
        case .playerMoving:
            text = playerOffRouteState ? "Poza trasą" : "Ślizg kapsla"
            nextHint = "Patrz na spin i kredową linię."
        case .rivalsMoving:
            text = "Rywale pstrykają"
            nextHint = "Za chwilę twój ruch."
        case .finished:
            text = "Meta"
            nextHint = "Jeszcze jedna szybka rundka?"
        }
        publishMain { [weak self] in
            self?.status = text
            self?.hint = nextHint
        }
    }

    private func publishStats() {
        let moves = statsMoves
        let penalties = statsPenalties
        let currentEnergy = statsEnergy
        let style = statsStyle
        publishMain { [weak self] in
            self?.moveCount = moves
            self?.penaltyCount = penalties
            self?.energy = currentEnergy
            self?.styleScore = style
        }
    }

    private func publishProgress() {
        let progress = max(0, min(100, Int((playerLegalProgressT * 100).rounded())))
        publishMain { [weak self] in
            self?.progressPercent = progress
        }
    }

    private func routePoint(t: Float) -> SCNVector3 {
        let tValue = clamped(t, min: 0, max: 1)
        let z = routeShape.startZ + tValue * routeShape.length
        let x = sin(tValue * .pi * routeShape.frequencyA + routeShape.phaseA) * routeShape.amplitudeA
            + sin(tValue * .pi * routeShape.frequencyB + routeShape.phaseB) * routeShape.amplitudeB
            + (tValue - 0.5) * routeShape.lean
        let safeX = clamped(x, min: -boardWidth * 0.5 + routeHalfWidth + 0.70, max: boardWidth * 0.5 - routeHalfWidth - 0.70)
        return SCNVector3(safeX, 0.06, z)
    }

    private func routeTangent(t: Float) -> SCNVector3 {
        let previous = routePoint(t: max(0, t - 0.012))
        let next = routePoint(t: min(1, t + 0.012))
        return SCNVector3(next.x - previous.x, 0, next.z - previous.z).normalized
    }

    private func routePosition(t: Float, lane: Float) -> SCNVector3 {
        let center = routePoint(t: t)
        let tangent = routeTangent(t: t)
        let normal = SCNVector3(-tangent.z, 0, tangent.x)
        return SCNVector3(center.x + normal.x * lane, center.y, center.z + normal.z * lane)
    }

    private func nearestRouteContact(x: Float, z: Float) -> RouteContact {
        var bestDistance = Float.greatestFiniteMagnitude
        var bestNearest = routePoint(t: 0)
        var bestT: Float = 0
        let query = SCNVector3(x, 0, z)
        var previous = routePoint(t: 0)

        for index in 1...routeSegmentCount {
            let currentT = Float(index) / Float(routeSegmentCount)
            let current = routePoint(t: currentT)
            let segment = current - previous
            let segmentLengthSquared = max(0.0001, segment.x * segment.x + segment.z * segment.z)
            let projection = ((query.x - previous.x) * segment.x + (query.z - previous.z) * segment.z) / segmentLengthSquared
            let clampedProjection = clamped(projection, min: 0, max: 1)
            let nearest = previous + segment * clampedProjection
            let dx = query.x - nearest.x
            let dz = query.z - nearest.z
            let distance = sqrt(dx * dx + dz * dz)

            if distance < bestDistance {
                bestDistance = distance
                bestNearest = nearest
                bestT = (Float(index - 1) + clampedProjection) / Float(routeSegmentCount)
            }

            previous = current
        }

        let tangent = routeTangent(t: bestT)
        let fromCenter = SCNVector3(x - bestNearest.x, 0, z - bestNearest.z)
        let fallback = SCNVector3(-tangent.z, 0, tangent.x)
        let outward = fromCenter.horizontalLength > 0.001 ? fromCenter.normalized : fallback
        return RouteContact(distance: bestDistance, nearest: bestNearest, tangent: tangent, outward: outward, t: bestT)
    }

    private func laneOffset(at contact: RouteContact, x: Float, z: Float) -> Float {
        let normal = SCNVector3(-contact.tangent.z, 0, contact.tangent.x)
        return (x - contact.nearest.x) * normal.x + (z - contact.nearest.z) * normal.z
    }

    private var routePenaltyLimit: Float {
        routeHalfWidth - capRadius * 0.15
    }

    private func isRouteLegal(_ contact: RouteContact) -> Bool {
        contact.distance <= routePenaltyLimit
    }

    private func boardPoint(fromScreen point: CGPoint, screenSize: CGSize) -> SCNVector3? {
        guard screenSize.width > 1, screenSize.height > 1 else {
            return nil
        }

        let normalizedX = Float((point.x / screenSize.width) * 2 - 1)
        let normalizedY = Float(1 - (point.y / screenSize.height) * 2)
        let aspect = Float(screenSize.width / screenSize.height)
        let fieldOfView = Float(cameraNode.camera?.fieldOfView ?? 47)
        let tangent = tan(fieldOfView * .pi / 360)
        let localDirection = SCNVector3(
            normalizedX * tangent * aspect,
            normalizedY * tangent,
            -1
        ).normalized
        let worldDirection = cameraNode.presentation.convertVector(localDirection, to: nil).normalized
        let origin = cameraNode.presentation.worldPosition

        guard abs(worldDirection.y) > 0.0001 else {
            return nil
        }

        let distance = (inputPlaneY - origin.y) / worldDirection.y
        guard distance > 0 else {
            return nil
        }

        return SCNVector3(
            origin.x + worldDirection.x * distance,
            inputPlaneY,
            origin.z + worldDirection.z * distance
        )
    }

    private func aimBoardVector(from start: CGPoint, to current: CGPoint, screenSize: CGSize) -> SCNVector3 {
        if let startPoint = activeAimStartWorld,
           let currentPoint = boardPoint(fromScreen: current, screenSize: screenSize) {
            let direction = SCNVector3(startPoint.x - currentPoint.x, 0, startPoint.z - currentPoint.z)
            if direction.horizontalLength > 0.001 {
                return direction
            }
        }

        let pullX = Float(start.x - current.x)
        let pullY = Float(start.y - current.y)
        return SCNVector3(
            pullX / max(1, Float(screenSize.width)) * boardWidth * 0.95,
            0,
            pullY / max(1, Float(screenSize.height)) * boardDepth * 0.92
        )
    }

    private func contactVector(fromScreen start: CGPoint, screenSize: CGSize) -> SCNVector3 {
        if let worldPoint = boardPoint(fromScreen: start, screenSize: screenSize) {
            let x = (worldPoint.x - cap.x) / capTouchWorldRadius
            let z = (worldPoint.z - cap.z) / capTouchWorldRadius
            return SCNVector3(clamped(x, min: -1.15, max: 1.15), 0, clamped(z, min: -1.15, max: 1.15))
        }

        let anchor = screenCapAnchor(in: screenSize)
        let radius = max(42, min(screenSize.width, screenSize.height) * 0.14)
        let x = Float((start.x - anchor.x) / radius)
        let z = Float((anchor.y - start.y) / radius)
        return SCNVector3(clamped(x, min: -1.15, max: 1.15), 0, clamped(z, min: -1.15, max: 1.15))
    }

    private func canStartAim(from start: CGPoint, screenSize: CGSize) -> Bool {
        if let worldPoint = boardPoint(fromScreen: start, screenSize: screenSize) {
            let distance = SCNVector3(worldPoint.x - cap.x, 0, worldPoint.z - cap.z).horizontalLength
            return distance <= capTouchWorldRadius
        }

        let capCenter = screenCapAnchor(in: screenSize)
        return hypot(start.x - capCenter.x, start.y - capCenter.y) <= max(150, min(screenSize.width, screenSize.height) * 0.40)
    }

    private func screenCapAnchor(in screenSize: CGSize) -> CGPoint {
        if let projectedCapAnchorRatio,
           projectedCapAnchorRatio.x >= 0,
           projectedCapAnchorRatio.x <= 1,
           projectedCapAnchorRatio.y >= 0,
           projectedCapAnchorRatio.y <= 1 {
            return CGPoint(
                x: screenSize.width * projectedCapAnchorRatio.x,
                y: screenSize.height * projectedCapAnchorRatio.y
            )
        }

        return CGPoint(x: screenSize.width * 0.42, y: screenSize.height * 0.66)
    }

    private func updateAimOverlay(preview: CGPoint, power: Float) {
        let percent = Int((power * 100).rounded())
        publishMain { [weak self] in
            self?.aimPreview = preview
            self?.aimPowerPercent = percent
            self?.isAiming = true
        }
    }

    private func hideAimGuide() {
        SCNTransaction.begin()
        SCNTransaction.disableActions = true
        aimNode.isHidden = true
        aimContactNode?.isHidden = true
        aimEndNode?.isHidden = true
        aimDashNodes.forEach { $0.isHidden = true }
        SCNTransaction.commit()
        activeAimStart = nil
        activeAimStartWorld = nil
        publishMain { [weak self] in
            self?.isAiming = false
            self?.aimPowerPercent = 0
        }
    }

    private func updateAimGuide3D(direction: SCNVector3, power: Float) {
        let horizontal = SCNVector3(direction.x, 0, direction.z).normalized
        guard horizontal.horizontalLength > 0.001 else {
            aimNode.isHidden = true
            return
        }

        prepareAimGuideNodes()
        SCNTransaction.begin()
        SCNTransaction.disableActions = true
        aimNode.isHidden = false
        let y = inputPlaneY + 0.060
        let startDistance = capRadius * 1.05
        let totalLength = 0.88 + power * 4.20
        let dashCount = min(maxAimDashCount, max(3, Int(3 + power * 4)))
        let dashSpacing = totalLength / Float(dashCount)
        let dashLength = min(0.52, max(0.24, dashSpacing * 0.60))
        let angle = atan2(horizontal.x, horizontal.z)

        if let aimContactNode {
            aimContactNode.isHidden = false
            aimContactNode.position = SCNVector3(cap.x + horizontal.x * capRadius * 0.95, y + 0.040, cap.z + horizontal.z * capRadius * 0.95)
        }

        for index in 0..<dashCount {
            let centerDistance = startDistance + Float(index) * dashSpacing + dashLength * 0.5
            let dashNode = aimDashNodes[index]
            dashNode.isHidden = false
            dashNode.opacity = 0.78 + CGFloat(power) * 0.16
            dashNode.scale = SCNVector3(1, 1, dashLength / aimDashBaseLength)
            dashNode.position = SCNVector3(cap.x + horizontal.x * centerDistance, y, cap.z + horizontal.z * centerDistance)
            dashNode.eulerAngles.y = angle
        }

        if dashCount < aimDashNodes.count {
            for index in dashCount..<aimDashNodes.count {
                aimDashNodes[index].isHidden = true
            }
        }

        if let aimEndNode {
            let endDistance = startDistance + totalLength
            aimEndNode.isHidden = false
            aimEndNode.position = SCNVector3(cap.x + horizontal.x * endDistance, y + 0.040, cap.z + horizontal.z * endDistance)
        }
        SCNTransaction.commit()
    }

    private func prepareAimGuideNodes() {
        guard aimDashNodes.isEmpty else {
            return
        }

        let contact = SCNSphere(radius: 0.12)
        contact.segmentCount = 14
        contact.firstMaterial = aimMaterial()
        let contactNode = SCNNode(geometry: contact)
        contactNode.isHidden = true
        aimNode.addChildNode(contactNode)
        aimContactNode = contactNode

        for _ in 0..<maxAimDashCount {
            let dash = SCNBox(width: 0.105, height: 0.026, length: CGFloat(aimDashBaseLength), chamferRadius: 0.026)
            dash.firstMaterial = aimMaterial()
            let node = SCNNode(geometry: dash)
            node.isHidden = true
            aimNode.addChildNode(node)
            aimDashNodes.append(node)
        }

        let end = SCNSphere(radius: 0.13)
        end.segmentCount = 14
        end.firstMaterial = aimMaterial()
        let node = SCNNode(geometry: end)
        node.isHidden = true
        aimNode.addChildNode(node)
        aimEndNode = node
    }

    private func stepCameraRig(dt: Float) {
        guard isManualCameraMode else {
            return
        }

        let lateralSpeed: Float = 5.2
        let depthSpeed: Float = 4.8
        let liftSpeed: Float = 3.0
        let zoomSpeed: Float = 4.6

        cameraOrbitOffset.x = clamped(cameraOrbitOffset.x + cameraMoveInput.x * lateralSpeed * dt, min: -5.4, max: 5.4)
        cameraOrbitOffset.z = clamped(cameraOrbitOffset.z + cameraMoveInput.z * depthSpeed * dt, min: -5.6, max: 5.6)
        cameraHeightOffset = clamped(cameraHeightOffset + cameraMoveInput.y * liftSpeed * dt, min: -2.4, max: 3.2)
        cameraZoomOffset = clamped(cameraZoomOffset + cameraZoomInput * zoomSpeed * dt, min: -4.8, max: 4.0)
    }

    private func updateNodes() {
        let speed = hypot(cap.vx, cap.vz)
        let lift = min(0.045, speed * 0.006)
        capNode.position = SCNVector3(cap.x, 0.035 + lift, cap.z)
        capNode.eulerAngles = SCNVector3(cap.vz * -0.006, cap.yaw, cap.vx * 0.006)

        for index in rivalNodes.indices where rivals.indices.contains(index) {
            rivalNodes[index].position = SCNVector3(rivals[index].x, 0.034, rivals[index].z)
            rivalNodes[index].eulerAngles.y = rivals[index].yaw
        }
    }

    private func updateCamera(force: Bool) {
        let speed = hypot(cap.vx, cap.vz)
        let activeControl = cameraMoveInput.x != 0 || cameraMoveInput.y != 0 || cameraMoveInput.z != 0 || cameraZoomInput != 0
        let desired: SCNVector3
        let lookTarget: SCNVector3

        if isManualCameraMode {
            desired = SCNVector3(
                cap.x + cameraOrbitOffset.x,
                (isPortraitViewport ? 9.20 : 10.30) + cameraHeightOffset - cameraZoomOffset * 0.34,
                cap.z - (isPortraitViewport ? 8.95 : 7.80) + cameraOrbitOffset.z + cameraZoomOffset * 0.92
            )
            lookTarget = SCNVector3(
                cap.x + cameraOrbitOffset.x * 0.22,
                0.12,
                cap.z + cameraOrbitOffset.z * 0.22
            )
        } else {
            let guide = nextRouteGuideTarget()
            let capPriority = playerOffRouteState
            let portraitSafetyZoom: Float = isPortraitViewport ? clamped((0.74 - viewportAspectRatio) * 2.2, min: 0.45, max: 1.0) : 0
            let capWeight: Float = capPriority ? (isPortraitViewport ? 0.74 : 0.64) : 0.30
            let guideWeight: Float = capPriority ? (isPortraitViewport ? 0.06 : 0.10) : 0.17
            let lookCapWeight: Float = capPriority ? (isPortraitViewport ? 0.84 : 0.78) : 0.40
            let lookGuideWeight: Float = 1 - lookCapWeight
            let heightBoost: Float = capPriority ? 0.70 + portraitSafetyZoom * 0.42 : 0
            let landscapeLift: Float = isPortraitViewport ? 0 : 1.85
            let landscapeBackTrim: Float = isPortraitViewport ? 0 : 0.92
            let speedPull: Float = capPriority ? min(0.08, speed * 0.003) : min(0.16, speed * 0.007)

            desired = SCNVector3(
                cap.x * capWeight + guide.x * guideWeight,
                8.92 + heightBoost + landscapeLift - min(0.10, speed * 0.004),
                cap.z - 8.55 + landscapeBackTrim - (capPriority ? 0.75 : 0) + (guide.z - cap.z) * (capPriority ? 0.045 : 0.14) - speedPull
            )
            lookTarget = SCNVector3(
                cap.x * lookCapWeight + guide.x * lookGuideWeight,
                0.14,
                cap.z * lookCapWeight + guide.z * lookGuideWeight
            )
        }

        if force {
            cameraNode.position = desired
            smoothedCameraLookTarget = lookTarget
            hasCameraTarget = true
        } else {
            let autoOffRouteFollow = playerOffRouteState && !isManualCameraMode
            let followSpeed: Float = activeControl ? 0.14 : (autoOffRouteFollow ? 0.125 : (turnPhase == .playerMoving ? 0.045 : 0.065))
            let lookFollowSpeed: Float = activeControl ? 0.16 : (autoOffRouteFollow ? 0.145 : (turnPhase == .playerMoving ? 0.042 : 0.075))
            cameraNode.position = cameraNode.position.lerped(to: desired, t: followSpeed)
            if hasCameraTarget {
                smoothedCameraLookTarget = smoothedCameraLookTarget.lerped(to: lookTarget, t: lookFollowSpeed)
            } else {
                smoothedCameraLookTarget = lookTarget
                hasCameraTarget = true
            }
        }
        cameraNode.look(at: smoothedCameraLookTarget)
    }

    private func nextRouteGuideTarget() -> SCNVector3 {
        let contact = cachedPlayerContact ?? nearestRouteContact(x: cap.x, z: cap.z)
        let targetT = clamped(contact.t + (turnPhase == .playerReady ? 0.078 : 0.058), min: 0.045, max: 0.985)
        let lane = laneOffset(at: contact, x: cap.x, z: cap.z)
        let softenedLane = clamped(lane * 0.34, min: -routeHalfWidth * 0.40, max: routeHalfWidth * 0.40)
        return routePosition(t: targetT, lane: softenedLane)
    }

    private func updateViewportMetrics(using renderer: SCNSceneRenderer) {
        let viewport = renderer.currentViewport
        guard viewport.width > 1, viewport.height > 1 else {
            return
        }
        viewportAspectRatio = Float(viewport.width / viewport.height)
        isPortraitViewport = viewport.height >= viewport.width
        cameraNode.camera?.fieldOfView = isPortraitViewport ? 39 : 45
    }

    private func updateProjectedCapAnchor(using renderer: SCNSceneRenderer) {
        let viewport = renderer.currentViewport
        let projected = renderer.projectPoint(SCNVector3(cap.x, 0.16, cap.z))
        guard projected.x.isFinite, projected.y.isFinite, viewport.width > 1, viewport.height > 1 else {
            return
        }

        let rawX = (CGFloat(projected.x) - viewport.minX) / viewport.width
        let rawY = (CGFloat(projected.y) - viewport.minY) / viewport.height
        let expectedY: CGFloat = 0.66
        let y = abs((1 - rawY) - expectedY) < abs(rawY - expectedY) ? 1 - rawY : rawY
        let candidate = CGPoint(x: min(1, max(0, rawX)), y: min(1, max(0, y)))

        if let previous = lastProjectedCapAnchorRatio,
           hypot(previous.x - candidate.x, previous.y - candidate.y) < 0.002 {
            return
        }
        lastProjectedCapAnchorRatio = candidate
        publishMain { [weak self] in
            self?.projectedCapAnchorRatio = candidate
        }
    }

    private func clampToBoard(_ motion: inout CapMotion) {
        let minX = -boardWidth * 0.5 + capRadius
        let maxX = boardWidth * 0.5 - capRadius
        let minZ = -boardDepth * 0.5 + capRadius
        let maxZ = boardDepth * 0.5 - capRadius

        if motion.x < minX || motion.x > maxX {
            motion.x = clamped(motion.x, min: minX, max: maxX)
            motion.vx *= -0.20
            motion.vz *= 0.72
            motion.spin *= -0.35
        }

        if motion.z < minZ || motion.z > maxZ {
            motion.z = clamped(motion.z, min: minZ, max: maxZ)
            motion.vz *= -0.20
            motion.vx *= 0.72
            motion.spin *= -0.35
        }
    }

    private func randomBoardPosition(y: Float) -> SCNVector3 {
        SCNVector3(
            Float.random(in: -boardWidth * 0.46...boardWidth * 0.46),
            y,
            Float.random(in: -boardDepth * 0.46...boardDepth * 0.46)
        )
    }

    private func emitFlickBurst(power: Float, direction: SCNVector3) {
        for _ in 0..<Int(6 + power * 10) {
            let dust = SCNSphere(radius: CGFloat.random(in: 0.024...0.058))
            dust.segmentCount = 8
            dust.firstMaterial = material(UIColor(red: 0.92, green: 0.82, blue: 0.58, alpha: 0.62), roughness: 1, transparency: 0.62)
            let node = SCNNode(geometry: dust)
            node.position = SCNVector3(cap.x, 0.22, cap.z)
            dustRoot.addChildNode(node)
            let side = SCNVector3(-direction.z, 0, direction.x)
            let move = direction * Float.random(in: -0.10...0.42) + side * Float.random(in: -0.30...0.30)
            node.runAction(.sequence([
                .group([
                    .moveBy(x: CGFloat(move.x), y: CGFloat.random(in: 0.02...0.20), z: CGFloat(move.z), duration: 0.45),
                    .fadeOut(duration: 0.45)
                ]),
                .removeFromParentNode()
            ]))
        }
    }

    private func emitSlideTrail(at position: SCNVector3, velocity: SCNVector3) {
        let speed = max(0.1, velocity.horizontalLength)
        let direction = velocity.normalized
        let trail = SCNBox(width: CGFloat(min(0.74, 0.16 + speed * 0.035)), height: 0.010, length: currentBoard == .sand ? 0.08 : 0.035, chamferRadius: 0.012)
        trail.firstMaterial = material(trailColor(), roughness: 1, transparency: currentBoard == .sand ? 0.40 : 0.26)
        let node = SCNNode(geometry: trail)
        node.position = SCNVector3(position.x - direction.x * capRadius * 0.72, position.y, position.z - direction.z * capRadius * 0.72)
        node.eulerAngles.y = atan2(direction.x, direction.z)
        dustRoot.addChildNode(node)
        node.runAction(.sequence([
            .group([
                .scale(to: 1.35, duration: 0.45),
                .fadeOut(duration: 0.45)
            ]),
            .removeFromParentNode()
        ]))
    }

    private func emitImpactFlash(at position: SCNVector3) {
        let flash = SCNSphere(radius: 0.16)
        flash.segmentCount = 12
        flash.firstMaterial = material(UIColor(red: 1.0, green: 0.86, blue: 0.40, alpha: 0.72), roughness: 0.24, transparency: 0.72)
        let node = SCNNode(geometry: flash)
        node.position = position
        dustRoot.addChildNode(node)
        node.runAction(.sequence([
            .group([
                .scale(to: 2.4, duration: 0.22),
                .fadeOut(duration: 0.22)
            ]),
            .removeFromParentNode()
        ]))
    }

    private func emitOffRouteDust(at position: SCNVector3, outward: SCNVector3) {
        for _ in 0..<10 {
            let puff = SCNSphere(radius: CGFloat.random(in: 0.034...0.078))
            puff.segmentCount = 8
            puff.firstMaterial = material(UIColor(red: 0.92, green: 0.84, blue: 0.62, alpha: 0.50), roughness: 1, transparency: 0.50)
            let node = SCNNode(geometry: puff)
            node.position = SCNVector3(position.x + Float.random(in: -0.10...0.10), position.y, position.z + Float.random(in: -0.10...0.10))
            dustRoot.addChildNode(node)
            let side = SCNVector3(-outward.z, 0, outward.x)
            let move = outward * Float.random(in: 0.05...0.28) + side * Float.random(in: -0.18...0.18)
            node.runAction(.sequence([
                .group([
                    .moveBy(x: CGFloat(move.x), y: CGFloat.random(in: 0.03...0.16), z: CGFloat(move.z), duration: 0.34),
                    .fadeOut(duration: 0.34)
                ]),
                .removeFromParentNode()
            ]))
        }
    }

    private func trailColor() -> UIColor {
        switch currentBoard {
        case .sidewalk:
            return UIColor(red: 0.86, green: 0.82, blue: 0.68, alpha: 1)
        case .grass:
            return UIColor(red: 0.32, green: 0.50, blue: 0.24, alpha: 1)
        case .sand:
            return UIColor(red: 0.78, green: 0.61, blue: 0.36, alpha: 1)
        case .schoolyard:
            return UIColor(red: 0.78, green: 0.82, blue: 0.74, alpha: 1)
        case .table:
            return UIColor(red: 0.54, green: 0.33, blue: 0.16, alpha: 1)
        }
    }

    private func material(_ color: UIColor, roughness: CGFloat, metalness: CGFloat = 0, transparency: CGFloat = 1) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .lambert
        material.diffuse.contents = color
        material.ambient.contents = color.lighter(by: 0.05)
        material.emission.contents = color.withAlphaComponent(0.035)
        material.specular.contents = UIColor.white.withAlphaComponent(max(0.03, 0.16 - roughness * 0.10 + metalness * 0.04))
        material.shininess = 0.10
        material.roughness.contents = roughness
        material.transparency = transparency
        material.isDoubleSided = true
        return material
    }

    private func portraitMaterial(named assetName: String) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.diffuse.contents = UIImage(named: assetName) ?? KapselkiTheme.uiPaper
        material.transparency = 1
        material.isDoubleSided = true
        material.locksAmbientWithDiffuse = true
        return material
    }

    private func aimMaterial() -> SCNMaterial {
        let material = material(UIColor(red: 1.0, green: 0.60, blue: 0.12, alpha: 0.92), roughness: 0.24, transparency: 0.92)
        material.emission.contents = UIColor(red: 1.0, green: 0.34, blue: 0.04, alpha: 0.80)
        return material
    }

    private func clamped(_ value: Float, min minimum: Float, max maximum: Float) -> Float {
        Swift.min(maximum, Swift.max(minimum, value))
    }

    private func clampedCameraControl(_ value: Float) -> Float {
        clamped(value, min: -1, max: 1)
    }

    private func publishMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}

private extension UIColor {
    func lighter(by amount: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(
            red: min(1, red + amount),
            green: min(1, green + amount),
            blue: min(1, blue + amount),
            alpha: alpha
        )
    }

    func darker(by amount: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(
            red: max(0, red - amount),
            green: max(0, green - amount),
            blue: max(0, blue - amount),
            alpha: alpha
        )
    }
}

private extension CGVector {
    var length: CGFloat {
        hypot(dx, dy)
    }
}

private extension SCNVector3 {
    var horizontalLength: Float {
        sqrt(x * x + z * z)
    }

    var length: Float {
        sqrt(x * x + y * y + z * z)
    }

    var normalized: SCNVector3 {
        let value = length
        guard value > 0.0001 else {
            return SCNVector3Zero
        }
        return self * (1 / value)
    }

    func rotated(by angle: Float) -> SCNVector3 {
        SCNVector3(
            x: x * cos(angle) - z * sin(angle),
            y: y,
            z: x * sin(angle) + z * cos(angle)
        )
    }

    func lerped(to target: SCNVector3, t: Float) -> SCNVector3 {
        SCNVector3(
            x: x + (target.x - x) * t,
            y: y + (target.y - y) * t,
            z: z + (target.z - z) * t
        )
    }

    static func + (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    static func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }

    static func * (lhs: SCNVector3, rhs: Float) -> SCNVector3 {
        SCNVector3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }
}
