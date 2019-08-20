//
//  ViewController.swift
//  Tomatimer
//
//  Created by Beniamin on 13.08.19.
//  Copyright © 2019 Beniamin. All rights reserved.
//  extra: info.plist: give option to set default session and break length

import UIKit
import AVFoundation
import KDCircularProgress //https://github.com/kaandedeoglu/KDCircularProgress

let progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
var breakTime = 60.0
var soundOn = true
var sessionTimeGone = 0.0
var timer = Timer()

class TimerViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var breakLengthLabel: UILabel!
    @IBOutlet weak var sessionLengthLabel: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var soundSwitch: UISwitch!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var breakStepper: UIStepper!
    @IBOutlet weak var sessionStepper: UIStepper!
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        soundOn = (sender.isOn ? true : false)
        
    }
    @IBAction func sessionStepperUsed(_ sender: UIStepper) {
        sessionLengthLabel.text = "Session length: " + String(Int(sender.value)) + " min" //Int() to remove decimals
    }
    
    @IBAction func breakStepperUsed(_ sender: UIStepper) {
        breakLengthLabel.text = "Break length: " + String(Int(sender.value)) + " min"
        breakTime = sender.value * 60 //convert to seconds
    }
    
    @IBAction func startPressed(_ sender: UIButton) {
        if progress.angle > 0{
        startButton.isEnabled = false
        }
         startButton.isEnabled = false
        changeSettingsState(enabled: false)
        progress.trackColor = UIColor.red
        var sessionDuration = sessionStepper.value * 60 //convert to minutes
        sessionDuration -= sessionTimeGone
        timer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
        progress.animate(fromAngle: progress.angle, toAngle: 360, duration: sessionDuration, completion: sessionComplete)
    }
    
    @objc func updateCounter(){
        print(sessionTimeGone)
        timeLabel.text = prepareTimeToDisplay(time: sessionTimeGone)
        sessionTimeGone += 0.1
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        changeSettingsState(enabled: true)
        progress.stopAnimation()
        progress.trackColor = UIColor.red
        startButton.isEnabled = true
        AudioPlayerSetup.shared.stop()
        timer.invalidate()
        sessionTimeGone = 0
        timeLabel.text = "00:00"
    }
    
    func changeSettingsState(enabled: Bool){
        soundSwitch.isEnabled = enabled
        breakStepper.isEnabled = enabled
        sessionStepper.isEnabled = enabled
        breakStepper.tintColor = (enabled ? UIColor.black : UIColor.gray)
        sessionStepper.tintColor = (enabled ? UIColor.black : UIColor.gray)
    }
    
    //based on https://medium.com/ios-os-x-development/build-an-stopwatch-with-swift-3-0-c7040818a10f
    func prepareTimeToDisplay(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    @IBAction func pausePressed(_ sender: Any) {
        progress.pauseAnimation()
        startButton.isEnabled = true
        timer.invalidate()
    }
    
    let sessionComplete:(Bool)->Void = { (compl:Bool) -> Void in
        let clearTheAngle:(Bool)->Void = { (compl:Bool) -> Void in
            progress.angle = 0
            progress.trackColor = UIColor.red
        }
        if(compl){
            print("completed")
            if(soundOn){
                AudioPlayerSetup.shared.play()
            }
            //setup break
            progress.trackColor = UIColor.green
            progress.animate(fromAngle: 0, toAngle: 360, duration: breakTime, completion: clearTheAngle)
        }
        timer.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        showTimer()
        
    }
    
    func showTimer(){
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.glowAmount = 0.2 //adds a little amunt of blur to the track
        progress.trackThickness = 0.1
        progress.trackColor = UIColor.lightGray
        progress.clockwise = true
        progress.roundedCorners = false
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.set(colors: UIColor.darkGray)
        progress.center = CGPoint(x: view.center.x, y: view.center.y + 25)
        
        mainStackView.insertArrangedSubview(progress, at: 1) //insert between top section (label) and bottom section (steppers)
        
        NSLayoutConstraint.activate(
            [
                progress.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6)
            ]
        )
    }
}


