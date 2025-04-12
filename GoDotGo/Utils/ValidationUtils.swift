import SwiftUI

struct ValidationUtils {
    static func isPointNearExistingPlacedPoint(point: CGPoint, circles: [Circle2D], minDistance: CGFloat = 20.0) -> Bool {
        for circle in circles where circle.isPlaced {
            let distance = hypot(point.x - circle.position.x, point.y - circle.position.y)
            if distance < minDistance {
                return true
            }
        }
        return false
    }
    
    static func isValidPointPlacement(at point: CGPoint, 
                                    canSelectNewPoint: Bool,
                                    circles: [Circle2D],
                                    lines: [Line]) -> Bool {
        if !canSelectNewPoint {
            return false
        }
        
        if isPointNearExistingPlacedPoint(point: point, circles: circles) {
            return false
        }
        
        for line in lines {
            if GeometryUtils.isPointOnLine(point: point, line: line) {
                return true
            }
        }
        return false
    }
    
    static func wouldExceedConnectionLimit(start: CGPoint, 
                                         end: CGPoint,
                                         circles: [Circle2D]) -> Bool {
        let startCircle = circles.first { $0.position == start && $0.isPlaced }
        let endCircle = circles.first { $0.position == end && $0.isPlaced }
        
        guard let startC = startCircle,
              let endC = endCircle else {
            return true
        }
        
        if start == end {
            let newConnections = startC.connections + 2
            return newConnections > CircleType.red.maxConnections
        }
        
        let startNewConnections = startC.connections + 1
        let endNewConnections = endC.connections + 1
        
        return startNewConnections > CircleType.red.maxConnections || 
               endNewConnections > CircleType.red.maxConnections
    }
} 