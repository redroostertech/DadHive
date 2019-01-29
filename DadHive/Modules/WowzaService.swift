//
//  WowzaService.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 5/19/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

/*
 import Foundation
import WowzaGoCoderSDK

protocol WowzaServiceDelegate {
    func didBeginBroadcast(success: Bool, message: String)
}

class WowzaService: NSObject {
    static let shared = WowzaService()
    
    private var apiKey: String!
    private var accessKey: String!
    private var goCoder: WowzaGoCoder?
    private var goCoderBroadcastConfig: WowzaConfig!
    private var group: DispatchGroup!
    
    var delegate: WowzaServiceDelegate?
    
    private override init() {
        super.init()
        
        print("Gumbo | Wowza Module Initialized.")
        if let goCoderLicensingError = WowzaGoCoder.registerLicenseKey(wowzaSDKApiKey) {
            print("Gumbo | GoCoder SDK Licensing Error: ", goCoderLicensingError)
        }
        WowzaGoCoder.setLogLevel(.default)
        
        self.apiKey = wowzaSandboxApi
        self.accessKey = wowzaSandboxAccess
        self.group = DispatchGroup()
        
        initializeGoCoder {
            print("Gumbo | Initialized GoCoder Shared Instance")
        }
    }
}

extension WowzaService: WZStatusCallback {
    func onWZStatus(_ status: WZStatus!) {
        switch status.state {
        case .idle:
            print("Gumbo | Idle")
            break
        case .buffering:
            print("Gumbo | Buffering")
            break
        case .ready:
            print("Gumbo | Ready")
            break
        case .running:
            print("Gumbo | Running")
            break
        case .starting:
            print("Gumbo | Starting")
            break
        case .stopping:
            print("Gumbo | Stopping")
            break
        }
    }
    func onWZError(_ status: WZStatus!) {
        print("Gumbo | Streaming Error | Consider showing an alert here.")
    }
}

//  MARK:- Private functions
extension WowzaService {
    private func initializeGoCoder(completion: @escaping ()-> Void) {
        self.goCoder = WowzaGoCoder.sharedInstance()
        completion()
    }
    private func validateGoCoderConfig() -> Bool {
        guard let coder = self.goCoder,
            (coder.config.validateForBroadcast() == nil) else {
            print("Gumbo | Incomplete streaming settings. | Consider showing an alert view.")
            return false
        }
        return true
    }
}

//  MARK:- Public Functions
extension WowzaService {
    func test() { }
    func getKeys() {
        print("Gumbo | Api Key: ", self.apiKey, " Access Key: ", self.accessKey)
    }
    func getCoder() -> WowzaGoCoder? {
        guard let coder = self.goCoder else {
            return nil
        }
        return coder
    }
    func requestPermissions(completion: @escaping ()->Void) {
        self.group.enter()
        WowzaGoCoder.requestPermission(for: .camera, response: { (permission) in
            print("Gumbo | Camera permission is: \(permission == .authorized ? "authorized" : "denied")")
            self.group.leave()
        })
        self.group.enter()
        WowzaGoCoder.requestPermission(for: .microphone, response: { (permission) in
            print("Gumbo | Microphone permission is: \(permission == .authorized ? "authorized" : "denied")")
            self.group.leave()
        })
        self.group.notify(queue: .main) {
            completion()
        }
    }
    func configureStream(usingStreamName name: String, completion: @escaping ()->Void) {
        guard let coder = self.goCoder else {
            completion()
            return
        }
        self.goCoderBroadcastConfig = coder.config
        self.goCoderBroadcastConfig.load(.preset1280x720)
        self.goCoderBroadcastConfig.hostAddress = wowzaHostAddress
        self.goCoderBroadcastConfig.portNumber = wowzaPortNumber
        self.goCoderBroadcastConfig.applicationName = wowzaApplicationName
        self.goCoderBroadcastConfig.streamName = name
        self.goCoderBroadcastConfig.username = wowzaUsername
        self.goCoderBroadcastConfig.password = wowzaPassword
        //  MARK:- Properties set pertaining to stream playback
        self.goCoderBroadcastConfig.audioEnabled = true
        self.goCoderBroadcastConfig.videoEnabled = true
        coder.config = self.goCoderBroadcastConfig

        completion()
    }
    func configureStream(usingConfiguration config: WowzaConfig, completion: @escaping ()->Void) {
        guard let coder = self.goCoder else {
            completion()
            return
        }
        coder.config = config
        completion()
    }
    func beginBroadcast(onView view: UIView) {
        if !validateGoCoderConfig() {
            self.delegate?.didBeginBroadcast(success: false, message: "Gumbo | Configuration is incomplete.")
        } else {
            if self.goCoder!.status.state != WZState.running {
                self.goCoder?.startStreaming(self)
                self.delegate?.didBeginBroadcast(success: true, message: "Gumbo | Everything is good to go and is running.")
            } else {
                self.goCoder!.endStreaming(nil)
                self.delegate?.didBeginBroadcast(success: false, message: "Gumbo | Streaming is not running.")
            }
        }
    }
    //  MARK:- Deprecated >>>>>>>>>>>
    func setupStreamingFrame(onView view: UIView) {
        guard let coder = self.goCoder else {
            return
        }
        coder.cameraView = view
        coder.cameraPreview?.previewGravity = .resizeAspectFill
        coder.cameraPreview?.start()
    }
    //  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
}
 */
