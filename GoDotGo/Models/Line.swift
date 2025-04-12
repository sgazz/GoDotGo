import SwiftUI

struct Line: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    
    init(points: [CGPoint], color: Color = NightSkyTheme.lineColor, lineWidth: CGFloat = NightSkyTheme.Dimensions.lineWidth) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
    }
} 