//
//  AudioPlayerSetup.swift
//  Tomatimer
//
//  Created by Beniamin on 17.08.19.
//  Copyright © 2019 Beniamin. All rights reserved.
//  Source of alarm sound: https://www.looperman.com/loops/detail/49562/wake-up-alarm-by-eshar-free-120bpm-fusion-fx-loop

import Foundation
import AVFoundation

class AudioPlayerSetup {
    static let shared = AudioPlayerSetup()
    init(){}
    var ringingSound: AVAudioPlayer? //this must be an instance variable - otherwise (local variable) no sound is played
    
    func play(){
        do{
            let path = Bundle.main.path(forResource: "wake-up-alarm.wav", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            ringingSound = try AVAudioPlayer(contentsOf: url)
            ringingSound?.play()
            print("played")
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func stop(){
        ringingSound?.stop()
    }
}
