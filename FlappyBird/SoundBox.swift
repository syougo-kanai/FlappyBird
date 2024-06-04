//
//  SoundBox.swift
//  FlappyBird
//
//  Created by MTBS049 on 2024/05/31.
//

import UIKit
import SpriteKit
import AVFoundation

class SoundClass {
//let music = SKAction.playSoundFileNamed("Cuckoo Clock Sound.mp3", waitForCompletion: false)
   // let getMusic = SKAction.playSoundFileNamed("_ mac chime.mp3", waitForCompletion: false)
    
    var SoundPlayer: AVAudioPlayer?

    func playSoundEffectMusic(filename: String) {
        if let bundle = Bundle.main.path(forResource: filename, ofType: nil) {
            let backgroundMusicURL = URL(fileURLWithPath: bundle)
            
            do {
                SoundPlayer = try AVAudioPlayer(contentsOf: backgroundMusicURL)
               // SoundPlayer?.numberOfLoops = 0  // 無限ループ
                SoundPlayer?.volume = 0.5
                SoundPlayer?.prepareToPlay()
                SoundPlayer?.play()
            } catch {
                print("Could not create audio player: \(error)")
            }
        }
    }
    
    var audioPlayer: AVAudioPlayer?

    func playBackgroundMusic(filename: String) {
        if let bundle = Bundle.main.path(forResource: filename, ofType: nil) {
            let backgroundMusicURL = URL(fileURLWithPath: bundle)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: backgroundMusicURL)
                audioPlayer?.numberOfLoops = -1  // 無限ループ
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Could not create audio player: \(error)")
            }
        }
    }
    func stopBackgroundMusic() {
        audioPlayer?.stop()
    }
}
class SoundBox: SKScene {

}
