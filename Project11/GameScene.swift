//
//  GameScene.swift
//  Project11
//
//  Created by Olha Pylypiv on 13.03.2024.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    var ballsLabel: SKLabelNode!
    var ballsCreated = 0 {
        didSet {
            ballsLabel.text = "Balls: \(5 - ballsCreated)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 650)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 650)
        addChild(editLabel)
        
        ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLabel.text = "Balls: 5"
        ballsLabel.position = CGPoint(x: 512, y: 650)
        addChild(ballsLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlots(at: CGPoint(x: 128, y: 50), isGood: true)
        makeSlots(at: CGPoint(x: 384, y: 50), isGood: false)
        makeSlots(at: CGPoint(x: 640, y: 50), isGood: true)
        makeSlots(at: CGPoint(x: 896, y: 50), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 50))
        makeBouncer(at: CGPoint(x: 256, y: 50))
        makeBouncer(at: CGPoint(x: 512, y: 50))
        makeBouncer(at: CGPoint(x: 768, y: 50))
        makeBouncer(at: CGPoint(x: 1024, y: 50))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let objects = nodes(at: location)
            if objects.contains(editLabel) {
                editingMode.toggle()
            } else {
                if editingMode {
                    //create a box
                    let size = CGSize(width: CGFloat.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    box.name = "box"
                    
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    
                    addChild(box)
                } else {
                    if ballsCreated < 5{
                        let ballRed = SKSpriteNode(imageNamed: "ballRed")
                        let ballBlue = SKSpriteNode(imageNamed: "ballBlue")
                        let ballCyan = SKSpriteNode(imageNamed: "ballCyan")
                        let ballGreen = SKSpriteNode(imageNamed: "ballGreen")
                        let ballGrey = SKSpriteNode(imageNamed: "ballGrey")
                        let ballPurple = SKSpriteNode(imageNamed: "ballPurple")
                        let ballYellow = SKSpriteNode(imageNamed: "ballYellow")
                        
                        let coloredBalls = [ballRed, ballBlue, ballCyan, ballGreen, ballGrey, ballPurple, ballYellow]
                        
                        let ball = coloredBalls[Int.random(in: 0...6)]
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                        ball.physicsBody?.restitution = 0.4
                        
                        ball.position.x = location.x
                        ball.position.y = 650
                        
                        ball.name = "ball"
                        addChild(ball)
                        ballsCreated += 1
                    }
                }
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlots(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballsCreated -= 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        } else if object.name == "box" {
            object.removeFromParent()
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
}
