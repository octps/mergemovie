//
//  ViewController.swift
//  mergemovie
//
//  Created by s001 on 2015/05/07.
//  Copyright (c) 2015年 s001. All rights reserved.

import UIKit
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func mergeButton(sender: AnyObject) {
        self.movieMerge()
    }
    
    func movieMerge() {
        var composition = AVMutableComposition()
        var compositionVideoTrack:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        var compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        
        var startTime: CMTime = kCMTimeZero;
        var files = ["sample","sample2"]
        var urls = [NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(files[0], ofType: "mp4")!),
            NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(files[1], ofType: "mp4")!)]
        
        for url in urls {
            var asset:AVAsset = AVAsset.assetWithURL(url) as AVAsset;
            var videoTrack :AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo).first as AVAssetTrack
            var audioTrack :AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeAudio).first as AVAssetTrack
            
            compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: videoTrack as AVAssetTrack, atTime: startTime, error: nil)
            compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: audioTrack as AVAssetTrack, atTime: startTime, error: nil)
            
            startTime = CMTimeAdd(startTime, asset.duration);
        }
        
        var exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        var videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        
        
        //        let outputPath = NSTemporaryDirectory()
        
        let outputPath = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask, true)
        
        //        let outputPath = NSSearchPathForDirectoriesInDomains(
        //            .CachesDirectory,
        //            .UserDomainMask, true)
        
        let completeMovie = outputPath[0].stringByAppendingPathComponent("movie0.mov")
        let completeMovieUrl = NSURL(fileURLWithPath: completeMovie)
        
        exporter.outputURL = completeMovieUrl
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.exportAsynchronouslyWithCompletionHandler({
            switch exporter.status{
            case  AVAssetExportSessionStatus.Failed:
                println("failed \(exporter.error)")
            case AVAssetExportSessionStatus.Cancelled:
                println("cancelled \(exporter.error)")
            default:
                println("complete")
                let assetsLib = ALAssetsLibrary()
                assetsLib.writeVideoAtPathToSavedPhotosAlbum(exporter.outputURL, completionBlock: {
                    (nsurl, error) -> Void in
                })
                //                削除機能
                //                NSFileManager.defaultManager().removeItemAtPath(completeMovie, error: nil)
                
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
