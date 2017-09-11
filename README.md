# ZPlayer
# Swift3 改写ZFPlayer代码更简洁


# 摘      要

##AVPlayer是用于管理媒体资产的播放和定时控制器对象它提供了控制播放器的接口，如它可以在媒体的时限内播放，暂停，和改变播放的速度，并有定位各个动态点的能力。可以使用AVPlayer来播放本地和远程的视频媒体文件，如QuickTime影片和MP3音频文件，以及视听媒体使用HTTP流媒体直播服务。

###关键词：m3u8流媒体， AVPlayer， iOS视频播放器，自定义播放。  

## 1 AVPlayer播放的两个层
### 1.1 一个普通播放器的组成

![](https://github.com/zhangpengfic/ZPlayer/blob/master/pic/1.png?raw=true)

### 1.2 创建播放层视图类
#### 使用AVPlayer需导入AVFoundation框架

```
    import AVFoundation
```
#### 创建类VideoPlayerView。

```
    internal class VedioPlayerView : UIView {
    ....
    }
```
#### 播放器的初始化，在VedioPlayerView里创建AVPLayerLayer并把AVPlayer加入

```
    playerLayer = AVPlayerLayer.init(player: self.playerPub)
```
#### 注意这里也可以先加AVURLAsset，本例未使用这个方式，self.asset可以记录缓存大小，而使用AVURLAsset初始化URL代码太复杂。
#### 接着设置下播放窗口大小为试图大小并加到视图的层上。

```
    playerLayer.frame = self.bounds
    self.layer.addSublayer(playerLayer)
```
#### 播放层视图类里的属性以及其作用（注释）

```
    internal var playerLayer: AVPlayerLayer! //播放层可添加其到指定的View，这里添加到self.layer
    internal var playerPub: AVPlayer! //播放的视频，苹果原生播放控件
    internal var url: String! //播放的网络地址
    internal var fatherView: UIView! //放置playerPub的View
    internal var holdImage: UIImage! //播放前显示的图片
    internal var playSeekTimeDic: NSMutableDictionary! //记录播放时间的字典
```
#### 视频播放需大量使用KVO和NSNotificationCenter

```
    NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: .UIApplicationWillResignActive, object: nil) //播放退到后台通知
    NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil) //播放进入前台通知
    NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate(notification:)), name: .UIDeviceOrientationDidChange, object: nil) //屏幕旋转通知
    NotificationCenter.default.addObserver(self, selector: #selector(videoPlayEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil) //播放结束通知
```
### 1.3 创建控制层视图类
#### 控制层在视频视图层的上面一层，用来控制视频的播放，如图
![](https://github.com/zhangpengfic/ZPlayer/blob/master/pic/2.png?raw=true
)
#### 创建类ControlView。控制层在视频视图的上面一层，用来控制视频的播放

```
    internal class ControlView: UIView {
    }
```
#### 拖拽按钮到控制层视图类里，其属性以及其作用如下：

```
    @IBOutlet weak internal var timelabel: UILabel! //记录播放时间的字典
    @IBOutlet weak internal var fullScreenButton: UIButton! //记录播放时间的字典
    @IBOutlet weak internal var progressView: UIProgressView! //记录播放时间的字典
    @IBOutlet weak internal var videoPlaySlider: UISlider! //记录播放时间的字典
    @IBOutlet weak internal var lightSlider: UISlider! //记录播放时间的字典
```
## 2 AVPlayer的功能和组成
#### 基于AVPlayer封装的轻量级播放器,可以播放本地网络视频,易于定制，适合初学者学习打造属于自己的视频播放器
### 2.1 初始化播放器和配置
#### 2.1.1播放器的初始化
##### 以下代码完成初始化。

```
    playerPub = AVPlayer.init(url: URL.init(string: url)!) //初始化一个播放URL地址的播放器
    let seconds = playSeekTimeDic.value(forKey: video_idLog) as? Float ?? 0.0 //取出上次播放的时间位置
    let cmTime = CMTime.init(seconds: Double(seconds), preferredTimescale: 1) //类型转换
    playerPub.seek(to: cmTime) //播放上次记录的位置
```
#### 2.1.2播放窗口放置方式videoGravity
##### 放置方式有以下三种：
##### 1. AVLayerVideoGravityResizeAspect 按比例填充
##### 2. AVLayerVideoGravityResizeAspectFill 按比例最大化填充
##### 3. AVLayerVideoGravityResize 拉伸填充
##### 这里使用按比例最大化填充

```
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
```
#### 2.1.3如果播放时需要显示视频里附带的字母可以设置显示字幕

```
    let item = playerPub.currentItem
    let asset = item?.asset
    let group = asset?.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible)
    let locale = Locale.init(identifier: "zh_CN")
    let options = AVMediaSelectionGroup.mediaSelectionOptions(from: (group?.options)!, with: locale)
    item?.select(options.first, in: group!)
```
### 2.2 横屏全屏以及旋转
#### 点击全屏按钮或者旋转手机的时候，判断旋转方向并全屏播放。
```
    @IBAction func fullScreenButtonClicked(_ sender: UIButton) { //点击横竖屏切换按钮进行横竖屏切换
        if UIDevice.current.orientation == UIDeviceOrientation.portrait {//切换到横屏
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            sender.isSelected = true
        }else{//切换到竖屏
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            sender.isSelected = false
        } 
    }
```
#### 收到系统屏幕旋转的通知调用deviceDidRotate方法。
```
    func deviceDidRotate(notification:NSNotification){
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation){ 
           //横屏时
        }else{
           //竖屏时
        }
    }
```
#### 当横屏时播放窗口放置在APP最上层，竖屏时销毁。横屏时调用的方法主要完成以下任务。
```
    self.removeFromSuperview() //在父窗口里移除播放器
    self.frame = HorizontalFrame //播放器横屏全屏尺寸
    playerLayer.frame = self.bounds //播放层横屏全屏尺寸
    controlView.frame = playerLayer.frame //控制层视图横屏全屏尺寸
    controlView.fullScreenButton.isSelected = true //控制层全屏按钮变为选中状态
    UIApplication.shared.keyWindow?.addSubview(self) //把播放器加在视图最上层
```
#### 竖屏时调用的方法主要完成以下任务。
```
    self.removeFromSuperview() //在父窗口里移除播放器
    self.frame = VerticalFrame //播放器竖屏窗口尺寸
    playerLayer.frame = self.bounds //播放层竖屏窗口尺寸
    controlView.fullScreenButton.isSelected = false //控制层全屏按钮变为未选中状态
    fatherView.addSubview(self) //把播放器加回原先fatherView竖屏的窗口
```
### 2.3 进度条
![](https://github.com/zhangpengfic/ZPlayer/blob/master/pic/3.png?raw=true
)
#### 刷新进度条包括，1当前时间显示、2进度百分比。在播放器里添加一个观察者每一秒钟监听一次并刷新进度。
```
    playerPub.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 2), queue: DispatchQueue.main) { (time) in
          let currentTime = self.playerPub.currentTime() //获取当前播放时间
          let totalTime = self.playerPub.currentItem?.duration //获取当总播放时间
          let progress = CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(totalTime!) //播放进度百分比
          let text = "\(formatPlayTime(CMTimeGetSeconds(currentTime)))/\(formatPlayTime(CMTimeGetSeconds(totalTime!)))" //时间文字
          self.controlVView.videoPlaySlider.value = Float(progress) //刷新播放进度百分比
          self.controlVView.timelabel.text = text //刷新时间文字
     }

```
### 2.4 前后台切换播放
#### 收到系统播放退到后台的通知调用appWillResignActive方法。
#### 收到系统播放进入前台的通知调用appDidBecomeActive方法。
#### 以下是开启后台播放的方法。
```
    func appWillResignActive(){
        playerLayer.player = nil  //开启后台播放功能
    }
    func appDidBecomeActive() {
        playerLayer.player = playerPub  //回到前台播放
    }
```
### 2.5 播放的销毁
#### 当播放器被父视图移除时候（removefromSuperView()）会调用播放视图的deinit()方法。需要同时销毁观察者和纪录退出时的播放时间。
```
    deinit {
        if (playerPub != nil) {
            playerPub.removeTimeObserver(playObserver)
            playerPub.removeObserver(self, forKeyPath: "status")
            playerPub.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
            UserDefaults.standard.set(playSeekTimeDic, forKey: "playSeekTimeDic")
        } 
    }
```
## 3  使用封装好的AVPlayer
### 3.1 播放的加载
```
    func playURL(_ urlString:String){
        videoView.fatherView = videoBackgroundView  //指定播放放到的视图
        videoView.holdImage = UIImage.init(named: "NetWaiting") //播放的封面图
        videoView.url = urlString //播放的网络地址
        videoView.playerPub.play()//开始播放
    }
```
### 3.2 播放\暂停
#### 在视图控制器ViewController加入播放、暂停按钮的点击事件
```
    @IBAction func playAndPause() {
        if isPlaying == true {
            videoView.playerPub.pause()
            isPlaying = false
        }else{
            videoView.playerPub.play()
            isPlaying = true
        }
    }
```
### 3.3 手势的调用
#### 在手势添加在播放视图上。方法和属性添加到控制器中。
![](https://github.com/zhangpengfic/ZPlayer/blob/master/pic/4.png?raw=true
)
#### 在视图控制器ViewController加入单击播放窗口出现控制视图，再次点击控制视图消失。
```
    @IBOutlet weak var TapGestureRecognizerOneTappes: UITapGestureRecognizer!
    @IBAction func videoViewOneTap(_ sender: UITapGestureRecognizer) { 
        if playButton.isHidden == true {
            var alpha = CGFloat(0.50)
            if self.controlVView.alpha == CGFloat(0.50) { //显示和消失状态切换
                alpha = 0
            }
            UIView.animate(withDuration: 0.6) { //切换时的动画
                self.controlView.alpha = CGFloat(alpha) 
            }
        }
    }
```
### 3.4 分享等自定义其他功能
#### 在视图控制器ViewController拖入分享图标的方法让ShareView弹出到控制器的view视图的最上层。其他功能的加法以此类推。
![](https://github.com/zhangpengfic/ZPlayer/blob/master/pic/5.png?raw=true
)![](https://github.com/zhangpengfic/ZPlayer/blob/master/pic/6.png?raw=true
)

```
    @IBOutlet weak var ShareView: VideoDetailShareView!
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        ShareView.fatherView = view
    }
```

## 4 结束语
#### 表述能力有限，如果大家喜欢的话，希望进入github网址star一下
#### 我的github：https://github.com/zhangpengfic/ZPlayer 




