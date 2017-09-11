//
//  iphone6Adapter.swift
//  SmartShop
//
//  Created by Alfred on 16/4/16.
//  Copyright © 2016年 开发者. All rights reserved.
//

import UIKit


let iPhoneWidth=UIScreen.main.bounds.size.width
let iPhoneHeigt=UIScreen.main.bounds.size.height


class Debug:NSObject{
    static let isRelease = false
    static func log(_ item:Any){
        if !isRelease {
            if let dic = item as? NSDictionary {
                let data = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                let str = String.init(data: data ?? Data(), encoding: .utf8)!
                print(str)
            }else{
                print(item)
            }
        }
    }
}



let autoSizeScale : CGFloat = iPhoneWidth/375

public func CGRectMakeiphone6Adapter (_ x:CGFloat,_ y:CGFloat,_ width:CGFloat, _ height:CGFloat) -> CGRect {

    let rect : CGRect = CGRect(x: x*autoSizeScale ,y: y*autoSizeScale,width: width*autoSizeScale,height: height*autoSizeScale)
    
    return rect;
    
}



public func formatPlayTime(_ secounds:TimeInterval)->String{
    if secounds.isNaN{
        return "00:00"
    }
    let Min = Int(secounds / 60)
    let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
    return String(format: "%02d:%02d", Min, Sec)
}

public func getTodayDate(addingDays:Int)->(String){//算今天之后的多少天的日期
    let now = Date()
    let days:TimeInterval = TimeInterval(24*60*60*1*addingDays)
    let theDate = now.addingTimeInterval(days)
    // 创建一个日期格式器
    let dformatter = DateFormatter()
    dformatter.dateFormat = "yyyy年MM月dd日"
    let str = dformatter.string(from: theDate)
    return str
    
}

public func getDateWithTimeInterval(_ timeInterval:TimeInterval)->(String){//通过时间戳获取时间
    let theDate = Date.init(timeIntervalSince1970: timeInterval)    // 创建一个日期格式器
    let dformatter = DateFormatter()
    dformatter.dateFormat = "yyyy-MM-dd"
    let str = dformatter.string(from: theDate)
    return str
    
}

public func getTimeText(time:NSInteger)->(String){
    let min = time / 60
    let sec = time % 60
    let str = "\(min):\(sec)"
    return str
}



open class UImyViewSetting {

    var bottonHeight:CGFloat
    
    func myViewtoUIView(_ begin:CGFloat,_ height:CGFloat)->UIView{
        let myView:UIView=UIView.init(frame: CGRectMakeiphone6Adapter(0, begin, 375, height))
        myView.backgroundColor=UIColor.white
        return myView
    }
    
    init(bottonHeight:CGFloat) {
        self.bottonHeight=bottonHeight
    }
    
}



open class mySwiftButton : UIButton{
    open var price:String!
    public init(frame: CGRect,price:String) {
        super.init(frame:frame)
        self.price=price
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}





extension UIView{
    func myUIView(_ begin:CGFloat,_ height:CGFloat)->UIView{
        frame = CGRectMakeiphone6Adapter(0, begin, 375, height)
        self.backgroundColor=UIColor.white
        return self
    }
    func addLabel(_ frame:CGRect,_ text:String!,_ size:CGFloat,_ alignment:NSTextAlignment,_ color:UIColor) -> UILabel! {
        
        let label:UILabel=UILabel.init(frame: frame)
        label.font=UIFont.systemFont(ofSize: size)
        label.textAlignment=alignment
        label.text=text
        label.textColor=color
        self.addSubview(label)
        return label
    }
    func addImageView(_ frame:CGRect,_ image:String!) -> UIImageView {
        let imageView = UIImageView.init(frame: frame)
        if (image != nil) {
            imageView.image = UIImage.init(named: image)
        }
        imageView.isUserInteractionEnabled = true;
        self.addSubview(imageView);
        return imageView;
    }
    func hitTest(_ p: CGPoint) -> UIView? {
        return hitTest(p, with: nil)
    }
}

extension UILabel{
    convenience init(addtoView:UIView,_ labelFrame:CGRect,_ labelText:String,_ fontSize:CGFloat) {
        self.init(frame: labelFrame)
        //        myUIlabel(addtoView, labelFrame, labelText, fontSize)
    }
    func myUIlabel(_ addtoView:UIView,_ labelFrame:CGRect,_ labelText:String,_ fontSize:CGFloat)->UILabel{
        
        self.text=labelText
        self.font=UIFont.systemFont(ofSize: fontSize)
        addtoView.addSubview(self)
        
        return self
    }
}



extension CGFloat {
    static func random(_ max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

extension UIColor {
    class var random: UIColor {
        switch arc4random()%5 {
        case 0: return UIColor.green
        case 1: return UIColor.blue
        case 2: return UIColor.orange
        case 3: return UIColor.red
        case 4: return UIColor.purple
        default: return UIColor.black
        }
    }
    
    class func colorHex(hex:Int,alpha:CGFloat)->UIColor{
        return UIColor.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255, green: CGFloat((hex & 0xFF00) >> 8) / 255, blue: CGFloat((hex & 0xFF)) / 255, alpha: alpha)
    }
    class func colorHex(hex:Int)->UIColor{
        return UIColor.colorHex(hex: hex, alpha: 1)
    }

}

extension CGRect {
    var mid: CGPoint { return CGPoint(x: midX, y: midY) }
    var upperLeft: CGPoint { return CGPoint(x: minX, y: minY) }
    var lowerLeft: CGPoint { return CGPoint(x: minX, y: maxY) }
    var upperRight: CGPoint { return CGPoint(x: maxX, y: minY) }
    var lowerRight: CGPoint { return CGPoint(x: maxX, y: maxY) }
    
    init(center: CGPoint, size: CGSize) {
        let upperLeft = CGPoint(x: center.x-size.width/2, y: center.y-size.height/2)
        self.init(origin: upperLeft, size: size)
    }
}



extension UIBezierPath {
    class func lineFrom(_ from: CGPoint, to: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)
        return path
    }
}


open class navBase:UINavigationController{
    open override var shouldAutorotate: Bool{
        return (self.topViewController?.shouldAutorotate) ?? false
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return (self.topViewController?.supportedInterfaceOrientations) ?? .portrait
    }
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return (self.topViewController?.preferredInterfaceOrientationForPresentation)!
    }
}

