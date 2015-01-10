//
//  ViewController.swift
//  Multipeer Chat
//
//  Created by Jack Chong on 1/10/15.
//  Copyright (c) 2015 Jack. All rights reserved.
//


import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate {
    
    @IBOutlet weak var chatView: UITextView!
    @IBOutlet weak var messageField: UITextField!
    
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        appDelegate.peerFinder.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        
        appDelegate.peerFinder.setupSession()
        
        appDelegate.peerFinder.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification", name: "MPC_DidReceiveDataNotification", object: nil);
        
    }
    
    @IBAction func sendChat(sender: AnyObject) {
        // bundle up the text in the message field and sent it to connected peers
        let msg = self.messageField.text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        var error : NSError?
        
        var session = appDelegate.peerFinder.session
        
        session.sendData(msg, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: &error)
        
        if error != nil {
            print("Error sending data: \(error?.localizedDescription)")
        }
        
        self.updateChat(self.messageField.text, fromPeer: appDelegate.peerFinder.peerID)
        
        self.messageField.text = ""
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        let msg = NSDictionary(dictionary: notification.userInfo!);
    
        let raw_msg = msg.objectForKey("data") as NSString
        let peerID = msg.objectForKey("peerID") as MCPeerID
            
        //var msg = NSString(raw_msg, encoding: NSUTF8StringEncoding)
            
        self.updateChat(raw_msg, fromPeer: peerID)
        
    }
    
    func updateChat(text: String, fromPeer peerID: MCPeerID) {
        // appends text to chat view
        
        // if peer ID is local device's peer ID, then show name as "me"
        var name:String
        
        switch peerID {
        case appDelegate.peerFinder.peerID:
            name="Me"
        default:
            name=peerID.displayName
        }
        
        // add name to the message and display it
        let message = "\(name): \(text)\n"
        self.chatView.text = self.chatView.text + message
        
    }
    
    @IBAction func showBrowser(sender: AnyObject) {
        // show the browser view controller
        //self.presentViewController(self.browser, animated:true, completion:nil)
        if appDelegate.peerFinder.session != nil {
            appDelegate.peerFinder.setupBrowser()
            appDelegate.peerFinder.browser.delegate = self
            
            self.presentViewController(appDelegate.peerFinder.browser, animated:true, completion:nil)
        }
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        // called when the browser view controller is dismissed (ie the done button is tapped)
        appDelegate.peerFinder.browser.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        // called when the controller is cancelled
        appDelegate.peerFinder.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
}


/*
class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {

    let serviceType = "LCOC-Chat"
    
    // set variables
    var browser:MCBrowserViewController!
    var assistant:MCAdvertiserAssistant!
    var session:MCSession!
    var peerID: MCPeerID!
    
    @IBOutlet weak var chatView: UITextView!
    @IBOutlet weak var messageField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // create the browser viewcontroller with a unique service name
        self.browser = MCBrowserViewController(serviceType: serviceType, session: self.session)
        
        self.browser.delegate = self
        
        self.assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
        
        // tell the assistant to start advertising the chat
        self.assistant.start()
        
    }

    @IBAction func sendChat(sender: AnyObject) {
        // bundle up the text in the message field and sent it to connected peers
        let msg = self.messageField.text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        var error : NSError?
        
        self.session.sendData(msg, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: &error)
        
        if error != nil {
            print("Error sending data: \(error?.localizedDescription)")
        }
        
        self.updateChat(self.messageField.text, fromPeer: self.peerID)
        
        self.messageField.text = ""
    }
    
    func updateChat(text: String, fromPeer peerID: MCPeerID) {
        // appends text to chat view
        
        // if peer ID is local device's peer ID, then show name as "me"
        var name:String
        
        switch peerID {
        case self.peerID:
            name="Me"
        default:
            name=peerID.displayName
        }
        
        // add name to the message and display it
        let message = "\(name): \(text)\n"
        self.chatView.text = self.chatView.text + message
        
    }
    
    @IBAction func showBrowser(sender: AnyObject) {
        // show the browser view controller
        self.presentViewController(self.browser, animated:true, completion:nil)
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        // called when the browser view controller is dismissed (ie the done button is tapped)
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        // called when the controller is cancelled
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        // called when a peer sends an NSData to us
        
        // needs to run on main queue
        dispatch_async(dispatch_get_main_queue()) {
            var msg = NSString(data:data, encoding: NSUTF8StringEncoding)
            
            self.updateChat(msg!, fromPeer: peerID)
            
        }
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
}
*/
