
import Foundation
import SpriteKit


import Foundation
import SpriteKit

class GameOverScene: SKScene {
    init(size: CGSize,score : Int,record : Int) {
        super.init(size: size)
        
        let background = SKSpriteNode(imageNamed: "background-day")
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = 1
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        
        
        let scoreLabel = SKLabelNode(fontNamed: "Rockwell")
        scoreLabel.text = " You got \(score) points"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = SKColor.black
        scoreLabel.zPosition = 2
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 40)
        addChild(scoreLabel)
        
        
        let recordLabel = SKLabelNode(fontNamed: "Rockwell")
        recordLabel.text = "Record : \(record) points"
        recordLabel.fontSize = 40
        recordLabel.fontColor = SKColor.black
        recordLabel.zPosition = 2
        recordLabel.horizontalAlignmentMode = .center
        recordLabel.position = CGPoint(x: size.width/2 , y: size.height/2 - 60)
        addChild(recordLabel)
        
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() { [weak self] in
                guard let `self` = self else { return }
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
        ]))
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
