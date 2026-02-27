import SpriteKit
import UIKit

// MARK: - CoinIntroScene
// SpriteKit physics scene: four coins drop one at a time (1, 5, 10, 20).
// Larger coins are heavier, bounce less, and shake the screen more on landing.
// After all four drop, a completion arc animates and the continue button appears.

@MainActor
final class CoinIntroScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Beat Definition

    enum Beat: Int, CaseIterable {
        case one    = 1
        case five   = 5
        case ten    = 10
        case twenty = 20

        var next: Beat? {
            switch self {
            case .one:    return .five
            case .five:   return .ten
            case .ten:    return .twenty
            case .twenty: return nil
            }
        }

        // Perceptual scale: diameter = 28 * sqrt(value) * 0.88
        var diameter: CGFloat {
            switch self {
            case .one:    return 28
            case .five:   return 52
            case .ten:    return 72
            case .twenty: return 96
            }
        }

        // Physics: larger coin = heavier = less bounce
        var mass:        CGFloat { switch self { case .one: 0.05; case .five: 0.20; case .ten: 0.55; case .twenty: 1.80 } }
        var restitution: CGFloat { switch self { case .one: 0.72; case .five: 0.50; case .ten: 0.30; case .twenty: 0.08 } }

        // Screen shake amplitude
        var shakeAmplitude: CGFloat { switch self { case .one: 0; case .five: 3; case .ten: 8; case .twenty: 18 } }

        var coinColor: SKColor {
            switch self {
            case .one:    return SKColor(red: 0.72, green: 0.45, blue: 0.20, alpha: 1)  // Bronze
            case .five:   return SKColor(red: 0.72, green: 0.72, blue: 0.72, alpha: 1)  // Silver
            case .ten:    return SKColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1)  // Gold
            case .twenty: return SKColor(red: 0.94, green: 0.78, blue: 0.25, alpha: 1)  // Rich Gold
            }
        }

        var labelColor: SKColor {
            self == .one ? SKColor.white : SKColor(red: 0.36, green: 0.24, blue: 0.18, alpha: 1)
        }

        // Floor shadow radius (proportional to value)
        var shadowRadius: CGFloat { switch self { case .one: 5; case .five: 14; case .ten: 28; case .twenty: 52 } }
    }

    // MARK: - Physics Categories
    private struct Physics {
        static let coin:  UInt32 = 0x1 << 0
        static let floor: UInt32 = 0x1 << 1
    }

    // MARK: - State
    var onComplete: (() -> Void)?
    var onAllBeatsComplete: (() -> Void)?   // SwiftUI shows continue button
    var reduceMotion: Bool = false

    private var currentBeat: Beat? = nil
    private var droppedNodes: [SKNode] = []
    private var pendingCoin: SKNode? = nil
    private var tapHint: SKNode? = nil
    private var floorNode: SKShapeNode!
    private var isAnimating = false
    private var allBeatsComplete = false

    // MARK: - didMove

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self

        setupFloor()
        setupWalls()

        // Start first beat after short delay
        run(.wait(forDuration: 0.4)) { [weak self] in
            self?.advanceToNextBeat()
        }
    }

    // MARK: - Floor Setup

    private func setupFloor() {
        let floorH: CGFloat = 30
        let floorY: CGFloat = floorH / 2 + 16
        let floorW = size.width + 20

        let floor = SKShapeNode(rectOf: CGSize(width: floorW, height: floorH), cornerRadius: 4)
        floor.fillColor   = SKColor(red: 0.55, green: 0.38, blue: 0.25, alpha: 1)
        floor.strokeColor = SKColor(red: 0.40, green: 0.28, blue: 0.18, alpha: 1)
        floor.lineWidth   = 2
        floor.position    = CGPoint(x: size.width / 2, y: floorY)
        floor.zPosition   = 10

        // Wood grain pattern lines
        for i in 1...3 {
            let grain = SKShapeNode()
            let path = CGMutablePath()
            let gy = CGFloat(i) * (floorH / 4)
            path.move(to: CGPoint(x: -floorW / 2 + 10, y: -floorH / 2 + gy))
            path.addLine(to: CGPoint(x: floorW / 2 - 10, y: -floorH / 2 + gy))
            grain.path = path
            grain.strokeColor = SKColor(red: 0.48, green: 0.33, blue: 0.22, alpha: 0.30)
            grain.lineWidth = 0.8
            floor.addChild(grain)
        }

        let body = SKPhysicsBody(rectangleOf: CGSize(width: floorW, height: floorH))
        body.isDynamic = false
        body.restitution = 0.1
        body.friction = 0.8
        body.categoryBitMask = Physics.floor
        body.contactTestBitMask = Physics.coin
        floor.physicsBody = body

        addChild(floor)
        floorNode = floor
    }

    private func setupWalls() {
        let wallBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0,
                                                           width: size.width,
                                                           height: size.height * 2))
        wallBody.friction = 0
        physicsBody = wallBody
    }

    // MARK: - Beat Advancement

    private func advanceToNextBeat() {
        if currentBeat == nil {
            currentBeat = .one
        } else if let next = currentBeat?.next {
            currentBeat = next
        } else {
            // All beats complete — aha moment
            playAhaMoment()
            return
        }
        guard let beat = currentBeat else { return }
        spawnCoin(for: beat)
    }

    // MARK: - Coin Spawning

    private func spawnCoin(for beat: Beat) {
        isAnimating = true
        tapHint?.removeFromParent()
        tapHint = nil

        let r = beat.diameter / 2
        let spawnX = size.width / 2
        let spawnY = size.height - 80

        let container = SKNode()
        container.position = CGPoint(x: spawnX, y: spawnY)
        container.zPosition = 50
        container.name = "pendingCoin"

        // Main circle
        let circle = SKShapeNode(circleOfRadius: r)
        circle.fillColor   = beat.coinColor
        circle.strokeColor = beat.coinColor.withAlphaComponent(0.5)
        circle.lineWidth   = r * 0.08
        circle.zPosition   = 1
        container.addChild(circle)

        // Inner ring (depth effect)
        let ring = SKShapeNode(circleOfRadius: r * 0.78)
        ring.fillColor   = .clear
        ring.strokeColor = SKColor.white.withAlphaComponent(0.28)
        ring.lineWidth   = r * 0.05
        ring.zPosition   = 2
        container.addChild(ring)

        // Top-left light reflection
        let arcPath = CGMutablePath()
        arcPath.addArc(center: .zero, radius: r * 0.86,
                       startAngle: .pi * 0.60, endAngle: .pi * 1.20, clockwise: false)
        let arc = SKShapeNode(path: arcPath)
        arc.strokeColor = SKColor.white.withAlphaComponent(0.45)
        arc.lineWidth   = r * 0.07
        arc.lineCap     = .round
        arc.zPosition   = 3
        container.addChild(arc)

        // Value label
        let label = SKLabelNode(text: "\(beat.rawValue)")
        label.fontName  = "Helvetica-Bold"
        label.fontSize  = r * 0.65
        label.fontColor = beat.labelColor
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 4
        container.addChild(label)

        // Physics — initially static (won't fall until tapped)
        let pb = SKPhysicsBody(circleOfRadius: r)
        pb.isDynamic         = false
        pb.mass              = beat.mass
        pb.restitution       = beat.restitution
        pb.friction          = 0.4
        pb.angularDamping    = 0.8
        pb.linearDamping     = 0.1
        pb.categoryBitMask   = Physics.coin
        pb.contactTestBitMask = Physics.floor
        pb.collisionBitMask  = Physics.floor
        container.physicsBody = pb

        // Entrance animation: small → full size, spring bounce
        container.alpha = 0
        container.setScale(0.35)
        addChild(container)
        pendingCoin = container

        // 20-coin anticipation wobble
        if beat == .twenty && !reduceMotion {
            let wobble = SKAction.sequence([
                .wait(forDuration: 0.3),
                .rotate(byAngle:  0.07, duration: 0.12),
                .rotate(byAngle: -0.14, duration: 0.20),
                .rotate(byAngle:  0.07, duration: 0.12),
            ])
            container.run(wobble)
        }

        container.run(.group([
            .fadeIn(withDuration: 0.20),
            .sequence([
                .scale(to: 1.18, duration: 0.22),
                .scale(to: 0.96, duration: 0.10),
                .scale(to: 1.00, duration: 0.08),
            ]),
        ])) { [weak self] in
            self?.isAnimating = false
            if let beat = self?.currentBeat {
                self?.showTapHint(below: container, beat: beat)
            }
        }
    }

    // MARK: - Tap Hint

    private func showTapHint(below node: SKNode, beat: Beat) {
        let hint = SKLabelNode(text: "👆")
        hint.fontSize  = 36
        hint.position  = CGPoint(x: node.position.x,
                                  y: node.position.y - beat.diameter * 0.75)
        hint.zPosition = 60
        hint.alpha     = 0
        addChild(hint)
        tapHint = hint

        if reduceMotion {
            hint.run(.fadeIn(withDuration: 0.3))
        } else {
            hint.run(.repeatForever(.sequence([
                .group([.fadeIn(withDuration: 0.30), .moveBy(x: 0, y: -6, duration: 0.50)]),
                .group([.fadeOut(withDuration: 0.25), .moveBy(x: 0, y: 6, duration: 0.35)]),
            ])))
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isAnimating, !allBeatsComplete else { return }
        guard let coin = pendingCoin, let beat = currentBeat else { return }

        tapHint?.removeFromParent()
        tapHint = nil
        isAnimating = true

        // Haptic fires immediately (before the drop)
        HapticService.shared.coinValueHaptic(value: beat.rawValue)
        // Sound
        SpeechService.shared.coinDropped(value: beat.rawValue)

        // 20-coin: short pause + "inhale" then release
        if beat == .twenty && !reduceMotion {
            coin.physicsBody?.isDynamic = false
            coin.run(.sequence([
                .scale(to: 1.10, duration: 0.20),
                .scale(to: 1.00, duration: 0.10),
            ])) { [weak self] in
                coin.physicsBody?.isDynamic = true
                self?.droppedNodes.append(coin)
                self?.pendingCoin = nil
            }
        } else {
            coin.physicsBody?.isDynamic = true
            droppedNodes.append(coin)
            pendingCoin = nil
        }

        // Screen shake (for larger coins)
        if beat.shakeAmplitude > 0 && !reduceMotion {
            let settle: TimeInterval = beat == .twenty ? 2.0 : 1.0
            run(.wait(forDuration: settle)) { [weak self] in
                self?.shakeCamera(amplitude: beat.shakeAmplitude)
            }
        }

        // Advance to next beat or aha moment
        let delay: TimeInterval = beat == .twenty ? 2.2 : 1.1
        run(.wait(forDuration: delay)) { [weak self] in
            self?.isAnimating = false
            self?.advanceToNextBeat()
        }
    }

    // MARK: - Physics Contact (coin hits floor)

    nonisolated func didBegin(_ contact: SKPhysicsContact) {
        let isLargeCoin = contact.bodyA.categoryBitMask == Physics.coin
                       || contact.bodyB.categoryBitMask == Physics.coin
        guard isLargeCoin else { return }

        // CGPoint is Sendable — extract before crossing actor boundary
        let point = contact.contactPoint

        Task { @MainActor [weak self] in
            guard let self, let beat = self.currentBeat else { return }
            // Add floor shadow (visual impact for larger coins only)
            if beat.shadowRadius > 10 {
                self.addImpactShadow(at: point, radius: beat.shadowRadius)
            }
            // Largest coin causes settled coins to bounce slightly
            if beat == .twenty {
                self.bounceSettledCoins()
            }
        }
    }

    private func addImpactShadow(at point: CGPoint, radius: CGFloat) {
        let shadow = SKShapeNode(circleOfRadius: radius)
        shadow.fillColor   = SKColor(red: 0.36, green: 0.24, blue: 0.18, alpha: 0.15)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: point.x, y: floorNode.position.y + 16)
        shadow.zPosition   = 9
        shadow.setScale(0)
        addChild(shadow)
        shadow.run(.sequence([
            .scale(to: 1.0, duration: 0.20),
            .wait(forDuration: 1.0),
            .fadeOut(withDuration: 0.4),
            .removeFromParent(),
        ]))
    }

    private func bounceSettledCoins() {
        // Previous 3 coins (excluding 20-coin) bounce slightly
        for (i, node) in droppedNodes.dropLast().enumerated() {
            let delay = Double(i) * 0.05
            node.run(.sequence([
                .wait(forDuration: delay),
                .moveBy(x: 0, y: 10, duration: 0.12),
                .moveBy(x: 0, y: -10, duration: 0.15),
            ]))
        }
    }

    // MARK: - Camera Shake

    private func shakeCamera(amplitude: CGFloat) {
        guard let cam = camera ?? childNode(withName: "cam") as? SKCameraNode else {
            // No camera — shake the scene instead
            shakeScene(amplitude: amplitude)
            return
        }
        let orig = cam.position
        let shake = SKAction.sequence([
            .moveBy(x:  amplitude, y: 0, duration: 0.05),
            .moveBy(x: -amplitude * 2, y: 0, duration: 0.05),
            .moveBy(x:  amplitude * 2, y: 0, duration: 0.05),
            .moveBy(x: -amplitude, y: 0, duration: 0.05),
        ])
        cam.run(.sequence([shake, .move(to: orig, duration: 0.05)]))
    }

    private func shakeScene(amplitude: CGFloat) {
        // Without a camera, shake all nodes directly
        let shake = SKAction.sequence([
            .moveBy(x:  amplitude, y: 0, duration: 0.04),
            .moveBy(x: -amplitude * 2, y: 0, duration: 0.04),
            .moveBy(x:  amplitude * 2, y: 0, duration: 0.04),
            .moveBy(x: -amplitude, y: 0, duration: 0.04),
            .moveBy(x: -amplitude, y: 0, duration: 0.04),
            .moveBy(x:  amplitude, y: 0, duration: 0.04),
        ])
        for node in droppedNodes {
            node.run(shake)
        }
        floorNode.run(shake)
    }

    // MARK: - Aha Moment (after all coins have dropped)

    private func playAhaMoment() {
        allBeatsComplete = false

        // 1) All coins glow in staggered sequence
        for (i, node) in droppedNodes.enumerated() {
            let delay = Double(i) * 0.08
            node.run(.sequence([
                .wait(forDuration: delay),
                .scale(to: 1.22, duration: 0.14),
                .scale(to: 1.00, duration: 0.18),
            ]))

            // Golden halo
            let halo = SKShapeNode(circleOfRadius: (Beat.allCases[i].diameter / 2) * 1.7)
            halo.fillColor   = SKColor(red: 0.96, green: 0.65, blue: 0.14, alpha: 0)
            halo.strokeColor = .clear
            halo.position    = node.position
            halo.zPosition   = node.zPosition - 1
            addChild(halo)
            halo.run(.sequence([
                .wait(forDuration: delay),
                .group([
                    .fadeAlpha(to: 0.35, duration: 0.22),
                    .scale(to: 1.2, duration: 0.22),
                ]),
                .wait(forDuration: 0.35),
                .fadeOut(withDuration: 0.35),
                .removeFromParent(),
            ]))
        }

        // 2) After 1.0s draw comparison arc
        run(.wait(forDuration: 1.0)) { [weak self] in
            self?.drawComparisonArc()
        }

        // 3) After 2.5s show SwiftUI continue button + narration
        run(.wait(forDuration: 2.5)) { [weak self] in
            guard let self else { return }
            self.allBeatsComplete = true
            SpeechService.shared.allCoinsRevealed()
            UIAccessibility.post(notification: .announcement,
                argument: "Amazing! You know all four coins! Tap Let's Go to start shopping!")
            self.onAllBeatsComplete?()
        }
    }

    // MARK: - Comparison Arc (connects smallest to largest coin)

    private func drawComparisonArc() {
        guard droppedNodes.count == 4 else { return }

        let startX = droppedNodes[0].position.x
        let endX   = droppedNodes[3].position.x
        let arcY   = floorNode.position.y + 55

        let arcPath = CGMutablePath()
        arcPath.move(to: CGPoint(x: startX, y: arcY))
        arcPath.addQuadCurve(
            to: CGPoint(x: endX, y: arcY),
            control: CGPoint(x: (startX + endX) / 2, y: arcY + 50)
        )

        let arcNode = SKShapeNode(path: arcPath)
        // Pride blue for the comparison arc — Apple inclusivity signal
        arcNode.strokeColor = SKColor(red: 0.00, green: 0.48, blue: 1.00, alpha: 0.85)
        arcNode.lineWidth   = 4
        arcNode.lineCap     = .round
        arcNode.alpha       = 0
        arcNode.zPosition   = 80
        addChild(arcNode)

        arcNode.run(.sequence([
            .group([.fadeIn(withDuration: 0.12), .scale(to: 1.0, duration: 0.45)]),
            .wait(forDuration: 0.55),
            .fadeOut(withDuration: 0.35),
            .removeFromParent(),
        ]))

        // Arrow at arc end
        let arrow = SKLabelNode(text: "→")
        arrow.fontSize  = 26
        arrow.fontColor = SKColor(red: 0.00, green: 0.48, blue: 1.00, alpha: 0.85)
        arrow.position  = CGPoint(x: endX + 18, y: arcY + 8)
        arrow.alpha     = 0
        arrow.zPosition = 81
        addChild(arrow)
        arrow.run(.sequence([
            .wait(forDuration: 0.40),
            .fadeIn(withDuration: 0.12),
            .wait(forDuration: 0.70),
            .fadeOut(withDuration: 0.28),
            .removeFromParent(),
        ]))
    }

    // Continue button now handled by SwiftUI overlay in CoinIntroView
}
