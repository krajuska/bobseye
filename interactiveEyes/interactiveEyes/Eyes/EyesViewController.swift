//
//  EyesViewController.swift
//  interactiveEyes
//
//  Created by Aline Krajuska on 8/17/21.
//

import UIKit
import AVFoundation

enum Side {
    case left
    case right
}

class EyesViewController: UIViewController, AVAudioRecorderDelegate {
    private var mainView = UIView()
    private var eyesImageView: UIImageView = UIImageView()
    private var blinkImageView: UIImageView = UIImageView()
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    var eyeTimer = Timer()
    var blinkTimer = Timer()

    var LEVEL_THRESHOLD: Float = -40.0
    var BLINK_TIME_INTERVAL: Double = 0.2
    var TIME_BETWEEN_BLINKS: Double = 5
    var EYE_TIME_INTERVAL: Double = 0.1
    var EYE_CHECK_TIME_INTERVAL: Double = 2
    
    var chosenSide: Side = .right
    var alreadyToTheSide: Bool = false
    var alreadyInTheCenter: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
        recordStuff()
        scheduledTimerWithTimeInterval()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func setupMainView() {
        view.addSubview(mainView)
        mainView.anchor(top: view.topAnchor,
                        left: view.leftAnchor,
                        bottom: view.bottomAnchor,
                        right: view.rightAnchor
        )
        
        view.addSubview(eyesImageView)
        eyesImageView.image = UIImage(named: "eye center")
        eyesImageView.anchor(top: view.topAnchor,
                             left: view.leftAnchor,
                             bottom: view.bottomAnchor,
                             right: view.rightAnchor)
        
        view.addSubview(blinkImageView)
        blinkImageView.image = UIImage(named: "blink 3")
        blinkImageView.isHidden = true
        blinkImageView.anchor(top: view.topAnchor,
                             left: view.leftAnchor,
                             bottom: view.bottomAnchor,
                             right: view.rightAnchor)
        
        addGestures()
    }
    
    func addGestures() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(EyesViewController.handleTap(_:)))
        tapGR.delegate = self
        tapGR.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapGR)
        
        let longTapGR = UILongPressGestureRecognizer(target: self, action: #selector(EyesViewController.handleLongPress(_:)))
        longTapGR.delegate = self
        view.addGestureRecognizer(longTapGR)
    }
    
    func recordStuff() {
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let url = documents.appendingPathComponent("record.caf")

        let recordSettings: [String: Any] = [
            AVFormatIDKey:              kAudioFormatAppleIMA4,
            AVSampleRateKey:            44100.0,
            AVNumberOfChannelsKey:      2,
            AVEncoderBitRateKey:        12800,
            AVLinearPCMBitDepthKey:     16,
            AVEncoderAudioQualityKey:   AVAudioQuality.max.rawValue
        ]

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setActive(true)
            try recorder = AVAudioRecorder(url:url, settings: recordSettings)
        } catch {
            return
        }

        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()

        levelTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
        
        eyeTimer = Timer.scheduledTimer(timeInterval: self.EYE_CHECK_TIME_INTERVAL, target: self, selector: #selector(updateAnimationTimer), userInfo: nil, repeats: true)
    }

    @objc func levelTimerCallback() {
        recorder.updateMeters()

        let level = recorder.averagePower(forChannel: 0)
        let isLoud = level > LEVEL_THRESHOLD
        let shouldLookToTheSide = isLoud && !self.alreadyToTheSide

        print("level: \(level) isLoud: \(isLoud)")
        
        if shouldLookToTheSide {
            self.lookToTheSide(side: self.chosenSide)
        }
    }
    
    @objc func updateAnimationTimer() {
        recorder.updateMeters()

        let level = recorder.averagePower(forChannel: 0)
        let isLoud = level > LEVEL_THRESHOLD
        let isQuiet = !isLoud
        let shouldReturnToTheCenter = isQuiet && !self.alreadyInTheCenter
        
        if shouldReturnToTheCenter {
            self.returnToTheCenter(side: self.chosenSide)
        }
    }
    
    func returnToTheCenter(side: Side) {
        switch side {
        case .left:
            DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                self.eyesImageView.image = UIImage(named: "left 4")
                DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                    self.eyesImageView.image = UIImage(named: "left 3")
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                        self.eyesImageView.image = UIImage(named: "left 2")
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                            self.eyesImageView.image = UIImage(named: "left 1")
                            DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                                self.eyesImageView.image = UIImage(named: "eye center")
                                self.alreadyToTheSide = false
                                self.alreadyInTheCenter = true
                            }
                        }
                    }
                }
            }
        case .right:
            DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                self.eyesImageView.image = UIImage(named: "right 4")
                DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                    self.eyesImageView.image = UIImage(named: "right 3")
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                        self.eyesImageView.image = UIImage(named: "right 2")
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                            self.eyesImageView.image = UIImage(named: "right 1")
                            DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                                self.eyesImageView.image = UIImage(named: "eye center")
                                self.alreadyToTheSide = false
                                self.alreadyInTheCenter = true
                            }
                        }
                    }
                }
            }
        }
    }

    func lookToTheSide(side: Side) {
        switch side {
        case .left:
            DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                self.eyesImageView.image = UIImage(named: "left 1")
                DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                    self.eyesImageView.image = UIImage(named: "left 2")
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                        self.eyesImageView.image = UIImage(named: "left 3")
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                            self.eyesImageView.image = UIImage(named: "left 4")
                            self.alreadyToTheSide = true
                            self.alreadyInTheCenter = false
                        }
                    }
                }
            }
        case .right:
            DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                self.eyesImageView.image = UIImage(named: "right 1")
                DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                    self.eyesImageView.image = UIImage(named: "right 2")
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                        self.eyesImageView.image = UIImage(named: "right 3")
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.EYE_TIME_INTERVAL) {
                            self.eyesImageView.image = UIImage(named: "right 4")
                            self.alreadyToTheSide = true
                            self.alreadyInTheCenter = false
                        }
                    }
                }
            }
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        blinkTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.blink), userInfo: nil, repeats: true)
    }
    
    func setupLongPressTweaksView() {
        let modalViewController = UIViewController()
        modalViewController.modalPresentationStyle = .fullScreen
        modalViewController.view.backgroundColor = .white
        
        let longTapGR = UILongPressGestureRecognizer(target: self, action: #selector(EyesViewController.handleExitLongPress(_:)))
        longTapGR.delegate = self
        modalViewController.view.addGestureRecognizer(longTapGR)
        
        let tweakTitleLabel = UILabel()
        tweakTitleLabel.text = "Hellozinho, my love! It's tweak time!"
        tweakTitleLabel.textAlignment = .center
        
        let tweakSubtitleLabel = UILabel()
        tweakSubtitleLabel.text = "Tap on the options to add new values for all the possible variables."
        tweakSubtitleLabel.textAlignment = .center
        
        let thresholdButton = UIButton()
        thresholdButton.setTitle("LEVEL THRESHOLD", for: .normal)
        
        let blinkButton = UIButton()
        blinkButton.setTitle("BLINK ANIMATION SPEED", for: .normal)
        
        let eyeButton = UIButton()
        eyeButton.setTitle("EYE MOVEMENT SPEED", for: .normal)
        
        let eyeIntervalButton = UIButton()
        eyeIntervalButton.setTitle("SILENCE CHECKS", for: .normal)
        
        let blinkIntervalButton = UIButton()
        blinkIntervalButton.setTitle("TIME BETWEEN BLINKS", for: .normal)
        
        let dismissLabel = UILabel()
        dismissLabel.text = "Another long tap to dismiss me. I love you, bye!"
        dismissLabel.textAlignment = .center
        dismissLabel.numberOfLines = 0
        
        modalViewController.view.addSubview(tweakTitleLabel)
        modalViewController.view.addSubview(tweakSubtitleLabel)
        modalViewController.view.addSubview(dismissLabel)
        
        tweakTitleLabel.anchor(top: modalViewController.view.topAnchor,
                               left: modalViewController.view.leftAnchor,
                               right: modalViewController.view.rightAnchor,
                               paddingTop: 20,
                               paddingLeft: 30,
                               paddingRight: 30)
        
        tweakSubtitleLabel.anchor(top: tweakTitleLabel.bottomAnchor,
                                  left: modalViewController.view.leftAnchor,
                                  right: modalViewController.view.rightAnchor,
                                  paddingTop: 10,
                                  paddingLeft: 30,
                                  paddingRight: 30)
        
        let whiteView = UIView()
        whiteView.backgroundColor = .systemPurple
        
        modalViewController.view.addSubview(whiteView)
        whiteView.anchor(left: modalViewController.view.leftAnchor,
                    right: modalViewController.view.rightAnchor,
                    paddingTop: 20,
                    paddingLeft: 30,
                    paddingRight: 30)
        
        whiteView.addSubview(thresholdButton)
        whiteView.addSubview(blinkButton)
        whiteView.addSubview(eyeButton)
        whiteView.addSubview(eyeIntervalButton)
        whiteView.addSubview(blinkIntervalButton)
        
        thresholdButton.anchor(top: whiteView.topAnchor,
                               left: whiteView.leftAnchor,
                               paddingTop: 10,
                               paddingLeft: 10)
        
        blinkButton.anchor(top: whiteView.topAnchor,
                           right: whiteView.rightAnchor,
                           paddingTop: 10,
                           paddingRight: 10)
        
        blinkIntervalButton.anchor(top: blinkButton.bottomAnchor,
                                   right: whiteView.rightAnchor,
                                   paddingTop: 10,
                                   paddingRight: 10)
        
        eyeButton.anchor(top: thresholdButton.bottomAnchor,
                         left: whiteView.leftAnchor,
                         paddingTop: 10,
                         paddingLeft: 10)
        
        eyeIntervalButton.anchor(top: eyeButton.bottomAnchor,
                                 left: whiteView.leftAnchor,
                                 bottom: whiteView.bottomAnchor,
                                 paddingTop: 10,
                                 paddingLeft: 10,
                                 paddingBottom: 10)
        
        dismissLabel.anchor(top: whiteView.bottomAnchor,
                            left: modalViewController.view.leftAnchor,
                            bottom: modalViewController.view.bottomAnchor,
                            right: modalViewController.view.rightAnchor,
                            paddingTop: 30,
                            paddingLeft: 30,
                            paddingBottom: 30,
                            paddingRight: 30)
        
        
        thresholdButton.addTarget(self, action: #selector(thresholdChanger), for: .touchUpInside)
        blinkButton.addTarget(self, action: #selector(blinkChanger), for: .touchUpInside)
        blinkIntervalButton.addTarget(self, action: #selector(blinkIntervalChanger), for: .touchUpInside)
        eyeButton.addTarget(self, action: #selector(eyeChanger), for: .touchUpInside)
        eyeIntervalButton.addTarget(self, action: #selector(eyeIntervalChanger), for: .touchUpInside)
        
        present(modalViewController, animated: true, completion: nil)
    }
    
    @objc func thresholdChanger(sender: UIButton!) {
      print("threshold tapped")
        
        let alert = UIAlertController(title: "Level threshold", message: "Tells the app how loud you expect to talk. The current value is \(self.LEVEL_THRESHOLD)", preferredStyle: .alert)
        alert.addTextField { (thresholdTextField) in
            thresholdTextField.placeholder = "New threshold value:"
        }
        alert.addAction(UIAlertAction(title: "Change it!", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let thresholdText = textField.text else { return }
            print("Level threshold: \(thresholdText)")
            self.LEVEL_THRESHOLD = Float(thresholdText) ?? self.LEVEL_THRESHOLD
        }))
        
        var parentController = UIApplication.shared.keyWindow?.rootViewController
        while (parentController?.presentedViewController != nil &&
                parentController != parentController!.presentedViewController) {
            parentController = parentController!.presentedViewController
        }
        parentController?.present(alert, animated:true, completion:nil)
    }
    
    @objc func blinkIntervalChanger(sender: UIButton!) {
        print("blink interval tapped")
          
          let alert = UIAlertController(title: "Time between blinks", message: "Tells the app how often the eye must blink. The current value is \(self.TIME_BETWEEN_BLINKS)", preferredStyle: .alert)
          alert.addTextField { (blinkTextField) in
              blinkTextField.placeholder = "New blinking pattern in seconds:"
          }
          alert.addAction(UIAlertAction(title: "Change it!", style: .default, handler: { [weak alert] (_) in
              guard let textField = alert?.textFields?[0], let blinkText = textField.text else { return }
              print("Blink time interval: \(blinkText)")
              self.TIME_BETWEEN_BLINKS = Double(blinkText) ?? self.TIME_BETWEEN_BLINKS
          }))
          
          var parentController = UIApplication.shared.keyWindow?.rootViewController
          while (parentController?.presentedViewController != nil &&
                  parentController != parentController!.presentedViewController) {
              parentController = parentController!.presentedViewController
          }
          parentController?.present(alert, animated:true, completion:nil)
      }
    
    @objc func blinkChanger(sender: UIButton!) {
      print("blink tapped")
        
        let alert = UIAlertController(title: "Blink animation speed", message: "Tells how fast the app should loop through the blink frames. The current value is \(self.BLINK_TIME_INTERVAL)", preferredStyle: .alert)
        alert.addTextField { (blinkTextField) in
            blinkTextField.placeholder = "New blinking speed in seconds:"
        }
        alert.addAction(UIAlertAction(title: "Change it!", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let blinkText = textField.text else { return }
            print("Blink time interval: \(blinkText)")
            self.BLINK_TIME_INTERVAL = Double(blinkText) ?? self.BLINK_TIME_INTERVAL
        }))
        
        var parentController = UIApplication.shared.keyWindow?.rootViewController
        while (parentController?.presentedViewController != nil &&
                parentController != parentController!.presentedViewController) {
            parentController = parentController!.presentedViewController
        }
        parentController?.present(alert, animated:true, completion:nil)
    }
    
    @objc func eyeChanger(sender: UIButton!) {
        print("eye tapped")
        
        let alert = UIAlertController(title: "Eye animation speed. Tells how fast the app should loop between frames", message: "The current value is \(self.EYE_TIME_INTERVAL)", preferredStyle: .alert)
        alert.addTextField { (eyeTextField) in
            eyeTextField.placeholder = "New eye animation speed in seconds:"
        }
        alert.addAction(UIAlertAction(title: "Change it!", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let eyeText = textField.text else { return }
            print("Eye speed: \(eyeText)")
            self.EYE_TIME_INTERVAL = Double(eyeText) ?? self.EYE_TIME_INTERVAL
        }))
        
        var parentController = UIApplication.shared.keyWindow?.rootViewController
        while (parentController?.presentedViewController != nil &&
                parentController != parentController!.presentedViewController) {
            parentController = parentController!.presentedViewController
        }
        parentController?.present(alert, animated:true, completion:nil)
    }
    
    @objc func eyeIntervalChanger(sender: UIButton!) {
        print("eye interval tapped")
        
        let alert = UIAlertController(title: "Time interval between silence checks. This is when the app sees if the eye has to return to the center.", message: "The current value is \(self.EYE_CHECK_TIME_INTERVAL)", preferredStyle: .alert)
        alert.addTextField { (eyeTextField) in
            eyeTextField.placeholder = "New silence check time interval:"
        }
        alert.addAction(UIAlertAction(title: "Change it!", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let eyeText = textField.text else { return }
            print("silence check time interval: \(eyeText)")
            self.EYE_CHECK_TIME_INTERVAL = Double(eyeText) ?? self.EYE_CHECK_TIME_INTERVAL
        }))
        
        var parentController = UIApplication.shared.keyWindow?.rootViewController
        while (parentController?.presentedViewController != nil &&
                parentController != parentController!.presentedViewController) {
            parentController = parentController!.presentedViewController
        }
        parentController?.present(alert, animated:true, completion:nil)
    }
    
    func setupDoubleTapSideChanger() {
        switch self.chosenSide {
        case .left:
            self.chosenSide = .right
            print("from left to right")
        case .right:
            self.chosenSide = .left
            print("from right to left")
        }
    }
    
    @objc func blink() {
        DispatchQueue.main.asyncAfter(deadline: .now() + self.BLINK_TIME_INTERVAL) {
            self.blinkImageView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + self.BLINK_TIME_INTERVAL) {
                self.blinkImageView.image = UIImage(named: "blink 2")
                DispatchQueue.main.asyncAfter(deadline: .now() + self.BLINK_TIME_INTERVAL) {
                    self.blinkImageView.image = UIImage(named: "blink 3")
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.BLINK_TIME_INTERVAL) {
                        self.blinkImageView.isHidden = true
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("did receive memory warning")
    }
}

extension EyesViewController: UIGestureRecognizerDelegate {
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        self.setupDoubleTapSideChanger()
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        self.setupLongPressTweaksView()
    }
    
    @objc func handleExitLongPress(_ gesture: UILongPressGestureRecognizer) {
        self.dismiss(animated: true)
    }
}
