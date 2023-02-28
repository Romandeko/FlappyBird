//
//  GameScene.swift
//  FlappyBird
//
//  Created by Роман Денисенко on 22.12.22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: - Stored properties
    var record : Int{
        get{
            UserDefaults.standard.integer(forKey: "Record")
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "Record")
        }
        
    }
    
    //MARK: - UI properties
    private lazy var bird = {
        let node = SKSpriteNode(imageNamed: "bird2")
        node.name = "Bird"
        node.size = CGSize(width: 100, height: 80)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.position = CGPoint(x: size.width/20 - 70, y: size.height/12 - 20)
        node.zPosition = 10
        return node
    }()
    
    private lazy var background = {
        let node = SKSpriteNode(imageNamed: "background-day")
        node.zPosition = -100
        node.position = CGPoint.zero
        node.size = CGSize(width: size.width, height: size.height)
        return node
    }()
    
    private lazy var getReady = {
        let node = SKSpriteNode(imageNamed: "getReady")
        node.zPosition = 1
        node.position = CGPoint(x: 0, y: 300)
        node.size = CGSize(width: 300, height: 100)
        return node
    }()
    
    private lazy var scoreLabel = {
        let node = SKLabelNode(fontNamed: "Chalkduster")
        node.zPosition = 2
        node.text = "0"
        node.fontSize = 65
        node.fontColor = SKColor.white
        node.zPosition = 50
        node.position = CGPoint(x: size.width/3, y: size.height/2.5)
        return node
    }()
    
    //MARK: - Private properties
    private var birdAnimation = [SKTexture]()
    private var upRotate = SKAction()
    private var downRotate = SKAction()
    private var oldY : CGFloat = 0
    private var jump : CGFloat = 115
    private var score = 0
    private var time = 0
    private var step : CGFloat = 6
    private var pipesCount = 4
    private var xCoordinate : CGFloat = 400
    private var yCoordinateBot : CGFloat = -450
    private var yCoordinateTop : CGFloat = 700
    private var gameEnded = false
    private var gameStarted = false
    private var isTimerStarted = false
    private var currentPipesNumber = 0
    private var previousPipesNumber = -6
    private var spawnTime = 7
    private let wingSound = SKAction.playSoundFileNamed("wing", waitForCompletion: false)
    private let hitSound = SKAction.playSoundFileNamed("hit", waitForCompletion: false)
    private let pointSound = SKAction.playSoundFileNamed("point", waitForCompletion: false)
    
    
    
    //MARK: - Override methods
    override func didMove(to view: SKView) {
        addEverything()
        createGrounds()
        
        createAnimation()
        createPipes(withName: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameStarted{
            movePipes(withname: currentPipesNumber)
            movePipes(withname: previousPipesNumber)
            movePipes(withname: currentPipesNumber - spawnTime * 2)
            rotateBird()
            
            if !isTimerStarted{
                run(SKAction.repeatForever(SKAction.sequence([SKAction.run(timerCount),SKAction.wait(forDuration: 1)])))
                isTimerStarted.toggle()
            }
            
            self.enumerateChildNodes(withName: "Pipe\(currentPipesNumber)", using:({
                (node,error) in
                
                if self.bird.position.x - node.position.x > 2 && self.bird.position.x - node.position.x < 8 {
                    self.score += 1
                    self.scoreLabel.text = String(self.score)
                    self.run(self.pointSound)
                }
                
            }))
            
            self.enumerateChildNodes(withName: "Pipe\(previousPipesNumber)", using:({
                (node,error) in
                
                if self.bird.position.x - node.position.x > 2 && self.bird.position.x - node.position.x < 8 {
                    self.score += 1
                    self.scoreLabel.text = String(self.score)
                    self.run(self.pointSound)
                }
            }))
        }
        moveGrounds()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted{
            bird.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bird.frame.width, height: bird.frame.height))
            bird.physicsBody?.mass = 0.130
            bird.physicsBody?.contactTestBitMask = 1
            getReady.isHidden = true
            gameStarted.toggle()
        }
        
        if !gameEnded{
            oldY = bird.position.y + jump
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jump))
            upRotate = SKAction.rotate(toAngle: (.pi / 5), duration: 0.25)
            bird.run(upRotate, withKey: "up")
            bird.removeAction(forKey: "down")
            run(wingSound)
        }
    }
    //MARK: - Create  sprites
    private func addEverything(){
        addChild(scoreLabel)
        addChild(background)
        addChild(getReady)
        addChild(bird)
        physicsWorld.contactDelegate = self
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    private func createGrounds(){
        for i in 0...3{
            let ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.size = CGSize(width: self.scene?.size.width ?? 0, height: 250)
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: -(self.frame.size.height/2))
            ground.zPosition = 15
            ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: ground.frame.width, height: ground.frame.height))
            ground.physicsBody?.isDynamic = false
            ground.physicsBody?.allowsRotation = false
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.contactTestBitMask = 1
            self.addChild(ground)
        }
    }
    
    private func makePipe(withName name: Int, step stepY: CGFloat, isReversed: Bool = false) -> SKSpriteNode {
        let imageName = isReversed ? "piperev" : "pipe"
        let pipe = SKSpriteNode(imageNamed: imageName)
        
        pipe.name = isReversed
        ? "PipeRev\(name)"
        : "Pipe\(name)"
        pipe.size = CGSize(width: 200, height: 800)
        pipe.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pipe.position = isReversed
        ? CGPoint(x: xCoordinate + 500, y:yCoordinateTop + stepY)
        : CGPoint(x: xCoordinate + 500, y:yCoordinateBot + stepY)
        pipe.zPosition = 14
        pipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 800))
        pipe.physicsBody?.isDynamic = false
        pipe.physicsBody?.allowsRotation = false
        pipe.physicsBody?.affectedByGravity = false
        pipe.physicsBody?.contactTestBitMask = 1
        return pipe
    }
    
    private func createPipes(withName name: Int){
        
        for _ in 0...pipesCount{
            let randomStepY = CGFloat.random(in: 0...300)
            
            let pipe = makePipe(withName: name, step: randomStepY)
            let pipeRev = makePipe(withName: name, step: randomStepY, isReversed: true)
            
            self.addChild(pipe)
            self.addChild(pipeRev)
            
            xCoordinate = pipeRev.position.x
        }
        xCoordinate = 700
    }
    
    private func createBird(){
        self.addChild(bird)
    }
    
    //MARK: - Animations
    private func moveGrounds(){
        if !gameEnded{
            self.enumerateChildNodes(withName: "Ground", using:({
                (node,error) in
                
                node.position.x -= self.step
                if node.position.x < -((self.scene?.size.width) ?? 0) {
                    node.position.x += ((self.scene?.size.width) ?? 0) * 3
                }
                
            }))
            
        }
    }
    
    private func movePipes(withname name: Int){
        self.enumerateChildNodes(withName: "Pipe\(name)", using:({
            (node,error) in
            node.position.x -= self.step
        }))
        
        self.enumerateChildNodes(withName: "PipeRev\(name)", using:({
            (node,error) in
            node.position.x -= self.step
            
        }))
    }
    
    private func createAnimation(){
        let textureAtlas = SKTextureAtlas(named: "Sprites")
        for i in 1..<textureAtlas.textureNames.count{
            let name = "bird"  + String(i)
            birdAnimation.append(textureAtlas.textureNamed(name))
        }
        
        bird.run(SKAction.repeatForever(SKAction.animate(with: birdAnimation, timePerFrame: 0.15)))
        
    }
    
    private func rotateBird(){
        let newY = bird.position.y
        if newY - oldY > 5{
            downRotate = SKAction.rotate(toAngle: -(.pi / 2), duration: 0.7)
            bird.run(downRotate, withKey: "down")
            bird.removeAction(forKey: "up")
            oldY = newY
        }
    }
    
    private func stopGame(){
        if score > record{
            record = score
        }
        
        bird.removeAllActions()
        downRotate = SKAction.rotate(toAngle: -(.pi / 2), duration: 0.2)
        bird.run(downRotate)
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.5){ [self] in
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: size,score : score,record: record)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    //MARK: - Timer
    private func timerCount(){
        time += 1
        if time % spawnTime == 0{
            createPipes(withName: time)
            currentPipesNumber = time
            previousPipesNumber = time - spawnTime
        }
        
        if time % 11 == 0{
            self.enumerateChildNodes(withName: "Pipe\(currentPipesNumber - spawnTime * 2)", using:({
                (node,error) in
                node.removeFromParent()
            }))
            
            self.enumerateChildNodes(withName: "PipeRev\(currentPipesNumber - spawnTime * 2)", using:({
                (node,error) in
                node.removeFromParent()
            }))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        if !gameEnded{
            run(hitSound)
            stopGame()
            gameEnded = true
        }
    }
}

