//
//  ViewController.swift
//  mergemovie
//
//  Created by s001 on 2015/05/07.
//  Copyright (c) 2015年 s001. All rights reserved.

import UIKit
import AVFoundation
import AssetsLibrary
import MobileCoreServices

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    @IBAction func mergeButton(sender: AnyObject) {
        self.movieMerge()
    }
    
    @IBAction func movieSelect(sender: AnyObject) {
        self.movieSelct()
    }
    
    //　カメラロールから動画の選択
    func movieSelct() {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            UIAlertView(title: "警告", message: "Photoライブラリにアクセス出来ません", delegate: nil, cancelButtonTitle: "OK").show()
        } else {
            var imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePickerController.mediaTypes = NSArray(object: kUTTypeMovie)
            imagePickerController.allowsEditing = false
            imagePickerController.delegate = self
            self.presentViewController(imagePickerController,animated:true ,completion:nil)
        }
    }
    
    func showMovie(movieUrl:NSURL) {
        var fileURL = movieUrl
        var avAsset = AVURLAsset(URL: fileURL, options: nil)
        
//        var playerItem : AVPlayerItem!
//        var videoPlayer : AVPlayer!
        var playerItem : AVPlayerItem = AVPlayerItem(asset: avAsset)
        var videoPlayer : AVPlayer! = AVPlayer(playerItem: playerItem)
        var videoPlayerView = AVPlayerView(frame: self.view.bounds)
        
        var layer = videoPlayerView.layer as AVPlayerLayer
        layer.videoGravity = AVLayerVideoGravityResizeAspect
        layer.player = videoPlayer
        
        self.view.layer.addSublayer(layer)
    }

    // カメラロールから選択後、選択した動画のurlを取得、showMovieにurlを渡す
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        var url = info[UIImagePickerControllerMediaURL] as NSURL!
        var pickedURL:NSURL = info[UIImagePickerControllerReferenceURL] as NSURL
        self.dismissViewControllerAnimated(true, completion: nil)
        showMovie(pickedURL)
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
        
        
        let outputPath = NSTemporaryDirectory()
        
        let completeMovie = outputPath.stringByAppendingPathComponent("movie.mov")
        let completeMovieUrl = NSURL(fileURLWithPath: completeMovie)

        if (NSFileManager.defaultManager().fileExistsAtPath(completeMovie)) {
            NSFileManager.defaultManager().removeItemAtPath(completeMovie, error: nil)
        }

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
                
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // レイヤーをAVPlayerLayerにする為のラッパークラス.
    class AVPlayerView : UIView{
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        override class func layerClass() -> AnyClass{
            return AVPlayerLayer.self
        }
        
    }
}
