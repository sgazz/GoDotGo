import SwiftUI

struct GameControls: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        HStack(spacing: 40) {
            Spacer()
            
            Button(action: {
                viewModel.resetGame()
            }) {
                Text("New Game")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 180, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(NightSkyTheme.blueDotColor)
                    )
                    .glow(color: NightSkyTheme.blueDotColor)
            }
            
            CircleControls(viewModel: viewModel)
            
            Button(action: {
                viewModel.startGame()
            }) {
                Text("Start Game")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 180, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(viewModel.canStartGame ? NightSkyTheme.greenDotColor : NightSkyTheme.greenDotColor.opacity(0.5))
                    )
                    .glow(color: viewModel.canStartGame ? NightSkyTheme.greenDotColor : NightSkyTheme.greenDotColor.opacity(0.3))
            }
            .disabled(!viewModel.canStartGame)
            
            Spacer()
        }
        .padding(.top, 50)
        .padding(.bottom, 20)
    }
} 