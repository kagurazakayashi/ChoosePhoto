//
//  ViewController.swift
//  choosephoto
//
//  Created by 神楽坂雅詩 on 2017/7/21.
//  Copyright © 2017年 KagurazakaYashi. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

public let 全局主题颜色:[CGColor] = [UIColor(red: 0, green: 158/255, blue: 212/255, alpha: 1).cgColor,UIColor(red: 39/255, green: 224/255, blue: 36/255, alpha: 1).cgColor,UIColor(red: 241/255, green: 158/255, blue: 194/255, alpha: 1).cgColor]
public let 全局故事板:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate, UITabBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var 图像列表框: UICollectionView!
    @IBOutlet weak var 实时预览框: UIImageView!
    @IBOutlet weak var 底部工具栏: UITabBar!
    
    var 摄像头权限: AVAuthorizationStatus!
    var 视频捕获预览: AVCaptureVideoPreviewLayer!
    var 视频捕获会话: AVCaptureSession!
    var 视频捕获输入: AVCaptureDeviceInput!
    var 视频捕获输出: AVCaptureVideoDataOutput!
    var 视频捕获设备:AVCaptureDevice? = nil
    var 视频捕获启动:Bool = false
    var 正在复位底部工具栏:Bool = false
    var 列表数据:[UIImage] = [UIImage]()
    var 正在使用后摄像头 = false
    var 缩略图布局 = UICollectionViewFlowLayout()
    
    override func viewDidAppear(_ animated: Bool) {
        if 检查是否有摄像头权限() == false {
            print("没有权限访问摄像头")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        初始化外观()
        底部工具栏.delegate = self
        
        视频捕获会话 = AVCaptureSession()
        视频捕获输出 = AVCaptureVideoDataOutput()
        if 前后摄像头切换() == false {
            print("摄像头获取失败")
            return
        }
        if (初始化照相机() == false) {
            print("照相机初始化失败")
            return
        }
        视频捕获会话.startRunning()
    }
    
    func 初始化外观() {
        实时预览框.layer.borderWidth = 1
        实时预览框.layer.borderColor = 全局主题颜色[2]
        图像列表框.collectionViewLayout = 缩略图布局
        缩略图布局.itemSize = CGSize(width: 图像列表框.frame.width / 2, height: 图像列表框.frame.height / 2)
        缩略图布局.minimumLineSpacing = 10.0  //上下间隔
        缩略图布局.minimumInteritemSpacing = 1.0 //左右间隔
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        if (正在复位底部工具栏 == true) {
//            正在复位底部工具栏 = false
//            return
//        }
        if tabBar.tag == 1000 {
            switch item.tag {
            case 1001: //清空
                列表数据.removeAll()
                图像列表框.reloadData()
                break
            case 1002: //拍摄
                缓存照片()
                break
            case 1003: //设置
                打开系统设置页面()
                break
            case 1004: //补光
                补光()
                break
            case 1005: //前后摄像头切换
                if (前后摄像头切换() == false)
                {
                    print("切换失败或设备没有前摄像头")
                }
                break
            default:
                break
            }
        }
//        正在复位底部工具栏 = true
    }
    
    func 缓存照片() {
        if 列表数据.count > 30 {
            print("一次只能临时保存30张。")
        } else if (实时预览框.image != nil) {
            列表数据.append(实时预览框.image!)
            图像列表框.reloadData()
        }
    }
    func 补光() {
        if !正在使用后摄像头 {
            print("前置摄像头没有闪光灯")
            return
        }
        if 视频捕获设备 == nil {
            print("没有找到闪光灯。")
            return
        }
        if 视频捕获设备!.torchMode == AVCaptureDevice.TorchMode.off{
            do {
                try 视频捕获设备!.lockForConfiguration()
            } catch {
                return
            }
            视频捕获设备!.torchMode = .on
            视频捕获设备!.unlockForConfiguration()
        } else {
            do {
                try 视频捕获设备!.lockForConfiguration()
            } catch {
                return
            }
            视频捕获设备!.torchMode = .off
            视频捕获设备!.unlockForConfiguration()
        }
    }
    func 前后摄像头切换() -> Bool {
//        断开摄像头连接()
        if 正在使用后摄像头 {
            视频捕获设备 = 获得摄像头(摄像头位置: AVCaptureDevice.Position.front)
        } else {
            视频捕获设备 = 获得摄像头(摄像头位置: AVCaptureDevice.Position.back)
        }
        正在使用后摄像头 = !正在使用后摄像头
        if (视频捕获设备 == nil) {
            print("没能启动视频捕获设备")
            return false
        }
        视频捕获会话.beginConfiguration()
        if 视频捕获启动 {
            视频捕获会话.removeInput(视频捕获输入)
        }
        do{
            try 视频捕获输入 = AVCaptureDeviceInput(device: 视频捕获设备!)
        } catch let error as NSError {
            print("视频捕获失败: ",error)
            return false
        }
        if(视频捕获会话.canAddInput(视频捕获输入)){
            视频捕获会话.addInput(视频捕获输入)
        } else {
            print("视频捕获输入设置失败！")
            return false
        }
        视频捕获会话.commitConfiguration()
        return true
    }
    func 断开摄像头连接() {
        if 视频捕获启动 {
            视频捕获会话.beginConfiguration()
            视频捕获会话.removeInput(视频捕获输入)
            视频捕获会话.removeOutput(视频捕获输出)
            视频捕获会话.commitConfiguration()
        }
        视频捕获会话 = nil
        视频捕获输入 = nil
        视频捕获输出 = nil
        视频捕获设备 = nil
        实时预览框.image = nil
        视频捕获启动 = false
    }
    func 获得摄像头(摄像头位置:AVCaptureDevice.Position) -> AVCaptureDevice? {
        let 视频设备会话:AVCaptureDevice.DiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: 摄像头位置)
        let 视频设备列表 = 视频设备会话.devices
        for 视频设备:AVCaptureDevice in 视频设备列表 {
            if 视频设备.position == 摄像头位置 {
                return 视频设备
            }
        }
        return nil
    }
    
    //<tabBar代理>
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 列表数据.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let 列表项:ImgCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgcell", for: indexPath) as! ImgCollectionViewCell
        列表项.设置缩略图(图片: 列表数据[indexPath.row])
        return 列表项
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let 图片浏览器:ImgViewController = 全局故事板.instantiateViewController(withIdentifier: "ImgViewController") as! ImgViewController
        self.present(图片浏览器, animated: true) {
            print("打开图片浏览器")
        }
        
        // TODO:怎么又崩溃啊喵
        if (indexPath.row < 列表数据.count) {
            图片浏览器.装入图片(图片: 列表数据[indexPath.row])
        } else {
            print("无效图片请求",indexPath.row,列表数据.count)
        }
    }
    //</tabBar代理>
    func 打开系统设置页面() {
        let 系统设置页面地址:URL = URL(string: UIApplicationOpenSettingsURLString)!
        if UIApplication.shared.canOpenURL(系统设置页面地址) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(系统设置页面地址, options: [:], completionHandler: {
                    (success) in
                })
            } else {
                UIApplication.shared.openURL(系统设置页面地址)
            }
        }
    }
    
    func 检查是否有摄像头权限() -> Bool {
        摄像头权限 = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if 摄像头权限 == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if(granted){
                    self.摄像头权限 = AVAuthorizationStatus.authorized
                } else {
                    self.摄像头权限 = AVAuthorizationStatus.restricted
                }
            })
        }
        if 摄像头权限 == AVAuthorizationStatus.authorized {
            //已获得相关权限
            return true
        }
        if ( 摄像头权限 == AVAuthorizationStatus.denied || 摄像头权限 == AVAuthorizationStatus.restricted ) {
                    let 摄像头权限申请提示框:UIAlertController = UIAlertController(title: "需要摄像头权限", message: "你需要在系统设置中允许我访问摄像头，要现在跳转到设置吗？", preferredStyle: UIAlertControllerStyle.alert)
                    摄像头权限申请提示框.addAction(UIAlertAction(title: "进入设置", style: UIAlertActionStyle.default, handler: { (此摄像头权限申请提示框:UIAlertAction) in
                        self.打开系统设置页面()
                    }))
                    摄像头权限申请提示框.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (此摄像头权限申请提示框:UIAlertAction) in
                        //N
                    }))
                    self.present(摄像头权限申请提示框, animated: true, completion: nil)
        }
        return false
    }
    
    func 初始化照相机() -> Bool {
        视频捕获会话.beginConfiguration()
        视频捕获会话.sessionPreset = AVCaptureSession.Preset.medium
        let 视频像素模式K = kCVPixelBufferPixelFormatTypeKey as String
        let 视频像素模式V = NSNumber(value: kCVPixelFormatType_32BGRA)
//        let 视频像素宽度K = kCVPixelBufferWidthKey as String
//        let 视频像素宽度V = NSNumber(value: 1280)
//        let 视频像素高度K = kCVPixelBufferHeightKey as String
//        let 视频像素高度V = NSNumber(value: 720)
        视频捕获输出.videoSettings = [视频像素模式K:视频像素模式V] //, 视频像素宽度K:视频像素宽度V, 视频像素高度K:视频像素高度V]
        if(视频捕获会话.canAddOutput(视频捕获输出)){
            视频捕获会话.addOutput(视频捕获输出)
        } else {
            print("视频捕获输出设置失败！")
            return false
        }
        let 视频捕获线程 = DispatchQueue(label: "cameraQueue")
        视频捕获输出.setSampleBufferDelegate(self, queue: 视频捕获线程)
//        视频捕获预览 = AVCaptureVideoPreviewLayer(session: 视频捕获会话)
//        视频捕获预览.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        视频捕获预览.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        self.view.layer.addSublayer(视频捕获预览)
        视频捕获会话.commitConfiguration()
        视频捕获启动 = true
        return true
    }
    
    func 从数据流创建图片(缓冲区:CMSampleBuffer!) -> CGImage? {
        let 图片缓冲区:CVImageBuffer? = CMSampleBufferGetImageBuffer(缓冲区)
        if (图片缓冲区 == nil) {
            print("缓冲区中没有数据！")
            return nil
        }
        CVPixelBufferLockBaseAddress(图片缓冲区!, CVPixelBufferLockFlags(rawValue: 0))
        let 逐行大小:size_t = CVPixelBufferGetBytesPerRow(图片缓冲区!)
        let 宽度:size_t = CVPixelBufferGetWidth(图片缓冲区!)
        let 高度:size_t = CVPixelBufferGetHeight(图片缓冲区!)
        let 安全点:UnsafeMutableRawPointer = CVPixelBufferGetBaseAddress(图片缓冲区!)!
        let 位图信息:UInt32 = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        let 色彩空间: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let 画布:CGContext = CGContext(data: 安全点, width: 宽度, height: 高度, bitsPerComponent: 8, bytesPerRow: 逐行大小, space: 色彩空间, bitmapInfo: 位图信息)!
        let 取出图片: CGImage = 画布.makeImage()!
        CVPixelBufferUnlockBaseAddress(图片缓冲区!, CVPixelBufferLockFlags(rawValue: 0))
        return 取出图片
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if (视频捕获启动 == false) {
            return
        }
        let 当前图片:CGImage? = 从数据流创建图片(缓冲区: sampleBuffer)
        DispatchQueue.main.async() { () -> Void in
            self.输出预览图像(当前图片: 当前图片)
        }
    }
    
    func 输出预览图像(当前图片:CGImage?) {
        var 图片旋转方向:UIImageOrientation = UIImageOrientation.right
        switch UIDevice.current.orientation {
//            case UIDeviceOrientation.portrait:
//                图片旋转方向 = .right
//                break
            case UIDeviceOrientation.portraitUpsideDown:
                图片旋转方向 = .down
                break
            case UIDeviceOrientation.landscapeLeft:
                图片旋转方向 = .up
                break
            case UIDeviceOrientation.landscapeRight:
                图片旋转方向 = .down
                break
//            case UIDeviceOrientation.faceUp:
//                图片旋转方向 = .right
//                break
            default:
                break
        }
        if 当前图片 == nil {
            self.实时预览框.image = nil
        } else {
            self.实时预览框.image = UIImage(cgImage: 当前图片!, scale: 1, orientation: 图片旋转方向)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        视频捕获会话.stopRunning()
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("内存不足！")
    }
    
    
}

