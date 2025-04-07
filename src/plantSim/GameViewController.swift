//
//  GameViewController.swift
//  plantSim
//
//  Created by user208467 on 4/4/23.
//

import SpriteKit

class GameViewController : UIViewController {
   
    private let dataModel = (UIApplication.shared.delegate as! AppDelegate).gameDataModel
    
    
    @IBOutlet weak var waterButton: UIButton!
    private var showingFaucetButton = false
    
    private var wateringCanSpeed: CGFloat = 200
    
    @IBOutlet weak var stopwatchLabel: UILabel!
    @IBOutlet weak var waterTankBar: UIProgressView!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    private let pauseTexture = UIImage(named: "pause_button")!
    private let playTexture = UIImage(named: "play_button")!
    private var gameScene = GameScene()
    

    @IBOutlet weak var menuButton: UIButton!
    
    // MARK: Button inputs
    
    @IBAction func rightButtonDown(_ sender: Any) {
        movePlayer(xVelocity: wateringCanSpeed)
    }
    @IBAction func rightButtonUp(_ sender: Any) {
        stopMovingPlayer()
    }
    @IBAction func rightButtonUpOutside(_ sender: Any) {
        stopMovingPlayer()
    }
    @IBAction func leftButtonDown(_ sender: Any) {
        movePlayer(xVelocity: -wateringCanSpeed)
    }
    @IBAction func leftButtonUp(_ sender: Any) {
        stopMovingPlayer()
    }
    @IBAction func leftButtonUpOutside(_ sender: Any) {
        stopMovingPlayer()
    }
    

    @IBAction func pourButtonDown(_ sender: Any) {
        changePouring(isPouring: true)
    }
    @IBAction func pourButtonUp(_ sender: Any) {
        changePouring(isPouring: false)
    }
    @IBAction func pourButtonUpOutside(_ sender: Any) {
        changePouring(isPouring: false)
    }
    
    func goToResultsScreen(gameTime: TimeInterval)
    {
        dataModel.latestScore = gameTime
        let resultsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultsViewController")
        show(resultsVC, sender: self)
        
    }
    
    
    private func changePouring(isPouring: Bool)
    {
        if (!gameScene.gameOver)
        {
            if (showingFaucetButton)
            {
                if (isPouring)
                {
                    gameScene.setWateringCanRotationIntensity(intensity: 0)
                }
                gameScene.setFaucetEnabled(enabled: isPouring)
            } else {
                gameScene.setWateringCanRotationIntensity(intensity: isPouring ? 1 : 0)
                if (isPouring)
                {
                    gameScene.setFaucetEnabled(enabled: false)
                }
            }
        } else {
            gameScene.setWateringCanRotationIntensity(intensity: 0)
            gameScene.setFaucetEnabled(enabled: false)
        }
        
    }
    
    private func stopMovingPlayer()
    {
        gameScene.setWateringCanVelocity(xVelocity: 0)
    }
    
    private func movePlayer(xVelocity: CGFloat)
    {
        if (!gameScene.gameOver)
        {
            gameScene.setWateringCanVelocity(xVelocity: xVelocity)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if (!dataModel.infiniteWater)
        {
            // Necessary since runtime attributes do not support these data types.
            waterTankBar.layer.borderColor = UIColor.black.cgColor
            waterTankBar.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        } else {
            waterTankBar.isHidden = true
        }


        
        
        // previous attempts at rotating the watering can before the use of interface builder
/*
        waterBarContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        waterBarContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        waterBarContainer.widthAnchor.constraint(equalToConstant: 6).isActive = true
        waterBarContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7).isActive = true
        waterTankBar.transform = CGAffineTransform(rotationAngle: -.pi / 2)
 */
        /*
        waterTankBar.translatesAutoresizingMaskIntoConstraints = false

        
        
        NSLayoutConstraint.activate([
            waterTankBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waterTankBar.widthAnchor.constraint(equalToConstant: 10),
            waterTankBar.topAnchor.constraint(equalTo: pauseButton.bottomAnchor, constant: 20),
            waterTankBar.bottomAnchor.constraint(equalTo: leftButton.topAnchor, constant: -20)
        ])

        // Rotate the waterTankBar
        waterTankBar.transform = CGAffineTransform(rotationAngle: -.pi / 2)

        // Update constraints to adjust for rotated view
        NSLayoutConstraint.deactivate([
            waterTankBar.widthAnchor.constraint(equalToConstant: 10)
        ])
        NSLayoutConstraint.activate([
            waterTankBar.heightAnchor.constraint(equalToConstant: 200),
            //waterTankBar.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 20),
            //waterTankBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            //waterTankBar.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        */

        gameScene.size = view.bounds.size
        gameScene.scaleMode = .resizeFill
        (view as! SKView).presentScene(gameScene)
        
        // Check if gestures settings are on and enable recognizers respectively.
        if (dataModel.isUsingGestures)
        {
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(onRotationGesture(recognizer:)))
            view.addGestureRecognizer(rotationGestureRecognizer)
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(recognizer:)))
            view.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    func updateWaterTankBar(percentage: Float)
    {
        waterTankBar.setProgress(percentage, animated: true)
    }
    
    // MARK: Gesture inputs
    
    @objc func onPanGesture(recognizer: UIPanGestureRecognizer)
    {
        if (!gameScene.gameOver)
        {
            var faucetPouring = false
            if (showingFaucetButton)
            {
                var downTranslation = max(0, recognizer.translation(in: view).y/view.frame.height) // Get normalized down gesture
                if (recognizer.state == .ended)
                {
                    downTranslation = 0
                }
                faucetPouring = downTranslation > 0.2
                changePouring(isPouring: faucetPouring)
            }
            // To make sure there are no conflicting gestures between pour and move
            if (!faucetPouring)
            {
                if (recognizer.state != .ended)
                {
                    // Normalized horizantal movement
                    let horizantalMovement = min(recognizer.translation(in: view).x/(view.frame.width), 1)
                    //print(horizantalMovement.description)
                    // Threshhold to ensure that the user does not accidently input lower movements.
                    if (abs(horizantalMovement) > 0.05)
                    {
                        movePlayer(xVelocity: min(wateringCanSpeed*horizantalMovement*3, wateringCanSpeed))
                    }
                } else {
                    stopMovingPlayer()
                }
            }
        } else {
            stopMovingPlayer()
            changePouring(isPouring: false)
        }
        
    }
    
    func updateStopwatch(currentTime: TimeInterval)
    {
        stopwatchLabel.text = ScoreManager.getTimeScoreFormatted(time: currentTime)
    }
    
    /*
    @objc func onSwipeGesture(recognizer: UISwipeGestureRecognizer)
    {
        if (showingFaucetButton)
        {
            var downTranslation = (recognizer.direction == .down) //max(0, recognizer.translation(in: view).y/view.frame.height) // Get normalized down gesture
            if (recognizer.state == .ended)
            {
                downTranslation = false
            }
            changePouring(isPouring: recognizer.state != .ended)
        }
    }
    */
     
    @objc func onRotationGesture(recognizer: UIRotationGestureRecognizer)
    {
        if (!gameScene.gameOver)
        {
            var intensity: CGFloat = recognizer.rotation
            if (recognizer.state == .ended)
            {
                intensity = 0
            }
            gameScene.setWateringCanRotationIntensity(intensity: -intensity)
        }
    }
    
    
    
    @IBAction func onPausePlayButtonPressed(_ sender: UIButton)
    {
        let newState = !gameScene.isPaused
        gameScene.isPaused = newState
        let buttonImage: UIImage = newState ? playTexture : pauseTexture
        menuButton.isHidden = !newState
        sender.setImage(buttonImage, for: .normal)
    }
    
    func updateWaterButton(isUnderFaucet: Bool)
    {
        if (isUnderFaucet != showingFaucetButton)
        {
            var imageName: String
            if (isUnderFaucet) {
                imageName = "faucet_button"
            } else {
                imageName = "water_button"
            }
            let image = UIImage(named: imageName)
            waterButton.setImage(image, for: .normal)
            showingFaucetButton = isUnderFaucet
        }
    }
    
    func setUIEnabled(view: UIView, enabled: Bool)
    {
        // Change button useability
        for subview in view.subviews {
            if (subview != gameScene) {
                //subview.isEnabled = enabled
                subview.isHidden = !enabled
            }
        }
    }
    
    func setUserInteractionEnabled(canInteract: Bool)
    {
        view.isUserInteractionEnabled = canInteract
        
        setUIEnabled(view: view,enabled: canInteract)
        
        if (!canInteract)
        {
            stopMovingPlayer()
            changePouring(isPouring: false)
        }
        
    }
    
}
