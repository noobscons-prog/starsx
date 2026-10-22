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
    
    // State variables for dragging the button
    @State private var dragAmount = CGSize.zero
    @State private var position = CGSize(width: 300, height: -350) 
    
    var body: some View {
        ZStack {
            // The Game WebView
            WebView(model: webModel)
                .edgesIgnoringSafeArea(.all)
            
            // The Draggable Floating Button
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
            // Apply the drag offset
            .offset(x: position.width + dragAmount.width, y: position.height + dragAmount.height)
            // Add the drag gesture
            .gesture(
                DragGesture(minimumDistance: 10) // 10 points prevents accidental drags when tapping
                    .onChanged { value in
                        dragAmount = value.translation
                    }
                    .onEnded { value in
                        // Save the new position when the drag ends
                        position.width += dragAmount.width
                        position.height += dragAmount.height
                        dragAmount = .zero
                    }
            )
        }
    }
}
