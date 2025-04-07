//
//  GameScene.swift
//  plantSim
//
//  Created by user208467 on 4/4/23.
//

import SpriteKit


class GameScene : SKScene, SKPhysicsContactDelegate {
    
    private var gameViewController: GameViewController!
    var wateringCan: WateringCan!
    var faucet: Faucet!
    
    //private var wateringCanXVelocity: CGFloat = 0
    private var pouring: Bool = false
    
    private var frameCount = 0
    private var dropletRate = 10
    
    private let stopwatchLabel = SKLabelNode(text: "00:00.00")
    
    
    // Collision categories
    static let dropletCategory:UInt32 = 0x1 << 0;
    static let surfaceCategory:UInt32 = 0x1 << 1;
    static let noCollisionsCategory: UInt32 = 0x0
    
    // Start time
    private var startTime: TimeInterval = -1
    
    private var pauseStartTime: TimeInterval = 0
    
    private var pauseTime: TimeInterval = 0
    
    private var actualGameTime: TimeInterval = 0
    
    private var infiniteWater: Bool = (UIApplication.shared.delegate as! AppDelegate).gameDataModel.infiniteWater
    
    var gameOver: Bool = false
    
    override var isPaused: Bool {
        get {
            return super.isPaused
        }
        set {
            if (!gameOver)
            {
                super.isPaused = newValue
                if (newValue)
                {
                    pauseStartTime = lastUpdatedTime
                }
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        
        if let view = self.view, let viewController = view.next as? GameViewController {
            gameViewController = viewController
        }
        
        // Set up physics & gravity for droplets
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -1.8)
        
        
        // Set up background
        let bgImage = SKSpriteNode(imageNamed: "planks_background")
        let frameSize = frame.size
        bgImage.size.width = frameSize.width/frameSize.height*bgImage.size.height // = CGSize(frameSize.width/frameSize.height*background.size.height, background.size) // (Removed for better startup optimization)
        bgImage.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(bgImage)
        
        
        // Set up window.
        let windowHeight: CGFloat = 350 / 414 * size.height
        let windowImage = SKSpriteNode(imageNamed: "window_shelf")
        windowImage.size = CGSize(width: windowImage.size.width/windowImage.size.height * windowHeight, height: windowHeight)
        windowImage.position = CGPoint(x: frame.midX - (frame.width * 0.1), y: frame.midY)
        let windowSize = windowImage.size
        
        let windowBody = SKPhysicsBody(rectangleOf: CGSize(width: windowSize.width, height: windowSize.height * 0.074), center: CGPoint(x:0, y:-windowSize.height/2 * 0.926))
        windowBody.isDynamic = false
        windowImage.physicsBody = windowBody
        addChild(windowImage)
                
        let plantHeight: CGFloat = windowHeight/4.375 //80
        let plantTexture = SKTexture(imageNamed: "pot")
        
        let plantSize = CGSize(width: plantTexture.size().width/plantTexture.size().height * plantHeight, height: plantHeight)
        
        //let plantGap =
        let plantDeathCallback = #selector(self.onPlantDeath)
        
        for i in -1...1 {
            let plant = Plant(imageNamed: "pot")
            plant.size = plantSize
            plant.position = CGPoint(x: windowImage.position.x + (plantSize.width * 4/3 * CGFloat(i)) , y: windowImage.position.y - (windowImage.position.y * 0.535))
            plant.createPhysicsBody()
            plant.onDeathListener(target: self, selector: plantDeathCallback)
            addChild(plant)
            plant.setup()
        }
        
        
        // Set up watering can.
        let canHeight: CGFloat = 100 / 414 * size.height
        wateringCan = WateringCan(imageNamed: "updated_watering_can");
        wateringCan.position = CGPoint(x: size.width/2, y:size.height * 0.65)
        wateringCan.size = CGSize(width: wateringCan.size.width/wateringCan.size.height * canHeight, height: canHeight)
        wateringCan.setup()
        wateringCan.setOnTankUpdateListener(target: self, selector: #selector(updateWaterTankDisplay(tankCapacity:)))
        wateringCan.infiniteWater = infiniteWater
        //wateringCan.physicsBody = SKPhysicsBody(rectangleOf: wateringCan.frame.size)
        //wateringCan.physicsBody?.isDynamic = false
        
        addChild(wateringCan);
        if (!infiniteWater)
        {
            faucet = Faucet(imageNamed: "faucet")
            let faucetHeight :CGFloat = 50 / 414 * size.height
            faucet.size = CGSize(width: faucet.size.width/faucet.size.height * faucetHeight, height: faucetHeight)
            faucet.position = CGPoint(x: size.width-(faucet.size.width/2), y: size.height - (size.height/8))
            addChild(faucet)
        }
        
        /*
        // Add label
        stopwatchLabel.fontColor = .black
        stopwatchLabel.fontSize = size.height * 0.13
        stopwatchLabel.position = CGPoint(x: size.width/2, y: size.height*0.87)
        stopwatchLabel.fontName = "Helvetica"
        stopwatchLabel.horizontalAlignmentMode = .center
        stopwatchLabel.preferredMaxLayoutWidth = 80

        addChild(stopwatchLabel)
        */
        // Debugging using physics bodys. This helps viualize the bodies and figure out if they are the right size.
        //view.showsPhysics = true
        

    }
    
    private var deadPlants = 0
    
    @objc func onPlantDeath()
    {
        deadPlants += 1
    }
    

    
    func setInfiniteWater(infiniteWater: Bool)
    {
        self.infiniteWater = infiniteWater
    }
    
    func endGame()
    {
        if (!gameOver)
        {
            gameOver = true
            print("Game over!")
        
            var timeBeforeContinue: CGFloat = 1.5
            
            var deadPlants = [Plant]()
            
            // Disable gauges and degrading on plants
            for node in children {
                if let plant = node as? Plant { // Cast to plant if possible
                    plant.stopDegrading()
                    plant.gaugeEnabled = false
                    if (!plant.isAlive())
                    {
                        deadPlants.append(plant)
                        print("Dead plant detected")
                    }
                } else if let dropletLifetime = (node as? WaterDroplet)?.maximumLifetime { // If droplet found then check its maximum lifetime
                    timeBeforeContinue = max(timeBeforeContinue, dropletLifetime) // If droplet lifetime is higher then update the wait time before continue
                }
            }
            
            if let viewController = gameViewController {
                // Disable interaction
                viewController.setUserInteractionEnabled(canInteract: false)

                var zoomPos: CGPoint
                
                // Calculate zoom position based on dead plant positions.
                if (deadPlants.count > 1)
                {
                    var totalX: CGFloat = 0
                    var totalY: CGFloat = 0
                    
                    for deadPlant in deadPlants {
                        let centerPos = deadPlant.getCenter()
                        totalX += centerPos.x
                        totalY += centerPos.y
                    }
                    // Get zoom pos based on the average position
                    zoomPos = CGPoint(x: totalX/CGFloat(deadPlants.count), y: totalY/CGFloat(deadPlants.count) )
                } else {
                    zoomPos = deadPlants[0].getCenter()
                }
                
                let cameraNode = SKCameraNode()
                addChild(cameraNode)
                let scale = CGFloat(0.5) // the zoom scale you want to apply
                    
                // set the camera to start in the middle
                cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
                
                let zoomAction = SKAction.group([
                    SKAction.move(to: zoomPos, duration: 1.5),
                    SKAction.scale(to: scale, duration: 1.5)
                ])
                self.camera = cameraNode
                cameraNode.run(zoomAction)
                
                // Pause before transition for user effect
                let pauseAction = SKAction.sequence([
                    SKAction.wait(forDuration: timeBeforeContinue + 0.1),
                    SKAction.run {
                        viewController.goToResultsScreen(gameTime: self.actualGameTime)
                        super.isPaused = true
                        print("Sent to results.")
                    }
                ])
                run(pauseAction)
            }

            
            //isPaused = true
        }
    }
    
    func updateStopwatch(currentTime: TimeInterval)
    {
        if (!gameOver)
        {
            gameViewController.updateStopwatch(currentTime: currentTime)
        }
    }
    
    
    func setWateringCanVelocity(xVelocity: CGFloat)
    {
        wateringCan.xVelocity = xVelocity
    }
    
    func setWateringCanRotationIntensity(intensity: CGFloat)
    {
        if (intensity != wateringCan.rotationIntensity)
        {
            wateringCan.rotate(intensity: intensity)
        }
    }
    
    func setFaucetEnabled(enabled: Bool)
    {
        if (!infiniteWater)
        {
            if (enabled)
            {
                setWateringCanRotationIntensity(intensity: 0)
            }
            faucet.isPouring = enabled
        }
    }
    
    func createDroplet(pourable: Pourable)-> WaterDroplet
    {
        let droplet = WaterDroplet(imageNamed: "water_droplet")
        droplet.size = pourable.getDropletSize()
        droplet.position = pourable.getSprinklerPosition()
        let xSpeed = pourable.getDropletSpreadX()
        
        //let xSpread = CGFloat.random(in: -spreadLimit...spreadLimit)
        //droplet.position.x += xSpread
        addChild(droplet)
        droplet.drop(xVelocity: xSpeed)
        return droplet
    }
    
    @objc func updateWaterTankDisplay(tankCapacity: Float)
    {
        gameViewController.updateWaterTankBar(percentage:  tankCapacity / wateringCan.tankLimit)
    }
    
    private var lastUpdatedTime: TimeInterval = 0
    
    
    override func update(_ currentTime: TimeInterval) {
        frameCount += 1
        if (!gameOver)
        {
            if (wateringCan != nil)
            {
                if (startTime == -1)
                {
                    startTime = currentTime
                }
                // Check if game was paused recently
                if (pauseStartTime > 0)
                {
                    let pauseDuration = currentTime - pauseStartTime
                    pauseTime += pauseDuration
                    pauseStartTime = 0
                    lastUpdatedTime = currentTime
                    return
                }
                let gameTime = currentTime - startTime - pauseTime
                actualGameTime = gameTime
                updateStopwatch(currentTime: gameTime)
                
                if (wateringCan.xVelocity != 0)
                {
                    wateringCan.move(deltaTime: currentTime-lastUpdatedTime)
                    
                    if (!infiniteWater)
                    {
                        // Check if under faucet
                        var useFaucet = false
                        if let wateringCanBody = wateringCan.physicsBody {
                            if let boundingBox = wateringCanBody.node?.frame {
                                var faucetDrainPos = faucet.getSprinklerPosition()
                                faucetDrainPos.y = boundingBox.midY
                                useFaucet = boundingBox.contains(faucetDrainPos)
                                
                            }
                        }
                        // Update watering button
                        gameViewController.updateWaterButton(isUnderFaucet: useFaucet)
                        if (useFaucet)
                        {
                            setWateringCanRotationIntensity(intensity: 0)
                        }
                    }
                }
                
                
                if (wateringCan.drain(amount: 1, currentTime: gameTime))
                {
                    let _ = createDroplet(pourable: wateringCan)
                }
                else if (!infiniteWater && wateringCan.tankLimit > wateringCan.tankCapacity && faucet.drain(amount: 1, currentTime: gameTime))
                {
                    let _ = createDroplet(pourable: faucet) //.physicsBody?.collisionBitMask = GameScene.noCollisionsCategory
                }
            }
            //let deltaTime = currentTime - lastUpdatedTime
            
            lastUpdatedTime = currentTime
            if (deadPlants > 0)
            {
                endGame()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let objectA = contact.bodyA.node as? GameObject, let objectB = contact.bodyB.node as? GameObject
        {
            objectA.onCollide(object: objectB)
            objectB.onCollide(object: objectA)
        }
    }
    
}

