//
//  ContentView.swift
//  GoDotGo
//
//  Created by Gazza on 9. 4. 2025..
//

import SwiftUI

struct Circle2D {
    var position: CGPoint
    var isAnimating: Bool = true
    var color: Color = .red
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
    
    private var canStartGame: Bool {
        placedCircles.count >= 3
    }
    
    private func createGameCircles(in size: CGSize) -> (blue: [Circle2D], green: [Circle2D]) {
        let spacing: CGFloat = size.width / 8 // 7 circles + spacing
        let startX: CGFloat = spacing
        let blueY: CGFloat = size.height / 3
        let greenY: CGFloat = 2 * size.height / 3
        
        let blue = (0..<7).map { index in
            Circle2D(position: CGPoint(x: startX + spacing * CGFloat(index), y: blueY), color: .blue)
        }
        
        let green = (0..<7).map { index in
            Circle2D(position: CGPoint(x: startX + spacing * CGFloat(index), y: greenY), color: .green)
        }
        
        return (blue, green)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 40) {
                Spacer()
                
                Button(action: {
                    lines = []
                    currentLine = nil
                    // Reset circles
                    placedCircles = []
                    availableCircles = Array(0..<7)
                    pulsingCircles = []
                    gameStarted = false
                    blueCircles = []
                    greenCircles = []
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
                                                pulsingCircles.insert(index)
                                            }
                                        }
                                } else {
                                    Color.clear
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                    } else {
                        HStack(spacing: 15) {
                            ForEach(0..<7, id: \.self) { _ in
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                        HStack(spacing: 15) {
                            ForEach(0..<7, id: \.self) { _ in
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 20, height: 20)
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
            
            Canvas { context, size in
                canvasSize = size
                let strokeStyle = StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                
                // Draw lines
                for line in lines {
                    var path = Path()
                    if let firstPoint = line.points.first {
                        path.move(to: firstPoint)
                        for point in line.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    context.stroke(path, with: .color(line.color), style: strokeStyle)
                }
                
                if let currentLine = currentLine {
                    var path = Path()
                    if let firstPoint = currentLine.points.first {
                        path.move(to: firstPoint)
                        for point in currentLine.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    context.stroke(path, with: .color(currentLine.color), style: strokeStyle)
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
                        let point = value.location
                        if currentLine == nil {
                            currentLine = Line(points: [point])
                        } else {
                            if let lastPoint = currentLine?.points.last,
                               hypot(point.x - lastPoint.x, point.y - lastPoint.y) > 1 {
                                currentLine?.points.append(point)
                            }
                        }
                    }
                    .onEnded { _ in
                        if let line = currentLine {
                            lines.append(line)
                            currentLine = nil
                        }
                    }
            )
            .simultaneousGesture(
                SpatialTapGesture()
                    .onEnded { value in
                        guard pulsingCircles.count > 0 else { return }
                        let index = pulsingCircles.first!
                        placedCircles.append(Circle2D(position: value.location))
                        pulsingCircles.remove(index)
                        if let indexToRemove = availableCircles.firstIndex(of: index) {
                            availableCircles.remove(at: indexToRemove)
                        }
                    }
            )
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded { value in
                        guard pulsingCircles.count > 0 else { return }
                        let index = pulsingCircles.first!
                        placedCircles.append(Circle2D(position: value.location))
                        pulsingCircles.remove(index)
                        if let indexToRemove = availableCircles.firstIndex(of: index) {
                            availableCircles.remove(at: indexToRemove)
                        }
                    }
            )
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
