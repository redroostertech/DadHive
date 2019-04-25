//
//  WowzaConfigurationLayer.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 5/20/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

/*
import Foundation
import WowzaGoCoderSDK
import Player

class WowzaConfigurationLayer {
    private var goCoderBroadcastConfig: WowzaConfig!
    var hostAddress: String!
    var portNumber: UInt!
    var applicationName: String!
    var streamName: String!
    init(usingCoder coder: WowzaGoCoder, withStreamName name: String) {
        
        //  MARK:- Provided in Configs.swift
        self.hostAddress = wowzaHostAddress
        self.portNumber = wowzaPortNumber
        self.applicationName = wowzaApplicationName
        
        self.streamName = name
        
        self.goCoderBroadcastConfig = coder.config
        self.goCoderBroadcastConfig.load(.preset1280x720)
        self.goCoderBroadcastConfig.hostAddress = self.hostAddress
        self.goCoderBroadcastConfig.portNumber = self.portNumber
        self.goCoderBroadcastConfig.applicationName = self.applicationName
        self.goCoderBroadcastConfig.streamName = self.streamName
        self.goCoderBroadcastConfig.username = wowzaUsername
        self.goCoderBroadcastConfig.password = wowzaPassword
        
        //  MARK:- Properties set pertaining to stream playback
        self.goCoderBroadcastConfig.audioEnabled = true
        self.goCoderBroadcastConfig.videoEnabled = true
        
        coder.config = self.goCoderBroadcastConfig
    }
}

//  MARK:- Public Functions
extension WowzaConfigurationLayer {
    func getGoCoderBroadcastConfig() -> WowzaConfig {
        return self.goCoderBroadcastConfig
    }
}

class StreamPlayerConfigurationlayer: NSObject {
    var player: Player!
    private override init() {
        print("Gumbo | Stream Player Configuration Layer is initialized.")
        self.player = Player()
    }
    convenience init(_ nilValue: String? = nil) {
        self.init()
        self.player.playerDelegate = self
        self.player.playbackDelegate = self
    }
    func startPlayer(usingViewController viewcontroller: UIViewController,
                     usingStreamConfigurationLayer configurationLayer: WowzaConfigurationLayer) {
        self.player.view.frame = viewcontroller.view.bounds
        viewcontroller.addChildViewController(self.player)
        viewcontroller.view.addSubview(self.player.view)
        self.player.didMove(toParentViewController: viewcontroller)
        
        guard let hostAddress = configurationLayer.hostAddress,
            let portNumber = configurationLayer.portNumber,
            let applicationName = configurationLayer.applicationName,
            let streamName = configurationLayer.streamName else {
                print("Gumbo | Unable to generate url from configuration layer")
                return
        }
        
        let urlString = "http://\(hostAddress):\(portNumber)/\(applicationName)/\(streamName)/playlist.m3u8"
        
        guard let url = URL(string: urlString) else {
            print("Gumbo | Unable to create url.")
            return
        }
        
        self.player.url = url
        self.player.playFromBeginning()
    }
}

extension StreamPlayerConfigurationlayer:
    PlayerDelegate,
    PlayerPlaybackDelegate
{
    func playerReady(_ player: Player) {
        //  Do nothing for now
        print("Gumbo | Player ready.")
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        //  Do nothing for now
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        //  Do nothing for now
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        //  Do nothing for now
    }
    
    func playerCurrentTimeDidChange(_ player: Player) {
        //  Do nothing for now
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
        //  Do nothing for now
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        //  Do nothing for now
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        //  Do nothing for now
    }
    
    
}
 */
