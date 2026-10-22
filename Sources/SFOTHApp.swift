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
    
    // 1. The saved position of the button
    @State private var position = CGPoint(x: 320, y: 120)
    
    // 2. The LIVE drag offset (resets to 0 automatically when you lift your finger)
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        ZStack {
            // The Game WebView
            WebView(model: webModel)
                .edgesIgnoringSafeArea(.all)
            
            // The Draggable Floating Button
            Button(action: {
                // Only toggle if it wasn't a drag
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
            // Apply the saved position + the live offset
            .position(x: position.x + dragOffset.width, y: position.y + dragOffset.height)
            
            .gesture(
                DragGesture(minimumDistance: 0) // 0 makes it instantly responsive
                    .updating($dragOffset) { value, state, _ in
                        // This updates 60-120 times a second for perfectly smooth dragging
                        state = value.translation
                    }
                    .onEnded { value in
                        // Save the final resting place when you let go
                        position.x += value.translation.width
                        position.y += value.translation.height
                    }
            )
        }
    }
}
