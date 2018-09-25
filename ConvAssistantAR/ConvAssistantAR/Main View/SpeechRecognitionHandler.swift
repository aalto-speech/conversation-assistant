//
//  SpeechRecognition.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 03/07/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import Accelerate

enum ASRType {
    case aalto
    case apple
}

class SpeechRecognitionHandler: NSObject {

//    var transcriptions: [String]? = [""]
    var transcriptions: [String]? = ["Y", "Yk", "Yks", "Yksi", "Väli", "Yksik", "Yksikk", "Yksikkö", "Makkara", "Yksikkök", "Yksikköka", "Yksikkökak", "Yksikkökaks", "Yksikkökaksi", "Yksikkökaksik", "Yksikkökaksikk", "Yksikkökaksikko", "Vaihtelevaa pilvisyyttä ja lähinnä idässä päivällä yksittäisiä sadekuuroja. Yöllä poutaa ja verrattain selkeää. Päivän ylin lämpötila yhdeksäntoista viiva kaksikymmentäneljä ja yön alin kymmenen viiva viisitoista astetta. Lännessä vähän voimistuvaa etelätuulta, muuten heikkoa tuulta.", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec feugiat mi at justo semper volutpat. Vivamus rhoncus libero ut eros ultricies, sodales feugiat velit sagittis. Donec ornare tortor mi, at porta quam bibendum sit amet. In quis ex ipsum.", "Vestibulum in enim ante. Sed scelerisque vitae tortor ut tempus. Aenean lobortis porta condimentum. Aenean condimentum laoreet pulvinar. Suspendisse potenti. Etiam ex risus, pharetra interdum nunc vel, tempus consequat sem.", "Nullam vulputate tincidunt sem, eget pretium dolor elementum id. Quisque enim lorem, porttitor eget vestibulum vitae, malesuada ut dolor. Mauris venenatis laoreet arcu eget hendrerit. Nulla sed finibus tortor, id tincidunt metus. Praesent vulputate nisi vitae ex posuere, quis luctus nibh mattis. Morbi consectetur tortor nec mi aliquet, sit amet tristique nunc dictum. Vivamus lacinia ex eu rutrum lacinia. Aenean ac facilisis dui. Nam consectetur metus sit amet tempus tincidunt. Pellentesque ut sodales nulla, non maximus risus. Integer neque elit, tempus a metus non, scelerisque faucibus risus. Duis imperdiet augue ac tincidunt hendrerit. Maecenas at lacus iaculis, pretium libero sed, fermentum libero. Quisque sollicitudin mauris id mi elementum ultricies. Vestibulum tellus massa, pulvinar ut cursus nec, fringilla eget libero. Vestibulum fringilla turpis dolor, sed sollicitudin sapien pharetra a.", "Cras euismod luctus lacinia. Ut egestas ultrices est, id placerat risus sodales quis.", "Quisque dapibus, ipsum molestie pharetra blandit, arcu ipsum ultricies turpis, eget tincidunt eros risus ac nulla. Phasellus posuere eget velit sit amet vehicula. Integer at vestibulum purus, vitae molestie lorem. Cras ac nisi efficitur turpis ullamcorper sodales lobortis non metus. Nam tempor tellus vel magna posuere malesuada.", "Donec pulvinar tincidunt elementum. Sed non commodo urna. Aliquam maximus, nunc nec scelerisque egestas, libero ligula suscipit lorem, id sagittis urna lectus vel nisl. Vivamus auctor mauris sit amet laoreet tempus. Cras porta fermentum nunc nec interdum.", "Integer id nibh volutpat, aliquam ipsum quis, consequat ipsum. In in orci at nisl iaculis tempus. Quisque ut mauris ut magna cursus rhoncus. Praesent facilisis nisl non mi tempor imperdiet.", "Integer sit amet libero diam. Phasellus condimentum facilisis eros et condimentum. Cras elit neque, porta in odio ac, scelerisque vehicula tortor. Mauris condimentum tortor ultricies turpis pretium, vitae congue purus consequat.", "Duis eu porttitor lectus. Vestibulum dignissim ac tellus eget consequat. Proin id urna non mi cursus ultricies nec ac erat. Nullam quis consectetur orci. Etiam accumsan tristique eros, imperdiet tempor tortor commodo vel. Aliquam tincidunt vel odio quis porta. Quisque porta quis neque id faucibus.", "Maecenas dignissim posuere dui vitae maximus. Vivamus quam ipsum, feugiat nec faucibus id, imperdiet sit amet neque.", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec feugiat mi at justo semper volutpat. Vivamus rhoncus libero ut eros ultricies, sodales feugiat velit sagittis. Donec ornare tortor mi, at porta quam bibendum sit amet. In quis ex ipsum.", "Vestibulum in enim ante. Sed scelerisque vitae tortor ut tempus. Aenean lobortis porta condimentum. Aenean condimentum laoreet pulvinar. Suspendisse potenti. Etiam ex risus, pharetra interdum nunc vel, tempus consequat sem.", "Nullam vulputate tincidunt sem, eget pretium dolor elementum id. Quisque enim lorem, porttitor eget vestibulum vitae, malesuada ut dolor. Mauris venenatis laoreet arcu eget hendrerit. Nulla sed finibus tortor, id tincidunt metus. Praesent vulputate nisi vitae ex posuere, quis luctus nibh mattis. Morbi consectetur tortor nec mi aliquet, sit amet tristique nunc dictum. Vivamus lacinia ex eu rutrum lacinia. Aenean ac facilisis dui. Nam consectetur metus sit amet tempus tincidunt. Pellentesque ut sodales nulla, non maximus risus. Integer neque elit, tempus a metus non, scelerisque faucibus risus. Duis imperdiet augue ac tincidunt hendrerit. Maecenas at lacus iaculis, pretium libero sed, fermentum libero. Quisque sollicitudin mauris id mi elementum ultricies. Vestibulum tellus massa, pulvinar ut cursus nec, fringilla eget libero. Vestibulum fringilla turpis dolor, sed sollicitudin sapien pharetra a.", "Cras euismod luctus lacinia. Ut egestas ultrices est, id placerat risus sodales quis.", "Quisque dapibus, ipsum molestie pharetra blandit, arcu ipsum ultricies turpis, eget tincidunt eros risus ac nulla. Phasellus posuere eget velit sit amet vehicula. Integer at vestibulum purus, vitae molestie lorem. Cras ac nisi efficitur turpis ullamcorper sodales lobortis non metus. Nam tempor tellus vel magna posuere malesuada.", "Donec pulvinar tincidunt elementum. Sed non commodo urna. Aliquam maximus, nunc nec scelerisque egestas, libero ligula suscipit lorem, id sagittis urna lectus vel nisl. Vivamus auctor mauris sit amet laoreet tempus. Cras porta fermentum nunc nec interdum.", "Integer id nibh volutpat, aliquam ipsum quis, consequat ipsum. In in orci at nisl iaculis tempus. Quisque ut mauris ut magna cursus rhoncus. Praesent facilisis nisl non mi tempor imperdiet.", "Integer sit amet libero diam. Phasellus condimentum facilisis eros et condimentum. Cras elit neque, porta in odio ac, scelerisque vehicula tortor. Mauris condimentum tortor ultricies turpis pretium, vitae congue purus consequat.", "Duis eu porttitor lectus. Vestibulum dignissim ac tellus eget consequat. Proin id urna non mi cursus ultricies nec ac erat. Nullam quis consectetur orci. Etiam accumsan tristique eros, imperdiet tempor tortor commodo vel. Aliquam tincidunt vel odio quis porta. Quisque porta quis neque id faucibus.", "Maecenas dignissim posuere dui vitae maximus. Vivamus quam ipsum, feugiat nec faucibus id, imperdiet sit amet neque.", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec feugiat mi at justo semper volutpat. Vivamus rhoncus libero ut eros ultricies, sodales feugiat velit sagittis. Donec ornare tortor mi, at porta quam bibendum sit amet. In quis ex ipsum.", "Vestibulum in enim ante. Sed scelerisque vitae tortor ut tempus. Aenean lobortis porta condimentum. Aenean condimentum laoreet pulvinar. Suspendisse potenti. Etiam ex risus, pharetra interdum nunc vel, tempus consequat sem.", "Nullam vulputate tincidunt sem, eget pretium dolor elementum id. Quisque enim lorem, porttitor eget vestibulum vitae, malesuada ut dolor. Mauris venenatis laoreet arcu eget hendrerit. Nulla sed finibus tortor, id tincidunt metus. Praesent vulputate nisi vitae ex posuere, quis luctus nibh mattis. Morbi consectetur tortor nec mi aliquet, sit amet tristique nunc dictum. Vivamus lacinia ex eu rutrum lacinia. Aenean ac facilisis dui. Nam consectetur metus sit amet tempus tincidunt. Pellentesque ut sodales nulla, non maximus risus. Integer neque elit, tempus a metus non, scelerisque faucibus risus. Duis imperdiet augue ac tincidunt hendrerit. Maecenas at lacus iaculis, pretium libero sed, fermentum libero. Quisque sollicitudin mauris id mi elementum ultricies. Vestibulum tellus massa, pulvinar ut cursus nec, fringilla eget libero. Vestibulum fringilla turpis dolor, sed sollicitudin sapien pharetra a.", "Cras euismod luctus lacinia. Ut egestas ultrices est, id placerat risus sodales quis.", "Quisque dapibus, ipsum molestie pharetra blandit, arcu ipsum ultricies turpis, eget tincidunt eros risus ac nulla. Phasellus posuere eget velit sit amet vehicula. Integer at vestibulum purus, vitae molestie lorem. Cras ac nisi efficitur turpis ullamcorper sodales lobortis non metus. Nam tempor tellus vel magna posuere malesuada.", "Donec pulvinar tincidunt elementum. Sed non commodo urna. Aliquam maximus, nunc nec scelerisque egestas, libero ligula suscipit lorem, id sagittis urna lectus vel nisl. Vivamus auctor mauris sit amet laoreet tempus. Cras porta fermentum nunc nec interdum.", "Integer id nibh volutpat, aliquam ipsum quis, consequat ipsum. In in orci at nisl iaculis tempus. Quisque ut mauris ut magna cursus rhoncus. Praesent facilisis nisl non mi tempor imperdiet.", "Integer sit amet libero diam. Phasellus condimentum facilisis eros et condimentum. Cras elit neque, porta in odio ac, scelerisque vehicula tortor. Mauris condimentum tortor ultricies turpis pretium, vitae congue purus consequat.", "Duis eu porttitor lectus. Vestibulum dignissim ac tellus eget consequat. Proin id urna non mi cursus ultricies nec ac erat. Nullam quis consectetur orci. Etiam accumsan tristique eros, imperdiet tempor tortor commodo vel. Aliquam tincidunt vel odio quis porta. Quisque porta quis neque id faucibus.", "Maecenas dignissim posuere dui vitae maximus. Vivamus quam ipsum, feugiat nec faucibus id, imperdiet sit amet neque.", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec feugiat mi at justo semper volutpat. Vivamus rhoncus libero ut eros ultricies, sodales feugiat velit sagittis. Donec ornare tortor mi, at porta quam bibendum sit amet. In quis ex ipsum.", "Vestibulum in enim ante. Sed scelerisque vitae tortor ut tempus. Aenean lobortis porta condimentum. Aenean condimentum laoreet pulvinar. Suspendisse potenti. Etiam ex risus, pharetra interdum nunc vel, tempus consequat sem.", "Nullam vulputate tincidunt sem, eget pretium dolor elementum id. Quisque enim lorem, porttitor eget vestibulum vitae, malesuada ut dolor. Mauris venenatis laoreet arcu eget hendrerit. Nulla sed finibus tortor, id tincidunt metus. Praesent vulputate nisi vitae ex posuere, quis luctus nibh mattis. Morbi consectetur tortor nec mi aliquet, sit amet tristique nunc dictum. Vivamus lacinia ex eu rutrum lacinia. Aenean ac facilisis dui. Nam consectetur metus sit amet tempus tincidunt. Pellentesque ut sodales nulla, non maximus risus. Integer neque elit, tempus a metus non, scelerisque faucibus risus. Duis imperdiet augue ac tincidunt hendrerit. Maecenas at lacus iaculis, pretium libero sed, fermentum libero. Quisque sollicitudin mauris id mi elementum ultricies. Vestibulum tellus massa, pulvinar ut cursus nec, fringilla eget libero. Vestibulum fringilla turpis dolor, sed sollicitudin sapien pharetra a.", "Cras euismod luctus lacinia. Ut egestas ultrices est, id placerat risus sodales quis.", "Quisque dapibus, ipsum molestie pharetra blandit, arcu ipsum ultricies turpis, eget tincidunt eros risus ac nulla. Phasellus posuere eget velit sit amet vehicula. Integer at vestibulum purus, vitae molestie lorem. Cras ac nisi efficitur turpis ullamcorper sodales lobortis non metus. Nam tempor tellus vel magna posuere malesuada.", "Donec pulvinar tincidunt elementum. Sed non commodo urna. Aliquam maximus, nunc nec scelerisque egestas, libero ligula suscipit lorem, id sagittis urna lectus vel nisl. Vivamus auctor mauris sit amet laoreet tempus. Cras porta fermentum nunc nec interdum.", "Integer id nibh volutpat, aliquam ipsum quis, consequat ipsum. In in orci at nisl iaculis tempus. Quisque ut mauris ut magna cursus rhoncus. Praesent facilisis nisl non mi tempor imperdiet.", "Integer sit amet libero diam. Phasellus condimentum facilisis eros et condimentum. Cras elit neque, porta in odio ac, scelerisque vehicula tortor. Mauris condimentum tortor ultricies turpis pretium, vitae congue purus consequat.", "Duis eu porttitor lectus. Vestibulum dignissim ac tellus eget consequat. Proin id urna non mi cursus ultricies nec ac erat. Nullam quis consectetur orci. Etiam accumsan tristique eros, imperdiet tempor tortor commodo vel. Aliquam tincidunt vel odio quis porta. Quisque porta quis neque id faucibus.", "Maecenas dignissim posuere dui vitae maximus. Vivamus quam ipsum, feugiat nec faucibus id, imperdiet sit amet neque.", ""]
    var ASRType: ASRType
    let transcriptionCollectionView: UICollectionView
    
    // Speech recognition
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    // Apple limits speech recognition to one minute of continous input at a time
    private var recognitionLimiter: Timer?
    private let recognitionLimitSec: Int
    // Measure periods of silence in speech to find where to place line breaks
    private var noSpeechDurationTimer: Timer?
    private let noSpeechDurationLimitSec: Int
    // Detect microphone audio with metering
    private var averagePowerForChannel0: Float = 0.0
    private var averagePowerForChannel1: Float = 0.0
    let LEVEL_LOWPASS_TRIG: Float32 = 0.30
    
    // Client connecting to server
    var client: Client?
    
    init(asrType: ASRType, transcriptionCollectionView: UICollectionView, recognitionLimitSec: Int, noSpeechDurationLimitSec: Int, socketDelegate: SocketEventDelegate) {
        self.ASRType = asrType
        self.transcriptionCollectionView = transcriptionCollectionView
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
        
        // Apple limits speech recognition tasks to 60 seconds at max
        self.recognitionLimitSec = recognitionLimitSec
        // Apple limits task calls to 1000 requests in hour / device
        self.noSpeechDurationLimitSec = noSpeechDurationLimitSec
        
        super.init()
        // Init audio session
        self.initializeAVAudioSession()
        
        self.client = Client(speechHandler: self, uri: "wss://conversation.aalto.fi:80/client/ws/speech", channels: 1, rate: 44100, delegate: socketDelegate)
    }
    
    // MARK: Recording control functions
    func tryRecording() {
        if ASRType == .aalto {
            client?.openSocket()
            do {
                try self.startRecording()
            } catch let error {
                print("There was a problem in starting the recording: \(error.localizedDescription)")
            }
            
        } else if ASRType == .apple {
            do {
                // Ensure previous task is canceled
                if let recognitionTask = recognitionTask {
                    recognitionTask.cancel()
                    self.recognitionTask = nil
                }
                try self.startRecording()
                self.startTimer()
            } catch let error {
                print("There was a problem in starting the recording: \(error.localizedDescription)")
            }
        }
    }
    
    private func startRecording() throws {        
        
        // Initialize recording process
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        let node = audioEngine.inputNode
        
        if ASRType == .aalto {
            let mixer = AVAudioMixerNode()
            audioEngine.attach(mixer)
            audioEngine.connect(node, to: mixer, format: node.outputFormat(forBus: 0))
            let formatIn = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100.0, channels: 1, interleaved: true)!
            let formatOut = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44100.0, channels: 1, interleaved: true)!
            guard let bufferMapper = AVAudioConverter(from: formatIn, to: formatOut) else {
                fatalError("Unable to convert audio format.")
            }
            
            mixer.installTap(onBus: 0, bufferSize: 1024, format: formatIn, block: {
                [weak self] buffer, when in
                
                guard let int16Buffer = AVAudioPCMBuffer(pcmFormat: formatOut, frameCapacity: buffer.frameCapacity) else {
                    //  Returns nil in the following cases:
                    //                    - if the format has zero bytes per frame (format.streamDescription->mBytesPerFrame == 0)
                    //                    - if the buffer byte capacity (frameCapacity * format.streamDescription->mBytesPerFrame)
                    //                    cannot be represented by an uint32_t
                    print("Cannot create PCM buffer.")
                    return
                }
                
                // This is needed because the 'frameLenght' default value is 0 (since iOS 10) and cause the 'convert' call
                // to faile with an error (Error Domain=NSOSStatusErrorDomain Code=-50 "(null)")
                // More here: http://stackoverflow.com/questions/39714244/avaudioconverter-is-broken-in-ios-10
                int16Buffer.frameLength = int16Buffer.frameCapacity
                
                // Convert raw input to int16 (required by the server)
                do {
                    try bufferMapper.convert(to: int16Buffer, from: buffer)
                } catch (let error as NSError) {
                    print(error)
                    return
                }
                

                // Send raw audio to the server
                let channels = UnsafeBufferPointer(start: int16Buffer.int16ChannelData, count: 1)
                let data = Data(bytes: UnsafeMutablePointer<Int16>(channels[0]), count: Int(int16Buffer.frameCapacity * formatOut.streamDescription.pointee.mBytesPerFrame))
                self?.client?.socket?.send(data: data)
                
            })
        } else if ASRType == .apple {
            // Initialize request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest  else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest") }
            recognitionRequest.shouldReportPartialResults = true
            
            // Make a task and send it in a request
            let recordingFormat = node.outputFormat(forBus: 0)
            node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
                [unowned self] (buffer, _) in
                self.recognitionRequest?.append(buffer)
            }
            
            // Prepare new entry in transcription container if necessary
            var lastIndexPath = findLastIndexPath()
            if transcriptions?[lastIndexPath.item].trimmingCharacters(in: .whitespaces) != "" {
                transcriptions?.append("")
                // Reload and scroll must be done here otherwise there is delay
                transcriptionCollectionView.reloadData()
                lastIndexPath = findLastIndexPath()
                self.transcriptionCollectionView.scrollToItem(at: lastIndexPath, at: UICollectionViewScrollPosition.top, animated: true)
            }
            // Handling of recognition results
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: {
                [unowned self] (result, error) in
                if let result = result {
                    self.transcriptions?[lastIndexPath.item] = result.bestTranscription.formattedString
                    self.reloadAndScrollToItem(indexPath: lastIndexPath, animated: true)
                    // Detect silence
                    self.stopNoSpeechDurationTimer()
                    self.startNoSpeechDurationTimer()
                } else if let error = error {
                    print("There was an error transcribing the audio: \(error.localizedDescription)")
                }
            })
        }
        
        // Start recording
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stopRecording() {
        if ASRType == .aalto {
            if audioEngine.isRunning {
                print("Stopping audio engine")
                audioEngine.stop()
            }
        } else if ASRType == .apple {
            if audioEngine.isRunning {
                audioEngine.stop()
                recognitionTask?.finish()
                recognitionRequest?.endAudio()
                self.stopTimer()
                self.stopNoSpeechDurationTimer()
            }
        }
        // End recording
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    // Start timer that counts how much of Apple's one minute recording limit is used
    func startTimer() {
        if recognitionLimiter == nil {
            recognitionLimiter = Timer.scheduledTimer(timeInterval: TimeInterval(self.recognitionLimitSec),
                                                      target: self,
                                                      selector: #selector(recordingEvent),
                                                      userInfo: nil,
                                                      repeats: false)
        }
    }
    // Stop timer started above
    func stopTimer() {
        if recognitionLimiter != nil {
            recognitionLimiter?.invalidate()
            recognitionLimiter = nil
        }
    }
    
    // Start timer that counts the duration of silence
    func startNoSpeechDurationTimer() {
        self.stopTimer()
        if noSpeechDurationTimer == nil {
            noSpeechDurationTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.noSpeechDurationLimitSec),
                                                         target: self,
                                                         selector: #selector(recordingEvent),
                                                         userInfo: nil,
                                                         repeats: false)
        }
    }
    
    // Stop timer started above
    func stopNoSpeechDurationTimer() {
        if noSpeechDurationTimer != nil {
            noSpeechDurationTimer?.invalidate()
            noSpeechDurationTimer = nil
        }
    }
    
    // Handle timer events
    @objc func recordingEvent() {
        // Stop recording if time limit hit
        stopRecording()
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        tryRecording()
    }
    
    // Configure AVAudioSession (how app reacts to notification sounds etc.)
    func initializeAVAudioSession() {
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        try! AVAudioSession.sharedInstance().setActive(false)
    }
    
    func findLastIndexPath() -> IndexPath {
        // Find the IndexPath of last transcription in the list
        return IndexPath.init(item: transcriptionCollectionView.numberOfItems(inSection: 0)-1, section: 0)
    }
    
    func reloadAndScrollToItem(indexPath: IndexPath, animated: Bool) {
        self.transcriptionCollectionView.reloadItems(at: [indexPath])
        self.transcriptionCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: animated)
    }
}
