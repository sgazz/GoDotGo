import SwiftUI
import PencilKit

class GameViewModel: ObservableObject {
    @Published var lines: [Line] = []
    @Published var currentLine: Line?
    @Published var pulsingCircles: Set<Int> = []
    @Published var placedCircles: [Circle2D] = []
    @Published var availableCircles: [Int] = Array(0..<7)
    @Published var gameStarted: Bool = false
    @Published var blueCircles: [Circle2D] = []
    @Published var greenCircles: [Circle2D] = []
    @Published var canvasSize: CGSize = .zero
    @Published var startPoint: CGPoint?
    @Published var showInvalidPlacementMessage: Bool = false
    @Published var canSelectNewPoint: Bool = true
    
    let canvasView = PKCanvasView()
    
    private let snapDistance: CGFloat = 15.0
    
    init() {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: UIColor(NightSkyTheme.lineColor), width: NightSkyTheme.Dimensions.lineWidth)
    }
    
    var canStartGame: Bool {
        placedCircles.count >= 3
    }
    
    func resetGame() {
        lines = []
        currentLine = nil
        placedCircles = []
        availableCircles = Array(0..<7)
        pulsingCircles = []
        gameStarted = false
        blueCircles = []
        greenCircles = []
        canSelectNewPoint = true
        startPoint = nil
        canvasView.drawing = PKDrawing()
    }
    
    func startGame() {
        gameStarted = true
        availableCircles = []
        pulsingCircles = []
        let circles = createGameCircles()
        blueCircles = circles.blue
        greenCircles = circles.green
        updateCircleAnimations()
        
        // Onemogući dalje crtanje
        canvasView.isUserInteractionEnabled = false
    }
    
    private func createGameCircles() -> (blue: [Circle2D], green: [Circle2D]) {
        let blue = (0..<7).map { _ in
            Circle2D(position: .zero, color: CircleType.blue.color)
        }
        
        let green = (0..<7).map { _ in
            Circle2D(position: .zero, color: CircleType.green.color)
        }
        
        return (blue, green)
    }
    
    func updateCircleAnimations() {
        // Ažuriraj plave krugove
        for i in 0..<blueCircles.count {
            var shouldAnimate = false
            for line in lines {
                if GeometryUtils.isPointOnLine(point: blueCircles[i].position, line: line) {
                    shouldAnimate = true
                    break
                }
            }
            if blueCircles[i].isPlaced != shouldAnimate {
                blueCircles[i].isPlaced = shouldAnimate
            }
        }
        
        // Ažuriraj zelene krugove
        for i in 0..<greenCircles.count {
            var shouldAnimate = false
            for line in lines {
                if GeometryUtils.isPointOnLine(point: greenCircles[i].position, line: line) {
                    shouldAnimate = true
                    break
                }
            }
            if greenCircles[i].isPlaced != shouldAnimate {
                greenCircles[i].isPlaced = shouldAnimate
            }
        }
    }
    
    func updateConnections(start: CGPoint, end: CGPoint) {
        func updateCircleConnections(_ circle: inout Circle2D) {
            if start == end {
                circle.connections += 2
            } else {
                circle.connections += 1
            }
        }
        
        // Ažuriraj početnu tačku
        if let startIndex = placedCircles.firstIndex(where: { $0.position == start }) {
            updateCircleConnections(&placedCircles[startIndex])
        } else if let startIndex = blueCircles.firstIndex(where: { $0.position == start }) {
            updateCircleConnections(&blueCircles[startIndex])
        } else if let startIndex = greenCircles.firstIndex(where: { $0.position == start }) {
            updateCircleConnections(&greenCircles[startIndex])
        }
        
        // Ako nije self-connection, ažuriraj i krajnju tačku
        if start != end {
            if let endIndex = placedCircles.firstIndex(where: { $0.position == end }) {
                updateCircleConnections(&placedCircles[endIndex])
            } else if let endIndex = blueCircles.firstIndex(where: { $0.position == end }) {
                updateCircleConnections(&blueCircles[endIndex])
            } else if let endIndex = greenCircles.firstIndex(where: { $0.position == end }) {
                updateCircleConnections(&greenCircles[endIndex])
            }
        }
    }
    
    func placeCircle(at point: CGPoint, index: Int) {
        if !gameStarted {
            // Postavljanje crvenih tačaka
            placedCircles.append(Circle2D(position: point))
            pulsingCircles.remove(index)
            if let indexToRemove = availableCircles.firstIndex(of: index) {
                availableCircles.remove(at: indexToRemove)
            }
        } else if ValidationUtils.isValidPointPlacement(at: point,
                                                      canSelectNewPoint: canSelectNewPoint,
                                                      circles: placedCircles + blueCircles + greenCircles,
                                                      lines: lines) {
            let initialConnections = countInitialConnections(at: point)
            
            if index < 7 {
                // Plava tačka
                var newCircle = blueCircles[index]
                newCircle.position = point
                newCircle.isPlaced = true
                newCircle.connections = initialConnections
                blueCircles[index] = newCircle
            } else {
                // Zelena tačka
                let greenIndex = index - 7
                var newCircle = greenCircles[greenIndex]
                newCircle.position = point
                newCircle.isPlaced = true
                newCircle.connections = initialConnections
                greenCircles[greenIndex] = newCircle
            }
            pulsingCircles.remove(index)
            canSelectNewPoint = false
        } else {
            showInvalidPlacementMessage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showInvalidPlacementMessage = false
            }
        }
    }
    
    private func countInitialConnections(at point: CGPoint) -> Int {
        for line in lines {
            if GeometryUtils.isPointOnLine(point: point, line: line) {
                return 2
            }
        }
        return 0
    }
    
    func handleDragGesture(value: DragGesture.Value) {
        guard gameStarted else { return }
        
        let point = value.location
        
        if currentLine == nil {
            if let nearestPoint = findNearestPoint(to: point) {
                currentLine = Line(points: [nearestPoint])
                startPoint = nearestPoint
            }
        } else if let startPoint = startPoint {
            if let nearestPoint = findNearestPoint(to: point) {
                // Ako smo blizu neke tačke i to nije početna tačka, završi liniju
                if nearestPoint != startPoint {
                    var points = currentLine?.points ?? []
                    points.append(nearestPoint)
                    if !wouldExceedConnectionLimit(start: startPoint, end: nearestPoint) {
                        lines.append(Line(points: [startPoint, nearestPoint]))
                        updateConnections(start: startPoint, end: nearestPoint)
                        canSelectNewPoint = true
                    }
                    currentLine = nil
                    self.startPoint = nil
                }
            } else {
                // Ažuriraj trenutnu liniju za preview
                currentLine?.points = [startPoint, point]
            }
        }
    }
    
    func handleDragGestureEnd(value: DragGesture.Value) {
        currentLine = nil
        startPoint = nil
    }
    
    private func findNearestPoint(to point: CGPoint) -> CGPoint? {
        let allPoints = placedCircles.map { $0.position } +
                       blueCircles.filter { $0.isPlaced }.map { $0.position } +
                       greenCircles.filter { $0.isPlaced }.map { $0.position }
        
        return allPoints.min(by: { first, second in
            let firstDistance = hypot(first.x - point.x, first.y - point.y)
            let secondDistance = hypot(second.x - point.x, second.y - point.y)
            return firstDistance < secondDistance
        }).flatMap { nearestPoint in
            let distance = hypot(nearestPoint.x - point.x, nearestPoint.y - point.y)
            return distance <= snapDistance ? nearestPoint : nil
        }
    }
    
    private func wouldExceedConnectionLimit(start: CGPoint, end: CGPoint) -> Bool {
        let startConnections = countConnections(at: start)
        let endConnections = countConnections(at: end)
        return startConnections >= 3 || endConnections >= 3
    }
    
    private func countConnections(at point: CGPoint) -> Int {
        lines.reduce(0) { count, line in
            if line.points.first == point || line.points.last == point {
                return count + 1
            }
            return count
        }
    }
} 