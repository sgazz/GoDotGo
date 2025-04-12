import SwiftUI

struct GameBoard: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pozadina sa zvezdama
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .nightSkyTheme()
                
                // Canvas za crtanje
                Canvas { context, size in
                    let strokeStyle = StrokeStyle(
                        lineWidth: NightSkyTheme.Dimensions.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                    
                    // Crtaj završene linije sa glow efektom
                    for line in viewModel.lines {
                        var path = Path()
                        if let firstPoint = line.points.first {
                            path.move(to: firstPoint)
                            for point in line.points.dropFirst() {
                                path.addLine(to: point)
                            }
                            // Prvo nacrtaj liniju sa većom širinom za glow efekat
                            context.stroke(path, with: .color(line.color.opacity(0.3)),
                                         style: StrokeStyle(lineWidth: NightSkyTheme.Dimensions.lineWidth * 3))
                            // Zatim nacrtaj glavnu liniju
                            context.stroke(path, with: .color(line.color),
                                         style: strokeStyle)
                        }
                    }
                    
                    // Crtaj trenutnu liniju
                    if let currentLine = viewModel.currentLine {
                        var path = Path()
                        if let firstPoint = currentLine.points.first {
                            path.move(to: firstPoint)
                            for point in currentLine.points.dropFirst() {
                                path.addLine(to: point)
                            }
                            // Glow efekat za trenutnu liniju
                            context.stroke(path, with: .color(currentLine.color.opacity(0.3)),
                                         style: StrokeStyle(lineWidth: NightSkyTheme.Dimensions.lineWidth * 3))
                            context.stroke(path, with: .color(currentLine.color),
                                         style: strokeStyle)
                        }
                    }
                    
                    // Crtaj postavljene crvene krugove sa glow efektom
                    for circle in viewModel.placedCircles {
                        // Glow efekat
                        let glowPath = Path(ellipseIn: CGRect(
                            x: circle.position.x - NightSkyTheme.Dimensions.dotSize/2 - 2,
                            y: circle.position.y - NightSkyTheme.Dimensions.dotSize/2 - 2,
                            width: NightSkyTheme.Dimensions.dotSize + 4,
                            height: NightSkyTheme.Dimensions.dotSize + 4
                        ))
                        context.fill(glowPath, with: .color(NightSkyTheme.redDotColor.opacity(0.3)))
                        
                        // Glavni krug
                        let circlePath = Path(ellipseIn: CGRect(
                            x: circle.position.x - NightSkyTheme.Dimensions.dotSize/2,
                            y: circle.position.y - NightSkyTheme.Dimensions.dotSize/2,
                            width: NightSkyTheme.Dimensions.dotSize,
                            height: NightSkyTheme.Dimensions.dotSize
                        ))
                        context.fill(circlePath, with: .color(NightSkyTheme.redDotColor))
                    }
                    
                    if viewModel.gameStarted {
                        // Crtaj postavljene plave krugove sa glow efektom
                        for circle in viewModel.blueCircles where circle.isPlaced {
                            // Glow efekat
                            let glowPath = Path(ellipseIn: CGRect(
                                x: circle.position.x - NightSkyTheme.Dimensions.dotSize/2 - 2,
                                y: circle.position.y - NightSkyTheme.Dimensions.dotSize/2 - 2,
                                width: NightSkyTheme.Dimensions.dotSize + 4,
                                height: NightSkyTheme.Dimensions.dotSize + 4
                            ))
                            context.fill(glowPath, with: .color(NightSkyTheme.blueDotColor.opacity(0.3)))
                            
                            // Glavni krug
                            let circlePath = Path(ellipseIn: CGRect(
                                x: circle.position.x - NightSkyTheme.Dimensions.dotSize/2,
                                y: circle.position.y - NightSkyTheme.Dimensions.dotSize/2,
                                width: NightSkyTheme.Dimensions.dotSize,
                                height: NightSkyTheme.Dimensions.dotSize
                            ))
                            context.fill(circlePath, with: .color(NightSkyTheme.blueDotColor))
                        }
                        
                        // Crtaj postavljene zelene krugove sa glow efektom
                        for circle in viewModel.greenCircles where circle.isPlaced {
                            // Glow efekat
                            let glowPath = Path(ellipseIn: CGRect(
                                x: circle.position.x - NightSkyTheme.Dimensions.dotSize/2 - 2,
                                y: circle.position.y - NightSkyTheme.Dimensions.dotSize/2 - 2,
                                width: NightSkyTheme.Dimensions.dotSize + 4,
                                height: NightSkyTheme.Dimensions.dotSize + 4
                            ))
                            context.fill(glowPath, with: .color(NightSkyTheme.greenDotColor.opacity(0.3)))
                            
                            // Glavni krug
                            let circlePath = Path(ellipseIn: CGRect(
                                x: circle.position.x - NightSkyTheme.Dimensions.dotSize/2,
                                y: circle.position.y - NightSkyTheme.Dimensions.dotSize/2,
                                width: NightSkyTheme.Dimensions.dotSize,
                                height: NightSkyTheme.Dimensions.dotSize
                            ))
                            context.fill(circlePath, with: .color(NightSkyTheme.greenDotColor))
                        }
                    }
                }
                .allowsHitTesting(true)
                .gesture(
                    SpatialTapGesture()
                        .onEnded { value in
                            if viewModel.pulsingCircles.count > 0 {
                                viewModel.placeCircle(at: value.location, index: viewModel.pulsingCircles.first!)
                            }
                        }
                )
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            viewModel.handleDragGesture(value: value)
                        }
                        .onEnded { value in
                            viewModel.handleDragGestureEnd(value: value)
                        }
                )
            }
            .overlay(
                viewModel.showInvalidPlacementMessage ?
                Text("Plava i zelena tačka moraju biti na liniji!")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(10)
                    .transition(.scale.combined(with: .opacity))
                    .glow(color: .red)
                : nil
            )
            .animation(.easeInOut, value: viewModel.showInvalidPlacementMessage)
            .onAppear {
                viewModel.canvasSize = geometry.size
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
} 