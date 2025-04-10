//
//  ContentView.swift
//  GoDotGo
//
//  Created by Gazza on 9. 4. 2025..
//

import SwiftUI

struct Circle2D {
    var position: CGPoint
    var isPlaced: Bool = false  // Da li je tačka postavljena na canvas
    var color: Color = .red
    var connections: Int = 0
}

struct Line {
    var points: [CGPoint]
    var color: Color = .black
    var lineWidth: CGFloat = 2.5
}

struct MainView: View {
    @State private var lines: [Line] = []
    @State private var currentLine: Line?
    @State private var pulsingCircles: Set<Int> = []
    @State private var placedCircles: [Circle2D] = []
    @State private var availableCircles: [Int] = Array(0..<7)
    @State private var gameStarted: Bool = false
    @State private var blueCircles: [Circle2D] = []
    @State private var greenCircles: [Circle2D] = []
    @State private var canvasSize: CGSize = .zero
    @State private var startPoint: CGPoint?
    @State private var showInvalidPlacementMessage: Bool = false
    @State private var canSelectNewPoint: Bool = true
    
    private let snapDistance: CGFloat = 15.0
    
    private var canStartGame: Bool {
        placedCircles.count >= 3
    }
    
    private func findNearestCircle(to point: CGPoint) -> CGPoint? {
        // Uzimamo samo postavljene krugove
        let allCircles = placedCircles + 
                        blueCircles.filter { $0.isPlaced } + 
                        greenCircles.filter { $0.isPlaced }
        
        return allCircles.map { $0.position }
            .first { circlePosition in
                let distance = hypot(circlePosition.x - point.x, circlePosition.y - point.y)
                return distance <= snapDistance
            }
    }
    
    private func isValidLine(from start: CGPoint, to end: CGPoint) -> Bool {
        guard let _ = findNearestCircle(to: start),
              let _ = findNearestCircle(to: end) else {
            return false
        }
        return true
    }
    
    private func createGameCircles(in size: CGSize) -> (blue: [Circle2D], green: [Circle2D]) {
        let blue = (0..<7).map { _ in
            Circle2D(position: .zero, color: .blue)
        }
        
        let green = (0..<7).map { _ in
            Circle2D(position: .zero, color: .green)
        }
        
        return (blue, green)
    }
    
    private func getConnectionCount(for point: CGPoint) -> Int {
        if let index = placedCircles.firstIndex(where: { $0.position == point }) {
            return placedCircles[index].connections
        }
        return 0
    }
    
    private func getCircleAtPosition(_ position: CGPoint) -> (circle: Circle2D, type: CircleType, index: Int)? {
        // Proveri crvene tačke
        if let index = placedCircles.firstIndex(where: { $0.position == position }) {
            return (placedCircles[index], .red, index)
        }
        
        // Proveri plave tačke
        if let index = blueCircles.firstIndex(where: { $0.position == position && $0.isPlaced }) {
            return (blueCircles[index], .blue, index)
        }
        
        // Proveri zelene tačke
        if let index = greenCircles.firstIndex(where: { $0.position == position && $0.isPlaced }) {
            return (greenCircles[index], .green, index)
        }
        
        return nil
    }
    
    private func countInitialConnections(at point: CGPoint) -> Int {
        // Kada se tačka postavi na liniju, ona dobija 2 konekcije
        // jer preseca liniju na kojoj se nalazi
        for line in lines {
            if isPointOnLine(point: point, line: line) {
                return 2
            }
        }
        return 0
    }
    
    private func wouldExceedConnectionLimit(start: CGPoint, end: CGPoint) -> Bool {
        guard let startCircle = getCircleAtPosition(start),
              let endCircle = getCircleAtPosition(end) else {
            return true
        }
        
        // Ako je self-connection, računa se kao 2 konekcije
        if start == end {
            let newConnections = startCircle.circle.connections + 2
            print("Self connection check - Current: \(startCircle.circle.connections), New: \(newConnections)")
            return newConnections > 3
        }
        
        // Proveri obe tačke
        let startNewConnections = startCircle.circle.connections + 1
        let endNewConnections = endCircle.circle.connections + 1
        
        print("Connection check - Start: \(startCircle.circle.connections) -> \(startNewConnections), End: \(endCircle.circle.connections) -> \(endNewConnections)")
        
        return startNewConnections > 3 || endNewConnections > 3
    }
    
    private func updateConnections(start: CGPoint, end: CGPoint) {
        print("Updating connections - Start: \(start), End: \(end)")
        
        // Ažuriraj broj konekcija za početnu tačku
        if let startCircle = getCircleAtPosition(start) {
            switch startCircle.type {
            case .red:
                placedCircles[startCircle.index].connections += 1
                print("Red circle at \(start) now has \(placedCircles[startCircle.index].connections) connections")
            case .blue:
                blueCircles[startCircle.index].connections += 1
                print("Blue circle at \(start) now has \(blueCircles[startCircle.index].connections) connections")
            case .green:
                greenCircles[startCircle.index].connections += 1
                print("Green circle at \(start) now has \(greenCircles[startCircle.index].connections) connections")
            }
        }
        
        // Ako je self-connection, dodaj još jednu konekciju istoj tački
        if start == end {
            if let startCircle = getCircleAtPosition(start) {
                switch startCircle.type {
                case .red:
                    placedCircles[startCircle.index].connections += 1
                    print("Red circle self-connection at \(start) now has \(placedCircles[startCircle.index].connections) connections")
                case .blue:
                    blueCircles[startCircle.index].connections += 1
                    print("Blue circle self-connection at \(start) now has \(blueCircles[startCircle.index].connections) connections")
                case .green:
                    greenCircles[startCircle.index].connections += 1
                    print("Green circle self-connection at \(start) now has \(greenCircles[startCircle.index].connections) connections")
                }
            }
        } else {
            // Ažuriraj broj konekcija za krajnju tačku
            if let endCircle = getCircleAtPosition(end) {
                switch endCircle.type {
                case .red:
                    placedCircles[endCircle.index].connections += 1
                    print("Red circle at \(end) now has \(placedCircles[endCircle.index].connections) connections")
                case .blue:
                    blueCircles[endCircle.index].connections += 1
                    print("Blue circle at \(end) now has \(blueCircles[endCircle.index].connections) connections")
                case .green:
                    greenCircles[endCircle.index].connections += 1
                    print("Green circle at \(end) now has \(greenCircles[endCircle.index].connections) connections")
                }
            }
        }
    }
    
    private func distanceFromPointToLine(point: CGPoint, lineStart: CGPoint, lineEnd: CGPoint) -> CGFloat {
        let a = lineEnd.y - lineStart.y
        let b = lineStart.x - lineEnd.x
        let c = lineEnd.x * lineStart.y - lineStart.x * lineEnd.y
        
        let distance = abs(a * point.x + b * point.y + c) / sqrt(a * a + b * b)
        return distance
    }
    
    private func isPointOnLine(point: CGPoint, line: Line) -> Bool {
        let snapDistance: CGFloat = 10.0 // Rastojanje za snap na liniju
        
        for i in 0..<line.points.count-1 {
            let start = line.points[i]
            let end = line.points[i+1]
            
            // Proveri da li je tačka blizu segmenta linije
            let distance = distanceFromPointToLine(point: point, lineStart: start, lineEnd: end)
            
            if distance <= snapDistance {
                // Proveri da li je tačka između početka i kraja segmenta
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
    
    private func isPointNearExistingPlacedPoint(point: CGPoint) -> Bool {
        let minDistance: CGFloat = 20.0
        
        // Proveri postavljene plave tačke
        for circle in blueCircles where circle.isPlaced {
            let distance = hypot(point.x - circle.position.x, point.y - circle.position.y)
            if distance < minDistance {
                return true
            }
        }
        
        // Proveri postavljene zelene tačke
        for circle in greenCircles where circle.isPlaced {
            let distance = hypot(point.x - circle.position.x, point.y - circle.position.y)
            if distance < minDistance {
                return true
            }
        }
        
        return false
    }
    
    private func isValidPointPlacement(at point: CGPoint) -> Bool {
        // Ako ne možemo da postavimo novu tačku, odmah vrati false
        if !canSelectNewPoint {
            return false
        }
        
        // Ako je tačka preblizu postojećoj postavljenoj tački, nije validna
        if isPointNearExistingPlacedPoint(point: point) {
            return false
        }
        
        // Proveri da li je tačka na nekoj liniji
        for line in lines {
            if isPointOnLine(point: point, line: line) {
                return true
            }
        }
        return false
    }
    
    private func updateCircleAnimations() {
        // Ažuriraj plave krugove
        for i in 0..<blueCircles.count {
            var shouldAnimate = false
            for line in lines {
                if isPointOnLine(point: blueCircles[i].position, line: line) {
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
                if isPointOnLine(point: greenCircles[i].position, line: line) {
                    shouldAnimate = true
                    break
                }
            }
            if greenCircles[i].isPlaced != shouldAnimate {
                greenCircles[i].isPlaced = shouldAnimate
            }
        }
    }
    
    private enum CircleType {
        case red, blue, green
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 40) {
                Spacer()
                
                Button(action: {
                    lines = []
                    currentLine = nil
                    placedCircles = []
                    availableCircles = Array(0..<7)
                    pulsingCircles = []
                    gameStarted = false
                    blueCircles = []
                    greenCircles = []
                    canSelectNewPoint = true
                    // Reset all connection counts
                    placedCircles = placedCircles.map { circle in
                        var newCircle = circle
                        newCircle.connections = 0
                        return newCircle
                    }
                }) {
                    Text("New Game")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 180, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                                .shadow(radius: 5)
                        )
                }

                VStack(spacing: 10) {
                    if !gameStarted {
                        // Prikaz crvenih tačaka pre starta igre
                        HStack(spacing: 15) {
                            ForEach(0..<7, id: \.self) { index in
                                if availableCircles.contains(index) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 20, height: 20)
                                        .scaleEffect(pulsingCircles.contains(index) ? 1.3 : 1.0)
                                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), 
                                                 value: pulsingCircles.contains(index))
                                        .onTapGesture {
                                            if pulsingCircles.contains(index) {
                                                pulsingCircles.remove(index)
                                            } else {
                                                pulsingCircles = [index]
                                            }
                                        }
                                } else {
                                    Color.clear
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                    } else {
                        // Prikaz plavih tačaka
                        HStack(spacing: 15) {
                            ForEach(0..<7, id: \.self) { index in
                                if !blueCircles[index].isPlaced {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 20, height: 20)
                                        .scaleEffect(pulsingCircles.contains(index) ? 1.3 : 1.0)
                                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                                                 value: pulsingCircles.contains(index))
                                        .onTapGesture {
                                            if pulsingCircles.contains(index) {
                                                pulsingCircles.remove(index)
                                            } else {
                                                pulsingCircles = [index]
                                            }
                                        }
                                } else {
                                    Color.clear
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                        
                        // Prikaz zelenih tačaka
                        HStack(spacing: 15) {
                            ForEach(0..<7, id: \.self) { index in
                                if !greenCircles[index].isPlaced {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 20, height: 20)
                                        .scaleEffect(pulsingCircles.contains(index + 7) ? 1.3 : 1.0)
                                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                                                 value: pulsingCircles.contains(index + 7))
                                        .onTapGesture {
                                            if pulsingCircles.contains(index + 7) {
                                                pulsingCircles.remove(index + 7)
                                            } else {
                                                pulsingCircles = [index + 7]
                                            }
                                        }
                                } else {
                                    Color.clear
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                    }
                }
                .frame(minWidth: 200)
                
                Button(action: {
                    gameStarted = true
                    availableCircles = []  // Samo uklanjamo preostale crvene krugove iz HStack-a
                    pulsingCircles = []    // Resetujemo pulsiranje
                    let circles = createGameCircles(in: canvasSize)
                    blueCircles = circles.blue
                    greenCircles = circles.green
                    updateCircleAnimations() // Proveri inicijalne animacije
                }) {
                    Text("Start Game")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 180, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(canStartGame ? Color.green : Color.green.opacity(0.5))
                                .shadow(radius: 5)
                        )
                }
                .disabled(!canStartGame)
                
                Spacer()
            }
            .padding(.top, 50)
            .padding(.bottom, 20)
            
            GeometryReader { geometry in
                Canvas { context, size in
                    let strokeStyle = StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                    
                    if gameStarted {
                        // Draw completed lines
                        for line in lines {
                            var path = Path()
                            if let firstPoint = line.points.first {
                                path.move(to: firstPoint)
                                for point in line.points.dropFirst() {
                                    path.addLine(to: point)
                                }
                                context.stroke(path, with: .color(line.color), style: strokeStyle)
                            }
                        }
                        
                        // Draw current line
                        if let currentLine = currentLine {
                            var path = Path()
                            if let firstPoint = currentLine.points.first {
                                path.move(to: firstPoint)
                                for point in currentLine.points.dropFirst() {
                                    path.addLine(to: point)
                                }
                                context.stroke(path, with: .color(currentLine.color), style: strokeStyle)
                            }
                        }
                        
                        // Draw placed blue circles
                        for circle in blueCircles where circle.isPlaced {
                            let circlePath = Path(ellipseIn: CGRect(x: circle.position.x - 10,
                                                                   y: circle.position.y - 10,
                                                                   width: 20,
                                                                   height: 20))
                            context.fill(circlePath, with: .color(.blue))
                        }
                        
                        // Draw placed green circles
                        for circle in greenCircles where circle.isPlaced {
                            let circlePath = Path(ellipseIn: CGRect(x: circle.position.x - 10,
                                                                   y: circle.position.y - 10,
                                                                   width: 20,
                                                                   height: 20))
                            context.fill(circlePath, with: .color(.green))
                        }
                    }
                    
                    // Draw placed red circles - always visible
                    for circle in placedCircles {
                        let circlePath = Path(ellipseIn: CGRect(x: circle.position.x - 10, 
                                                               y: circle.position.y - 10,
                                                               width: 20, 
                                                               height: 20))
                        context.fill(circlePath, with: .color(.red))
                    }
                }
                .background(Color.white)
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            guard gameStarted else { return }
                            
                            let point = value.location
                            
                            if currentLine == nil {
                                // Počni liniju samo ako je početna tačka blizu neke tačke
                                if let nearestPoint = findNearestCircle(to: point) {
                                    currentLine = Line(points: [nearestPoint])
                                    startPoint = nearestPoint
                                }
                            } else {
                                // Dodaj tačke za freehand crtanje
                                if let lastPoint = currentLine?.points.last,
                                   hypot(point.x - lastPoint.x, point.y - lastPoint.y) > 1 {
                                    currentLine?.points.append(point)
                                }
                            }
                        }
                        .onEnded { value in
                            guard gameStarted else { return }
                            
                            if let line = currentLine,
                               let endPoint = findNearestCircle(to: value.location),
                               let startPoint = self.startPoint {
                                
                                // Proveri ograničenje broja konekcija
                                if !wouldExceedConnectionLimit(start: startPoint, end: endPoint) {
                                    var points = line.points
                                    points.append(endPoint)
                                    lines.append(Line(points: points))
                                    
                                    // Ažuriraj broj konekcija
                                    updateConnections(start: startPoint, end: endPoint)
                                    
                                    // Ažuriraj animacije krugova
                                    updateCircleAnimations()
                                    canSelectNewPoint = true
                                }
                            }
                            
                            currentLine = nil
                            self.startPoint = nil
                        }
                )
                .simultaneousGesture(
                    SpatialTapGesture()
                        .onEnded { value in
                            let point = value.location
                            
                            if !gameStarted && pulsingCircles.count > 0 {
                                // Postavljanje crvenih tačaka pre početka igre
                                let index = pulsingCircles.first!
                                placedCircles.append(Circle2D(position: point))
                                pulsingCircles.remove(index)
                                if let indexToRemove = availableCircles.firstIndex(of: index) {
                                    availableCircles.remove(at: indexToRemove)
                                }
                            } else if gameStarted && pulsingCircles.count > 0 {
                                // Postavljanje plavih i zelenih tačaka tokom igre
                                let index = pulsingCircles.first!
                                
                                // Proveri da li je tačka na liniji
                                if isValidPointPlacement(at: point) {
                                    let initialConnections = countInitialConnections(at: point)
                                    
                                    if index < 7 {
                                        // Plava tačka
                                        var newCircle = blueCircles[index]
                                        newCircle.position = point
                                        newCircle.isPlaced = true
                                        newCircle.connections = initialConnections
                                        blueCircles[index] = newCircle
                                        canSelectNewPoint = false
                                    } else {
                                        // Zelena tačka
                                        let greenIndex = index - 7
                                        var newCircle = greenCircles[greenIndex]
                                        newCircle.position = point
                                        newCircle.isPlaced = true
                                        newCircle.connections = initialConnections
                                        greenCircles[greenIndex] = newCircle
                                        canSelectNewPoint = false
                                    }
                                    pulsingCircles.remove(index)
                                } else {
                                    showInvalidPlacementMessage = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showInvalidPlacementMessage = false
                                    }
                                }
                            }
                        }
                )
                .overlay(
                    showInvalidPlacementMessage ?
                    Text("Plava i zelena tačka moraju biti na liniji!")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                        .transition(.scale.combined(with: .opacity))
                    : nil
                )
                .animation(.easeInOut, value: showInvalidPlacementMessage)
                .onAppear {
                    canvasSize = geometry.size
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(radius: 2)
            )
            .padding()
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(Color(uiColor: .systemBackground))
    }
}

struct ContentView: View {
    @State private var showMainView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Button(action: {
                    showMainView = true
                }) {
                    Text("Go Dot...Go!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                                .shadow(radius: 5)
                        )
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $showMainView) {
                MainView()
            }
        }
    }
}

#Preview {
    ContentView()
}

