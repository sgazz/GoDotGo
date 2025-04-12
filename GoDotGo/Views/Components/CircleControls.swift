import SwiftUI

struct CircleControls: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            if !viewModel.gameStarted {
                // Prikaz crvenih tačaka pre starta igre
                HStack(spacing: 15) {
                    ForEach(0..<7, id: \.self) { index in
                        if viewModel.availableCircles.contains(index) {
                            Circle()
                                .fill(NightSkyTheme.redDotColor)
                                .frame(width: NightSkyTheme.Dimensions.dotSize,
                                       height: NightSkyTheme.Dimensions.dotSize)
                                .scaleEffect(viewModel.pulsingCircles.contains(index) ? 1.3 : 1.0)
                                .animation(NightSkyTheme.Animation.dotPulse,
                                         value: viewModel.pulsingCircles.contains(index))
                                .glow(color: NightSkyTheme.redDotColor)
                                .onTapGesture {
                                    if viewModel.pulsingCircles.contains(index) {
                                        viewModel.pulsingCircles.remove(index)
                                    } else {
                                        viewModel.pulsingCircles = [index]
                                    }
                                }
                        } else {
                            Color.clear
                                .frame(width: NightSkyTheme.Dimensions.dotSize,
                                       height: NightSkyTheme.Dimensions.dotSize)
                        }
                    }
                }
            } else {
                // Prikaz plavih tačaka
                HStack(spacing: 15) {
                    ForEach(0..<7, id: \.self) { index in
                        if !viewModel.blueCircles[index].isPlaced {
                            Circle()
                                .fill(NightSkyTheme.blueDotColor)
                                .frame(width: NightSkyTheme.Dimensions.dotSize,
                                       height: NightSkyTheme.Dimensions.dotSize)
                                .scaleEffect(viewModel.pulsingCircles.contains(index) ? 1.3 : 1.0)
                                .animation(NightSkyTheme.Animation.dotPulse,
                                         value: viewModel.pulsingCircles.contains(index))
                                .glow(color: NightSkyTheme.blueDotColor)
                                .onTapGesture {
                                    if viewModel.pulsingCircles.contains(index) {
                                        viewModel.pulsingCircles.remove(index)
                                    } else {
                                        viewModel.pulsingCircles = [index]
                                    }
                                }
                        } else {
                            Color.clear
                                .frame(width: NightSkyTheme.Dimensions.dotSize,
                                       height: NightSkyTheme.Dimensions.dotSize)
                        }
                    }
                }
                
                // Prikaz zelenih tačaka
                HStack(spacing: 15) {
                    ForEach(0..<7, id: \.self) { index in
                        if !viewModel.greenCircles[index].isPlaced {
                            Circle()
                                .fill(NightSkyTheme.greenDotColor)
                                .frame(width: NightSkyTheme.Dimensions.dotSize,
                                       height: NightSkyTheme.Dimensions.dotSize)
                                .scaleEffect(viewModel.pulsingCircles.contains(index + 7) ? 1.3 : 1.0)
                                .animation(NightSkyTheme.Animation.dotPulse,
                                         value: viewModel.pulsingCircles.contains(index + 7))
                                .glow(color: NightSkyTheme.greenDotColor)
                                .onTapGesture {
                                    if viewModel.pulsingCircles.contains(index + 7) {
                                        viewModel.pulsingCircles.remove(index + 7)
                                    } else {
                                        viewModel.pulsingCircles = [index + 7]
                                    }
                                }
                        } else {
                            Color.clear
                                .frame(width: NightSkyTheme.Dimensions.dotSize,
                                       height: NightSkyTheme.Dimensions.dotSize)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 200)
    }
} 