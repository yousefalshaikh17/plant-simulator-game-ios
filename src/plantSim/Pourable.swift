//
//  Pourable.swift
//  plantSim
//
//  Created by user208467 on 5/2/23.
//

import CoreGraphics
import SpriteKit

protocol Pourable {
    var isPouring: Bool {get}
    var tankLimit: Float {get}
    func getSprinklerPosition()-> CGPoint
    func getDropletSize()-> CGSize
    func drain(amount: Int, currentTime: TimeInterval)-> Bool
    func getDropletSpreadX()-> CGFloat
}
