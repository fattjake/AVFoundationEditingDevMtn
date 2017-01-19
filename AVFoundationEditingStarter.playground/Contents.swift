//: Playground - noun: a place where people can play

import UIKit
import AVFoundation
import PlaygroundSupport

extension CGRect {
    func center() -> CGPoint {
        return CGPoint(x: self.origin.x + self.size.width / 2.0, y: self.origin.y + self.size.height / 2.0)
    }
}



class PlayerController : UIViewController {
    let player = AVPlayer()
    let playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        view.layer.backgroundColor = UIColor.red.cgColor
    }
    
    func play(item : AVPlayerItem) {
        player.replaceCurrentItem(with: item)
        playerLayer.player = player
        
        player.play()
    }
    
    override func viewWillLayoutSubviews() {
        playerLayer.removeFromSuperlayer()
        playerLayer.bounds = view.bounds
        playerLayer.position = view.frame.center()
        view.layer.addSublayer(playerLayer)
    }
}

//let firstURL = Bundle.main.url(forResource: "first", withExtension: "mp4")!
let jawsURL = Bundle.main.url(forResource: "jaws", withExtension: "mp3")!
let playerItem = AVPlayerItem(url: jawsURL)
//let playerItem = AVPlayerItem(url: firstURL)

let playerController = PlayerController()
playerController.view.frame = CGRect(x: 0, y: 0, width: 512, height: 512)
playerController.play(item: playerItem)

PlaygroundPage.current.liveView = playerController.view
