import SwiftUI
#if os(watchOS)
import WatchKit
#endif
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
