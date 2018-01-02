//
//  AudioPlayerManager.swift
//  AudioRecorder
//
//  Created by 최윤주 on 2018. 1. 2..
//  Copyright © 2018년 YUNJU. All rights reserved.
//

import Foundation
import AVFoundation

extension Notification.Name {
    static let AudioPlayerDidFinishPlayingAudioFile = Notification.Name("AudioPlayerDidFinishPalyingAudioFile")
}

class AudioPlayerManager: NSObject {
    
    static let shared = AudioPlayerManager()
    
    override init() {
        super.init()
        
        // One more thing - If you're going to use this class without the AudioRecorderManager then you need to set the session active for audio or otherwise it wont work
        // I will write the code anyway and comment it so if you need it you can use it later
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback )
//            print("AVAudioSession Category Playback OK")
//            
//            do {
//                try AVAudioSession.sharedInstance().setActive(true)
//                print("AVAudioSession is Active")
//            } catch {
//                print("Error Activating Session", error.localizedDescription)
//            }
//        } catch {
//            print("Error activating audio session", error.localizedDescription)
//        }
        
        
    }
    
    private var currentPlayer:AVAudioPlayer?
    
    var isPlaying = false
    var isFinished = false
    
    var lastPath:String?
    
    func play(path:String){
        
        // If we already loaded the file no need to load it again in case the user paused and play it again
        if lastPath == path && isFinished == false {
            self.currentPlayer?.play()
            return
        }
        
        let url = URL.init(string: path)
        
        do {
            self.currentPlayer = try AVAudioPlayer(contentsOf: url!)
            self.currentPlayer?.delegate = self
            self.currentPlayer?.play()
            isPlaying = true
            self.isFinished = false
            self.lastPath = url?.path // Here we're taking a copy of the url to track it later to see if the user playing the same file or different one
            
        } catch {
            print("Error loading File", error.localizedDescription)
        }
    }
    
    func pause() {
        isPlaying = false
        self.currentPlayer?.pause()
    }
    
    
    // You can play audio files from different places
    // I will list here two ways
    // 1 - Load file from userDocuments Folder (like what we did in the last video when we recorded the file and then saved it in the user doc
    // 2 - Load file from bundle (Just drag and drop it in the navigator)
    
    func audioFileInUserDocuments(fileName:String) -> String {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        return  url.appendingPathComponent(fileName+".m4a").path
    }
 
    func audioFileFromBundle(fileName:String) -> String {
        return Bundle.main.path(forResource: fileName, ofType: ".m4a")! // In our case
    }
}

// Let's implement the delegate for AVAudioPlayerDelegate
extension AudioPlayerManager:AVAudioPlayerDelegate {
    
    // Called when the file finished playing
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isFinished = true
        isPlaying = false
        
        NotificationCenter.default.post(name: Notification.Name.AudioPlayerDidFinishPlayingAudioFile, object: nil)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription ?? "") // ?? means if nil then show ""
    }
    
}








