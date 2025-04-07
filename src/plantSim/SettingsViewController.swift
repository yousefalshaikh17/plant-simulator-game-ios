//
//  SettingsViewController.swift
//  plantSim
//
//  Created by user208467 on 5/4/23.
//

import Foundation
import UIKit

class SettingsViewController : UIViewController {
    
    private let dataModel = (UIApplication.shared.delegate as! AppDelegate).gameDataModel
    
    private let cheatPattern = [ 0,1,2,3 ]
    private var cheatProgress = -1
    
    @IBOutlet weak var useGesturesSwitch: UISwitch!
    @IBOutlet weak var infiniteWaterText: UILabel!
    @IBOutlet weak var infiniteWaterSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load in settings to the switches
        useGesturesSwitch.isOn = dataModel.isUsingGestures
        infiniteWaterSwitch.isOn = dataModel.infiniteWater
        
        // If cheats are not already being used or have been activated previously, enable the secret gestures.
        if (!dataModel.infiniteWater && !dataModel.cheatsActivated)
        {
            setupCheatGestures()
        } else {
            showCheatOption()
            dataModel.cheatsActivated = true
        }
        
    }
    
    private func setupCheatGestures()
    {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(cheatSwipeGestureRecognizer))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(cheatSwipeGestureRecognizer))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cheatSwipeGestureRecognizer))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(cheatSwipeGestureRecognizer))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
    
    }
    
    private func showCheatOption()
    {
        infiniteWaterText.isHidden = false
        infiniteWaterSwitch.isHidden = false
    }
    
    private func activateCheat()
    {
        self.showCheatOption()
        dataModel.cheatsActivated = true
        let alertController = UIAlertController(title: "Secret Cheats Enabled", message: "Infinite water has been enabled.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            print("Activated cheats.")
            self.infiniteWaterSwitch.isOn = true
            self.dataModel.infiniteWater = true
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func cheatSwipeGestureRecognizer(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            var directionNum: Int
            switch swipeGesture.direction {
            case .up:
                directionNum = 0
            case .right:
                directionNum = 1
            case .down:
                directionNum = 2
            case .left:
                directionNum = 3
            default:
                directionNum = -1
            }
            
            if (cheatPattern[cheatProgress+1] == directionNum)
            {
                cheatProgress += 1
                print("Cheat step \(cheatProgress) completed.")
                if (cheatPattern.count == cheatProgress+1)
                {
                    print("Secret pattern complete.")
                    // Disable cheats
                    if let recognizers = view.gestureRecognizers {
                        for recognizer in recognizers {
                            view.removeGestureRecognizer(recognizer)
                        }
                    }
                    activateCheat()
                }
            } else {
                print("Failed. Restarting cheat.")
                // Check if the failed swipe was the first in the cheat pattern. If so, skip the first step as it has already been done.
                if (cheatPattern[0] == directionNum)
                {
                    cheatProgress = 0
                } else {
                    cheatProgress = -1
                }
            }
            
        }
    }
    
    @IBAction func onUseGestureSwitchClick(_ sender: UISwitch) {
        let newState = sender.isOn
        if (newState != dataModel.isUsingGestures)
        {
            dataModel.isUsingGestures = newState
        }
    }
    
    
    @IBAction func onInfiniteWaterSwitchClick(_ sender: UISwitch) {
        let newState = sender.isOn
        if (newState != dataModel.infiniteWater)
        {
            dataModel.infiniteWater = newState
        }
            
    }
}
