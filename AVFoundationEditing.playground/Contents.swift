//: Playground - noun: a place where people can play

import UIKit
import AVFoundation
import PlaygroundSupport

extension CGRect {
    func center() -> CGPoint {
        return CGPoint(x: self.origin.x + self.size.width / 2.0, y: self.origin.y + self.size.height / 2.0)
    }
}

func getInputAssets() -> [AVURLAsset] {
    let assets = [AVURLAsset]()
    guard let firstURL = Bundle.main.url(forResource: "first", withExtension: "mp4") else { return assets }
    guard let secondURL = Bundle.main.url(forResource: "artisto", withExtension: "mp4") else { return assets }
    guard let thirdURL = Bundle.main.url(forResource: "third", withExtension: "mp4") else { return assets }

    let firstAsset = AVURLAsset(url: firstURL)
    let secondAsset = AVURLAsset(url: secondURL)
    let thirdAsset = AVURLAsset(url: thirdURL)
    
    return [firstAsset, secondAsset, thirdAsset]
}

func getPrimaryVideo(asset : AVURLAsset) -> AVAssetTrack? {
    let tracks = asset.tracks(withMediaType: AVMediaTypeVideo)
    return tracks.first
}

func getJawsMusic() -> AVAssetTrack? {
    guard let url = Bundle.main.url(forResource: "jaws", withExtension: "mp3") else { return nil }
    let asset = AVURLAsset(url: url)
    return asset.tracks(withMediaType: AVMediaTypeAudio).first
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
//let jawsURL = Bundle.main.url(forResource: "jaws", withExtension: "mp3")!
////let playerItem = AVPlayerItem(url: jawsURL)
//let playerItem = AVPlayerItem(url: firstURL)

//func createMutableComposition(videoTracks : [AVAssetTrack], audioTrack : AVAssetTrack?) -> AVMutableComposition {
//    let composition = AVMutableComposition()
//    let firstVideoCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
//    
//    let firstVideoTrack = videoTracks[0]
//    let start = kCMTimeZero
//    let duration = CMTime(seconds: 1.0, preferredTimescale: 600)
//    let timeRange = CMTimeRange(start: start, duration: duration)
//    
//    do {
//        try firstVideoCompositionTrack.insertTimeRange(timeRange, of: firstVideoTrack, at: kCMTimeZero)
//    } catch let e {
//        print(e)
//    }
//    
//    return composition
//}

func createMutableComposition(videoTracks : [AVAssetTrack], audioTrack : AVAssetTrack?, totalDuration: CMTime) -> AVMutableComposition {
    let composition = AVMutableComposition()
    
    let firstVideoCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
    //let secondVideoCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    var trackStartTime = kCMTimeZero
    var trackEndTime = CMTime(seconds: 1.5, preferredTimescale: 600)
    
    var projectStartTime = kCMTimeZero
    
    var timeRange = CMTimeRange(start: trackStartTime, end: trackEndTime)
    
    var i = 0
    
    while CMTimeGetSeconds(projectStartTime) < CMTimeGetSeconds(totalDuration) {
        let videoTrack = videoTracks[i % 3]
        i += 1
        do {
            try firstVideoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: projectStartTime)
//            try firstVideoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: startTime)
            let duration = CMTimeSubtract(trackEndTime, trackStartTime)
            trackStartTime = CMTimeAdd(trackStartTime, duration)
            trackEndTime = CMTimeAdd(trackEndTime, duration)
            
            projectStartTime = CMTimeAdd(projectStartTime, duration)
            //looping forever
            if CMTimeGetSeconds(trackEndTime) > 10.0 {
                trackStartTime = kCMTimeZero
                trackEndTime = CMTimeAdd(trackStartTime, duration)
            }
            //looping forever
            
            timeRange = CMTimeRange(start: trackStartTime, end: trackEndTime)
        } catch let e {
            print(e)
        }
    }
    
    //add music
    if let jaws = getJawsMusic() {
    let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
    timeRange = CMTimeRange(start: CMTime(seconds: 15.0, preferredTimescale: 600), duration: totalDuration)
        do {
            try audioCompositionTrack.insertTimeRange(timeRange, of: jaws, at: kCMTimeZero)
        } catch let e {
            print(e)
        }
    }
    
    return composition
}


let assets = getInputAssets()
let firstVideoTracks = assets.flatMap { (asset) -> AVAssetTrack? in
    return getPrimaryVideo(asset: asset)
}

let composition = createMutableComposition(videoTracks: firstVideoTracks, audioTrack: nil, totalDuration: CMTime(seconds: 200.0, preferredTimescale: 600))
let playerItem = AVPlayerItem(asset: composition)

let playerController = PlayerController()
playerController.view.frame = CGRect(x: 0, y: 0, width: 512, height: 512)
playerController.play(item: playerItem)

PlaygroundPage.current.liveView = playerController.view
