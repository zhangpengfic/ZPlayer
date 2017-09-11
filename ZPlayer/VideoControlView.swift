//
//  VideoControlView.swift
//  MMFinancialSchool
//
//  Created by Alfred on 2017/5/28.
//  Copyright © 2017年 linweibiao. All rights reserved.
//

import UIKit
import MediaPlayer

enum PanDirection {
    case VerticalMoved, HorizontalMoved
}
//protocol VideoControlViewDelegate:NSObjectProtocol {
//    
//    func videoControl(_ playerView:VideoControlView,sliderTouchUpOut slider:UISlider)
//    func videoControl(_ playerView:VideoControlView,playAndPause playBtn:UIButton)
//}

class ControlVView: UIView {
    
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var videoPlaySlider: UISlider!{
        didSet{
            videoPlaySlider.setThumbImage(UIImage(named:"slider_thumb"), for: .normal)
        }
    }
    
    
    
}


class ControlHView: UIView {
    
    
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var videoPlaySlider: UISlider!{
        didSet{
            videoPlaySlider.setThumbImage(UIImage(named:"slider_thumb"), for: .normal)
        }
    }
    
    @IBAction func navBack(_ sender: UIButton) {
        if UIDevice.current.orientation != UIDeviceOrientation.portrait {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
    
    
    
    
}

class SystemVolume {
    static let instance = SystemVolume()
    let volumeView = MPVolumeView.init()
//    volumeView.showsRouteButton = false
//    volumeView.showsVolumeSlider = false
     func getLastVolume(view:UIView) -> Float {
        
        var slider:UISlider!
        for view in volumeView.subviews {
            if view is UISlider {
                slider = view as! UISlider
            }
            
        }
        let volume = slider.value
        return volume
    }
    
     func setLastVolume(value:Float) {
        
        
        var slider:UISlider!
        for view in volumeView.subviews {
            if view is UISlider {
                slider = view as! UISlider
            }
            
        }
        slider.value = value
    }

    
    
}


