//
//  AudioRecorderManager.swift
//  AudioRecorder
//
//  Created by 최윤주 on 2018. 1. 2..
//  Copyright © 2018년 YUNJU. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecorderManager: NSObject {
    
    static let shared = AudioRecorderManager()
    
    var recordingSession:AVAudioSession!
    var recorder:AVAudioRecorder?
    
    func setup() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try recordingSession.setActive(true)
            
            // we need to request permission from the user otherwise we will be recording silence
            
            recordingSession.requestRecordPermission({ (allowed:Bool) in
                if allowed {
                    print("Mic authorized")
                } else{
                    print("Mic not authorized")
                }
            })
        } catch {
            print("Failed to set category", error.localizedDescription)
        }
    }
    
    var meterTimer:Timer?
    
    var recorderApc0:Float = 0
    var recorderPeak0:Float = 0
    
    // Start The record session
    func recorded(fileName:String) -> Bool {
        let url = getUserPath().appendingPathComponent(fileName+".m4a")
        
        let audioURL = URL.init(fileURLWithPath:url.path)
        
        let recordedSettings:[String:Any] = [
            AVFormatIDKey:NSNumber(value: kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey:1200.0,
            AVNumberOfChannelsKey:1,
            AVSampleRateKey:44100.0
        ]
        
        do {
            recorder = try AVAudioRecorder(url: audioURL, settings: recordedSettings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.prepareToRecord()
            
            recorder?.record()
            
            self.meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {(timer:Timer) in
                
                // Here we should always update the recorder meter values so we can track the voice loudness
                
                if let recorder = self.recorder {
                    recorder.updateMeters()
                    self.recorderApc0 = recorder.averagePower(forChannel: 0)
                    self.recorderPeak0 = recorder.peakPower(forChannel: 0)
                }
        })
            
            print("Recording")
            
            return true
        } catch {
            print("Erro Recording")
            
            return false
        }
        
    }
    
    // Stop the recorder
    func finishRecording() {
        self.recorder?.stop()
        self.meterTimer?.invalidate()
    }
    
    
    // Get the path for the folder we will be saving the file to
    func getUserPath() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// Let's become the delegate AVAudioRecorder

extension AudioRecorderManager:AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Audio Manager did finish recording")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error encoding", error?.localizedDescription ?? "")
        
    }
}














