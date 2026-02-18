import Foundation
import CoreGraphics

public enum EdgeZone: String, Sendable {
    case topRight
    case topLeft
}

public enum EdgeEvent: Sendable {
    case entered
    case triggered
    case exited
}

public struct EdgeTrigger: Sendable {
    public var zone: EdgeZone
    public var enterThreshold: CGFloat
    public var exitThreshold: CGFloat
    public var dwellTime: TimeInterval

    public init(zone: EdgeZone, enterThreshold: CGFloat = 5, exitThreshold: CGFloat = 50, dwellTime: TimeInterval = 0.15) {
        self.zone = zone
        self.enterThreshold = enterThreshold
        self.exitThreshold = exitThreshold
        self.dwellTime = dwellTime
    }
}

public final class EdgeDetector: @unchecked Sendable {
    public var onEdgeEvent: ((EdgeEvent) -> Void)?

    private let trigger: EdgeTrigger
    private let screenBounds: CGRect
    private var isInZone = false
    private var dwellTimer: DispatchWorkItem?
    private var hasTriggered = false
    private let queue: DispatchQueue

    public init(trigger: EdgeTrigger, screenBounds: CGRect, queue: DispatchQueue = .main) {
        self.trigger = trigger
        self.screenBounds = screenBounds
        self.queue = queue
    }

    public func update(position: CGPoint) {
        let inZone = isInsideEnterZone(position)
        let outsideExit = isOutsideExitZone(position)

        if inZone && !isInZone {
            isInZone = true
            hasTriggered = false
            onEdgeEvent?(.entered)
            startDwellTimer()
        } else if outsideExit && isInZone {
            isInZone = false
            cancelDwellTimer()
            if hasTriggered {
                hasTriggered = false
                onEdgeEvent?(.exited)
            }
        }
    }

    /// Mark the detector as "already in zone" so the cursor must leave and
    /// re-enter before the next trigger fires.
    public func armAfterEntry() {
        isInZone = true
        hasTriggered = false
        cancelDwellTimer()
    }

    private func isInsideEnterZone(_ pos: CGPoint) -> Bool {
        let t = trigger.enterThreshold
        switch trigger.zone {
        case .topRight:
            return pos.x >= screenBounds.maxX - t && pos.y <= screenBounds.minY + t
        case .topLeft:
            return pos.x <= screenBounds.minX + t && pos.y <= screenBounds.minY + t
        }
    }

    private func isOutsideExitZone(_ pos: CGPoint) -> Bool {
        let t = trigger.exitThreshold
        switch trigger.zone {
        case .topRight:
            return pos.x < screenBounds.maxX - t || pos.y > screenBounds.minY + t
        case .topLeft:
            return pos.x > screenBounds.minX + t || pos.y > screenBounds.minY + t
        }
    }

    private func startDwellTimer() {
        cancelDwellTimer()
        let item = DispatchWorkItem { [weak self] in
            guard let self, self.isInZone else { return }
            self.hasTriggered = true
            self.onEdgeEvent?(.triggered)
        }
        dwellTimer = item
        queue.asyncAfter(deadline: .now() + trigger.dwellTime, execute: item)
    }

    private func cancelDwellTimer() {
        dwellTimer?.cancel()
        dwellTimer = nil
    }
}
