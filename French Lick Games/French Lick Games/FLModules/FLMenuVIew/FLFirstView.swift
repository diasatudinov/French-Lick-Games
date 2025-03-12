import SwiftUI

struct FLFirstView: View {
    @State private var isLoading = true
    @State var toUp: Bool = true
    @AppStorage("vers") var verse: Int = 0
    
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    var body: some View {
        ZStack {
            if verse == 1 {
                WVWrap(urlString: AppLinks.winStarData)
            } else {
                VStack {
                    if isLoading {
                        FLLoaderView()
                            .onAppear {
                                startTimer()
                            }
                    } else {
                        FLMainMenuView()
                            .onAppear {
                                AppDelegate.orientationLock = .landscape
                                setOrientation(.landscapeRight)
                            }
                            .onDisappear {
                                AppDelegate.orientationLock = .all
                            }
                            
                    }
                }
            }
        }
        .onAppear {
            updateIfNeeded()
        }
    }
    
    func updateIfNeeded() {
        if AppLinks.shared.finalURL == nil {
            Task {
                if await !ProcessingData.checking() {
                    verse = 1
                    toUp = false
                    
                } else {
                    verse = 0
                    toUp = true
                }
            }
        } else {
            isLoading = false
        }
        
        
    }
    
    func setOrientation(_ orientation: UIInterfaceOrientation) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let selector = NSSelectorFromString("setInterfaceOrientation:")
            if let responder = windowScene.value(forKey: "keyWindow") as? UIResponder, responder.responds(to: selector) {
                responder.perform(selector, with: orientation.rawValue)
            }
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { timer in
            if progress < 1 {
                progress += 0.01
            } else {
                isLoading = false
                timer.invalidate()
            }
        }
    }
}

#Preview {
    FLFirstView()
}
