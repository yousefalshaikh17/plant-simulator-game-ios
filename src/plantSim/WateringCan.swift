//
//  DynamicObject.swift
//  plantSim
//
//  Created by user208467 on 4/30/23.
//

import CoreGraphics
import SpriteKit

class WateringCan : DynamicObject, Pourable {

    
    private var lastTimeUsed: TimeInterval = 0
    var rotationIntensity: CGFloat = 0
    
    var infiniteWater: Bool = false
    
    var isPouring: Bool = false
    
    var xVelocity: CGFloat = 0
    //let maxXVelocity: CGFloat = 200
    
    var tankLimit: Float = 100
    var tankCapacity: Float = 100
    
    private let drainNode: SKNode = SKNode()
    
    private let minimumAngleForWatering: CGFloat = 38
    private let maximumAngle: CGFloat = 70
    
    private var maximumDropletsPerSecond: CGFloat = 2
    
    private var onTankUpdateCallback: ((Float)->Void)? = nil
    
    
    func getSprinklerPosition() -> CGPoint {
        let drainPos = drainNode.convert(drainNode.position, to: scene!)
        //drainPos.y -= size.height * 0.05
        return drainPos
    }
    
    func getDropletSize() -> CGSize {
        let size :CGFloat = 15 / 414 * (parent as! SKScene).size.height
        return CGSize(width: size, height: size)
    }
    
    func drain(amount: Int, currentTime: TimeInterval) -> Bool {
        let angle = zRotation / (CGFloat.pi / 180)
        // Get power between 0 and 1.
        let dropPower = max(0, angle-minimumAngleForWatering)/(maximumAngle-minimumAngleForWatering)
        if (isPouring && (infiniteWater || tankCapacity > 0) && currentTime - lastTimeUsed > (maximumDropletsPerSecond / dropPower)/60 )
        {
            lastTimeUsed = currentTime
            if (!infiniteWater)
            {
                setTankCapacity(newCapacity: max(0, tankCapacity - Float(dropPower)))
            }
            return true
        }
        return false
    }
    
    func getDropletSpreadX() -> CGFloat {
        return (CGFloat.random(in: -5...5) + xVelocity) / 414 * (parent as! SKScene).size.height
    }
    
    
    
    
    override func createPhysicsBody()
    {
        let physicsSize = min(size.width, size.height) * 0.85
        let newPhysicsBody = SKPhysicsBody(rectangleOf: CGSize(width: physicsSize, height: physicsSize*0.2), center: CGPoint(x: size.width*0.1,y: size.height*0.28) )
        
        // Set up collision category
        newPhysicsBody.categoryBitMask = GameScene.surfaceCategory
        newPhysicsBody.contactTestBitMask = GameScene.dropletCategory
        
        newPhysicsBody.collisionBitMask = 0
        
        
        // Configure it instantly to make sure it isnt affected.
        newPhysicsBody.isDynamic = false
        
        // Update physicsbody property now that it is safe.
        physicsBody = newPhysicsBody
    }
    
    override func setup()
    {
        createPhysicsBody()
        let drainPoint = CGPoint(x: -(size.width*0.23), y: (size.height*0.04))
        addChild(drainNode)
        drainNode.position = drainPoint
    }
    
    override func move(deltaTime: TimeInterval)
    {
        //print((parent as! SKScene).size.height.description)
        let xChange = xVelocity * deltaTime * (896 / (parent as! SKScene).size.width)
        if let scene = scene {
            if (xChange != 0)
            {
                if (xChange > 0)
                {
                    position.x = min(scene.size.width-(size.width/2), position.x + xChange)
                } else {
                    position.x = max(size.width/2, position.x + xChange)
                }
            }

        }
    }
    
    func rotate(intensity: CGFloat)
    {
        rotationIntensity = intensity
        let angle: CGFloat = maximumAngle * max( min(1,intensity) , 0 )
        removeAllActions()
        let rotationAction = SKAction.sequence([
            SKAction.rotate(toAngle: angle * CGFloat.pi / 180 , duration: 0.02, shortestUnitArc: true),
            SKAction.run{
                self.isPouring = angle >= self.minimumAngleForWatering
            }
        ])
        run(rotationAction)
    }

    private func setTankCapacity(newCapacity: Float)
    {
        tankCapacity = newCapacity //min(tankCapacity+2, tankLimit)
        onTankUpdateCallback?(tankCapacity)
    }
    
    
    override func onCollide(object: GameObject) {
        //print("Collided with " + String(describing: type(of: object)))
        if object is WaterDroplet {
            object.destroy()
            // Add water to the tank
            setTankCapacity(newCapacity: min(tankCapacity+2, tankLimit))
        }
    }
    
    func setOnTankUpdateListener(target: NSObject, selector: Selector)
    {
        onTankUpdateCallback = { [weak target] tankCapacity in
            // To prevent memory leaks and strong references
            guard let target = target else { return }
            target.perform(selector)
        }
    }
}
