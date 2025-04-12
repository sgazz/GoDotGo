import SwiftUI

struct GeometryUtils {
    static func distanceFromPointToLine(point: CGPoint, lineStart: CGPoint, lineEnd: CGPoint) -> CGFloat {
        let a = lineEnd.y - lineStart.y
        let b = lineStart.x - lineEnd.x
        let c = lineEnd.x * lineStart.y - lineStart.x * lineEnd.y
        
        return abs(a * point.x + b * point.y + c) / sqrt(a * a + b * b)
    }
    
    static func isPointOnLine(point: CGPoint, line: Line, snapDistance: CGFloat = 10.0) -> Bool {
        for i in 0..<line.points.count-1 {
            let start = line.points[i]
            let end = line.points[i+1]
            
            let distance = distanceFromPointToLine(point: point, lineStart: start, lineEnd: end)
            
            if distance <= snapDistance {
                let minX = min(start.x, end.x) - snapDistance
                let maxX = max(start.x, end.x) + snapDistance
                let minY = min(start.y, end.y) - snapDistance
                let maxY = max(start.y, end.y) + snapDistance
                
                if point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY {
                    return true
                }
            }
        }
        return false
    }
    
    static func findNearestCircle(to point: CGPoint, among circles: [Circle2D], snapDistance: CGFloat = 15.0) -> CGPoint? {
        return circles
            .filter { $0.isPlaced }
            .map { $0.position }
            .first { circlePosition in
                let distance = hypot(circlePosition.x - point.x, circlePosition.y - point.y)
                return distance <= snapDistance
            }
    }
} 