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
    var body: some View {
        WebView(url: URL(string: "https://shedletsky.com/SFOTH/")!)
            .edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Forces full screen
    }
}
