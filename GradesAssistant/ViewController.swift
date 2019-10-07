//
//  ViewController.swift
//  GradesAssistant
//
//  Created by Ahmed Khattab on 8/25/19.
//  Copyright © 2019 AhmedKhattab. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

struct message {
    var text:String
    var sender: Bool
}

class ViewController:  UIViewController , UITableViewDelegate, UITableViewDataSource,AVSpeechSynthesizerDelegate , SFSpeechRecognizerDelegate
{
    
    
    let synth = AVSpeechSynthesizer()
    var myText = AVSpeechUtterance(string: "")
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var messages = [message]()
    let first = message(text: "Hello ... pleas say student's name.." , sender: true)
    var flag = 0

    
    @IBOutlet weak var AssistantTableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.AssistantTableView.register(messagesTableViewCell.self, forCellReuseIdentifier: "cell")
        self.messages.append(first)
        
        speechRecognizer?.delegate = self
        
        synth.delegate = self
        
        myText = AVSpeechUtterance(string: first.text)
        myText.rate = 0.35
        synth.speak(myText)
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .notDetermined:
                isButtonEnabled = false
                print("not authorized yet\n")
            case .denied:
                isButtonEnabled = false
                print("user denied access to speech recognition\n")
            case .restricted:
                isButtonEnabled = false
                print("speech recognition is restricted on this device")
            }
            
            OperationQueue.main.addOperation {
                self.recordButton.isEnabled = isButtonEnabled
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(dataReceved), name: Notification.Name("getStudent"), object: nil)
    }
    
    
    @objc func dataReceved (notification:Notification) {
        
        let result = notification.userInfo!["result"] as! String
        let says = message(text: result , sender: true)
        
        self.messages.append(says)
        DispatchQueue.main.sync {
            UIView.animate(withDuration: 2)
            {
                self.AssistantTableView.reloadData()
                self.scrollToBottom()
            }
            speakText(voiceOutdata: result)
        }}
   
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! messagesTableViewCell
        cell.messageLabel.text = messages[indexPath.row].text
        cell.sender = messages[indexPath.row].sender
        return cell
    }
    
    func scrollToBottom(){
        let indexPath = IndexPath(row: self.messages.count-1, section: 0)
        self.AssistantTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    //Speach Recognizer
    

    @IBAction func record(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
            recordButton.isEnabled = false
            recordButton.setImage(UIImage(named: "mic"), for: .normal)
            if (self.messages[self.messages.count - 1].sender == false)
            {
                let studentData = DataViewController()
                studentData.getStudent(name: messages[messages.count - 1].text)
            }
            recordButton.isEnabled = true
        } else {
            self.flag = 0
            startRecording()
            recordButton.setImage(UIImage(named: "listen"), for: .normal)
        }
    }
    
    func startRecording(){
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        }
        catch {
            print("audioSession properties weren't set because of an error")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
      
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: {(result, error) in
            var isFinal = false
            if result != nil {
                let outresult = (result?.bestTranscription.formattedString)!
                if (self.flag == 0)
                {
                    let says = message(text: outresult , sender: false)
                    self.messages.append(says)
                    self.flag = self.messages.count - 1
                }
                else
                {
                    self.messages[self.flag].text = outresult
                }
                self.AssistantTableView.reloadData()
                self.scrollToBottom()
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.recordButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine Couldn't start because of an error")
        }
    }
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        }
        else {
            recordButton.isEnabled = false
        }
    }
    
    
    func speakText(voiceOutdata: String ) {
    
        do {
            try AVAudioSession.sharedInstance().setCategory("AVAudioSessionCategoryPlayAndRecord", mode: "AVAudioSessionModeSpokenAudio", options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        let utterance = AVSpeechUtterance(string: voiceOutdata)
        utterance.voice = AVSpeechSynthesisVoice(language: "en")
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
        
        defer {
            disableAVSession()
        }
    }
    
    private func disableAVSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("audioSession properties weren't disable.")
        }
    }
}
