//
//  ContentView.swift
//  GoDotGo
//
//  Created by Gazza on 9. 4. 2025..
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            GameControls(viewModel: viewModel)
            GameBoard(viewModel: viewModel)
        }
        .toolbar(.hidden, for: .navigationBar)
        .nightSkyTheme()
    }
}

struct ContentView: View {
    @State private var showMainView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Pozadina sa zvezdama
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .nightSkyTheme()
                    .ignoresSafeArea()
                
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
                                    .fill(NightSkyTheme.blueDotColor)
                                    .shadow(radius: 5)
                            )
                            .glow(color: NightSkyTheme.blueDotColor)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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

