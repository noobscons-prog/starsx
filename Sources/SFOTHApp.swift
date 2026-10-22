import SwiftUI

@main
struct SFOTHApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBarHidden(true)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView: View {
    @StateObject private var webModel = WebViewModel()
    @State private var isHackActive = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            WebView(model: webModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Button(action: {
                    isHackActive.toggle()
                    webModel.toggleHack(isHackActive)
                }) {
                    Text(isHackActive ? "Bounce: ON" : "Bounce: OFF")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(isHackActive ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .padding(.top, 50)
                .padding(.trailing, 20)
                
                Spacer()
            }
        }
    }
}
