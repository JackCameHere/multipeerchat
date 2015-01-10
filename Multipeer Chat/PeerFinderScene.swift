//
//  PeerFinderScene.swift
//  Multipeer Chat
//
//  Created by Jack Chong on 1/10/15.
//  Copyright (c) 2015 Jack. All rights reserved.
//

//import Foundation
import UIKit
import MultipeerConnectivity

class PeerFinderScene: NSObject, MCSessionDelegate {
    @IBOutlet weak var chatView: UITextView!
    
    let serviceType = "LCOC-Chat"
    
    // set variables
    var browser:MCBrowserViewController!
    var advertiser:MCAdvertiserAssistant!
    var session:MCSession!
    var peerID: MCPeerID!
    
    func setupPeerWithDisplayName(displayName:String) {
        peerID = MCPeerID(displayName: displayName)
    }
    
    func setupSession() {
        session = MCSession(peer: peerID);
        session.delegate = self
    }
    
    func setupBrowser() {
        browser = MCBrowserViewController(serviceType: serviceType, session: session)
    }
    
    func advertiseSelf(advertise:Bool) {
        if advertise{
            advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session);
            advertiser!.start();
        }else{
            advertiser!.stop();
            advertiser = nil;
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID) {
        // called when a peer sends an NSData to us
        
        // needs to run on main queue
        //dispatch_async(dispatch_get_main_queue()) {
            //var msg = NSString(data:data, encoding: NSUTF8StringEncoding)
            
            //ViewController.updateChat(msg!, fromPeer: peerID)
        
        
            let userInfo = ["data":data, "peerID":peerID]
            dispatch_async(dispatch_get_main_queue(), {() -> Void in NSNotificationCenter.defaultCenter().postNotificationName("MPC_DidReceiveDataNotification", object: nil, userInfo: userInfo)
            
        })
    }
    
    // The following methods do nothing, but the MCSessionDelegate protocol
    // requires that we implement them.
    func session(session: MCSession!,
        didStartReceivingResourceWithName resourceName: String!,
        fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!)  {
            
            // Called when a peer starts sending a file to us
    }
    
    func session(session: MCSession!,
        didFinishReceivingResourceWithName resourceName: String!,
        fromPeer peerID: MCPeerID!,
        atURL localURL: NSURL!, withError error: NSError!)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!,
        withName streamName: String!, fromPeer peerID: MCPeerID!)  {
            // Called when a peer establishes a stream with us
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!,
        didChangeState state: MCSessionState)  {
            // Called when a connected peer changes state (for example, goes offline)
            
    }

    /*
    self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
    self.session = MCSession(peer: peerID)
    self.session.delegate = self
    
    // create the browser viewcontroller with a unique service name
    self.browser = MCBrowserViewController(serviceType: serviceType, session: self.session)
    
    self.browser.delegate = self
    
    self.assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
    
    // tell the assistant to start advertising the chat
    self.assistant.start()
    */
}