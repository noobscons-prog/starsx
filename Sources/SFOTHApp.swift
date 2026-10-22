import SwiftUI

@main
struct SFOTHApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBarHidden(true)
                .ignoresSafeArea(.all) // Forces full screen
        }
    }
}

struct ContentView: View {
    @StateObject private var webModel = WebViewModel()
    @State private var isHackActive = false
    
    @State private var position = CGPoint(x: 320, y: 120)
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        ZStack {
            // Force the WebView to stretch to the absolute edges
            WebView(model: webModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
            
            Button(action: {
                if dragOffset == .zero {
                    isHackActive.toggle()
                    webModel.toggleHack(isHackActive)
                }
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
            .position(x: position.x + dragOffset.width, y: position.y + dragOffset.height)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        position.x += value.translation.width
                        position.y += value.translation.height
                    }
            )
        }
    }
}
