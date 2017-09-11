//
//  VideoDetailShareView.swift
//  MMFinancialSchool
//
//  Created by Alfred on 2017/8/10.
//  Copyright © 2017年 linweibiao. All rights reserved.
//

import UIKit

class VideoDetailShareView: UIView {

    @IBAction func navBack(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    var fatherView:UIView! {
        didSet{
            fatherView.addSubview(self)
            self.frame = fatherView.bounds
        }
    }
    
    @IBAction func 微信好友ButtonClicked(_ sender: UIButton) {
        Debug.log("微信好友ButtonClicked")
    }
    
    @IBAction func 朋友圈ButtonClicked(_ sender: UIButton) {
        Debug.log("朋友圈ButtonClicked")
    }
    
   

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    //MARK:- 微信朋友圈
    /**
     *  微信朋友圈
     */
    //    SSDKPlatformSubTypeWechatTimeline
//    func shareSDKWX(title:String, subTitle:String, video_id:String, type:SSDKPlatformType){
        // 1.创建分享参数
//        
        
        //2.进行分享
//        ShareSDK.share(type, parameters: shareParames) 
//    }

}
