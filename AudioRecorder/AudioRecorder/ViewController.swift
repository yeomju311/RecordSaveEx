//
//  ViewController.swift
//  AudioRecorder
//
//  Created by 최윤주 on 2018. 1. 2..
//  Copyright © 2018년 YUNJU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    // MARK :
    // MARK : Recorded Button
    
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var recordedView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.buildVoiceCircle()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.audioPlayerDidFinishPlaying), name: Notification.Name.AudioPlayerDidFinishPlayingAudioFile, object: nil)
    }
    
    func audioPlayerDidFinishPlaying() {
        print("Audio player did finish")
        
        DispatchQueue.main.async {
            self.playBtn.setImage(#imageLiteral(resourceName: "playbutton"), for: .normal)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Timer to update the status of our recording
    var nonObservablePropertiesUpdateTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)

    
    @IBAction func StartRecording(_ sender: UIButton) {
        
        if AudioRecorderManager.shared.recorded(fileName: "TestFile") {
            nonObservablePropertiesUpdateTimer.resume()
        }
        
        // We need create a data formatter to format the time from the recorder
        
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = false
        formatter.allowedUnits = [.minute, .second]
        formatter.calendar = Calendar.current
        
        nonObservablePropertiesUpdateTimer.setEventHandler { [weak self] in
            // Aduio recording circle animations here
            
            guard let peak = AudioRecorderManager.shared.recorder else {
                return
            }
            
            self?.durationLabel.text = formatter.string(from: AudioRecorderManager.shared.recorder!.currentTime)
            
            let percent = (Double(AudioRecorderManager.shared.recorderPeak0) + 160) / 160
            
            let final = CGFloat(percent) + 0.3
            
            UIView.animate(withDuration: 0.15, animations: {
                self?.WaveAnimationView.transform = CGAffineTransform(scaleX: final, y: final)
            })
        }
            
        nonObservablePropertiesUpdateTimer.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.milliseconds(100))
        
            UIView.animate(withDuration: 0.15, animations: {
                self.WaveAnimationView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Release to stop recording"
            self.statusLabel.textColor = UIColor.orange
        }
    }
    
    @IBAction func StopRecording(_ sender: UIButton) {
        
        AudioRecorderManager.shared.finishRecording()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.WaveAnimationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        })
        
        nonObservablePropertiesUpdateTimer.suspend()
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Press & hold to start"
            self.statusLabel.textColor = UIColor.black
        }
    }
    
    @IBAction func playFile(_ sender: AnyObject) {
        //In order to check the file if it's recording we can check for the file if it is exists after the record
        
        //Let's get the user's doc path
        
        
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        
//        print("File Location:",url.path)
//        
//        
//        if FileManager.default.fileExists(atPath: url.path){
//            print("File found and ready to play")
//        }else{
//            print("no File")
//        }
        
        if AudioPlayerManager.shared.isPlaying {
            AudioPlayerManager.shared.pause()
            self.playBtn.setImage(#imageLiteral(resourceName: "playbutton"), for: .normal)
        } else {
            let path = AudioPlayerManager.shared.audioFileInUserDocuments(fileName: "TestFile")
            self.playBtn.setImage(#imageLiteral(resourceName: "stopbutton"), for: .normal)
            
            AudioPlayerManager.shared.play(path: path)
        }
    }
    
    
    // MARK:
    // MARK: Build Wave Circle
    var WaveAnimationView: UIView!
    func buildVoiceCircle() {
        
        let size = CGSize(width: 200, height: 200)
        
        let newPoint = CGPoint(x:self.recordedView.frame.size.width / 2 - 100 , y: self.recordedView.frame.size.height / 2 - 100)
        WaveAnimationView = UIView(frame: CGRect(origin:newPoint , size: size))
        WaveAnimationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        WaveAnimationView.layer.cornerRadius = 100
        WaveAnimationView.backgroundColor = UIColor.clear
        WaveAnimationView.layer.borderColor = UIColor.green.cgColor
        WaveAnimationView.layer.borderWidth = 1.0
        self.recordedView.addSubview(WaveAnimationView)
        
        self.WaveAnimationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
    
}











