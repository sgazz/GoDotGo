import SwiftUI

struct NightSkyTheme {
    // Boje
    static let backgroundColor = Color(red: 0.05, green: 0.05, blue: 0.15) // Tamno plava kao noćno nebo
    static let redDotColor = Color(red: 1.0, green: 0.3, blue: 0.3).opacity(0.9)
    static let blueDotColor = Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.9)
    static let greenDotColor = Color(red: 0.3, green: 0.9, blue: 0.5).opacity(0.9)
    static let lineColor = Color.white.opacity(0.6)
    
    // Dimenzije
    struct Dimensions {
        static let dotSize: CGFloat = 20
        static let lineWidth: CGFloat = 2.5
        static let glowRadius: CGFloat = 10
        static let backgroundStarSize: CGFloat = 2
    }
    
    // Animacije
    struct Animation {
        static let dotPulse = SwiftUI.Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        static let starTwinkle = SwiftUI.Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)
        static let lineGlow = SwiftUI.Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)
    }
}

// View modifier za dodavanje sjaja (glow effect)
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius / 2)
            .shadow(color: color, radius: radius / 2)
    }
}

// View modifier za noćno nebo sa zvezdama
struct NightSkyBackground: ViewModifier {
    @State private var stars: [(position: CGPoint, opacity: Double)] = []
    let numberOfStars = 50
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                // Pozadina
                NightSkyTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                // Zvezde
                ForEach(0..<stars.count, id: \.self) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: NightSkyTheme.Dimensions.backgroundStarSize,
                               height: NightSkyTheme.Dimensions.backgroundStarSize)
                        .position(x: stars[index].position.x,
                                y: stars[index].position.y)
                        .opacity(stars[index].opacity)
                        .animation(NightSkyTheme.Animation.starTwinkle, value: stars[index].opacity)
                }
                
                content
            }
            .onAppear {
                // Generisanje nasumičnih zvezda
                stars = (0..<numberOfStars).map { _ in
                    let x = CGFloat.random(in: 0...geometry.size.width)
                    let y = CGFloat.random(in: 0...geometry.size.height)
                    let opacity = Double.random(in: 0.3...0.7)
                    return (CGPoint(x: x, y: y), opacity)
                }
                
                // Animacija treperenja zvezda
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                    for i in 0..<stars.count {
                        if Double.random(in: 0...1) < 0.3 {
                            stars[i].opacity = Double.random(in: 0.3...0.7)
                        }
                    }
                }
            }
        }
    }
}

// Extension za lakše korišćenje modifiera
extension View {
    func glow(color: Color = .white, radius: CGFloat = NightSkyTheme.Dimensions.glowRadius) -> some View {
        self.modifier(GlowEffect(color: color, radius: radius))
    }
    
    func nightSkyTheme() -> some View {
        self.modifier(NightSkyBackground())
    }
} 