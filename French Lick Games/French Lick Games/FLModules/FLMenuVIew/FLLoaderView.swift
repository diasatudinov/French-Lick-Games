import SwiftUI

struct FLLoaderView: View {
    @State private var progress: Double = 0.0
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        TextWithBorder(text: "loading...", font: .custom(FLFonts.regular.rawValue, size: 40), textColor: .milk, borderColor: .black, borderWidth: 1)
                            .textCase(.uppercase)
                        Spacer()
                    }
                    .foregroundColor(.black)
                    .padding(.bottom, 25)
                }
                
            }.background(
                Image(.bgFL)
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                
                
            )
            .onAppear {
                startTimer()
            }
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        progress = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { timer in
            if progress < 100 {
                progress += 1
            } else {
                timer.invalidate()
            }
        }
    }
}


#Preview {
    FLLoaderView()
}
