import SwiftUI

struct Circle2D: Identifiable {
    let id = UUID()
    var position: CGPoint
    var isPlaced: Bool = false
    var color: Color
    var connections: Int = 0
    
    init(position: CGPoint, color: Color = .red, isPlaced: Bool = false, connections: Int = 0) {
        self.position = position
        self.color = color
        self.isPlaced = isPlaced
        self.connections = connections
    }
} 