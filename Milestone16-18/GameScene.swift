//
//  GameScene.swift
//  Milestone16-18
//
//  Created by Максим Зыкин on 12.09.2023.
//

import SpriteKit

class GameScene: SKScene {
    var rows = [ShootingRow]()
    
    var gameTimer: Timer?
    
    var popupTime = 0.85
    
    var timerLabel: SKLabelNode!
    var secondsRemaining = 60 {
        didSet {
            timerLabel.text = "\(secondsRemaining) seconds remaining"
        }
    }
    
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var reloadButton: SKLabelNode!
    
    var bulletsLabel: SKLabelNode!
    var bullets = 6 {
        didSet {
            bulletsLabel.text = "\(bullets) bullets left"
        }
    }
    
    override func didMove(to view: SKView) {
        let safeHeight: Double = view.scene!.size.height - (view.scene!.size.height / 5)
        let safeArea = view.scene!.size.height / 10
        
        backgroundColor = .gray
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.position = CGPoint(x: 8, y: view.scene!.size.height - 32)
        gameScore.horizontalAlignmentMode = .left
        addChild(gameScore)
        
        score = 0

        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.position = CGPoint(x: view.scene!.size.width / 2, y: view.scene!.size.height - 32)
        addChild(timerLabel)

        secondsRemaining = 60
        
        bulletsLabel = SKLabelNode(fontNamed: "Chalkduster")
        bulletsLabel.position = CGPoint(x: 8, y: 8)
        bulletsLabel.horizontalAlignmentMode = .left
        addChild(bulletsLabel)
        
        bullets = 6
        
        reloadButton = SKLabelNode(fontNamed: "Chalkduster")
        reloadButton.position = CGPoint(x: 700, y: 8)
        reloadButton.text = "Reload"
        reloadButton.name = "reload"
        addChild(reloadButton)
        
        for i in 0...2 {
            createRow(at: safeArea + (safeHeight / 3 * Double(i)), to: i % 2 == 1 ? .left : .right)
        }
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.secondsRemaining -= 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createTarget()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if let row = node.parent?.parent as? ShootingRow {
                guard bullets > 0 else { return }
                
                if node.name == "bigTarget" {
                    score += 5
                } else if node.name == "smallTarget" {
                    score += 10
                } else if node.name == "bad" {
                    score -= 10
                }
                
                bullets -= 1
                row.hide(node)
            } else if node.name == "reload" {
                bullets = 6
            }
        }
    }
    
    func createRow(at height: CGFloat, to direction: Direction) {
        let row = ShootingRow()
        row.configure(at: height, to: direction)
        addChild(row)
        rows.append(row)
    }
    
    func createTarget() {
        if secondsRemaining == 0 {
            gameTimer?.invalidate()
            
            for row in rows {
                for target in row.targets {
                    row.hide(target.spriteNode)
                }
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = view?.center ?? CGPoint(x: 590, y: 410)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            gameScore.text = "You have scored \(score) points"
            gameScore.position = CGPoint(x: view?.center.x ?? 590, y: (view?.center.y ?? 410) - gameOver.size.height - 10)
            gameScore.zPosition = 1
            gameScore.horizontalAlignmentMode = .center
            
            run(SKAction.playSoundFileNamed("gameOver.mp3", waitForCompletion: false))
            
            return
        }
        
        popupTime *= 0.991
        rows.shuffle()
        rows[0].createTarget(runTime: popupTime)

        if Int.random(in: 0...12) > 8 { rows[1].createTarget(runTime: popupTime) }
        if Int.random(in: 0...12) > 10 { rows[2].createTarget(runTime: popupTime) }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createTarget()
        }
    }
}
