import Foundation
import CoreGraphics

public struct ScreenGeometry {
    public var bounds: CGRect

    public init(bounds: CGRect) {
        self.bounds = bounds
    }

    /// Single main display only.
    public static func mainDisplay() -> ScreenGeometry {
        let id = CGMainDisplayID()
        let bounds = CGDisplayBounds(id)
        return ScreenGeometry(bounds: bounds)
    }

    /// Union of all connected displays — full virtual screen.
    public static func allDisplays() -> ScreenGeometry {
        var displayIDs = [CGDirectDisplayID](repeating: 0, count: 32)
        var count: UInt32 = 0
        CGGetActiveDisplayList(32, &displayIDs, &count)

        guard count > 0 else { return mainDisplay() }

        var union = CGDisplayBounds(displayIDs[0])
        for i in 1..<Int(count) {
            union = union.union(CGDisplayBounds(displayIDs[i]))
        }
        return ScreenGeometry(bounds: union)
    }

    public func normalize(point: CGPoint) -> (x: Double, y: Double) {
        let x = (point.x - bounds.minX) / bounds.width
        let y = (point.y - bounds.minY) / bounds.height
        return (x: Double(x), y: Double(y))
    }

    public func denormalize(x: Double, y: Double) -> CGPoint {
        CGPoint(
            x: bounds.minX + CGFloat(x) * bounds.width,
            y: bounds.minY + CGFloat(y) * bounds.height
        )
    }
}
