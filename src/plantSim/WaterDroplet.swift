//
//  WaterDroplet.swift
//  plantSim
//
//  Created by user208467 on 5/1/23.
//

import CoreGraphics
import SpriteKit

class WaterDroplet : DynamicObject {
    
    let shrinkTime: CGFloat = 1.5
    let maximumLifetime: CGFloat = 3.5
    
    override func createPhysicsBody() {
        let newPhysicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        

        newPhysicsBody.categoryBitMask = GameScene.dropletCategory
        newPhysicsBody.contactTestBitMask = GameScene.dropletCategory | GameScene.surfaceCategory
        newPhysicsBody.isDynamic = true
        
        physicsBody = newPhysicsBody
    }
    
    func drop(xVelocity: CGFloat)
    {
        //let dropletMove = SKAction.repeatForever(SKAction.move(by: CGVector(dx: xVelocity, dy: 0), duration: 0.01))
        velocity = CGVector(dx: xVelocity, dy: 0) // Better to provide velocity to the physics body to handle.
        useGravity = true
        let deathSequence = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                SKAction.run{
                    [weak self] in
                    guard let droplet = self else {return}
                    if (droplet.position.y < 0)
                    {
                        droplet.destroy()
                    }
                }
            ])
        )
        

        let despawnSequence = SKAction.sequence([
            SKAction.wait(forDuration: maximumLifetime - shrinkTime),
            SKAction.scale(to: 0, duration: shrinkTime),
            SKAction.removeFromParent()
        ])
        
        run(SKAction.group([
            despawnSequence,
            deathSequence
        ]))
        
        
    }
    
}
