//
//  SplashScreen.swift
//  French Lick Games
//
//  Created by Dias Atudinov on 10.03.2025.
//


import SwiftUI

struct SplashScreen: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            
            
            VStack {
                Spacer()
                TextWithBorder(text: "LOADING...", font: .custom(Fonts.mazzardM.rawValue, size: 60), textColor: .mainYellow, borderColor: .mainBrown, borderWidth: 2)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(scale)
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: scale
                    )
                    .onAppear {
                        scale = 0.8
                    }
                Spacer()
            }
        }.background(
            Image(.background)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            
        )
    }
}

#Preview {
    SplashScreen()
}

struct TextWithBorder: View {
    let text: String
    let font: Font
    let textColor: Color
    let borderColor: Color
    let borderWidth: CGFloat

    var body: some View {
        ZStack {
            // Multiple layers of text for the border effect
//            ForEach([1, 1], id: \.self) { xOffset in
//                ForEach([1, 1], id: \.self) { yOffset in
//                    Text(text)
//                        .font(font)
//                        .foregroundColor(borderColor)
//                        .offset(x: CGFloat(xOffset) * borderWidth, y: CGFloat(yOffset) * borderWidth)
//                }
//            }
//            .offset(x: 1, y: 1)
//            // Main text layer
            Text(text)
                .font(font)
                .foregroundColor(textColor)
                .glowBorder(color: borderColor, lineWidth: 5)
            
            
        }
    }
}
   
    
//.offset(x: -2, y: 2)

struct GlowBorder: ViewModifier {
    var color: Color
    var lineWidth: Int
    func body(content: Content) -> some View {
        applyShadow(content: AnyView(content), lineWidth: lineWidth)
    }
    
    func applyShadow(content: AnyView, lineWidth: Int) -> AnyView {
        if lineWidth == 0 {
            return content
        } else {
            return applyShadow(content: AnyView(content.shadow(color: color, radius: 1)), lineWidth: lineWidth - 1)
        }
    }
}

extension View {
    func glowBorder(color: Color, lineWidth: Int) -> some View {
        self.modifier(GlowBorder(color: color, lineWidth: lineWidth))
    }
}