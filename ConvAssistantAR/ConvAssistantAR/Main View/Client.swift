//
//  Client.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 11/07/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import Foundation
// Web socket implementation downloaded with cocoapods (https://github.com/tidwall/SwiftWebSocket)
import SwiftWebSocket

// Structs for parsing the JSONs coming from the server (nonessential elements are skipped in codingkeys)
struct ServerResponse: Decodable {
    let status: Int
    var id: String?
    var totalLength: Double?
    var segment: Int?
    var result: Result?
    var segmentLength, segmentStart: Double?
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case result
    }
    
    struct Result: Decodable {
        let final: Bool
        let hypotheses: [Hypotheses]
        
        enum CodingKeys: String, CodingKey {
            case final
            case hypotheses
        }
    }
    
    struct Hypotheses: Decodable {
        var confidence, likelihood: Double?
        let transcript: String
        
        private enum CodingKeys: String, CodingKey {
            case transcript
        }
    }
}

protocol SocketEventDelegate: AnyObject {
    func socketClosed()
}

class Client: NSObject {
    
    let speechHandler: SpeechRecognitionHandler
    let uri: String?
    var rate: Int = 44100
    var channels: Int = 1
    var receivedNoSpeechFromServer: Bool = false
    let socket: WebSocket?
    let delegate: SocketEventDelegate?
    
    init(speechHandler: SpeechRecognitionHandler, uri: String, channels: Int, rate: Int, delegate: SocketEventDelegate) {
        self.speechHandler = speechHandler
        self.uri = uri
        self.channels = channels
        self.rate = rate
        self.socket = WebSocket()
        self.delegate = delegate
        
        self.socket?.allowSelfSignedSSL = true
        
        super.init()
        
        self.setUpSocket()
    }
    
    private func setUpSocket() {
        if let socket = socket {
            socket.event.open = {
                print("Socket opened!")
            }
            socket.event.close = { code, reason, clean in
                if self.receivedNoSpeechFromServer {
                    self.receivedNoSpeechFromServer = false
                    sleep(1) // Give server time to reopen socket
                    socket.open()
                    print("Reopening socket")
                    return
                }
                self.speechHandler.stopRecording()
                self.delegate?.socketClosed()
                print("Socket closed with code \(code) and reason: \(reason)")
            }
            socket.event.error = { error in
                print("Socket error: \(error)")
            }
            socket.event.message = { message in
                if let text = message as? String {
                    self.handleMessage(text)
                }
            }
        }
    }
    
    func openSocket() {
        if let socket = socket, let uri = uri {
            socket.open(formURL(uri: uri))
        }
    }
    
    func closeSocket() {
        if let socket = socket {
            socket.send("EOS")
            print("Socket state: \(socket.readyState)")
        }
    }
    
    
    func handleMessage(_ jsonString:String) {
        if let data = jsonString.data(using: .utf8) {
            let response: ServerResponse?
            do {
                response = try JSONDecoder().decode(ServerResponse.self, from: data)
                if response?.status == 0 {
                    let lastIndexPath = speechHandler.findLastIndexPath()
                    if let result = response?.result {
                        let transcript = cleanTranscript(transcript: result.hypotheses[0].transcript)
                        if result.final {
                            // Process transcripts                            
                            speechHandler.transcriptions?[lastIndexPath.item] = transcript
                            speechHandler.reloadAndScrollToItem(indexPath: lastIndexPath, animated: true)
                            speechHandler.transcriptions?.append("")
                            speechHandler.transcriptionCollectionView.insertItems(at: [IndexPath(item: speechHandler.transcriptionCollectionView.numberOfItems(inSection: 0), section: 0)])
                        } else {
                            // Process transcripts
                            speechHandler.transcriptions?[lastIndexPath.item] = transcript
                            speechHandler.reloadAndScrollToItem(indexPath: lastIndexPath, animated: true)
                        }
                        
                    }
                } else if response?.status == 1 {
                    print("NO_SPEECH signal received from the server")
                    receivedNoSpeechFromServer = true
                } else if response?.status == 9 {
                    print("No worker available")
                    sleep(1)
                    socket?.open()
                } else {
                    print("Received error from server (status: \(String(describing: response?.status)))")
                    if let message = response?.message {
                        print("Server error message: \(message)")
                    }
                }
            } catch let error {
                print("Error with JSON: \(error)")
            }
        }
    }
    
    // Clean kaldi output from special characters
    private func cleanTranscript(transcript: String) -> String {
        return transcript.replacingOccurrences(of: "+ +", with: "")
                         .replacingOccurrences(of: "+", with: "")
                         .replacingOccurrences(of: ".", with: "")
    }
    
    private func formURL(uri: String) -> String {
        // Add content-type request parameter after uri
        let content_type = "audio/x-raw, layout=(string)interleaved, rate=(int)\(rate), format=(string)S16LE, channels=(int)\(channels)"
        let customAllowedSet =  NSCharacterSet(charactersIn:",()=\"#%/<>?@\\^`{|}").inverted
        let encodedString = content_type.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!.replacingOccurrences(of: " ", with: "+")
        
        return "\(uri)?content-type=\(encodedString)"
    }
}
