import Foundation
import CoreGraphics

public struct ScreenGeometry {
    public var bounds: CGRect
    /// Individual display rects (populated by allDisplays())
    public var displayRects: [CGRect]

    public init(bounds: CGRect, displayRects: [CGRect] = []) {
        self.bounds = bounds
        self.displayRects = displayRects
    }

    /// Single main display only.
    public static func mainDisplay() -> ScreenGeometry {
        let id = CGMainDisplayID()
        let bounds = CGDisplayBounds(id)
        return ScreenGeometry(bounds: bounds, displayRects: [bounds])
    }

    /// Union of all connected displays — full virtual screen.
    public static func allDisplays(log: Bool = false) -> ScreenGeometry {
        var displayIDs = [CGDirectDisplayID](repeating: 0, count: 32)
        var count: UInt32 = 0
        CGGetActiveDisplayList(32, &displayIDs, &count)

        guard count > 0 else { return mainDisplay() }

        var rects: [CGRect] = []
        let mainID = CGMainDisplayID()
        for i in 0..<Int(count) {
            let id = displayIDs[i]
            let b = CGDisplayBounds(id)
            rects.append(b)
            if log {
                let isMain = (id == mainID)
                print("[Screen] Display \(i): \(Int(b.width))x\(Int(b.height)) at (\(Int(b.origin.x)), \(Int(b.origin.y)))\(isMain ? " [main]" : "")")
            }
        }

        var union = rects[0]
        for i in 1..<rects.count {
            union = union.union(rects[i])
        }
        if log {
            print("[Screen] Virtual screen: \(Int(union.width))x\(Int(union.height)) at (\(Int(union.origin.x)), \(Int(union.origin.y))) → maxX=\(Int(union.maxX)), maxY=\(Int(union.maxY))")
        }
        return ScreenGeometry(bounds: union, displayRects: rects)
    }

    /// Returns the bounds of the display whose right edge is the rightmost (for sender edge detection).
    public func displayAtRightEdge() -> CGRect {
        displayRects.max(by: { $0.maxX < $1.maxX }) ?? bounds
    }

    /// Returns the bounds of the display whose left edge is the leftmost (for receiver cursor entry).
    public func displayAtLeftEdge() -> CGRect {
        displayRects.min(by: { $0.minX < $1.minX }) ?? bounds
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
