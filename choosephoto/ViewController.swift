//
//  ViewController.swift
//  choosephoto
//
//  Created by 神楽坂雅詩 on 2017/7/21.
//  Copyright © 2017年 KagurazakaYashi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var 图像列表框: UICollectionView!
    @IBOutlet weak var 实时预览框: UIImageView!
    @IBOutlet weak var 底部工具栏: UITabBar!
    
    var 摄像头权限: AVAuthorizationStatus!
    var 视频捕获预览: AVCaptureVideoPreviewLayer!
    var 视频捕获会话: AVCaptureSession!
    var 视频捕获输入: AVCaptureDeviceInput!
    var 视频捕获输出: AVCaptureVideoDataOutput!
    var 视频捕获启动:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        初始化照相机()
    }
    
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
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case AVAuthorizationStatus.authorized:
            //已获得相关权限
            摄像头权限 = AVAuthorizationStatus.authorized
            return true
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if(granted){
                    self.摄像头权限 = AVAuthorizationStatus.restricted
                    print("没有摄像头访问权限！")
                }
            })
            return false
        case AVAuthorizationStatus.denied:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (已授权: Bool) -> Void in
                if(!已授权){
                    self.摄像头权限 = AVAuthorizationStatus.denied
                    let 摄像头权限申请提示框:UIAlertController = UIAlertController(title: "需要摄像头权限", message: "你需要在系统设置中允许我访问摄像头，要现在跳转到设置吗？", preferredStyle: UIAlertControllerStyle.alert)
                    摄像头权限申请提示框.addAction(UIAlertAction(title: "进入设置", style: UIAlertActionStyle.default, handler: { (此摄像头权限申请提示框:UIAlertAction) in
                        //Y
                    }))
                    摄像头权限申请提示框.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (此摄像头权限申请提示框:UIAlertAction) in
                        //N
                    }))
                    self.present(摄像头权限申请提示框, animated: true, completion: nil)
                }
            })
            return false
        default:
            print("摄像头访问权限未知。")
            return false
        }
    }
    
    func 初始化照相机() -> Bool {
        视频捕获会话 = AVCaptureSession()
        let 视频捕获设备:AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.video)
        if (视频捕获设备 == nil) {
            print("没能启动视频捕获设备")
            return false
        }
        视频捕获输出 = AVCaptureVideoDataOutput()
        do{
            try 视频捕获输入 = AVCaptureDeviceInput(device: 视频捕获设备!)
        } catch let error as NSError {
            print("视频捕获失败: ",error)
            return false
        }
        if 检查是否有摄像头权限() == false {
            return false
        }
        视频捕获会话.beginConfiguration()
        视频捕获会话.sessionPreset = AVCaptureSession.Preset.hd1280x720
        let 视频像素模式K = kCVPixelBufferPixelFormatTypeKey as String
        let 视频像素模式V = NSNumber(value: kCVPixelFormatType_32BGRA)
        let 视频像素宽度K = kCVPixelBufferWidthKey as String
        let 视频像素宽度V = NSNumber(value: 1280)
        let 视频像素高度K = kCVPixelBufferHeightKey as String
        let 视频像素高度V = NSNumber(value: 720)
        视频捕获输出.videoSettings = [视频像素模式K:视频像素模式V, 视频像素宽度K:视频像素宽度V, 视频像素高度K:视频像素高度V]
        if(视频捕获会话.canAddInput(视频捕获输入)){
            视频捕获会话.addInput(视频捕获输入)
        } else {
            print("视频捕获输入设置失败！")
            return false
        }
        if(视频捕获会话.canAddOutput(视频捕获输出)){
            视频捕获会话.addOutput(视频捕获输出)
        } else {
            print("视频捕获输出设置失败！")
            return false
        }
        let 视频捕获线程 = DispatchQueue(label: "subQueue")
        视频捕获输出.setSampleBufferDelegate(self, queue: 视频捕获线程)
        
        视频捕获预览 = AVCaptureVideoPreviewLayer(session: 视频捕获会话)
        视频捕获预览.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        视频捕获预览.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(视频捕获预览)
//        视频捕获预览.isHidden = true
        
        视频捕获会话.commitConfiguration()
        视频捕获启动 = true
        return true
    }
    
    func 从数据流创建图片(缓冲区:CMSampleBuffer!) -> UIImage {
        let 图片缓冲区:CVImageBuffer = CMSampleBufferGetImageBuffer(缓冲区)!
        CVPixelBufferLockBaseAddress(图片缓冲区, CVPixelBufferLockFlags(rawValue: 0))
        let 逐行大小:size_t = CVPixelBufferGetBytesPerRow(图片缓冲区)
        let 宽度:size_t = CVPixelBufferGetWidth(图片缓冲区)
        let 高度:size_t = CVPixelBufferGetHeight(图片缓冲区)
        let 安全点:UnsafeMutableRawPointer = CVPixelBufferGetBaseAddress(图片缓冲区)!
        let 位图信息:UInt32 = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        let 色彩空间: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let 画布:CGContext = CGContext(data: 安全点, width: 宽度, height: 高度, bitsPerComponent: 8, bytesPerRow: 逐行大小, space: 色彩空间, bitmapInfo: 位图信息)!
        let 取出图片: CGImage = 画布.makeImage()!
        CVPixelBufferUnlockBaseAddress(图片缓冲区, CVPixelBufferLockFlags(rawValue: 0))
        return UIImage(cgImage: 取出图片, scale: 1, orientation: UIImageOrientation.right)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let 当前图片 = 从数据流创建图片(缓冲区: sampleBuffer)
        DispatchQueue.main.async() { () -> Void in
            self.实时预览框.image = 当前图片
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        视频捕获会话.startRunning()
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

