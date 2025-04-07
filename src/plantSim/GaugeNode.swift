//
//  Gauge.swift
//  plantSim
//
//  Created by user208467 on 5/2/23.
//
import SpriteKit

class GaugeNode: SKNode {
    private let backgroundNode: SKShapeNode
    private let gaugeNode: SKShapeNode
    let anchorPoint = CGPoint(x: 0.5, y: -0.5)
    
    private var currentAmount: CGFloat = 0
    private var maxValue: CGFloat
    private var gaugeSize: CGSize
    private var padding: CGFloat
    private var cornerRad: CGFloat = 0
    
    var cornerRadius: CGFloat {
        get {
            return cornerRad
        }
        set {
            cornerRad = newValue
            updateGaugeShape()
        }
    }
    
    var size: CGSize {
        get {
            return gaugeSize
        }
        set {
            gaugeSize = newValue
            // To ensure anchor point is still intact
            position = position
        }
    }
    
    override var position: CGPoint {
        get {
            return super.position
        }
        set {
            
            let offset = CGPoint(x: -size.width * anchorPoint.x, y: size.height * anchorPoint.y)
            super.position = CGPoint(x: newValue.x + offset.x, y: newValue.y + offset.y)
            //self.gaugeNode.position = CGPoint(x: 0, y: self.gaugeNode.size.height / 2 + offset.y)
        }
    }
    
    var backgroundColor: UIColor {
        get {
            return backgroundNode.fillColor
        }
        set {
            backgroundNode.fillColor = newValue
        }
    }
    
    var outlineColor: UIColor {
        get {
            return backgroundNode.strokeColor
        }
        set {
            backgroundNode.strokeColor = newValue
        }
    }
    
    var outlineWidth: CGFloat {
        get {
            return backgroundNode.lineWidth
        }
        set {
            backgroundNode.lineWidth = newValue
        }
    }
    
    var barColor: UIColor {
        get {
            return gaugeNode.fillColor
        }
        set {
            gaugeNode.fillColor = newValue
        }
    }
    
    var amount: CGFloat {
        get {
            return currentAmount
        }
        set {
            currentAmount = max(0, min(newValue, maximumValue))
            //gaugeNode.xScale = currentAmount
            //print("changed: " + gaugeNode.frame.size.width.description)
            //gaugeNode.position = CGPoint(x: (gaugeNode.xScale)/padding, y: 0)
            updateGaugeShape()
        }
    }
    
    var maximumValue :CGFloat {
        get {
            return maxValue
        }
        set {
            maxValue = newValue
            // To reset progress bar
            amount = amount
        }
    }
    
    init(size: CGSize, maximumValue: CGFloat = 1.0, radius: CGFloat = 0) {
        
        backgroundNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerRadius: max(0, radius))

        
        padding = 0.15 * size.height
        
        //print(padding.description + " " + size.height.description)
        
        gaugeNode = SKShapeNode()

        //print("initial: " + gaugeNode.frame.size.width.description)
        gaugeNode.strokeColor = .clear

        gaugeSize = size
        
        maxValue = maximumValue
        
        //cornerRad = cornerRadius
        
        super.init()
        
        self.cornerRadius = max(0, radius)
        
        // To reset anchor position
        position = position
        
        barColor = .blue
        backgroundColor = .white
        outlineColor = .black
        outlineWidth = 2
        
        
        addChild(backgroundNode)
        addChild(gaugeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateGaugeShape()
    {
        let gaugeRect = CGRect(x: padding, y: padding, width: (((size.width) - (padding * 2)))*(currentAmount/maximumValue), height: size.height - (padding * 2))
        gaugeNode.path = UIBezierPath(roundedRect: gaugeRect, cornerRadius: cornerRad/2).cgPath
    }

}
