import SwiftUI
import WatchKit

struct TestView: View {
    var body: some View {
        VStack {
            Text("Hello")
        }
        .onTapGesture(coordinateSpace: .local) { location in
            print(location)
        }
    }
}
