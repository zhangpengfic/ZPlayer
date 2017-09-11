//
//  VideoDetailViewController.swift
//  MMFinancialSchool
//
//  Created by Alfred on 2017/4/22.
//  Copyright © 2017年 linweibiao. All rights reservevar//

import UIKit
import AVKit
import AVFoundation


enum PlayWay {
    case online, local
}

class VideoDetailViewController: UIViewController {

    
    override var shouldAutorotate : Bool {
        return true
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait, .landscapeLeft,.landscapeRight,.portraitUpsideDown]
    }
    //MARK: - ShowLabel
    
    
    @IBOutlet weak var coursePrice: UILabel!
    @IBOutlet weak var 下载Button: UIButton!
    @IBOutlet weak var 赚奖学金Button: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    
    
    //MARK: - DetailTableViewControl

 
    
    @IBOutlet weak var defaultButton: UIButton!{
        didSet{
            defaultButton.isSelected = true
            selectedButton = defaultButton
        }
    }
    
    
    @IBOutlet weak var lineHCConstraint: NSLayoutConstraint!
    @IBOutlet weak var 课程评价Button: UIButton!
    var selectedButton:UIButton!
    @IBAction func buttonsClicked(_ sender: UIButton) {
        
        if (selectedButton != nil) {
            selectedButton.isSelected = false
        }
        sender.isSelected = true
        
        
        
        switch sender.tag {
        case 1:
            
           
            UIView.animate(withDuration: 0.25, animations: {[weak me = self] in
                me?.lineHCConstraint.constant = -iPhoneWidth/3
                self.view.layoutIfNeeded()
            })
        case 2:
            
            UIView.animate(withDuration: 0.25, animations: {[weak me = self] in
                me?.lineHCConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        case 3:
            
            UIView.animate(withDuration: 0.25, animations: {[weak me = self] in
                me?.lineHCConstraint.constant = iPhoneWidth/3
                self.view.layoutIfNeeded()
            })
            
        default:
            break
        }
        selectedButton = sender
        
        
    }
    
    //MARK:- PlayerControl------------------------------------
    
    @IBOutlet weak var ShareView: VideoDetailShareView!
    
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        Debug.log("shareButtonClicked")
        ShareView.fatherView = view
    }
    
    @IBAction func shareButtonHClicked(_ sender: UIButton) {
        Debug.log("shareButtonHClicked")
        ShareView.fatherView = videoView
    }

    var video_id = ""
    var video_idLog = ""//日志里记录的video_id和视频播放纪录里的Key
    
    
    var url = "" {
        didSet{
            
            videoView.video_idLog = video_idLog
            videoView.url = url
        }
    }
    var filePath = "" {
        didSet{
            
            videoView.video_idLog = video_idLog
            videoView.filePath = filePath
        }
    }
    
    
    
    
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


    
    @IBOutlet weak var 立即学习Button: UIButton!
    @IBAction func 立即学习Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        Debug.log("立即学习Clicked")
        fristPlayHidden(sender)
        
    }

    @IBAction func fristPlayHidden(_ sender: UIButton) {
    
        
        (UIApplication.shared.delegate as! AppDelegate).allowRotation = true
        playButton.isHidden = true
//        playURL("https://devstreaming-cdn.apple.com/videos/wwdc/2017/102xyar2647hak3e/102/hls_vod_mvp.m3u8")
        playURL("https://devstreaming-cdn.apple.com/videos/wwdc/2017/703muvahj3880222/703/hls_vod_mvp.m3u8")
    }
    
    enum playType {
        case play, noLogin, nopay
    }
    
    
    func playURL(_ urlString:String){
        //  如果有封面加播放器应该放这里
        videoView.fatherView = videoBackgroundView
        videoView.holdImage = UIImage.init(named: "NetWaiting")
//      url = "http://vid.phjrxy.cn/20170531-Wangyue-ruhemaiertongbaoxiaobubeikeng-01-2.mp4"
        url = urlString
        videoView.playerPub.play()
        
    }
   
    var isPlaying = false{
        didSet{
            if isPlaying == true {
                controlHView.playAndPauseButton.isSelected = true
                controlVView.playAndPauseButton.isSelected = true
            }else{
                controlHView.playAndPauseButton.isSelected = false
                controlVView.playAndPauseButton.isSelected = false
            }
        }
    }
    
    
    @IBAction func playAndPause() {
        Debug.log("playAndPause")

        if isPlaying == true {
            videoView.playerPub.pause()
            
            isPlaying = false
        }else{
            videoView.playerPub.play()
            
            isPlaying = true
        }
        
        
    }
 
    
    
    @IBOutlet weak var videoView: VedioPlayerView!
    @IBOutlet weak var videoBackgroundView: UIView!{
        didSet{
            videoView.frame = videoBackgroundView.bounds
            
//没有封面的情况直接加播放器
//            videoView.fatherView = videoBackgroundView
        }
    }
  
    
    
    //MARK: - ControlViewGestures
   
    @IBOutlet weak var TapGestureRecognizerOneTappes: UITapGestureRecognizer!
    @IBAction func videoViewOneTap(_ sender: UITapGestureRecognizer) {
        Debug.log("controlViewClicked")
        
        
        if playButton.isHidden == true {
            controlVView.frame = videoBackgroundView.bounds
            var alpha = CGFloat(0.50)
            if self.controlVView.alpha == CGFloat(0.50) {
                alpha = 0
            }
            UIView.animate(withDuration: 0.6) {
                self.controlVView.alpha = CGFloat(alpha)
                self.controlHView.alpha = CGFloat(alpha)
                
            }
        }
        
    }
    
    @IBOutlet weak var TapGestureRecognizerTwoTappes: UITapGestureRecognizer!{
        didSet{
           TapGestureRecognizerOneTappes.require(toFail: TapGestureRecognizerTwoTappes)
        }
    }
    @IBAction func videoViewTwoTappes(_ sender: UITapGestureRecognizer) {
        Debug.log("videoViewTwoTappes")
        playAndPause()
    }
    
    
    //MARK: - life
    
    @IBAction func backNav(_ sender: UIButton) {
       
        navigationController?.popViewController(animated: true)
        
    }
    
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (UIApplication.shared.delegate as! AppDelegate).allowRotation = false
        
        playButton.isHidden = false
        controlVView.fullScreenButton.isSelected = false
        lineHCConstraint.constant = -iPhoneWidth / 3
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoView.playerPub.pause()
        (UIApplication.shared.delegate as! AppDelegate).allowRotation = false
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
    @IBAction func 赚奖学金ButtonClicked(_ sender: UIButton) {
        Debug.log("赚奖学金ButtonClicked")
        
        
        
        
    }
    @IBAction func 下载ButtonClicked(_ sender: UIButton) {
        
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       
        
        
    }
 
    
    
    
    
    deinit {
        videoView.removeFromSuperview()
        
    }
    
    
    
    
}
