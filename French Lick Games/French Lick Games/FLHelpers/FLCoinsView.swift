import SwiftUI

struct FLCoinsView: View {
    @StateObject var user = FLUser.shared
    var body: some View {
        ZStack {
            Image(.coinsBgFL)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            
            Text("\(user.coins)")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .offset(x: 7)
        }
    }
}

#Preview {
    FLCoinsView()
}
