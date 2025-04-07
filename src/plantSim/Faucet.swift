//
//  Faucet.swift
//  plantSim
//
//  Created by user208467 on 5/1/23.
//

import CoreGraphics
import SpriteKit

class Faucet : StaticObject, Pourable {
    
    private var lastTimeUsed: TimeInterval = 0
    
    var tankLimit: Float = 0
    
    var isPouring = false
    
    func getSprinklerPosition() -> CGPoint {
        return CGPoint(x: position.x - (size.width*0.26), y: position.y - (size.height*0.7))
    }
    
    func getDropletSize() -> CGSize {
        let size :CGFloat = 20 / 414 * (parent as! SKScene).size.height
        return CGSize(width: size, height: size)
    }
    
    func drain(amount: Int, currentTime: TimeInterval)-> Bool
    {
        if (isPouring && currentTime - lastTimeUsed > 2/60)
        {
            lastTimeUsed = currentTime
            return true
        }
        return false
    }
    
    func getDropletSpreadX() -> CGFloat {
        let spread :CGFloat = 2 / 414 * (parent as! SKScene).size.height
        return CGFloat.random(in: -spread...spread)
    }
    
    
    
}
