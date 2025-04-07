//
//  Plant.swift
//  plantSim
//
//  Created by user208467 on 5/2/23.
//

import SpriteKit

class Plant : StaticObject {
    
    private let maxHealth: CGFloat = 100
    private var gauge: GaugeNode!
    
    private var plantNode: SKSpriteNode?
    
    private var onDeathCallback: (()->Void)? = nil
    
    var gaugeEnabled: Bool {
        get {
            return gauge.parent == self
        }
        set {
            if (newValue && !gaugeEnabled)
            {
                addChild(gauge)
            } else {
                if let gauge = gauge {
                    gauge.removeAllActions()
                    gauge.removeAllChildren()
                }
            }
        }
    }
    
    override func createPhysicsBody()
    {
        let physicsSize = min(size.width, size.height)
        let newPhysicsBody = SKPhysicsBody(rectangleOf: CGSize(width: physicsSize*0.95, height: physicsSize*0.05), center: CGPoint(x: 0,y: size.height*0.5) )
        
        // Set up collision category
        newPhysicsBody.categoryBitMask = GameScene.surfaceCategory
        newPhysicsBody.contactTestBitMask = GameScene.dropletCategory
        
        //newPhysicsBody.collisionBitMask = 0
        
        
        // Configure it instantly to make sure it isnt affected.
        newPhysicsBody.isDynamic = false

        // Update physicsbody property now that it is safe.
        physicsBody = newPhysicsBody
    }
    
    func createPlantNode(isAlive: Bool)
    {
        // Remove previous plant
        removeAllChildren()
        // get file name
        var plantName = "plant"
        if (!isAlive)
        {
            plantName += "_dead"
        }
        // Create plant
        let plant = SKSpriteNode(imageNamed: plantName)
        let plantWidth = size.width
        plant.size = CGSize(width: plantWidth, height: plant.size.height/plant.size.width * plantWidth)
        plant.position = CGPoint(x: 0, y: (size.height/2) + plant.size.height/2  )
        plantNode = plant
        addChild(plant)

    }
    
    
    func die()
    {
        createPlantNode(isAlive: false)
        gaugeEnabled = false
        gauge.amount = 0
        onDeathCallback?()
        
        // Stop degrading to optimize as plant is no longer needed.
        stopDegrading()
    }
    
    func isAlive()-> Bool
    {
        let health = getHealth()
        return health > 0
    }
    
    func getCenter()-> CGPoint
    {
        var plantNodeHeight :CGFloat = 0
        if let plantNode = self.plantNode {
            plantNodeHeight = plantNode.size.height
        }
        let newY = (position.y - (size.height/2)) + ((size.height+plantNodeHeight)/2)
        return CGPoint(x: position.x, y: newY)
    }
    
    func startDegrading()
    {
        // Remove previous action
        stopDegrading()
        // Start degrading livecycle. Player should start watering.
        let degradeAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.run {
                [weak self] in
                guard let plant = self else {return}
                guard let gauge = plant.gauge else {return}
                gauge.amount -= CGFloat.random(in: 1...3)
                if (!plant.isAlive())
                {
                    plant.die()
                }
            }
        ]))
        run(degradeAction)
    }
    
    func stopDegrading()
    {
        removeAllActions()
    }
    
    override func setup()
    {
        createPlantNode(isAlive: true)
        gauge = GaugeNode(size: CGSize(width: size.width, height: size.width/4), maximumValue: maxHealth, radius: 8 / 414 * (parent as! SKScene).size.height)
        gauge.amount = maxHealth
        
        gauge.position = CGPoint(x: 0, y: 0)
        gaugeEnabled = true
        
        startDegrading()
    }
    
    func getHealth()->CGFloat
    {
        return gauge!.amount/maxHealth
    }

    
    override func onCollide(object: GameObject) {
        print("Collided with " + String(describing: type(of: object)))
        if object is WaterDroplet {
            object.destroy()
            let newHP = gauge.amount + 2
            if (newHP <= gauge.maximumValue)
            {
                gauge.amount = newHP
            } else {
                die()
                
                // Overflow so allow water droplets to spill around
                physicsBody = nil
            }
        }
    }
    
    func onDeathListener(target: NSObject, selector: Selector)
    {
        onDeathCallback = {
            // To prevent memory leaks and strong references
            [weak target] in
            target?.perform(selector)
        }
    }
}
