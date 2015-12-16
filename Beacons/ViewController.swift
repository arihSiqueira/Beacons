//
//  ViewController.swift
//  Beacons
//
//  Created by Student on 12/10/15.
//  Copyright © 2015 Student. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, ESTBeaconManagerDelegate, OEEventsObserverDelegate{
    
    @IBOutlet weak var talkB: UIButton!
    @IBOutlet weak var mLabelTalk: UILabel!
    @IBOutlet weak var mLabel: UILabel!
    var lmPath: String!
    var dicPath: String!
    var words: Array<String> = []
    var currentWord: String!
    
    
    let openEarsEventObserver = OEEventsObserver()
    let speechSynthesizer = AVSpeechSynthesizer()
    let audioPermission = AVAudioSession()
    
    let beaconManager = ESTBeaconManager()
    let beaconRegion = CLBeaconRegion(
        proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
        identifier: "ranged region")
    let placesByBeacons = [
        "5330:65289": [
            "Heavenly Sandwiches": 50, // read as: it's 50 meters from
            // "Heavenly Sandwiches" to the beacon with
            // major 6574 and minor 54631
            "Green & Green Salads": 150,
            "Mini Panini": 325
        ],
        "50668:34186": [
            "Heavenly Sandwiches": 250,
            "Green & Green Salads": 100,
            "Mini Panini": 20
        ]
    ]
 
    
//    func placesNearBeacon(beacon: CLBeacon) -> [String] {
//        let beaconKey = "\(beacon.major):\(beacon.minor)"
//        if let places = self.placesByBeacons[beaconKey] {
//            let sortedPlaces = Array(places).sort { $0.1 < $1.1 }.map { $0.0 }
//            return sortedPlaces
//        }
//        return []
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.beaconManager.delegate = self
        
        talkB.setTitle("Go", forState: UIControlState.Normal)
        
        self.beaconManager.requestAlwaysAuthorization()
        self.audioPermission.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if allowed {
                   print("Cop that")
                } else {
                   print("you'r the boss")
                }
            }
        }
        
        self.openEarsEventObserver.delegate = self
        loadOpenEar()
        
    }
    
    func loadOpenEar(){
        
        let lmGenerator: OELanguageModelGenerator = OELanguageModelGenerator()
        
        self.words = ["Help","Understood"]
        
        let name = "LanguageModelFileStarSaver"
        
        lmGenerator.generateLanguageModelFromArray(words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
        lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
        dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
    }

    @IBAction func talk(sender: AnyObject) {
        if talkB.currentTitle! == "Go"{
            startListening()
            talkB.setTitle("stop", forState: UIControlState.Normal)
        }
        else if talkB.currentTitle! == "stop"{
            stopListening()
            talkB.setTitle("Go", forState: UIControlState.Normal)
            
             }
     }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    
//    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon],
//        inRegion region: CLBeaconRegion) {
//            if let nearestBeacon = beacons.first {
//                let places = placesNearBeacon(nearestBeacon)
//                // TODO: update the UI here
//                
//                mLabel.text = places.first
//                
//                let speechUtterance = AVSpeechUtterance(string: mLabel.text!)
//                speechSynthesizer.speakUtterance(speechUtterance)
//                
//                print(places)
//                
//                
//                // TODO: remove after implementing the UI
//            }
//    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.beaconManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.beaconManager.stopRangingBeaconsInRegion(self.beaconRegion)
    }
    
    func startListening() {
        do{
            try OEPocketsphinxController.sharedInstance().setActive(true)
                OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
            } catch _ {}
        
        
    }
    
    func pocketsphinxDidStartListening() {
        print("Pocketsphinx is now listening.")
        
    }
    func pocketsphinxDidStopListening() {
        print("Pocketsphinx has stopped listening.")
        }
    
    func stopListening() {
        OEPocketsphinxController.sharedInstance().stopListening()
    }
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        
        mLabelTalk.text = "Heard: \(hypothesis)"
    }
    func pocketsphinxDidDetectFinishedSpeech() {
        print("Pocketsphinx has detected a period of silence, concluding an utterance.")
        mLabelTalk.text = "Pocketsphinx has detected a period of silence, concluding an utterance."
    }
    
    func pocketsphinxDidSuspendRecognition() {
        print("Pocketsphinx has suspended recognition.")
        mLabelTalk.text = "Pocketsphinx has suspended recognition."
    }
    
    func pocketsphinxDidResumeRecognition() {
        print("Pocketsphinx has resumed recognition.")
        mLabelTalk.text = "Pocketsphinx has resumed recognition."
    }


}

