import SwiftUI

enum CircleType {
    case red
    case blue
    case green
    
    var color: Color {
        switch self {
        case .red:
            return NightSkyTheme.redDotColor
        case .blue:
            return NightSkyTheme.blueDotColor
        case .green:
            return NightSkyTheme.greenDotColor
        }
    }
    
    var maxConnections: Int {
        return 3
    }
} 