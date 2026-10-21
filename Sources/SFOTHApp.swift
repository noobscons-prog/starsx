import SwiftUI

@main
struct SFOTHApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBarHidden(true) // Hides the iOS clock/battery bar for full immersion
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView: View {
    var body: some View {
        WebView(url: URL(string: "https://shedletsky.com/SFOTH/")!)
            .edgesIgnoringSafeArea(.all)
    }
}
