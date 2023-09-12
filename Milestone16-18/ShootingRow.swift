//
//  ShootingRow.swift
//  Milestone16-18
//
//  Created by Максим Зыкин on 12.09.2023.
//

import SpriteKit
import UIKit

enum Direction {
    case left
    case right
}

enum SizeSpeed {
    case bigSlow
    case smallFast
}

struct Target {
    let spriteNode: SKSpriteNode
    let sizeSpeed: SizeSpeed
    let bad: Bool
}

class ShootingRow: SKNode {
    var cropNode: SKCropNode!
    var targets = [Target]()
    
    var direction: Direction = .left
    var start: CGFloat {
        switch direction {
        case .left:
            return 525
        case .right:
            return -525
        }
    }
    var finish: CGFloat {
        switch direction {
        case .left:
            return -1050
        case .right:
            return 1050
        }
    }
    
    func configure(at height: CGFloat, to direction: Direction) {
        self.position.x = 1133 / 2
        self.position.y = height
        self.zPosition = 1
        
        self.direction = direction
        
        let row = SKSpriteNode(color: .brown, size: CGSize(width: 1133, height: 20))
        addChild(row)
        
        cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 110)
        cropNode.zPosition = 0.5
        cropNode.maskNode = SKSpriteNode(color: .black, size: CGSize(width: 1133, height: 200))
        
        addChild(cropNode)
    }
    
    func createTarget(runTime: Double) {
        let sizeSpeed: SizeSpeed = Int.random(in: 0...2) % 2 == 0 ? .bigSlow : .smallFast
        
        let target = Target(
            spriteNode: SKSpriteNode(imageNamed: "target"),
            sizeSpeed: sizeSpeed,
            bad: Int.random(in: 0...4) % 4 == 1
        )
        
        switch sizeSpeed {
        case .bigSlow:
            target.spriteNode.setScale(0.45)
            target.spriteNode.position = CGPoint(x: start, y: -150)
            target.spriteNode.zPosition = 0.5
            target.spriteNode.name = "bigTarget"
        case .smallFast:
            target.spriteNode.setScale(0.35)
            target.spriteNode.position = CGPoint(x: start, y: -150)
            target.spriteNode.zPosition = 0.5
            target.spriteNode.name = "smallTarget"
        }
        
        switch target.bad {
        case true:
            target.spriteNode.blendMode = .replace
            target.spriteNode.name = "bad"
        case false:
            break
        }
        
        cropNode.addChild(target.spriteNode)
        targets.append(target)
        
        target.spriteNode.run(SKAction.moveBy(x: 0, y: 115, duration: 0.05))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            target.spriteNode.run(SKAction.moveBy(x: self.finish, y: 0, duration: runTime * (sizeSpeed == .bigSlow ? 6 : 4))) { [weak self] in
                self?.hide(target.spriteNode)
            }
        }
    }
    
    func hide(_ target: SKNode) {
        target.run(SKAction.moveBy(x: 0, y: -115, duration: 0.05))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.targets.removeAll(where: { $0.spriteNode == target })
            target.removeFromParent()
        }
    }
}
