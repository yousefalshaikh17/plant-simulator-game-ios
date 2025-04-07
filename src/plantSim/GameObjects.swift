//
//  GameObject.swift
//  plantSim
//
//  Created by user208467 on 4/30/23.
//


import SpriteKit


class GameObject : SKSpriteNode {
        
 
    
    open func createPhysicsBody()
    {
        physicsBody = SKPhysicsBody(rectangleOf: size)
    }
    
    func getPhysicsBody() -> SKPhysicsBody
    {
        if (physicsBody == nil)
        {
            createPhysicsBody()
        }
        return physicsBody!
    }
    
    open func onCollide(object: GameObject)
    {
        
    }
    
    open func checkIfInFrame() -> Bool
    {
        if let scene = scene {
            if (scene.intersects(self))
            {
                return true
            }
        }
        return false
    }
    
    open func destroy()
    {
        removeFromParent()
        print("Destroyed object of class:  " + String(describing: type(of: self)))
    }
    
    open func setup()
    {
        
    }
}

class StaticObject : GameObject {

}

class DynamicObject : GameObject {
    
    open var useGravity: Bool {
        get {
            return getPhysicsBody().affectedByGravity
        }
        set {
            getPhysicsBody().affectedByGravity = newValue
        }
    }
    
    open var velocity: CGVector {
        get {
            return getPhysicsBody().velocity
        }
        set {
            getPhysicsBody().velocity = newValue
        }
    }
    
    open func move(deltaTime: TimeInterval)
    {
        
    }
}
