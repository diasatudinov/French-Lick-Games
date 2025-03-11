//
//  RunnerGameContainerView.swift
//  French Lick Games
//
//  Created by Dias Atudinov on 11.03.2025.
//


struct RunnerGameContainerView: View {
    var scene: SKScene {
        let scene = TrainingRunnerGameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
    }
}

struct RunnerGameContainerView_Previews: PreviewProvider {
    static var previews: some View {
        RunnerGameContainerView()
    }
}