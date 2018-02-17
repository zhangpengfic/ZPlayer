//
//  VedioPlayerView.swift
//  MMFinancialSchool
//
//  Created by Alfred on 2017/8/2.
//  Copyright © 2017年 linweibiao. All rights reserved.
//

import UIKit
//import AVKit
import AVFoundation

class VedioPlayerView: UIView {
    
    var playSeekTimeDic:NSMutableDictionary!
    
    var video_idLog:String! = ""//日志里记录的video_id

    
    var url:String! = "" {
        didSet{
            choose = PlayWay.online
            videoPlay()
        }
    }
    var filePath = "" {
        didSet{
            choose = PlayWay.local
            videoPlay()
        }
    }
    
    var choose = PlayWay.online
    
    
    var fatherView:UIView! {
        didSet{
            fatherView.addSubview(self)
            self.frame = fatherView.bounds
            coverImageView.frame = fatherView.bounds
            
        }
    }
    
    override func awakeFromNib() {
        let dic = UserDefaults.standard.object(forKey: "playSeekTimeDic") as? NSMutableDictionary ?? [:]
        let mutableDic:NSMutableDictionary = [:]
        mutableDic.setDictionary(dic as! [AnyHashable : Any])
        playSeekTimeDic = mutableDic
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate(notification:)), name: .UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoPlayEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)//静音模式下播放声音
        
    }
    
    
    var holdImage:UIImage! {
        
        get{
            return netWaitingImageView.image
        }
        set{
            netWaitingImageView.image = newValue
            if fatherView != nil {
                fatherView.addSubview(netWaitingImageView)
                netWaitingImageView.frame = fatherView.bounds
            }
        }
    }
    
    @IBOutlet weak var coverImageView: UIImageView!{
        didSet{
            coverImageView.contentMode = .scaleToFill
            coverImageView.frame = CGRect(x: 0, y: 0, width: iPhoneWidth, height: iPhoneWidth * 400 / 750)
        }
    }
    
    @IBOutlet weak var netWaitingImageView: UIImageView!
    
    
    
    @IBOutlet weak var controlVView: ControlVView!{
        didSet{
            controlVView.alpha = CGFloat(0)
        }
    }
    
    @IBOutlet weak var controlHView: ControlHView!{
        didSet{
            
            controlHView.isHidden = true
            controlHView.alpha = CGFloat(0)
        }
    }
    
    
    @IBOutlet weak var timeSheetView: TimeSheetView!{
        didSet{
            timeSheetView.layer.cornerRadius = 10
            timeSheetView.isHidden = true
            timeSheetView.frame = CGRect(center: CGPoint(x:iPhoneHeigt / 2,y: iPhoneWidth / 2), size: CGSize(width: 120, height: 60))
        }
    }
    
    
    var playerLayer:AVPlayerLayer!
    var playerPub:AVPlayer!{
        didSet{
            playerLayer = AVPlayerLayer.init(player: self.playerPub)
            playerLayer.frame = self.bounds
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.layer.addSublayer(playerLayer)
            
            self.addSubview(controlVView)
            self.addSubview(controlHView)
        }
    }
    
    var updateSiderValue = true
    @IBAction func sliderTouchDown(_ sender: UISlider) {
        updateSiderValue = false
    }
    
    @IBAction func sliderTouchOut(_ sender: UISlider) {
        
        //当视频状态为AVPlayerStatusReadyToPlay时才处理
        if playerPub.status == AVPlayerStatus.readyToPlay{
            let duration = sender.value * Float(CMTimeGetSeconds(playerPub.currentItem!.duration))
            let seekTime = CMTimeMake(Int64(duration), 1)
            playerPub.seek(to: seekTime, completionHandler: {
                //                [weak me = self]
                (_) in
                self.updateSiderValue = true
                
            })
        }
    }
    
    @IBAction func fullScreenButtonClicked(_ sender: UIButton) {
        
        if UIDevice.current.orientation == UIDeviceOrientation.portrait {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            
            sender.isSelected = true
            
        }else{
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            
            sender.isSelected = false
            
        }
        
    }
    
    func videoPlay() -> () {
        
        
        if (playerPub != nil){
            playerPub.pause()
        }
        
        if playerPub != nil{
            playerPub.removeObserver(self, forKeyPath: "status")
            playerPub.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        }
        
        switch choose {
        case .local:
            playerPub = AVPlayer.init(url: URL.init(fileURLWithPath: filePath))
        case .online:
            
            playerPub = AVPlayer.init(url: URL.init(string: url)!)
            
        }
        
        let seconds = playSeekTimeDic.value(forKey: video_idLog) as? Float ?? 0.0
        let cmTime = CMTime.init(seconds: Double(seconds), preferredTimescale: 1)
        
        playerPub.rate = 1.50//加在KVO时候才生效
        playerPub.pause()
        playerPub.seek(to: cmTime)
       
        
//        
//        controlVView.progressView.progress = 0
//        controlHView.progressView.progress = 0
//        controlVView.videoPlaySlider.value = 0
//        controlHView.videoPlaySlider.value = 0
//        
        
        
        
        //获取字幕
        let item = playerPub.currentItem
        let asset = item?.asset
        let group = asset?.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible)
        if group != nil {
            for item in (group?.options)! {
                Debug.log(item)
            }
            let locale = Locale.init(identifier: "zh_CN")///en_US
            
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: (group?.options)!, with: locale)
            item?.select(options.first, in: group!)
        }
        
        
        
        //监听状态改变
        playerPub.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        //监听缓冲进度改变
        playerPub.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        
        playObserver = playerPub.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 2), queue: DispatchQueue.main) { [weak me = self] (time) in
            if me != nil {
                let currentTime = me?.playerPub.currentTime()
                let totalTime = me?.playerPub.currentItem?.duration
                let progress = CMTimeGetSeconds(currentTime!) / CMTimeGetSeconds(totalTime!)
                let text = "\(formatPlayTime(CMTimeGetSeconds(currentTime!)))/\(formatPlayTime(CMTimeGetSeconds(totalTime!)))"
                Debug.log(Float(progress))
                
                DispatchQueue.main.async {
                    let boollet = (me?.updateSiderValue)!
                    if boollet != nil {
                        if (me?.updateSiderValue)! {
                            if !(me?.isDragged)! {
                                me?.controlVView.videoPlaySlider.value = Float(progress)
                                me?.controlHView.videoPlaySlider.value = Float(progress)
                                me?.controlVView.timelabel.text = text
                                me?.controlHView.timelabel.text = text
                                
                            }
                            
                        }
                    }
                    
                }
                
            }
            
            
            
            
            
        }
    }
    
    //MARK: - notification#Selector
    var backPlayModel = true
    @objc func appWillResignActive(){
        Debug.log("appWillResignActive")
        if backPlayModel {
            playerLayer.player = nil
        }else{
            playerPub.pause()
        }
    }
    @objc func appDidBecomeActive() {
        Debug.log("appDidBecomeActive")
        if backPlayModel {
            playerLayer.player = playerPub
        }else{
            // playerPub.play()
        }
    }
    @objc func deviceDidRotate(notification:NSNotification){
        
        if UIDevice.current.orientation.rawValue == 5 || UIDevice.current.orientation.rawValue == 6{
            return
        }
        
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation){
            videoViewHStatus()
        }else{
            videoViewVStatus()
        }
        
        Debug.log(UIDevice.current.orientation.rawValue)
        
    }
    
    let HorizontalFrame = CGRect(x: 0, y: 0, width: iPhoneHeigt, height: iPhoneWidth)
    let VerticalFrame = CGRect(x: 0, y: 0, width: iPhoneWidth, height: iPhoneWidth * 40 / 75)
    
    func videoViewVStatus() {
        controlVView.fullScreenButton.isSelected = false
        self.removeFromSuperview()
        timeSheetView.removeFromSuperview()
        self.frame = VerticalFrame
        if playerLayer != nil{
            playerLayer.frame = self.bounds
            controlVView.frame = playerLayer.frame
        }
        if fatherView != nil {
            fatherView.addSubview(self)
        }
        controlVView.isHidden = false
        controlHView.isHidden = true
        // UIApplication.shared.isStatusBarHidden = false
        
    }
    
    func videoViewHStatus() {
        controlVView.fullScreenButton.isSelected = true
        self.removeFromSuperview()
        self.frame = HorizontalFrame
        playerLayer.frame = self.bounds
        
        if (UIApplication.shared.delegate as! AppDelegate).allowRotation == true{
            UIApplication.shared.keyWindow?.addSubview(timeSheetView)
            UIApplication.shared.keyWindow?.insertSubview(self, belowSubview: timeSheetView)
//            UIApplication.shared.keyWindow?.insertSubview(self, belowSubview: BrightnessView.shared())
//            UIApplication.shared.keyWindow?.insertSubview(timeSheetView, belowSubview: BrightnessView.shared())
        }
        
        controlHView.frame = playerLayer.frame
        controlVView.isHidden = true
        controlHView.isHidden = false
        //UIApplication.shared.isStatusBarHidden = true
        
    }
    
    var indexPath = 0
    var playEndBlock:((Int)->())!
    @objc func videoPlayEnd(){
        Debug.log("videoPlayEnd")
        if playEndBlock != nil {
            
            if UIDeviceOrientationIsLandscape(UIDevice.current.orientation){
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                
            }
            playEndBlock(indexPath + 1)//下一个视频
        }
    }
    
    
    //MARK:-UIPanGestureRecognizer
    var lastVolume:Float = 0
    var lastBrightness:Float = Float(UIScreen.main.brightness)
    var panDirection:PanDirection = .HorizontalMoved
    var isVolume = true
    @IBAction func controlViewPanned(_ sender: UIPanGestureRecognizer) {
        
        
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation){
            
            
        }else{//横
            
            let location = sender.location(in: controlHView)
            let velocty = sender.velocity(in: controlHView)
            
            switch sender.state {
            case .began:
                let x = fabs(velocty.x)
                let y = fabs(velocty.y)
                if (x>y) {//水平移动
                    Debug.log("水平移动began")
                    panDirection = .HorizontalMoved
                    sumValue = CGFloat(controlHView.videoPlaySlider.value)
                    timeSheetView.isHidden = false
                }else if (x<y) {//垂直移动
                    Debug.log("垂直移动began")
                    panDirection = .VerticalMoved
                    if location.x > iPhoneHeigt / 2 {
                        Debug.log("音量")
                        isVolume = true
                    }else{
                        Debug.log("亮度")
                        isVolume = false
                    }
                }
                break
            case .changed:
                switch panDirection {
                case .HorizontalMoved:
                    Debug.log("水平移动changed")
                    horizontalMoved(value: velocty.x)
                    break
                case .VerticalMoved:
                    Debug.log("垂直移动changed")
                    verticalMoved(value: velocty.y)
                    break
                }
            case .ended:
                switch panDirection {
                case .HorizontalMoved:
                    Debug.log("水平移动ended")
                    let sliderTime = CGFloat(controlHView.videoPlaySlider.value) * CGFloat(CMTimeGetSeconds(playerPub.currentItem!.duration))
                    Debug.log(sliderTime)
                    let seekTime = CMTimeMake(Int64(sliderTime), 1)
                    playerPub.seek(to: seekTime)
                    timeSheetView.isHidden = true
                    isDragged = false
                    sumValue = 0
                    break
                case .VerticalMoved:
                    Debug.log("垂直移动ended")
                    break
                }
            default:
                break
            }
            
        }
    }
    var isDragged = false
    var sumValue:CGFloat = 0.0
    func horizontalMoved(value:CGFloat) {
        sumValue += value/50000
        controlHView.videoPlaySlider.value = Float(sumValue)
        
        if value > 0 {
            timeSheetView.timeSheetImage.image = UIImage(named: "progress_icon_r")
        }else{
            timeSheetView.timeSheetImage.image = UIImage(named: "progress_icon_l")
        }
        
        isDragged = true
        
        let totalTime = NSInteger(CMTimeGetSeconds(playerPub.currentItem!.duration))
        let currentTime = NSInteger(Float(controlHView.videoPlaySlider.value) * Float(CMTimeGetSeconds(playerPub.currentItem!.duration)))
        timeSheetView.timeSheetLabel.text = "\(getTimeText(time: currentTime))/\(getTimeText(time: totalTime))"
        
    }
    
    
    
    func verticalMoved(value:CGFloat) {
        if isVolume {//声音
            let volumeDelta = value / 10000
            let newVolume = lastVolume - Float(volumeDelta)
            SystemVolume.instance.setLastVolume(value: newVolume)
            lastVolume = newVolume
        }else{//亮度
            let volumeDelta = value / 10000
            let newVolume = lastBrightness - Float(volumeDelta)
            UIScreen.main.brightness = CGFloat(newVolume)
            lastBrightness = newVolume
//            Debug.log(BrightnessView.shared().frame)
        }
        
    }

    
    
    //MARK:- KVO
    
    
    func avalableDurationWithplayerItem()->TimeInterval{
        //        guard let loadedTimeRanges = playerPub?.currentItem?.loadedTimeRanges,let first = loadedTimeRanges.first else {fatalError()}
        
        if let first = playerPub?.currentItem?.loadedTimeRanges.first {
            let timeRange = first.timeRangeValue
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSecound = CMTimeGetSeconds(timeRange.duration)
            let result = startSeconds + durationSecound
            return result
        }else{
            return 0
        }
        
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "loadedTimeRanges"{
            //            通过监听AVPlayerItem的"loadedTimeRanges"，可以实时知道当前视频的进度缓冲
            
            
            let loadedTime = avalableDurationWithplayerItem()
            let totalTime = CMTimeGetSeconds((playerPub.currentItem?.duration)!)
            let percent = loadedTime/totalTime
            
            controlVView.progressView.progress = Float(percent)
            controlHView.progressView.progress = Float(percent)
        }else if keyPath == "status"{
            
            if let player:AVPlayer = object as? AVPlayer {
                
                if player.status == .readyToPlay {
                    
                    
                    Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (_) in
                        UIView.animate(withDuration: 1) {
                            [weak me = self] in
                            
                            if me?.netWaitingImageView != nil{
                                me?.netWaitingImageView.alpha = 0
                            }
                        }
                    })
                    
                    Timer.scheduledTimer(withTimeInterval: 1.9, repeats: false, block: { [weak me = self] (_) in
                        me?.netWaitingImageView.isHidden = true
                        me?.netWaitingImageView.alpha = 1
                        
                    })
                    
                }
            }
            
            
        }
        
        
    }
    var playObserver:Any!
    
    func actionPlayExitLog() {
        if playerPub != nil {
            if playerPub.status == AVPlayerStatus.readyToPlay{
                let currentTime = controlVView.videoPlaySlider.value * Float(CMTimeGetSeconds(playerPub.currentItem!.duration))
                
                playSeekTimeDic.setValue(currentTime, forKey: video_idLog)
            }
        }
    }
    
    deinit {
        
        actionPlayExitLog()
        if (playerPub != nil) {
            playerPub.removeTimeObserver(playObserver)
            playerPub.removeObserver(self, forKeyPath: "status")
            playerPub.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        }
        
        UserDefaults.standard.set(playSeekTimeDic, forKey: "playSeekTimeDic")
    }
    


}
